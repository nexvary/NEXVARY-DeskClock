# Synthetic scenario formats

Open a file from **Scenarios → Open JSON file**. Start with [the v1 two-aircraft example](civil-training.json) or [the v2 climb and turn example](civil-waypoints.json). Successful loading switches the simulator to the new scenario at time zero and pauses it. **Play** starts it, **Step** manually advances one tick, and **Reset** restores the current scenario's initial coordinates. **Load built-in scenario** restores the original three civil aircraft.

The **Scenarios** workspace also provides a draft JSON editor. **Apply draft** validates the document and starts it paused at time zero. **Save draft** validates and atomically writes the JSON to a user-selected local file, keeping the active simulation in its current state. Opening a different scenario or returning to the built-in one replaces the draft with that scenario's JSON. Validation errors preserve the current simulation and any existing destination file.

Files are UTF-8 JSON, limited to 256 KiB and 1–256 aircraft. Root metadata declares the format, version and synthetic source. IDs are positive and unique within the scenario. The loader trims names and labels, limits their length to 80 and 64 UTF-16 code units respectively, and rejects inline control and format characters. It rejects unknown fields and invalid numeric values. The magnitude of the local horizontal velocity is limited to 2 km/s. The [JSON Schema](scenario-v1.schema.json) describes interchange structure and per-field bounds. The desktop enforces an equivalent typed contract plus the loader-specific limits.

Coordinates are east and north in kilometers, velocities are east and north in kilometers per second, and altitude is meters above the simulation reference plane. The horizontal position bounds apply to initial state. The default 40 km radar scope may leave some valid tracks beyond the visible rings. Use zoom and pan to explore a wider area. The air traffic list remains available for selection. Both formats use the fixed desktop tick. Aircraft without a route use constant horizontal velocity and fixed altitude. Weather, geodetic positions and validated flight performance models remain outside these file versions.

## Timed waypoints in v2

The [v2 schema](scenario-v2.schema.json) keeps the v1 fields and adds an optional `waypoints` array to each aircraft. Existing v1 files load without conversion. A v2 aircraft without waypoints behaves like a v1 aircraft.

A route starts at the aircraft's initial coordinates and altitude at simulation time zero. Supply 1–64 waypoints with strictly increasing `time_s` values greater than 0 and at most 86,400. Every waypoint has east and north coordinates and altitude in the original units. The loader validates each leg's horizontal speed against the 2 km/s scenario limit.

East, north and altitude interpolate linearly over each leg. For a routed aircraft, horizontal velocity comes from the current leg. After the last waypoint its position and altitude hold and its horizontal speed goes to zero. This model permits instantaneous heading or speed changes and applies no turn, climb, descent or weather performance constraints.
