#!/usr/bin/env python3
"""Detect upstream drift for Bazzite-SDX stable, testing, and unstable channels.

Compares versions recorded in release notes against current upstreams:

* Bazzite-DX base image (stable/testing/unstable) version + digest
* linux-surface packages published for Fedora 45
* newest SDX Control Centre release tag
* Testing/Unstable extras: kernel-surface-devel (linux-surface repo), make, gcc

Outputs (to $GITHUB_OUTPUT):
  stable_drift=true|false
  testing_drift=true|false
  unstable_drift=true|false
  stable_bazzite_version=<version>
  testing_bazzite_version=<version>
  unstable_bazzite_version=<version>

Network or parse failures are reported as warnings and treated as "no drift"
for that channel so a transient upstream outage cannot start a rebuild loop.
"""

from __future__ import annotations

import functools
import json
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

BAZZITE_IMAGES = {
    "stable": "ghcr.io/ublue-os/bazzite-dx:stable",
    "testing": "ghcr.io/ublue-os/bazzite-dx:testing",
    "unstable": "ghcr.io/ublue-os/bazzite-dx:unstable",
}

# rpm package name -> label used in the generated release notes
PACKAGES = {
    "kernel-surface": "Surface kernel",
    "iptsd": "iptsd",
    "libwacom-surface": "libwacom-surface",
    "surface-control": "surface-control",
    "surface-dtx-daemon": "surface-dtx-daemon",
}
# Extra packages tracked for Testing and Unstable channels (issue #2).
EXTRA_SURFACE_PACKAGES = {
    "kernel-surface-devel": "kernel-surface-devel",
}
EXTRA_FEDORA_PACKAGES = {
    "make": "make",
    "gcc": "gcc",
}
SDX_LABEL = "SDX Control Centre"
BAZZITE_VERSION_LABEL = "Bazzite version"
BAZZITE_DIGEST_LABEL = "Bazzite digest"


def warn(message: str) -> None:
    print(f"::warning::{message}")


def emit(
    stable_drift: bool,
    testing_drift: bool,
    unstable_drift: bool,
    lines: list[str],
    stable_bazzite_version: str = "",
    testing_bazzite_version: str = "",
    unstable_bazzite_version: str = "",
) -> None:
    summary = "\n".join(lines)
    print(summary)
    summary_file = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary_file:
        with open(summary_file, "a", encoding="utf-8") as handle:
            handle.write("### Upstream drift check\n\n")
            for line in lines:
                handle.write(f"- {line}\n")
            handle.write("\n")
    output_file = os.environ.get("GITHUB_OUTPUT")
    if output_file:
        with open(output_file, "a", encoding="utf-8") as handle:
            handle.write(f"stable_drift={'true' if stable_drift else 'false'}\n")
            handle.write(f"testing_drift={'true' if testing_drift else 'false'}\n")
            handle.write(f"unstable_drift={'true' if unstable_drift else 'false'}\n")
            handle.write(
                f"drift={'true' if (stable_drift or testing_drift or unstable_drift) else 'false'}\n"
            )
            if stable_bazzite_version:
                handle.write(f"stable_bazzite_version={stable_bazzite_version}\n")
            if testing_bazzite_version:
                handle.write(f"testing_bazzite_version={testing_bazzite_version}\n")
            if unstable_bazzite_version:
                handle.write(f"unstable_bazzite_version={unstable_bazzite_version}\n")


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
    wanted = {**PACKAGES, **EXTRA_SURFACE_PACKAGES}
    found: dict[str, list[str]] = {}
    for package in primary.findall("c:package", NS):
        name = package.findtext("c:name", namespaces=NS)
        if name not in wanted:
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


def upstream_fedora_packages_from_base(channel: str) -> dict[str, str]:
    """Query Fedora package versions from the Bazzite-DX base image for a channel."""
    image = BAZZITE_IMAGES[channel]
    packages = list(EXTRA_FEDORA_PACKAGES.keys())
    if not packages:
        return {}
    query = " ".join(packages)
    cmd_fmt = " ".join([f"{p}=$(rpm -q {p} --qf '%{{VERSION}}-%{{RELEASE}}' 2>/dev/null || echo unknown)" for p in packages])
    script = f"{cmd_fmt}; " + " ".join([f'echo "{p}=${{{p}}}"' for p in packages])
    for runner in (["docker", "run", "--rm", "--entrypoint", "/bin/sh", f"{image}", "-lc", script],
                   ["podman", "run", "--rm", "--entrypoint", "/bin/sh", f"{image}", "-lc", script]):
        try:
            result = subprocess.run(runner, capture_output=True, text=True, check=False, timeout=300)
        except FileNotFoundError:
            continue
        except Exception as exc:  # noqa: BLE001
            warn(f"could not query {image} for fedora packages via {runner[0]}: {exc}")
            continue
        if result.returncode != 0:
            warn(f"{runner[0]} query for {image} failed: {result.stderr.strip()[:200]}")
            continue
        versions: dict[str, str] = {}
        for line in result.stdout.splitlines():
            if "=" in line:
                k, v = line.split("=", 1)
                k, v = k.strip(), v.strip()
                if k in EXTRA_FEDORA_PACKAGES and v and v != "unknown":
                    versions[k] = v
        return versions
    warn(f"no container runtime available to query Fedora packages from {image}")
    return {}


def upstream_bazzite(channel: str) -> dict[str, str]:
    image = BAZZITE_IMAGES[channel]
    # Prefer skopeo (available on ubuntu runners and in containers)
    try:
        result = subprocess.run(
            ["skopeo", "inspect", f"docker://{image}"],
            capture_output=True,
            text=True,
            check=True,
            timeout=120,
        )
        data = json.loads(result.stdout)
        labels = data.get("Labels") or {}
        version = (
            labels.get("org.opencontainers.image.version")
            or labels.get("version")
            or ""
        ).strip()
        digest = (data.get("Digest") or "").strip()
        return {"version": version, "digest": digest}
    except FileNotFoundError:
        pass
    except Exception as exc:  # noqa: BLE001
        raise RuntimeError(f"skopeo inspect failed for {image}: {exc}") from exc

    # Fallback: podman inspect (if image is local/pullable)
    result = subprocess.run(
        ["podman", "pull", "--quiet", image],
        capture_output=True,
        text=True,
        check=False,
        timeout=300,
    )
    if result.returncode != 0:
        raise RuntimeError(f"cannot inspect {image}: skopeo missing and podman pull failed")
    inspect = subprocess.run(
        ["podman", "inspect", image, "--format", "{{json .}}"],
        capture_output=True,
        text=True,
        check=True,
        timeout=60,
    )
    data = json.loads(inspect.stdout)
    labels = data.get("Labels") or {}
    return {
        "version": (labels.get("org.opencontainers.image.version") or "").strip(),
        "digest": (data.get("Digest") or "").strip(),
    }


def recorded_versions(release_tag: str) -> dict[str, str]:
    result = subprocess.run(
        ["gh", "release", "view", release_tag, "--json", "body", "-q", ".body"],
        capture_output=True,
        text=True,
        check=True,
    )
    body = result.stdout
    recorded: dict[str, str] = {}
    labels = [
        *PACKAGES.values(),
        *EXTRA_SURFACE_PACKAGES.values(),
        *EXTRA_FEDORA_PACKAGES.values(),
        SDX_LABEL,
        BAZZITE_VERSION_LABEL,
        BAZZITE_DIGEST_LABEL,
    ]
    for label in labels:
        match = re.search(
            r"\*\*" + re.escape(label) + r":\*\*\s*([^\n]+)", body
        )
        if match:
            recorded[label] = match.group(1).strip().strip("`").strip()
    return recorded


def recorded_versions_for(channel: str) -> dict[str, str]:
    tags = [channel]
    if channel == "stable":
        tags.append("latest")  # migration fallback
    last_exc: Exception | None = None
    for tag in tags:
        try:
            return recorded_versions(tag)
        except Exception as exc:  # noqa: BLE001
            last_exc = exc
    if last_exc:
        raise last_exc
    return {}


def compare_common(
    channel: str,
    recorded: dict[str, str],
    upstream: dict[str, str],
    sdx_upstream: str,
) -> tuple[bool, list[str]]:
    drift = False
    lines: list[str] = []
    for rpm_name, label in PACKAGES.items():
        newest = upstream.get(rpm_name)
        built = recorded.get(label)
        if not newest:
            lines.append(f"[{channel}] {label}: not found in upstream repository")
            continue
        if built is None or built == "unknown":
            lines.append(f"[{channel}] {label}: not recorded yet (upstream {newest})")
            continue
        if built != newest:
            drift = True
            lines.append(f"[{channel}] CHANGED {label}: built {built} -> upstream {newest}")
        else:
            lines.append(f"[{channel}] ok {label}: {built}")

    built_sdx = recorded.get(SDX_LABEL)
    if built_sdx is None or built_sdx == "unknown":
        lines.append(f"[{channel}] {SDX_LABEL}: not recorded yet (upstream {sdx_upstream})")
    elif built_sdx != sdx_upstream:
        drift = True
        lines.append(
            f"[{channel}] CHANGED {SDX_LABEL}: built {built_sdx} -> upstream {sdx_upstream}"
        )
    else:
        lines.append(f"[{channel}] ok {SDX_LABEL}: {built_sdx}")
    return drift, lines


def compare_bazzite(channel: str, recorded: dict[str, str]) -> tuple[bool, list[str], str]:
    lines: list[str] = []
    try:
        info = upstream_bazzite(channel)
    except Exception as exc:  # noqa: BLE001
        warn(f"could not inspect Bazzite-DX {channel}: {exc}")
        return False, [f"[{channel}] Bazzite check failed; not triggering {channel} build"], ""

    version = info.get("version", "")
    digest = info.get("digest", "")
    rec_version = recorded.get(BAZZITE_VERSION_LABEL)
    rec_digest = recorded.get(BAZZITE_DIGEST_LABEL)

    # Prefer digest for exactness; version as secondary signal.
    changed = False
    if not version and not digest:
        lines.append(f"[{channel}] Bazzite-DX: no version/digest found")
    elif rec_digest and digest and rec_digest != digest:
        changed = True
        lines.append(
            f"[{channel}] CHANGED Bazzite-DX: {rec_version or 'unknown'} ({rec_digest[:19]}...) -> {version or 'unknown'} ({digest[:19]}...)"
        )
    elif rec_version and version and rec_version != version:
        changed = True
        lines.append(f"[{channel}] CHANGED Bazzite-DX version: {rec_version} -> {version}")
    elif rec_digest is None and rec_version is None:
        lines.append(f"[{channel}] Bazzite-DX: not recorded yet (upstream {version} {digest[:19]}...)")
        # Do not force drift just because notes lack field yet; common packages will handle first build.
    else:
        lines.append(f"[{channel}] ok Bazzite-DX: {version} ({digest[:19]}...)")
    return changed, lines, version


def compare_extra_packages(
    channel: str,
    recorded: dict[str, str],
    upstream: dict[str, str],
) -> tuple[bool, list[str]]:
    """Check Testing/Unstable extra packages (kernel-surface-devel, make, gcc)."""
    drift = False
    lines: list[str] = []

    for rpm_name, label in EXTRA_SURFACE_PACKAGES.items():
        newest = upstream.get(rpm_name)
        built = recorded.get(label)
        if not newest:
            lines.append(f"[{channel}] {label}: not found in upstream repository")
            continue
        if built is None or built in ("unknown", "not-installed"):
            lines.append(f"[{channel}] {label}: not recorded yet (upstream {newest})")
            continue
        if built != newest:
            drift = True
            lines.append(f"[{channel}] CHANGED {label}: built {built} -> upstream {newest}")
        else:
            lines.append(f"[{channel}] ok {label}: {built}")

    fedora_upstream = upstream_fedora_packages_from_base(channel)
    for rpm_name, label in EXTRA_FEDORA_PACKAGES.items():
        newest = fedora_upstream.get(rpm_name)
        built = recorded.get(label)
        if not newest:
            lines.append(f"[{channel}] {label}: not found in upstream base image")
            continue
        if built is None or built in ("unknown", "not-installed"):
            lines.append(f"[{channel}] {label}: not recorded yet (upstream {newest})")
            continue
        if built != newest:
            drift = True
            lines.append(f"[{channel}] CHANGED {label}: built {built} -> upstream {newest}")
        else:
            lines.append(f"[{channel}] ok {label}: {built}")

    return drift, lines


def main() -> int:
    lines: list[str] = []

    try:
        upstream = upstream_packages()
        sdx_upstream = upstream_sdx()
    except Exception as exc:  # noqa: BLE001
        warn(f"could not read common upstream versions: {exc}")
        emit(False, False, False, ["upstream check failed; not triggering builds"])
        return 0

    channel_results: dict[str, bool] = {}
    bazzite_versions: dict[str, str] = {}

    for channel in ("stable", "testing", "unstable"):
        try:
            recorded = recorded_versions_for(channel)
        except Exception as exc:  # noqa: BLE001
            warn(f"could not read {channel} release notes: {exc}")
            recorded = {}

        common_drift, common_lines = compare_common(channel, recorded, upstream, sdx_upstream)
        bazzite_drift, bazzite_lines, baz_ver = compare_bazzite(channel, recorded)
        bazzite_versions[channel] = baz_ver
        lines.extend(common_lines)
        lines.extend(bazzite_lines)

        extra_drift = False
        if channel in ("testing", "unstable"):
            extra_drift, extra_lines = compare_extra_packages(channel, recorded, upstream)
            lines.extend(extra_lines)

        # If release notes are missing entirely, treat as drift so we create it.
        missing_notes = len(recorded) == 0
        drift = common_drift or bazzite_drift or extra_drift or missing_notes
        if missing_notes:
            lines.append(f"[{channel}] release notes missing/unreadable -> rebuild required")
        channel_results[channel] = drift
        lines.append(f"[{channel}] RESULT: {'rebuild required' if drift else 'up to date'}")

    emit(
        channel_results.get("stable", False),
        channel_results.get("testing", False),
        channel_results.get("unstable", False),
        lines,
        bazzite_versions.get("stable", ""),
        bazzite_versions.get("testing", ""),
        bazzite_versions.get("unstable", ""),
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
