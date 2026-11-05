# Security Notes for Bazzite-SDX

## Cosign Signing

Bazzite-SDX uses cosign for image signing. The **public key** (`cosign.pub`) is included in this repository for users to verify image signatures.

The **private key** is stored securely and is NOT included in this repository.

## For Repository Owners

If you fork this repository to build your own version, you **MUST** generate your own cosign keys:

```bash
COSIGN_PASSWORD="" cosign generate-key-pair
```

Then:
1. Add `cosign.pub` to your repository
2. Add `cosign.key` contents as a GitHub Secret named `SIGNING_SECRET`

## For Users

Users installing Bazzite-SDX do **NOT** need cosign keys. The image is pre-built and pre-signed.

To install:
```bash
sudo bootc switch ghcr.io/NexGen-3D-Printing/bazzite-sdx:stable
sudo reboot
```

### Optional: Verify Image Signature

If you want to verify the image was built by NexGen-3D-Printing:

```bash
# Get the public key from the repository
curl -fsSL https://raw.githubusercontent.com/NexGen-3D-Printing/bazzite-sdx/main/cosign.pub -o cosign.pub

# Verify the image
cosign verify --key cosign.pub ghcr.io/NexGen-3D-Printing/bazzite-sdx:stable
```

## File Locations

- **cosign.pub** (public key) - In the repository (safe to share)
- **cosign.key** (private key) - NOT in the repository (stored securely)

## Security Contact

If you discover a security vulnerability, please report it responsibly:
- GitHub Issues: https://github.com/NexGen-3D-Printing/bazzite-sdx/issues

---

*Last updated: 2026-11-06*
