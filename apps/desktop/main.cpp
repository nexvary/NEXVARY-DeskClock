#include "SimulatorModel.hpp"
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QString>
#include <QTimer>
#include <cstring>

int main(int argc, char* argv[]) {
    // --smoke:       load QML, wait 1500 ms, exit 0 if clean.
    // --screenshot <path>: load QML, wait 2500 ms, grab window, save to <path>, exit 0.
    bool    smokeMode      = false;
    bool    screenshotMode = false;
    QString screenshotPath;

    for (int i = 1; i < argc; ++i) {
        if (std::strcmp(argv[i], "--smoke") == 0) {
            smokeMode = true;
        } else if (std::strcmp(argv[i], "--screenshot") == 0 && i + 1 < argc) {
            screenshotMode = true;
            screenshotPath = argv[++i];
        }
    }

    QGuiApplication app(argc, argv);
    app.setApplicationName("NEXVARY AeroRadar");
    app.setApplicationVersion("0.1.0");
    app.setOrganizationName("Nexvary Inc.");

    SimulatorModel simulatorModel;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("simulator", &simulatorModel);

    bool qmlObjectFailed = false;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, [&qmlObjectFailed]() { qmlObjectFailed = true; },
                     Qt::DirectConnection);

    engine.loadFromModule("AeroRadar", "Main");

    if (engine.rootObjects().isEmpty()) {
        qCritical("AeroRadar: QML root object is empty — load failed");
        return 1;
    }

    if (smokeMode) {
        QTimer::singleShot(1500, &app, [&app, &qmlObjectFailed]() {
            if (qmlObjectFailed) {
                qCritical("SMOKE FAIL: QML object creation error detected");
                app.exit(1);
            } else {
                qDebug("SMOKE PASS: QML loaded and running cleanly");
                app.exit(0);
            }
        });
    }

    if (screenshotMode) {
        QTimer::singleShot(2500, &app, [&app, &engine, &qmlObjectFailed, screenshotPath]() {
            if (qmlObjectFailed || engine.rootObjects().isEmpty()) {
                qCritical("SCREENSHOT FAIL: QML not loaded");
                app.exit(1);
                return;
            }
            auto* window = qobject_cast<QQuickWindow*>(engine.rootObjects().first());
            if (!window) {
                qCritical("SCREENSHOT FAIL: root object is not a QQuickWindow");
                app.exit(1);
                return;
            }
            const QImage img = window->grabWindow();
            if (img.isNull()) {
                qCritical("SCREENSHOT FAIL: grabWindow() returned null image");
                app.exit(1);
                return;
            }
            if (!img.save(screenshotPath)) {
                qCritical("SCREENSHOT FAIL: could not save to %s",
                          qPrintable(screenshotPath));
                app.exit(1);
                return;
            }
            qDebug("SCREENSHOT SAVED: %s (%dx%d)",
                   qPrintable(screenshotPath), img.width(), img.height());
            app.exit(0);
        });
    }

    return app.exec();
}
