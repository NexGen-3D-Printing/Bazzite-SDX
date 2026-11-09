# Rename Log (`bazzite-sdx` repo branding -> `Bazzite-SDX`)

Date: 2026-11-09
Requested by: project maintainer

## Summary
Updated in-repo GitHub repository references to use the `Bazzite-SDX` repository name/casing, in preparation for (or in alignment with) renaming the GitHub repository. **Container image identifiers were intentionally kept lowercase for compatibility.**

## What was changed
- **GitHub repository path references**: replaced `NexGen-3D-Printing/bazzite-sdx` with `NexGen-3D-Printing/Bazzite-SDX` in repo files (GitHub URLs, raw.githubusercontent.com URLs, badge/page IDs, clone/docs references where applicable).
  - 24 replacements across 10 files (see commit diff): `artifacthub-repo.yml`, `PUSH_INSTRUCTIONS.md`, `FIX_SUMMARY.md`, `Containerfile` (source label context if present via repo refs), `README.md`, `RELEASE-INFO.md`, `SECURITY.md`, `.github/workflows/build.yml` (repo URL contexts), `system_files/usr/share/yafti/nexgen3d-sdx.yml`, and log tracking.

## What was changed (second pass - safe cosmetic identifiers)
- **`ujust` group display names** in `system_files/usr/share/ublue-os/just/60-custom.just` (27 groups): `bazzite-sdx` -> `Bazzite-SDX`, `bazzite-sdx-ai` -> `Bazzite-SDX-AI`, `bazzite-sdx-utils` -> `Bazzite-SDX-Utils`, `bazzite-sdx-media` -> `Bazzite-SDX-Media`, `bazzite-sdx-system` -> `Bazzite-SDX-System`. Cosmetic only; no command/script compatibility impact.
- **NexGen3D SDX Portal (yafti) action IDs** (cosmetic): `bazzite-sdx-readme` -> `Bazzite-SDX-readme`, `bazzite-sdx-release` -> `Bazzite-SDX-release`. Recipe/command targets unchanged.

## What was intentionally NOT changed (compatibility / safety)
These remain lowercase `bazzite-sdx` to avoid breaking existing installs, published artifacts, and functional identifiers:

- **GHCR/container image name & bootc targets**: `ghcr.io/nexgen-3d-printing/bazzite-sdx:*` and all `bootc switch .../bazzite-sdx:*` / `cosign verify .../bazzite-sdx:*` references.
- **`image-template.env`**: `IMAGE_NAME=bazzite-sdx` (drives published image name).
- **Recipe/command identifiers**: `ujust install-bazzite-sdx-flatpaks` and portal script invocations that call it (kept for compatibility).
- **Internal/runtime paths & filenames** (kept to avoid breakage/churn): `/etc/bazzite-sdx/`, `system_files/usr/share/ublue-os/bazzite-sdx/`, `nexgen3d-sdx.yml` filename/path references, and similar functional identifiers.
- **Local historical paths** in old docs (`/home/NexGen3D/Documents/OpenCode/bazzite-sdx`) were not treated as active config; adjust manually if desired.

## GitHub repository rename (manual step)
This log/commit updates in-repo references, but **does not rename the actual GitHub repository**. To complete the rename:
1. GitHub repo Settings -> General -> Repository name: `Bazzite-SDX`.
2. Update local remotes if needed:
   ```bash
   git remote set-url origin https://github.com/NexGen-3D-Printing/Bazzite-SDX.git
   ```
3. GitHub will redirect old URLs, but updating external links/bookmarks is recommended.

## Revert instructions
- Review the commit diff: `git show --name-status --unified=3 <commit>`
- Revert the commit: `git revert <commit>` (or `git reset --hard <previous>` if not shared/published as appropriate)
- If the GitHub repo was renamed, rename it back in GitHub settings and restore the remote URL.
- GHCR image targets were not changed, so no image/bootc rollback is needed for this rename.

## Notes
- If you also want to rename the **published container image** (`ghcr.io/.../bazzite-sdx` -> a different name/casing), treat that as a separate migration: it affects `bootc switch` targets, release instructions, user deployments, Cosign verification commands, and GHCR package naming. Do not do it casually.
