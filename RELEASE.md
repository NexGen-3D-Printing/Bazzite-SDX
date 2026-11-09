# Bazzite-SDX Release / Channel Checklist

Bazzite-SDX uses **coexisting channels and versioning**:

- **`latest` (weekly)** - automatic **weekly scheduled** build. Publishes image tags `latest`, `weekly`, `weekly-YYYYMMDD`, `sha-*`. Updates the GitHub release tagged `latest` and marks it **Latest**.
- **`testing`** - **any build that is not the automatic weekly build** (pushes to `main`, manual `workflow_dispatch`). Publishes `testing`, `testing-YYYYMMDD`, `sha-*`. Updates the GitHub release tagged `testing` as a **prerelease** (not Latest).
- **SemVer (coexisting, pinned)** - explicit `vMAJOR.MINOR.PATCH` tag pushes. Publishes `vX.Y.Z`, `vX.Y`, `sha-*` and creates/updates a versioned GitHub release (**not** Latest; `latest` remains the weekly channel). Source of truth: git tag `v*` + [`VERSION`](VERSION) (must match).

## Version/build labels

- Weekly: `weekly-YYYYMMDD+<shortsha>` (OCI `org.opencontainers.image.version`)
- Testing: `testing-YYYYMMDD+<shortsha>`
- SemVer: `vX.Y.Z`

## Weekly `latest` builds (automatic)

No manual action required. The scheduled workflow (weekly cron, **Monday 12:00 PM AWST / 04:00 UTC**) builds and publishes the weekly `latest` channel.

Checklist after a weekly run:
1. Verify Actions run for the scheduled build succeeded.
2. Verify `ghcr.io/nexgen-3d-printing/bazzite-sdx:latest` (and `:weekly-*`) were published/signed.
3. Verify the GitHub release `latest` is marked **Latest** and contains current base OS/Surface kernel/portal info.

## Testing builds (non-weekly commits/manual)

Testing builds run automatically on pushes to `main` and can be run via **Actions → Build container image → Run workflow**. They do **not** move `latest`.

Use `testing` for validation:
```bash
sudo bootc switch ghcr.io/nexgen-3d-printing/bazzite-sdx:testing
sudo reboot
```

## SemVer pinned release checklist (coexisting)

Use SemVer tags when you want an explicit, reproducible/pinned release (`v0.1.0`, `v0.1.1`, etc.). SemVer releases coexist with weekly/testing and do not replace `latest` (weekly).

1. **Pick the version** (`MAJOR.MINOR.PATCH`):
   - **PATCH**: fixes
   - **MINOR**: features
   - **MAJOR**: breaking/major changes

2. **Prepare `main`** and ensure relevant CI is green:
   ```bash
   git checkout main
   git pull
   ```

3. **Update `VERSION`** (must match tag without `v`):
   ```bash
   echo "X.Y.Z" > VERSION
   git add VERSION
   git commit -m "chore(release): bump VERSION to X.Y.Z"
   git push origin main
   ```

4. **Create and push the tag**:
   ```bash
   git tag -a vX.Y.Z -m "Bazzite-SDX vX.Y.Z"
   git push origin vX.Y.Z
   ```

5. **Verify** the tag workflow:
   - Image tags: `vX.Y.Z`, `vX.Y`, `sha-*`
   - Image signed (cosign)
   - GitHub release `vX.Y.Z` created/updated (**not** marked Latest; weekly `latest` remains Latest)

6. **Pin/verify** (optional):
   ```bash
   cosign verify --key cosign.pub ghcr.io/nexgen-3d-printing/bazzite-sdx:vX.Y.Z
   sudo bootc switch ghcr.io/nexgen-3d-printing/bazzite-sdx:vX.Y.Z
   ```

## Notes

- `latest` = **weekly automatic build only**.
- `testing` = **all non-weekly builds** (commits to `main`, manual dispatch).
- SemVer tags coexist for explicit pinned releases; if tag and `VERSION` don’t match, the workflow fails.
