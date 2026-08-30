#!/usr/bin/env python3
"""Audit all 44 apps for launch blockers (compile, metadata, icons, native entry)."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BROKEN_ENTRY = re.compile(r"WindowGroup\s*\{\s*\x01\(\)")
APP_DIRS = sorted(
    p for p in ROOT.iterdir() if p.is_dir() and re.match(r"^\d{2}-", p.name)
)


def main() -> int:
    errors: list[str] = []
    warnings: list[str] = []

    metadata = json.loads((ROOT / "release/app-store-metadata.json").read_text())
    meta_by_folder = {e["folder"]: e for e in metadata["apps"]}

    for app_dir in APP_DIRS:
        label = app_dir.name
        app_files = list(app_dir.glob("*App.swift"))
        if not app_files:
            errors.append(f"{label}: missing *App.swift")
            continue

        swift_files = list(app_dir.glob("**/*.swift"))
        joined = "\n".join(p.read_text(encoding="utf-8", errors="replace") for p in swift_files)

        if not re.search(r"@main\s+struct", joined):
            errors.append(f"{label}: no @main App struct")

        if BROKEN_ENTRY.search(joined):
            errors.append(f"{label}: broken WindowGroup native entry (\\x01())")

        if "dumbNativeEntry" not in joined:
            warnings.append(f"{label}: no dumbNativeEntry wired")

        icon = app_dir / "Assets.xcassets/AppIcon.appiconset/Contents.json"
        if not icon.exists():
            errors.append(f"{label}: missing AppIcon.appiconset")

        intents = list(app_dir.glob("*Intents.swift"))
        if not intents:
            warnings.append(f"{label}: no App Intents file")

        if label not in meta_by_folder:
            errors.append(f"{label}: missing app-store-metadata.json entry")
        else:
            entry = meta_by_folder[label]
            if entry.get("priority") == "HOLD":
                warnings.append(f"{label}: marked HOLD in store metadata")

    hold = [e["folder"] for e in metadata["apps"] if e.get("priority") == "HOLD"]
    ship = [e["folder"] for e in metadata["apps"] if e.get("priority") != "HOLD"]

    print(f"audited {len(APP_DIRS)} app folders")
    print(f"ship-ready metadata: {len(ship)} | HOLD: {len(hold)} ({', '.join(hold)})")

    if warnings:
        print(f"\n{len(warnings)} warning(s):")
        for w in warnings:
            print(f"  - {w}")

    if errors:
        print(f"\n{len(errors)} error(s):")
        for e in errors:
            print(f"  - {e}")
        return 1

    print("\nno blocking errors found")
    return 0


if __name__ == "__main__":
    sys.exit(main())
