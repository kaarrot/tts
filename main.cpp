#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QSGRendererInterface>
// #include "tts.h"   // TODO

int main(int argc, char *argv[]) {
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    // qmlRegisterType<tts>("custom.tts", 1, 0, "TTS");
    
    QGuiApplication app(argc, argv);
    QQuickWindow::setSceneGraphBackend("software");

    QQmlApplicationEngine engine;

    // TODO
    // engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    engine.load(QUrl(QStringLiteral("main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;
    
    return app.exec();
}
