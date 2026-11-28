# NEXVARY AeroRadar engineering instructions

NEXVARY AeroRadar is NEXVARY Inc.'s civilian flight simulation and research desktop application. The existing GitHub repository is `nexvary/NEXVARY-DeskClock`. Every data view must label whether its source is synthetic or recorded. Operational navigation, operational air traffic control, aircraft control, military tracking, targeting, interception, jamming and spoofing are outside the product scope.

## Architecture and requirements

- Keep the C++20 simulation core independent of Qt, rendering, file I/O and external data. Document units, coordinate systems and time bases. Feed PPI and the future Qt Quick 3D view from the same simulation state.
- Keep Qt objects and timers on the owning thread. Keep QML components focused on UI, presentation state and user input. Keep the provider, scenario and replay contracts versioned.
- Use [architecture](docs/ARCHITECTURE.md) for layer contracts and [engineering plan](docs/MASTER-ENGINEERING-PLAN.md) for P0–P11 sequencing and stage acceptance. Use [feature parity](docs/FEATURE-PARITY.md) for the authoritative feature inventory, individual acceptance evidence and remaining work.
- Validate at boundaries. Reject non-finite values, invalid enums, overflows and ambiguous identifiers. A rejected update must leave observable state unchanged. Limit untrusted file and dataset sizes before allocation.
- Use RAII, explicit dependencies and a consistent C++20 implementation on MSVC, GCC and Clang. Follow [code quality policy](docs/CODE_QUALITY_POLICY.md), `.editorconfig` and `.clang-format`. Avoid stale placeholder controls and preserve existing behavior unless the requirement changes it.

## Verification and workflow

1. Read this file and check the current revision, open PRs, CI and the development log before making changes.
2. Choose the next dependency-ready feature. Add focused regression cases for defects. Run relevant tests in Debug and Release with checks active under `NDEBUG`. Follow the [testing strategy](docs/TESTING-STRATEGY.md).
3. Update the feature matrix and [development log](docs/DEVELOPMENT-LOG.md) with source, test command, scope, exact revision or changeset, result and residual gaps. Use only Missing, Partial, Implemented, Verified or Blocked. Verified requires an executed acceptance test with evidence. A successful parent run does not verify a changed child revision.
4. Work on a dedicated branch and make focused Git commits. Use a draft PR against the correct parent in the PR stack and track required reviews and CI. Keep shared branch history intact. Use GitHub merge controls and never bypass protection. Meet the release acceptance checklist before publishing.
5. Follow the [security design](docs/SECURITY.md) and record dependency decisions in the [adoption matrix](docs/THIRD_PARTY_ADOPTION_MATRIX.md). Keep secrets, private source and undeclared licensed assets out of the public repository.
