# Enable Branch Protection for Bazzite-SDX

## Repository Ruleset Status

The ruleset "Block-Access" has been temporarily disabled to allow the initial push.

## To Re-enable Branch Protection (Recommended)

Go to **https://github.com/NexGen-3D-Printing/bazzite-sdx/rules** and:

1. **Edit the "Block-Access" ruleset**
2. **Enforcement**: Change to "Active"
3. **Who can bypass**:
   - Add `NexGen-3D-Printing` as a user who can bypass
   - Or leave empty if you want strict PR reviews
4. **Click "Save changes"**

## Branch Protection Settings (Optional)

If you want additional protection beyond the ruleset:

1. Go to **Settings → Rules**
2. Click **"Add rule"**
3. Set **Branch name pattern**: `main`
4. Configure:
   - ✅ Require pull requests before merging (1 approval)
   - ✅ Linear history required
   - ❌ Allow force pushes (disabled)
   - ❌ Allow deletions (disabled)
   - ✅ Enforce for administrators
5. Click **Create**

## Current Repository State

### Files in Repository:
- ✅ `build_files/build.sh` - Installs Linux Surface kernel
- ✅ `Containerfile` - Uses Bazzite-DX Stable
- ✅ `cosign.pub` - Public key for image verification
- ✅ `image-template.env` - Repository configuration
- ✅ `README.md` - User documentation
- ✅ `RELEASE-INFO.md` - Release information
- ✅ `SECURITY.md` - Security documentation
- ✅ `setup-branch-protection.sh` - Setup script

### Files NOT in Repository (Secure):
- ❌ `cosign.key` - Private key kept secure at `/home/NexGen3D/.secure-keys/bazzite-sdx/`

## Next Steps After Enabling Protection

1. Push any future changes through pull requests
2. Or add yourself as a bypass user in the ruleset
3. Enable GitHub Actions to build and publish the image

## GitHub Actions Setup

1. Go to **Actions** tab
2. Click **"I understand my workflows, go ahead and enable them"**

## Add Signing Secret (Required for Building)

1. Go to **Settings → Secrets and Variables → Actions**
2. Click **"New repository secret"**
3. **Name**: `SIGNING_SECRET`
4. **Secret**: Paste contents from `/home/NexGen3D/.secure-keys/bazzite-sdx/cosign.key`
5. Click **"Add secret"**

---

*Updated: 2026-11-06*
