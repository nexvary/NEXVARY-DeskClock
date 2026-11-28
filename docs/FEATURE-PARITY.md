# Feature parity

The matrix describes the working branch. Paths shortened to file basenames refer to unique tracked files. Evidence labels resolve to [the development log](DEVELOPMENT-LOG.md). Verified denotes a feature whose acceptance is covered by executed evidence. Partial denotes a subset or an outstanding acceptance check.

## P0

| Feature ID | Requirement | Implementation | Status | Priority | Source Files | Tests | Evidence | Remaining Gap | Next Action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P0-01 | Product identity | App/installer/README use product name; GitHub retains historical slug | Implemented | P0 | CMakeLists.txt, installer/aeroradar.nsi, README.md | Repository and package metadata audit | Baseline inventory | Version parity across installer and app | Derive installer metadata from project version |
| P0-02 | Branch integration | All prior development tips are ancestors of the P1 base | Partial | P0 | Git history | Ancestry and PR audit | Baseline inventory | Four upstream drafts | Integrate stack in order through reviewed PRs |
| P0-03 | C++20 and compiler compatibility | C++20 enforced; GCC and Clang/MSVC CI defined | Partial | P0 | CMakeLists.txt, .github/workflows/ci.yml | Core Debug/Release | Local P0 and baseline CI | Changed revision platform coverage | Run full CI |
| P0-04 | Portable pi constant | Uses std::numbers::pi in core and adapter | Verified | P0 | Simulator.cpp, SimulatorModel.cpp | Bearing cases; desktop build | Local P0 | Cross-platform adapter build | Confirm CI |
| P0-05 | Integer overflow | Checked uint64 step counter and tick-based clock formatting | Partial | P0 | Simulator.cpp, SimulatorModel.cpp | Clock display regression | Local P0 | Counter exhaustion and long-run checks | Exercise clock limits with fixed-clock tests |
| P0-06 | Floating-point overflow | Rejects unrepresentable position, range and elapsed time before mutation | Verified | P0 | Simulator.cpp | step_rejects_elapsed_overflow_atomically, step_rejects_range_overflow_atomically | Local P0 | Wider scenario domains | Maintain invariant at future boundaries |
| P0-07 | Input validation | Validates finite state, duration, unique IDs and aircraft enum | Verified | P0 | Simulator.cpp | constructor_rejects_invalid_aircraft, step_inf_throws, step_nan_throws | Local P0 | Future scenario and file inputs | Apply validations at import boundary |
| P0-08 | Memory and exception safety | RAII, allocation-free reset and atomic step | Partial | P0 | Simulator.cpp, SimulatorModel.cpp | Reset and overflow regressions | Local P0 | Allocation and stress profiling | Run extended sanitizer stress suite |
| P0-09 | Thread safety | Single-owner core and GUI-affinity adapter | Partial | P0 | SimulatorModel.hpp, ARCHITECTURE.md | Model tests | Baseline CI, Local P0 | Concurrent provider design | Define snapshot transfer before introducing worker threads |
| P0-10 | Timer and QML update performance | Stopped paused timer and linear trail conversion | Partial | P0 | SimulatorModel.cpp | pauseStopsSimulation | Local P0 | Frame and tick benchmarks | Measure representative track counts |
| P0-11 | Paused simulation refresh | Paused timer sleeps and emits no unsolicited simulation updates | Verified | P0 | SimulatorModel.cpp | pauseStopsSimulation, resumeRestoresSimulation | Local P0 | Changed revision hosted runs | Confirm Qt matrix |
| P0-12 | License and IP review | Repository and runtime inventory reviewed | Partial | P0 | THIRD_PARTY_ADOPTION_MATRIX.md | Tracked files and workflow audit | Baseline inventory | Source license grant and runtime notices | Resolve publication and redistribution terms |
| P0-13 | README accuracy | Describes repository identity, current UI and historical package evidence | Implemented | P0 | README.md | Cross-check repository inventory | Baseline inventory | Refresh with future evidence | Review on each delivery |
| P0-14 | Regression suite | NDEBUG-safe core and Qt tests with new overflow and notification cases | Partial | P0 | tests/, CMakeLists.txt | Core, model, smoke | Local P0 | Cross-platform and UI cases | Run all hosted jobs |

## P1

| Feature ID | Requirement | Implementation | Status | Priority | Source Files | Tests | Evidence | Remaining Gap | Next Action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P1-01 | NEXVARY design system | Brand, color and typography singleton | Partial | P1 | AeroTheme.qml | Baseline rendered screenshots | Baseline CI | Complete token coverage | Move remaining UI colors into the theme |
| P1-02 | Reusable QML components | PPI, header, controls and instrument components | Partial | P1 | ui/qml/, CMakeLists.txt | Desktop smoke and screenshots | Baseline CI | Reusable workspace and track list | Extract tested navigation and track list |
| P1-03 | Design tokens | Dark dashboard colors and fonts defined | Partial | P1 | AeroTheme.qml | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P1-04 | Typography system | Theme font family and per-view sizes | Partial | P1 | AeroTheme.qml, ui/qml/ | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P1-05 | Iconography | PPI geometry symbols | Partial | P1 | RadarPpi.qml | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P1-06 | Dark mode | Current dark dashboard appearance | Implemented | P1 | AeroTheme.qml | Rendered screenshot | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P1-07 | Light mode | — | Missing | P1 | — | — | — | Light mode | Implement light mode with acceptance tests |
| P1-08 | Responsive desktop layout | Window layout and a minimum-size capture path | Partial | P1 | Main.qml | Rendered screenshots at two sizes | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P1-09 | High-DPI support | Qt Quick layout using logical dimensions | Partial | P1 | Main.qml | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P1-10 | Accessibility | Pointer controls lack an accessible button role | Partial | P1 | SimulationControls.qml | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P1-11 | Keyboard navigation | Current playback controls and radar selection use pointer areas | Missing | P1 | SimulationControls.qml, RadarPpi.qml | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P1-12 | Multiple displays | — | Missing | P1 | — | — | — | Multiple displays | Implement multiple displays with acceptance tests |
| P1-13 | Overview workspace | — | Missing | P1 | — | — | — | Overview workspace | Implement overview workspace with acceptance tests |
| P1-14 | Flight simulation workspace | Built-in simulation, control and track readout | Partial | P1 | Main.qml, SimulationControls.qml | Qt model suite and smoke | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P1-15 | Radar PPI workspace | PPI embedded in flight dashboard | Partial | P1 | RadarPpi.qml | Rendered screenshots | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P1-16 | Air traffic visualization workspace | Track list embedded in controls | Partial | P1 | SimulationControls.qml | Qt model suite | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P1-17 | Scenario management workspace | — | Missing | P1 | — | — | — | Scenario management workspace | Implement scenario management workspace with acceptance tests |
| P1-18 | Replay workspace | — | Missing | P1 | — | — | — | Replay workspace | Implement replay workspace with acceptance tests |
| P1-19 | Research workspace | — | Missing | P1 | — | — | — | Research workspace | Implement research workspace with acceptance tests |
| P1-20 | System settings workspace | — | Missing | P1 | — | — | — | System settings workspace | Implement system settings workspace with acceptance tests |
| P1-21 | Diagnostics workspace | — | Missing | P1 | — | — | — | Diagnostics workspace | Implement diagnostics workspace with acceptance tests |
| P1-22 | Help and documentation workspace | — | Missing | P1 | — | — | — | Help and documentation workspace | Implement help and documentation workspace with acceptance tests |

## P2

| Feature ID | Requirement | Implementation | Status | Priority | Source Files | Tests | Evidence | Remaining Gap | Next Action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P2-01 | Deterministic simulation | Deterministic planar update for a given timestep sequence | Partial | P2 | Simulator.cpp | step_position, multi_aircraft | Local P0 | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P2-02 | Fixed-timestep simulation | Fixed 100 ms desktop steps; core accepts arbitrary duration | Partial | P2 | Simulator.cpp, SimulatorModel.cpp | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P2-03 | Simulation clock | Elapsed seconds and uint64 step count | Partial | P2 | Simulator.cpp, SimulatorModel.cpp | elapsed_accumulates, clockDisplayUsesFixedTicks | Local P0 | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P2-04 | Configurable time scale | — | Missing | P2 | — | — | — | Configurable time scale | Implement configurable time scale with acceptance tests |
| P2-05 | Pause / resume / reset | Core state transitions and Qt controls | Implemented | P2 | Simulator.cpp, SimulatorModel.cpp | pause_stops_motion, reset_restores_initial, Qt model cases | Local P0 | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P2-06 | Step-by-step simulation | Core step method; no desktop manual stepping | Partial | P2 | Simulator.cpp | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P2-07 | Scenario loading | — | Missing | P2 | — | — | — | Scenario loading | Implement scenario loading with acceptance tests |
| P2-08 | Scenario editing | — | Missing | P2 | — | — | — | Scenario editing | Implement scenario editing with acceptance tests |
| P2-09 | Scenario validation | Initial aircraft-state validation | Partial | P2 | Simulator.cpp | constructor_rejects_invalid_aircraft | Local P0 | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P2-10 | Synthetic aircraft generation | Fixed synthetic aircraft fixtures in desktop and CLI | Partial | P2 | SimulatorModel.cpp, apps/cli/main.cpp | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P2-11 | Civil flight paths | Straight-line local planar paths | Partial | P2 | Simulator.cpp | step_position | Local P0 | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P2-12 | Configurable waypoints | — | Missing | P2 | — | — | — | Configurable waypoints | Implement configurable waypoints with acceptance tests |
| P2-13 | Altitude profiles | — | Missing | P2 | — | — | — | Altitude profiles | Implement altitude profiles with acceptance tests |
| P2-14 | Synthetic weather conditions | — | Missing | P2 | — | — | — | Synthetic weather conditions | Implement synthetic weather conditions with acceptance tests |
| P2-15 | Configurable environmental parameters | — | Missing | P2 | — | — | — | Configurable environmental parameters | Implement configurable environmental parameters with acceptance tests |
| P2-16 | Civil aircraft performance models | — | Missing | P2 | — | — | — | Civil aircraft performance models | Implement civil aircraft performance models with acceptance tests |
| P2-17 | Coordinate system management | Explicit local planar units; no geodetic frame | Partial | P2 | Simulator.hpp, ARCHITECTURE.md | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P2-18 | Unit conversion | Speed conversion to m/s and knots | Partial | P2 | Simulator.cpp | speed_mps_diagonal, speed_kt_conversion | Local P0 | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P2-19 | Simulation events | — | Missing | P2 | — | — | — | Simulation events | Implement simulation events with acceptance tests |
| P2-20 | Reproducible random seeds | — | Missing | P2 | — | — | — | Reproducible random seeds | Implement reproducible random seeds with acceptance tests |

## P3

| Feature ID | Requirement | Implementation | Status | Priority | Source Files | Tests | Evidence | Remaining Gap | Next Action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P3-01 | Plan Position Indicator | Canvas renders model tracks and synthetic sweep | Implemented | P3 | RadarPpi.qml | Rendered screenshots | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P3-02 | Range rings | Four labeled rings | Implemented | P3 | RadarPpi.qml | Rendered screenshots | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P3-03 | Compass rose | Bearing spokes and numeric labels | Partial | P3 | RadarPpi.qml | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P3-04 | Zoom and pan | — | Missing | P3 | — | — | — | Zoom and pan | Implement zoom and pan with acceptance tests |
| P3-05 | Track labels | Tracks display IDs and measured values | Implemented | P3 | RadarPpi.qml | Rendered screenshots | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P3-06 | Track history | Bounded history per aircraft; PPI dots | Partial | P3 | RadarPpi.qml, SimulatorModel.cpp | pauseStopsSimulation | Local P0 | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P3-07 | Track selection | Pointer-assisted selection and model selection signals | Partial | P3 | RadarPpi.qml, SimulatorModel.cpp | selectTrackEmitsSelectedChanged | Local P0 | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P3-08 | Configurable display layers | — | Missing | P3 | — | — | — | Configurable display layers | Implement configurable display layers with acceptance tests |
| P3-09 | Synthetic track filtering | — | Missing | P3 | — | — | — | Synthetic track filtering | Implement synthetic track filtering with acceptance tests |
| P3-10 | Civil air traffic visualization | Fixed-wing and multirotor icons | Partial | P3 | RadarPpi.qml | Rendered screenshots | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P3-11 | Configurable measurement units | — | Missing | P3 | — | — | — | Configurable measurement units | Implement configurable measurement units with acceptance tests |
| P3-12 | Geographic coordinate visualization | — | Missing | P3 | — | — | — | Geographic coordinate visualization | Implement geographic coordinate visualization with acceptance tests |
| P3-13 | Display preferences | — | Missing | P3 | — | — | — | Display preferences | Implement display preferences with acceptance tests |
| P3-14 | Performance optimization | Bounded trails and linear track conversion | Partial | P3 | SimulatorModel.cpp | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P3-15 | Synthetic source label | Dashboard and PPI labels | Implemented | P3 | Main.qml, RadarPpi.qml | Rendered screenshots | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |

## P4

| Feature ID | Requirement | Implementation | Status | Priority | Source Files | Tests | Evidence | Remaining Gap | Next Action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P4-01 | 3D scene architecture | — | Missing | P4 | — | — | — | 3D scene architecture | Implement 3d scene architecture with acceptance tests |
| P4-02 | Civil aircraft models | — | Missing | P4 | — | — | — | Civil aircraft models | Implement civil aircraft models with acceptance tests |
| P4-03 | Synthetic flight paths in 3D | — | Missing | P4 | — | — | — | Synthetic flight paths in 3D | Implement synthetic flight paths in 3d with acceptance tests |
| P4-04 | Altitude visualization | — | Missing | P4 | — | — | — | Altitude visualization | Implement altitude visualization with acceptance tests |
| P4-05 | Camera controls | — | Missing | P4 | — | — | — | Camera controls | Implement camera controls with acceptance tests |
| P4-06 | Orbit camera | — | Missing | P4 | — | — | — | Orbit camera | Implement orbit camera with acceptance tests |
| P4-07 | Top view | — | Missing | P4 | — | — | — | Top view | Implement top view with acceptance tests |
| P4-08 | Perspective view | — | Missing | P4 | — | — | — | Perspective view | Implement perspective view with acceptance tests |
| P4-09 | Selected aircraft view | — | Missing | P4 | — | — | — | Selected aircraft view | Implement selected aircraft view with acceptance tests |
| P4-10 | Synthetic terrain visualization | — | Missing | P4 | — | — | — | Synthetic terrain visualization | Implement synthetic terrain visualization with acceptance tests |
| P4-11 | Configurable 3D environment | — | Missing | P4 | — | — | — | Configurable 3D environment | Implement configurable 3d environment with acceptance tests |
| P4-12 | PPI synchronization | — | Missing | P4 | — | — | — | PPI synchronization | Implement ppi synchronization with acceptance tests |
| P4-13 | Performance scaling | — | Missing | P4 | — | — | — | Performance scaling | Implement performance scaling with acceptance tests |
| P4-14 | Hardware compatibility | — | Missing | P4 | — | — | — | Hardware compatibility | Implement hardware compatibility with acceptance tests |

## P5

| Feature ID | Requirement | Implementation | Status | Priority | Source Files | Tests | Evidence | Remaining Gap | Next Action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P5-01 | Scenario editor | — | Missing | P5 | — | — | — | Scenario editor | Implement scenario editor with acceptance tests |
| P5-02 | Scenario templates | — | Missing | P5 | — | — | — | Scenario templates | Implement scenario templates with acceptance tests |
| P5-03 | Scenario library | — | Missing | P5 | — | — | — | Scenario library | Implement scenario library with acceptance tests |
| P5-04 | Scenario save/load | — | Missing | P5 | — | — | — | Scenario save/load | Implement scenario save/load with acceptance tests |
| P5-05 | Scenario import/export | — | Missing | P5 | — | — | — | Scenario import/export | Implement scenario import/export with acceptance tests |
| P5-06 | Versioned scenario format and migrations | — | Missing | P5 | — | — | — | Versioned scenario format and migrations | Implement versioned scenario format and migrations with acceptance tests |
| P5-07 | JSON Schema validation | — | Missing | P5 | — | — | — | JSON Schema validation | Implement json schema validation with acceptance tests |
| P5-08 | Simulation recording | — | Missing | P5 | — | — | — | Simulation recording | Implement simulation recording with acceptance tests |
| P5-09 | Timeline navigation | — | Missing | P5 | — | — | — | Timeline navigation | Implement timeline navigation with acceptance tests |
| P5-10 | Replay controls | — | Missing | P5 | — | — | — | Replay controls | Implement replay controls with acceptance tests |
| P5-11 | Playback speed | — | Missing | P5 | — | — | — | Playback speed | Implement playback speed with acceptance tests |
| P5-12 | Event bookmarks | — | Missing | P5 | — | — | — | Event bookmarks | Implement event bookmarks with acceptance tests |
| P5-13 | Research notes | — | Missing | P5 | — | — | — | Research notes | Implement research notes with acceptance tests |
| P5-14 | CSV and JSON export | — | Missing | P5 | — | — | — | CSV and JSON export | Implement csv and json export with acceptance tests |
| P5-15 | Scenario comparison | — | Missing | P5 | — | — | — | Scenario comparison | Implement scenario comparison with acceptance tests |

## P6

| Feature ID | Requirement | Implementation | Status | Priority | Source Files | Tests | Evidence | Remaining Gap | Next Action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P6-01 | Abstract data provider interface | — | Missing | P6 | — | — | — | Abstract data provider interface | Implement abstract data provider interface with acceptance tests |
| P6-02 | Synthetic data provider | Core output feeds the Qt desktop without a provider abstraction | Partial | P6 | SimulatorModel.cpp | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P6-03 | Recorded data provider | — | Missing | P6 | — | — | — | Recorded data provider | Implement recorded data provider with acceptance tests |
| P6-04 | Offline dataset import | — | Missing | P6 | — | — | — | Offline dataset import | Implement offline dataset import with acceptance tests |
| P6-05 | Data validation | Synthetic core validates input | Partial | P6 | Simulator.cpp | Constructor and overflow regressions | Local P0 | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P6-06 | Timestamp normalization | — | Missing | P6 | — | — | — | Timestamp normalization | Implement timestamp normalization with acceptance tests |
| P6-07 | Data provenance | — | Missing | P6 | — | — | — | Data provenance | Implement data provenance with acceptance tests |
| P6-08 | Data quality indicators | — | Missing | P6 | — | — | — | Data quality indicators | Implement data quality indicators with acceptance tests |
| P6-09 | Simulation and recorded data labels | Synthetic labels only | Partial | P6 | StatusStrip.qml, RadarPpi.qml | Rendered screenshots | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |

## P7

| Feature ID | Requirement | Implementation | Status | Priority | Source Files | Tests | Evidence | Remaining Gap | Next Action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P7-01 | Flight statistics | — | Missing | P7 | — | — | — | Flight statistics | Implement flight statistics with acceptance tests |
| P7-02 | Simulation metrics | — | Missing | P7 | — | — | — | Simulation metrics | Implement simulation metrics with acceptance tests |
| P7-03 | Speed and altitude charts | — | Missing | P7 | — | — | — | Speed and altitude charts | Implement speed and altitude charts with acceptance tests |
| P7-04 | Trajectory analysis | — | Missing | P7 | — | — | — | Trajectory analysis | Implement trajectory analysis with acceptance tests |
| P7-05 | Scenario comparison analytics | — | Missing | P7 | — | — | — | Scenario comparison analytics | Implement scenario comparison analytics with acceptance tests |
| P7-06 | Data quality reports | — | Missing | P7 | — | — | — | Data quality reports | Implement data quality reports with acceptance tests |
| P7-07 | Simulation performance reports | — | Missing | P7 | — | — | — | Simulation performance reports | Implement simulation performance reports with acceptance tests |
| P7-08 | Exportable research results | — | Missing | P7 | — | — | — | Exportable research results | Implement exportable research results with acceptance tests |
| P7-09 | Reproducibility metadata | — | Missing | P7 | — | — | — | Reproducibility metadata | Implement reproducibility metadata with acceptance tests |

## P8

| Feature ID | Requirement | Implementation | Status | Priority | Source Files | Tests | Evidence | Remaining Gap | Next Action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P8-01 | English | UI text in English; translation catalogs absent | Partial | P8 | ui/qml/ | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P8-02 | Arabic | — | Missing | P8 | — | — | — | Arabic | Implement arabic with acceptance tests |
| P8-03 | RTL and LTR | — | Missing | P8 | — | — | — | RTL and LTR | Implement rtl and ltr with acceptance tests |
| P8-04 | Qt Translation System | — | Missing | P8 | — | — | — | Qt Translation System | Implement qt translation system with acceptance tests |
| P8-05 | Localized dates and times | — | Missing | P8 | — | — | — | Localized dates and times | Implement localized dates and times with acceptance tests |
| P8-06 | UTC time display | Independent UTC wall-clock label | Implemented | P8 | Main.qml, StatusStrip.qml | Rendered screenshots | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P8-07 | Configurable units | — | Missing | P8 | — | — | — | Configurable units | Implement configurable units with acceptance tests |
| P8-08 | Kilometers and nautical miles | — | Missing | P8 | — | — | — | Kilometers and nautical miles | Implement kilometers and nautical miles with acceptance tests |
| P8-09 | Meters and feet | — | Missing | P8 | — | — | — | Meters and feet | Implement meters and feet with acceptance tests |
| P8-10 | Knots and kilometers per hour | — | Missing | P8 | — | — | — | Knots and kilometers per hour | Implement knots and kilometers per hour with acceptance tests |
| P8-11 | Localized number formatting | — | Missing | P8 | — | — | — | Localized number formatting | Implement localized number formatting with acceptance tests |

## P9

| Feature ID | Requirement | Implementation | Status | Priority | Source Files | Tests | Evidence | Remaining Gap | Next Action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P9-01 | Secure file handling | Screenshot output path required; general import/export absent | Partial | P9 | apps/desktop/main.cpp | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P9-02 | Input validation | Core and screenshot arguments validated | Partial | P9 | Simulator.cpp, apps/desktop/main.cpp | Core regressions | Local P0 | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P9-03 | Dependency auditing | Manual inventory and license review | Partial | P9 | THIRD_PARTY_ADOPTION_MATRIX.md | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P9-04 | Secure configuration storage | — | Missing | P9 | — | — | — | Secure configuration storage | Implement secure configuration storage with acceptance tests |
| P9-05 | Structured logging | — | Missing | P9 | — | — | — | Structured logging | Implement structured logging with acceptance tests |
| P9-06 | Crash handling | — | Missing | P9 | — | — | — | Crash handling | Implement crash handling with acceptance tests |
| P9-07 | Error recovery | State is preserved on step rejection; adapter pauses on overflow | Partial | P9 | Simulator.cpp, SimulatorModel.cpp | Overflow regressions | Local P0 | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P9-08 | Safe import and export | — | Missing | P9 | — | — | — | Safe import and export | Implement safe import and export with acceptance tests |
| P9-09 | Resource limits | Desktop trail length capped | Partial | P9 | SimulatorModel.hpp, SimulatorModel.cpp | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P9-10 | Memory leak detection | — | Missing | P9 | — | — | — | Memory leak detection | Implement memory leak detection with acceptance tests |
| P9-11 | Static analysis | Source hygiene and compiler diagnostics | Partial | P9 | tools/check_source_hygiene.py, CMakeLists.txt | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P9-12 | Sanitizer testing | — | Partial | P9 | SimulatorTests.cpp | GCC ASan/UBSan core suite | Local P0 | Desktop sanitizers and leak detection | Add sanitizer CI and run extended checks |
| P9-13 | Software Bill of Materials | — | Missing | P9 | — | — | — | Software Bill of Materials | Implement software bill of materials with acceptance tests |
| P9-14 | Third-party license compliance | Inventory in place; package obligations pending | Partial | P9 | THIRD_PARTY_ADOPTION_MATRIX.md | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P9-15 | Privacy protection | Application processes embedded synthetic data | Partial | P9 | SECURITY.md, ARCHITECTURE.md | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |

## P10

| Feature ID | Requirement | Implementation | Status | Priority | Source Files | Tests | Evidence | Remaining Gap | Next Action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P10-01 | Unit tests | NDEBUG-safe core checks | Implemented | P10 | tests/unit/SimulatorTests.cpp | simulator_tests | Local P0 | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P10-02 | Integration tests | Qt-to-core behavior and signals | Implemented | P10 | tests/integration/SimulatorModelTests.cpp | simulator_tests_integration | Local P0 | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P10-03 | Regression tests | Covers core, model and source hygiene regressions | Partial | P10 | tests/, tools/check_source_hygiene.py | Core and model | Local P0 | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P10-04 | QML tests | — | Missing | P10 | — | — | — | QML tests | Implement qml tests with acceptance tests |
| P10-05 | Qt model tests | QObject adapter properties and slots checked; no QML interaction coverage | Partial | P10 | tests/integration/SimulatorModelTests.cpp | simulator_tests_integration | Local P0 | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P10-06 | UI smoke tests | Offscreen app startup available through CTest | Implemented | P10 | apps/desktop/main.cpp, CMakeLists.txt | aeroradar_desktop_smoke | Local P0 | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P10-07 | Screenshot tests | CI captures two rendered sizes and checks non-empty files | Partial | P10 | .github/workflows/ci.yml | Linux screenshot step | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P10-08 | Scenario validation tests | Core aircraft validation only | Partial | P10 | tests/unit/SimulatorTests.cpp | constructor_rejects_invalid_aircraft | Local P0 | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P10-09 | Replay determinism tests | — | Missing | P10 | — | — | — | Replay determinism tests | Implement replay determinism tests with acceptance tests |
| P10-10 | Performance benchmarks | — | Missing | P10 | — | — | — | Performance benchmarks | Implement performance benchmarks with acceptance tests |
| P10-11 | Memory tests | — | Missing | P10 | — | — | — | Memory tests | Implement memory tests with acceptance tests |
| P10-12 | Long-running stability tests | — | Missing | P10 | — | — | — | Long-running stability tests | Implement long-running stability tests with acceptance tests |
| P10-13 | Windows compatibility tests | Hosted core and desktop startup on Windows Server 2022 | Partial | P10 | .github/workflows/ci.yml | Windows jobs | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P10-14 | Linux compatibility tests | Hosted CI and local Debian build for this slice | Partial | P10 | .github/workflows/ci.yml | Linux jobs and local suites | Baseline CI, Local P0 | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P10-15 | Installer tests | Silent install and startup on hosted Windows | Partial | P10 | .github/workflows/ci.yml | Windows packaging job | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P10-16 | Upgrade tests | — | Missing | P10 | — | — | — | Upgrade tests | Implement upgrade tests with acceptance tests |
| P10-17 | Uninstallation tests | Hosted Windows removal preserves unrelated files | Partial | P10 | .github/workflows/ci.yml | Windows packaging job | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P10-18 | Debug and Release checks under NDEBUG | Core macros always execute; Qt CTest job defined in each configuration | Implemented | P10 | tests/TestMacros.hpp, .github/workflows/ci.yml | Core and desktop CTest | Local P0 | Full acceptance coverage | Exercise remaining stage acceptance criteria |

## P11

| Feature ID | Requirement | Implementation | Status | Priority | Source Files | Tests | Evidence | Remaining Gap | Next Action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P11-01 | Windows x64 | Hosted Windows x64 packaging | Implemented | P11 | .github/workflows/ci.yml | Windows packaging job | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P11-02 | Portable ZIP | Candidate ZIP with app-local runtimes | Implemented | P11 | .github/workflows/ci.yml | Portable smoke | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P11-03 | Professional installer | NSIS candidate with silent installation and uninstall | Partial | P11 | installer/aeroradar.nsi | Windows packaging job | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P11-04 | Qt runtime deployment | windeployqt with QML modules and platform plugin | Implemented | P11 | .github/workflows/ci.yml | Deployed runtime smoke | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P11-05 | Visual C++ runtime deployment | App-local CRT DLLs | Implemented | P11 | .github/workflows/ci.yml | Windows packaging job | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P11-06 | Start Menu integration | NSIS shortcut declaration | Partial | P11 | installer/aeroradar.nsi | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P11-07 | Desktop shortcut | Optional NSIS component | Partial | P11 | installer/aeroradar.nsi | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P11-08 | Safe upgrade | Existing installer aborts on payload collision | Missing | P11 | installer/aeroradar.nsi | — | — | Safe upgrade | Implement safe upgrade with acceptance tests |
| P11-09 | Safe uninstallation | Payload-only removal tested on hosted runner | Partial | P11 | installer/aeroradar.nsi, .github/workflows/ci.yml | Uninstall preserves unrelated files | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P11-10 | SHA-256 checksums | CI emits sidecars; GitHub reports outer artifact digests | Implemented | P11 | .github/workflows/ci.yml | Windows packaging job | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P11-11 | Digital signing | Candidates are unsigned | Blocked | P11 | installer/aeroradar.nsi | None | Baseline inventory | Approved signing certificate | Enable signing once the certificate is available |
| P11-12 | Linux AppImage or distribution package | — | Missing | P11 | — | — | — | Linux AppImage or distribution package | Implement linux appimage or distribution package with acceptance tests |
| P11-13 | Desktop entry | — | Missing | P11 | — | — | — | Desktop entry | Implement desktop entry with acceptance tests |
| P11-14 | Application icons | — | Missing | P11 | — | — | — | Application icons | Implement application icons with acceptance tests |
| P11-15 | Linux dependency management | Build dependencies documented; runtime bundle absent | Partial | P11 | README.md, .github/workflows/ci.yml | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P11-16 | Installation documentation | Source build instructions and candidate references | Partial | P11 | README.md | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P11-17 | Semantic versioning | Starts from version 0.1.0 | Partial | P11 | CMakeLists.txt, installer/aeroradar.nsi | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P11-18 | Automated build pipeline | Core and desktop CI with package artifact upload | Implemented | P11 | .github/workflows/ci.yml | Hosted runs | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P11-19 | GitHub Actions | CI and source hygiene workflows | Implemented | P11 | .github/workflows/ | Hosted runs | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P11-20 | Release notes | — | Missing | P11 | — | — | — | Release notes | Implement release notes with acceptance tests |
| P11-21 | Changelog | — | Missing | P11 | — | — | — | Changelog | Implement changelog with acceptance tests |
| P11-22 | Build artifacts | Windows portable and setup plus Linux captures | Implemented | P11 | .github/workflows/ci.yml | Artifacts present | Baseline inventory | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P11-23 | Dependency manifest | — | Missing | P11 | — | — | — | Dependency manifest | Implement dependency manifest with acceptance tests |
| P11-24 | Release SBOM | — | Missing | P11 | — | — | — | Release SBOM | Implement release sbom with acceptance tests |
| P11-25 | Reproducible build improvements | Automated builds and independent build modes | Partial | P11 | .github/workflows/ci.yml | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P11-26 | Third-party adoption decisions | Current dependencies and candidate disposition documented | Partial | P11 | THIRD_PARTY_ADOPTION_MATRIX.md | Dependency inventory audit | Baseline inventory | Full acceptance coverage | Exercise remaining stage acceptance criteria |
