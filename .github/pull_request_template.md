## Summary

<!-- One paragraph: what changed and why. -->

Closes #

## What changed

<!-- For multi-file PRs, a short table helps reviewers navigate the diff. Delete if the summary covers it. -->

| File | Change |
| ---- | ------ |
|      |        |

## Security / correctness notes

<!-- Auth, input validation, data-integrity, or other risk implications. Write "None" if not applicable — don't delete the section. -->

None

## How I know this works

<!--
Two questions a green CI run cannot answer. One line each. Write "None" with a
reason rather than deleting either.
-->

- **Tests aren't vacuous:** <!-- What did you break, on purpose, to prove a test actually fails? A test only ever seen passing proves nothing — it can pass against both the correct and the broken implementation. Deliberately free text: a checkbox gets ticked reflexively, naming the change you made does not. None + reason if no tests changed. -->
- **Sweep:** <!-- If this fixes a bug, where else does the same class occur? Bugs travel in families, and the second instance is the one a user stumbles onto. "Searched X across N files, this was the only one" is a good answer. None + reason if not a bug fix. -->

## Verification

<!--
Tick every box before requesting review. An unchecked item is indistinguishable
from a skipped one.

If an item genuinely does not apply, still tick it and append the reason
("- [x] Build succeeds — None, docs-only change"). Ticked-with-a-reason says
"considered, does not apply"; an empty box says nothing at all.
-->

- [ ] Tests pass locally
- [ ] Lint / format clean
- [ ] Build succeeds
- [ ] Manual smoke test: <!-- what you actually exercised, and where -->

---
<!-- Attribution for AI-assisted PRs — keep to one line, no session URL. Delete if human-authored. -->
Built by [Agent] · Reviewed by [Agent] · 🤖 [Claude Code](https://claude.ai/claude-code)
