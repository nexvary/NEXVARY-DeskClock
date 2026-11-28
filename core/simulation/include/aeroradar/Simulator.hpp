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

class Simulator {
public:
    // Aircraft IDs must be unique; state and displayed quantities must be finite.
    explicit Simulator(std::vector<Aircraft> aircraft);

    // Does nothing when paused. Otherwise rejects invalid duration or overflow
    // without changing aircraft, elapsed time or step count.
    void step(double seconds);

    // Control — idempotent; never throw
    void pause()  noexcept;
    void resume() noexcept;
    void reset()  noexcept; // restore initial positions; keeps paused state

    [[nodiscard]] bool   is_paused()       const noexcept;
    [[nodiscard]] double elapsed_seconds() const noexcept;
    [[nodiscard]] std::uint64_t step_count() const noexcept;

    [[nodiscard]] const std::vector<Aircraft>& aircraft() const noexcept;

private:
    std::vector<Aircraft> initial_;
    std::vector<Aircraft> aircraft_;
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
