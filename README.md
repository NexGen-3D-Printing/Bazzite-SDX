# Bazzite-SDX

[![Build container image](https://github.com/NexGen-3D-Printing/bazzite-sdx/actions/workflows/build.yml/badge.svg)](https://github.com/NexGen-3D-Printing/bazzite-sdx/actions/workflows/build.yml)

[![Universal Blue](https://img.shields.io/badge/Universal%20Blue-303030?style=for-the-badge&logo=universalblue)](https://universal-blue.org/)
[![Fedora](https://img.shields.io/badge/Fedora-44-294172?style=for-the-badge&logo=fedora)](https://fedoraproject.org/)

Bazzite-SDX is a ready-to-use bootc image built from Bazzite with Linux Surface kernel packages pre-installed. This makes it ideal for Microsoft Surface devices while maintaining all the gaming and desktop features of Bazzite.

## ✨ What Makes It Special

**Linux Surface Kernel Support** - Full hardware acceleration and device support for Microsoft Surface devices:
- Surface Pro (3-9), Surface Book (1-3), Surface Laptop (1-6), Surface Studio
- Surface Go (1-3), Surface Dial, Surface Pen, and Surface accessories

**Bazzite All-Stars** - Everything you love from Bazzite:
- 🎮 Automatic updates powered by uupd
- 🎮 Steam and Lutris pre-installed
- 🎮 vkBasalt, MangoHUD, OBS VkCapture
- 💾 Distrobox for nested containers
- 🛠️ Input Remapper and Webapp Manager
- 🔧 Flatpak support with Flathub enabled

## 🚀 Quick Installation

### Prerequisites
- A machine running a bootc image (Bazzite, Bluefin, Aurora, or Fedora Atomic)
- A GitHub account (for the registry)

### Install Bazzite-SDX

```bash
# Switch to Bazzite-SDX (stable release)
sudo bootc switch ghcr.io/nexgen-3d-printing/bazzite-sdx:stable

# Reboot to apply
sudo reboot
```

### Verify Installation

After rebooting, verify the Linux Surface kernel is active:

```bash
# Check kernel version
uname -r
# Should show: 7.2.14-surface-xxx or similar

# List Surface packages
rpm -qa | grep -E "(kernel-surface|iptsd|libwacom-surface|surface-)"
```

### Optional: Verify Image Signature

If you want to verify the image was signed by me (NexGen-3D-Printing):

```bash
# Get my public key
curl -fsSL https://raw.githubusercontent.com/NexGen-3D-Printing/bazzite-sdx/main/cosign.pub -o cosign.pub

# Verify the image
cosign verify --key cosign.pub ghcr.io/nexgen-3d-printing/bazzite-sdx:stable
```

## 📦 Supported Hardware

### Microsoft Surface Devices

| Device | Status |
|--------|--------|
| Surface Pro 3-9 | ✅ Full support |
| Surface Pro X | ⚠️ Partial support |
| Surface Book 1-3 | ✅ Full support |
| Surface Laptop 1-6 | ✅ Full support |
| Surface Laptop Studio | ✅ Full support |
| Surface Laptop Go 1-2 | ✅ Full support |
| Surface Go 1-3 | ✅ Full support |
| Surface Studio 1-2 | ✅ Full support |

### Other Hardware
- Intel, AMD, and NVIDIA GPUs
- Wireless networking (Intel, Realtek, Broadcom)
- Audio (Realtek, Intel HD Audio)
- USB peripherals and accessories

## 🔄 Updates

Bazzite-SDX receives automatic updates from Bazzite. When new Surface kernel versions are available, they will be included in future builds.

```bash
sudo bootc fetch ghcr.io/nexgen-3d-printing/bazzite-sdx:stable
sudo reboot
```

## 📖 Release Notes

See [RELEASE-INFO.md](RELEASE-INFO.md) for detailed release information including current kernel version and feature highlights.

## 🏗️ Building from Source

This image is automatically built and published to GitHub Container Registry. If you want to build it yourself:

```bash
# Clone this repository
git clone https://github.com/NexGen-3D-Printing/bazzite-sdx
cd bazzite-sdx

# Install dependencies
sudo dnf install podman just

# Build the image
just build

# Switch to the locally built image
sudo bootc switch localhost/bazzite-sdx:latest
sudo reboot
```

## 👥 Connect With Me

I'm NexGen-3D-Printing, creator of Bazzite-SDX. I'm a 3D printing enthusiast and developer who loves building custom Linux images.

### 🌐 Social Media & Projects

| Platform | Link | Description |
|----------|------|-------------|
| 🏪 [Big Cartel](https://nexgen3d.bigcartel.com/) | [Visit](https://nexgen3d.bigcartel.com/) | My 3D printing shop |
| ▶️ [YouTube](https://www.youtube.com/@NexGen-3D) | [Visit](https://www.youtube.com/@NexGen-3D) | 3D printing tutorials & tech |
| 🐙 [GitHub](https://github.com/NexGen-3D-Printing) | [Visit](https://github.com/NexGen-3D-Printing) | My open source projects |
| 📦 [Printables](https://www.printables.com/@NexGen3D) | [Visit](https://www.printables.com/@NexGen3D) | 3D printing models & designs |
| 🤖 [Reddit](https://www.reddit.com/user/NexGen-3D/) | [Visit](https://www.reddit.com/user/NexGen-3D/) | Join the discussion |
| ☕ [Ko-fi](https://ko-fi.com/nexgen3d) | [Visit](https://ko-fi.com/nexgen3d) | Support my work |

## 🛠️ Troubleshooting

### Image won't boot
- Verify the image signature: `cosign verify --key cosign.pub ghcr.io/nexgen-3d-printing/bazzite-sdx:stable`
- Try an earlier build tag
- Check the [issues](https://github.com/NexGen-3D-Printing/bazzite-sdx/issues)

### Linux Surface kernel issues
- Check the [linux-surface repository](https://github.com/linux-surface/linux-surface)
- Some Surface devices may require additional firmware

## 📄 License

Apache-2.0 (same as Bazzite and Universal Blue)

## 🙏 Credits

- Built using [Universal Blue image-template](https://github.com/ublue-os/image-template)
- Based on [Bazzite](https://github.com/ublue-os/bazzite)
- Linux Surface kernel from [linux-surface/linux-surface](https://github.com/linux-surface/linux-surface)
- Built by [NexGen-3D-Printing](https://github.com/NexGen-3D-Printing)

---

**Built with ❤️ by NexGen-3D-Printing**

*Making Linux work better for everyone, one device at a time.*
# Update
