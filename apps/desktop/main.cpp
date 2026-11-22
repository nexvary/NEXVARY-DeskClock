#include "SimulatorModel.hpp"
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTimer>
#include <cstring>

int main(int argc, char* argv[]) {
    // --smoke: load QML via offscreen, wait 1500 ms, exit 0 if no errors.
    // Used as CI startup gate: distinguishes clean load from crash/QML failure.
    bool smokeMode = false;
    for (int i = 1; i < argc; ++i)
        if (std::strcmp(argv[i], "--smoke") == 0) { smokeMode = true; break; }

    QGuiApplication app(argc, argv);
    app.setApplicationName("NEXVARY AeroRadar");
    app.setApplicationVersion("0.1.0");
    app.setOrganizationName("Nexvary Inc.");

    SimulatorModel simulatorModel;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("simulator", &simulatorModel);

    // Track QML load errors
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

    return app.exec();
}
