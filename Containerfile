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

## Remove Firefox RPM if present (Brave is installed as a Flatpak below)
RUN dnf5 remove -y firefox || true

## Install apps as system Flatpaks (drop apps without Flatpak support; ujust recipes later)
RUN set -euo pipefail; \
    flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo; \
    flatpak remote-add --if-not-exists --system solidcraft https://docs.solidcraft.io/flatpak/solidcraft.flatpakrepo; \
    # Flathub apps
    flatpak install --system -y --noninteractive flathub com.brave.Browser ai.opencode.opencode io.missioncenter.MissionCenter; \
    # SolidCraft (own remote; Flathub provides runtimes)
    flatpak install --system -y --noninteractive solidcraft io.tangencylabs.solidcraft; \
    # ArtCraft (upstream Flatpak bundle from latest GitHub release)
    tmp="$(mktemp -d)"; \
    art_url="$(curl -fsSL https://api.github.com/repos/storytold/artcraft/releases/latest | python3 -c 'import json,sys; d=json.load(sys.stdin); print(next(a[\"browser_download_url\"] for a in d.get(\"assets\",[]) if a[\"name\"].endswith(\"linux-x86_64.flatpak\")))')"; \
    curl -fsSL -o "$tmp/artcraft.flatpak" "$art_url"; \
    flatpak install --system -y --noninteractive "$tmp/artcraft.flatpak"; \
    rm -rf "$tmp"

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
