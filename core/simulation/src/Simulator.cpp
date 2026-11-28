#include "aeroradar/Simulator.hpp"
#include <algorithm>
#include <cmath>
#include <limits>
#include <numbers>
#include <stdexcept>
#include <unordered_map>
#include <utility>

namespace aeroradar {

Simulator::Simulator(std::vector<Aircraft> aircraft, std::vector<AircraftRoute> routes)
    : aircraft_(std::move(aircraft)), routes_(aircraft_.size()), next_(aircraft_.size())
{
    std::unordered_map<int, std::size_t> indices;
    indices.reserve(aircraft_.size());
    for (std::size_t i = 0; i < aircraft_.size(); ++i) {
        const auto& a = aircraft_[i];
        if (!indices.emplace(a.id, i).second)
            throw std::invalid_argument("aircraft IDs must be unique");
        if (!std::isfinite(range_km(a)) || !std::isfinite(speed_kt(a)) ||
            !std::isfinite(a.altitude_m))
            throw std::invalid_argument("aircraft state and derived quantities must be finite");
        if (a.type != AircraftType::FIXED_WING && a.type != AircraftType::MULTIROTOR)
            throw std::invalid_argument("unknown aircraft type");
    }

    for (auto& route : routes) {
        const auto match = indices.find(route.aircraft_id);
        if (match == indices.end() || route.waypoints.empty() || !routes_[match->second].empty())
            throw std::invalid_argument("route must uniquely reference an existing aircraft");

        auto& a = aircraft_[match->second];
        Waypoint previous{0.0, a.x_km, a.y_km, a.altitude_m};
        for (const auto& point : route.waypoints) {
            if (!std::isfinite(point.time_s) || point.time_s <= previous.time_s ||
                !std::isfinite(std::hypot(point.x_km, point.y_km)) ||
                !std::isfinite(point.altitude_m))
                throw std::invalid_argument("waypoints must have increasing times and finite state");
            const double duration = point.time_s - previous.time_s;
            const double east = (point.x_km - previous.x_km) / duration;
            const double north = (point.y_km - previous.y_km) / duration;
            if (!std::isfinite((std::hypot(east, north) * 1000.0) / 0.51444))
                throw std::invalid_argument("route velocity is not representable");
            previous = point;
        }
        apply_movement(a, route_movement(a, route.waypoints, 0.0));
        routes_[match->second] = std::move(route.waypoints);
    }
    initial_ = aircraft_;
}

Simulator::Movement Simulator::route_movement(const Aircraft& initial,
                                               const std::vector<Waypoint>& route,
                                               double elapsed) {
    const auto destination = std::ranges::upper_bound(route, elapsed, {}, &Waypoint::time_s);
    if (destination == route.end()) {
        const auto& last = route.back();
        return {last.x_km, last.y_km, last.altitude_m, 0.0, 0.0};
    }

    const Waypoint origin = destination == route.begin()
        ? Waypoint{0.0, initial.x_km, initial.y_km, initial.altitude_m}
        : *(destination - 1);
    const double duration = destination->time_s - origin.time_s;
    const double fraction = (elapsed - origin.time_s) / duration;
    return {
        std::lerp(origin.x_km, destination->x_km, fraction),
        std::lerp(origin.y_km, destination->y_km, fraction),
        std::lerp(origin.altitude_m, destination->altitude_m, fraction),
        (destination->x_km - origin.x_km) / duration,
        (destination->y_km - origin.y_km) / duration
    };
}

void Simulator::apply_movement(Aircraft& aircraft, const Movement& movement) noexcept {
    aircraft.x_km = movement.x_km;
    aircraft.y_km = movement.y_km;
    aircraft.altitude_m = movement.altitude_m;
    aircraft.vx_km_s = movement.vx_km_s;
    aircraft.vy_km_s = movement.vy_km_s;
}

void Simulator::step(double seconds) {
    if (!paused_)
        advance(seconds);
}

void Simulator::step_once(double seconds) {
    if (paused_)
        advance(seconds);
}

void Simulator::advance(double seconds) {
    if (!std::isfinite(seconds) || seconds < 0.0)
        throw std::invalid_argument("step duration must be finite and nonnegative");

    const double nextElapsed = elapsed_ + seconds;
    if (!std::isfinite(nextElapsed) || steps_ == std::numeric_limits<std::uint64_t>::max())
        throw std::overflow_error("simulation clock overflow");

    for (std::size_t i = 0; i < aircraft_.size(); ++i) {
        const auto& a = aircraft_[i];
        next_[i] = routes_[i].empty()
            ? Movement{a.x_km + a.vx_km_s * seconds, a.y_km + a.vy_km_s * seconds,
                       a.altitude_m, a.vx_km_s, a.vy_km_s}
            : route_movement(initial_[i], routes_[i], nextElapsed);
        if (!std::isfinite(std::hypot(next_[i].x_km, next_[i].y_km)))
            throw std::overflow_error("simulation position or range overflow");
    }

    for (std::size_t i = 0; i < aircraft_.size(); ++i)
        apply_movement(aircraft_[i], next_[i]);
    elapsed_ = nextElapsed;
    ++steps_;
}

void Simulator::pause()  noexcept { paused_ = true; }
void Simulator::resume() noexcept { paused_ = false; }

void Simulator::reset() noexcept {
    for (std::size_t i = 0; i < aircraft_.size(); ++i) {
        const auto& a = initial_[i];
        apply_movement(aircraft_[i], {a.x_km, a.y_km, a.altitude_m, a.vx_km_s, a.vy_km_s});
    }
    elapsed_  = 0.0;
    steps_    = 0;
}

bool   Simulator::is_paused()       const noexcept { return paused_; }
double Simulator::elapsed_seconds() const noexcept { return elapsed_; }
std::uint64_t Simulator::step_count() const noexcept { return steps_; }

bool Simulator::has_routes() const noexcept {
    return std::ranges::any_of(routes_, [](const auto& route) { return !route.empty(); });
}

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
