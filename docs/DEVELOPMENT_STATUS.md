# AeroRadar — Development Status

**Last updated:** 2026-11-25  
**Branch:** `feature/p1-qml-components`  
**Base SHA:** `1c7ce9888163c99dbe0819090b400e5cb879694d`

---

## P0 — Foundation (complete)

| Item | Evidence |
|---|---|
| C++20 core simulation kernel | `core/simulation/` |
| 19 unit tests (pre-P1 baseline) | CI green, both OS, Debug + Release |
| Qt/QML desktop shell | `apps/desktop/`, `ui/qml/Main.qml` |
| Dynamic PPI with sweep + track icons | `ui/qml/RadarPpi.qml` (P1 extraction) |
| Track selection via click | `RadarPpi.qml` MouseArea |
| Pause / Resume / Reset | `SimulatorModel.cpp` slots |
| QML offscreen smoke test | CI step, Linux |
| Source hygiene CI (clang-format, include-what-you-use) | `.github/workflows/code-hygiene.yml` |

---

## P1 — Engineering Foundation (this PR)

### Completed

| Item | File / Notes |
|---|---|
| **QML component extraction** | `RadarPpi.qml`, `StatusStrip.qml`, `FlightInstruments.qml`, `SimulationControls.qml` |
| **Design token singleton** | `AeroTheme.qml` — Nexvary brand colours, fonts |
| **Main.qml refactor** | Reduced from 913 lines to ~175; orchestration-only |
| **CMakeLists.txt update** | All 6 QML files registered; `QT_QML_SINGLETON_TYPE` set for `AeroTheme.qml`; project renamed `NexvaryAeroRadar` |
| **24 unit tests (+5 new)** | `pause_idempotent`, `resume_idempotent`, `reset_while_running_stays_running`, `step_count_per_step`, `empty_aircraft_list` |
| **CI workflow fix** | Added `quality/**` to push branch triggers |
| **README.md** | Added to development branch |

### Not yet complete (P1.1 or P2)

| Item | Notes |
|---|---|
| Windows portable ZIP | Requires windeployqt + artifact upload step |
| Windows installer | NSIS / WiX script not yet written |
| Real desktop screenshots in CI artifacts | Needs Xvfb composite or virtual framebuffer |
| Qt integration tests (QTest) | Paused/resume/selection via C++ QTest not yet wired up |
| Arabic RTL localisation | Planned P2 |
| 3-D scene (Qt Quick 3D) | Planned P2 |

---

## Other Nexvary repository assessment

As required by Issue #5 (P1 source matrix), three additional Nexvary repositories were queried for reusable components:

| Repository | Outcome |
|---|---|
| `nexvary/NEXVARY-Avionics-Lab` | Not found / inaccessible via GitHub API (November 2026) |
| `nexvary/NEXVARY-Aviation-Navigator` | Not found / inaccessible via GitHub API (November 2026) |
| `nexvary/Aegis-CUAS-Command` | Not found / inaccessible via GitHub API (November 2026) |

**Conclusion:** No external components were imported. AeroRadar development continues independently. The P1 source matrix document (`docs/P1_REUSE_MATRIX.md`) should be updated to reflect these access failures and confirm that no private or restricted source was transferred.

---

## Known limitations

- Track motion uses a constant-velocity planar model with no geodesy, terrain, or flight dynamics.
- Weather, scenario name, and environment fields are hardcoded presentation placeholders — not model-backed.
- Simulation indicator reflects the actual `SimulatorModel::isPaused()` property (not a hardcoded string).
- No Windows installer or portable ZIP has been produced yet.
- No actual desktop screenshots exist in CI artifacts (smoke test only validates headless QML load).
- Binaries are unsigned.
