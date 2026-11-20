# AeroRadar architecture — initial foundation
## Scope
Research-grade radar simulation, civil aviation tracking, passive SDR, geospatial visualization, and reproducible analysis.

## Safety boundaries
The desktop radar preview uses hardcoded synthetic points and does not represent live observations.
The CLI uses a constant-velocity, planar toy model; it is NOT a validated radar measurement, navigation, flight dynamics, or collision safety model.
No aircraft control, radar transmitter, jamming, interception, or operational air traffic control is supported.

## Components
- `core/simulation`: deterministic, isolated simulation kernel with explicit units (km, km/s, m).
- `apps/cli`: headless simulation smoke test.
- `apps/desktop`: optional Qt Quick shell and static PPI visualization.
- `tests/unit`: simple assertions; evolve into dedicated test framework.
- `integrations`: reserved for receive-only ADS-B and SDR adapters after licensing and hardware checks.
- `data`: reserve for provenance-aware schemas and migration history.

## Next engineering steps
Define stable UTC timestamps, coordinate systems, uncertainty models, immutable measurement provenance, scenario serialization, realistic geodesy, track association, replay, and live-vs-simulation safeguards.
Protect main and require both OS CI jobs before merging.
