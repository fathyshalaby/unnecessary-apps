#!/usr/bin/env python3
"""Repair WindowGroup lines broken by wire_native_schemes.py."""

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BROKEN = re.compile(
    r'WindowGroup\s*\{\s*\x01\(\)\.dumbNativeEntry\(scheme:\s*"([^"]+)"\)\s*\{\s*_,\s*_\s+in\s*\}\s*\}'
)


def view_name(app_path: Path, text: str) -> str | None:
    for source in (text, *(p.read_text(encoding="utf-8") for p in app_path.parent.glob("*.swift") if p != app_path)):
        if match := re.search(r"struct (\w+View)\s*:", source):
            return match.group(1)
        if match := re.search(r"struct (\w+ContentView)\s*:", source):
            return match.group(1)
    return None


def main() -> None:
    fixed = 0
    for path in ROOT.glob("**/*App.swift"):
        if "retired" in str(path):
            continue
        text = path.read_text(encoding="utf-8")
        if not BROKEN.search(text) and "dumbNativeEntry" not in text:
            continue
        if not BROKEN.search(text):
            continue
        name = view_name(path, text)
        if not name:
            print(f"skip {path} — no view name")
            continue
        scheme = BROKEN.search(text).group(1)
        replacement = f'WindowGroup {{ {name}().dumbNativeEntry(scheme: "{scheme}") {{ _, _ in }} }}'
        text = BROKEN.sub(replacement, text, count=1)
        if "import DumbKit" not in text:
            text = text.replace("import SwiftUI", "import SwiftUI\nimport DumbKit", 1)
        path.write_text(text, encoding="utf-8")
        fixed += 1
        print(f"fixed {path.relative_to(ROOT)} -> {name}")
    print(f"done — {fixed} files")


if __name__ == "__main__":
    main()
