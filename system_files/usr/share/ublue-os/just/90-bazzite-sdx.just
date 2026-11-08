# vim: set ft=make :

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

# Install OpenCode (ai.opencode.opencode, Flathub)
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

# Install all Bazzite-SDX Flatpak apps (Bazzite-style; not baked into the image)
[group("bazzite-sdx")]
install-bazzite-sdx-flatpaks:
    #!/usr/bin/bash
    set -euo pipefail
    echo "=== Brave Browser ==="
    sudo flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    sudo flatpak --system -y install --reinstall --or-update flathub com.brave.Browser || sudo flatpak --system -y install --reinstall --or-update com.brave.Browser
    echo "=== OpenCode ==="
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
    echo "All Bazzite-SDX Flatpak apps processed."
