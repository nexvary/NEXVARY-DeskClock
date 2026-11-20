#include "aeroradar/Simulator.hpp"
#include <cmath>
#include <stdexcept>
#include <utility>
namespace aeroradar {
Simulator::Simulator(std::vector<Aircraft> aircraft): aircraft_(std::move(aircraft)) {}
void Simulator::step(double seconds) {
    if (!std::isfinite(seconds) || seconds < 0.0) {
        throw std::invalid_argument("step duration must be finite and nonnegative");
    }
    for (const auto& aircraft : aircraft_) {
        if (!std::isfinite(aircraft.x_km) || !std::isfinite(aircraft.y_km) ||
            !std::isfinite(aircraft.vx_km_s) || !std::isfinite(aircraft.vy_km_s)) {
            throw std::invalid_argument("aircraft state must be finite");
        }
        if (!std::isfinite(aircraft.x_km + aircraft.vx_km_s * seconds) ||
            !std::isfinite(aircraft.y_km + aircraft.vy_km_s * seconds)) {
            throw std::overflow_error("simulation state overflow");
        }
    }
    for (auto& aircraft : aircraft_) {
        aircraft.x_km += aircraft.vx_km_s * seconds;
        aircraft.y_km += aircraft.vy_km_s * seconds;
    }
}
const std::vector<Aircraft>& Simulator::aircraft() const noexcept { return aircraft_; }
double range_km(const Aircraft& target) noexcept {
    return std::hypot(target.x_km, target.y_km);
}
}
