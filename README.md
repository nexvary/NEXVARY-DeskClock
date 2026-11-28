# NEXVARY AeroRadar

**Civil Aviation Research & Simulation Lab**  
Nexvary Inc. — Educational / Research Platform

> **SIMULATION ONLY — No live aircraft data. Not for navigation or air traffic control.**

---

## What it is

AeroRadar is an educational desktop application for visualising synthetic civil aviation tracks. It runs a deterministic constant-velocity simulation and renders a Plan-Position Indicator (PPI) radar display. The project exists to explore Qt/QML cockpit UI patterns, C++20 simulation architecture, and cross-platform CI tooling.

No real radar, ADS-B, or SDR hardware is required. All tracks are generated synthetically.

---

## Current capabilities

The optional Qt desktop displays a synthetic PPI with range rings, a sweep, selectable tracks, track history and data readouts. Zoom and drag pan adjust the view, and controls filter track types or hide labels and history. The built-in three-aircraft scenario supports pause, resume, reset and single-step. Playback speed ranges from 0.25× to 4×. The Scenarios workspace opens [versioned local JSON scenarios](docs/scenarios/README.md). The simulator uses local planar motion with constant-velocity tracks or timed waypoints and altitude profiles. The desktop has flight, radar, traffic, overview, diagnostics and help workspaces, with persistent light and dark appearance settings.

The project lives in the existing `nexvary/NEXVARY-DeskClock` repository. The latest verified development baseline before this work is `d173a1e89e3f17d58c7c0a7cadbe6fd53c1a86b9` on `feature/p1-qml-components`. It produced unsigned Windows x64 portable and installer candidates and rendered Linux dashboard screenshots. See [development log](docs/DEVELOPMENT-LOG.md) for exact CI jobs, artifacts and current verification.

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

CTest runs the simulator unit suite. Use `ctest --test-dir build -V` to see individual case results.

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

The smoke command exits with 0 after starting the QML application and with 1 on a root-object load failure or a warning from the QML engine.

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
  unit/SimulatorTests.cpp Simulator regression suite
  integration/            Qt model tests
```

The simulation kernel (`aeroradar_core`) is a pure C++ static library with no Qt or platform dependency. The Qt desktop shell is an optional layer on top.

---

## CI

GitHub Actions runs for pulls and for pushes to the configured development branches.

- **Core job** — builds and tests in Debug and Release on Ubuntu with GCC and Clang and on Windows with MSVC.
- **Desktop job** — builds with Qt 6.5, runs core, model and smoke tests, renders Linux screenshots and verifies Windows packaging.

---

## Limitations

- Motion is planar. Timed waypoints use linear interpolation and have no validated flight dynamics, geodesy or terrain.
- Weather, terrain and in-app scenario editing are pending.
- Local scenario import is available. Save, migration and replay are pending.
- No digital signing on Windows binaries.
- CI captures Linux screenshots from a running window under Xvfb. The Windows runner exercises packaged app startup and silent installation.

---

## Safety boundaries

AeroRadar is a research and educational simulation tool:

- All tracks are **synthetic**. No live radar, ADS-B, or SDR data is processed.
- Not certified for navigation, air traffic control, or safety-of-life applications.
- No weapon targeting, interception, jamming, spoofing, or radio transmission capability.

---

## Licence

See [contribution guidelines](CONTRIBUTING.md), [engineering instructions](AGENTS.md) and [security reporting](SECURITY.md).
Copyright (c) 2026 Nexvary Inc. All rights reserved. No license has been granted for reuse or redistribution. See the [dependency and license review](docs/THIRD_PARTY_ADOPTION_MATRIX.md).

---

*Nexvary Inc. — Civil Aviation Research*
