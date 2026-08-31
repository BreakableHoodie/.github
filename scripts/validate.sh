#!/usr/bin/env bash
# validate.sh — every check this repo has. The lint workflow runs exactly this,
# so a green local run is the same evidence as a green CI run.
#
# WHY THIS EXISTS AT ALL: the files here are inherited by every BreakableHoodie
# repo automatically. A malformed issue form does not fail loudly — GitHub just
# stops offering that form in the New-issue picker, everywhere, silently. This
# repo previously had no CI of any kind, so the first sign of a broken form
# would have been noticing its absence by eye.
#
# Every check FAILS with an install hint rather than skipping when its tool is
# missing. A check that quietly passes because its tool is absent is worse than
# no check.
#
# Usage: ./scripts/validate.sh

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

rc=0

# mktemp, not a fixed /tmp path: a predictable name can be pre-created as a
# symlink by another local user, redirecting whatever this writes. Cleaned up
# on any exit, including a failure or an interrupt.
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

fail() {
  printf '  \033[31mFAIL\033[0m %s\n' "$1" >&2
  rc=1
}
ok() { printf '  \033[32mok\033[0m   %s\n' "$1"; }

# ---------------------------------------------------------------- markdown ---
echo "==> markdownlint"
if ! command -v npx >/dev/null 2>&1; then
  echo "  npx not found — install Node.js (https://nodejs.org)" >&2
  exit 1
fi
if npx --yes markdownlint-cli2 "**/*.md" >"$tmpdir/mdlint.out" 2>&1; then
  ok "markdown clean"
else
  cat "$tmpdir/mdlint.out" >&2
  fail "markdownlint reported issues"
fi

# ------------------------------------------------------------- issue forms ---
# Syntax AND structure. Syntax alone is not enough: a YAML file can parse
# perfectly and still be rejected by GitHub for a missing `body`, a body entry
# with no `type`, or a dropdown with no `options` — and the failure mode is a
# form that silently stops being offered.
echo "==> issue forms"
if ! command -v jq >/dev/null 2>&1; then
  echo "  jq not found — install it (brew install jq / apt-get install jq)" >&2
  exit 1
fi

shopt -s nullglob
forms=(.github/ISSUE_TEMPLATE/*.yml)
shopt -u nullglob

if [[ ${#forms[@]} -eq 0 ]]; then
  fail "no issue forms found — expected at least one under .github/ISSUE_TEMPLATE/"
fi

for form in "${forms[@]}"; do
  base="$(basename "$form")"

  # config.yml is the issue-picker config, not a form: different shape entirely.
  if [[ "$base" == "config.yml" ]]; then
    if npx --yes js-yaml "$form" >/dev/null 2>&1; then
      ok "$base (picker config, syntax)"
    else
      fail "$base is not valid YAML"
    fi
    continue
  fi

  if ! json="$(npx --yes js-yaml "$form" 2>/dev/null)"; then
    fail "$base is not valid YAML"
    continue
  fi

  # Top level: name/description are what the picker shows; body is the form.
  if ! jq -e 'has("name") and has("description") and (.body | type == "array") and (.body | length > 0)' \
    >/dev/null <<<"$json"; then
    fail "$base missing name/description, or body is not a non-empty array"
    continue
  fi

  # Every entry's type must be one GitHub actually supports. Checking only that
  # a `type` KEY exists is not enough: a typo like "textareaa" has a type, is
  # not in the id-required set, and is not a dropdown, so it passes every other
  # assertion here while GitHub rejects the whole form. That is the exact
  # silent-breakage this validator exists to prevent, so the allowed set is
  # enumerated rather than inferred.
  #
  # Also: anything collecting input needs an `id` (GitHub keys submitted values
  # on it), a dropdown without options renders empty, and a form made only of
  # markdown blocks collects nothing and is rejected.
  if ! jq -e '
        (.body | all(has("type")))
        and (.body | all(.type | IN("markdown","input","textarea","dropdown","checkboxes")))
        and (.body | map(select(.type | IN("input","textarea","dropdown","checkboxes")))
             | all(has("id")))
        and (.body | map(select(.type == "dropdown"))
             | all(.attributes.options | type == "array" and (length > 0)))
        and (.body | map(select(.type != "markdown")) | length > 0)
      ' >/dev/null <<<"$json"; then
    fail "$base: unsupported/missing type, missing id on an input field, a dropdown with no options, or no non-markdown field"
    continue
  fi

  ok "$base"
done

# ------------------------------------------------------------------- shell ---
echo "==> shellcheck"
if ! command -v shellcheck >/dev/null 2>&1; then
  echo "  shellcheck not found — install it (brew install shellcheck / apt-get install shellcheck)" >&2
  exit 1
fi
if shellcheck ./*.sh scripts/*.sh; then
  ok "shell clean"
else
  fail "shellcheck reported issues"
fi

echo
if [[ $rc -eq 0 ]]; then
  echo "All checks passed."
else
  echo "One or more checks FAILED." >&2
fi
exit "$rc"
