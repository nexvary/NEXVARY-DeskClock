// tests/integration/SimulatorModelTests.cpp
// QTest integration tests for SimulatorModel.
// Requires Qt6::Test. Built only when AERORADAR_BUILD_DESKTOP=ON AND BUILD_TESTING=ON.
#include "SimulatorModel.hpp"
#include <QCoreApplication>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QTemporaryDir>
#include <QUrl>
#include <QSignalSpy>
#include <QString>
#include <QtTest/QtTest>
#include <limits>

namespace {
QByteArray sampleScenario() {
    QFile fixture(QStringLiteral(":/scenarios/docs/scenarios/civil-training.json"));
    if (!fixture.open(QIODevice::ReadOnly))
        return {};
    return fixture.readAll();
}
}

class SimulatorModelTests : public QObject {
    Q_OBJECT

private slots:
    void init()    { model_ = new SimulatorModel; }
    void cleanup() { delete model_; model_ = nullptr; }

    // --- Initial state ---

    void modelCreationSucceeds() {
        QVERIFY(model_ != nullptr);
        QVERIFY(model_->trackCount() > 0);
        QVERIFY(!model_->isPaused());     // starts running
        QCOMPARE(model_->simTimeSeconds(), 0.0);
    }

    // --- Pause / Resume ---

    void pauseStopsSimulation() {
        QTRY_VERIFY(model_->simTimeSeconds() > 0.0);
        model_->pause();
        QVERIFY(model_->isPaused());
        const double elapsed = model_->simTimeSeconds();
        const auto tracks = model_->tracks();
        QSignalSpy state(model_, &SimulatorModel::simStateChanged);
        QSignalSpy selection(model_, &SimulatorModel::selectedChanged);
        QTest::qWait(350);
        QCOMPARE(model_->simTimeSeconds(), elapsed);
        QCOMPARE(model_->tracks(), tracks);
        QCOMPARE(state.count(), 0);
        QCOMPARE(selection.count(), 0);
    }

    void resumeRestoresSimulation() {
        model_->pause();
        QVERIFY(model_->isPaused());
        model_->play();
        QVERIFY(!model_->isPaused());
        QTRY_VERIFY(model_->simTimeSeconds() > 0.0);
    }

    void pauseIdempotent() {
        model_->pause();
        model_->pause();
        QVERIFY(model_->isPaused());
        double t0 = model_->simTimeSeconds();
        QTest::qWait(250);
        QCOMPARE(model_->simTimeSeconds(), t0);
    }

    void resumeIdempotent() {
        QVERIFY(!model_->isPaused());
        QSignalSpy state(model_, &SimulatorModel::simStateChanged);
        model_->play();
        QVERIFY(!model_->isPaused());
        QCOMPARE(state.count(), 0);
        QTRY_VERIFY(model_->simTimeSeconds() > 0.0);
    }

    // --- Reset ---

    void resetRestoresTime() {
        QTRY_VERIFY(model_->simTimeSeconds() > 0.0);
        model_->reset();
        QCOMPARE(model_->simTimeSeconds(), 0.0);
    }

    void resetDoesNotUnpause() {
        model_->pause();
        model_->reset();
        QVERIFY(model_->isPaused());
    }

    void resetLeavesRunningStateUnchanged() {
        QVERIFY(!model_->isPaused());
        model_->reset();
        QVERIFY(!model_->isPaused());
        QTRY_VERIFY(model_->simTimeSeconds() > 0.0);
    }

    // --- Track selection ---

    void selectTrackUpdatesSelected() {
        const auto tracks = model_->tracks();
        QVERIFY(!tracks.isEmpty());
        int firstId = tracks.first().toMap().value("id").toInt();
        model_->selectTrack(firstId);
        QCOMPARE(model_->selected().value("id").toInt(), firstId);
    }

    void selectInvalidIdClearsSelection() {
        // Select a valid track first
        const auto tracks = model_->tracks();
        QVERIFY(!tracks.isEmpty());
        model_->selectTrack(tracks.first().toMap().value("id").toInt());
        // Now select an invalid ID
        model_->selectTrack(-9999);
        const auto sel = model_->selected();
        // selected() must reflect no valid track: empty or negative id
        QVERIFY(sel.isEmpty() || sel.value("id", -1).toInt() <= 0);
    }

    // --- Signal notifications (QSignalSpy) ---

    void pauseEmitsSimStateChanged() {
        QSignalSpy spy(model_, &SimulatorModel::simStateChanged);
        model_->pause();
        QVERIFY(spy.count() >= 1);
    }

    void playEmitsSimStateChanged() {
        model_->pause();
        QSignalSpy spy(model_, &SimulatorModel::simStateChanged);
        model_->play();
        QVERIFY(spy.count() >= 1);
    }

    void resetEmitsSimStateChanged() {
        QSignalSpy spy(model_, &SimulatorModel::simStateChanged);
        model_->reset();
        QVERIFY(spy.count() >= 1);
    }

    void selectTrackEmitsSelectedChanged() {
        const auto tracks = model_->tracks();
        QVERIFY(!tracks.isEmpty());
        const int id = tracks.last().toMap().value("id").toInt();
        QSignalSpy spy(model_, &SimulatorModel::selectedChanged);
        model_->selectTrack(id);
        model_->selectTrack(id);
        QCOMPARE(spy.count(), 1);
    }

    void timerTickEmitsSimStateChanged() {
        QSignalSpy spy(model_, &SimulatorModel::simStateChanged);
        QTRY_VERIFY(spy.count() >= 2);
    }

    void clockDisplayUsesFixedTicks() {
        QCOMPARE(model_->simTimeDisplay(), QStringLiteral("00:00:00"));
        QTRY_COMPARE(model_->simTimeDisplay(), QStringLiteral("00:00:01"));
        model_->reset();
        QCOMPARE(model_->simTimeDisplay(), QStringLiteral("00:00:00"));
    }

    void manualStepKeepsPauseAndFixedDelta() {
        model_->stepOnce();
        QCOMPARE(model_->simTimeSeconds(), 0.0);
        model_->pause();
        const double initialEast = model_->selected().value("x_km").toDouble();
        model_->setTimeScale(4.0);
        QSignalSpy changes(model_, &SimulatorModel::simStateChanged);
        model_->stepOnce();
        QCOMPARE(model_->simTimeSeconds(), 0.1);
        QVERIFY(model_->selected().value("x_km").toDouble() > initialEast);
        QCOMPARE(model_->selected().value("trail").toList().size(), 1);
        QCOMPARE(changes.count(), 1);
        QTest::qWait(120);
        QCOMPARE(changes.count(), 1);
        QVERIFY(model_->isPaused());
    }

    void timeScaleRejectsInvalidRatesAndPreservesState() {
        model_->pause();
        QSignalSpy changes(model_, &SimulatorModel::timeScaleChanged);
        model_->setTimeScale(2.0);
        model_->setTimeScale(2.0);
        model_->setTimeScale(1.5);
        model_->setTimeScale(0.0);
        model_->setTimeScale(std::numeric_limits<double>::quiet_NaN());
        QCOMPARE(model_->timeScale(), 2.0);
        QCOMPARE(changes.count(), 1);
        QCOMPARE(model_->simTimeSeconds(), 0.0);
        model_->reset();
        QCOMPARE(model_->timeScale(), 2.0);
        QVERIFY(model_->isPaused());
    }

    void loadsScenarioAndResetsItsOwnInitialState() {
        QTemporaryDir directory;
        QVERIFY(directory.isValid());
        const auto url = writeScenario(directory, sampleScenario());
        QVERIFY(url.isLocalFile());
        QVERIFY(model_->loadScenario(url));
        QVERIFY(model_->scenarioError().isEmpty());
        QCOMPARE(model_->scenarioName(), QStringLiteral("Two civil aircraft"));
        QCOMPARE(model_->trackCount(), 2);
        QVERIFY(model_->isPaused());
        QCOMPARE(model_->simTimeSeconds(), 0.0);
        QCOMPARE(model_->selected().value("id").toInt(), 21);
        QCOMPARE(model_->selected().value("x_km").toDouble(), 2.0);
        model_->stepOnce();
        QVERIFY(model_->selected().value("x_km").toDouble() > 2.0);
        model_->reset();
        QCOMPARE(model_->selected().value("x_km").toDouble(), 2.0);

        model_->loadBuiltinScenario();
        QCOMPARE(model_->trackCount(), 3);
        QCOMPARE(model_->selected().value("id").toInt(), 1);
        QVERIFY(model_->isPaused());
    }

    void rejectsInvalidScenario_data() {
        QTest::addColumn<QByteArray>("contents");
        QTest::newRow("bad-json") << QByteArray("{]");
        QTest::newRow("oversized") << QByteArray(256 * 1024 + 1, ' ');
        const auto sample = sampleScenario();
        QVERIFY(!sample.isEmpty());
        auto rejectedVersion = sample;
        rejectedVersion.replace(R"("version": 1)", R"("version": 2)");
        QTest::newRow("future-version") << rejectedVersion;
        auto duplicate = sample;
        duplicate.replace(R"("id": 22)", R"("id": 21)");
        QTest::newRow("duplicate-id") << duplicate;
        auto speed = sample;
        speed.replace(R"("vx_km_s": 0.12)", R"("vx_km_s": 3)");
        QTest::newRow("out-of-range-speed") << speed;
        auto altitude = sample;
        altitude.replace(R"("altitude_m": 800)", R"("altitude_m": null)");
        QTest::newRow("wrong-field-type") << altitude;
        auto source = sample;
        source.replace(R"("source": "synthetic")", R"("source": "recorded")");
        QTest::newRow("wrong-source") << source;
        auto tooManyTracks = QJsonDocument::fromJson(sample).object();
        const auto first = tooManyTracks.value("aircraft").toArray().first().toObject();
        QJsonArray aircraft;
        for (int id = 1; id <= 257; ++id) {
            auto record = first;
            record.insert("id", id);
            aircraft.append(record);
        }
        tooManyTracks.insert("aircraft", aircraft);
        QTest::newRow("record-limit") << QJsonDocument(tooManyTracks).toJson(QJsonDocument::Compact);
    }

    void rejectsInvalidScenario() {
        QFETCH(QByteArray, contents);
        model_->pause();
        model_->stepOnce();
        const auto previousTracks = model_->tracks();
        const auto previousTime = model_->simTimeSeconds();
        const auto previousName = model_->scenarioName();
        QTemporaryDir directory;
        QVERIFY(directory.isValid());
        const auto url = writeScenario(directory, contents);
        QVERIFY(url.isLocalFile());
        QSignalSpy stateChanges(model_, &SimulatorModel::simStateChanged);
        QVERIFY(!model_->loadScenario(url));
        QVERIFY(!model_->scenarioError().isEmpty());
        QCOMPARE(model_->tracks(), previousTracks);
        QCOMPARE(model_->simTimeSeconds(), previousTime);
        QCOMPARE(model_->scenarioName(), previousName);
        QCOMPARE(stateChanges.count(), 0);
        QVERIFY(model_->isPaused());
    }

    void rejectsRemoteScenarioUrl() {
        QVERIFY(!model_->loadScenario(QUrl(QStringLiteral("https://example.invalid/scenario.json"))));
        QVERIFY(!model_->scenarioError().isEmpty());
        QCOMPARE(model_->trackCount(), 3);
    }

private:
    static QUrl writeScenario(const QTemporaryDir& directory, const QByteArray& contents) {
        QFile file(directory.filePath(QStringLiteral("scenario.json")));
        if (!file.open(QIODevice::WriteOnly) || file.write(contents) != contents.size())
            return {};
        return QUrl::fromLocalFile(file.fileName());
    }

    SimulatorModel* model_ = nullptr;
};

QTEST_MAIN(SimulatorModelTests)
#include "SimulatorModelTests.moc"
