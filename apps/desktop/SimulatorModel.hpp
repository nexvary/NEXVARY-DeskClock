#pragma once
#include "aeroradar/Simulator.hpp"
#include <QObject>
#include <QTimer>
#include <QUrl>
#include <QVariantList>
#include <QVariantMap>
#include <deque>
#include <optional>
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
    Q_PROPERTY(QString scenarioName READ scenarioName NOTIFY scenarioChanged)
    Q_PROPERTY(QString flightModel READ flightModel NOTIFY scenarioChanged)
    Q_PROPERTY(QString scenarioText READ scenarioText NOTIFY scenarioChanged)
    Q_PROPERTY(QString scenarioError READ scenarioError NOTIFY scenarioErrorChanged)
    Q_PROPERTY(double  timeScale       READ timeScale    WRITE setTimeScale NOTIFY timeScaleChanged)
    Q_PROPERTY(QVariantMap  selected   READ selected       NOTIFY selectedChanged)

public:
    static constexpr int TICKS_PER_SECOND = 10;
    static constexpr int TICK_INTERVAL_MS = 1000 / TICKS_PER_SECOND;
    static constexpr double SIM_DT_S   = 1.0 / TICKS_PER_SECOND;   // physics timestep, seconds
    static constexpr double RANGE_KM   = 40.0;  // display radius
    static constexpr int    TRAIL_LEN  = 25;    // history points per track

    explicit SimulatorModel(QObject* parent = nullptr);

    [[nodiscard]] bool         isPaused()        const;
    [[nodiscard]] double       simTimeSeconds()  const;
    [[nodiscard]] QString      simTimeDisplay()  const; // "HH:MM:SS"
    [[nodiscard]] int          trackCount()      const;
    [[nodiscard]] QVariantList tracks()          const;
    [[nodiscard]] QString      scenarioName() const;
    [[nodiscard]] QString      scenarioError() const;
    [[nodiscard]] QString      scenarioText() const;
    [[nodiscard]] QString      flightModel() const;
    [[nodiscard]] double       timeScale() const;
    [[nodiscard]] QVariantMap  selected()        const; // currently selected track

public slots:
    Q_INVOKABLE void play();
    Q_INVOKABLE void pause();
    Q_INVOKABLE void reset();
    Q_INVOKABLE void stepOnce();
    Q_INVOKABLE bool loadScenario(const QUrl& fileUrl);
    Q_INVOKABLE bool applyScenarioText(const QString& text);
    Q_INVOKABLE bool saveScenarioText(const QUrl& fileUrl, const QString& text);
    Q_INVOKABLE void loadBuiltinScenario();
    Q_INVOKABLE void setTimeScale(double scale);
    Q_INVOKABLE void selectTrack(int id);

signals:
    void simStateChanged();
    void selectedChanged();
    void timeScaleChanged();
    void scenarioChanged();
    void scenarioErrorChanged();

private:
    void replaceScenario(QString name, QString document, aeroradar::Simulator simulator);
    void setScenarioError(QString error);
    void onTick();
    void advance(bool singleStep);
    [[nodiscard]] QVariantMap trackToVariant(std::size_t index) const;

    aeroradar::Simulator sim_;
    QTimer*              timer_;
    double timeScale_{1.0};
    QString scenarioName_;
    QString scenarioText_;
    QString scenarioError_;
    // Bounded trail per aircraft, in simulation order.
    std::vector<std::deque<std::pair<double,double>>> trails_;
    std::optional<std::size_t> selectedIndex_;
};
