# NEXVARY AeroRadar — Engineering Quality Policy

**Status:** working quality baseline for research software; not an aviation safety certification.
**Scope:** core C++20, Qt 6, QML, integration adapters, simulation studies, and CI.

## 1. Engineering gates (required before a feature is merged)

1. **Reproducible builds** for Windows x64 and Linux, both Debug and Release, with no
   ignored build failures.
2. **Executable tests** for changed algorithms and error paths. Tests must remain active
   in Release (`NDEBUG`); count registrations accurately. The P0 baseline is 19.
3. **Real GUI startup validation** on both systems, with a nonzero exit on QML errors.
   A green compile job is not proof that a UI panel works as advertised.
4. **Reproducible evidence:** provide exact commit SHA, test/CI URLs, and genuine runtime
   screenshots for visual claims. Never substitute conceptual art.
5. **Truthful system boundaries:** all simulated tracks labelled synthetic; no live-data,
   flight dynamics, 3D, replay or sensor fusion claims without actual implementation/tests.
6. **Security and data provenance:** no credentials, private source, unauthorized data
   collection, or sensitive external URLs in public changes.
7. **Licensing:** review Qt, JSBSim, source assets, fonts, icons and third-party service
   terms before distribution.
8. **Human approval:** owner reviews merge/release/publication of private-owned code.
   PRs begin as drafts when evidence or packaging is incomplete.

## 2. Code architecture

- **Core (C++):** deterministic simulation and domain logic. Keep Qt out of the core.
  Explicit units; document whether coordinates are local ENU, geodetic or another frame.
- **Qt adapter:** conversion from core data to observable Qt properties and commands.
  Q_PROPERTY NOTIFY must fire for all changing fields. Keep view and physics clocks separate.
- **QML:** small reusable components, not a monolithic window. Split `Main.qml` into
  independently testable panels; keep one authoritative state model and remove decorative
  controls that pretend to work.
- **UI rules:** readable high-contrast dark styling, professional vector icons, Arabic
  RTL where supported. Placeholder panels must be visibly labelled as such.
- **Interop:** versioned, read-only, opt-in adapters. The private Avionics-Lab,
  Aviation-Navigator and Aegis-CUAS-Command repositories stay private.

## 3. P1 refactoring order (separate PRs, no big-bang rewrite)

1. Extract color and typography tokens into a dedicated theme component/singleton.
2. Extract the radar canvas into `RadarPpi.qml` and test selection, range, sweep,
   trail rendering and pause behavior independently.
3. Extract `StatusStrip.qml`, `FlightInstruments.qml`, `SimulationControls.qml`,
   and `TrackList.qml`; update `qt_add_qml_module` and validate imports on both OSes.
4. Replace large dynamic `QVariantMap`/list surfaces with typed models once the
   app has regression tests protecting existing bindings.
5. Replace static/self-registering test initialization with an explicit test registry
   or a maintained framework, without reducing actual test coverage.
6. Add automated screenshot + UI-interaction tests and a deployment-tested Windows
   installer when the interface is stable.

## 4. Pull-request evidence

Each PR must identify: changed behavior, tests, CI, screenshots if UI changed,
security/data exposure, licensing, limitations, and explicit roll-back path.
Avoid sweeping formatting-only edits mixed with functional changes.

**Safety:** This software is a civil research/simulation environment and must not be
presented as certified avionics or a real operational radar system.
