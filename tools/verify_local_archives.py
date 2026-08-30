#!/usr/bin/env python3
"""Verify every unsigned local Release archive against the metadata manifest."""

from __future__ import annotations

import json
import plistlib
import sys
from pathlib import Path


def fail(message: str) -> None:
    raise SystemExit(f"archive verification failed: {message}")


def main() -> int:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".")
    archive_dir = Path(sys.argv[2]) if len(sys.argv) > 2 else root / "build/local-archives"
    metadata = json.loads((root / "release/app-store-metadata.json").read_text())
    expected = {entry["number"]: entry for entry in metadata["apps"]}
    manifest_path = archive_dir / "archive-manifest.tsv"
    rows = [line.split("\t") for line in manifest_path.read_text().splitlines() if line.strip()]
    expected_count = len(expected)
    if len(rows) != expected_count:
        fail(f"expected {expected_count} archive rows, found {len(rows)}")

    for scheme, version, build in rows:
        if not scheme.startswith("App") or not scheme[3:5].isdigit():
            fail(f"invalid scheme row: {scheme}")
        number = int(scheme[3:5])
        entry = expected.get(number)
        if entry is None:
            fail(f"archive row has no metadata entry: {scheme}")
        archive = archive_dir / f"{scheme}.xcarchive"
        products = list((archive / "Products/Applications").glob("*.app"))
        if len(products) != 1:
            fail(f"{scheme} has {len(products)} archived application products")
        info_path = products[0] / "Info.plist"
        info = plistlib.loads(info_path.read_bytes())
        checks = {
            "bundle ID": (info.get("CFBundleIdentifier"), entry["bundle_id"]),
            "marketing version": (info.get("CFBundleShortVersionString"), version),
            "build": (str(info.get("CFBundleVersion")), build),
            "encryption flag": (info.get("ITSAppUsesNonExemptEncryption"), False),
        }
        for label, (actual, wanted) in checks.items():
            if actual != wanted:
                fail(f"{scheme} {label}: expected {wanted!r}, found {actual!r}")

    print(f"verified {len(rows)} unsigned Release archives")
    print("bundle IDs, archived version/build values, and non-exempt-encryption flags match the manifest")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
