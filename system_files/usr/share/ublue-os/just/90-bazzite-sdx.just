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
    sudo flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing Brave Browser (com.brave.Browser) from Flathub..."
    sudo flatpak --system -y install --reinstall --or-update flathub com.brave.Browser || sudo flatpak --system -y install --reinstall --or-update com.brave.Browser
    echo "Done."

# Install OpenCode app (ai.opencode.opencode, Flathub)
[group("bazzite-sdx")]
install-sdx-opencode:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    sudo flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing OpenCode (ai.opencode.opencode) from Flathub..."
    sudo flatpak --system -y install --reinstall --or-update flathub ai.opencode.opencode || sudo flatpak --system -y install --reinstall --or-update ai.opencode.opencode
    echo "Done."

# Install Mission Center (io.missioncenter.MissionCenter, Flathub)
[group("bazzite-sdx")]
install-sdx-mission-center:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    sudo flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing Mission Center (io.missioncenter.MissionCenter) from Flathub..."
    sudo flatpak --system -y install --reinstall --or-update flathub io.missioncenter.MissionCenter || sudo flatpak --system -y install --reinstall --or-update io.missioncenter.MissionCenter
    echo "Done."

# Install SolidCraft (io.tangencylabs.solidcraft, SolidCraft Flatpak repo)
[group("bazzite-sdx")]
install-sdx-solidcraft:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    sudo flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    if [[ -f /etc/flatpak/remotes.d/solidcraft.flatpakrepo ]]; then
        sudo flatpak remote-add --if-not-exists --system solidcraft /etc/flatpak/remotes.d/solidcraft.flatpakrepo || true
    else
        sudo flatpak remote-add --if-not-exists --system solidcraft https://docs.solidcraft.io/flatpak/solidcraft.flatpakrepo || true
    fi
    echo "Installing SolidCraft (io.tangencylabs.solidcraft)..."
    sudo flatpak --system -y install --reinstall --or-update solidcraft io.tangencylabs.solidcraft || sudo flatpak --system -y install --reinstall --or-update io.tangencylabs.solidcraft
    echo "Done."

# Install ArtCraft (upstream Flatpak bundle from latest storytold/artcraft release)
[group("bazzite-sdx")]
install-sdx-artcraft:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes (Flathub for runtimes)..."
    sudo flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing ArtCraft (upstream Flatpak bundle)..."
    tmp="$(mktemp -d)"
    trap 'rm -rf "${tmp}"' EXIT
    if art_url="$(curl -fsSL https://api.github.com/repos/storytold/artcraft/releases/latest | python3 -c 'import json,sys; d=json.load(sys.stdin); print(next(a["browser_download_url"] for a in d.get("assets",[]) if a["name"].endswith("linux-x86_64.flatpak")))')" && [[ -n "${art_url}" ]]; then
        curl -fsSL -o "${tmp}/artcraft.flatpak" "${art_url}"
        sudo flatpak install --system -y --noninteractive --reinstall "${tmp}/artcraft.flatpak" || sudo flatpak install --system -y --noninteractive "${tmp}/artcraft.flatpak"
        echo "Done."
    else
        echo "Warning: could not resolve ArtCraft Flatpak bundle URL; install manually if needed."
        exit 1
    fi

# Install all core Bazzite-SDX Flatpak apps (Brave, OpenCode app, Mission Center, SolidCraft, ArtCraft)
[group("bazzite-sdx")]
install-bazzite-sdx-flatpaks:
    #!/usr/bin/bash
    set -euo pipefail
    echo "=== Brave Browser ==="
    sudo flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    sudo flatpak --system -y install --reinstall --or-update flathub com.brave.Browser || sudo flatpak --system -y install --reinstall --or-update com.brave.Browser
    echo "=== OpenCode (app) ==="
    sudo flatpak --system -y install --reinstall --or-update flathub ai.opencode.opencode || sudo flatpak --system -y install --reinstall --or-update ai.opencode.opencode
    echo "=== Mission Center ==="
    sudo flatpak --system -y install --reinstall --or-update flathub io.missioncenter.MissionCenter || sudo flatpak --system -y install --reinstall --or-update io.missioncenter.MissionCenter
    echo "=== SolidCraft ==="
    if [[ -f /etc/flatpak/remotes.d/solidcraft.flatpakrepo ]]; then
        sudo flatpak remote-add --if-not-exists --system solidcraft /etc/flatpak/remotes.d/solidcraft.flatpakrepo || true
    else
        sudo flatpak remote-add --if-not-exists --system solidcraft https://docs.solidcraft.io/flatpak/solidcraft.flatpakrepo || true
    fi
    sudo flatpak --system -y install --reinstall --or-update solidcraft io.tangencylabs.solidcraft || sudo flatpak --system -y install --reinstall --or-update io.tangencylabs.solidcraft
    echo "=== ArtCraft ==="
    tmp="$(mktemp -d)"
    trap 'rm -rf "${tmp}"' EXIT
    if art_url="$(curl -fsSL https://api.github.com/repos/storytold/artcraft/releases/latest | python3 -c 'import json,sys; d=json.load(sys.stdin); print(next(a["browser_download_url"] for a in d.get("assets",[]) if a["name"].endswith("linux-x86_64.flatpak")))')" && [[ -n "${art_url}" ]]; then
        curl -fsSL -o "${tmp}/artcraft.flatpak" "${art_url}"
        sudo flatpak install --system -y --noninteractive --reinstall "${tmp}/artcraft.flatpak" || sudo flatpak install --system -y --noninteractive "${tmp}/artcraft.flatpak"
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
    sudo flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing LM Studio (ai.lmstudio.lm-studio) from Flathub..."
    sudo flatpak --system -y install --reinstall --or-update flathub ai.lmstudio.lm-studio || sudo flatpak --system -y install --reinstall --or-update ai.lmstudio.lm-studio
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
    sudo flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing Gear Lever (it.mijorus.gearlever) from Flathub..."
    sudo flatpak --system -y install --reinstall --or-update flathub it.mijorus.gearlever || sudo flatpak --system -y install --reinstall --or-update it.mijorus.gearlever
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
    sudo flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing Plex Desktop (tv.plex.PlexDesktop) from Flathub..."
    sudo flatpak --system -y install --reinstall --or-update flathub tv.plex.PlexDesktop || sudo flatpak --system -y install --reinstall --or-update tv.plex.PlexDesktop
    echo "Done."

# Install Plex HTPC (tv.plex.PlexHTPC, Flathub)
[group("bazzite-sdx-media")]
install-sdx-plex-htpc:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    sudo flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing Plex HTPC (tv.plex.PlexHTPC) from Flathub..."
    sudo flatpak --system -y install --reinstall --or-update flathub tv.plex.PlexHTPC || sudo flatpak --system -y install --reinstall --or-update tv.plex.PlexHTPC
    echo "Done."

# Install VLC (org.videolan.VLC, Flathub)
[group("bazzite-sdx-media")]
install-sdx-vlc:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    sudo flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing VLC (org.videolan.VLC) from Flathub..."
    sudo flatpak --system -y install --reinstall --or-update flathub org.videolan.VLC || sudo flatpak --system -y install --reinstall --or-update org.videolan.VLC
    echo "Done."

# Install Delfin (cafe.avery.Delfin, Flathub) — Jellyfin client
[group("bazzite-sdx-media")]
install-sdx-delfin:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    sudo flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing Delfin (cafe.avery.Delfin) from Flathub..."
    sudo flatpak --system -y install --reinstall --or-update flathub cafe.avery.Delfin || sudo flatpak --system -y install --reinstall --or-update cafe.avery.Delfin
    echo "Done."

# Install Web App Hub (org.pvermeer.WebAppHub, Flathub)
[group("bazzite-sdx-media")]
install-sdx-web-app-hub:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    sudo flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing Web App Hub (org.pvermeer.WebAppHub) from Flathub..."
    sudo flatpak --system -y install --reinstall --or-update flathub org.pvermeer.WebAppHub || sudo flatpak --system -y install --reinstall --or-update org.pvermeer.WebAppHub
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
