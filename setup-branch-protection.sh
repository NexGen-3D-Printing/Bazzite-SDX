#!/bin/bash
#
# setup-branch-protection.sh
# Sets up branch protection rules for the bazzite-sdx repository
#
# Usage: ./setup-branch-protection.sh [owner/repo] [github_token]
# If not provided, will use environment variables GITHUB_OWNER and GITHUB_TOKEN
#

set -eou pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Bazzite-SDX Branch Protection Setup ===${NC}"
echo ""

# Get repository info
REPO="${1:-${GITHUBOwner:-}}"
TOKEN="${2:-${GITHUB_TOKEN:-}}"

if [[ -z "$REPO" ]]; then
    echo -e "${YELLOW}Enter repository (owner/repo format):${NC}"
    read -r REPO
fi

if [[ -z "$TOKEN" ]]; then
    echo -e "${YELLOW}Enter GitHub Personal Access Token (with repo scope):${NC}"
    read -rs TOKEN
fi

echo ""
echo -e "${YELLOW}Configuring branch protection for:${NC} ${REPO}"
echo ""

# Parse owner and repo
OWNER="${REPO%/*}"
REPO_NAME="${REPO#*/}"

# GitHub API endpoint
API_URL="https://api.github.com"

# Check if token is valid
echo -e "${YELLOW}Verifying GitHub token...${NC}"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: token ${TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" \
    "${API_URL}/user")

if [[ "$HTTP_STATUS" -eq 401 ]]; then
    echo -e "${RED}Error: Invalid GitHub token${NC}"
    exit 1
elif [[ "$HTTP_STATUS" -ne 200 ]]; then
    echo -e "${RED}Error: Failed to verify token (HTTP ${HTTP_STATUS})${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Token verified${NC}"
echo ""

# Enable branch protection on main
echo -e "${YELLOW}Setting up branch protection rules...${NC}"

curl -fsSL -X POST \
    -H "Authorization: token ${TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" \
    -d '{
        "required_status_checks": {
            "strict": true,
            "contexts": [
                "Build container image",
                "Update Release Info"
            ]
        },
        "enforce_admins": true,
        "required_pull_request_reviews": {
            "dismiss_stale_reviews": true,
            "require_code_owner_reviews": false,
            "required_approving_review_count": 1
        },
        "restrictions": null,
        "required_linear_history": true,
        "allow_force_pushes": false,
        "allow_deletions": false
    }' \
    "${API_URL}/repos/${OWNER}/${REPO_NAME}/branches/main/protection" > /dev/null

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✓ Branch protection enabled for main${NC}"
else
    echo -e "${RED}✗ Failed to enable branch protection${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}=== Branch Protection Setup Complete! ===${NC}"
echo ""
echo -e "${YELLOW}Summary:${NC}"
echo "  - main branch is protected"
echo "  - Force pushes: ${RED}Disabled${NC}"
echo "  - Branch deletion: ${RED}Disabled${NC}"
echo "  - Pull requests required: ${GREEN}Enabled (1 approval required)${NC}"
echo "  - Stale PR reviews dismissed: ${GREEN}Enabled${NC}"
echo "  - Linear history required: ${GREEN}Enabled${NC}"
echo "  - Admins restricted: ${GREEN}Enabled${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Go to your repository on GitHub"
echo "2. Visit: https://github.com/${REPO}/settings/branches"
echo "3. Verify the rules are in place"
echo "4. Enable workflows: https://github.com/${REPO}/settings/branches"
echo ""
