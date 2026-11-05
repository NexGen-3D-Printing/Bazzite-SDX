# Bazzite-SDX Release Information

This file documents each release of Bazzite-SDX, including the Linux Surface kernel version and any changes.

## Current Release

### Version: 1.0.0 (Initial Release)
**Date:** 2026-11-06
**Fedora Version:** 45
**Base Image:** Bazzite-DX Stable
**Linux Surface Kernel:** Latest available from the Surface Linux repository

### What's Included

- **Bazzite Features:**
  - Automatic updates powered by uupd
  - Steam and Lutris pre-installed
  - vkBasalt, MangoHUD, OBS VkCapture
  - Distrobox for nested containers
  - Flatpak support with Flathub enabled
  - Input Remapper and Webapp Manager

- **Linux Surface Kernel Packages:**
  - `kernel-surface` - Main Surface kernel with latest patches
  - `kernel-surface-default` - Surface modules
  - `iptsd` - Intel Precise Touch & Stylus daemon
  - `libwacom-surface` - Wacom tablet support
  - `libwacom-surface-data` - Wacom device data
  - `surface-control` - Surface device control utilities
  - `surface-dtx-daemon` - Direct Touch feedback daemon

### Supported Hardware

#### Microsoft Surface Devices
- ✅ Surface Pro 3-9
- ✅ Surface Pro X (partial support)
- ✅ Surface Book 1-3
- ✅ Surface Laptop 1-6
- ✅ Surface Laptop Studio
- ✅ Surface Go 1-3
- ✅ Surface Studio 1-2

#### Other Hardware
- Intel, AMD, and NVIDIA GPUs
- Wireless networking (Intel, Realtek, Broadcom)
- Audio (Realtek, Intel HD Audio)
- USB peripherals and accessories

### How to Install

```bash
# Switch to Bazzite-SDX (stable release)
sudo bootc switch ghcr.io/NexGen-3D-Printing/bazzite-sdx:stable

# Reboot to apply
sudo reboot

# Verify installation
uname -r
rpm -qa | grep -E "(kernel-surface|iptsd|libwacom-surface|surface-)"
```

## Connect With Me

I'm NexGen-3D-Printing, creator of Bazzite-SDX. I'm a 3D printing enthusiast and developer who loves building custom Linux images.

| Platform | Link | Description |
|----------|------|-------------|
| 🏪 Big Cartel | [Visit](https://nexgen3d.bigcartel.com/) | My 3D printing shop |
| ▶️ YouTube | [Visit](https://www.youtube.com/@NexGen-3D) | 3D printing tutorials & tech |
| 🐙 GitHub | [Visit](https://github.com/NexGen-3D-Printing) | My open source projects |
| 📦 Printables | [Visit](https://www.printables.com/@NexGen3D) | 3D printing models & designs |
| 🤖 Reddit | [Visit](https://www.reddit.com/user/NexGen-3D/) | Join the discussion |
| ☕ Ko-fi | [Visit](https://ko-fi.com/nexgen3d) | Support my work |

## Release Notes

### Future Releases

- **Version 1.1.0** (Planned)
  - Add ISO image generation for direct installation
  - Add Bazzite-SDX GNOME variant
  - Add ARM64 support (Surface Pro X, Surface Laptop 5G)

### Version History

#### Version 1.0.0 (2026-11-06)
- Initial release of Bazzite-SDX
- Based on Bazzite-DX Stable (Fedora 45)
- Includes Linux Surface kernel packages
- Supports Surface Pro, Book, Laptop, Studio, and Go series
- Automatic Linux Surface kernel updates on each build

## Building from Source

If you want to build Bazzite-SDX yourself:

```bash
# Clone this repository
git clone https://github.com/NexGen-3D-Printing/bazzite-sdx
cd bazzite-sdx

# Build the image
just build

# Switch to the locally built image
sudo bootc switch localhost/bazzite-sdx:latest
sudo reboot
```

## Troubleshooting

### Image won't boot
- Verify the image signature: `cosign verify --key cosign.pub ghcr.io/NexGen-3D-Printing/bazzite-sdx:stable`
- Try an earlier build tag
- Check the [issues](https://github.com/NexGen-3D-Printing/bazzite-sdx/issues)

### Linux Surface kernel issues
- Check the [linux-surface repository](https://github.com/linux-surface/linux-surface)
- Some Surface devices may require additional firmware

---

*Last updated: 2026-11-06*
*Built with ❤️ by NexGen-3D-Printing*
