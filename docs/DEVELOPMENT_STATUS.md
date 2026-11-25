# AeroRadar — Development Status

**Last updated:** 2026-11-25  
**Branch:** `feature/p1-qml-components`  
**Verified build commit:** `b241bf7b16d2d1b1772f116ab80062b3a408995c`  
**CI:** [AeroRadar CI](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/45560516711) and [Source Hygiene](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/45560516687) passed.

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
| **Qt integration tests (QTest)** | `tests/integration/SimulatorModelTests.cpp` — 11 QTest cases via QSignalSpy | ✅ Passed as `simulator_tests_integration` via an exact CTest filter |
| **NSIS installer script** | `installer/aeroradar.nsi` | Verified on Windows Server 2022 |
| **`--screenshot <path>` mode** | `apps/desktop/main.cpp` | Verified on Linux Xvfb at 1440 × 900 and 1200 × 760 |
| **docs/ci/ci_p1_packaging.yml** | Reference copy of the active P1 packaging workflow | In repo (documentation) |
| **README.md** | Added | ✅ |

---

## P1 packaging and QA

The workflow was committed from GitHub’s web editor on the P1 branch. CI requires both desktop CTest entries to exist and pass. Windows packaging uses `windeployqt` for the Qt runtime, QML imports and Windows platform plugin, and includes the Visual C++ runtime DLLs.

The Windows Server 2022 job started both the extracted portable build and the installed application with the native Qt Windows plugin and the Qt development paths removed. It then uninstalled the application and confirmed that unrelated files at the installation root and in a nested directory retained their contents. The NSIS uninstaller removes files listed in the build payload and removes directories only when empty.

| Deliverable | GitHub Actions artifact |
|---|---|
| Windows x64 installer and SHA-256 file | [Download](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/45560516711/artifacts/14997771843) |
| Windows x64 portable ZIP and SHA-256 file | [Download](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/45560516711/artifacts/14997856252) |
| Running dashboard at 1440 × 900 and 1200 × 760 | [Download](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/45560516711/artifacts/14997492887) |

Visual review confirmed the synthetic radar tracks, aircraft details and icons, controls, panel alignment, Nexvary branding and the simulation-only warning at both sizes.

## Known limitations

- The Windows packages are unsigned. Verification used the hosted Windows runner and a silent installation. Interactive installer and dashboard review on a physical Windows device remain unverified.
- Some secondary dashboard labels are small and low-contrast. The visual evidence was captured on Linux.
- Track motion uses constant-velocity planar simulation. Weather and scenario metadata are presentation placeholders. The application is for civilian research and synthetic simulation.
- 3-D scene and Arabic RTL are planned for P2.
