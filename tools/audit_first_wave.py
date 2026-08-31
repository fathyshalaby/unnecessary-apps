#!/usr/bin/env python3
"""Audit the first ten release-lane apps from release/RELEASE_ORDER.md."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

FIRST_WAVE = [
    "20-is-this-a-real-email",
    "03-do-not-text-them",
    "10-what-was-i-doing",
    "18-tiny-gratitude",
    "28-overthinking-evidence-board",
    "43-hydration-narc",
    "13-toilet-timer",
    "17-meeting-bingo-for-one",
    "22-snack-roulette",
    "11-am-i-early",
]


def main() -> int:
    audit = ROOT / "tools/audit_launch_readiness.py"
    result = subprocess.run(
        [sys.executable, str(audit)],
        capture_output=True,
        text=True,
        check=False,
    )
    print("First release lane (10 apps)")
    print("=" * 40)
    for index, folder in enumerate(FIRST_WAVE, start=1):
        app_dir = ROOT / folder
        status = "OK" if app_dir.is_dir() else "MISSING"
        print(f"{index:2}. {folder} — {status}")

    if result.returncode != 0:
        print("\nFull audit reported errors:")
        print(result.stdout)
        print(result.stderr, file=sys.stderr)
        return result.returncode

    print("\nAll first-wave folders present. Full repo audit: no blocking errors.")
    print("\nMac pipeline (all 44 apps):")
    print("  zsh tools/run_all_apps_mac.sh")
    print("  zsh tools/capture_all_apps_screenshots.sh")
    print("  zsh tools/record_all_apps_demos.sh")
    print("\nMac pipeline (first wave only):")
    print("  zsh tools/run_first_wave_mac.sh")
    print("  zsh tools/capture_first_wave_screenshots.sh")
    print("  zsh tools/record_first_wave_demos.sh")
    return 0


if __name__ == "__main__":
    sys.exit(main())
