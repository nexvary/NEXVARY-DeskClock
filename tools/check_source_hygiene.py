#!/usr/bin/env python3
"""AeroRadar source hygiene gate, using Python standard library only.

This is a lightweight regression check, not a substitute for the C++/Qt compiler,
unit tests, sanitizer runs, or real GUI tests.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIRS = ("apps", "core", "tests", "ui")
SOURCE_EXTENSIONS = {".h", ".hpp", ".c", ".cc", ".cpp", ".cxx", ".qml"}
CPP_EXTENSIONS = {".cc", ".cpp", ".cxx"}
CONFLICT_MARKER = re.compile(r"(?m)^(?:<<<<<<< |=======\s*$|>>>>>>> )")
CPP_MAIN = re.compile(r"(?m)^\s*int\s+main\s*\(")
AERO_TEST = re.compile(r"(?m)^\s*AERO_TEST\s*\(")
UNSAFE_SMOKE = re.compile(
    r"(?m)^\s*[^#\n]*(?:aeroradar_desktop|--smoke)[^\n]*\|\|\s*true\b"
)


def main() -> int:
    problems: list[str] = []
    checked = 0

    for name in SOURCE_DIRS:
        folder = ROOT / name
        if not folder.is_dir():
            problems.append(f"Missing expected source directory: {name}")
            continue

        for path in sorted(folder.rglob("*")):
            if not path.is_file() or path.suffix.lower() not in SOURCE_EXTENSIONS:
                continue
            checked += 1
            relative = path.relative_to(ROOT)
            raw = path.read_bytes()

            if b"\x00" in raw:
                problems.append(f"{relative}: embedded NUL byte")
                continue
            try:
                data = raw.decode("utf-8-sig")
            except UnicodeDecodeError:
                problems.append(f"{relative}: file is not valid UTF-8")
                continue

            if CONFLICT_MARKER.search(data):
                problems.append(f"{relative}: unresolved Git merge marker")

            if path.suffix.lower() in CPP_EXTENSIONS:
                count = len(CPP_MAIN.findall(data))
                if count > 1:
                    problems.append(f"{relative}: {count} definitions of main()")

            if relative.as_posix() == "tests/unit/SimulatorTests.cpp":
                count = len(AERO_TEST.findall(data))
                if count < 19:
                    problems.append(
                        f"{relative}: only {count} registered unit tests; "
                        "P0 baseline is 19"
                    )
                else:
                    print(f"Simulator unit test registrations: {count}")

    if checked == 0:
        problems.append("No source files found to check")

    ci = ROOT / ".github" / "workflows" / "ci.yml"
    if not ci.is_file():
        problems.append("Missing existing .github/workflows/ci.yml")
    else:
        content = ci.read_text(encoding="utf-8-sig")
        if UNSAFE_SMOKE.search(content):
            problems.append(
                ".github/workflows/ci.yml: GUI smoke errors are suppressed with || true"
            )
        if "--smoke" not in content:
            problems.append(".github/workflows/ci.yml: missing GUI startup smoke gate")

    print(f"Source hygiene scan: {checked} source files inspected")
    if problems:
        for problem in problems:
            print(f"FAIL: {problem}", file=sys.stderr)
        return 1
    print("PASS: no source hygiene regressions detected")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
