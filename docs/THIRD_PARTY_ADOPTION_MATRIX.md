# NEXVARY AeroRadar — Third-Party Adoption Matrix

**Date:** 2026-11-22  
**Status:** Initial P0 audit. No third-party code has been copied into this repository yet.

## Purpose

This document records every external component, library, dataset, asset, and tool
referenced or potentially incorporated. No code or asset may be added to the public
`nexvary/NEXVARY-DeskClock` repository without a GREEN status in this matrix.

## Status legend

| Symbol | Meaning |
|--------|---------|
| ✅ GREEN | Reviewed; adoption permitted under chosen licence route |
| 🟡 PENDING | Under review; not yet adopted |
| 🔴 BLOCKED | Cannot be adopted without further owner action |
| ➖ N/A | Referenced for inspiration only; no code copying |

---

## 1. Build tools and runtimes (not distributed)

| Component | Version | Licence | Action | Status |
|-----------|---------|---------|--------|--------|
| CMake | ≥ 3.22 | BSD-3-Clause | Build tool only | ✅ GREEN |
| MSVC / Clang / GCC | — | Various | Compiler only | ✅ GREEN |
| Qt6 (dynamic link) | ≥ 6.5 | LGPL 2.1 / GPL | Dynamic link; must ship Qt licence notices | 🟡 PENDING — licence notice template needed |

**Qt LGPL obligation:** Dynamic linking with Qt6 LGPL modules is permitted for a proprietary
application provided: (a) the LGPL licence text is distributed, (b) users can relink with a
modified Qt, (c) no modified Qt source is claimed as proprietary. Verify exact modules used;
QtQuick3D may carry additional notices.

---

## 2. Flight dynamics and physics references

| Component | URL | Licence | Chosen action | Status |
|-----------|-----|---------|---------------|--------|
| JSBSim | github.com/JSBSim-Team/jsbsim | LGPL 2.1 | Evaluate for P3 physics backend; dynamic link only | 🟡 PENDING |
| Project AirSim | github.com/iamaisim/ProjectAirSim | MIT (core) | Reference architecture; subcomponent licences TBD | 🟡 PENDING |
| Gazebo (gz-sim) | github.com/gazebosim/gz-sim | Apache 2.0 | Optional adapter; not in base installer | 🟡 PENDING |
| Old AirSim (Microsoft) | github.com/microsoft/AirSim | MIT | Reference only; abandoned upstream | ➖ N/A |
| FlightGear | github.com/FlightGear/flightgear | GPL-2.0+ | Inspiration only; GPL prevents embedding | ➖ N/A |

---

## 3. Air traffic and autopilot simulation

| Component | URL | Licence | Chosen action | Status |
|-----------|-----|---------|---------------|--------|
| BlueSky (TU Delft) | github.com/TUDelft-CNS-ATM/bluesky | MIT | Reference for multi-aircraft scenario design; no copy | ➖ N/A |
| PX4 Autopilot | github.com/PX4/PX4-Autopilot | BSD-3-Clause | External SITL process (P4); no code copy in AeroRadar | 🟡 PENDING |
| ArduPilot | github.com/ArduPilot/ardupilot | GPL-3.0-or-later | External SITL only via JSON/UDP interface; **no source copy** | 🔴 BLOCKED — GPL requires careful isolation |

**ArduPilot note:** ArduPilot is GPL-3.0-or-later. Its protocol documentation and message
formats may be referenced. Its source code MUST NOT be copied into AeroRadar. Any
interaction must be via a clearly documented external process boundary.

---

## 4. Telemetry and ground control

| Component | URL | Licence | Chosen action | Status |
|-----------|-----|---------|---------------|--------|
| MAVLink message headers | mavlink.io | MIT | May generate C++ headers; use message definitions only | 🟡 PENDING |
| MAVSDK C++ | github.com/mavlink/MAVSDK | BSD-3-Clause | Evaluate for P4 telemetry receive-only adapter | 🟡 PENDING |
| QGroundControl | github.com/mavlink/qgroundcontrol | Apache-2.0 OR GPLv3 | UI inspiration only; licence route must be chosen before any copy | 🔴 BLOCKED — dual licence requires explicit route choice |

---

## 5. Proprietary Nexvary source (private → public boundary)

| Repository | Artefact | Current status | Required approval |
|------------|----------|----------------|-------------------|
| nexvary/NEXVARY-Avionics-Lab | QML components (RadarScope, AI, Replay…) | PRIVATE — not copied | Owner must explicitly authorise per-file public release |
| nexvary/NEXVARY-Avionics-Lab | TelemetryRecorder, SensorBus | PRIVATE — not copied | Same as above |
| nexvary/NEXVARY-Aviation-Navigator | AircraftTrack.kt, TrafficRepository.kt | PRIVATE — Kotlin; reimplement in C++ | Owner must authorise data-contract adaptation |
| nexvary/Aegis-CUAS-Command | AirspaceSimulator.cs, TrackFusionEngine.cs | PRIVATE — C#; reimplement in C++ | Owner must authorise concept reuse |

**Current status for P0:** No code from any private repository has been copied into
`nexvary/NEXVARY-DeskClock`. The P0 implementation derives `aeroradar_core` and all Qt
bridge code independently. The `nexvary.air-operations.exchange/v1` wire format will be
documented and tested against published schema fixtures (not private source).

---

## 6. Data sources

| Source | Licence / Terms | Action |
|--------|-----------------|--------|
| OpenSky Network | Academic / Non-commercial | Receive-only; not bundled; display requires attribution; not for commercial operational use |
| ADS-B Exchange | Commercial restrictions | Evaluate before any live-feed integration |
| Radar tile maps | Per-provider (OSM: ODbL) | Attribution required; tiles not bundled |

---

## 7. Fonts, icons, images

| Asset | Source | Licence | Status |
|-------|--------|---------|--------|
| System UI font (Consolas/monospace) | OS-bundled | OS licence | ✅ GREEN — referenced only |
| Dashboard concept artwork | Owner-supplied | Nexvary proprietary | ✅ GREEN — reference only, not committed |

---

## Review history

| Date | Reviewer | Change |
|------|----------|--------|
| 2026-11-22 | Claude (P0 audit) | Initial matrix created; no code adoptions |

