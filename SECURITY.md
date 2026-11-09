# Security Notes for Bazzite-SDX

## Image Signing (Cosign)

Bazzite-SDX container images are signed with Cosign. The **public key** (`cosign.pub`) is included in this repository for users to verify image signatures.

The **private key** is stored securely as a GitHub Actions secret (`COSIGN_PRIVATE_KEY`) and is **NOT** included in this repository.

## Channels and Verification

- **Weekly/latest:** `ghcr.io/nexgen-3d-printing/bazzite-sdx:latest`
- **Testing:** `ghcr.io/nexgen-3d-printing/bazzite-sdx:testing`
- **Pinned SemVer:** `ghcr.io/nexgen-3d-printing/bazzite-sdx:vX.Y.Z`

To verify an image:

```bash
curl -fsSL https://raw.githubusercontent.com/NexGen-3D-Printing/bazzite-sdx/main/cosign.pub -o cosign.pub
cosign verify --key cosign.pub ghcr.io/nexgen-3d-printing/bazzite-sdx:latest
# or :testing / :vX.Y.Z
```

## For Repository Owners / Forks

If you fork this repository to build your own images, generate your own Cosign keys:

```bash
COSIGN_PASSWORD="" cosign generate-key-pair
```

Then:
1. Commit your `cosign.pub` to your fork.
2. Add the private key contents as a GitHub Actions secret named `COSIGN_PRIVATE_KEY`.
3. Update image references/workflow env to match your registry/namespace.

## Repository Access Hygiene (Maintainers)

- Use **fine-grained personal access tokens** scoped to this repository with minimum required permissions and short expiration.
- Enable **2FA/passkeys** on the GitHub account.
- Rotate/revoke tokens/keys when exposed or no longer needed.
- Review collaborators, deploy keys, SSH keys, OAuth apps, and GitHub App installations periodically.

## Reporting a Vulnerability

If you discover a security vulnerability, please report it responsibly:
- GitHub Issues: https://github.com/NexGen-3D-Printing/bazzite-sdx/issues

---

*Last updated: 2026-11-09*
