#include "aeroradar/Simulator.hpp"
#include "../TestMacros.hpp"
#include <cmath>
#include <limits>
#include <numbers>
#include <stdexcept>

// --- Kinematic stepping ---

AERO_TEST(range_initial) {
    using namespace aeroradar;
    Aircraft a{ 1, 3.0, 4.0, 0.5, -0.5, 1000.0 };
    AERO_REQUIRE_NEAR(range_km(a), 5.0, 1e-12);
}

AERO_TEST(range_zero) {
    AERO_REQUIRE_NEAR(aeroradar::range_km({}), 0.0, 1e-15);
}

AERO_TEST(step_position) {
    using namespace aeroradar;
    Simulator sim({ {1, 3.0, 4.0, 0.5, -0.5, 1000.0} });
    sim.step(2.0);
    AERO_REQUIRE_NEAR(sim.aircraft().front().x_km, 4.0,  1e-12);
    AERO_REQUIRE_NEAR(sim.aircraft().front().y_km, 3.0,  1e-12);
}

AERO_TEST(elapsed_accumulates) {
    using namespace aeroradar;
    Simulator sim({ {1, 0.0, 0.0, 1.0, 0.0, 500.0} });
    sim.step(3.0);
    sim.step(2.0);
    AERO_REQUIRE_NEAR(sim.elapsed_seconds(), 5.0, 1e-12);
    AERO_REQUIRE(sim.step_count() == 2);
}

AERO_TEST(step_zero_dt) {
    using namespace aeroradar;
    Simulator sim({ {1, 7.0, 0.0, 1.0, 0.0, 100.0} });
    sim.step(0.0);
    AERO_REQUIRE_NEAR(sim.aircraft().front().x_km, 7.0, 1e-15);
}

AERO_TEST(step_negative_throws) {
    using namespace aeroradar;
    Simulator sim({ {1, 3.0, 4.0, 0.5, -0.5, 1000.0} });
    const double before = sim.aircraft().front().x_km;
    AERO_REQUIRE_THROWS(std::invalid_argument, sim.step(-1.0));
    AERO_REQUIRE_NEAR(sim.aircraft().front().x_km, before, 1e-15);
}

AERO_TEST(step_inf_throws) {
    using namespace aeroradar;
    Simulator sim({ {1, 3.0, 4.0, 0.5, -0.5, 1000.0} });
    AERO_REQUIRE_THROWS(std::invalid_argument,
        sim.step(std::numeric_limits<double>::infinity()));
}

AERO_TEST(step_nan_throws) {
    using namespace aeroradar;
    Simulator sim({ {1, 3.0, 4.0, 0.5, -0.5, 1000.0} });
    AERO_REQUIRE_THROWS(std::invalid_argument,
        sim.step(std::numeric_limits<double>::quiet_NaN()));
}

// --- Pause / Resume / Reset ---

AERO_TEST(pause_stops_motion) {
    using namespace aeroradar;
    Simulator sim({ {1, 0.0, 0.0, 1.0, 0.0, 100.0} });
    sim.pause();
    AERO_REQUIRE(sim.is_paused());
    sim.step(5.0);  // must be silent no-op while paused
    AERO_REQUIRE_NEAR(sim.aircraft().front().x_km, 0.0, 1e-15);
    AERO_REQUIRE_NEAR(sim.elapsed_seconds(), 0.0, 1e-15);
    AERO_REQUIRE(sim.step_count() == 0);
}

AERO_TEST(resume_resumes_motion) {
    using namespace aeroradar;
    Simulator sim({ {1, 0.0, 0.0, 1.0, 0.0, 100.0} });
    sim.pause();
    sim.step(5.0);
    sim.resume();
    AERO_REQUIRE(!sim.is_paused());
    sim.step(2.0);
    AERO_REQUIRE_NEAR(sim.aircraft().front().x_km, 2.0, 1e-12);
}

AERO_TEST(reset_restores_initial) {
    using namespace aeroradar;
    Simulator sim({ {1, 3.0, 4.0, 0.5, -0.5, 1000.0} });
    sim.step(10.0);
    AERO_REQUIRE(sim.aircraft().front().x_km != 3.0);
    sim.reset();
    AERO_REQUIRE_NEAR(sim.aircraft().front().x_km, 3.0,  1e-15);
    AERO_REQUIRE_NEAR(sim.aircraft().front().y_km, 4.0,  1e-15);
    AERO_REQUIRE_NEAR(sim.elapsed_seconds(), 0.0, 1e-15);
    AERO_REQUIRE(sim.step_count() == 0);
}

AERO_TEST(reset_does_not_unpause) {
    using namespace aeroradar;
    Simulator sim({ {1, 0.0, 0.0, 1.0, 0.0, 100.0} });
    sim.pause();
    sim.step(5.0);
    sim.reset();
    // paused state is preserved by reset per spec
    AERO_REQUIRE(sim.is_paused());
}

// --- Multiple aircraft ---

AERO_TEST(multi_aircraft) {
    using namespace aeroradar;
    Simulator sim({
        {101, 10.0, 5.0,   0.12,  0.02, 9000.0},
        {102, 25.0, -15.0, -0.08, 0.06, 11500.0},
    });
    AERO_REQUIRE(sim.aircraft().size() == 2u);
    sim.step(1.0);
    AERO_REQUIRE_NEAR(sim.aircraft()[0].x_km,  10.12, 1e-12);
    AERO_REQUIRE_NEAR(sim.aircraft()[1].x_km,  24.92, 1e-12);
}

// --- Derived quantities ---

AERO_TEST(bearing_east) {
    using namespace aeroradar;
    // Pure east velocity → heading = 90°
    Aircraft a{ 1, 0.0, 0.0, 1.0, 0.0, 0.0 };
    AERO_REQUIRE_NEAR(bearing_deg(a), 90.0, 1e-9);
}

AERO_TEST(bearing_north) {
    using namespace aeroradar;
    // Pure north velocity → heading = 0°
    Aircraft a{ 1, 0.0, 0.0, 0.0, 1.0, 0.0 };
    AERO_REQUIRE_NEAR(bearing_deg(a), 0.0, 1e-9);
}

AERO_TEST(bearing_southwest) {
    using namespace aeroradar;
    // SW velocity → heading = 225°
    Aircraft a{ 1, 0.0, 0.0, -1.0, -1.0, 0.0 };
    AERO_REQUIRE_NEAR(bearing_deg(a), 225.0, 1e-9);
}

AERO_TEST(speed_mps_diagonal) {
    using namespace aeroradar;
    // vx=vy=0.001 km/s → speed = sqrt(2)*1 m/s ≈ 1.4142 m/s
    Aircraft a{ 1, 0.0, 0.0, 0.001, 0.001, 0.0 };
    AERO_REQUIRE_NEAR(speed_mps(a), std::hypot(1.0, 1.0), 1e-9);
}

AERO_TEST(speed_kt_conversion) {
    using namespace aeroradar;
    // 1 kt = 0.51444 m/s; 100 kt = 51.444 m/s = 0.051444 km/s east
    Aircraft a{ 1, 0.0, 0.0, 0.051444, 0.0, 0.0 };
    AERO_REQUIRE_NEAR(speed_kt(a), 100.0, 0.01);
}

AERO_TEST(bearing_west) {
    using namespace aeroradar;
    // Pure west velocity (vx = -1, vy = 0) -> bearing = 270 deg
    Aircraft a{ 1, 0.0, 0.0, -1.0, 0.0, 0.0 };
    AERO_REQUIRE_NEAR(bearing_deg(a), 270.0, 1e-9);
}

int main() {
    // AERO_TEST blocks run via static initialisers before main().
    // If any failed, std::exit(1) was already called.
    // 19 tests: range(2) step(3) elapsed(1) invalid_dt(3)
    //           pause/resume/reset(4) multi(1) bearing(4) speed(2) = 19
    std::fprintf(stdout, "\nAll 19 simulator tests passed.\n");
    return 0;
}
