# .github — account-wide defaults for BreakableHoodie repos

This repository is GitHub's mechanism for **default community-health files**.
Anything here is automatically inherited by every repository owned by
`BreakableHoodie` that doesn't ship its own copy — the GitHub parallel to a
global `~/.claude/CLAUDE.md`. Change it once; it applies everywhere.

## What's inherited automatically

| File | Applies to |
| ---- | ---------- |
| `.github/pull_request_template.md` | PR description prefilled in every repo without its own template |
| `.github/ISSUE_TEMPLATE/bug_report.yml` | "Bug report" option in **New issue** |
| `.github/ISSUE_TEMPLATE/feature_request.yml` | "Feature / enhancement" option in **New issue** |
| `.github/ISSUE_TEMPLATE/config.yml` | Issue-picker config (keeps the blank-issue escape hatch) |

A repo overrides any of these by committing its own file at the same path.
settimesdotca, for example, keeps its own richer `pull_request_template.md`.

## What is NOT inherited — run the script

**Labels do not propagate.** Run `sync-labels.sh` to upsert the shared label
spine (`bug`, `enhancement`, `documentation`, `chore`, `ci`, `security`,
`priority:p1/p2/p3`) into a repo:

```bash
./sync-labels.sh BreakableHoodie/filltheholedotca
```

It's idempotent (`--force` updates existing labels), so re-run it anytime.
Repo-specific domain labels live in their own repo and are left untouched.

## Scope

Only `BreakableHoodie`-owned repos inherit from here. Repos under other accounts
or orgs (e.g. `CivicTechWR`) need their own `.github` repo or per-repo files.
