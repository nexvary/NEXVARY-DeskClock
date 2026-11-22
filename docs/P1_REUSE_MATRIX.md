# NEXVARY AeroRadar â€” P1 Component Reuse Matrix
<!-- DATA: INTERNAL DESIGN DOCUMENT. No private source included. -->

**Status:** Planned P1 â€” awaiting owner authorisation to inspect private repos
**Author:** Claude (Principal Engineer)
**Date:** 2026-11-22
**Security note:** Private repository source MUST NOT be copied into this public repo without explicit owner approval per the AeroRadar master brief.

---

## Access Status

The three private repos referenced in the master brief are not visible via the current GitHub token:

| Repository | Expected content | Access status |
|---|---|---|
| `nexvary/NEXVARY-Avionics-Lab` | Qt/QML radar viz, flight instruments, digital-twin | âŒ Not accessible (private / token scope) |
| `nexvary/NEXVARY-Aviation-Navigator` | Aviation data models, ADS-B integration, maps | âŒ Not accessible (private / token scope) |
| `nexvary/Aegis-CUAS-Command` | Sim, track fusion, versioned air-ops exchange contract | âŒ Not accessible (private / token scope) |

**Owner action required:** Grant read access to private repos before code-level audit can proceed.

The matrix below is derived from the master brief descriptions and represents the **design-intent reuse plan**, not verified code inventory.

---

## Component Reuse Matrix

### From `NEXVARY-Avionics-Lab`

| Component | Described capability | AeroRadar destination | Lang compat | Security | Licence | Refactor effort | Tests required |
|---|---|---|---|---|---|---|---|
| Radar PPI QML widget | Qt/QML range-ring + sweep canvas | Replace `radarCanvas` in `Main.qml` | Qt6/QML âœ… | None | Proprietary â†’ needs owner release | Low â€” same stack | Visual regression, PPI geometry |
| Flight instrument widgets | QML attitude, airspeed, altitude indicators | Instruments row (currently read-only text) | Qt6/QML âœ… | None | Proprietary â†’ owner release | Medium â€” integrate to `SimulatorModel` | Per-instrument bound-data test |
| Digital-twin interface | Live telemetry binding pattern | `SimulatorModel` property expansion | Qt6/QML âœ… | Verify no live-data calls | Proprietary â†’ owner release | Medium | Mock-data unit test |
| Telemetry replay system | Recording + playback of track history | REPLAY tab (currently P2 placeholder) | Qt6/C++ | Verify no undocumented transmission | Proprietary â†’ owner release | High â€” new C++ replay engine | Deterministic replay regression |

### From `NEXVARY-Aviation-Navigator`

| Component | Described capability | AeroRadar destination | Lang compat | Security | Licence | Refactor effort | Tests required |
|---|---|---|---|---|---|---|---|
| Aviation data model | Aircraft, waypoint, route structs | Extend `Aircraft` + `Simulator` | C++ âœ… | None | Proprietary â†’ owner release | Low â€” extend headers | Serialisation round-trip test |
| ADS-B integration | ADS-B message parser | Optional passive ADS-B overlay (P3+) | C++ | **Review carefully**: must label PASSIVE RESEARCH only; no spoofing/takeover | GPL or proprietary â€” confirm | High â€” new I/O layer | Offline-only replay; no live-claim test |
| Map/tile provider | Aviation chart overlay | Radar background map (P2) | QML/JS | Verify tile attribution; offline-first | Check tile provider licence | Medium | Attribution test |
| Data normalisation layer | Multi-source track merging | `SimulatorModel` multi-source bridge | C++ âœ… | Verify no undocumented external calls | Proprietary â†’ owner release | Medium | Source-merge unit test |

### From `Aegis-CUAS-Command`

| Component | Described capability | AeroRadar destination | Lang compat | Security | Licence | Refactor effort | Tests required |
|---|---|---|---|---|---|---|---|
| `nexvary.air-operations.exchange/v1` contract | Versioned read-only data interface | P1 domain model contracts | C++ âœ… | No write/command path in public repo | Proprietary â†’ owner release | Low â€” headers only | Contract version test |
| Track fusion engine | Multi-sensor observation merging | Future sensor aggregation (P3) | C++ | Confirm: no jamming/spoofing/weapon surfaces | Proprietary â†’ owner release | High | Fusion accuracy test |
| Simulation core | Scenario definition, deterministic stepping | Could replace kinematic `Simulator` | C++ âœ… | Audit for any offensive capability | Proprietary â†’ owner release | Medium | Determinism, edge-case tests |
| Playback engine | Recorded scenario replay | REPLAY tab | C++ âœ… | None | Proprietary â†’ owner release | Medium | Seek + frame-exact regression |

---

## Blocking Decisions Before P1

1. **Owner must grant private repo read access** so actual file/API inventory can proceed.
2. **Owner must explicitly approve** release of each specific source file before it enters the public repo.
3. **ADS-B integration** requires a legal/compliance review: must be passive-research-only, offline-capable, and labelled DATA: PASSIVE RESEARCH before any import.
4. **Aegis track fusion** must be audited for removal of any offensive-capability surface before even designing a compatible interface in the public repo.

---

## FlightSim Engine Evaluation (Phase 6 preview)

| Engine | Model type | Licence | Integration effort | Offline capable | Verdict |
|---|---|---|---|---|---|
| JSBSim | 6DOF flight dynamics | LGPL 2.1 | High â€” C++ lib, CMake | âœ… | **Candidate P3** â€” dynamic link; licence notice required |
| BlueSky | ATM traffic sim | MIT | Medium â€” Python core | âœ… | Concept reference only; Pythonâ†’C++ port needed |
| PX4 SITL | Autopilot SITL | BSD-3 | High â€” SITL environment | Partial | P4+ autopilot integration |
| ArduPilot SITL | Autopilot SITL | GPL-3.0-or-later | Blocked | N/A | **GPL â€” cannot copy source into proprietary** |
| Gazebo | Robotics/UAV sim | Apache-2.0 | Very high | âœ… | P4+ 3D environment |
| Microsoft AirSim | Unreal-based flight | MIT (deprecated) | High â€” Unreal dep | âœ… | Unmaintained; fork risk |
| MAVLink / MAVSDK | Protocol bridge | LGPL 2.1 / MIT | Medium | âœ… | **Candidate P3** â€” MAVLink for autopilot bridge |

**Current engine:** kinematic 2D (constant velocity, no physics). Altitude is fixed per aircraft. No wind, gravity, or control surfaces. This is explicitly documented as a **simulation scaffold**, not a validated flight-dynamics model.
