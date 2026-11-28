# NEXVARY AeroRadar development log

## 2026-11-28 — Baseline inventory

GitHub reported 5 branches, 4 open draft pull requests, 2 open issues, 2 workflows, 72 workflow runs, 60 workflow artifacts and no official releases. The clone contained 30 distinct commits before local work. The five branch tips form one ancestry chain.

| Branch | Head | Evidence |
| --- | --- | --- |
| `main` | `f69bfb8` | Ownership notice only. |
| `feature/aeroradar-foundation` | `ad2de93` | Core CI succeeded. Desktop runtime coverage was absent from this branch's workflow. [PR #1](https://github.com/nexvary/NEXVARY-DeskClock/pull/1) · [CI](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/44961493449) |
| `feature/p0-foundation-repair` | `82d80b2` | Core and desktop CI succeeded. [PR #3](https://github.com/nexvary/NEXVARY-DeskClock/pull/3) · [CI](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/44982888909) |
| `quality/p0-engineering-gates` | `1c7ce98` | Core, desktop and hygiene succeeded. [PR #4](https://github.com/nexvary/NEXVARY-DeskClock/pull/4) · [CI](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/44983001963) · [Hygiene](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/44983001936) |
| `feature/p1-qml-components` | `d173a1e89e3f17d58c7c0a7cadbe6fd53c1a86b9` | Selected as the latest verified development baseline. It contains all earlier branch tips, native desktop startup, screenshots and Windows packages. [PR #6](https://github.com/nexvary/NEXVARY-DeskClock/pull/6) · [CI](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/45560978192) · [Hygiene](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/45560978296) |

GitHub reported the four original draft PRs as clean at their recorded heads. PRs are stacked from `main` through foundation, repair, quality and P1. Issue #2 records project coordination and disclosure rules. Issue #5 tracks P1 desktop work. The product source lacks a tracked license grant. Historical workflows, documentation and handoff files were retained. [Issue #2](https://github.com/nexvary/NEXVARY-DeskClock/issues/2) · [Issue #5](https://github.com/nexvary/NEXVARY-DeskClock/issues/5)

### Baseline CI and artifact verification

The push and PR runs for the selected SHA each report four successful jobs, covering core Debug/Release and Qt desktop Release on Ubuntu 24.04 and Windows Server 2022. Source hygiene also passed. The hosted Windows workflow covers deployed portable startup, silent install and installed startup, and uninstall preserving two unrelated files. That evidence applies to the baseline SHA. [PR CI](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/45560978192) · [Push CI](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/45560972544)

| Artifact from run 45560978192 | Local inspection |
| --- | --- |
| [Portable ZIP](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/45560978192/artifacts/14998525704) | Outer SHA-256 matches GitHub. Portable payload matches its bundled sidecar. Archive integrity, AMD64 PE header and Qt/platform/MSVC DLL entries checked. |
| [NSIS installer](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/45560978192/artifacts/14998236251) | Outer SHA-256 matches GitHub. Installer matches its bundled checksum and has an executable header. |
| [Rendered dashboard captures](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/45560978192/artifacts/14998096223) | Outer SHA-256 matches GitHub. PNG headers show 1440×900 and 1200×760. |

Interactive Windows install, upgrade, signing and Linux distribution packaging remain open.

### Local P0 work

Branch `engineering/p0-baseline-hardening` starts at the full P1 SHA above. Commit `8d80d57f73429f87a9c716a67bd70cc242333a20` hardens input and overflow handling, resets without allocation, stops the paused model timer and redundant notifications, uses a standard pi constant and calculates the clock display from integral ticks. It adds targeted regressions, CTest desktop startup and configuration coverage for Clang, Windows and Linux.

On Debian 13 with GCC 14.2.0, CMake 4.4.5 and Qt 6.5.3, separate build directories passed `cmake --build` and `ctest --no-tests=error --output-on-failure` for core and desktop Debug and Release. Each desktop build ran 3 CTest entries with 28 core cases, 16 Qt model cases and one offscreen startup check. The source hygiene scan passed. All 28 core cases also passed with GCC AddressSanitizer and UndefinedBehaviorSanitizer. LeakSanitizer could not run under the local process sandbox, and that run used `ASAN_OPTIONS=detect_leaks=0`.

An additional runtime check of the desktop identified repeated Canvas font errors that the original startup check missed, and a mismatch between the fixed-wing icon's rotation and its heading vector. Follow-up commit `826d6e5e16c9c01741cc3df86cab5f182aeb7ac2` uses a portable Canvas font and consistent heading rotation. CTest checks the font error and the smoke command fails on warnings from the QML engine. Linux GCC/Qt Debug and Release builds passed all three CTest entries after the follow-up.

### Hosted P0

The exact P0 PR head `413afb08b75964735af2c9887e9666b20719a742` passed both CI trigger runs and both source-hygiene runs. Results cover GCC and Clang on Ubuntu, MSVC on Windows, and Qt desktop Debug and Release on both systems. The Windows desktop job completed portable startup, silent install, installed startup and removal while keeping unrelated files. [PR #7](https://github.com/nexvary/NEXVARY-DeskClock/pull/7) · [PR CI](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/46186080411) · [Push CI](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/46186040183) · [Hygiene](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/46186080459)

GitHub published the [Windows installer](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/46186080411/artifacts/15280031036), [portable ZIP](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/46186080411/artifacts/15280016046), and [Linux screenshots](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/46186080411/artifacts/15279523171) as workflow candidates. Local inspection independently verified the outer archive hashes, the bundled installer and portable hashes, essential portable runtime DLLs and both screenshot dimensions.

## 2026-11-28 — P1 desktop workspaces

Branch `engineering/p1-desktop-workspaces` starts at the tested P0 head. Commit `c9cf509b6776bf8ea0b38353e27437f9f066517c` adds functional workspace navigation, keyboard and pointer controls, and a reusable track list with stable delegates. It replaces the empty 3D panel and fictitious weather, terrain and timeline values with current model data and removes duplicate playback controls. Commit `464041211d0bdf64aacd3c2a04c60722e2a90609` adds a persisted light/dark appearance setting and updates shared UI and PPI colors.

Local Debian 13, GCC 14.2.0 and Qt 6.5.3 builds passed Debug and Release CTest (4/4 entries in each). The dashboard tests opened the actual QML window, exercised Tab and Space navigation, stable track focus through a simulation tick, track selection, keyboard appearance switching, persistence after window recreation, and pointer pause, reset and resume. Release produced dark 1440×900 and 1200×760 images and a light 1200×760 image offscreen. Source hygiene passed.

## 2026-11-28 — P2 fixed-step playback

Branch `engineering/p2-fixed-step-controls` starts at P1 head `e485730896317ed413d378c2fca5edb97786381b`. Commit `ba38fe3d8a6e6f7da375f2b1f5c94b68c1bb3b0c` moves the existing built-in scenario into the dependency-free core and adds paused single-step and five playback rates. Playback rate changes the wall timer interval while each model step advances 100 ms of simulation time. Reset keeps the pause state and selected playback rate.

Local Debian 13, GCC 14.2.0 and Qt 6.5.3 builds passed `ctest --no-tests=error --output-on-failure` in Debug and Release, with four entries in each configuration. The run covers 30 core cases, 18 model cases, two Qt dashboard cases and one startup test. A regression compares 300 automatic and manual steps on the built-in scenario and checks exact coordinate and elapsed-time equality within the build. UI tests verify the initial speed selection, keyboard rate and pause controls, and manual and continuous advancement. Source hygiene passed.

### Hosted P1 and fixed-step playback

P1 head `e485730896317ed413d378c2fca5edb97786381b` and fixed-step head `7f739afb8b5ac929f993a9a8061d2e6b96d704c7` passed hosted source hygiene and the Linux/Windows CI matrix including Windows package startup, silent install and uninstall. [PR #8](https://github.com/nexvary/NEXVARY-DeskClock/pull/8) · [P1 CI](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/46186659107) · [PR #9](https://github.com/nexvary/NEXVARY-DeskClock/pull/9) · [Fixed-step CI](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/46187093999)

## 2026-11-28 — P2 synthetic scenario loading

Branch `engineering/p2-scenario-loading` starts at the fixed-step head. Commit `f2e065fb9287e0a99617fced262e1fa34f98965f` adds a Scenarios workspace, v1 schema and working civil example. A Qt file boundary reads only bounded local inputs and validates them before replacing the current simulator. Success loads the new scenario at time zero while paused. Failure leaves the active simulator untouched and updates the visible error. The track list is scrollable and keeps the current track identities across ticks.

Local Debian 13 GCC 14.2.0 and Qt 6.5.3 passed `ctest --no-tests=error --output-on-failure` in Debug and Release, with four entries each. Model tests exercised accepted load and reset, restoration of the built-in scenario, remote rejection and eight invalid-file rows. Dashboard tests exercised navigation, display of load errors and restoration from the real QML window. The draft 2020-12 schema and the checked-in example passed Python jsonschema validation. Source hygiene passed. Native file-chooser interactions and Windows packaging are covered separately by platform review and hosted verification.

The scenario-load push CI for exact head `62c83b0d7856737a88d55ab9931d446cafbeefe1` passed core GCC/Clang/MSVC, Linux and Windows desktop Debug and Release, and hosted Windows packaging. [PR #10](https://github.com/nexvary/NEXVARY-DeskClock/pull/10) · [Push CI](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/46187644371)

## 2026-11-28 — P3 radar navigation

Branch `engineering/p3-radar-navigation` starts at the scenario-load head. Commit `882f642d071a9b47d3ea9395d1caaf96f3560898` adds 10–1280 km zoom, drag panning, recentering, type filtering and independent label and history overlays. PPI painting and click selection use one local projection and filter. The view reuses the latest Qt track snapshot between simulation notifications. Commit `5d2444c9ea9aa412d9baba5766cd8576a7bae317` fits controls to the minimum supported window and sets readable theme colors for their labels.

Local Debian 13 GCC 14.2.0 and Qt 6.5.3 passed 4/4 CTest entries in Debug and Release. The real-window radar test exercises zoom, drag pan, panned-track selection, hidden-track rejection, toggles and recenter while paused. The source hygiene check passed. The release executable rendered the dashboard at the minimum window size.

## 2026-11-28 — P2 waypoint and altitude profiles

Branch `engineering/p2-waypoint-profiles` starts at the P3 head. Commit `634a930acc3c4aa36ad95710c0766bc377131090` adds timed local waypoint interpolation and route-based altitude. The simulation validates routes at construction, computes deltas and next state before committing a tick, and restores position, velocity and altitude on reset. Version 2 adds optional waypoints while retaining the v1 file behavior. The app labels the active flight model.

Debian 13 with GCC 14.2.0 and Qt 6.5.3 passed 4/4 CTest entries in Debug and Release. Coverage includes interpolation midway through each leg, direction change at a waypoint, terminal hold, restoration of altitude and velocity, invalid times and route speed, and loading both schema versions. All 32 core tests passed with AddressSanitizer and UndefinedBehaviorSanitizer. Local LeakSanitizer remained unavailable. Both schemas and both examples passed Python jsonschema validation. Source hygiene passed.

### Dependency review

The published Qt Quick 3D terms are commercial or GPLv3. The repository currently reserves all rights, so product adoption remains blocked pending an approved compatible licensing route. JSBSim remains an evaluation candidate based on active native C++ upstream maintenance, and BlueSky remains reference-only. No new bundled dependency was introduced. [Adoption matrix](THIRD_PARTY_ADOPTION_MATRIX.md)

### Hosted radar and waypoint evidence

The radar PR head `52cdcf8f54f0ef25079cb7247d44f5b34cc5efca` and waypoint code head `575405cc6ce4721bb7707d552237fd49de3857c0` passed their full hosted matrix. The Windows packaging workflow verified portable and installed startup and silent uninstallation while preserving unrelated files. The radar artifact archives and their installer and portable checksums were also verified locally. [Radar PR #11](https://github.com/nexvary/NEXVARY-DeskClock/pull/11) · [Radar CI](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/46188112221) · [Waypoints PR #12](https://github.com/nexvary/NEXVARY-DeskClock/pull/12) · [Waypoint CI](https://github.com/nexvary/NEXVARY-DeskClock/actions/runs/46188588930)

## 2026-11-28 — P5 scenario editor and atomic save

Branch `engineering/p5-scenario-edit-save` starts at the waypoint and licensing changes. Commit `f46201e9ace11255e01d11a92571eec7242f921f` adds a draft JSON editor with separate Apply and Save operations. Apply validates before replacing the active simulation. Save validates and atomically commits a local file using QSaveFile and retains the simulation state.

Local Debian 13 GCC 14.2.0 and Qt 6.5.3 passed 4/4 CTest entries in Debug and Release. The real-window test applied a changed draft. Model tests verified the rejected edit and rejected save leave active state and existing file bytes intact, invalid save destinations fail, and both scenario versions round trip. Source hygiene passed.

### Resume point

Continue on `engineering/p5-scenario-edit-save` from the latest pushed commit. The next shared dependency is a bounded simulation recording format with explicit version, tick, scenario, source and reproducibility metadata, then replay and research workspaces. The P2 engine still needs seeded generation, synthetic weather and validated civil performance models. P3 still needs units, display preferences, geodetic projection and measured performance. Qt Quick 3D adoption requires a compatible license route. Upstream integration, additional P4–P11 acceptance checks and release gates remain open. See [feature parity](FEATURE-PARITY.md) and [release checklist](RELEASE-CHECKLIST.md).
