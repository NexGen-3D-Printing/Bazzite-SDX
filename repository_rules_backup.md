# Repository Rules Backup

## Current Rules Configuration

Branch protection rules were set up on the `main` branch with the following restrictions:

### Protection Settings:
- **Force pushes:** Disabled
- **Branch deletion:** Disabled  
- **Pull requests required:** Yes (1 approval required)
- **Stale PR reviews dismissed:** Yes
- **Linear history required:** Yes
- **Admins restricted:** Yes

### Status Checks Required:
- Build container image
- Update Release Info

## How to Set Up These Rules Manually

1. Go to https://github.com/NexGen-3D-Printing/bazzite-sdx/settings/rules
2. Click "Add rule" or "Edit" if rule exists
3. Set branch name pattern: `main`
4. Configure the settings above
5. Click "Create" or "Save changes"

## To Temporarily Disable Protection (for initial push)

If you need to push directly to main initially:

1. Go to https://github.com/NexGen-3D-Printing/bazzite-sdx/settings/branches
2. Edit the main branch protection rule
3. Temporarily disable "Require pull requests before merging"
4. Push your code
5. Re-enable the protection

Or use `--force-with-lease` if you're the only contributor:
```bash
git push --force-with-lease origin main
```

Note: This will bypass the PR requirement but still enforces other protections like linear history and admins.
