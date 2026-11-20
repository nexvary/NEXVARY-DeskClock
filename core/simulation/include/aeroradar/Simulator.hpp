#pragma once
#include <cstddef>
#include <vector>
namespace aeroradar {
struct Aircraft {
    int id{};
    double x_km{};
    double y_km{};
    double vx_km_s{};
    double vy_km_s{};
    double altitude_m{};
};
class Simulator {
public:
    explicit Simulator(std::vector<Aircraft> aircraft);
    void step(double seconds);
    [[nodiscard]] const std::vector<Aircraft>& aircraft() const noexcept;
private:
    std::vector<Aircraft> aircraft_;
};
[[nodiscard]] double range_km(const Aircraft& target) noexcept;
}
