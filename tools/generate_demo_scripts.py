#!/usr/bin/env python3
"""Generate release/ALL_APPS_DEMO_SCRIPTS.md from app-store metadata."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "config/app-manifest.json"
OUT = ROOT / "release/ALL_APPS_DEMO_SCRIPTS.md"


def main() -> None:
    apps = json.loads(MANIFEST.read_text(encoding="utf-8"))["apps"]
    lines = [
        "# All apps — demo scripts",
        "",
        "30–45 second screen recordings for all 44 active apps. Run on Mac:",
        "",
        "```bash",
        "python3 tools/generate_app_manifest.py",
        "python3 tools/generate_demo_scripts.py",
        "zsh tools/record_all_apps_demos.sh",
        "```",
        "",
        "The recorder launches each app, starts a simulator clip, prints the",
        "App Review path below, and waits for Enter when your take is done.",
        "",
        "Output: `release/demos/all-apps/NN-slug.mp4`",
        "",
        "Use harmless sample text only. Launch from Springboard so the status",
        "bar has no previous-app back label.",
        "",
        "Apps marked **HOLD** (38, 40) are documented for completeness but stay",
        "out of the first public App Store cohort per `release/RELEASE_ORDER.md`.",
        "",
        "---",
        "",
    ]

    for app in apps:
        hold = " **[HOLD]**" if app["hold"] else ""
        filename = f"{app['number']:02d}-{app['slug']}.mp4"
        lines.extend(
            [
                f"## {app['number']:02d}. {app['name']}{hold}",
                "",
                f"**File:** `{filename}` · **Scheme:** `{app['scheme']}`",
                "",
                "**Demo path (from App Review notes):**",
                "",
                app["review_notes"],
                "",
                "---",
                "",
            ]
        )

    lines.extend(
        [
            "## Post-production",
            "",
            "- Trim to under 45 seconds each.",
            "- No real private emails, health data, or contact info.",
            "- Export H.264 MP4.",
            "- Physical device clips are fine for Live Activity, camera, and HealthKit demos.",
            "",
        ]
    )

    OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"wrote {OUT} ({len(apps)} apps)")


if __name__ == "__main__":
    main()
