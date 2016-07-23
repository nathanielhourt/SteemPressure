#include "KeyPair.hpp"

#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    qmlRegisterType<KeyPair>("com.nathanhourt.steem.crypto", 1, 0, "KeyPair");
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));

    return app.exec();
}
