#include "SimulatorModel.hpp"
#include "aeroradar/BuiltinScenario.hpp"

#include <QDebug>
#include <QString>
#include <algorithm>
#include <array>
#include <stdexcept>

// --- Construction ---------------------------------------------------------

SimulatorModel::SimulatorModel(QObject* parent)
    : QObject(parent)
    , sim_(aeroradar::make_builtin_scenario())
    , timer_(new QTimer(this))
{
    trails_.resize(sim_.aircraft().size());
    connect(timer_, &QTimer::timeout, this, &SimulatorModel::onTick);
    timer_->setTimerType(Qt::PreciseTimer);
    timer_->setInterval(TICK_INTERVAL_MS);
    if (!sim_.aircraft().empty())
        selectedIndex_ = 0;
    timer_->start();
}

// --- Tick -----------------------------------------------------------------

void SimulatorModel::onTick() { advance(false); }

void SimulatorModel::stepOnce() { advance(true); }

void SimulatorModel::advance(bool singleStep) {
    if (singleStep != sim_.is_paused())
        return;
    try {
        if (singleStep)
            sim_.step_once(SIM_DT_S);
        else
            sim_.step(SIM_DT_S);
    } catch (const std::overflow_error& error) {
        qCritical() << "Simulation paused:" << error.what();
        pause();
        return;
    }

    for (std::size_t i = 0; i < sim_.aircraft().size(); ++i) {
        const auto& a = sim_.aircraft()[i];
        auto& trail = trails_[i];
        trail.emplace_back(a.x_km, a.y_km);
        if (trail.size() > TRAIL_LEN)
            trail.pop_front();
    }

    emit simStateChanged();
    if (selectedIndex_)
        emit selectedChanged();
}

// --- Properties -----------------------------------------------------------

bool SimulatorModel::isPaused() const { return sim_.is_paused(); }

double SimulatorModel::simTimeSeconds() const {
    return static_cast<double>(sim_.step_count()) / TICKS_PER_SECOND;
}

double SimulatorModel::timeScale() const { return timeScale_; }

void SimulatorModel::setTimeScale(double scale) {
    constexpr std::array rates{0.25, 0.5, 1.0, 2.0, 4.0};
    if (scale == timeScale_ || std::ranges::find(rates, scale) == rates.end())
        return;
    timeScale_ = scale;
    // All supported rates map exactly to whole milliseconds.
    timer_->setInterval(static_cast<int>(TICK_INTERVAL_MS / scale));
    emit timeScaleChanged();
}

QString SimulatorModel::simTimeDisplay() const {
    const qulonglong total = sim_.step_count() / TICKS_PER_SECOND;
    const auto h = total / 3600;
    const auto m = (total % 3600) / 60;
    const auto s = total % 60;
    return QString("%1:%2:%3")
        .arg(h, 2, 10, QChar('0'))
        .arg(m, 2, 10, QChar('0'))
        .arg(s, 2, 10, QChar('0'));
}

int SimulatorModel::trackCount() const {
    return static_cast<int>(sim_.aircraft().size());
}

QVariantMap SimulatorModel::trackToVariant(std::size_t index) const {
    const auto& a = sim_.aircraft()[index];
    QVariantMap m;
    m["id"]          = a.id;
    m["label"]       = QString::fromStdString(a.label);
    m["x_km"]        = a.x_km;
    m["y_km"]        = a.y_km;
    m["altitude_m"]  = a.altitude_m;
    m["speed_kt"]    = aeroradar::speed_kt(a);
    m["speed_mps"]   = aeroradar::speed_mps(a);
    m["heading_deg"] = aeroradar::bearing_deg(a);
    m["range_km"]    = aeroradar::range_km(a);
    m["type"]        = (a.type == aeroradar::AircraftType::MULTIROTOR)
                           ? QStringLiteral("UAS") : QStringLiteral("FIXED_WING");
    m["selected"]    = (index == selectedIndex_);

    QVariantList trail;
    trail.reserve(static_cast<qsizetype>(trails_[index].size()));
    for (const auto& [x, y] : trails_[index]) {
        trail.append(QVariantMap{{"x_km", x}, {"y_km", y}});
    }
    m["trail"] = trail;
    return m;
}

QVariantList SimulatorModel::tracks() const {
    QVariantList result;
    result.reserve(trackCount());
    for (std::size_t i = 0; i < sim_.aircraft().size(); ++i)
        result.append(trackToVariant(i));
    return result;
}

QVariantMap SimulatorModel::selected() const {
    return selectedIndex_ ? trackToVariant(*selectedIndex_) : QVariantMap{};
}

// --- Slots ----------------------------------------------------------------

void SimulatorModel::play() {
    if (!sim_.is_paused())
        return;
    sim_.resume();
    timer_->start();
    emit simStateChanged();
}

void SimulatorModel::pause() {
    if (sim_.is_paused())
        return;
    timer_->stop();
    sim_.pause();
    emit simStateChanged();
}

void SimulatorModel::reset() {
    sim_.reset();
    for (auto& t : trails_) t.clear();
    emit simStateChanged();
    emit selectedChanged();
}

void SimulatorModel::selectTrack(int id) {
    const auto& aircraft = sim_.aircraft();
    const auto match = std::ranges::find(aircraft, id, &aeroradar::Aircraft::id);
    std::optional<std::size_t> index;
    if (match != aircraft.end())
        index = static_cast<std::size_t>(match - aircraft.begin());
    if (index == selectedIndex_)
        return;
    selectedIndex_ = index;
    emit selectedChanged();
    emit simStateChanged();
}
