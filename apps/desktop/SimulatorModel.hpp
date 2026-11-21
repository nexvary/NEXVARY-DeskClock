#pragma once
#include "aeroradar/Simulator.hpp"
#include <QObject>
#include <QTimer>
#include <QVariantList>
#include <QVariantMap>
#include <deque>
#include <vector>

// Qt bridge: wraps aeroradar::Simulator for QML consumption.
// Runs a 100 ms timer tick (10 Hz) independently of the QML renderer.
class SimulatorModel : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool    paused          READ isPaused       NOTIFY simStateChanged)
    Q_PROPERTY(double  simTimeSeconds  READ simTimeSeconds NOTIFY simStateChanged)
    Q_PROPERTY(QString simTimeDisplay  READ simTimeDisplay NOTIFY simStateChanged)
    Q_PROPERTY(int     trackCount      READ trackCount     NOTIFY simStateChanged)
    Q_PROPERTY(QVariantList tracks     READ tracks         NOTIFY simStateChanged)
    Q_PROPERTY(QVariantMap  selected   READ selected       NOTIFY selectedChanged)

public:
    static constexpr double SIM_DT_S   = 0.1;   // physics timestep, seconds
    static constexpr double RANGE_KM   = 40.0;  // display radius
    static constexpr int    TRAIL_LEN  = 25;    // history points per track

    explicit SimulatorModel(QObject* parent = nullptr);

    [[nodiscard]] bool         isPaused()        const;
    [[nodiscard]] double       simTimeSeconds()  const;
    [[nodiscard]] QString      simTimeDisplay()  const; // "HH:MM:SS"
    [[nodiscard]] int          trackCount()      const;
    [[nodiscard]] QVariantList tracks()          const;
    [[nodiscard]] QVariantMap  selected()        const; // currently selected track

public slots:
    Q_INVOKABLE void play();
    Q_INVOKABLE void pause();
    Q_INVOKABLE void reset();
    Q_INVOKABLE void selectTrack(int id);

signals:
    void simStateChanged();
    void selectedChanged();

private:
    static aeroradar::Simulator makeScenario();

    void onTick();
    [[nodiscard]] QVariantMap trackToVariant(const aeroradar::Aircraft& a) const;

    aeroradar::Simulator sim_;
    QTimer*              timer_;
    // Ring-buffer trail: map from aircraft id -> deque of (x_km, y_km)
    std::vector<std::deque<std::pair<double,double>>> trails_;
    int selectedId_{ -1 };
};
