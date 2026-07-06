#!/usr/bin/env bash
# sync-labels.sh — apply the portable label spine to a repo.
#
# GitHub inherits default community-health files (PR template, issue templates)
# from this .github repo automatically, but it does NOT inherit labels. This
# script upserts the universal label set every project should share. Repo-
# specific domain labels stay in the repo they belong to; this only manages the
# shared spine, so it is safe to re-run.
#
# Usage:
#   ./sync-labels.sh owner/repo            # e.g. BreakableHoodie/filltheholedotca
#   ./sync-labels.sh                       # defaults to the current directory's repo
#
# Requires: gh (authenticated). --force updates a label if it already exists.

set -euo pipefail

REPO="${1:-}"
REPO_ARG=()
if [[ -n "$REPO" ]]; then
  REPO_ARG=(--repo "$REPO")
  TARGET="$REPO"
else
  TARGET="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
fi

echo "Syncing portable label spine → $TARGET"

# name|color(hex, no #)|description
LABELS=(
  "bug|d73a4a|Something isn't working"
  "enhancement|a2eeef|New feature or request"
  "documentation|0075ca|Improvements or additions to documentation"
  "chore|cccccc|Maintenance, tooling, repo hygiene"
  "ci|0e8a16|CI/CD workflows and gates"
  "security|b60205|Security-related issue or fix"
  "priority:p1|b60205|High priority"
  "priority:p2|fbca04|Medium priority"
  "priority:p3|0e8a16|Lower priority"
)

for entry in "${LABELS[@]}"; do
  IFS='|' read -r name color desc <<<"$entry"
  gh label create "$name" --color "$color" --description "$desc" --force "${REPO_ARG[@]}"
done

echo "Done. $((${#LABELS[@]})) labels synced to $TARGET."
