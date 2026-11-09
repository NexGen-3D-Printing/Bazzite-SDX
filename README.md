# Bazzite-SDX

[![Build container image](https://github.com/NexGen-3D-Printing/bazzite-sdx/actions/workflows/build.yml/badge.svg)](https://github.com/NexGen-3D-Printing/bazzite-sdx/actions/workflows/build.yml)

[![Universal Blue](https://img.shields.io/badge/Universal%20Blue-303030?style=for-the-badge&logo=universalblue)](https://universal-blue.org/)
[![Bazzite-DX](https://img.shields.io/badge/Bazzite--DX-stable-294172?style=for-the-badge)](https://github.com/ublue-os/bazzite-dx)

Bazzite-SDX is a bootc image built from **Bazzite-DX** (`ghcr.io/ublue-os/bazzite-dx:stable`) with the **Linux Surface kernel stack** pre-installed for Microsoft Surface devices.

**Default install philosophy:** the default Bazzite-SDX install is based on the upstream **Bazzite-DX** experience and adds **Linux Surface kernel packages/support**. **Optional software is not installed by default** — all optional app installs are offered through the **NexGen3D SDX Portal** and are **purely optional** (Bazzite-style, user-initiated).

## NexGen3D SDX Portal

**NexGen3D SDX Portal** is Bazzite-SDX’s companion app for optional post-install setup and software. It is a yafti-based portal (separate from the upstream Bazzite Portal) that runs Bazzite-SDX `ujust` recipes. Apps are **not baked into the OS image**; Flatpak apps install **per user** (no `sudo` required for app installs), following the Bazzite/Bazaar-style user experience.

**Launch:** open **NexGen3D SDX Portal** from the app menu (or run `yafti_gtk.py /usr/share/yafti/nexgen3d-sdx.yml`). On first boot, Bazzite-SDX is configured to launch the NexGen3D SDX Portal.

**Features:**
- Category tabs: **Setup**, **AI Tools**, **Web Browsers**, **Creative Utilities**, **System Utilities**, **Media**, **System Management**
- Per-app install actions with full descriptions and source/install-method notes
- “Install core Bazzite-SDX Flatpak apps (all)” option + per-app `ujust` recipes
- Install priority (where applicable): **Flatpak > AppImage > rpm-ostree layer > Docker**
- System actions: check for image/system updates (prompts before running `ujust update`), run `ujust benchmark` (if available), show system info via `fastfetch`

**Apps available via the portal (optional):**
- **AI Tools:** OpenCode (app, user Flatpak) + OpenCode CLI (official user installer), LM Studio (user Flatpak), Unsloth Desktop (AppImage, user install), ArtCraft (upstream Flatpak bundle; *warning: requires an account and may require a subscription for some features/services*), Craft Anything (upstream Flatpak bundle), REA / `rea-agents` (user-local npm/npx CLI/MCP setup; requires supported Node.js/npm), Harbor (`av/harbor`, Docker/Compose setup), Odysseus (`odysseus-dev/odysseus`, Docker/Compose setup)
- **Web Browsers:** Brave Browser (user Flatpak; Firefox RPM removed from the image when present)
- **Creative Utilities:** SolidCraft (user Flatpak), PhotoCraft (upstream Flatpak bundle), PDFCraft (upstream Flatpak bundle)
- **System Utilities:** Mission Center (user Flatpak), Gear Lever (user Flatpak, AppImage manager)
- **Media:** Plex Desktop, Plex HTPC, VLC, Delfin (Jellyfin client), Web App Hub (user Flatpaks)

## What Makes It Special

**Linux Surface Kernel Support** — Surface kernel and userspace support for Microsoft Surface devices:
- `kernel-surface`, `iptsd`, `libwacom-surface`/data, `surface-control`, `surface-dtx-daemon`
- Surface Pro, Book, Laptop, Studio, Go families (see [Supported Hardware](#supported-hardware))

**Bazzite-DX base** — the Bazzite-DX experience (gaming + developer tooling), built from `ghcr.io/ublue-os/bazzite-dx:stable`. The repository metadata is currently configured for the Fedora 45 Surface kernel packages; the actual base OS version follows the upstream Bazzite-DX `:stable` image at build time.

**Optional apps via NexGen3D SDX Portal** — no optional apps are baked into the OS image. Install only what you want after rebasing:
```bash
ujust install-bazzite-sdx-flatpaks
```
Or use **NexGen3D SDX Portal** for per-app installs and additional tools.

> Base OS/kernel versions change per build. See the [**latest** release](https://github.com/NexGen-3D-Printing/bazzite-sdx/releases/tag/latest) for details from the most recent successful image build. Distribution is **rebase-only** (no custom USB installer ISO).

## Quick Installation (Rebase)

Bazzite-SDX is distributed as a bootc container image (no custom USB installer ISO). Install an official **Bazzite** image first (or use an existing Fedora Atomic/Bazzite/Kinoite installation compatible with bootc), then rebase:

```bash
# Verify current state
sudo bootc status

# Rebase to Bazzite-SDX (latest weekly build)
sudo bootc switch ghcr.io/nexgen-3d-printing/bazzite-sdx:latest

# Or track the testing channel (non-weekly commit/manual builds):
# sudo bootc switch ghcr.io/nexgen-3d-printing/bazzite-sdx:testing

# Or pin to a specific SemVer release (recommended for reproducibility), e.g.:
# sudo bootc switch ghcr.io/nexgen-3d-printing/bazzite-sdx:v0.1.0

# Reboot to apply
sudo reboot
```

After rebooting, **NexGen3D SDX Portal** is configured to launch on first boot so you can choose optional apps (purely optional). You can also install the core curated set anytime with:

```bash
ujust install-bazzite-sdx-flatpaks
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

## Releases & Channels

Bazzite-SDX uses coexisting channel/versioning:

- **`latest` (weekly):** automatic **weekly scheduled** build (Monday 12:00 PM AWST / 04:00 UTC; `:latest`, `:weekly`, `:weekly-YYYYMMDD`). The GitHub **Latest** release tracks the newest weekly build.
- **`testing`:** any build that is **not** the automatic weekly build (pushes to `main`, manual workflow runs). Publishes `:testing`, `:testing-YYYYMMDD`, `:sha-*` and updates a `testing` prerelease for validation.
- **SemVer tags (coexisting, pinned):** explicit `vX.Y.Z` tag pushes create versioned releases/tags (source of truth: git tag + [`VERSION`](VERSION)). SemVer releases coexist with weekly/testing channels and do **not** move `latest` (weekly remains `latest`).

Build version labels: weekly = `weekly-YYYYMMDD+<sha>`, testing = `testing-YYYYMMDD+<sha>`, SemVer = `vX.Y.Z`.

- [**Latest (weekly) release**](https://github.com/NexGen-3D-Printing/bazzite-sdx/releases/latest)
- [RELEASE.md](RELEASE.md) — channel/release checklist (weekly, testing, SemVer).
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
