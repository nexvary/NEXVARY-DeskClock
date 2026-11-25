# NEXVARY AeroRadar

**Civil Aviation Research & Simulation Lab**  
Nexvary Inc. — Educational / Research Platform

> **SIMULATION ONLY — No live aircraft data. Not for navigation or air traffic control.**

---

## What it is

AeroRadar is an open-source, educational desktop application for visualising synthetic civil aviation tracks. It runs a deterministic constant-velocity simulation and renders a Plan-Position Indicator (PPI) radar display. The project exists to explore Qt/QML cockpit UI patterns, C++20 simulation architecture, and cross-platform CI tooling.

No real radar, ADS-B, or SDR hardware is required. All tracks are generated synthetically.

---

## Status summary

| Capability | Status |
|---|---|
| Core simulation kernel (C++20) | Implemented & verified |
| 24 unit tests (Debug + Release) | Implemented & verified |
| Qt/QML desktop shell | Implemented |
| Synthetic PPI radar display | Implemented |
| Track selection + data readout | Implemented |
| Pause / Resume / Reset controls | Implemented |
| Scenario timeline bar | Implemented |
| CI: Ubuntu + Windows builds | Passing |
| QML offscreen smoke test | Passing (Linux) |
| Windows portable ZIP | Planned P1.1 |
| Windows installer | Planned P1.1 |
| 3-D scene view | Planned P2 |
| ADS-B passive receiver | Planned P3 (licensing review required) |
| Arabic RTL localisation | Planned P2 |

---

## Quick start

### Prerequisites

- CMake ≥ 3.22
- C++20 compiler (GCC 12+, Clang 15+, MSVC 2022)
- Qt 6.5+ with `QtQuick`, `QtQuickControls2` *(desktop app only)*

### Build — core + tests (no Qt required)

```bash
cmake -S . -B build -DBUILD_TESTING=ON
cmake --build build --parallel
ctest --test-dir build --output-on-failure
```

Expected: **All 24 simulator tests passed.**

### Build — desktop Qt app

```bash
cmake -S . -B build -DAERORADAR_BUILD_DESKTOP=ON -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release --parallel
./build/aeroradar_desktop          # Linux
build\Release\aeroradar_desktop.exe  # Windows
```

### Smoke test (headless / CI)

```bash
QT_QPA_PLATFORM=offscreen ./build/aeroradar_desktop --smoke
```

Exit 0 = QML loaded cleanly. Exit 1 = load failure.

---

## Architecture overview

```
core/simulation/          C++20 Simulator kernel — zero Qt dependency
  include/aeroradar/      Public headers (Simulator.hpp)
  src/                    Implementation (Simulator.cpp)

apps/
  cli/                    Headless CLI smoke test
  desktop/                Qt bridge (SimulatorModel, main.cpp)

ui/qml/                   QML module "AeroRadar"
  AeroTheme.qml           Design token singleton (colours, fonts)
  Main.qml                Orchestration-only root window
  RadarPpi.qml            Plan-Position Indicator Canvas component
  StatusStrip.qml         Application header strip
  FlightInstruments.qml   Horizontal instruments readout row
  SimulationControls.qml  Right-panel playback controls + track list

tests/
  TestMacros.hpp          AERO_REQUIRE / AERO_TEST — NDEBUG-safe
  unit/SimulatorTests.cpp 24 deterministic unit tests
```

The simulation kernel (`aeroradar_core`) is a pure C++ static library with no Qt or platform dependency. The Qt desktop shell is an optional layer on top.

---

## CI

GitHub Actions runs on every push to `main`, `feature/**`, `quality/**`, and all pull requests:

- **Core job** — builds and tests in Debug + Release on Ubuntu and Windows.
- **Desktop job** — builds with Qt 6.5, runs the core tests, and runs the QML offscreen smoke test.

---

## Limitations

- Track motion is constant-velocity planar — no geodesy, flight dynamics, or terrain.
- Weather, scenario, and environment fields are hardcoded placeholders.
- No persistent scenario serialisation or replay.
- No digital signing on Windows binaries.
- Screenshots require a live desktop session; CI only validates headless smoke loading.

---

## Safety boundaries

AeroRadar is a research and educational simulation tool:

- All tracks are **synthetic**. No live radar, ADS-B, or SDR data is processed.
- Not certified for navigation, air traffic control, or safety-of-life applications.
- No weapon targeting, interception, jamming, spoofing, or radio transmission capability.

---

## Licence

See `CONTRIBUTING.md` and `SECURITY.md` for contribution and vulnerability disclosure guidelines.  
Third-party dependency notices are documented in `docs/THIRD_PARTY_ADOPTION_MATRIX.md`.

---

*Nexvary Inc. — Civil Aviation Research*
