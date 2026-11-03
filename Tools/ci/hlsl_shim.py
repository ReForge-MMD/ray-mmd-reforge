#!/usr/bin/env python3
"""Create an fxc-compilable copy of the MME shader tree.

MME uses proprietary annotations (CONTROLOBJECT, RENDERCOLORTARGET, ...) and
technique blocks that fxc does not understand. This shim copies only shader
and config text files, strips those annotations and technique blocks, and then
invokes fxc for one entry point at a time.

The shim is intentionally conservative: it checks HLSL syntax, macro
resolution and ps_3_0 resource/register limits, but it does not emulate MME
pass routing or render-target semantics. Those are covered by the static lint
and by the MMD smoke test.
"""

from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

SHADER_SUFFIXES = {".fx", ".fxsub", ".conf", ".inc", ".hlsl"}

# MME annotations that may appear without an angle-bracketed argument.
SIMPLE_ANNOTATIONS = (
    "TIME",
    "ELAPSEDTIME",
    "MOUSEPOSITION",
    "WORLD",
    "WORLDINVERSE",
    "WORLDVIEW",
    "WORLDVIEWPROJECTION",
    "VIEW",
    "VIEWINVERSE",
    "PROJECTION",
    "PROJECTIONINVERSE",
    "VIEWPROJECTION",
    "VIEWPROJECTIONINVERSE",
    "VIEWPORTPIXELSIZE",
    "MATERIALTEXTURE",
)

# MME annotations that are always followed by <...>.
BRACKETED_ANNOTATIONS = (
    "CONTROLOBJECT",
    "DIRECTION",
    "SPECULAR",
    "DIFFUSE",
    "AMBIENT",
    "TOONCOLOR",
    "SPECULARPOWER",
    "POSITION",
    "STANDARDSGLOBAL",
    "RENDERCOLORTARGET",
    "OFFSCREENRENDERTARGET",
    "RENDERDEPTHSTENCILTARGET",
    "TEXTUREVALUE",
)

SIMPLE_ANN_RE = re.compile(
    r":\s*(?:" + "|".join(SIMPLE_ANNOTATIONS) + r")\s*;",
    re.MULTILINE,
)

BRACKETED_ANN_RE = re.compile(
    r":\s*(?:" + "|".join(BRACKETED_ANNOTATIONS) + r")\s*<.*?>\s*;",
    re.DOTALL,
)

TEXTURE_ANN_RE = re.compile(
    r"(?i)(?:shared\s+)?texture\s+(\w+)\s*:\s*"
    r"(?:RENDERCOLORTARGET|OFFSCREENRENDERTARGET|RENDERDEPTHSTENCILTARGET)"
    r"\s*<.*?>\s*;",
    re.DOTALL,
)

STANDARDSGLOBAL_RE = re.compile(
    r"float\s+Script\s*:\s*STANDARDSGLOBAL\s*<.*?>\s*=\s*[^;]+;",
    re.DOTALL,
)


def strip_techniques(text: str) -> str:
    """Remove technique { ... } blocks, including nested braces."""
    out = []
    index = 0
    length = len(text)

    while index < length:
        # Technique declarations start a line; avoid matching the word in
        # comments such as "technique pipeline".
        match = re.search(r"^[ \t]*technique\b", text[index:], re.MULTILINE)
        if not match:
            out.append(text[index:])
            break

        start = index + match.start()
        out.append(text[index:start])

        brace_start = text.find("{", start)
        if brace_start == -1:
            index = start + len("technique")
            continue

        depth = 0
        cursor = brace_start
        in_string = False
        while cursor < length:
            char = text[cursor]
            if char == '"':
                in_string = not in_string
            elif not in_string:
                if char == "{":
                    depth += 1
                elif char == "}":
                    depth -= 1
                    if depth == 0:
                        cursor += 1
                        break
            cursor += 1

        index = cursor

    return "".join(out)


def shim_text(text: str) -> str:
    text = strip_techniques(text)
    text = STANDARDSGLOBAL_RE.sub("", text)
    text = TEXTURE_ANN_RE.sub(r"texture \1;", text)
    text = BRACKETED_ANN_RE.sub(";", text)
    text = SIMPLE_ANN_RE.sub(";", text)

    # D3D9 semantics.
    text = text.replace("SV_Position", "VPOS")
    text = text.replace("SV_Target", "COLOR0")
    text = text.replace("SV_Depth", "DEPTH0")
    return text


def copy_shader_tree(source_root: Path, destination_root: Path) -> None:
    skip_dirs = {".git", "ref-code", "ref-docs", "screenshots", "__pycache__"}
    for path in source_root.rglob("*"):
        if not path.is_file():
            continue
        if any(part in skip_dirs for part in path.parts):
            continue
        if path.suffix.lower() not in SHADER_SUFFIXES:
            continue

        relative = path.relative_to(source_root)
        target = destination_root / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(shim_text(path.read_text(encoding="utf-8", errors="replace")), encoding="utf-8")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", help="Entry file relative to the repository root")
    parser.add_argument("--entry", help="Entry point function name")
    parser.add_argument("--profile", default="ps_3_0", help="fxc target profile")
    parser.add_argument(
        "--job",
        action="append",
        default=[],
        metavar="SOURCE|ENTRY|PROFILE",
        help="Batch job; repeat to compile several entry points with one shim tree",
    )
    parser.add_argument("--fxc", required=True, help="Path to fxc.exe")
    parser.add_argument("--root", default=".", help="Repository root")
    parser.add_argument(
        "--set",
        action="append",
        default=[],
        metavar="NAME=VALUE",
        help="Override a #define in the shimmed config (repeatable)",
    )
    parser.add_argument("--keep", action="store_true", help="Keep the generated shim tree")
    return parser.parse_args()


def apply_overrides(root: Path, overrides: list[str]) -> None:
    for item in overrides:
        if "=" not in item:
            raise ValueError(f"invalid override (expected NAME=VALUE): {item}")
        name, value = item.split("=", 1)
        pattern = re.compile(rf"(?m)^(\s*#\s*define\s+{re.escape(name)}\s+).*$")
        applied = False
        for config in root.glob("*.conf"):
            text = config.read_text(encoding="utf-8", errors="replace")
            updated, count = pattern.subn(rf"\g<1>{value}", text)
            if count:
                config.write_text(updated, encoding="utf-8")
                applied = True
        if not applied:
            config = root / "ray.conf"
            text = config.read_text(encoding="utf-8", errors="replace")
            config.write_text(text + f"\n#define {name} {value}\n", encoding="utf-8")


def parse_jobs(args: argparse.Namespace) -> list[tuple[str, str, str]]:
    jobs: list[tuple[str, str, str]] = []

    for raw in args.job:
        parts = raw.split("|")
        if len(parts) != 3:
            raise ValueError(f"invalid job (expected SOURCE|ENTRY|PROFILE): {raw}")
        jobs.append((parts[0], parts[1], parts[2]))

    if args.source or args.entry:
        if not args.source or not args.entry:
            raise ValueError("--source and --entry must be used together")
        jobs.append((args.source, args.entry, args.profile))

    if not jobs:
        raise ValueError("no jobs specified; use --source/--entry or --job")

    return jobs


def main() -> int:
    args = parse_args()
    root = Path(args.root).resolve()
    fxc = Path(args.fxc)

    if not fxc.is_file():
        print(f"error: fxc not found: {fxc}", file=sys.stderr)
        return 2

    try:
        jobs = parse_jobs(args)
    except ValueError as error:
        print(f"error: {error}", file=sys.stderr)
        return 2

    for source, _, _ in jobs:
        if not (root / source).is_file():
            print(f"error: source not found: {source}", file=sys.stderr)
            return 2

    temp_root = Path(tempfile.mkdtemp(prefix="ray-mmd-shim-"))
    failures = 0
    try:
        copy_shader_tree(root, temp_root)
        apply_overrides(temp_root, args.set)

        for source, entry, profile in jobs:
            shim_source = temp_root / source
            output = temp_root / "out.cso"
            command = [
                str(fxc),
                "/nologo",
                "/T",
                profile,
                "/E",
                entry,
                "/I",
                str(temp_root),
                "/Fo",
                str(output),
                str(shim_source),
            ]
            print(f"=== {source} :: {entry} ({profile}) ===")
            result = subprocess.run(command, capture_output=True, text=True)
            if result.returncode == 0:
                print("ok")
                continue

            failures += 1
            print("failed")
            if result.stdout:
                print(result.stdout.strip(), file=sys.stderr)
            if result.stderr:
                print(result.stderr.strip(), file=sys.stderr)

        return 1 if failures else 0
    finally:
        if args.keep:
            print(f"shim tree kept at {temp_root}")
        else:
            shutil.rmtree(temp_root, ignore_errors=True)


if __name__ == "__main__":
    raise SystemExit(main())
