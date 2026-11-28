# Testing strategy

Build and run tests separately for Debug and Release:

```sh
cmake -S . -B build-debug -DCMAKE_BUILD_TYPE=Debug -DBUILD_TESTING=ON
cmake --build build-debug --config Debug --parallel
ctest --test-dir build-debug -C Debug --no-tests=error --output-on-failure
cmake -S . -B build-release -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=ON
cmake --build build-release --config Release --parallel
ctest --test-dir build-release -C Release --no-tests=error --output-on-failure
python3 tools/check_source_hygiene.py
```

Set `-DAERORADAR_BUILD_DESKTOP=ON` in both configurations for Qt work. Use separate build directories for compiler variants. Core checks use `AERO_REQUIRE`, which remains active with `NDEBUG`. Desktop CTest adds Qt model integration and timed offscreen application startup with QML warning checks. A rendered window and interactive tests are distinct acceptance checks.

| Area | Required evidence |
| --- | --- |
| Core | Numerical fixtures, input validation, failure atomicity, reset and deterministic control transitions. |
| Desktop | Model signal tests, QML keyboard and pointer interactions, screen scaling, localization and genuine images from a running application. |
| Data and replay | Positive and negative schemas, resource caps, migrations, round-trip data and replay equivalence. |
| Performance | Document hardware, build mode, dataset size, frame and tick timings, memory and long-running stability. |
| Security | Compiler warnings, static analysis, sanitizer runs, dependency inventory and malformed-input regression fixtures. |
| Packaging | Launch portable package without Qt SDK in PATH, install, upgrade, relaunch and uninstall while preserving unrelated files. Repeat on supported platforms. |

Record revision, OS, compiler, Qt version, build mode, command and test result. Record the CI run and artifact links where available. Use [feature parity](FEATURE-PARITY.md) to associate evidence with each requirement.
