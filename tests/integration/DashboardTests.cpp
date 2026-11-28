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
        auto* step = findItem(window->contentItem(), QStringLiteral("simulation-step"));
        auto* rate = findItem(window->contentItem(), QStringLiteral("simulation-time-scale"));
        auto* track = findItem(window->contentItem(), QStringLiteral("track-2"));
        QVERIFY(radar && traffic && pause && play && reset && step && rate && track);
        QVERIFY(!step->isEnabled());
        QCOMPARE(rate->property("currentValue").toDouble(), 1.0);

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
        pause->forceActiveFocus();
        QTest::keyClick(window, Qt::Key_Space);
        QVERIFY(simulator.isPaused());
        QVERIFY(step->isEnabled());
        rate->forceActiveFocus();
        QTest::keyClick(window, Qt::Key_Down);
        QCOMPARE(simulator.timeScale(), 2.0);
        click(reset);
        QCOMPARE(simulator.simTimeSeconds(), 0.0);
        click(step);
        QCOMPARE(simulator.simTimeSeconds(), 0.1);
        QVERIFY(simulator.isPaused());
        click(play);
        QTRY_VERIFY(simulator.simTimeSeconds() > 0.1);
        QVERIFY(window->property("utcWallClock").toString().endsWith(QStringLiteral(" UTC")));
        auto* scenarios = findItem(window->contentItem(), QStringLiteral("workspace-scenarios"));
        QVERIFY(scenarios);
        click(scenarios);
        QCOMPARE(window->property("workspace").toString(), QStringLiteral("scenarios"));
        auto* error = findItem(window->contentItem(), QStringLiteral("scenario-load-error"));
        auto* builtin = findItem(window->contentItem(), QStringLiteral("scenario-builtin"));
        QVERIFY(error && builtin);
        QVERIFY(!simulator.loadScenario(QUrl(QStringLiteral("https://example.invalid/scenario.json"))));
        QVERIFY(error->isVisible());
        click(builtin);
        QVERIFY(!error->isVisible());
        auto* editor = findItem(window->contentItem(), QStringLiteral("scenario-editor"));
        auto* apply = findItem(window->contentItem(), QStringLiteral("scenario-apply"));
        QVERIFY(editor && apply);
        auto draft = editor->property("text").toString();
        QVERIFY(!draft.isEmpty());
        draft.replace(simulator.scenarioName(), QStringLiteral("Dashboard draft"));
        QVERIFY(editor->setProperty("text", draft));
        click(apply);
        QCOMPARE(simulator.scenarioName(), QStringLiteral("Dashboard draft"));
        QVERIFY(!error->isVisible());
        QCOMPARE(simulator.simTimeSeconds(), 0.0);
        QVERIFY(simulator.isPaused());

        QCOMPARE(warnings.size(), 0);
    }

    void radarNavigationAndFiltering() {
        SimulatorModel simulator;
        simulator.pause();
        QQmlApplicationEngine engine;
        engine.rootContext()->setContextProperty("aeroSimulatorModel", &simulator);
        QSignalSpy warnings(&engine, &QQmlApplicationEngine::warnings);
        engine.loadFromModule("AeroRadar", "Main");
        QCOMPARE(engine.rootObjects().size(), 1);
        auto* window = qobject_cast<QQuickWindow*>(engine.rootObjects().front());
        QVERIFY(window);
        QVERIFY(QTest::qWaitForWindowExposed(window));

        auto* ppi = findItem(window->contentItem(), QStringLiteral("radar-ppi"));
        QVERIFY(ppi);
        auto* canvas = findItem(ppi, QStringLiteral("radar-canvas"));
        auto* zoom = findItem(ppi, QStringLiteral("radar-zoom-in"));
        auto* center = findItem(ppi, QStringLiteral("radar-reset-view"));
        auto* labels = findItem(ppi, QStringLiteral("radar-labels"));
        auto* trails = findItem(ppi, QStringLiteral("radar-history"));
        auto* filter = findItem(ppi, QStringLiteral("radar-track-filter"));
        QVERIFY(canvas && zoom && center && labels && trails && filter);
        QTRY_VERIFY(canvas->width() > 100 && canvas->height() > 100);
        QCOMPARE(ppi->property("rangeKm").toDouble(), 40.0);

        const auto click = [window](QQuickItem* item) {
            const QPointF midpoint(item->width() / 2, item->height() / 2);
            QTest::mouseClick(window, Qt::LeftButton, Qt::NoModifier, item->mapToScene(midpoint).toPoint());
        };
        click(zoom);
        QCOMPARE(ppi->property("rangeKm").toDouble(), 20.0);
        const QPoint start = canvas->mapToScene(QPointF(canvas->width() / 2, canvas->height() / 2)).toPoint();
        const QPoint end = start + QPoint(64, -40);
        QTest::mousePress(window, Qt::LeftButton, Qt::NoModifier, start);
        QTest::mouseMove(window, end);
        QTest::mouseRelease(window, Qt::LeftButton, Qt::NoModifier, end);
        QVERIFY(ppi->property("centerEastKm").toDouble() < 0.0);
        QVERIFY(ppi->property("centerNorthKm").toDouble() < 0.0);

        // Track 2 is a multirotor at (-6.5 km east, -17.5 km north).
        const double pixelsPerKm = canvas->property("pixelsPerKm").toDouble();
        const QPointF trackPoint(canvas->property("originX").toDouble() - 6.5 * pixelsPerKm,
                                 canvas->property("originY").toDouble() + 17.5 * pixelsPerKm);
        const QPoint trackScenePoint = canvas->mapToScene(trackPoint).toPoint();
        QTest::mouseClick(window, Qt::LeftButton, Qt::NoModifier, trackScenePoint);
        QCOMPARE(simulator.selected().value("id").toInt(), 2);

        simulator.selectTrack(1);
        filter->forceActiveFocus();
        QTest::keyClick(window, Qt::Key_Down);
        QCOMPARE(ppi->property("trackTypeFilter").toString(), QStringLiteral("FIXED_WING"));
        QTest::mouseClick(window, Qt::LeftButton, Qt::NoModifier, trackScenePoint);
        QCOMPARE(simulator.selected().value("id").toInt(), 1);

        click(labels);
        click(trails);
        QVERIFY(!ppi->property("showLabels").toBool());
        QVERIFY(!ppi->property("showHistory").toBool());
        click(center);
        QCOMPARE(ppi->property("rangeKm").toDouble(), 40.0);
        QCOMPARE(ppi->property("centerEastKm").toDouble(), 0.0);
        QCOMPARE(ppi->property("centerNorthKm").toDouble(), 0.0);
        QCOMPARE(simulator.simTimeSeconds(), 0.0);
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
