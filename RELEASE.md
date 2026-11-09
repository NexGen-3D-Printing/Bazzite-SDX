# Bazzite-SDX Release Checklist (SemVer)

Bazzite-SDX uses **SemVer** (`vMAJOR.MINOR.PATCH`) for stable releases.

- **Source of truth (both):** git tag `v*` **and** the [`VERSION`](VERSION) file (they must match).
- **When releases are cut:** only on pushes of `v*` tags (e.g., `v0.1.0`). Non-tag `main`/schedule builds publish test tags (`main`, `main-YYYYMMDD`, `sha-*`) and **do not** move `latest`.
- **`latest`:** points to the newest stable SemVer release (recommended behavior). SemVer releases are marked as GitHub “Latest”.
- **No pre-releases** for now (all SemVer releases are treated as stable/latest-eligible).

## Release checklist

1. **Pick the next version** (`MAJOR.MINOR.PATCH`):
   - **PATCH**: fixes (recipes, portal, build/release fixes, docs/metadata)
   - **MINOR**: features (new portal apps/tabs, new `ujust` actions/capabilities)
   - **MAJOR**: breaking/major changes (base/rebase behavior, incompatible workflow expectations)

2. **Prepare `main`**:
   ```bash
   git checkout main
   git pull
   ```
   - Ensure CI/builds are green for the commits you intend to release.
   - Confirm portal/`ujust`/docs changes are accurate.

3. **Update `VERSION`** (must match the tag without the `v` prefix):
   ```bash
   echo "X.Y.Z" > VERSION
   git add VERSION
   git commit -m "chore(release): bump VERSION to X.Y.Z"
   git push origin main
   ```

4. **Create and push the SemVer tag**:
   ```bash
   git tag -a vX.Y.Z -m "Bazzite-SDX vX.Y.Z"
   git push origin vX.Y.Z
   ```

5. **Verify the release workflow** (Actions: *Build container image* for tag `vX.Y.Z`):
   - Image tags published: `vX.Y.Z`, `vX.Y`, `latest`, `sha-*`
   - Image signed (cosign) and digest recorded
   - GitHub release `vX.Y.Z` created/updated and marked **Latest**
   - Release notes include base OS, Surface kernel, portal/apps summary, and verification commands

6. **Post-release sanity check** (optional but recommended):
   ```bash
   cosign verify --key cosign.pub ghcr.io/nexgen-3d-printing/bazzite-sdx:vX.Y.Z
   sudo bootc switch ghcr.io/nexgen-3d-printing/bazzite-sdx:vX.Y.Z
   sudo bootc status
   ```
   On a test system, confirm NexGen3D SDX Portal launches as expected and key `ujust` actions work.

## Notes

- The `latest` **image tag** and GitHub **Latest** release move only when a stable SemVer tag release succeeds.
- If the tag and `VERSION` do not match, the workflow fails by design.
