#!/bin/bash

# Ref: https://github.com/ondrejbudai/bootc-isos/blob/3b3a185e4a57947f57baf53d2be5aee469274f98/bazzite/src/build.sh

set -exo pipefail

{ export PS4='+( ${BASH_SOURCE}:${LINENO} ): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'; } 2>/dev/null

BASE_IMAGE=${BASE_IMAGE:?}

# Install ISO builder tools
dnf install -y --setopt=install_weak_deps=False \
    grub2-efi-x64-cdboot \
    xorriso \
    squashfs-tools \
    mksquashfs && \
    # Set up EFI directory
    mkdir -p /boot/efi/EFI && \
    cp -av /usr/lib/efi/shim/*/EFI/* /boot/efi/EFI/ && \
    # Copy grubx64.efi from /usr/lib/efi/grub2/
    cp -v /usr/lib/efi/grub2/*/EFI/fedora/grubx64.efi /boot/efi/EFI/BOOT/fbx64.efi && \
    # Clean up
    dnf clean all

# Copy in the iso config for image-builder
mkdir -p /usr/lib/bootc-image-builder
cp /system_files/iso.yaml /usr/lib/bootc-image-builder/iso.yaml
