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

private:
    SimulatorModel* model_ = nullptr;
};

QTEST_MAIN(SimulatorModelTests)
#include "SimulatorModelTests.moc"
