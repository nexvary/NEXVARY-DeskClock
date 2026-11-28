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

### Remaining work

Run the changed branch against the full Windows/Linux and compiler matrix, inspect packaging, and resolve upstream integration gates. Resume P1 with functional workspace navigation, removal of placeholder panels, and keyboard/pointer interaction coverage. Phase acceptance and all remaining requirements are recorded in [feature parity](FEATURE-PARITY.md).
