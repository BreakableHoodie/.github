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
#   ./sync-labels.sh owner/repo              # e.g. BreakableHoodie/filltheholedotca
#   ./sync-labels.sh                         # defaults to the current directory's repo
#   ./sync-labels.sh owner/repo --dry-run    # show what would change, touch nothing
#
# Requires: gh, authenticated.
#
# --dry-run exists because this rewrites colours and descriptions on labels that
# already exist. Pointed at the wrong repo it would silently restyle that repo's
# labels, and there is no undo. Preview first when you are unsure.

set -euo pipefail

DRY_RUN=0
REPO=""
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    -h | --help)
      sed -n '2,20p' "$0"
      exit 0
      ;;
    -*)
      echo "Unknown option: $arg" >&2
      exit 2
      ;;
    *)
      # Reject a second positional rather than silently overwriting the first:
      # `sync-labels.sh owner/right owner/wrong` would otherwise preflight and
      # then WRITE to owner/wrong, which is the mistake --dry-run exists to
      # prevent.
      if [[ -n "$REPO" ]]; then
        echo "Expected at most one owner/repo argument (got '$REPO' and '$arg')." >&2
        exit 2
      fi
      REPO="$arg"
      ;;
  esac
done

# Preflight. Each of these otherwise surfaces as a confusing gh error partway
# through the loop, with some labels already written and others not.
if ! command -v gh >/dev/null 2>&1; then
  echo "gh not found — install the GitHub CLI (https://cli.github.com)" >&2
  exit 1
fi
if ! gh auth status >/dev/null 2>&1; then
  echo "gh is not authenticated — run: gh auth login" >&2
  exit 1
fi

REPO_ARG=()
if [[ -n "$REPO" ]]; then
  REPO_ARG=(--repo "$REPO")
  TARGET="$REPO"
else
  if ! TARGET="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)"; then
    echo "Not inside a GitHub repo, and no owner/repo argument given." >&2
    exit 1
  fi
fi

# Fail before writing anything if the target is wrong or unreachable, rather
# than discovering it on the first label.
if ! gh label list "${REPO_ARG[@]}" --limit 1 >/dev/null 2>&1; then
  echo "Cannot read labels on '$TARGET' — check the name and your access." >&2
  exit 1
fi

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

if [[ $DRY_RUN -eq 1 ]]; then
  echo "DRY RUN — no changes will be made to $TARGET"
else
  echo "Syncing portable label spine → $TARGET"
fi

# --limit is a hard cap, not a page size: a repo with more labels than this
# would silently return a truncated list, and every label past the cap would be
# misreported as "create". 1000 is far above any realistic repo; the check below
# makes a future overflow loud instead of silent.
LABEL_FETCH_LIMIT=1000
existing="$(gh label list "${REPO_ARG[@]}" --limit "$LABEL_FETCH_LIMIT" --json name --jq '.[].name')"
existing_count="$(grep -c . <<<"$existing" || true)"
if [[ "$existing_count" -ge "$LABEL_FETCH_LIMIT" ]]; then
  echo "Refusing to continue: $TARGET has >= $LABEL_FETCH_LIMIT labels, so the" >&2
  echo "existing-label list may be truncated and this run could mislabel" >&2
  echo "updates as creations. Raise LABEL_FETCH_LIMIT in this script." >&2
  exit 1
fi

created=0
updated=0
for entry in "${LABELS[@]}"; do
  IFS='|' read -r name color desc <<<"$entry"

  if grep -qxF "$name" <<<"$existing"; then
    action="update"
    updated=$((updated + 1))
  else
    action="create"
    created=$((created + 1))
  fi

  if [[ $DRY_RUN -eq 1 ]]; then
    printf '  would %s  %s\n' "$action" "$name"
    continue
  fi

  # --force turns create into upsert, so this one call covers both cases.
  gh label create "$name" --color "$color" --description "$desc" --force "${REPO_ARG[@]}" >/dev/null
  printf '  %-7s %s\n' "$action" "$name"
done

echo
if [[ $DRY_RUN -eq 1 ]]; then
  echo "Dry run: ${created} would be created, ${updated} would be updated on $TARGET."
  echo "Re-run without --dry-run to apply."
else
  echo "Done. ${created} created, ${updated} updated on $TARGET."
fi
