#!/usr/bin/env python3
"""Detect upstream package drift for the Bazzite-SDX image.

The script compares the package versions recorded in the current ``testing``
release notes against:

* the newest linux-surface packages published for Fedora 45, and
* the newest SDX Control Centre release tag.

It writes ``drift=true|false`` to ``$GITHUB_OUTPUT`` so the caller can decide
whether to run a testing build. Network or parse failures are reported as
warnings and treated as "no drift" so a transient upstream outage cannot start
a rebuild loop.
"""

from __future__ import annotations

import functools
import os
import re
import subprocess
import sys
import urllib.request
import xml.etree.ElementTree as ET

REPO_BASE = "https://pkg.surfacelinux.com/fedora/f45"
SDX_REPO = "https://github.com/NexGen-3D-Printing/SDX-Control-Centre.git"
NS = {"c": "http://linux.duke.edu/metadata/common"}
REPO_NS = {"r": "http://linux.duke.edu/metadata/repo"}

# rpm package name -> label used in the generated release notes
PACKAGES = {
    "kernel-surface": "Surface kernel",
    "iptsd": "iptsd",
    "libwacom-surface": "libwacom-surface",
    "surface-control": "surface-control",
    "surface-dtx-daemon": "surface-dtx-daemon",
}
SDX_LABEL = "SDX Control Centre"


def warn(message: str) -> None:
    print(f"::warning::{message}")


def emit(drift: bool, lines: list[str]) -> None:
    summary = "\n".join(lines)
    print(summary)
    summary_file = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary_file:
        with open(summary_file, "a", encoding="utf-8") as handle:
            handle.write("### Upstream package check\n\n")
            for line in lines:
                handle.write(f"- {line}\n")
            handle.write("\n")
    output_file = os.environ.get("GITHUB_OUTPUT")
    if output_file:
        with open(output_file, "a", encoding="utf-8") as handle:
            handle.write(f"drift={'true' if drift else 'false'}\n")


def rpmvercmp(left: str, right: str) -> int:
    """Small rpm-style version comparison (enough for these packages)."""
    if left == right:
        return 0
    i = j = 0
    la, lb = len(left), len(right)
    while i < la or j < lb:
        while i < la and not left[i].isalnum():
            i += 1
        while j < lb and not right[j].isalnum():
            j += 1
        if i >= la or j >= lb:
            break
        start_i, start_j = i, j
        while i < la and left[i].isalnum():
            i += 1
        while j < lb and right[j].isalnum():
            j += 1
        seg_a, seg_b = left[start_i:i], right[start_j:j]
        if seg_a.isdigit() and seg_b.isdigit():
            seg_a = seg_a.lstrip("0") or "0"
            seg_b = seg_b.lstrip("0") or "0"
            if len(seg_a) != len(seg_b):
                return 1 if len(seg_a) > len(seg_b) else -1
            if seg_a != seg_b:
                return 1 if seg_a > seg_b else -1
        elif seg_a.isdigit() != seg_b.isdigit():
            return 1 if seg_a.isdigit() else -1
        elif seg_a != seg_b:
            return 1 if seg_a > seg_b else -1
    remaining_a = left[i:].strip("~^+.-_")
    remaining_b = right[j:].strip("~^+.-_")
    if remaining_a == remaining_b:
        return 0
    return 1 if remaining_a > remaining_b else -1


def highest(versions: list[str]) -> str:
    return max(versions, key=functools.cmp_to_key(rpmvercmp))


def fetch(url: str) -> bytes:
    with urllib.request.urlopen(url, timeout=90) as response:
        return response.read()


def decompress_zstd(data: bytes) -> bytes:
    try:
        result = subprocess.run(
            ["zstd", "-dc"], input=data, capture_output=True, check=False
        )
        if result.returncode == 0:
            return result.stdout
        raise RuntimeError(result.stderr.decode("utf-8", "replace").strip())
    except FileNotFoundError:
        pass
    try:
        import zstandard  # type: ignore

        return zstandard.ZstdDecompressor().decompressobj().decompress(data)
    except Exception as exc:  # noqa: BLE001 - fall through to stdlib
        last_error = exc
    try:
        from compression import zstd as stdlib_zstd  # type: ignore

        return stdlib_zstd.decompress(data)
    except Exception as exc:  # noqa: BLE001
        raise RuntimeError(f"no usable zstd decompressor: {last_error}; {exc}") from exc


def upstream_packages() -> dict[str, str]:
    repomd = ET.fromstring(fetch(f"{REPO_BASE}/repodata/repomd.xml"))
    primary_href = None
    for data in repomd.findall("r:data", REPO_NS):
        if data.get("type") == "primary":
            location = data.find("r:location", REPO_NS)
            if location is not None:
                primary_href = location.get("href")
            break
    if not primary_href:
        raise RuntimeError("primary metadata not listed in repomd.xml")

    primary = ET.fromstring(decompress_zstd(fetch(f"{REPO_BASE}/{primary_href}")))
    found: dict[str, list[str]] = {}
    for package in primary.findall("c:package", NS):
        name = package.findtext("c:name", namespaces=NS)
        if name not in PACKAGES:
            continue
        version = package.find("c:version", NS)
        if version is None:
            continue
        found.setdefault(name, []).append(
            f'{version.get("ver")}-{version.get("rel")}'
        )
    return {name: highest(versions) for name, versions in found.items()}


def upstream_sdx() -> str:
    result = subprocess.run(
        ["git", "ls-remote", "--tags", "--refs", SDX_REPO, "v*"],
        capture_output=True,
        text=True,
        check=True,
    )
    tags = [
        line.split("refs/tags/", 1)[1].strip()
        for line in result.stdout.splitlines()
        if "refs/tags/" in line
    ]
    if not tags:
        raise RuntimeError("no SDX Control Centre tags found")

    def tag_key(tag: str) -> tuple[int, ...]:
        return tuple(int(part) for part in re.findall(r"\d+", tag))

    return max(tags, key=tag_key).lstrip("v")


def recorded_versions() -> dict[str, str]:
    result = subprocess.run(
        ["gh", "release", "view", "testing", "--json", "body", "-q", ".body"],
        capture_output=True,
        text=True,
        check=True,
    )
    body = result.stdout
    recorded: dict[str, str] = {}
    for label in [*PACKAGES.values(), SDX_LABEL]:
        match = re.search(
            r"\*\*" + re.escape(label) + r":\*\*\s*([^\n]+)", body
        )
        if match:
            recorded[label] = match.group(1).strip().strip("`").strip()
    return recorded


def main() -> int:
    lines: list[str] = []

    try:
        recorded = recorded_versions()
    except Exception as exc:  # noqa: BLE001
        warn(f"could not read the testing release notes: {exc}")
        recorded = {}

    try:
        upstream = upstream_packages()
        sdx_upstream = upstream_sdx()
    except Exception as exc:  # noqa: BLE001
        warn(f"could not read upstream versions: {exc}")
        emit(False, ["upstream check failed; not triggering a build"])
        return 0

    drift = False
    for rpm_name, label in PACKAGES.items():
        newest = upstream.get(rpm_name)
        built = recorded.get(label)
        if not newest:
            lines.append(f"{label}: not found in the upstream repository")
            continue
        if built is None or built == "unknown":
            lines.append(f"{label}: not recorded yet (upstream {newest})")
            continue
        if built != newest:
            drift = True
            lines.append(f"CHANGED {label}: built {built} -> upstream {newest}")
        else:
            lines.append(f"ok {label}: {built}")

    built_sdx = recorded.get(SDX_LABEL)
    if built_sdx is None or built_sdx == "unknown":
        lines.append(f"{SDX_LABEL}: not recorded yet (upstream {sdx_upstream})")
    elif built_sdx != sdx_upstream:
        drift = True
        lines.append(f"CHANGED {SDX_LABEL}: built {built_sdx} -> upstream {sdx_upstream}")
    else:
        lines.append(f"ok {SDX_LABEL}: {built_sdx}")

    lines.append("RESULT: rebuild required" if drift else "RESULT: up to date")
    emit(drift, lines)
    return 0


if __name__ == "__main__":
    sys.exit(main())
