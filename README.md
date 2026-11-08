# Bazzite-SDX

[![Build container image](https://github.com/NexGen-3D-Printing/bazzite-sdx/actions/workflows/build.yml/badge.svg)](https://github.com/NexGen-3D-Printing/bazzite-sdx/actions/workflows/build.yml)

[![Universal Blue](https://img.shields.io/badge/Universal%20Blue-303030?style=for-the-badge&logo=universalblue)](https://universal-blue.org/)
[![Bazzite-DX](https://img.shields.io/badge/Bazzite--DX-stable-294172?style=for-the-badge)](https://github.com/ublue-os/bazzite-dx)

Bazzite-SDX is a ready-to-use bootc image built from **Bazzite-DX** (`ghcr.io/ublue-os/bazzite-dx:stable`) with the Linux Surface kernel stack pre-installed. It targets Microsoft Surface devices while keeping the Bazzite-DX desktop/developer experience, plus a curated set of additional apps. The repository metadata is currently configured for the Fedora 45 Surface kernel packages; the actual base OS version follows the upstream Bazzite-DX `:stable` image at build time.

## What Makes It Special

**Linux Surface Kernel Support** - Surface kernel and userspace support for Microsoft Surface devices:
- `kernel-surface`, `iptsd`, `libwacom-surface`/data, `surface-control`, `surface-dtx-daemon`
- Surface Pro, Book, Laptop, Studio, Go families (see [Supported Hardware](#supported-hardware))

**Bazzite-DX base** - The Bazzite-DX experience (gaming + developer tooling), built from `ghcr.io/ublue-os/bazzite-dx:stable`.

**Bazzite-SDX apps (Bazzite-style Flatpak setup; not baked into the image):**
After rebasing, install the curated app set with:
```bash
ujust install-bazzite-sdx-flatpaks
```
Or open **NexGen3D SDX Portal** (a separate portal alongside the original Bazzite Portal) and run the Bazzite-SDX app install action.
- **Brave Browser** (`com.brave.Browser`, Flathub; Firefox RPM removed from the image when present)
- **OpenCode** (`ai.opencode.opencode`, Flathub)
- **SolidCraft** (`io.tangencylabs.solidcraft`, SolidCraft Flatpak repo)
- **ArtCraft** (upstream Flatpak bundle from `storytold/artcraft` releases)
- **Mission Center** (`io.missioncenter.MissionCenter`, Flathub)

The image ships Flatpak remotes/lists and the `ujust` recipe (following the upstream Bazzite pattern), but does **not** preinstall these Flatpaks into the OS image. Apps without Flatpak support are dropped and may be added later via `ujust` recipes.

> Base OS/kernel versions change per build. See the [**latest** release](https://github.com/NexGen-3D-Printing/bazzite-sdx/releases/tag/latest) for details from the most recent successful image build. Distribution is **rebase-only** (no custom USB installer ISO).

## Quick Installation (Rebase)

Bazzite-SDX is distributed as a bootc container image (no custom USB installer ISO). Install an official **Bazzite** image first (or use an existing Fedora Atomic/Bazzite/Kinoite installation compatible with bootc), then rebase:

```bash
# Verify current state
sudo bootc status

# Rebase to Bazzite-SDX (based on Bazzite-DX)
sudo bootc switch ghcr.io/nexgen-3d-printing/bazzite-sdx:latest

# Reboot to apply
sudo reboot

# After reboot: install the curated Bazzite-SDX Flatpak apps
ujust install-bazzite-sdx-flatpaks
# (or use the "NexGen3D SDX Portal" app)
```

After rebooting:

```bash
# Verify the new deployment
sudo bootc status

# Check kernel / Surface packages
uname -r
rpm -qa | grep -E "(kernel-surface|iptsd|libwacom-surface|surface-)"
```

### Optional: Verify Image Signature

```bash
curl -fsSL https://raw.githubusercontent.com/NexGen-3D-Printing/bazzite-sdx/main/cosign.pub -o cosign.pub
cosign verify --key cosign.pub ghcr.io/nexgen-3d-printing/bazzite-sdx:latest
```

## Supported Hardware

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

## Updates

```bash
sudo bootc upgrade
# or fetch/apply explicitly
sudo bootc fetch --apply
sudo reboot
```

## Release Notes

- [**latest** release](https://github.com/NexGen-3D-Printing/bazzite-sdx/releases/tag/latest) — auto-updated by `build.yml` with detected app/kernel versions from the built image.
- [RELEASE-INFO.md](RELEASE-INFO.md) — repository release notes/history.

## Building from Source

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

## Connect With Me

I'm NexGen-3D-Printing, creator of Bazzite-SDX. I'm a 3D printing enthusiast and developer who loves building custom Linux images.

### Social Media & Projects

| Platform | Link | Description |
|----------|------|-------------|
|  [Big Cartel](https://nexgen3d.bigcartel.com/) | [Visit](https://nexgen3d.bigcartel.com/) | My 3D printing shop |
|  [YouTube](https://www.youtube.com/@NexGen-3D) | [Visit](https://www.youtube.com/@NexGen-3D) | 3D printing tutorials & tech |
|  [GitHub](https://github.com/NexGen-3D-Printing) | [Visit](https://github.com/NexGen-3D-Printing) | My open source projects |
|  [Printables](https://www.printables.com/@NexGen3D) | [Visit](https://www.printables.com/@NexGen3D) | 3D printing models & designs |
|  [Reddit](https://www.reddit.com/user/NexGen-3D/) | [Visit](https://www.reddit.com/user/NexGen-3D/) | Join the discussion |
|  [Ko-fi](https://ko-fi.com/nexgen3d) | [Visit](https://ko-fi.com/nexgen3d) | Support my work |

## Troubleshooting

### Image won't boot
- Verify the image signature: `cosign verify --key cosign.pub ghcr.io/nexgen-3d-printing/bazzite-sdx:latest`
- Try an earlier build tag (dated tags are published by CI)
- Check the [issues](https://github.com/NexGen-3D-Printing/bazzite-sdx/issues)

### Linux Surface kernel issues
- Check the [linux-surface repository](https://github.com/linux-surface/linux-surface)
- Some Surface devices may require additional firmware

## License

Apache-2.0 (same as Bazzite and Universal Blue)

## Credits

- Built using [Universal Blue image-template](https://github.com/ublue-os/image-template)
- Based on [Bazzite-DX](https://github.com/ublue-os/bazzite-dx) / [Bazzite](https://github.com/ublue-os/bazzite)
- Linux Surface kernel from [linux-surface/linux-surface](https://github.com/linux-surface/linux-surface)
- Built by [NexGen-3D-Printing](https://github.com/NexGen-3D-Printing)

---

**Built with ❤️ by NexGen-3D-Printing**

*Making Linux work better for everyone, one device at a time.*
