#include "SimulatorModel.hpp"
#include <QDateTime>
#include <QString>
#include <cmath>

// --- Scenario definition --------------------------------------------------

aeroradar::Simulator SimulatorModel::makeScenario() {
    using namespace aeroradar;
    // Three synthetic research aircraft matching the concept image layout.
    // All speeds/positions are purely illustrative; labelled SIMULATION.
    // Headings expressed as CW degrees from north:
    //   AC-01:  heading ~087°, speed ~61 m/s (118 kt), fixed-wing
    //   UAS-01: heading ~200°, speed ~19 m/s (36 kt),  multirotor
    //   UAS-02: heading ~310°, speed ~43 m/s (83 kt),  multirotor
    const double kts2kmps = 0.51444 / 1000.0;
    auto vel = [&](double heading_deg, double speed_kt_val) {
        const double r = heading_deg * (M_PI / 180.0);
        const double spd = speed_kt_val * kts2kmps;
        return std::make_pair(spd * std::sin(r), spd * std::cos(r)); // vx, vy
    };
    auto [vx1, vy1] = vel(87.0,  118.0);
    auto [vx2, vy2] = vel(200.0,  36.0);
    auto [vx3, vy3] = vel(310.0,  83.0);

    return Simulator({
        { 1,  14.0,  5.0,  vx1, vy1, 3500.0, AircraftType::FIXED_WING, "AC-01"  },
        { 2,  -6.5, -17.5, vx2, vy2,  150.0, AircraftType::MULTIROTOR, "UAS-01" },
        { 3,  -9.0,   8.0, vx3, vy3, 1200.0, AircraftType::MULTIROTOR, "UAS-02" },
    });
}

// --- Construction ---------------------------------------------------------

SimulatorModel::SimulatorModel(QObject* parent)
    : QObject(parent)
    , sim_(makeScenario())
    , timer_(new QTimer(this))
{
    // Initialise trail deques, one per aircraft
    trails_.resize(sim_.aircraft().size());

    connect(timer_, &QTimer::timeout, this, &SimulatorModel::onTick);
    timer_->setInterval(static_cast<int>(SIM_DT_S * 1000.0)); // 100 ms
    timer_->start();

    // Select first track by default
    if (!sim_.aircraft().empty())
        selectedId_ = sim_.aircraft().front().id;
}

// --- Tick -----------------------------------------------------------------

void SimulatorModel::onTick() {
    sim_.step(SIM_DT_S);

    // Append current positions to trails
    for (std::size_t i = 0; i < sim_.aircraft().size(); ++i) {
        const auto& a = sim_.aircraft()[i];
        auto& trail = trails_[i];
        trail.emplace_back(a.x_km, a.y_km);
        while (static_cast<int>(trail.size()) > TRAIL_LEN)
            trail.pop_front();
    }

    emit simStateChanged();
}

// --- Properties -----------------------------------------------------------

bool SimulatorModel::isPaused() const { return sim_.is_paused(); }

double SimulatorModel::simTimeSeconds() const { return sim_.elapsed_seconds(); }

QString SimulatorModel::simTimeDisplay() const {
    const int total = static_cast<int>(sim_.elapsed_seconds());
    const int h = total / 3600;
    const int m = (total % 3600) / 60;
    const int s = total % 60;
    return QString("%1:%2:%3")
        .arg(h, 2, 10, QChar('0'))
        .arg(m, 2, 10, QChar('0'))
        .arg(s, 2, 10, QChar('0'));
}

int SimulatorModel::trackCount() const {
    return static_cast<int>(sim_.aircraft().size());
}

QVariantMap SimulatorModel::trackToVariant(const aeroradar::Aircraft& a) const {
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
    m["selected"]    = (a.id == selectedId_);

    // Build trail list
    QVariantList trail;
    for (std::size_t i = 0; i < sim_.aircraft().size(); ++i) {
        if (sim_.aircraft()[i].id == a.id) {
            for (const auto& [tx, ty] : trails_[i]) {
                QVariantMap pt;
                pt["x_km"] = tx;
                pt["y_km"] = ty;
                trail.append(pt);
            }
            break;
        }
    }
    m["trail"] = trail;
    return m;
}

QVariantList SimulatorModel::tracks() const {
    QVariantList result;
    for (const auto& a : sim_.aircraft())
        result.append(trackToVariant(a));
    return result;
}

QVariantMap SimulatorModel::selected() const {
    for (const auto& a : sim_.aircraft())
        if (a.id == selectedId_) return trackToVariant(a);
    return {};
}

// --- Slots ----------------------------------------------------------------

void SimulatorModel::play() {
    sim_.resume();
    if (!timer_->isActive()) timer_->start();
    emit simStateChanged();
}

void SimulatorModel::pause() {
    sim_.pause();
    emit simStateChanged();
}

void SimulatorModel::reset() {
    sim_.reset();
    for (auto& t : trails_) t.clear();
    emit simStateChanged();
}

void SimulatorModel::selectTrack(int id) {
    selectedId_ = id;
    emit selectedChanged();
    emit simStateChanged();
}
