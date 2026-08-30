#!/usr/bin/env python3
"""Validate the Apple App Store metadata manifest before a release handoff."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


EXPECTED_COUNT = 44
BUNDLE_PATTERN = re.compile(r"^corp\.unecessary\.app\d{2}[a-z0-9]+$")


def fail(message: str) -> None:
    raise SystemExit(f"metadata validation failed: {message}")


def main() -> int:
    manifest_path = Path(sys.argv[1] if len(sys.argv) > 1 else "release/app-store-metadata.json")
    data = json.loads(manifest_path.read_text())
    public_urls = data.get("public_urls", {})
    if public_urls.get("support", "").startswith("REPLACE_") or public_urls.get("privacy", "").startswith("REPLACE_"):
        print("warning: public support/privacy URLs are still placeholders")
    apps = data.get("apps")
    if not isinstance(apps, list) or len(apps) != EXPECTED_COUNT:
        fail(f"expected {EXPECTED_COUNT} app entries")

    numbers = []
    bundle_ids = []
    for app in apps:
        number = app.get("number")
        name = app.get("name", "")
        subtitle = app.get("subtitle", "")
        keywords = app.get("keywords", "")
        bundle_id = app.get("bundle_id", "")
        description = app.get("description", "")
        review_notes = app.get("review_notes", "")

        if not isinstance(number, int) or number < 1 or number > EXPECTED_COUNT:
            fail(f"invalid app number: {number!r}")
        numbers.append(number)
        if not 2 <= len(name) <= 30:
            fail(f"app {number} name length is {len(name)}, expected 2..30")
        if len(subtitle) > 30:
            fail(f"app {number} subtitle is {len(subtitle)} characters")
        if len(keywords.encode("utf-8")) > 100:
            fail(f"app {number} keywords are {len(keywords.encode('utf-8'))} bytes")
        if not BUNDLE_PATTERN.fullmatch(bundle_id):
            fail(f"app {number} has invalid bundle ID: {bundle_id}")
        if len(description) > 4000:
            fail(f"app {number} description is over 4000 characters")
        if not review_notes:
            fail(f"app {number} is missing review notes")
        bundle_ids.append(bundle_id)

    if sorted(numbers) != list(range(1, EXPECTED_COUNT + 1)):
        fail("app numbers are not exactly 1..44")
    if len(set(bundle_ids)) != EXPECTED_COUNT:
        fail("bundle IDs are not unique")

    project_path = manifest_path.parent.parent / "UnnecessaryApps.xcodeproj" / "project.pbxproj"
    project_text = project_path.read_text()
    project_bundle_ids = set(re.findall(r"PRODUCT_BUNDLE_IDENTIFIER = (corp\.unecessary\.app[0-9]+[a-z0-9]+);", project_text))
    if set(bundle_ids) != project_bundle_ids:
        fail("manifest bundle IDs do not exactly match the Xcode project")

    print(f"validated {len(apps)} Apple App Store metadata entries")
    print("all names, subtitles, keyword byte lengths, descriptions, review notes, and project bundle IDs are valid")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
