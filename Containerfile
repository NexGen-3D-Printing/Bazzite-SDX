# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY system_files /system_files

# Base Image - Using Bazzite-DX Stable
FROM ghcr.io/ublue-os/bazzite-dx:stable

### MODIFICATIONS
## Install Linux Surface kernel packages directly from the Surface Linux repository

## Import GPG key for Surface Linux repository
RUN mkdir -p /usr/share/keyrings && curl -fsSL https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc | gpg --dearmor -o /usr/share/keyrings/linux-surface.gpg

## Add Surface Linux repository using the official dnf5 method
RUN dnf config-manager addrepo --from-repofile=https://pkg.surfacelinux.com/fedora/linux-surface.repo

## Install Linux Surface kernel packages
RUN dnf5 install -y --allowerasing \
    kernel-surface \
    iptsd \
    libwacom-surface \
    libwacom-surface-data \
    surface-control \
    surface-dtx-daemon

## Clean up GPG key
RUN rm -f /usr/share/keyrings/linux-surface.gpg

## Install Brave browser and remove Firefox
RUN dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo && \
    dnf5 install -y brave-browser && \
    dnf5 remove -y firefox || true

## Install OpenCode CLI (system-wide)
RUN set -euo pipefail; \
    target="linux-x64"; \
    metadata="$(curl -fsSL https://opencode.ai/update/api/latest/cli/npm)"; \
    version="$(printf '%s' "$metadata" | sed -n 's/.*\"version\":\"\([^\"]*\)\".*/\1/p')"; \
    scope="$(printf '%s' "$metadata" | sed -n 's/.*\"package\":\"\([^\"]*\)\".*/\1/p' | sed 's#/cli$##')"; \
    pkg="${scope}/cli-${target}"; \
    file="cli-${target}-${version}.tgz"; \
    url="https://registry.npmjs.org/${pkg}/-/${file}"; \
    tmp="$(mktemp -d)"; \
    curl -fsSL -o "$tmp/$file" "$url"; \
    tar -xzf "$tmp/$file" -C "$tmp"; \
    install -m 0755 "$tmp/package/bin/opencode" /usr/local/bin/opencode; \
    rm -rf "$tmp"; \
    /usr/local/bin/opencode --version || true

## Remove stock kernel to ensure exactly one /usr/lib/modules kernel directory
## bootc requires exactly one kernel; version sorting would prefer ogc1.1 over surface.fc45
## This cascade removes ~50 packages including stock-kernel kmods (nvidia, xone, ryzen_smu, etc.)
RUN dnf5 remove -y --setopt=protected_packages= \
    kernel kernel-core kernel-modules kernel-devel kernel-devel-matched && \
    ## Delete non-surface module directories (should be empty, unowned leftovers)
    for d in /usr/lib/modules/*/; do \
        if [[ ! "$d" =~ surface ]]; then \
            rm -rf "$d"; \
        fi; \
    done && \
    ## Assert exactly one module directory and kernel-surface installed
    test "$(ls -1 /usr/lib/modules/ | wc -l)" -eq 1 && \
    rpm -q kernel-surface

## Ensure PLATFORM_ID is present for bootc-image-builder/osbuild
RUN if ! grep -q '^PLATFORM_ID=' /usr/lib/os-release 2>/dev/null; then \
      . /usr/lib/os-release; \
      echo "PLATFORM_ID=\"platform:f${VERSION_ID:-45}\"" >> /usr/lib/os-release; \
    fi

## Create release info file
RUN mkdir -p /etc/bazzite-sdx && printf '%s\\n' \
    '# Bazzite-SDX Release Information' \
    '' \
    'version = "1.0.0"' \
    'fedora_version = 45' \
    'base_image = "ghcr.io/ublue-os/bazzite-dx:stable"' \
    'linux_surface_kernel = "7.2.15-1.surface.fc45"' \
    '' \
    '[links]' \
    'github = "https://github.com/NexGen-3D-Printing/bazzite-sdx"' \
    'youtube = "https://www.youtube.com/@NexGen-3D"' \
    'bigcartel = "https://nexgen3d.bigcartel.com/"' \
    'printables = "https://www.printables.com/@NexGen3D"' \
    'reddit = "https://www.reddit.com/user/NexGen-3D/"' \
    'kofi = "https://ko-fi.com/nexgen3d"' \
    > /etc/bazzite-sdx/release-info.toml

## Titanoboa ISO contract: copy iso.yaml (required /usr/lib/bootc-image-builder/iso.yaml)
COPY --chmod=644 system_files/iso.yaml /usr/lib/bootc-image-builder/iso.yaml
