#include "KeyPair.hpp"
#include "KeyStore.hpp"
#include "AccountKeys.hpp"
#include "QmlJsonRpcProvider.hpp"
#include "TransactionFoundry.hpp"

#include <QtQmlTricksPlugin_SmartDataModels.h>

#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);
    app.setOrganizationName("Nathan Hourt");
    app.setOrganizationDomain("nathanhourt.com");
    app.setApplicationName("Steem Pressure");
    app.setApplicationVersion("1.0 Beta");

    QQmlApplicationEngine engine;

    // For benlau's quickpromise library
    engine.addImportPath("qrc:/");

    registerQtQmlTricksSmartDataModel(&engine);

    qmlRegisterType<TransactionFoundry>("com.nathanhourt.steem.crypto", 1, 0, "TransactionFoundry");
    qmlRegisterType<KeyPair>("com.nathanhourt.steem.crypto", 1, 0, "KeyPair");
    qmlRegisterType<KeyStore>("com.nathanhourt.steem.accounts", 1, 0, "KeyStore");
    qmlRegisterType<AccountKeys>("com.nathanhourt.steem.accounts", 1, 0, "AccountKeys");
    qmlRegisterType<QmlJsonRpcProvider>("com.nathanhourt.rpc", 1, 0, "JsonRpcProvider");

    engine.load(QUrl(QLatin1String("qrc:/main.qml")));

    return app.exec();
}
