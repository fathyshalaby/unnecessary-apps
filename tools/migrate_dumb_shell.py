#!/usr/bin/env python3
"""Migrate DumbShell layouts to AppCanvas + AppHeader with sticky bottom CTAs."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

SKIP = {
    ROOT / "retired/45-lab-report-translator/LabTranslatorApp.swift",
    ROOT / "shared/DumbKit.swift",
}


def find_matching_paren(text: str, open_index: int) -> int:
    depth = 0
    i = open_index
    while i < len(text):
        if text[i] == "(":
            depth += 1
        elif text[i] == ")":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    raise ValueError(f"No matching paren at {open_index}")


def find_matching_brace(text: str, open_index: int) -> int:
    depth = 0
    i = open_index
    while i < len(text):
        c = text[i]
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    raise ValueError(f"No matching brace at {open_index}")


def extract_string_param(block: str, name: str) -> str | None:
    m = re.search(rf'{name}:\s*"((?:\\.|[^"\\])*)"', block)
    return m.group(1) if m else None


def extract_experience(block: str) -> str | None:
    m = re.search(r"experience:\s*(\.[a-zA-Z]+)", block)
    return m.group(1) if m else None


def extract_view_call(content: str, name: str, start: int = 0) -> tuple[str, int, int] | None:
    """Extract a View call like DumbAction(...) including chained modifiers."""
    pattern = rf"\n(\s*){name}\("
    m = re.search(pattern, content[start:])
    if not m:
        return None
    abs_start = start + m.start() + 1  # skip leading newline
    paren_start = content.index("(", abs_start)
    paren_end = find_matching_paren(content, paren_start)
    end = paren_end + 1
    # Chain modifiers: .disabled(...), .accessibilityIdentifier(...), etc.
    while True:
        mod = re.match(r"\s*(\.\w+(?:\([^)]*\)|\{[^}]*\}))", content[end:])
        if not mod:
            break
        end += len(mod.group(0))
    block = content[abs_start:end].strip()
    return block, abs_start, end


def migrate_file(path: Path) -> bool:
    text = path.read_text()
    if "DumbShell(" not in text:
        return False

    shell_idx = text.index("DumbShell(")
    paren_start = shell_idx + len("DumbShell")
    paren_end = find_matching_paren(text, paren_start)

    header_block = text[shell_idx : paren_end + 1]
    eyebrow = extract_string_param(header_block, "eyebrow")
    title = extract_string_param(header_block, "title")
    subtitle = extract_string_param(header_block, "subtitle")
    experience = extract_experience(header_block)
    if not all([eyebrow, title, subtitle]):
        print(f"SKIP (missing params): {path}")
        return False

    brace_open = text.index("{", paren_end)
    brace_close = find_matching_brace(text, brace_open)
    content = text[brace_open + 1 : brace_close]
    after_shell = text[brace_close + 1 :]

    action = extract_view_call(content, "DumbAction")
    result = extract_view_call(content, "DumbResult")

    new_content = content
    bottom_parts: list[str] = []
    if action:
        bottom_parts.append(action[0])
        new_content = new_content[: action[1]] + new_content[action[2] :]
    if result:
        bottom_parts.append(result[0])
        # Re-find result in trimmed content
        result2 = extract_view_call(new_content, "DumbResult")
        if result2:
            new_content = new_content[: result2[1]] + new_content[result2[2] :]

    new_content = new_content.strip("\n")
    # Normalize blank lines
    new_content = re.sub(r"\n{3,}", "\n\n", new_content)

    exp_param = f", experience: {experience}" if experience else ""
    indent = "        "
    inner = indent + "    "

    lines = [
        f"{indent}AppCanvas(accent: accent{exp_param}) {{",
        f"{inner}AppHeader(",
        f'{inner}    eyebrow: "{eyebrow}",',
        f'{inner}    title: "{title}",',
        f'{inner}    subtitle: "{subtitle}",',
        f"{inner}    accent: accent",
        f"{inner})",
        "",
    ]
    for line in new_content.splitlines():
        if line.strip():
            lines.append(f"{inner}{line.strip()}")
        else:
            lines.append("")

    if bottom_parts:
        lines.append(f"{indent}}} bottomBar: {{")
        for part in bottom_parts:
            for pline in part.splitlines():
                lines.append(f"{inner}{pline.strip()}")
            lines.append("")
        lines.append(f"{indent}}}")
    else:
        lines.append(f"{indent}}}")

    replacement = "\n".join(lines) + after_shell
    new_text = text[:shell_idx] + replacement
    path.write_text(new_text)
    print(f"MIGRATED: {path.relative_to(ROOT)}")
    return True


def main() -> int:
    paths = sorted(ROOT.rglob("*.swift"))
    count = 0
    for path in paths:
        if path in SKIP:
            continue
        if migrate_file(path):
            count += 1
    print(f"\nDone: {count} files migrated")
    return 0


if __name__ == "__main__":
    sys.exit(main())
