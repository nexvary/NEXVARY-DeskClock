#include "aeroradar/Simulator.hpp"
#include <cmath>
#include <limits>
#include <numbers>
#include <stdexcept>
#include <unordered_set>
#include <utility>

namespace aeroradar {

Simulator::Simulator(std::vector<Aircraft> aircraft)
    : aircraft_(std::move(aircraft))
{
    std::unordered_set<int> ids;
    ids.reserve(aircraft_.size());
    for (const auto& a : aircraft_) {
        if (!ids.insert(a.id).second)
            throw std::invalid_argument("aircraft IDs must be unique");
        if (!std::isfinite(range_km(a)) || !std::isfinite(speed_kt(a)) ||
            !std::isfinite(a.altitude_m))
            throw std::invalid_argument("aircraft state and derived quantities must be finite");
        if (a.type != AircraftType::FIXED_WING && a.type != AircraftType::MULTIROTOR)
            throw std::invalid_argument("unknown aircraft type");
    }
    initial_ = aircraft_;
}

void Simulator::step(double seconds) {
    if (paused_) return;

    if (!std::isfinite(seconds) || seconds < 0.0)
        throw std::invalid_argument("step duration must be finite and nonnegative");

    const double nextElapsed = elapsed_ + seconds;
    if (!std::isfinite(nextElapsed) || steps_ == std::numeric_limits<std::uint64_t>::max())
        throw std::overflow_error("simulation clock overflow");

    for (const auto& a : aircraft_) {
        const double x = a.x_km + a.vx_km_s * seconds;
        const double y = a.y_km + a.vy_km_s * seconds;
        if (!std::isfinite(std::hypot(x, y)))
            throw std::overflow_error("simulation position or range overflow");
    }

    for (auto& a : aircraft_) {
        a.x_km += a.vx_km_s * seconds;
        a.y_km += a.vy_km_s * seconds;
    }
    elapsed_ = nextElapsed;
    ++steps_;
}

void Simulator::pause()  noexcept { paused_ = true; }
void Simulator::resume() noexcept { paused_ = false; }

void Simulator::reset() noexcept {
    // Velocity, label, ID and altitude are immutable throughout a run.
    for (std::size_t i = 0; i < aircraft_.size(); ++i) {
        aircraft_[i].x_km = initial_[i].x_km;
        aircraft_[i].y_km = initial_[i].y_km;
    }
    elapsed_  = 0.0;
    steps_    = 0;
}

bool   Simulator::is_paused()       const noexcept { return paused_; }
double Simulator::elapsed_seconds() const noexcept { return elapsed_; }
std::uint64_t Simulator::step_count() const noexcept { return steps_; }

const std::vector<Aircraft>& Simulator::aircraft() const noexcept { return aircraft_; }

// --- Derived quantities ---

double range_km(const Aircraft& a) noexcept {
    return std::hypot(a.x_km, a.y_km);
}

double bearing_deg(const Aircraft& a) noexcept {
    if (a.vx_km_s == 0.0 && a.vy_km_s == 0.0) return 0.0;
    // atan2(east, north) gives CW bearing from north in radians
    double deg = std::atan2(a.vx_km_s, a.vy_km_s) *
                 (180.0 / std::numbers::pi);
    return deg < 0.0 ? deg + 360.0 : deg;
}

double speed_mps(const Aircraft& a) noexcept {
    return std::hypot(a.vx_km_s, a.vy_km_s) * 1000.0; // km/s -> m/s
}

double speed_kt(const Aircraft& a) noexcept {
    return speed_mps(a) / 0.51444; // m/s -> kt
}

} // namespace aeroradar
