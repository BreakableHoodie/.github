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
| `.github/ISSUE_TEMPLATE/maintenance.yml` | "Maintenance" option in **New issue** — test / refactor / chore / perf / docs |
| `.github/ISSUE_TEMPLATE/config.yml` | Issue-picker config (keeps the blank-issue escape hatch) |
| `SECURITY.md` | Security policy + the **Report a vulnerability** flow, in every repo without its own |

### Overriding — and the trap in how issue templates inherit

The PR template overrides **per file**: commit your own
`.github/pull_request_template.md` and it replaces this one, nothing else.
settimesdotca does exactly that, keeping a richer version.

**Issue templates do not work that way.** Inheritance is *all-or-nothing at the
folder level*, per
[GitHub's docs](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file):

> if a repository defines valid issue templates or issue template configuration
> in its own `.github/ISSUE_TEMPLATE` folder, **none of the contents** of the
> default `.github/ISSUE_TEMPLATE` folder will be used.

So adding **one** issue form to a repo silently removes *every* form above from
that repo, and forks it off future improvements here. The failure is quiet:
nothing errors, the New-issue picker just stops offering the shared forms.

**Practical rule:** an issue form that should apply broadly belongs *here*,
written repo-agnostically (no project-specific commands, paths, or numbers). Put
one in a repo only when you intend that repo to own its whole issue-form set.
`maintenance.yml` was added here for exactly this reason — it was first proposed
as a per-repo form for settimesdotca, which would have deleted that repo's bug
and feature forms.

## What is NOT inherited — run the script

**Labels do not propagate.** Run `sync-labels.sh` to upsert the shared label
spine (`bug`, `enhancement`, `documentation`, `chore`, `ci`, `security`,
`priority:p1/p2/p3`) into a repo:

```bash
./sync-labels.sh BreakableHoodie/filltheholedotca
```

It's idempotent, so re-run it anytime. Repo-specific domain labels live in
their own repo and are left untouched.

Preview before applying when you are unsure of the target — the script rewrites
colours and descriptions on labels that already exist, and there is no undo:

```bash
./sync-labels.sh BreakableHoodie/filltheholedotca --dry-run
```

## Validating changes here

```bash
./scripts/validate.sh
```

Runs markdownlint, checks every issue form for both YAML validity **and** the
structure GitHub requires (a `body` array, a `type` on each entry, an `id` on
anything collecting input, `options` on every dropdown), and shellchecks the
scripts. The `Validate` workflow runs exactly this script, so a green local run
is the same evidence as a green CI run.

**Why it exists:** a malformed issue form does not fail loudly. GitHub simply
stops offering it in the New-issue picker — in every inheriting repo at once,
with nothing reporting an error. This repo had no CI at all until that gap was
noticed, so the first sign of a broken form would have been someone spotting its
absence by eye.

Each check fails with an install hint rather than skipping when its tool is
missing; a check that quietly passes because its tool is absent is worse than no
check.

## Scope

Only `BreakableHoodie`-owned repos inherit from here. Repos under other accounts
or orgs (e.g. `CivicTechWR`) need their own `.github` repo or per-repo files.
