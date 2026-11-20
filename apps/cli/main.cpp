#include "aeroradar/Simulator.hpp"
#include <iomanip>
#include <iostream>
int main() {
    using namespace aeroradar;
    Simulator simulation({{101, 10.0, 5.0, 0.12, 0.02, 9000.0},
                          {102, 25.0, -15.0, -0.08, 0.06, 11500.0}});
    for (int tick = 0; tick < 5; ++tick) {
        std::cout << "SIMULATED tick=" << tick << "\n";
        for (const auto& aircraft : simulation.aircraft()) {
            std::cout << "target=" << aircraft.id << " range_km="
                      << std::fixed << std::setprecision(2) << range_km(aircraft)
                      << " altitude_m=" << aircraft.altitude_m << "\n";
        }
        simulation.step(1.0);
    }
}
