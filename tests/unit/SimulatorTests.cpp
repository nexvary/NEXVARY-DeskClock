#include "aeroradar/Simulator.hpp"
#include <cassert>
#include <cmath>
#include <limits>
#include <stdexcept>
#include <vector>
int main() {
    using namespace aeroradar;
    Simulator sim({{1, 3, 4, 0.5, -0.5, 1000}});
    assert(std::abs(range_km(sim.aircraft().front()) - 5.0) < 1e-12);
    sim.step(2.0);
    assert(std::abs(sim.aircraft().front().x_km - 4.0) < 1e-12);
    assert(std::abs(sim.aircraft().front().y_km - 3.0) < 1e-12);
    const auto before = sim.aircraft().front().x_km;
    bool threw = false;
    try { sim.step(-1); } catch (const std::invalid_argument&) { threw = true; }
    assert(threw && sim.aircraft().front().x_km == before);
    threw = false;
    try { sim.step(std::numeric_limits<double>::infinity()); }
    catch (const std::invalid_argument&) { threw = true; }
    assert(threw);
    assert(sim.aircraft().size() == 1);
    assert(range_km({}) == 0);
}
