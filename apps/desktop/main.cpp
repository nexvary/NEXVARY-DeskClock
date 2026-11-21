#include "SimulatorModel.hpp"
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char* argv[]) {
    QGuiApplication app(argc, argv);
    app.setApplicationName("NEXVARY AeroRadar");
    app.setApplicationVersion("0.1.0");
    app.setOrganizationName("Nexvary Inc.");

    // Instantiate the simulation bridge and expose it to QML as "simulator"
    SimulatorModel simulatorModel;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("simulator", &simulatorModel);
    engine.loadFromModule("AeroRadar", "Main");

    if (engine.rootObjects().isEmpty()) return 1;
    return app.exec();
}
