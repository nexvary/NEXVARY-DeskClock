# Security and data handling

Report vulnerabilities through the private channel in the repository [security policy](../SECURITY.md). Keep secrets and sensitive recordings out of Git, CI logs, issue reports and screenshots.

The desktop accepts the embedded scenario, bounded local v1/v2 synthetic JSON and optional screenshot output paths. The loader caps files at 256 KiB and 256 aircraft and validates input before swapping the active state. User-supplied labels render as plain text. The syntax parser is Qt JSON. Imported routes are capped at 64 waypoints per aircraft and checked for ordering, time bounds and representable horizontal velocity. Simulator construction rejects duplicate aircraft IDs, non-finite state and unsupported aircraft types. Steps reject non-finite durations and overflow before changing the state. The Qt adapter confines simulation mutation to the GUI thread.

Before exposing file or dataset imports, cap file size, record count, nesting depth and string length. Validate schema, version, units and numerical ranges before updating the active simulation. Write outputs atomically, preserve user files and keep configuration free of credentials. Log failures using bounded fields, with source labels and redaction appropriate to civil aviation data.

Archive an inventory of versioned runtime dependencies. Verify licenses and redistribution obligations for Qt modules, Visual C++ runtime, NSIS and assets. Scan support branches for vulnerable versions and run sanitizer and static-analysis gates. Review privacy, source terms and retention before accepting recorded or public civil data.
