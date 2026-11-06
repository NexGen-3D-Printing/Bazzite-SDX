# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY system_files /system_files

# Base Image - Using Bazzite-DX Stable (Fedora 44)
FROM ghcr.io/ublue-os/bazzite:stable

### MODIFICATIONS
## Install Linux Surface kernel packages directly from the Surface Linux repository

## Import GPG key for Surface Linux repository
RUN curl -fsSL https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc | gpg --dearmor -o /usr/share/keyrings/linux-surface.gpg

## Add Surface Linux repository
RUN cat > /etc/yum.repos.d/linux-surface.repo << 'SURFACE_REPO'
[linux-surface]
name=linux-surface
baseurl=https://pkg.surfacelinux.com/fedora/f44/
enabled=1
skip_if_unavailable=1
gpgkey=file:///usr/share/keyrings/linux-surface.gpg
gpgcheck=1
enabled_metadata=1
type=rpm-md
repo_gpgcheck=0
SURFACE_REPO

## Install Linux Surface kernel packages
RUN dnf5 install -y --enablerepo=linux-surface \
    kernel-surface \
    kernel-surface-default \
    iptsd \
    libwacom-surface \
    libwacom-surface-data \
    surface-control \
    surface-dtx-daemon

## Clean up repository files
RUN rm -f /usr/share/keyrings/linux-surface.gpg
RUN rm -f /etc/yum.repos.d/linux-surface.repo

## Create release info file
RUN mkdir -p /etc/bazzite-sdx && cat > /etc/bazzite-sdx/release-info.toml << EOF
# Bazzite-SDX Release Information

version = "1.0.0"
fedora_version = 44
base_image = "ghcr.io/ublue-os/bazzite:stable"
linux_surface_kernel = "latest-available"

[links]
github = "https://github.com/NexGen-3D-Printing/bazzite-sdx"
youtube = "https://www.youtube.com/@NexGen-3D"
bigcartel = "https://nexgen3d.bigcartel.com/"
printables = "https://www.printables.com/@NexGen3D"
reddit = "https://www.reddit.com/user/NexGen-3D/"
kofi = "https://ko-fi.com/nexgen3d"
EOF

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
