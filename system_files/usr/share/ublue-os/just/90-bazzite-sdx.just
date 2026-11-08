# vim: set ft=make :

# Install Bazzite-SDX Flatpak apps (Bazzite-style list/install; not baked into the image)
[group("bazzite-sdx")]
install-bazzite-sdx-flatpaks:
    #!/usr/bin/bash
    set -euo pipefail
    LIST="/usr/share/ublue-os/bazzite-sdx/flatpaks/install"
    echo "Configuring Flatpak remotes..."
    sudo flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    if [[ -f /etc/flatpak/remotes.d/solidcraft.flatpakrepo ]]; then
        sudo flatpak remote-add --if-not-exists --system solidcraft /etc/flatpak/remotes.d/solidcraft.flatpakrepo || true
    fi
    if [[ -f "${LIST}" ]]; then
        echo "Installing Bazzite-SDX Flatpaks from ${LIST}..."
        # Install refs from configured remotes (Flathub/SolidCraft)
        grep -vE '^\s*(#|$)' "${LIST}" | while IFS= read -r ref; do
            [[ -z "${ref}" ]] && continue
            case "${ref}" in
                io.tangencylabs.solidcraft)
                    sudo flatpak --system -y install --reinstall --or-update solidcraft "${ref}" || sudo flatpak --system -y install --reinstall --or-update "${ref}"
                    ;;
                *)
                    sudo flatpak --system -y install --reinstall --or-update flathub "${ref}" || sudo flatpak --system -y install --reinstall --or-update "${ref}"
                    ;;
            esac
        done
    else
        echo "List not found: ${LIST}"
        exit 1
    fi
    # ArtCraft: upstream ships a Flatpak bundle in GitHub releases (not a simple remote ref in this list)
    echo "Installing ArtCraft (upstream Flatpak bundle)..."
    tmp="$(mktemp -d)"
    trap 'rm -rf "${tmp}"' EXIT
    if art_url="$(curl -fsSL https://api.github.com/repos/storytold/artcraft/releases/latest | python3 -c 'import json,sys; d=json.load(sys.stdin); print(next(a["browser_download_url"] for a in d.get("assets",[]) if a["name"].endswith("linux-x86_64.flatpak")))')" && [[ -n "${art_url}" ]]; then
        curl -fsSL -o "${tmp}/artcraft.flatpak" "${art_url}"
        sudo flatpak install --system -y --noninteractive --reinstall "${tmp}/artcraft.flatpak" || sudo flatpak install --system -y --noninteractive "${tmp}/artcraft.flatpak"
    else
        echo "Warning: could not resolve ArtCraft Flatpak bundle URL; install manually if needed."
    fi
    echo "Done."
