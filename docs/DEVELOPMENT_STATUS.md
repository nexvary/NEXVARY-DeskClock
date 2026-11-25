# AeroRadar — Development Status

**Last updated:** 2026-11-25  
**Branch:** `feature/p1-qml-components`  
**Head commit:** `1612093461576c8d511f6b567902a369f47e0d54`  
**CI:** ✅ AeroRadar CI — success | ✅ Source Hygiene — success

---

## P0 — Foundation (complete, verified)

| Item | Evidence |
|---|---|
| C++20 core simulation kernel | `core/simulation/` |
| 19 unit tests (pre-P1 baseline) | CI green, Ubuntu + Windows, Debug + Release |
| Qt/QML desktop shell | `apps/desktop/`, `ui/qml/Main.qml` |
| Dynamic PPI with sweep + track icons | `ui/qml/RadarPpi.qml` |
| Track selection via click | `RadarPpi.qml` MouseArea |
| Pause / Resume / Reset | `SimulatorModel.cpp` slots |
| QML offscreen smoke test | CI step, Linux + Windows |
| Source hygiene CI | `.github/workflows/code-hygiene.yml` |

---

## P1 — Engineering Foundation (this PR, branch verified by independent review)

### Completed and in CI

| Item | File | CI status |
|---|---|---|
| **QML component extraction** | `RadarPpi.qml`, `StatusStrip.qml`, `FlightInstruments.qml`, `SimulationControls.qml` | ✅ Builds + smoke |
| **Design token singleton** | `AeroTheme.qml` — Nexvary brand colours + fonts | ✅ |
| **Main.qml refactor** | 913 → ~175 lines, orchestration-only | ✅ |
| **CMakeLists.txt** | All 6 QML files registered; `QT_QML_SINGLETON_TYPE`; renamed `NexvaryAeroRadar` | ✅ |
| **24 unit tests (+5 new)** | `pause_idempotent`, `resume_idempotent`, `reset_while_running_stays_running`, `step_count_per_step`, `empty_aircraft_list` | ✅ Debug + Release |
| **QML offscreen smoke test** | `--smoke` flag, Linux + Windows offscreen | ✅ |
| **Qt integration tests (QTest)** | `tests/integration/SimulatorModelTests.cpp` — 11 QTest cases via QSignalSpy | ✅ Builds; runs as `simulator_tests_integration` via existing ctest filter |
| **NSIS installer script** | `installer/aeroradar.nsi` | In repo; CI execution blocked (see below) |
| **`--screenshot <path>` mode** | `apps/desktop/main.cpp` | In repo; CI step blocked (see below) |
| **docs/ci/ci_p1_packaging.yml** | Full packaging workflow ready | In repo (documentation) |
| **README.md** | Added | ✅ |

---

## Blockers — workflow scope

Updating `.github/workflows/ci.yml` requires the GitHub OAuth **`workflow`** scope.  
The `nexvary` CLI token has: `gist`, `read:org`, `repo` — **`workflow` is absent**.

The complete updated workflow is committed at `docs/ci/ci_p1_packaging.yml` and adds:

| Step | Platform | What it produces |
|---|---|---|
| `ctest -R simulator_tests` (expanded) | Ubuntu + Windows | Runs `simulator_tests_integration` (already works via rename — no ci.yml change needed) |
| Xvfb screenshot | Ubuntu | `screenshot_linux.png` CI artifact |
| `windeployqt` → ZIP | Windows | `NEXVARY-AeroRadar-P1-Windows-x64-Portable.zip` CI artifact |
| `makensis` | Windows | `NEXVARY-AeroRadar-P1-Windows-x64-Setup.exe` CI artifact |

**To unblock:** apply `docs/ci/ci_p1_packaging.yml` to `.github/workflows/ci.yml` via the GitHub web UI  
(browser session uses full user permissions, not the CLI token).  
URL: `https://github.com/nexvary/NEXVARY-DeskClock/edit/feature/p1-qml-components/.github/workflows/ci.yml`

---

## Remaining P1 artifacts (blocked on CI workflow update)

| Artifact | Status | Blocker |
|---|---|---|
| `NEXVARY-AeroRadar-P1-Windows-x64-Portable.zip` | Not produced | `workflow` OAuth scope |
| `NEXVARY-AeroRadar-P1-Windows-x64-Setup.exe` | Not produced | `workflow` OAuth scope |
| `screenshot_linux.png` (GUI) | Not produced | `workflow` OAuth scope |

---

## Note on Qt integration test execution (resolved without ci.yml change)

The CTest test name `simulator_tests_integration` was chosen so that the existing  
`ctest -R simulator_tests` command in `ci.yml` matches it via substring regex.  
`set_tests_properties(... ENVIRONMENT "QT_QPA_PLATFORM=offscreen")` makes it  
headless-safe. No workflow file change is needed for the integration tests to run.

---

## Other Nexvary repository assessment

| Repository | Outcome |
|---|---|
| `nexvary/NEXVARY-Avionics-Lab` | Not found / inaccessible (November 2026) |
| `nexvary/NEXVARY-Aviation-Navigator` | Not found / inaccessible (November 2026) |
| `nexvary/Aegis-CUAS-Command` | Not found / inaccessible (November 2026) |

No external components imported. AeroRadar develops independently.

---

## Known limitations

- Track motion: constant-velocity planar, no geodesy or flight dynamics.
- Weather/scenario/environment fields: hardcoded presentation placeholders.
- Simulation indicator reflects actual `SimulatorModel::isPaused()` (not hardcoded).
- Windows ZIP, installer, and screenshots require CI workflow update (see blockers).
- Binaries are unsigned (no digital signature).
- 3-D scene and Arabic RTL: planned P2.
