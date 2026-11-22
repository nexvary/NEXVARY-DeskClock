#include "aeroradar/Simulator.hpp"
#include <cmath>
#include <numbers>
#include <stdexcept>
#include <utility>

namespace aeroradar {

Simulator::Simulator(std::vector<Aircraft> aircraft)
    : initial_(aircraft), aircraft_(std::move(aircraft))
{}

void Simulator::step(double seconds) {
    if (!std::isfinite(seconds) || seconds < 0.0)
        throw std::invalid_argument("step duration must be finite and nonnegative");

    if (paused_) return;

    for (const auto& a : aircraft_) {
        if (!std::isfinite(a.x_km) || !std::isfinite(a.y_km) ||
            !std::isfinite(a.vx_km_s) || !std::isfinite(a.vy_km_s))
            throw std::invalid_argument("aircraft state must be finite before step");

        if (!std::isfinite(a.x_km + a.vx_km_s * seconds) ||
            !std::isfinite(a.y_km + a.vy_km_s * seconds))
            throw std::overflow_error("simulation state overflow");
    }

    for (auto& a : aircraft_) {
        a.x_km += a.vx_km_s * seconds;
        a.y_km += a.vy_km_s * seconds;
    }
    elapsed_ += seconds;
    ++steps_;
}

void Simulator::pause()  noexcept { paused_ = true; }
void Simulator::resume() noexcept { paused_ = false; }

void Simulator::reset() noexcept {
    aircraft_ = initial_;
    elapsed_  = 0.0;
    steps_    = 0;
}

bool   Simulator::is_paused()       const noexcept { return paused_; }
double Simulator::elapsed_seconds() const noexcept { return elapsed_; }
int    Simulator::step_count()      const noexcept { return steps_; }

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
