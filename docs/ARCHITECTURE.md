# NEXVARY AeroRadar architecture

The desktop demonstrates synthetic civil aviation tracks through a PPI. The C++20 core uses a local planar coordinate frame. Aircraft advance with constant velocity or follow timed planar legs with linear altitude interpolation. The model has no geodetic origin or validated flight dynamics. Positions are kilometers east and north, velocity is kilometers per second, altitude is meters relative to the local reference plane, and bearing is clockwise from north. Time is elapsed simulation seconds. The header's UTC clock reports wall time.

| Layer | Present implementation | Contract for extensions |
| --- | --- | --- |
| Simulation | `aeroradar_core` owns aircraft, elapsed time, step count and pause state. The CLI executes the core without Qt. | Validated scenario inputs, deterministic step order and a stable unit and seed contract. Keep I/O and rendering outside the kernel. |
| Desktop adapter | `SimulatorModel` owns the core and a 100 ms Qt timer on the GUI thread. It supplies selected track and bounded history through QML properties. The built-in desktop scenario is defined in the core. Desktop ticks always advance simulation time by 0.1 seconds. A separate wall timer paces playback at 0.25×, 0.5×, 1×, 2× or 4×. Late timer callbacks can reduce effective wall playback speed. | Publish one authoritative state and selection to both renderers. Introduce an explicit snapshot ownership boundary before worker threads. |
| Presentation | `Main.qml` composes the theme, PPI, header, instruments and controls. | Bind navigation to real workspaces. Keep PPI and Qt Quick 3D render-specific logic separate from simulation. |
| Scenario and replay | Built-in scenarios and validated v1/v2 JSON loading, draft editing and atomic save in the Qt adapter. The core takes typed aircraft records and optional timed routes. | Version, validate and migrate the persistent format. Record enough inputs and metadata for deterministic replay. |
| Sources | Synthetic model output only. | Use distinct synthetic and offline recorded providers. Preserve observed timestamps, normalized UTC, quality indicators and provenance. |
| Research | CLI prints sample range and altitude. | Consume reproducible state or recordings to derive and export statistics, trajectories and quality reports. |

The core is single-owner. Callers serialize mutation and avoid reading the aircraft vector concurrently with a step. The Qt adapter is confined to its QObject affinity thread. Reset restores coordinates, altitude, velocity and clocks without reallocating or changing the pause state. A rejected step leaves positions, elapsed time and steps intact. A manual step advances exactly one tick while preserving pause, and the desktop derives elapsed time from the integer tick count.

The original architecture proposal is archived in [the foundation document](architecture/ARCHITECTURE.md).
