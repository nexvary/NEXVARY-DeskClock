#include "SimulatorModel.hpp"
#include <QDebug>
#include <QString>
#include <algorithm>
#include <cmath>
#include <numbers>
#include <stdexcept>

// --- Scenario definition --------------------------------------------------

aeroradar::Simulator SimulatorModel::makeScenario() {
    using namespace aeroradar;
    // All positions/velocities: purely illustrative synthetic data.
    // Headings expressed as CW degrees from north:
    //   AC-01:  heading ~087°, speed ~61 m/s (118 kt), fixed-wing
    //   UAS-01: heading ~200°, speed ~19 m/s (36 kt),  multirotor
    //   UAS-02: heading ~310°, speed ~43 m/s (83 kt),  multirotor
    const double kts2kmps = 0.51444 / 1000.0;
    auto vel = [&](double heading_deg, double speed_kt_val) {
        const double r = heading_deg * (std::numbers::pi / 180.0);
        const double spd = speed_kt_val * kts2kmps;
        return std::make_pair(spd * std::sin(r), spd * std::cos(r));
    };
    auto [vx1, vy1] = vel(87.0,  118.0);
    auto [vx2, vy2] = vel(200.0,  36.0);
    auto [vx3, vy3] = vel(310.0,  83.0);

    return Simulator({
        { 1,  14.0,   5.0,  vx1, vy1, 3500.0, AircraftType::FIXED_WING, "AC-01"  },
        { 2,  -6.5, -17.5,  vx2, vy2,  150.0, AircraftType::MULTIROTOR, "UAS-01" },
        { 3,  -9.0,   8.0,  vx3, vy3, 1200.0, AircraftType::MULTIROTOR, "UAS-02" },
    });
}

// --- Construction ---------------------------------------------------------

SimulatorModel::SimulatorModel(QObject* parent)
    : QObject(parent)
    , sim_(makeScenario())
    , timer_(new QTimer(this))
{
    trails_.resize(sim_.aircraft().size());
    connect(timer_, &QTimer::timeout, this, &SimulatorModel::onTick);
    timer_->setInterval(1000 / TICKS_PER_SECOND); // 100 ms
    if (!sim_.aircraft().empty())
        selectedIndex_ = 0;
    timer_->start();
}

// --- Tick -----------------------------------------------------------------

void SimulatorModel::onTick() {
    if (sim_.is_paused())
        return;
    try {
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

double SimulatorModel::simTimeSeconds() const { return sim_.elapsed_seconds(); }

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
