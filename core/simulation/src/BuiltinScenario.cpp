#include "aeroradar/BuiltinScenario.hpp"

#include <cmath>
#include <numbers>
#include <utility>

namespace aeroradar {

Simulator make_builtin_scenario() {
    constexpr double knotsToKmPerSecond = 0.51444 / 1000.0;
    const auto velocity = [](double headingDeg, double speedKt) {
        const double radians = headingDeg * (std::numbers::pi / 180.0);
        const double speed = speedKt * knotsToKmPerSecond;
        return std::pair{speed * std::sin(radians), speed * std::cos(radians)};
    };

    const auto [east1, north1] = velocity(87.0, 118.0);
    const auto [east2, north2] = velocity(200.0, 36.0);
    const auto [east3, north3] = velocity(310.0, 83.0);

    return Simulator({
        {1, 14.0, 5.0, east1, north1, 3500.0, AircraftType::FIXED_WING, "AC-01"},
        {2, -6.5, -17.5, east2, north2, 150.0, AircraftType::MULTIROTOR, "UAS-01"},
        {3, -9.0, 8.0, east3, north3, 1200.0, AircraftType::MULTIROTOR, "UAS-02"},
    });
}

} // namespace aeroradar
