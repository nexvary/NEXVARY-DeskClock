#pragma once

#include "aeroradar/Simulator.hpp"

namespace aeroradar {

// Three synthetic civilian tracks in the local planar frame.
[[nodiscard]] Simulator make_builtin_scenario();

} // namespace aeroradar
