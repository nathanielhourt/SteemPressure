#ifndef JSONRPCPROVIDER_HPP
#define JSONRPCPROVIDER_HPP

#include "Promise.hpp"

#include <memory>

#include <QtWebSockets>

class QmlJsonRpcProvider : public QObject {
    Q_OBJECT
    Q_PROPERTY(QObject* socket READ socket WRITE setSocket NOTIFY socketChanged)

    int64_t nextQueryId = 0;
    std::map<int64_t, std::unique_ptr<QmlPromise>> pendingRequests;

    QObject* m_socket;

public:
    QmlJsonRpcProvider(QObject* parent = nullptr);

    Q_INVOKABLE QJSValue call(QString method, QVariantList params);

    QObject* socket() const { return m_socket; }

public slots:
    /// Set the socket to communicate RPC over. Technically, this can be any object with a textMessageReceived signal
    /// and a sendTextMessage slot, each having a single QString argument.
    void setSocket(QObject* socket);

protected slots:
    void messageReceived(QString message);

signals:
    void socketChanged(QObject* socket);
};

#endif // JSONRPCPROVIDER_HPP
