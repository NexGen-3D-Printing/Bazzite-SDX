# Ruleset Configuration for Bazzite-SDX

## Current Status

The repository currently has **no ruleset protection** enabled. This was done because:
- The previous "Block-Access" ruleset was blocking all pushes
- The GitHub API for ruleset bypass actors is complex and not well-documented

## To Restrict Pushes to Only NexGen-3D-Printing

### Method 1: Using GitHub UI (Recommended)

1. Go to **https://github.com/NexGen-3D-Printing/bazzite-sdx/settings/rules**
2. Click **"Add rule"**
3. Set **Branch name pattern**: `main`
4. Configure protections:
   - ✅ Require pull requests before merging (optional - set to 0 approvals)
   - ❌ Allow force pushes (disabled)
   - ❌ Allow deletions (disabled)
   - ✅ Enforce for administrators
5. Click **Create**

### Method 2: Using GitHub CLI (gh)

If you have GitHub CLI installed:

```bash
gh api \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/NexGen-3D-Printing/bazzite-sdx/branches/main/protection \
  -f required_pull_request_reviews='{}' \
  -f enforce_admins=true \
  -f allow_force_pushes=0 \
  -f allow_deletions=0
```

### Method 3: Manual Configuration

Go to **Settings → Rules** and create a ruleset with:
- **Target**: Branch
- **Enforcement**: Active
- **Conditions**: Branch name includes `~DEFAULT_BRANCH`
- **Rules**:
  - Deletion: Disabled
  - Non-fast-forward: Disabled
  - (No rules = allow all, but with branch protection enabled)

## Why No Ruleset is Currently Active

The ruleset system on GitHub can be challenging to configure for "push-only" access because:
- Rulesets work differently from traditional branch protection
- Bypass actors need to be configured with specific IDs
- The UI doesn't always show available bypass actors clearly

## Recommended Approach

Since the ruleset system is complex, the simplest approach is to:

1. **Keep the repository public** - anyone can view but only those with commit access can push
2. **Add yourself as a collaborator** (already have push access)
3. **Enable branch protection** on main to require PRs (optional)

## For Next Time

When setting up this repository again, consider:
- Using **branch protection rules** instead of rulesets for simpler configuration
- Adding a **CODEOWNERS** file to specify who can approve changes
- Using **required status checks** for automated verification

---

*Last updated: 2026-11-06*
*Created by: NexGen-3D-Printing*
