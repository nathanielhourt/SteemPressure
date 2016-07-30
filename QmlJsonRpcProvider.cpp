#include "QmlJsonRpcProvider.hpp"

#include <QDebug>

QmlJsonRpcProvider::QmlJsonRpcProvider(QObject* parent)
    : QObject(parent) {}

QJSValue QmlJsonRpcProvider::call(QString method, QVariantList params) {
    if (!m_socket)
        return QJSValue::NullValue;

    QJsonObject call {
        {"jsonrpc", "2.0"},
        {"method",  method},
        {"params",  QJsonValue::fromVariant(params)},
        {"id",      qint64(nextQueryId)}
    };
    QString jsonCall = QJsonDocument(call).toJson(QJsonDocument::JsonFormat::Compact);
    qDebug() << "Making call:" << jsonCall;
    QMetaObject::invokeMethod(m_socket, "sendTextMessage", Q_ARG(QString, jsonCall));

    return *pendingRequests.emplace(std::make_pair(nextQueryId++,
                                                   std::unique_ptr<QmlPromise>(new QmlPromise(this)))).first->second;
}

void QmlJsonRpcProvider::messageReceived(QString message) {
    qDebug() << "Got response:" << message;
    QJsonParseError error;
    auto response = QJsonDocument::fromJson(message.toLocal8Bit(), &error).object();

    if (error.error != QJsonParseError::ParseError::NoError || !response.contains("id") ||
            (!response.contains("error") && !response.contains("result"))) {
        qWarning() << "Got unrecognizeable message back from Bitshares wallet" << message;
        return;
    }

    auto itr = pendingRequests.find(response["id"].toVariant().toLongLong());
    if (itr == pendingRequests.end()) {
        qWarning() << "Got response from Bitshares wallet, but the ID doesn't match any outstanding call:" << message;
        return;
    }

    if (response.contains("result"))
        itr->second->resolve(response["result"].toVariant());
    else
        itr->second->reject(response["error"].toVariant());
    pendingRequests.erase(itr);
}

void QmlJsonRpcProvider::setSocket(QObject* socket) {
    if (m_socket == socket)
        return;

    m_socket = socket;
    if (m_socket)
        connect(m_socket, SIGNAL(textMessageReceived(QString)), this, SLOT(messageReceived(QString)));
    emit socketChanged(socket);
}
