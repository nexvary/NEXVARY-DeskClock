# Feature parity

The matrix describes the working branch. Paths shortened to file basenames refer to unique tracked files. Evidence labels resolve to [the development log](DEVELOPMENT-LOG.md). Verified denotes a feature whose acceptance is covered by executed evidence. Partial denotes a subset or an outstanding acceptance check.

## P0

| Feature ID | Requirement | Implementation | Status | Priority | Source Files | Tests | Evidence | Remaining Gap | Next Action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P0-01 | Product identity | App/installer/README use product name; GitHub retains historical slug | Implemented | P0 | CMakeLists.txt, installer/aeroradar.nsi, README.md | Repository and package metadata audit | Baseline inventory | Version parity across installer and app | Derive installer metadata from project version |
| P0-02 | Branch integration | All prior development tips are ancestors of the P1 base | Partial | P0 | Git history | Ancestry and PR audit | Baseline inventory | Four upstream drafts | Integrate stack in order through reviewed PRs |
| P0-03 | C++20 and compiler compatibility | C++20 enforced; GCC, Clang and MSVC core builds passed | Verified | P0 | CMakeLists.txt, .github/workflows/ci.yml | Core Debug/Release | Hosted P0 | — | Keep the compiler matrix |
| P0-04 | Portable pi constant | Uses std::numbers::pi in core and adapter | Verified | P0 | Simulator.cpp, SimulatorModel.cpp | Bearing cases; desktop build | Local P0 | Cross-platform adapter build | Confirm CI |
| P0-05 | Integer overflow | Checked uint64 step counter and tick-based clock formatting | Partial | P0 | Simulator.cpp, SimulatorModel.cpp | Clock display regression | Local P0 | Counter exhaustion and long-run checks | Exercise clock limits with fixed-clock tests |
| P0-06 | Floating-point overflow | Rejects unrepresentable position, range and elapsed time before mutation | Verified | P0 | Simulator.cpp | step_rejects_elapsed_overflow_atomically, step_rejects_range_overflow_atomically | Local P0 | Wider scenario domains | Maintain invariant at future boundaries |
| P0-07 | Input validation | Validates finite state, duration, unique IDs and aircraft enum | Verified | P0 | Simulator.cpp | constructor_rejects_invalid_aircraft, step_inf_throws, step_nan_throws | Hosted P0, Local P2 | — | Apply validation at each new import boundary |
| P0-08 | Memory and exception safety | Allocation-free reset, failure atomicity and RAII | Partial | P0 | Simulator.cpp, SimulatorModel.cpp | Reset, overflow and core ASan/UBSan | Local P0 | Desktop leak and stress profiling | Add extended sanitizer gates |
| P0-09 | Thread safety | Single-owner core and GUI-affinity adapter | Partial | P0 | SimulatorModel.hpp, ARCHITECTURE.md | Model tests | Baseline CI, Local P0 | Concurrent provider design | Define snapshot transfer before introducing worker threads |
| P0-10 | Timer and QML update performance | Stopped paused timer and linear trail conversion | Partial | P0 | SimulatorModel.cpp | pauseStopsSimulation | Local P0 | Frame and tick benchmarks | Measure representative track counts |
| P0-11 | Paused simulation refresh | Paused timer sleeps and emits no unsolicited simulation updates | Verified | P0 | SimulatorModel.cpp | pauseStopsSimulation, resumeRestoresSimulation | Local P0 | Changed revision hosted runs | Confirm Qt matrix |
| P0-12 | License and IP review | Repository and runtime inventory reviewed | Partial | P0 | THIRD_PARTY_ADOPTION_MATRIX.md | Tracked files and workflow audit | Baseline inventory | Source license grant and runtime notices | Resolve publication and redistribution terms |
| P0-13 | README accuracy | Describes repository identity, current UI and historical package evidence | Implemented | P0 | README.md | Cross-check repository inventory | Baseline inventory | Refresh with future evidence | Review on each delivery |
| P0-14 | Regression suite | NDEBUG-safe core and Qt regressions | Partial | P0 | tests/, CMakeLists.txt | Core, model, smoke | Local P0, Hosted P0 | Further scenario, packaging and stability cases | Add tests with each stage |

## P1

| Feature ID | Requirement | Implementation | Status | Priority | Source Files | Tests | Evidence | Remaining Gap | Next Action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P1-01 | NEXVARY design system | Shared NEXVARY palette and typography with light and dark variants | Partial | P1 | AeroTheme.qml, ui/qml/ | Dashboard appearance regression and rendered captures | Local P1 | Full visual and accessibility acceptance | Review high-DPI and multiple displays |
| P1-02 | Reusable QML components | PPI, header, instrument, controls, track list, info and appearance components | Implemented | P1 | ui/qml/, CMakeLists.txt | Dashboard interaction and startup | Local P1 | Further workspace extraction as functionality grows | Keep new workspace dependencies explicit |
| P1-03 | Design tokens | Shared surface, text, status, scope and trail colors | Implemented | P1 | AeroTheme.qml, RadarPpi.qml | Dashboard appearance regression and captures | Local P1 | Complete spacing and typography token coverage | Consolidate further values when extending workspace layouts |
| P1-04 | Typography system | Theme font family and per-view sizes | Partial | P1 | AeroTheme.qml, ui/qml/ | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P1-05 | Iconography | PPI geometry symbols | Partial | P1 | RadarPpi.qml | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P1-06 | Dark mode | Dark palette used by default and selectable via Settings | Verified | P1 | AeroTheme.qml, AppearanceSettings.qml | appearancePersistsAcrossWindows and dark captures | Local P1 | — | Retain coverage |
| P1-07 | Light mode | Shared light palette, persisted choice, immediate PPI redraw | Verified | P1 | AeroTheme.qml, AppearanceSettings.qml, RadarPpi.qml | appearancePersistsAcrossWindows and light capture | Local P1 | — | Retain coverage |
| P1-08 | Responsive desktop layout | Layout renders at 1440×900 and 1200×760 | Partial | P1 | Main.qml | Rendered size checks | Local P1 | High-DPI and multi-display testing | Exercise supported scaling factors and monitor transitions |
| P1-09 | High-DPI support | Qt Quick layout using logical dimensions | Partial | P1 | Main.qml | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P1-10 | Accessibility | Accessible Qt buttons with descriptive names and visible keyboard focus | Partial | P1 | Main.qml, SimulationControls.qml, TrackList.qml | Dashboard keyboard interaction | Local P1 | Assistive technology and UI scale coverage | Test screen-reader and scaling behavior |
| P1-11 | Keyboard navigation | Tab and Space navigate and operate the workspace, track list and playback controls | Verified | P1 | Main.qml, TrackList.qml, SimulationControls.qml | controlsAndWorkspaces | Local P1 | — | Keep focus regressions in CTest |
| P1-12 | Multiple displays | — | Missing | P1 | — | — | — | Multiple displays | Implement multiple displays with acceptance tests |
| P1-13 | Overview workspace | Shows live state from the built-in synthetic simulation and its documented model | Implemented | P1 | Main.qml, WorkspaceInfo.qml | Dashboard startup | Local P1 | Additional scenario summaries after P2/P5 | Expose validated scenario metadata |
| P1-14 | Flight simulation workspace | PPI and instrument telemetry with interactive playback and selection | Implemented | P1 | Main.qml, SimulationControls.qml, FlightInstruments.qml | controlsAndWorkspaces | Local P1 | Configurable scenarios and time scale | Integrate P2 controls |
| P1-15 | Radar PPI workspace | Dedicated radar workspace with model-backed PPI | Verified | P1 | Main.qml, RadarPpi.qml | controlsAndWorkspaces and rendered captures | Local P1 | — | Keep navigation coverage while extending P3 |
| P1-16 | Air traffic visualization workspace | Dedicated air traffic workspace displays track selection, local coordinates and instruments | Verified | P1 | Main.qml, TrackList.qml, FlightInstruments.qml | controlsAndWorkspaces | Local P1 | — | Extend traffic data as P6 providers become available |
| P1-17 | Scenario management workspace | Workspace opens, edits, applies and saves versioned v1/v2 synthetic scenarios | Partial | P1 | ScenarioWorkspace.qml, SimulatorModel.cpp | Dashboard and scenario integration tests | Local P5 editor | Scenario library and templates UI | Add library navigation and template selection |
| P1-18 | Replay workspace | — | Missing | P1 | — | — | — | Replay workspace | Implement replay workspace with acceptance tests |
| P1-19 | Research workspace | — | Missing | P1 | — | — | — | Research workspace | Implement research workspace with acceptance tests |
| P1-20 | System settings workspace | Persistent light/dark selector in the settings workspace | Partial | P1 | AppearanceSettings.qml, AeroTheme.qml | appearancePersistsAcrossWindows | Local P1 | Display units and localization settings | Add P3 and P8 preferences |
| P1-21 | Diagnostics workspace | Shows app version, platform, source type, elapsed simulation time and UTC | Partial | P1 | Main.qml, WorkspaceInfo.qml | Dashboard startup | Local P1 | Structured logs and resource diagnostics | Integrate P9 diagnostics |
| P1-22 | Help and documentation workspace | In-app help for controls, tracking, units and limitations | Implemented | P1 | Main.qml, WorkspaceInfo.qml | Dashboard startup | Local P1 | Full research workflow documentation | Extend alongside workspaces |

## P2

| Feature ID | Requirement | Implementation | Status | Priority | Source Files | Tests | Evidence | Remaining Gap | Next Action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P2-01 | Deterministic simulation | Built-in scenario repeats exactly within one build for the same step sequence | Partial | P2 | BuiltinScenario.cpp, Simulator.cpp | builtin_is_repeatable_with_manual_steps | Local P2 | Repeatable external scenarios and cross-platform comparison tolerance | Add versioned fixtures and reproducibility metadata |
| P2-02 | Fixed-timestep simulation | Automatic and manual desktop ticks each advance the same 100 ms | Verified | P2 | SimulatorModel.cpp, Simulator.cpp | manualStepKeepsPauseAndFixedDelta, builtin_is_repeatable_with_manual_steps | Local P2 | — | Retain fixed-tick regressions |
| P2-03 | Simulation clock | Desktop elapsed seconds and display derive from the integer tick counter | Verified | P2 | SimulatorModel.cpp | clockDisplayUsesFixedTicks, manualStepKeepsPauseAndFixedDelta | Local P2 | — | Retain clock tests |
| P2-04 | Configurable time scale | QML speed selector changes wall pacing across 0.25×, 0.5×, 1×, 2× and 4× | Verified | P2 | SimulatorModel.cpp, SimulationControls.qml | timeScaleRejectsInvalidRatesAndPreservesState, controlsAndWorkspaces | Local P2 | — | Retain speed selection regressions |
| P2-05 | Pause / resume / reset | Core transitions and desktop controls preserve pause state across reset | Verified | P2 | Simulator.cpp, SimulatorModel.cpp, SimulationControls.qml | Model and dashboard integration suites | Local P2 | — | Retain control regressions |
| P2-06 | Step-by-step simulation | Manual step advances one tick while paused and records trail and selection data | Verified | P2 | Simulator.cpp, SimulatorModel.cpp, SimulationControls.qml | manual_step_rejects_invalid_duration, manualStepKeepsPauseAndFixedDelta, controlsAndWorkspaces | Local P2 | — | Exercise manual stepping with imported scenarios |
| P2-07 | Scenario loading | Load v1/v2 local synthetic JSON into a fresh paused simulation | Verified | P2 | ScenarioLoader.cpp, ScenarioWorkspace.qml, SimulatorModel.cpp | loadsScenarioAndResetsItsOwnInitialState, loadsTimedRouteAndClimbs | Local P2 scenarios, Local P2 waypoints | — | Retain both format compatibility fixtures |
| P2-08 | Scenario editing | Draft JSON editor with shared validation and explicit apply | Verified | P2 | ScenarioWorkspace.qml, ScenarioLoader.cpp, SimulatorModel.cpp | editsAndSavesValidatedDraftWithoutReplacingActiveState, controlsAndWorkspaces | Local P5 editor | — | Extend the editor with structured route controls |
| P2-09 | Scenario validation | Validates file and track limits, record types, identifiers, increasing route times and speed | Verified | P2 | ScenarioLoader.cpp, Simulator.cpp | rejectsInvalidScenario, invalid_routes_are_rejected | Local P2 waypoints | — | Extend validation for future scenario versions |
| P2-10 | Synthetic aircraft generation | Three fixed civilian synthetic aircraft supplied by the core built-in scenario | Partial | P2 | BuiltinScenario.cpp | builtin_is_repeatable_with_manual_steps | Local P2 | Seeded generation and scenario-defined traffic | Add seeded generation under a versioned scenario contract |
| P2-11 | Civil flight paths | Straight-line motion and timed local planar flight legs | Verified | P2 | Simulator.cpp, ScenarioLoader.cpp | waypoints_interpolate_time_position_and_altitude | Local P2 waypoints | — | Add civil performance validation when adopting a dynamics model |
| P2-12 | Configurable waypoints | Optional v2 timed sequence of local waypoint coordinates | Verified | P2 | Simulator.cpp, ScenarioLoader.cpp, scenario-v2.schema.json | invalid_routes_are_rejected, loadsTimedRouteAndClimbs | Local P2 waypoints | — | Expose the existing contract in the scenario editor |
| P2-13 | Altitude profiles | Linearly interpolated altitude on timed routes and fixed altitude without a route | Verified | P2 | Simulator.cpp, SimulatorModel.cpp, civil-waypoints.json | waypoints_interpolate_time_position_and_altitude, loadsTimedRouteAndClimbs | Local P2 waypoints | — | Retain climb and reset fixtures |
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
| P3-02 | Range rings | Four concentric range rings labeled for the active radar scale | Implemented | P3 | RadarPpi.qml | Rendered captures and radar interaction | Baseline CI, Local P3 | Calibrated rendering assertions | Add projection screenshot fixtures |
| P3-03 | Compass rose | Bearing spokes and numeric labels | Partial | P3 | RadarPpi.qml | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P3-04 | Zoom and pan | Eight bounded zoom levels, wheel and buttons, drag pan, and recenter | Verified | P3 | RadarPpi.qml | radarNavigationAndFiltering | Local P3 | — | Retain projection and input regression coverage |
| P3-05 | Track labels | Track identity and telemetry labels with an on-screen toggle | Implemented | P3 | RadarPpi.qml | radarNavigationAndFiltering | Local P3 | Captured layout with dense traffic | Add dense synthetic scenario captures |
| P3-06 | Track history | Bounded trail history and independently toggled radar overlay | Partial | P3 | RadarPpi.qml, SimulatorModel.cpp | pauseStopsSimulation, radarNavigationAndFiltering | Local P0, Local P3 | History length preference and performance checks | Benchmark dense scenes and expose settings |
| P3-07 | Track selection | Click uses the same projection and filter as rendering after pan and zoom | Verified | P3 | RadarPpi.qml, SimulatorModel.cpp | radarNavigationAndFiltering | Local P3 | — | Retain click hit-test coverage |
| P3-08 | Configurable display layers | Labels and history switched independently | Partial | P3 | RadarPpi.qml | radarNavigationAndFiltering | Local P3 | Additional layers and persistent preferences | Extend the settings contract |
| P3-09 | Synthetic track filtering | Type filter applies to Canvas painting and mouse selection | Verified | P3 | RadarPpi.qml | radarNavigationAndFiltering | Local P3 | — | Retain hidden-track selection regression |
| P3-10 | Civil air traffic visualization | Fixed-wing and multirotor icons | Partial | P3 | RadarPpi.qml | Rendered screenshots | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P3-11 | Configurable measurement units | — | Missing | P3 | — | — | — | Configurable measurement units | Implement configurable measurement units with acceptance tests |
| P3-12 | Geographic coordinate visualization | — | Missing | P3 | — | — | — | Geographic coordinate visualization | Implement geographic coordinate visualization with acceptance tests |
| P3-13 | Display preferences | — | Missing | P3 | — | — | — | Display preferences | Implement display preferences with acceptance tests |
| P3-14 | Performance optimization | Radar caches the model snapshot between simulation updates and skips hidden/paused animation | Partial | P3 | RadarPpi.qml, SimulatorModel.cpp | Paused timer and dashboard interaction | Local P0, Local P3 | Measured frame and update performance | Benchmark rendering with 256 tracks and bounded trails |
| P3-15 | Synthetic source label | Dashboard and PPI labels | Implemented | P3 | Main.qml, RadarPpi.qml | Rendered screenshots | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |

## P4

| Feature ID | Requirement | Implementation | Status | Priority | Source Files | Tests | Evidence | Remaining Gap | Next Action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P4-01 | 3D scene architecture | Qt Quick 3D evaluated as the required renderer | Blocked | P4 | THIRD_PARTY_ADOPTION_MATRIX.md | — | Official Qt licensing review | Approved commercial or compatible GPLv3 distribution route | Select and document the licensing route before adoption |
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
| P5-01 | Scenario editor | Built-in JSON draft editor for both scenario versions | Verified | P5 | ScenarioWorkspace.qml, SimulatorModel.cpp | Dashboard and scenario integration tests | Local P5 editor | — | Add structured controls and validation detail as the contract grows |
| P5-02 | Scenario templates | Documented two-aircraft v1 and routed v2 example scenarios | Partial | P5 | docs/scenarios/ | Schema and model case validation | Local P2 waypoints | Scenario template library | Add representative templates for the supported scenario types |
| P5-03 | Scenario library | — | Missing | P5 | — | — | — | Scenario library | Implement scenario library with acceptance tests |
| P5-04 | Scenario save/load | Shared validation and atomic local save/load for v1/v2 | Verified | P5 | ScenarioLoader.cpp, ScenarioWorkspace.qml | editsAndSavesValidatedDraftWithoutReplacingActiveState | Local P5 editor | — | Retain versioned save/load regressions |
| P5-05 | Scenario import/export | Import and export of validated local v1/v2 JSON drafts | Verified | P5 | ScenarioLoader.cpp, ScenarioWorkspace.qml | v1 and v2 round-trip coverage | Local P5 editor | — | Retain invalid save destination and content checks |
| P5-06 | Versioned scenario format and migrations | v1 and v2 schemas with backward-compatible loading | Partial | P5 | docs/scenarios/, ScenarioLoader.cpp | Both example inputs and version rejection | Local P2 waypoints | Persisted migration and save fixtures | Implement save with round-trip migration tests |
| P5-07 | JSON Schema validation | Draft 2020-12 schemas and native checks for v1/v2 | Partial | P5 | docs/scenarios/, ScenarioLoader.cpp | Python schema validation and CTest input regressions | Local P2 waypoints | Hosted schema consistency gate | Add schema consistency checks to CI |
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
| P9-01 | Secure file handling | Bounded local read, validate-before-write, atomic commit and plain-text UI | Partial | P9 | ScenarioLoader.cpp, ScenarioWorkspace.qml | Scenario load/save and dashboard tests | Local P5 editor | File handling for future datasets and replay | Extend safe file support to each new format |
| P9-02 | Input validation | Core and screenshot arguments validated | Partial | P9 | Simulator.cpp, apps/desktop/main.cpp | Core regressions | Local P0 | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P9-03 | Dependency auditing | Manual inventory and license review | Partial | P9 | THIRD_PARTY_ADOPTION_MATRIX.md | — | — | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P9-04 | Secure configuration storage | — | Missing | P9 | — | — | — | Secure configuration storage | Implement secure configuration storage with acceptance tests |
| P9-05 | Structured logging | — | Missing | P9 | — | — | — | Structured logging | Implement structured logging with acceptance tests |
| P9-06 | Crash handling | — | Missing | P9 | — | — | — | Crash handling | Implement crash handling with acceptance tests |
| P9-07 | Error recovery | State is preserved on step rejection; adapter pauses on overflow | Partial | P9 | Simulator.cpp, SimulatorModel.cpp | Overflow regressions | Local P0 | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P9-08 | Safe import and export | Safe synthetic scenario JSON import/export | Partial | P9 | ScenarioLoader.cpp | Invalid draft preserves previous file and active state | Local P5 editor | Recorded data, CSV and future orders of magnitude | Extend resource limits and save tests to additional formats |
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
| P10-04 | QML tests | QTest drives the actual QML window with keyboard and mouse | Partial | P10 | DashboardTests.cpp, CMakeLists.txt | aeroradar_dashboard_tests | Local P1, Local P2 | Additional workspace and accessibility flows | Add tests with each workspace |
| P10-05 | Qt model tests | QObject adapter properties and slots checked; no QML interaction coverage | Partial | P10 | tests/integration/SimulatorModelTests.cpp | simulator_tests_integration | Local P0 | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P10-06 | UI smoke tests | Offscreen app startup available through CTest | Implemented | P10 | apps/desktop/main.cpp, CMakeLists.txt | aeroradar_desktop_smoke | Local P0 | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P10-07 | Screenshot tests | CI captures two rendered sizes and checks non-empty files | Partial | P10 | .github/workflows/ci.yml | Linux screenshot step | Baseline CI | Full acceptance coverage | Exercise remaining stage acceptance criteria |
| P10-08 | Scenario validation tests | Positive and negative input fixtures for both formats and timed routes | Partial | P10 | SimulatorTests.cpp, SimulatorModelTests.cpp, docs/scenarios/ | Core and Qt scenario tests | Local P2 waypoints | Validation for future versions | Expand fixtures when schema versions change |
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
