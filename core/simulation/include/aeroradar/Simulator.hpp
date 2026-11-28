#pragma once
#include <cstdint>
#include <string>
#include <vector>

namespace aeroradar {

enum class AircraftType { FIXED_WING, MULTIROTOR };

struct Aircraft {
    int          id{};
    double       x_km{};        // local planar east, km from origin
    double       y_km{};        // local planar north, km from origin
    double       vx_km_s{};     // velocity east, km/s
    double       vy_km_s{};     // velocity north, km/s
    double       altitude_m{};  // altitude above reference plane, m
    AircraftType type{ AircraftType::FIXED_WING };
    std::string  label{};
};

struct Waypoint {
    double time_s{};
    double x_km{};
    double y_km{};
    double altitude_m{};
};

struct AircraftRoute {
    int aircraft_id{};
    std::vector<Waypoint> waypoints;
};

class Simulator {
public:
    // Aircraft IDs must be unique; state and displayed quantities must be finite.
    // Routes have increasing elapsed timestamps and interpolate from the initial position.
    explicit Simulator(std::vector<Aircraft> aircraft, std::vector<AircraftRoute> routes = {});

    // Does nothing when paused. Otherwise rejects invalid duration or overflow
    // without changing aircraft, elapsed time or step count.
    void step(double seconds);
    // Advance one step while paused, preserving the pause state. No-op while running.
    void step_once(double seconds);

    // Control — idempotent; never throw
    void pause()  noexcept;
    void resume() noexcept;
    void reset()  noexcept; // restore initial positions; keeps paused state

    [[nodiscard]] bool   is_paused()       const noexcept;
    [[nodiscard]] double elapsed_seconds() const noexcept;
    [[nodiscard]] std::uint64_t step_count() const noexcept;

    [[nodiscard]] bool has_routes() const noexcept;
    [[nodiscard]] const std::vector<Aircraft>& aircraft() const noexcept;

private:
    struct Movement {
        double x_km;
        double y_km;
        double altitude_m;
        double vx_km_s;
        double vy_km_s;
    };

    static Movement route_movement(const Aircraft& initial, const std::vector<Waypoint>& route,
                                   double elapsed);
    static void apply_movement(Aircraft& aircraft, const Movement& movement) noexcept;
    void advance(double seconds);

    std::vector<Aircraft> initial_;
    std::vector<Aircraft> aircraft_;
    std::vector<std::vector<Waypoint>> routes_;
    std::vector<Movement> next_;
    bool   paused_{ false };
    double elapsed_{ 0.0 };
    std::uint64_t steps_{ 0 };
};

// Pure derived quantities — do not mutate
[[nodiscard]] double range_km(const Aircraft& a)    noexcept;
[[nodiscard]] double bearing_deg(const Aircraft& a) noexcept; // heading CW from north
[[nodiscard]] double speed_mps(const Aircraft& a)   noexcept;
[[nodiscard]] double speed_kt(const Aircraft& a)    noexcept;

} // namespace aeroradar
