#include "SimulatorModel.hpp"

#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlError>
#include <QQuickItem>
#include <QQuickWindow>
#include <QSettings>
#include <QSignalSpy>
#include <QTemporaryDir>
#include <QtTest/QtTest>

namespace {

QQuickItem* findItem(QQuickItem* root, const QString& name) {
    if (root->objectName() == name)
        return root;

    for (auto* child : root->childItems()) {
        if (auto* match = findItem(child, name))
            return match;
    }
    return nullptr;
}

} // namespace

class DashboardTests : public QObject {
    Q_OBJECT

private slots:
    void initTestCase() {
        QVERIFY(settingsDirectory_.isValid());
        QCoreApplication::setOrganizationName(QStringLiteral("NEXVARY Test"));
        QSettings::setDefaultFormat(QSettings::IniFormat);
        QSettings::setPath(QSettings::IniFormat, QSettings::UserScope, settingsDirectory_.path());
    }

    void controlsAndWorkspaces() {
        SimulatorModel simulator;
        QQmlApplicationEngine engine;
        engine.rootContext()->setContextProperty("aeroSimulatorModel", &simulator);
        QSignalSpy warnings(&engine, &QQmlApplicationEngine::warnings);
        engine.loadFromModule("AeroRadar", "Main");
        QCOMPARE(engine.rootObjects().size(), 1);
        auto* window = qobject_cast<QQuickWindow*>(engine.rootObjects().front());
        QVERIFY(window);
        QVERIFY(QTest::qWaitForWindowExposed(window));
        QCOMPARE(window->property("workspace").toString(), QStringLiteral("flight"));

        auto* radar = findItem(window->contentItem(), QStringLiteral("workspace-radar"));
        auto* traffic = findItem(window->contentItem(), QStringLiteral("workspace-traffic"));
        auto* pause = findItem(window->contentItem(), QStringLiteral("simulation-pause"));
        auto* play = findItem(window->contentItem(), QStringLiteral("simulation-play"));
        auto* reset = findItem(window->contentItem(), QStringLiteral("simulation-reset"));
        auto* track = findItem(window->contentItem(), QStringLiteral("track-2"));
        QVERIFY(radar && traffic && pause && play && reset && track);

        radar->forceActiveFocus();
        QTRY_VERIFY(radar->hasActiveFocus());
        QTest::keyClick(window, Qt::Key_Space);
        QCOMPARE(window->property("workspace").toString(), QStringLiteral("radar"));

        QTest::keyClick(window, Qt::Key_Tab);
        QTRY_VERIFY(traffic->hasActiveFocus());
        QTest::keyClick(window, Qt::Key_Space);
        QCOMPARE(window->property("workspace").toString(), QStringLiteral("traffic"));

        QTRY_VERIFY(simulator.simTimeSeconds() > 0.0);
        track->forceActiveFocus();
        QTRY_VERIFY(track->hasActiveFocus());
        QSignalSpy simulationChanges(&simulator, &SimulatorModel::simStateChanged);
        QTRY_VERIFY(!simulationChanges.isEmpty());
        QCOMPARE(findItem(window->contentItem(), QStringLiteral("track-2")), track);
        QVERIFY(track->hasActiveFocus());
        QTest::keyClick(window, Qt::Key_Space);
        QCOMPARE(simulator.selected().value("id").toInt(), 2);

        const auto click = [window](QQuickItem* item) {
            const QPointF center(item->width() / 2, item->height() / 2);
            QTest::mouseClick(window, Qt::LeftButton, Qt::NoModifier, item->mapToScene(center).toPoint());
        };
        click(pause);
        QVERIFY(simulator.isPaused());
        click(reset);
        QCOMPARE(simulator.simTimeSeconds(), 0.0);
        QVERIFY(simulator.isPaused());
        click(play);
        QTRY_VERIFY(simulator.simTimeSeconds() > 0.0);
        QVERIFY(window->property("utcWallClock").toString().endsWith(QStringLiteral(" UTC")));
        QCOMPARE(warnings.size(), 0);
    }

    void appearancePersistsAcrossWindows() {
        SimulatorModel simulator;
        QColor dark;
        QColor light;
        {
            QQmlApplicationEngine engine;
            engine.rootContext()->setContextProperty("aeroSimulatorModel", &simulator);
            engine.loadFromModule("AeroRadar", "Main");
            QCOMPARE(engine.rootObjects().size(), 1);
            auto* window = qobject_cast<QQuickWindow*>(engine.rootObjects().front());
            QVERIFY(window);
            QVERIFY(QTest::qWaitForWindowExposed(window));
            dark = window->color();

            auto* settings = findItem(window->contentItem(), QStringLiteral("workspace-settings"));
            QVERIFY(settings);
            settings->forceActiveFocus();
            QTest::keyClick(window, Qt::Key_Space);
            QCOMPARE(window->property("workspace").toString(), QStringLiteral("settings"));
            auto* appearance = findItem(window->contentItem(), QStringLiteral("appearance-light"));
            QVERIFY(appearance);
            QVERIFY(!appearance->property("checked").toBool());
            appearance->forceActiveFocus();
            QTest::keyClick(window, Qt::Key_Space);
            QVERIFY(appearance->property("checked").toBool());
            light = window->color();
            QVERIFY(light.lightness() > dark.lightness());
        }

        QQmlApplicationEngine engine;
        engine.rootContext()->setContextProperty("aeroSimulatorModel", &simulator);
        engine.loadFromModule("AeroRadar", "Main");
        QCOMPARE(engine.rootObjects().size(), 1);
        auto* window = qobject_cast<QQuickWindow*>(engine.rootObjects().front());
        QVERIFY(window);
        QCOMPARE(window->color(), light);
    }

private:
    QTemporaryDir settingsDirectory_;
};

QTEST_MAIN(DashboardTests)
#include "DashboardTests.moc"
