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

## Install SDX Control Centre (built from NexGen-3D-Printing/SDX-Control-Centre)
COPY build_files/rpmbuild/SDX-Control-Centre.spec /tmp/sdx-rpmbuild/SDX-Control-Centre.spec
RUN set -euo pipefail && \
    dnf5 install -y rpm-build git tar gzip python3 && \
    mkdir -p /root/rpmbuild/BUILD /root/rpmbuild/RPMS /root/rpmbuild/SOURCES /root/rpmbuild/SPECS /root/rpmbuild/SRPMS && \
    cp /tmp/sdx-rpmbuild/SDX-Control-Centre.spec /root/rpmbuild/SPECS/SDX-Control-Centre.spec && \
    git clone --depth 1 --branch v1.0.1 https://github.com/NexGen-3D-Printing/SDX-Control-Centre.git /tmp/sdx-cc-src && \
    tar -C /tmp -czf /root/rpmbuild/SOURCES/sdx-control-centre-1.0.1.tar.gz --transform 's,^sdx-cc-src,sdx-control-centre-1.0.1,' sdx-cc-src && \
    rpmbuild -bb /root/rpmbuild/SPECS/SDX-Control-Centre.spec && \
    rpm_path="$(find /root/rpmbuild/RPMS -name 'sdx-control-centre-*.rpm' | head -n1)" && \
    test -n "${rpm_path}" && \
    dnf5 install -y "${rpm_path}" && \
    dnf5 remove -y rpm-build && \
    rm -rf /tmp/sdx-rpmbuild /tmp/sdx-cc-src /root/rpmbuild

## Clean up GPG key
RUN rm -f /usr/share/keyrings/linux-surface.gpg

## Remove Firefox RPM if present (Brave installed via Bazzite-style Flatpak setup)
RUN dnf5 remove -y firefox || true

## Copy Bazzite-SDX system files (Flatpak remotes/lists, ujust recipes, etc.)
COPY --from=ctx /system_files /

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
RUN mkdir -p /etc/bazzite-sdx && \
    SURFACE_KERNEL="$(rpm -q kernel-surface --qf '%{VERSION}-%{RELEASE}' 2>/dev/null || echo unknown)" && \
    BASE_VERSION_ID="$(. /usr/lib/os-release 2>/dev/null; echo "${VERSION_ID:-45}")" && \
    printf '%s\n' \
    '# Bazzite-SDX Release Information' \
    '' \
    'version = "1.0.0"' \
    "fedora_version = ${BASE_VERSION_ID}" \
    'base_image = "ghcr.io/ublue-os/bazzite-dx:stable"' \
    "linux_surface_kernel = \"${SURFACE_KERNEL}\"" \
    '' \
    '[links]' \
    'github = "https://github.com/NexGen-3D-Printing/Bazzite-SDX"' \
    'youtube = "https://www.youtube.com/@NexGen-3D"' \
    'bigcartel = "https://nexgen3d.bigcartel.com/"' \
    'printables = "https://www.printables.com/@NexGen3D"' \
    'reddit = "https://www.reddit.com/user/NexGen-3D/"' \
    'kofi = "https://ko-fi.com/nexgen3d"' \
    > /etc/bazzite-sdx/release-info.toml

## Titanoboa ISO contract: copy iso.yaml (required /usr/lib/bootc-image-builder/iso.yaml)
COPY --chmod=644 system_files/iso.yaml /usr/lib/bootc-image-builder/iso.yaml
