#!/usr/bin/env python3
"""Install the generated mascot marks as per-app iOS AppIcon asset catalogs."""

import json
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets" / "app-icons"
APP_DIRS = sorted(ROOT.glob("[0-9][0-9]-*"))

ICON_SPECS = [
    ("AppIcon-60@2x.png", "iphone", "60x60", "2x", 120),
    ("AppIcon-60@3x.png", "iphone", "60x60", "3x", 180),
    ("AppIcon-76@2x.png", "ipad", "76x76", "2x", 152),
    ("AppIcon-83.5@2x.png", "ipad", "83.5x83.5", "2x", 167),
    ("AppIcon-1024.png", "ios-marketing", "1024x1024", "1x", 1024),
]

contents = {
    "images": [
        {"filename": filename, "idiom": idiom, "size": size, "scale": scale}
        for filename, idiom, size, scale, _ in ICON_SPECS
    ],
    "info": {"author": "xcode", "version": 1},
}

mascot_contents = {
    "images": [
        {
            "filename": "AppMascot.png",
            "idiom": "universal",
            "scale": "1x",
        }
    ],
    "info": {"author": "xcode", "version": 1},
}

installed = 0
for app_dir in APP_DIRS:
    slug = app_dir.name
    source = SOURCE / f"{slug}.png"
    if not source.exists():
        raise SystemExit(f"missing generated icon: {source}")
    icon_set = app_dir / "Assets.xcassets" / "AppIcon.appiconset"
    icon_set.mkdir(parents=True, exist_ok=True)
    (icon_set / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n", encoding="utf-8")
    for filename, _, _, _, pixels in ICON_SPECS:
        subprocess.run(
            ["sips", "-z", str(pixels), str(pixels), str(source), "--out", str(icon_set / filename)],
            check=True,
            capture_output=True,
        )
    mascot_set = app_dir / "Assets.xcassets" / "AppMascot.imageset"
    mascot_set.mkdir(parents=True, exist_ok=True)
    (mascot_set / "Contents.json").write_text(json.dumps(mascot_contents, indent=2) + "\n", encoding="utf-8")
    shutil.copy2(source, mascot_set / "AppMascot.png")
    installed += 1

print(f"installed {installed} AppIcon sets")
