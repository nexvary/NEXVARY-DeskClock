# NEXVARY AeroRadar engineering plan

This plan governs ongoing work in the existing `nexvary/NEXVARY-DeskClock` repository. [Development log](DEVELOPMENT-LOG.md) records the selected development base and evidence. [Feature parity](FEATURE-PARITY.md) records individual requirements and acceptance. Historical briefs, roadmap and branch reports remain in place.

| Stage | Entry dependency | Acceptance |
| --- | --- | --- |
| P0 Foundation | Verified development baseline | Named builds on GCC, Clang and MSVC. Debug and Release tests, input and overflow regressions, paused timer behavior, license inventory and accurate build instructions. |
| P1 Desktop | P0 | Each visible workspace performs a real action or displays real data. Review dark/light styling, keyboard use, accessibility, scaled rendering and multiple screens in a running application. |
| P2 Simulation | P0 | Repeatable runs from identical validated inputs, fixed timesteps, explicit clocks and seeds, documented coordinate and unit contracts, and independently tested controls, waypoints, weather and model behavior. |
| P3 PPI | P2 data contract | Check calibrated local projection, range rings, compass, selection, trail, filters, units and pan/zoom against synthetic fixtures and measure frame time. |
| P4 3D | P2 and P3 share a data source | Check Qt Quick 3D scene, camera modes, terrain, aircraft and paths with matching snapshot and selection in 2D and 3D. Record hardware results and asset licenses. |
| P5 Scenarios and replay | P2 scenario contract | Validate and migrate versioned JSON. Verify round trips, timeline, replay determinism, event bookmarks, notes and CSV/JSON export and comparison. |
| P6 Civil data | P2 and P5 data contracts | Verify synthetic and recorded providers with safe offline import, UTC normalization, provenance, quality indicators and unmistakable source labels. Require terms and privacy review before considering a public civil feed. |
| P7 Research | P2, P5 and P6 | Check analytics and comparison against reference trajectories. Export units, assumptions, seed, versions, source provenance and performance metrics. |
| P8 Localization | Stable P1 UI contracts | Exercise English and Arabic in both directions, Arabic glyphs, layout, UTC, localized dates and numbers, and all requested length, altitude and speed units. |
| P9 Security and reliability | Continuous | Validate and bound imports, verify recovery, structured logs and privacy, check dependencies and licenses, run static analysis and sanitizers, and generate the SBOM. |
| P10 QA | Continuous | Require named Debug and Release tests on Windows and Linux. Include real UI exercises, model tests, screenshots, scenarios, determinism, benchmarks, stability and install/upgrade/uninstall. |
| P11 Release | All applicable gates | Reproduce Windows and Linux packages and verify deployment, checksums, install, update and removal. Publish notes, dependency manifest and SBOM. Sign when an approved certificate is available. |

Track the highest-priority unmet item with a dependency-ready acceptance check. Capture commands and results before advancing the matrix. Prepare scoped draft PRs against the relevant parent. Integrate only after applicable CI, review and branch controls pass. Use [release checklist](RELEASE-CHECKLIST.md) for publication.
