# NEXVARY AeroRadar / DeskClock — Engineering Master Brief
**Owner:** Nexvary Inc. | **Platform:** Windows 10/11 x64 first; Linux validation second | **Date:** 2026-11-22  
**Coordination:** https://github.com/nexvary/NEXVARY-DeskClock/issues/2  
**Development PR:** https://github.com/nexvary/NEXVARY-DeskClock/pull/1  
**Visual specification:** NEXVARY AeroRadar concept dashboard image supplied by the owner separately. It is a **design reference**, NOT a screenshot of working functionality.

## 0. Nonnegotiable instructions
You are Claude acting as principal C++/Qt6 aviation simulation engineer, software architect, UX lead, quality/security reviewer and GitHub release engineer. Continue the **existing** repository; do NOT replace it, rename the public repository, rewrite unrelated Nexvary applications, or claim capabilities without evidence. Owner makes final product/merge decisions; perform safe implementation autonomously and use issue #2 to ask technical questions and post progress.

Existing code on branch \`feature/aeroradar-foundation\` (PR #1): C++20 library \`aeroradar_core\`, a two-dimensional constant-velocity planar toy simulator, CLI, 3 static QML PPI points, one simplistic CTest based on C \`assert\`, Windows/Ubuntu CI for core only. CMake desktop option \`AERORADAR_BUILD_DESKTOP\` currently defaults OFF. Existing green CI **does not** demonstrate working desktop UI, sensor fusion, physics, 3D, SITL or live tracking. Main has only bootstrap README. Inspect current state yourself; this note is a dated baseline, not a substitute for checking newer commits.

## 1. Three privately owned reuse sources (read-only source repositories)
1. \`nexvary/NEXVARY-Avionics-Lab\` — C++20/Qt6/QML: \`qml/ProfessionalRadarScope.qml\`, \`ReplayPage.qml\`, \`AttitudeIndicator.qml\`, \`DigitalTwinPage.qml\`, \`AircraftSchematic.qml\`, \`CommonAirPicturePage.qml\`, \`FlightTrackingPage.qml\`; \`src/core/TelemetryRecorder.*\`, \`TelemetryArchive.*\`, \`SensorBus.*\`, \`EventLog.*\`, \`src/air_ops/AirOperationsIntegration.*\`. Check QML dependencies and associated tests. Prior CodeQL run failed; failure cause not verified. Do not assume inherited code is secure.
2. \`nexvary/NEXVARY-Aviation-Navigator\` — Kotlin Android: \`domain/AircraftTrack.kt\`, \`data/TrafficRepository.kt\`, \`AdsbLolProvider.kt\`, \`OpenSkyProvider.kt\`, \`AircraftMapLayer.kt\`. Use data-contract ideas, provider quality rules and display principles; rewrite/adapt into clean C++ rather than embedding Android code.
3. \`nexvary/Aegis-CUAS-Command\` — C#/.NET: \`Simulation/AirspaceSimulator.cs\`, \`Tracking/TrackFusionEngine.cs\`, \`Sensors/SensorAdapterContracts.cs\`, \`Playback/*\`, \`Integration/AirOperationsExchange.cs\`, \`Geofencing/*\`, \`EoIr/RecordedEoIrPlaybackAdapter.cs\`. Its simulator emits synthetic tracks and pseudo-observations: not validated 6DoF flight physics. Reuse concepts and independently implement/test in C++; do not copy C# mechanically.

Aegis/Avionics have documented versioned awareness interchange contract \`nexvary.air-operations.exchange/v1\` supporting \`simulation-replay\` and \`awareness-only\`; preserve wire compatibility via published schemas/contract fixtures and tests, not loose handwritten assumptions. Exchanges are read-only with **no** reverse aircraft commands.

**PUBLIC SOURCE BOUNDARY**: these three sources are private; DeskClock is PUBLIC. Treat all inherited private source as internal proprietary until owner explicitly confirms release of specific code. Never commit private files, proprietary designs, datasets or third-party restricted material to public DeskClock merely because all four repos have the same owner. Prepare an adoption inventory and ask the owner once if the release decision is needed. You may independently implement interoperable public contracts without copying private implementation.

## 2. Verified open-source engineering references (study exact version and license)
- JSBSim: https://github.com/JSBSim-Team/jsbsim — flight dynamics (6DoF), C++, **LGPL 2.1**, not MIT. Assess architecture, dynamic-link/distribution obligations, fidelity and whether it fits fixed-wing and multirotor profiles; no fake validation.
- Project AirSim: https://github.com/iamaisim/ProjectAirSim — extensible simulations, headless engine / optional 3D and sensors, MIT for core; subcomponents/assets have separate notices/licenses.
- Gazebo Sim: https://github.com/gazebosim/gz-sim — simulation worlds, physics and sensors; Apache 2.0; Windows installation may be complex: isolate adapter as optional, never force a large engine into the minimal installer.
- PX4: https://github.com/PX4/PX4-Autopilot — BSD-3-Clause; use as separately run SITL interop test target, not embedded in the initial AeroRadar build.
- ArduPilot: https://github.com/ArduPilot/ardupilot — GPL-3.0-or-later; interact externally through defined SITL/JSON/UDP protocols; do not blindly embed GPL code in proprietary application. JSON simulation docs: https://github.com/ArduPilot/ardupilot/blob/master/libraries/SITL/examples/JSON/readme.md.
- MAVLink: https://mavlink.io/en/ — message definition XML and generated C headers MIT; generator tools have different licenses. MAVSDK C++: https://github.com/mavlink/MAVSDK — BSD-3-Clause; favor library for data interface only if scope and dependencies justified.
- BlueSky: https://github.com/TUDelft-CNS-ATM/bluesky — MIT air traffic simulator; reference for reproducible multi-aircraft scenarios, conflict display, air-traffic research, not a certified ATC engine.
- QGroundControl: https://github.com/mavlink/qgroundcontrol — Apache-2.0 OR GPLv3; valuable ground-station UI/telemetry inspiration; ensure correct chosen licensing route and transitive deps.
- FlightGear: https://github.com/FlightGear/flightgear — GPL; functional inspiration only unless compliance approved.
- Older Microsoft AirSim: https://github.com/microsoft/AirSim — MIT; compare its legacy architecture against maintained Project AirSim; don't uncritically choose abandoned approaches.
- Qt licenses: https://www.qt.io/development/qt-framework/qt-licensing — commercial or LGPL/GPL conditions vary by Qt module, static/dynamic link and deployment. Verify.
- Flight-feed licenses: treat OpenSky especially as restricted for commercial or operational use; don't bundle public API data as though it is freely redistributable. Every map tile, model, sound, font and icon requires a per-asset license review.

Create \`docs/THIRD_PARTY_ADOPTION_MATRIX.md\`: URL, upstream SHA/tag, author, license SPDX, chosen action (reference / external process / linked dependency / reimplement), dependency tree, attribution, commercial distribution consequences, Windows build, owner approval status. No code or asset copying without green license gate.

## 3. Architecture and language
C++20, CMake (minimum existing v3.22), Qt6/QML Quick/Quick Controls for GUI, Qt Quick 3D optional; tests via Catch2 or GoogleTest or an explicit custom check macro **not eliminated by NDEBUG**; package on Windows and test Linux. No Qt dependency in the core library.

Suggested modules:
- \`core/domain\`: Track, Observation, AircraftState, VehicleProfile, SensorReading, Scenario, Provenance; explicit units.
- \`core/time\`: injectable deterministic fixed-step monotonic simulation clock and UTC conversion.
- \`core/flight_sim\`: \`IFlightDynamicsBackend\`, basic kinematic track generator, validated multirotor dynamics backend, optional JSBSim fixed-wing adapter; never mix tracking extrapolation with genuine flight physics.
- \`core/world\`: WGS84 reference, local ENU/NED coordinate transforms, Earth curvature where appropriate; wind/weather layers and scenario boundaries.
- \`core/sensors\`: configurable synthetic GNSS/GPS, IMU, barometer, magnetometer, altimeter, Remote-ID-like/Radar-like observations explicitly marked simulated. Seeded noise and latency; no claim of actual hardware measurements.
- \`core/tracking\`: immutable provenance-aware observations, track association, stale/unknown source indication, uncertainty; no false "verified" classifications.
- \`core/scenario\`: versioned JSON schema, reproducible random seed, fixtures, reset, pause/resume, acceleration and step controls, deterministic serialization/replay.
- \`core/airspace\`: informative geofence layers, WGS84 latitude/longitude validation, timestamps, read-only licensed provider adapters; not an operational ATC decision engine.
- \`core/interop\`: awareness exchange v1 compatibility; separate MAVLink receiver / SITL interop adapter. Explicit local-only mode, separate network activation.
- \`apps/desktop\`: Qt UI, responsive QML components, telemetry charts, radar PPI, synthetic 3D viewport; driven by typed C++ models and signals rather than QML hardcoded arrays.
- \`apps/cli\`: headless scenarios, benchmark, deterministic test or export utility.
- \`tests\`: unit, integration, regression, GUI smoke, schema/golden replay, packaging tests.
- \`docs\`: architecture decisions (ADRs), safety and validation limits, user manual, license attribution, handoff.

Prefer contracts such as:
\`IFlightDynamicsBackend::initialize(profile, initialState)\`, \`step(dtSeconds, environment, controls)\`, \`state()\`; \`ITrackSource::poll(simTime)\`; \`IScenarioStore::save/load\`; \`IReplayEngine::seek/play/pause\`. These are sketches to refine after studying actual source.

### Required data fields / integrity rules
Every displayed target: \`track_id\`, \`source_type\` (SIMULATION / REPLAY / LIVE_AUTHORIZED), \`source_id\`, \`observed_at_utc\` ISO8601, \`lat_deg\`, \`lon_deg\`, \`altitude_m\` with reference (MSL/AGL/ellipsoid explicitly), \`groundspeed_mps\`, \`vertical_speed_mps\`, \`heading_deg\`, \`classification\`, \`confidence\` and/or uncertainty, \`synthetic=true/false\`, \`scenario_id\` and version, plus per-reading provenance. Store a canonical model in SI units; convert to knots/feet only in UI. Reject NaN/infinite states and invalid coordinates. Never show a zero altitude or position for missing values. Generate UTC clock from a single controlled time service; deterministic run ID/seed.

### FlightSim safety and physics
- Distinguish three levels visibly: A) kinematic synthetic tracks, B) physics simulation, C) SITL autopilot interactions. Provide separate labels and fidelity metadata.
- Fixed-step integrator (e.g., dt=0.01s for physics when justified), separate rendering at 30–60fps; simulation clock is independent of frame rate. Strong typing or audited conversions for seconds, metres, m/s, radians and degrees.
- Proper 6DoF formulation only when implemented/validated. Models for thrust, drag, moments, inertia and wind must be documented with assumptions and tests, rather than an "advanced" label. Multirotor and fixed-wing need separate model profiles.
- Scenario replay must be deterministic within documented tolerances. For external input use captured fixtures; live feed is not deterministic by definition.
- Sensor noise / dropout / latency injection and test scenarios: nominal, crosswind, sudden wind change, sensor loss, stale input, low battery in simulated model, invalid data, multiple targets and time-scaling. These are information/training functions only.
- Never expose active jamming, spoofing, interception, flight-control of real aircraft, weapon functions, or any unverified "certified" operational promise.

## 4. UX visual reference: NEXVARY AeroRadar command cockpit
The attached owner-approved concept artwork is a design target, not proof of functioning UI. Use premium deep glossy black / dark navy with metallic silver frames; cyan flight trails, emerald synthetic status, amber caution, occasional red fault; professional vector icons, not emoji/stock people. Arabic RTL/English toggle, Kufi-compatible fonts, high information density without unreadable microtext, responsive 1366×768/1920×1080/2560×1440, keyboard accessibility, clear focus and high-contrast labels. No giant empty areas.

Desktop layout:
- Header: company mark + NEXVARY AeroRadar, mission label "CIVIL AVIATION RESEARCH · SIMULATION LAB", giant "SIMULATION ONLY — NO LIVE DATA" status.
- Left navigation: Overview / FlightSim / Radar PPI / Air Traffic / Sensors / Replay / Research / System.
- Top KPIs: simulated track count, scenario ID, UTC simulation clock, elapsed, synthetic weather, environment, running/paused.
- Main workspace two large side-by-side functional visualizations: **dynamic PPI radar** with rings/bearings, tracks, provenance, select/zoom, source legend; and a **3D synthetic flight scene** (only if working renderer exists), vehicle models/waypoints/path/camera. Before a 3D renderer exists, honest placeholder or 2D schematic rather than screenshot deception.
- Right rail: health of simulated sensor feeds, scenario controls, routes/waypoints, sim clock, units.
- Middle instruments: attitude indicator, heading/compass, altitude tape, VS plot, airspeed, selected-track metadata.
- Bottom: timeline with scrub/play/pause/step/0.25×–4× and telemetry multi-series plot.
- Per-state transitions and truthful labels: "SIMULATED", "REPLAY", "LIVE AUTHORIZED" distinct shapes/legends; never silently merge fake with real.
- Accessibility: tooltips, explicit unit strings, legends, reduced-motion toggle, UI tests, RTL layout validation.
Build reusable QML components from Avionics Lab **only after** internal code/public release review; isolate their dependencies and add screenshot regression tests. Do not blindly copy QML pages requiring a global \`cockpit\` object into the new Qt shell.

## 5. Development order / PR boundaries
**P0 audit + fix current baseline** (separate PR):
1. Capture exact HEAD/branch and PR state; inventory repos including CI/log failures.
2. Replace \`assert\` tests with robust framework; run Release and Debug CTest on Windows/Linux.
3. Add Qt desktop build to matrix, QML load smoke test, screenshots from real app, and artifacts. Avoid claiming run on physical Windows if CI-only.
4. Wire at least 3 genuinely moving synthetic targets from C++ core into QML via model/signal; visual track positions update deterministically; time controls pause/reset.
5. Update documentation to state working vs mock.

**P1 consolidate architecture + read-only interoperability**:
- ADRs and schema/contract tests, provenance data, user-controlled unit display and UTC, safe deserialization and strict enum validations.
- Review all 3 private repos and create reuse map, dependency and license checks. Decision gate before source copies into PUBLIC DeskClock.
- Implement separately \`nexvary.air-operations.exchange/v1\` read-only compatibility with recorded fixtures.

**P2 FlightSim v0.1 operational offline demonstrator**:
- Deterministic multi-aircraft kinematic scenarios + save/load/replay + measured CPU/RAM.
- Configurable aircraft profiles with level of fidelity labels; geodesy tests, controllable sim clock, scenario editor.
- Radar PPI and synthetic sensor health wired to data sources; no dummy non-functional controls.

**P3 physically grounded simulator**:
- Compare JSBSim vs optional custom multirotor model vs optional Project AirSim/Gazebo; create benchmark/compatibility/authoring cost matrix and Architecture Decision Record.
- Implement chosen validated physics backend (document 6DoF math & units), drift/wind/flight envelope, synthetic sensor models and failure injection; compare deterministic invariants to independent trusted baselines.
- Optional 3D rendering with Qt Quick 3D or separately launched engine; keep minimum installer light. No hidden downloads.

**P4 SITL + external scenarios (optional)**:
- PX4 first, ArduPilot external JSON/UDP after licensing review, MAVLink read-only telemetry to AeroRadar, separate loopback-bound adapter and clear consent to open network interfaces.
- BlueSky reference for multiple-aircraft airspace research, scenario files, collision proximity visualization as **research indication, not safety authority**.

**P5 QA/security/release**:
- Qt deployment \`windeployqt\`/installer, no portable-only release when installer needed, x64, self-contained runtime and Qt license notices.
- CMake presets, pinned dependencies/lockfiles, MSVC+Clang/GCC warnings, compiler analysis, CodeQL, sanitizers where supported, SBOM and THIRD_PARTY_NOTICES, CodeQL review.
- Tests for frame-rate-independent stepping, determinism, invalid time, nonfinite state, geographic wrap, stale feeds, network opt-in, malicious/corrupt scenario file, source confusion, huge target count, multi-window resizing, Arabic RTL, accessibility; use a test matrix with passed/failed/not-tested statuses.
- GitHub Actions publish versioned screenshot, test reports, installer artifact and SHA256; only call build releasable after Windows launch + verified installer validation.

## 6. Strict execution / GitHub communications
- Public repo \`nexvary/NEXVARY-DeskClock\`. Do not rename. Work in new scoped branches and DRAFT PRs against correct base. Do not merge/release without owner authorization.
- Official discussion at **https://github.com/nexvary/NEXVARY-DeskClock/issues/2**. Post summaries using \`[CLAUDE] IMPLEMENTATION REPORT\` / \`[CLAUDE → CHATGPT] REVIEW REQUEST\`; include UTC timestamp, branch, commit/PR/CI links, exact modified files, actual screenshots, tests passed/failing, blockers and security/license risks. Do NOT claim automatic live chat with ChatGPT. When the owner invokes ChatGPT, it can read and post comments through its authenticated GitHub connector.
- Do NOT divulge private source material, license-incompatible code, secrets, data-provider tokens, or misleading screenshots to public GitHub. For confidential discussions propose private project handoff instead.
- If you encounter a blocker, choose the safest partial implementation and document what remains. Avoid unnecessary owner interruptions. First concrete target is P0 and a working animated simulation-only dashboard with reliable tests and CI.

## 7. Completion criteria
The work is accepted for P0 only when: source code compiles on Windows+Linux, all actual Release-mode test assertions execute, Qt GUI builds and loads at 1366×768 and 1920×1080, screenshots are from the executable rather than generated mockups, dynamic tracks use the C++ simulator, the simulation status is unmistakable, replay/pause/reset function, unit and schema validation tests pass, no copied restricted code appears in public commits, PR remains reviewable, and a complete handoff report with evidence is posted in issue #2.
