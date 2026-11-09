# vim: set ft=make :

# ==========================================
# Bazzite-SDX Flatpak apps (per-app + all)
# ==========================================

# Install Brave Browser (com.brave.Browser, Flathub)
[group("bazzite-sdx")]
install-sdx-brave:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing Brave Browser (com.brave.Browser) from Flathub..."
    flatpak --user -y install --reinstall --or-update flathub com.brave.Browser || flatpak --user -y install --reinstall --or-update com.brave.Browser
    echo "Done."

# Install OpenCode app (ai.opencode.opencode, Flathub)
[group("bazzite-sdx")]
install-sdx-opencode:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing OpenCode (ai.opencode.opencode) from Flathub..."
    flatpak --user -y install --reinstall --or-update flathub ai.opencode.opencode || flatpak --user -y install --reinstall --or-update ai.opencode.opencode
    echo "Done."

# Install Mission Center (io.missioncenter.MissionCenter, Flathub)
[group("bazzite-sdx")]
install-sdx-mission-center:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing Mission Center (io.missioncenter.MissionCenter) from Flathub..."
    flatpak --user -y install --reinstall --or-update flathub io.missioncenter.MissionCenter || flatpak --user -y install --reinstall --or-update io.missioncenter.MissionCenter
    echo "Done."

# Install SolidCraft (io.tangencylabs.solidcraft, SolidCraft Flatpak repo)
[group("bazzite-sdx")]
install-sdx-solidcraft:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    if [[ -f /etc/flatpak/remotes.d/solidcraft.flatpakrepo ]]; then
        flatpak remote-add --if-not-exists --user solidcraft /etc/flatpak/remotes.d/solidcraft.flatpakrepo || true
    else
        flatpak remote-add --if-not-exists --user solidcraft https://docs.solidcraft.io/flatpak/solidcraft.flatpakrepo || true
    fi
    echo "Installing SolidCraft (io.tangencylabs.solidcraft)..."
    flatpak --user -y install --reinstall --or-update solidcraft io.tangencylabs.solidcraft || flatpak --user -y install --reinstall --or-update io.tangencylabs.solidcraft
    echo "Done."

# Install ArtCraft (upstream Flatpak bundle from latest storytold/artcraft release)
[group("bazzite-sdx-ai")]
install-sdx-artcraft:
    #!/usr/bin/bash
    set -euo pipefail
    echo "WARNING: ArtCraft may require an account and may require a subscription for some features/services."
    echo "Check current terms at: https://getartcraft.com/"
    echo ""
    echo "Configuring Flatpak remotes (Flathub for runtimes)..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing ArtCraft (upstream Flatpak bundle)..."
    tmp="$(mktemp -d)"
    trap 'rm -rf "${tmp}"' EXIT
    if art_url="$(curl -fsSL https://api.github.com/repos/storytold/artcraft/releases/latest | python3 -c 'import json,sys; d=json.load(sys.stdin); print(next(a["browser_download_url"] for a in d.get("assets",[]) if a["name"].endswith("linux-x86_64.flatpak")))')" && [[ -n "${art_url}" ]]; then
        curl -fsSL -o "${tmp}/artcraft.flatpak" "${art_url}"
        flatpak install --user -y --noninteractive --reinstall "${tmp}/artcraft.flatpak" || flatpak install --user -y --noninteractive "${tmp}/artcraft.flatpak"
        echo "Done."
    else
        echo "Warning: could not resolve ArtCraft Flatpak bundle URL; install manually if needed."
        exit 1
    fi

# Install PhotoCraft (upstream Flatpak bundle from latest storytold/photocraft release)
[group("bazzite-sdx")]
install-sdx-photocraft:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes (Flathub for runtimes)..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing PhotoCraft (upstream Flatpak bundle)..."
    tmp="$(mktemp -d)"
    trap 'rm -rf "${tmp}"' EXIT
    if url="$(curl -fsSL https://api.github.com/repos/storytold/photocraft/releases/latest | python3 -c 'import json,sys; d=json.load(sys.stdin); print(next(a["browser_download_url"] for a in d.get("assets",[]) if a["name"].endswith("linux-x86_64.flatpak")))')" && [[ -n "${url}" ]]; then
        curl -fsSL -o "${tmp}/photocraft.flatpak" "${url}"
        flatpak install --user -y --noninteractive --reinstall "${tmp}/photocraft.flatpak" || flatpak install --user -y --noninteractive "${tmp}/photocraft.flatpak"
        echo "Done."
    else
        echo "Warning: could not resolve PhotoCraft Flatpak bundle URL; install manually if needed."
        exit 1
    fi

# Install PDFCraft (upstream Flatpak bundle from latest storytold/pdfcraft release)
[group("bazzite-sdx")]
install-sdx-pdfcraft:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes (Flathub for runtimes)..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing PDFCraft (upstream Flatpak bundle)..."
    tmp="$(mktemp -d)"
    trap 'rm -rf "${tmp}"' EXIT
    if url="$(curl -fsSL https://api.github.com/repos/storytold/pdfcraft/releases/latest | python3 -c 'import json,sys; d=json.load(sys.stdin); print(next(a["browser_download_url"] for a in d.get("assets",[]) if a["name"].endswith("linux-x86_64.flatpak")))')" && [[ -n "${url}" ]]; then
        curl -fsSL -o "${tmp}/pdfcraft.flatpak" "${url}"
        flatpak install --user -y --noninteractive --reinstall "${tmp}/pdfcraft.flatpak" || flatpak install --user -y --noninteractive "${tmp}/pdfcraft.flatpak"
        echo "Done."
    else
        echo "Warning: could not resolve PDFCraft Flatpak bundle URL; install manually if needed."
        exit 1
    fi

# Install Craft Anything (upstream Flatpak bundle from latest storytold/craft-anything release)
[group("bazzite-sdx-ai")]
install-sdx-craft-anything:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes (Flathub for runtimes)..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing Craft Anything (upstream Flatpak bundle)..."
    tmp="$(mktemp -d)"
    trap 'rm -rf "${tmp}"' EXIT
    if url="$(curl -fsSL https://api.github.com/repos/storytold/craft-anything/releases/latest | python3 -c 'import json,sys; d=json.load(sys.stdin); print(next(a["browser_download_url"] for a in d.get("assets",[]) if a["name"].endswith("linux-x86_64.flatpak")))')" && [[ -n "${url}" ]]; then
        curl -fsSL -o "${tmp}/craft-anything.flatpak" "${url}"
        flatpak install --user -y --noninteractive --reinstall "${tmp}/craft-anything.flatpak" || flatpak install --user -y --noninteractive "${tmp}/craft-anything.flatpak"
        echo "Done."
    else
        echo "Warning: could not resolve Craft Anything Flatpak bundle URL; install manually if needed."
        exit 1
    fi

# Install all core Bazzite-SDX Flatpak apps (Brave, OpenCode app, Mission Center, SolidCraft, ArtCraft)
[group("bazzite-sdx")]
install-bazzite-sdx-flatpaks:
    #!/usr/bin/bash
    set -euo pipefail
    echo "=== Brave Browser ==="
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    flatpak --user -y install --reinstall --or-update flathub com.brave.Browser || flatpak --user -y install --reinstall --or-update com.brave.Browser
    echo "=== OpenCode (app) ==="
    flatpak --user -y install --reinstall --or-update flathub ai.opencode.opencode || flatpak --user -y install --reinstall --or-update ai.opencode.opencode
    echo "=== Mission Center ==="
    flatpak --user -y install --reinstall --or-update flathub io.missioncenter.MissionCenter || flatpak --user -y install --reinstall --or-update io.missioncenter.MissionCenter
    echo "=== SolidCraft ==="
    if [[ -f /etc/flatpak/remotes.d/solidcraft.flatpakrepo ]]; then
        flatpak remote-add --if-not-exists --user solidcraft /etc/flatpak/remotes.d/solidcraft.flatpakrepo || true
    else
        flatpak remote-add --if-not-exists --user solidcraft https://docs.solidcraft.io/flatpak/solidcraft.flatpakrepo || true
    fi
    flatpak --user -y install --reinstall --or-update solidcraft io.tangencylabs.solidcraft || flatpak --user -y install --reinstall --or-update io.tangencylabs.solidcraft
    echo "=== ArtCraft ==="
    tmp="$(mktemp -d)"
    trap 'rm -rf "${tmp}"' EXIT
    if art_url="$(curl -fsSL https://api.github.com/repos/storytold/artcraft/releases/latest | python3 -c 'import json,sys; d=json.load(sys.stdin); print(next(a["browser_download_url"] for a in d.get("assets",[]) if a["name"].endswith("linux-x86_64.flatpak")))')" && [[ -n "${art_url}" ]]; then
        curl -fsSL -o "${tmp}/artcraft.flatpak" "${art_url}"
        flatpak install --user -y --noninteractive --reinstall "${tmp}/artcraft.flatpak" || flatpak install --user -y --noninteractive "${tmp}/artcraft.flatpak"
    else
        echo "Warning: could not resolve ArtCraft Flatpak bundle URL; install manually if needed."
        exit 1
    fi
    echo "All core Bazzite-SDX Flatpak apps processed."

# ==========================================
# AI Tools (Flatpak > AppImage > rpm-ostree layer > Docker)
# ==========================================

# Install LM Studio (ai.lmstudio.lm-studio, Flathub) — Flatpak preferred
[group("bazzite-sdx-ai")]
install-sdx-lm-studio:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing LM Studio (ai.lmstudio.lm-studio) from Flathub..."
    flatpak --user -y install --reinstall --or-update flathub ai.lmstudio.lm-studio || flatpak --user -y install --reinstall --or-update ai.lmstudio.lm-studio
    echo "Done."

# Install OpenCode CLI (official install script to user directory) — no official Flatpak CLI; user-local install
[group("bazzite-sdx-ai")]
install-sdx-opencode-cli:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Installing OpenCode CLI (official v2 install script)..."
    echo "This installs to the user directory (typically ~/.opencode/bin) and does not layer RPMs."
    curl -fsSL https://opencode.ai/v2/install | bash
    echo ""
    echo "If 'opencode' is not found, add the install bin directory to your PATH (see installer output)."
    echo "Done."

# Install Unsloth Desktop (latest Linux AppImage, user install) — no official Flatpak; AppImage preferred over rpm-ostree layer
[group("bazzite-sdx-ai")]
install-sdx-unsloth-desktop:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Installing Unsloth Desktop (latest Linux AppImage, user-local)..."
    dest_dir="${HOME}/Applications"
    bin_dir="${HOME}/.local/bin"
    mkdir -p "${dest_dir}" "${bin_dir}"
    tmp="$(mktemp -d)"
    trap 'rm -rf "${tmp}"' EXIT
    app_url="$(curl -fsSL https://api.github.com/repos/unslothai/unsloth/releases/latest | python3 -c 'import json,sys; d=json.load(sys.stdin); print(next(a["browser_download_url"] for a in d.get("assets",[]) if a["name"]=="Unsloth-Desktop-Linux.AppImage"))')"
    if [[ -z "${app_url}" ]]; then
        echo "Could not resolve Unsloth Desktop AppImage URL."
        exit 1
    fi
    out="${dest_dir}/Unsloth-Desktop-Linux.AppImage"
    echo "Downloading ${app_url} ..."
    curl -fL --progress-bar -o "${out}" "${app_url}"
    chmod +x "${out}"
    # Optional convenience symlink
    ln -sf "${out}" "${bin_dir}/unsloth-desktop" || true
    echo "Installed: ${out}"
    echo "Tip: integrate with Gear Lever (System Utilities) for menu/updates management, or run: ${out}"
    echo "Done."

# Install/setup REA (morluto/rea) — reverse-engineering CLI/MCP toolset (rea-agents)
[group("bazzite-sdx-ai")]
install-sdx-rea:
    #!/usr/bin/bash
    set -euo pipefail
    echo "REA (Reverse Engineer Anything, morluto/rea) is a CLI/MCP toolset for coding agents."
    echo "No official Flatpak/AppImage desktop package; using user-local CLI install/setup."
    echo ""
    echo "Notes:"
    echo "- Requires Node.js 22.x (>=22.23.4), 24.x (>=24.22.1), or 26.x (>=26.12.1) + npm."
    echo "- Deep/native analysis may require external tools (Hopper/Ghidra/IDA) configured separately."
    echo ""
    node_major=""
    if command -v node >/dev/null 2>&1; then
        node_major="$(node --version 2>/dev/null | sed -E 's/^v([0-9]+)\..*/\1/' || echo 0)"
    fi
    # Check if node/npm are available and supported
    if command -v npm >/dev/null 2>&1 && [[ -n "${node_major}" ]] && [[ "${node_major}" == "22" || "${node_major}" == "24" || "${node_major}" -ge "26" ]]; then
        #Supported Node.js + npm available
        echo "Supported Node.js ${node_major}.x detected. Installing/updating globally: npm install --global rea-agents"
        read -r -p "Proceed? [y/N] " ans
        case "${ans}" in
            y|Y|yes|YES)
                npm install --global rea-agents
                echo ""
                echo "Done. Try: rea --help   (or)   rea doctor --json"
                echo "For agent setup: npx rea-agents@latest setup"
                ;;
            *)
                echo "Skipped. You can run without global install: npx -y rea-agents@latest --help"
                ;;
        esac
    else
        # Need to install Node.js layer
        echo "Node.js ${node_major:-not installed} detected or npm missing."
        echo "REA requires Node.js 22.x (>=22.23.4), 24.x (>=24.22.1), or 26.x (>=26.12.1)."
        echo ""
        echo "Bazzite-SDX uses rpm-ostree for immutable package layering."
        echo "This will install a supported Node.js version (24.x) as a system layer."
        echo ""
        read -r -p "Proceed with 'sudo rpm-ostree install nodejs' for REA? [y/N] " ans
        case "${ans}" in
            y|Y|yes|YES)
                echo ""
                echo "Staging Node.js 24.x installation..."
                echo "IMPORTANT: This change requires a reboot to apply. The package will not be available until after reboot."
                echo ""
                sudo rpm-ostree install nodejs
                echo ""
                echo "Reboot required to complete Node.js installation."
                echo "After reboot, the REA CLI will be available and can be installed with: npm install --global rea-agents"
                echo "For agent setup: npx rea-agents@latest setup"
                ;;
            *)
                echo "Node.js installation skipped. REA cannot be installed without a supported Node.js version."
                echo "To install later: sudo rpm-ostree install nodejs, then reboot, then run npm install --global rea-agents"
                ;;
        esac
    fi
    echo "Done."

# Setup Harbor (av/harbor) — Docker Compose toolkit; requires Docker/Compose (or compatible)
[group("bazzite-sdx-ai")]
install-sdx-harbor:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Harbor (av/harbor) is a Docker Compose-based local LLM toolkit."
    if ! command -v docker >/dev/null 2>&1 && ! command -v podman >/dev/null 2>&1; then
        echo "Warning: neither 'docker' nor 'podman' found. Install/configure a container runtime first."
    fi
    if ! docker compose version >/dev/null 2>&1 && ! command -v docker-compose >/dev/null 2>&1; then
        echo "Warning: Docker Compose v2 not detected. Harbor requires Docker Engine + Docker Compose."
    fi
    echo ""
    echo "Running Harbor's official installer (may prompt for sudo / install dependencies):"
    echo "  curl -fsSL https://raw.githubusercontent.com/av/harbor/refs/heads/main/install.sh | bash"
    echo ""
    read -r -p "Proceed with Harbor installer now? [y/N] " ans
    case "${ans}" in
        y|Y|yes|YES)
            curl -fsSL https://raw.githubusercontent.com/av/harbor/refs/heads/main/install.sh | bash
            echo ""
            echo "If installed, try: harbor doctor   and   harbor up"
            ;;
        *)
            echo "Skipped. You can run the installer later."
            ;;
    esac
    echo "Done."

# Setup Odysseus (odysseus-dev/odysseus) — Docker Compose self-hosted AI workspace
[group("bazzite-sdx-ai")]
install-sdx-odysseus:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Odysseus is a Docker Compose self-hosted AI workspace (av/harbor-style compose workflow differs; Odysseus uses its own compose)."
    if ! command -v docker >/dev/null 2>&1 && ! command -v podman >/dev/null 2>&1; then
        echo "Warning: neither 'docker' nor 'podman' found. Install/configure a container runtime first."
    fi
    if ! docker compose version >/dev/null 2>&1 && ! command -v docker-compose >/dev/null 2>&1; then
        echo "Warning: Docker Compose not detected. Odysseus setup uses 'docker compose'."
    fi
    target="${HOME}/odysseus"
    echo ""
    echo "This will clone/update Odysseus in ${target}, create .env if missing, and start containers."
    echo "Default UI: http://localhost:7011 (after containers are healthy)."
    echo "First admin password is printed in: docker compose logs odysseus"
    echo ""
    read -r -p "Proceed with Odysseus setup now? [y/N] " ans
    case "${ans}" in
        y|Y|yes|YES)
            if [[ -d "${target}/.git" ]]; then
                git -C "${target}" pull --ff-only || true
            else
                git clone https://github.com/odysseus-dev/odysseus.git "${target}"
            fi
            cd "${target}"
            [[ -f .env ]] || cp .env.example .env
            docker compose up -d --build
            echo ""
            echo "Odysseus starting. Check: cd ${target} && docker compose logs -f odysseus"
            ;;
        *)
            echo "Skipped. Manual setup: git clone https://github.com/odysseus-dev/odysseus.git ~/odysseus && cd ~/odysseus && cp .env.example .env && docker compose up -d --build"
            ;;
    esac
    echo "Done."

# ==========================================
# System Utilities
# ==========================================

# Install Gear Lever (it.mijorus.gearlever, Flathub) — AppImage manager
[group("bazzite-sdx-utils")]
install-sdx-gearlever:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing Gear Lever (it.mijorus.gearlever) from Flathub..."
    flatpak --user -y install --reinstall --or-update flathub it.mijorus.gearlever || flatpak --user -y install --reinstall --or-update it.mijorus.gearlever
    echo "Done."

# ==========================================
# Media (Flatpaks)
# ==========================================

# Install Plex Desktop (tv.plex.PlexDesktop, Flathub)
[group("bazzite-sdx-media")]
install-sdx-plex-desktop:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing Plex Desktop (tv.plex.PlexDesktop) from Flathub..."
    flatpak --user -y install --reinstall --or-update flathub tv.plex.PlexDesktop || flatpak --user -y install --reinstall --or-update tv.plex.PlexDesktop
    echo "Done."

# Install Plex HTPC (tv.plex.PlexHTPC, Flathub)
[group("bazzite-sdx-media")]
install-sdx-plex-htpc:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing Plex HTPC (tv.plex.PlexHTPC) from Flathub..."
    flatpak --user -y install --reinstall --or-update flathub tv.plex.PlexHTPC || flatpak --user -y install --reinstall --or-update tv.plex.PlexHTPC
    echo "Done."

# Install VLC (org.videolan.VLC, Flathub)
[group("bazzite-sdx-media")]
install-sdx-vlc:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing VLC (org.videolan.VLC) from Flathub..."
    flatpak --user -y install --reinstall --or-update flathub org.videolan.VLC || flatpak --user -y install --reinstall --or-update org.videolan.VLC
    echo "Done."

# Install Delfin (cafe.avery.Delfin, Flathub) — Jellyfin client
[group("bazzite-sdx-media")]
install-sdx-delfin:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing Delfin (cafe.avery.Delfin) from Flathub..."
    flatpak --user -y install --reinstall --or-update flathub cafe.avery.Delfin || flatpak --user -y install --reinstall --or-update cafe.avery.Delfin
    echo "Done."

# Install Web App Hub (org.pvermeer.WebAppHub, Flathub)
[group("bazzite-sdx-media")]
install-sdx-web-app-hub:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing Web App Hub (org.pvermeer.WebAppHub) from Flathub..."
    flatpak --user -y install --reinstall --or-update flathub org.pvermeer.WebAppHub || flatpak --user -y install --reinstall --or-update org.pvermeer.WebAppHub
    echo "Done."

# ==========================================
# System Management
# ==========================================

# Check for Bazzite-SDX/bootc image updates and optionally run ujust update
[group("bazzite-sdx-system")]
check-sdx-system-updates:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Checking for system/bootc image updates..."
    echo ""
    has_update=0
    if command -v bootc >/dev/null 2>&1; then
        echo "== bootc status =="
        sudo bootc status || true
        echo ""
        echo "== bootc upgrade --check =="
        if sudo bootc upgrade --check; then
            # bootc upgrade --check exits 0 in some cases; look for common indicators is tricky.
            # We'll also offer update based on user prompt regardless.
            :
        fi
        # Heuristic: bootc upgrade --check output varies; prompt user.
        echo ""
        read -r -p "If an update is available (or you want to update now), run 'ujust update'? [y/N] " ans
        case "${ans}" in
            y|Y|yes|YES) has_update=1 ;;
        esac
    elif command -v rpm-ostree >/dev/null 2>&1; then
        echo "== rpm-ostree status =="
        rpm-ostree status || true
        echo ""
        echo "== rpm-ostree upgrade --check =="
        rpm-ostree upgrade --check || true
        echo ""
        read -r -p "If an update is available (or you want to update now), run 'ujust update'? [y/N] " ans
        case "${ans}" in
            y|Y|yes|YES) has_update=1 ;;
        esac
    else
        echo "Neither bootc nor rpm-ostree found."
        read -r -p "Run 'ujust update' anyway? [y/N] " ans
        case "${ans}" in
            y|Y|yes|YES) has_update=1 ;;
        esac
    fi
    if [[ "${has_update}" -eq 1 ]]; then
        echo "Running: ujust update"
        ujust update
    else
        echo "No update action taken."
    fi
    echo "Done."

# Run Bazzite/ujust benchmark
[group("bazzite-sdx-system")]
run-sdx-benchmark:
    #!/usr/bin/bash
    set -euo pipefail
    if ujust --list 2>/dev/null | grep -qE '\bbenchmark\b'; then
        echo "Running: ujust benchmark"
        ujust benchmark
    else
        echo "'ujust benchmark' recipe not found. Trying common fallbacks..."
        command -v stress-ng >/dev/null 2>&1 && echo "stress-ng is installed (run manually as needed)." || true
        echo "No benchmark action performed."
    fi
    echo "Done."

# Show system information (fastfetch)
[group("bazzite-sdx-system")]
show-sdx-system-info:
    #!/usr/bin/bash
    set -euo pipefail
    if command -v fastfetch >/dev/null 2>&1; then
        fastfetch
    elif command -v neofetch >/dev/null 2>&1; then
        neofetch
    else
        echo "fastfetch/neofetch not found. Basic info:"
        uname -a
        cat /etc/os-release 2>/dev/null || true
    fi
    echo ""
    echo "Press Enter to close..."
    read -r _

# ==========================================
# Image channel / version switching (bootc)
# ==========================================

# Switch Bazzite-SDX to the weekly/latest channel (ghcr.io/nexgen-3d-printing/bazzite-sdx:latest)
[group("bazzite-sdx-system")]
rebase-sdx-latest:
    #!/usr/bin/bash
    set -euo pipefail
    image="ghcr.io/nexgen-3d-printing/bazzite-sdx:latest"
    echo "This will switch (rebase) your system to: ${image}"
    echo "Channel: latest = automatic weekly build."
    echo ""
    echo "Current status:"
    sudo bootc status || true
    echo ""
    echo "After switching, reboot to apply the new deployment."
    echo "Tip: 'sudo bootc rollback' can revert to the previous deployment after reboot if needed."
    echo ""
    read -r -p "Proceed with 'sudo bootc switch ${image}'? [y/N] " ans
    case "${ans}" in
        y|Y|yes|YES)
            sudo bootc switch "${image}"
            echo ""
            echo "Switch staged. Reboot when ready: sudo systemctl reboot"
            ;;
        *)
            echo "No changes made."
            ;;
    esac
    echo "Done."

# Switch Bazzite-SDX to the testing channel (ghcr.io/nexgen-3d-printing/bazzite-sdx:testing)
[group("bazzite-sdx-system")]
rebase-sdx-testing:
    #!/usr/bin/bash
    set -euo pipefail
    image="ghcr.io/nexgen-3d-printing/bazzite-sdx:testing"
    echo "This will switch (rebase) your system to: ${image}"
    echo "Channel: testing = any build that is not the automatic weekly build (commits/manual builds)."
    echo "Testing builds may be less stable than weekly/latest."
    echo ""
    echo "Current status:"
    sudo bootc status || true
    echo ""
    echo "After switching, reboot to apply the new deployment."
    echo "Tip: 'sudo bootc rollback' can revert to the previous deployment after reboot if needed."
    echo ""
    read -r -p "Proceed with 'sudo bootc switch ${image}'? [y/N] " ans
    case "${ans}" in
        y|Y|yes|YES)
            sudo bootc switch "${image}"
            echo ""
            echo "Switch staged. Reboot when ready: sudo systemctl reboot"
            ;;
        *)
            echo "No changes made."
            ;;
    esac
    echo "Done."

# Switch Bazzite-SDX to a specific image tag/version (e.g., v0.1.0 for SemVer rollback/pin)
[group("bazzite-sdx-system")]
rebase-sdx-version:
    #!/usr/bin/bash
    set -euo pipefail
    base="ghcr.io/nexgen-3d-printing/bazzite-sdx"
    echo "Switch (rebase) Bazzite-SDX to a specific tag/version."
    echo "Examples: v0.1.0 (SemVer/pinned), latest, testing, weekly-20261109, testing-20261109"
    echo "This can be used to pin a known-good release or roll forward/back to a specific published tag."
    echo ""
    echo "Current status:"
    sudo bootc status || true
    echo ""
    read -r -p "Enter tag/version (e.g., v0.1.0): " tag
    tag="$(printf '%s' "${tag}" | tr -d '[:space:]')"
    if [[ -z "${tag}" ]]; then
        echo "No tag provided. No changes made."
        echo "Done."
        exit 0
    fi
    if [[ ! "${tag}" =~ ^[A-Za-z0-9][A-Za-z0-9._+-]{0,127}$ ]]; then
        echo "Invalid tag format. Use letters/numbers/dots/dashes/underscores/plus (e.g., v0.1.0)."
        echo "No changes made."
        exit 1
    fi
    image="${base}:${tag}"
    echo ""
    echo "Target: ${image}"
    echo "After switching, reboot to apply. 'sudo bootc rollback' can revert to the previous deployment after reboot if needed."
    read -r -p "Proceed with 'sudo bootc switch ${image}'? [y/N] " ans
    case "${ans}" in
        y|Y|yes|YES)
            sudo bootc switch "${image}"
            echo ""
            echo "Switch staged. Reboot when ready: sudo systemctl reboot"
            ;;
        *)
            echo "No changes made."
            ;;
    esac
    echo "Done."
