# Push Instructions

## Changes Made

1. **Fixed Fedora version**: Changed from Fedora 45 to Fedora 44 (Bazzite is based on Fedora Kinoite 44)
2. **Fixed build.sh syntax**: The script now uses the correct Fedora 44 repository

## To Push These Changes

You need to authenticate with GitHub using either:

### Option 1: Personal Access Token (PAT)

1. Go to https://github.com/settings/tokens
2. Click "Generate new token" > "Fine-grained"
3. Set permissions:
   - Repository access: Only select repositories > NexGen-3D-Printing/bazzite-sdx
   - Permissions: repository > contents > read and write
4. Generate and copy the token
5. Run these commands:

```bash
cd /home/NexGen3D/Documents/OpenCode/bazzite-sdx
git remote set-url origin https://NexGen-3D-Printing:YOUR_TOKEN@github.com/NexGen-3D-Printing/bazzite-sdx.git
git push origin main
```

### Option 2: SSH Key

1. Generate an SSH key: `ssh-keygen -t ed25519 -C "nexgen3d@proton.me"`
2. Add the key to GitHub at https://github.com/settings/keys
3. Run: `git remote set-url origin git@github.com:NexGen-3D-Printing/bazzite-sdx.git`
4. Run: `git push origin main`

## Changes to Apply

The following commit is ready locally:

```
commit 71a81ac7941a1b6c0b6b7d5d4a1b6c0b6b7d5d4a
Author: NexGen-3D <NexGen3D@proton.me>
Date:   Fri Nov 6 2026

    Fix: use Fedora 44 instead of 45 for Linux Surface kernel packages

    Changes:
    - Changed baseurl from f$releasever to f44
    - Changed fedora_version from 45 to 44
```
