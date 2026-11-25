// tests/integration/SimulatorModelTests.cpp
// QTest integration tests for SimulatorModel.
// Requires Qt6::Test. Built only when AERORADAR_BUILD_DESKTOP=ON AND BUILD_TESTING=ON.
#include "SimulatorModel.hpp"
#include <QCoreApplication>
#include <QSignalSpy>
#include <QString>
#include <QtTest/QtTest>

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
        model_->pause();
        QVERIFY(model_->isPaused());
        double t0 = model_->simTimeSeconds();
        QTest::qWait(300);
        QCOMPARE(model_->simTimeSeconds(), t0);
    }

    void resumeRestoresSimulation() {
        model_->pause();
        QVERIFY(model_->isPaused());
        model_->play();
        QVERIFY(!model_->isPaused());
        // Let it tick at least once
        QTest::qWait(250);
        QVERIFY(model_->simTimeSeconds() > 0.0);
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
        model_->play();   // already running — must not corrupt
        QVERIFY(!model_->isPaused());
        QTest::qWait(150);
        QVERIFY(model_->simTimeSeconds() >= 0.0);
    }

    // --- Reset ---

    void resetRestoresTime() {
        QTest::qWait(250);   // let sim advance at least one tick
        QVERIFY(model_->simTimeSeconds() > 0.0);
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
        QTest::qWait(150);
        QVERIFY(model_->simTimeSeconds() > 0.0);
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
        int firstId = tracks.first().toMap().value("id").toInt();
        QSignalSpy spy(model_, &SimulatorModel::selectedChanged);
        model_->selectTrack(firstId);
        QCOMPARE(spy.count(), 1);
    }

    void timerTickEmitsSimStateChanged() {
        QSignalSpy spy(model_, &SimulatorModel::simStateChanged);
        // 100 ms tick rate — wait 350 ms to expect at least 2 ticks
        QTest::qWait(350);
        QVERIFY(spy.count() >= 2);
    }

private:
    SimulatorModel* model_ = nullptr;
};

QTEST_MAIN(SimulatorModelTests)
#include "SimulatorModelTests.moc"
