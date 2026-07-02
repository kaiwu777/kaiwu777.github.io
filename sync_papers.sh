#!/usr/bin/env bash
# sync_papers.sh — pull latest paper PDFs from Dropbox into the website repo,
# then commit + push. Edit the SRC paths below as drafts get renamed.
#
# Usage: ./sync_papers.sh
#        ./sync_papers.sh --dry-run   (preview only, no copy/commit)

set -euo pipefail

REPO="/Users/kai/kaiwu777.github.io"

# format: "<absolute source path>::<filename inside repo>"
PAPERS=(
  "/Users/kai/Library/CloudStorage/Dropbox/Subway Fare/EarlyBird/Draft/Draft_Spring2026/Crowding_ABFER.pdf::Crowding.pdf"
  "/Users/kai/Library/CloudStorage/Dropbox/Projects/Web/PoliticalConsolidation_CorporateTax.pdf::Political_Consolidation.pdf"
  "/Users/kai/Library/CloudStorage/Dropbox/Projects/Web/CV_KaiWu.pdf::CV_KaiWu.pdf"
)

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

cd "$REPO"

for entry in "${PAPERS[@]}"; do
  src="${entry%%::*}"
  dst="${entry##*::}"
  if [[ ! -f "$src" ]]; then
    echo "  skip: $dst  (source missing: $src)"
    continue
  fi
  if cmp -s "$src" "$REPO/$dst" 2>/dev/null; then
    echo "  same: $dst"
    continue
  fi
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "  would update: $dst"
  else
    cp "$src" "$REPO/$dst"
    echo "  updated: $dst"
  fi
done

if [[ $DRY_RUN -eq 1 ]]; then
  echo "Dry run complete. No files copied."
  exit 0
fi

git add -A
if git diff --staged --quiet; then
  echo "No PDF changes. Nothing to commit."
  exit 0
fi

git commit -m "Sync paper drafts ($(date +%Y-%m-%d))"
git push
echo "Pushed."
