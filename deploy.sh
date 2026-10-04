#!/usr/bin/env bash
# Optional: publishes this folder to GitHub Pages with the GitHub CLI.
# Usage: ./deploy.sh [repo-name]
set -euo pipefail
cd "$(dirname "$0")"
REPO="${1:-AT_hub}"
command -v git >/dev/null || { echo "Install git first"; exit 1; }
command -v gh  >/dev/null || { echo "Install the GitHub CLI first: https://cli.github.com"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "Run: gh auth login"; exit 1; }
gh auth setup-git
OWNER="$(gh api user --jq .login)"
BUILD="$(mktemp -d)"
cp index.html tutorials.xlsx xlsx_full_min.js "$BUILD/"
touch "$BUILD/.nojekyll"
cd "$BUILD"
git init -q -b main && git add . && git commit -q -m "Update Assistive Technology Hub"
if gh repo view "$OWNER/$REPO" >/dev/null 2>&1; then
  git remote add origin "https://github.com/$OWNER/$REPO.git"; git push -q -f origin main
else
  gh repo create "$OWNER/$REPO" --public --source=. --remote=origin --push
fi
gh api -X POST "repos/$OWNER/$REPO/pages" -f "source[branch]=main" -f "source[path]=/" >/dev/null 2>&1 || true
echo "https://$OWNER.github.io/$REPO/"
