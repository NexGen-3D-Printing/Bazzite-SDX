# vim: set ft=make :

# ==========================================
# Bazzite-SDX Flatpak apps (per-app + all)
# ==========================================

# Install Brave Browser (com.brave.Browser, Flathub)
[group("Bazzite-SDX")]
install-sdx-brave:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing Brave Browser (com.brave.Browser) from Flathub..."
    flatpak --user -y install --reinstall --or-update flathub com.brave.Browser || flatpak --user -y install --reinstall --or-update com.brave.Browser
    echo "Done."

# Install OpenCode desktop app (AppImage from anomalyco/opencode) - integrated via Gear Lever
[group("Bazzite-SDX")]
install-sdx-opencode channel="stable":
    #!/usr/bin/bash
    set -euo pipefail
    channel="{{channel}}"
    case "${channel}" in
        stable|prerelease|beta|pre-release) ;;
        *) echo "Unknown channel '${channel}'. Use 'stable' or 'prerelease'."; exit 1 ;;
    esac
    if [[ "${channel}" == "pre-release" ]]; then channel="prerelease"; fi
    if [[ "${channel}" == "beta" ]]; then channel="prerelease"; fi

    echo "Installing OpenCode desktop (AppImage from anomalyco/opencode, channel: ${channel})..."
    echo "This uses the upstream AppImage and integrates it with Gear Lever."
    echo ""

    # Ensure Gear Lever is installed (required to integrate/manage the AppImage)
    if ! flatpak --user info it.mijorus.gearlever >/dev/null 2>&1; then
        echo "Gear Lever (AppImage manager) is not installed. Installing it first..."
        flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
        flatpak --user -y install --reinstall --or-update flathub it.mijorus.gearlever || flatpak --user -y install --reinstall --or-update it.mijorus.gearlever
        echo ""
    fi

    tmp="$(mktemp -d)"
    trap 'rm -rf "${tmp}"' EXIT

    echo "Resolving OpenCode desktop AppImage URL (${channel})..."
    if [[ "${channel}" == "prerelease" ]]; then
        app_url="$(curl -fsSL "https://api.github.com/repos/anomalyco/opencode/releases?per_page=30" | python3 -c "import json,sys; rel=json.load(sys.stdin); print(next((a['browser_download_url'] for r in rel if r.get('prerelease') and not r.get('draft') for a in r.get('assets',[]) if a.get('name')=='opencode-desktop-linux-x86_64.AppImage'), ''))")"
    else
        app_url="$(curl -fsSL https://api.github.com/repos/anomalyco/opencode/releases/latest | python3 -c "import json,sys; d=json.load(sys.stdin); print(next((a['browser_download_url'] for a in d.get('assets',[]) if a.get('name')=='opencode-desktop-linux-x86_64.AppImage'), ''))")"
    fi
    if [[ -z "${app_url}" ]]; then
        if [[ "${channel}" == "prerelease" ]]; then
            echo "No pre-release/beta OpenCode desktop AppImage found right now."
        else
            echo "Could not resolve OpenCode desktop AppImage URL."
        fi
        exit 1
    fi

    out="${tmp}/opencode-desktop-linux-x86_64.AppImage"
    echo "Downloading ${app_url} ..."
    curl -fL --progress-bar -o "${out}" "${app_url}"
    chmod +x "${out}"

    gearlever() { flatpak run --command=gearlever it.mijorus.gearlever "$@"; }

    # Remove legacy Flathub OpenCode app if present to avoid duplicates/confusion
    if flatpak --user info ai.opencode.opencode >/dev/null 2>&1; then
        echo "Removing legacy OpenCode Flatpak (ai.opencode.opencode)..."
        flatpak --user -y uninstall ai.opencode.opencode || true
    fi

    # If an existing Gear Lever-integrated OpenCode desktop app is present, remove it first so we can install the selected release
    _gl_json="$(gearlever --list-installed --json 2>/dev/null || true)"
    existing_path="$(printf '%s' "${_gl_json}" | python3 -c "import json,sys; d=json.loads(sys.stdin.read() or '{}') if sys.stdin.readable() else {}; print(next((i.get('path','') for i in d.get('installed',[]) if 'opencode' in ((i.get('name') or '').lower()+' '+(i.get('path') or '').lower())),''))" 2>/dev/null || true)"
    if [[ -n "${existing_path}" && -f "${existing_path}" ]]; then
        echo "Removing existing Gear Lever-integrated OpenCode app (${existing_path}) before reinstall..."
        gearlever --remove --yes "${existing_path}" || true
    fi

    echo "Integrating OpenCode AppImage with Gear Lever (adds to Applications menu and moves to Gear Lever default location)..."
    gearlever --integrate --yes "${out}"

    _gl_json2="$(gearlever --list-installed --json 2>/dev/null || true)"
    installed_path="$(printf '%s' "${_gl_json2}" | python3 -c "import json,sys; d=json.loads(sys.stdin.read() or '{}') if sys.stdin.readable() else {}; print(next((i.get('path','') for i in d.get('installed',[]) if 'opencode' in ((i.get('name') or '').lower()+' '+(i.get('path') or '').lower())),''))" 2>/dev/null || true)"

    if [[ -n "${installed_path}" && -f "${installed_path}" ]]; then
        allow_pre="0"
        if [[ "${channel}" == "prerelease" ]]; then allow_pre="1"; fi
        echo "Configuring Gear Lever update source (GitHub: anomalyco/opencode, prereleases: ${allow_pre})..."
        gearlever --set-update-source "${installed_path}" --manager GithubUpdater repo=anomalyco/opencode repo_filename=opencode-desktop-linux-x86_64.AppImage allow_prereleases=${allow_pre} || echo "Warning: could not set Gear Lever update source automatically; you can configure it in Gear Lever."
        echo "Installed: ${installed_path}"
    else
        echo "Warning: OpenCode was integrated, but its installed path could not be detected automatically."
        echo "You can configure update source in Gear Lever (GitHub: anomalyco/opencode, asset: opencode-desktop-linux-x86_64.AppImage)."
    fi

    echo "Done."

# Install Mission Center (io.missioncenter.MissionCenter, Flathub)
[group("Bazzite-SDX")]
install-sdx-mission-center:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing Mission Center (io.missioncenter.MissionCenter) from Flathub..."
    flatpak --user -y install --reinstall --or-update flathub io.missioncenter.MissionCenter || flatpak --user -y install --reinstall --or-update io.missioncenter.MissionCenter
    echo "Done."

# Install SolidCraft (io.tangencylabs.solidcraft, SolidCraft Flatpak repo)
[group("Bazzite-SDX")]
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

# Install ArtCraft (upstream Flatpak bundle from storytold/artcraft release)
[group("Bazzite-SDX-AI")]
install-sdx-artcraft channel="stable":
    #!/usr/bin/bash
    set -euo pipefail
    channel="{{channel}}"
    case "${channel}" in
        stable|prerelease|beta|pre-release) ;;
        *) echo "Unknown channel '${channel}'. Use 'stable' or 'prerelease'."; exit 1 ;;
    esac
    if [[ "${channel}" == "pre-release" || "${channel}" == "beta" ]]; then channel="prerelease"; fi
    echo "WARNING: ArtCraft may require an account and may require a subscription for some features/services."
    echo "Check current terms at: https://getartcraft.com/"
    echo ""
    echo "Configuring Flatpak remotes (Flathub for runtimes)..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing ArtCraft (upstream Flatpak bundle, channel: ${channel})..."
    tmp="$(mktemp -d)"
    trap 'rm -rf "${tmp}"' EXIT
    if [[ "${channel}" == "prerelease" ]]; then
        art_url="$(curl -fsSL "https://api.github.com/repos/storytold/artcraft/releases?per_page=30" | python3 -c "import json,sys; rel=json.load(sys.stdin); print(next((a['browser_download_url'] for r in rel if r.get('prerelease') and not r.get('draft') for a in r.get('assets',[]) if a.get('name','').endswith('linux-x86_64.flatpak')), ''))")"
    else
        art_url="$(curl -fsSL https://api.github.com/repos/storytold/artcraft/releases/latest | python3 -c 'import json,sys; d=json.load(sys.stdin); print(next((a["browser_download_url"] for a in d.get("assets",[]) if a.get("name","" ).endswith("linux-x86_64.flatpak")), ""))')"
    fi
    if [[ -n "${art_url}" ]]; then
        curl -fsSL -o "${tmp}/artcraft.flatpak" "${art_url}"
        flatpak install --user -y --noninteractive --reinstall "${tmp}/artcraft.flatpak" || flatpak install --user -y --noninteractive "${tmp}/artcraft.flatpak"
        mkdir -p "${HOME}/.config/bazzite-sdx/release-channel"
        echo "${channel}" > "${HOME}/.config/bazzite-sdx/release-channel/install-sdx-artcraft"
        echo "Done."
    else
        if [[ "${channel}" == "prerelease" ]]; then
            echo "No pre-release/beta ArtCraft Flatpak bundle found right now."
        else
            echo "Warning: could not resolve ArtCraft Flatpak bundle URL; install manually if needed."
        fi
        exit 1
    fi

# Install PhotoCraft (upstream Flatpak bundle from storytold/photocraft release)
[group("Bazzite-SDX")]
install-sdx-photocraft channel="stable":
    #!/usr/bin/bash
    set -euo pipefail
    channel="{{channel}}"
    case "${channel}" in
        stable|prerelease|beta|pre-release) ;;
        *) echo "Unknown channel '${channel}'. Use 'stable' or 'prerelease'."; exit 1 ;;
    esac
    if [[ "${channel}" == "pre-release" || "${channel}" == "beta" ]]; then channel="prerelease"; fi
    echo "Configuring Flatpak remotes (Flathub for runtimes)..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing PhotoCraft (upstream Flatpak bundle, channel: ${channel})..."
    tmp="$(mktemp -d)"
    trap 'rm -rf "${tmp}"' EXIT
    if [[ "${channel}" == "prerelease" ]]; then
        url="$(curl -fsSL "https://api.github.com/repos/storytold/photocraft/releases?per_page=30" | python3 -c "import json,sys; rel=json.load(sys.stdin); print(next((a['browser_download_url'] for r in rel if r.get('prerelease') and not r.get('draft') for a in r.get('assets',[]) if a.get('name','').endswith('linux-x86_64.flatpak')), ''))")"
    else
        url="$(curl -fsSL https://api.github.com/repos/storytold/photocraft/releases/latest | python3 -c "import json,sys; d=json.load(sys.stdin); print(next((a['browser_download_url'] for a in d.get('assets',[]) if a.get('name','').endswith('linux-x86_64.flatpak')), ''))")"
    fi
    if [[ -n "${url}" ]]; then
        curl -fsSL -o "${tmp}/photocraft.flatpak" "${url}"
        flatpak install --user -y --noninteractive --reinstall "${tmp}/photocraft.flatpak" || flatpak install --user -y --noninteractive "${tmp}/photocraft.flatpak"
        mkdir -p "${HOME}/.config/bazzite-sdx/release-channel"
        echo "${channel}" > "${HOME}/.config/bazzite-sdx/release-channel/install-sdx-photocraft"
        echo "Done."
    else
        if [[ "${channel}" == "prerelease" ]]; then
            echo "No pre-release/beta PhotoCraft Flatpak bundle found right now."
        else
            echo "Warning: could not resolve PhotoCraft Flatpak bundle URL; install manually if needed."
        fi
        exit 1
    fi

# Install PDFCraft (upstream Flatpak bundle from storytold/pdfcraft release)
[group("Bazzite-SDX")]
install-sdx-pdfcraft channel="stable":
    #!/usr/bin/bash
    set -euo pipefail
    channel="{{channel}}"
    case "${channel}" in
        stable|prerelease|beta|pre-release) ;;
        *) echo "Unknown channel '${channel}'. Use 'stable' or 'prerelease'."; exit 1 ;;
    esac
    if [[ "${channel}" == "pre-release" || "${channel}" == "beta" ]]; then channel="prerelease"; fi
    echo "Configuring Flatpak remotes (Flathub for runtimes)..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing PDFCraft (upstream Flatpak bundle, channel: ${channel})..."
    tmp="$(mktemp -d)"
    trap 'rm -rf "${tmp}"' EXIT
    if [[ "${channel}" == "prerelease" ]]; then
        url="$(curl -fsSL "https://api.github.com/repos/storytold/pdfcraft/releases?per_page=30" | python3 -c "import json,sys; rel=json.load(sys.stdin); print(next((a['browser_download_url'] for r in rel if r.get('prerelease') and not r.get('draft') for a in r.get('assets',[]) if a.get('name','').endswith('linux-x86_64.flatpak')), ''))")"
    else
        url="$(curl -fsSL https://api.github.com/repos/storytold/pdfcraft/releases/latest | python3 -c "import json,sys; d=json.load(sys.stdin); print(next((a['browser_download_url'] for a in d.get('assets',[]) if a.get('name','').endswith('linux-x86_64.flatpak')), ''))")"
    fi
    if [[ -n "${url}" ]]; then
        curl -fsSL -o "${tmp}/pdfcraft.flatpak" "${url}"
        flatpak install --user -y --noninteractive --reinstall "${tmp}/pdfcraft.flatpak" || flatpak install --user -y --noninteractive "${tmp}/pdfcraft.flatpak"
        mkdir -p "${HOME}/.config/bazzite-sdx/release-channel"
        echo "${channel}" > "${HOME}/.config/bazzite-sdx/release-channel/install-sdx-pdfcraft"
        echo "Done."
    else
        if [[ "${channel}" == "prerelease" ]]; then
            echo "No pre-release/beta PDFCraft Flatpak bundle found right now."
        else
            echo "Warning: could not resolve PDFCraft Flatpak bundle URL; install manually if needed."
        fi
        exit 1
    fi

# Install Craft Anything (upstream Flatpak bundle from storytold/craft-anything release)
[group("Bazzite-SDX-AI")]
install-sdx-craft-anything channel="stable":
    #!/usr/bin/bash
    set -euo pipefail
    channel="{{channel}}"
    case "${channel}" in
        stable|prerelease|beta|pre-release) ;;
        *) echo "Unknown channel '${channel}'. Use 'stable' or 'prerelease'."; exit 1 ;;
    esac
    if [[ "${channel}" == "pre-release" || "${channel}" == "beta" ]]; then channel="prerelease"; fi
    echo "Configuring Flatpak remotes (Flathub for runtimes)..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing Craft Anything (upstream Flatpak bundle, channel: ${channel})..."
    tmp="$(mktemp -d)"
    trap 'rm -rf "${tmp}"' EXIT
    if [[ "${channel}" == "prerelease" ]]; then
        url="$(curl -fsSL "https://api.github.com/repos/storytold/craft-anything/releases?per_page=30" | python3 -c "import json,sys; rel=json.load(sys.stdin); print(next((a['browser_download_url'] for r in rel if r.get('prerelease') and not r.get('draft') for a in r.get('assets',[]) if a.get('name','').endswith('linux-x86_64.flatpak')), ''))")"
    else
        url="$(curl -fsSL https://api.github.com/repos/storytold/craft-anything/releases/latest | python3 -c "import json,sys; d=json.load(sys.stdin); print(next((a['browser_download_url'] for a in d.get('assets',[]) if a.get('name','').endswith('linux-x86_64.flatpak')), ''))")"
    fi
    if [[ -n "${url}" ]]; then
        curl -fsSL -o "${tmp}/craft-anything.flatpak" "${url}"
        flatpak install --user -y --noninteractive --reinstall "${tmp}/craft-anything.flatpak" || flatpak install --user -y --noninteractive "${tmp}/craft-anything.flatpak"
        mkdir -p "${HOME}/.config/bazzite-sdx/release-channel"
        echo "${channel}" > "${HOME}/.config/bazzite-sdx/release-channel/install-sdx-craft-anything"
        echo "Done."
    else
        if [[ "${channel}" == "prerelease" ]]; then
            echo "No pre-release/beta Craft Anything Flatpak bundle found right now."
        else
            echo "Warning: could not resolve Craft Anything Flatpak bundle URL; install manually if needed."
        fi
        exit 1
    fi

# Install all core Bazzite-SDX apps (Brave, OpenCode desktop, Mission Center, SolidCraft, ArtCraft)
[group("Bazzite-SDX")]
install-bazzite-sdx-flatpaks:
    #!/usr/bin/bash
    set -euo pipefail
    echo "=== Brave Browser (Flatpak) ==="
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    flatpak --user -y install --reinstall --or-update flathub com.brave.Browser || flatpak --user -y install --reinstall --or-update com.brave.Browser
    echo "=== OpenCode desktop (AppImage via Gear Lever) ==="
    if command -v ujust >/dev/null 2>&1 && ujust --list 2>/dev/null | grep -q 'install-sdx-opencode'; then
        ujust install-sdx-opencode
    else
        echo "ujust recipe install-sdx-opencode not found; run it from the portal or shell after install."
    fi
    echo "=== Mission Center (Flatpak) ==="
    flatpak --user -y install --reinstall --or-update flathub io.missioncenter.MissionCenter || flatpak --user -y install --reinstall --or-update io.missioncenter.MissionCenter
    echo "=== SolidCraft (Flatpak) ==="
    if [[ -f /etc/flatpak/remotes.d/solidcraft.flatpakrepo ]]; then
        flatpak remote-add --if-not-exists --user solidcraft /etc/flatpak/remotes.d/solidcraft.flatpakrepo || true
    else
        flatpak remote-add --if-not-exists --user solidcraft https://docs.solidcraft.io/flatpak/solidcraft.flatpakrepo || true
    fi
    flatpak --user -y install --reinstall --or-update solidcraft io.tangencylabs.solidcraft || flatpak --user -y install --reinstall --or-update io.tangencylabs.solidcraft
    echo "=== ArtCraft (Flatpak bundle) ==="
    tmp="$(mktemp -d)"
    trap 'rm -rf "${tmp}"' EXIT
    if art_url="$(curl -fsSL https://api.github.com/repos/storytold/artcraft/releases/latest | python3 -c 'import json,sys; d=json.load(sys.stdin); print(next(a["browser_download_url"] for a in d.get("assets",[]) if a["name"].endswith("linux-x86_64.flatpak")))')" && [[ -n "${art_url}" ]]; then
        curl -fsSL -o "${tmp}/artcraft.flatpak" "${art_url}"
        flatpak install --user -y --noninteractive --reinstall "${tmp}/artcraft.flatpak" || flatpak install --user -y --noninteractive "${tmp}/artcraft.flatpak"
    else
        echo "Warning: could not resolve ArtCraft Flatpak bundle URL; install manually if needed."
        exit 1
    fi
    echo "All core Bazzite-SDX apps processed."

# ==========================================
# AI Tools (Flatpak > AppImage > rpm-ostree layer > Docker)
# ==========================================

# Install LM Studio (ai.lmstudio.lm-studio, Flathub) - Flatpak preferred
[group("Bazzite-SDX-AI")]
install-sdx-lm-studio:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing LM Studio (ai.lmstudio.lm-studio) from Flathub..."
    flatpak --user -y install --reinstall --or-update flathub ai.lmstudio.lm-studio || flatpak --user -y install --reinstall --or-update ai.lmstudio.lm-studio
    echo "Done."

# Install OpenCode CLI (official install script to user directory) - no official Flatpak CLI; user-local install
[group("Bazzite-SDX-AI")]
install-sdx-opencode-cli:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Installing OpenCode CLI (official v2 install script)..."
    echo "This installs to the user directory (typically ~/.opencode/bin) and does not layer RPMs."
    curl -fsSL https://opencode.ai/v2/install | bash
    echo ""
    echo "If 'opencode' is not found, add the install bin directory to your PATH (see installer output)."
    echo "Done."

# Install Unsloth Desktop (Linux AppImage, user install) - no official Flatpak; AppImage preferred over rpm-ostree layer
[group("Bazzite-SDX-AI")]
install-sdx-unsloth-desktop channel="stable":
    #!/usr/bin/bash
    set -euo pipefail
    channel="{{channel}}"
    case "${channel}" in
        stable|prerelease|beta|pre-release) ;;
        *) echo "Unknown channel '${channel}'. Use 'stable' or 'prerelease'."; exit 1 ;;
    esac
    if [[ "${channel}" == "pre-release" || "${channel}" == "beta" ]]; then channel="prerelease"; fi
    echo "Installing Unsloth Desktop (Linux AppImage, user-local, channel: ${channel})..."
    dest_dir="${HOME}/Applications"
    bin_dir="${HOME}/.local/bin"
    mkdir -p "${dest_dir}" "${bin_dir}"
    tmp="$(mktemp -d)"
    trap 'rm -rf "${tmp}"' EXIT
    if [[ "${channel}" == "prerelease" ]]; then
        app_url="$(curl -fsSL "https://api.github.com/repos/unslothai/unsloth/releases?per_page=30" | python3 -c "import json,sys; rel=json.load(sys.stdin); print(next((a['browser_download_url'] for r in rel if r.get('prerelease') and not r.get('draft') for a in r.get('assets',[]) if a.get('name')=='Unsloth-Desktop-Linux.AppImage'), ''))")"
    else
        app_url="$(curl -fsSL https://api.github.com/repos/unslothai/unsloth/releases/latest | python3 -c "import json,sys; d=json.load(sys.stdin); print(next((a['browser_download_url'] for a in d.get('assets',[]) if a.get('name')=='Unsloth-Desktop-Linux.AppImage'), ''))")"
    fi
    if [[ -z "${app_url}" ]]; then
        if [[ "${channel}" == "prerelease" ]]; then
            echo "No pre-release/beta Unsloth Desktop AppImage found right now."
        else
            echo "Could not resolve Unsloth Desktop AppImage URL."
        fi
        exit 1
    fi
    out="${dest_dir}/Unsloth-Desktop-Linux.AppImage"
    echo "Downloading ${app_url} ..."
    curl -fL --progress-bar -o "${out}" "${app_url}"
    chmod +x "${out}"
    # Optional convenience symlink
    ln -sf "${out}" "${bin_dir}/unsloth-desktop" || true
    mkdir -p "${HOME}/.config/bazzite-sdx/release-channel"
    echo "${channel}" > "${HOME}/.config/bazzite-sdx/release-channel/install-sdx-unsloth-desktop"
    echo "Installed: ${out}"
    echo "Tip: integrate with Gear Lever (System Utilities) for menu/updates management, or run: ${out}"
    echo "Done."

# Install/setup REA (morluto/rea) - reverse-engineering CLI/MCP toolset (rea-agents)
[group("Bazzite-SDX-AI")]
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

# Setup Harbor (av/harbor) - Docker Compose toolkit; requires Docker/Compose (or compatible)
[group("Bazzite-SDX-AI")]
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

# Setup Odysseus (odysseus-dev/odysseus) - Docker Compose self-hosted AI workspace
[group("Bazzite-SDX-AI")]
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

# Install Gear Lever (it.mijorus.gearlever, Flathub) - AppImage manager
[group("Bazzite-SDX-Utils")]
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
[group("Bazzite-SDX-Media")]
install-sdx-plex-desktop:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing Plex Desktop (tv.plex.PlexDesktop) from Flathub..."
    flatpak --user -y install --reinstall --or-update flathub tv.plex.PlexDesktop || flatpak --user -y install --reinstall --or-update tv.plex.PlexDesktop
    echo "Done."

# Install Plex HTPC (tv.plex.PlexHTPC, Flathub)
[group("Bazzite-SDX-Media")]
install-sdx-plex-htpc:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing Plex HTPC (tv.plex.PlexHTPC) from Flathub..."
    flatpak --user -y install --reinstall --or-update flathub tv.plex.PlexHTPC || flatpak --user -y install --reinstall --or-update tv.plex.PlexHTPC
    echo "Done."

# Install VLC (org.videolan.VLC, Flathub)
[group("Bazzite-SDX-Media")]
install-sdx-vlc:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing VLC (org.videolan.VLC) from Flathub..."
    flatpak --user -y install --reinstall --or-update flathub org.videolan.VLC || flatpak --user -y install --reinstall --or-update org.videolan.VLC
    echo "Done."

# Install Delfin (cafe.avery.Delfin, Flathub) - Jellyfin client
[group("Bazzite-SDX-Media")]
install-sdx-delfin:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Configuring Flatpak remotes..."
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "Installing Delfin (cafe.avery.Delfin) from Flathub..."
    flatpak --user -y install --reinstall --or-update flathub cafe.avery.Delfin || flatpak --user -y install --reinstall --or-update cafe.avery.Delfin
    echo "Done."

# Install Web App Hub (org.pvermeer.WebAppHub, Flathub)
[group("Bazzite-SDX-Media")]
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
[group("Bazzite-SDX-System")]
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
[group("Bazzite-SDX-System")]
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
[group("Bazzite-SDX-System")]
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
[group("Bazzite-SDX-System")]
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
[group("Bazzite-SDX-System")]
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
[group("Bazzite-SDX-System")]
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

# Install Dexnor Keyboard Linux fix (optional; keyboard/touchpad fixes for Dexnor Bluetooth keyboard/touchpad combo)
[group("Bazzite-SDX-System")]
install-sdx-dexnor-keyboard-fix:
    #!/usr/bin/bash
    set -euo pipefail
    echo "Dexnor Keyboard Linux fix (optional)"
    echo "Installs userspace fixes for the Dexnor Bluetooth keyboard/touchpad combo (HID-over-GATT):"
    echo "- Keyboard latency fix (BlueZ connection latency)"
    echo "- Touchpad physical-click fix"
    echo ""
    echo "Source: https://github.com/NexGen-3D-Printing/Dexnor-Keyboard-Linux"
    echo "This will clone/update the fix to ~/.local/Dexnor-Keyboard-Fix and run its installer (sudo required)."
    echo "Pair the keyboard before running if this is a fresh setup."
    echo ""
    if ! command -v git >/dev/null 2>&1; then
        echo "git is required but not found."
        exit 1
    fi
    read -r -p "Proceed with Dexnor keyboard/touchpad fix installation? [y/N] " ans
    case "${ans}" in
        y|Y|yes|YES)
            target="${HOME}/.local/Dexnor-Keyboard-Fix"
            mkdir -p "${HOME}/.local"
            if [[ -d "${target}/.git" ]]; then
                echo "Updating existing fix checkout in ${target}..."
                git -C "${target}" pull --ff-only || true
            elif [[ -e "${target}" ]]; then
                echo "Existing path ${target} is not a git checkout."
                echo "Please move/remove it and run again, or run the installer from that location manually."
                exit 1
            else
                echo "Cloning Dexnor-Keyboard-Linux to ${target}..."
                git clone https://github.com/NexGen-3D-Printing/Dexnor-Keyboard-Linux.git "${target}"
            fi
            echo ""
            echo "Running installer..."
            bash "${target}/install.sh"
            echo ""
            echo "If needed, reconnect your Bluetooth keyboard/touchpad after installation."
            ;;
        *)
            echo "No changes made."
            ;;
    esac
    echo "Done."
