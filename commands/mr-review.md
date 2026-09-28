---
description: Pre-merge review — mental trace, run tests, list missing tests, merge/block verdict
---

Run the pre-merge review on: $ARGUMENTS
(empty = current MR/PR, else MR number / PR number / diff refs like `main..HEAD`).

1. Detect platform: `gh` for GitHub, `glab` for GitLab. Fetch the diff:
   - GitHub: `gh pr diff [<number>]` (fallback: `git diff` against base branch).
   - GitLab: `glab mr diff [<id>]` (fallback: `git diff` against base branch).
   - Plain refs: `git diff <refs>`.
2. Delegate to the `mr-reviewer` subagent with: the diff, the base branch,
   and a one-line description of what the change claims to do
   (from the MR/PR title/description when available).
3. Display the subagent report verbatim: findings, trace, test results,
   missing tests, verdict.
4. Enforce the verdict:
   - `BLOCK: ...` → do NOT merge. Surface the blocking reason to the user.
   - `MERGE OK` → ask the user for explicit confirmation before merging.
     Never merge automatically.

If no MR/PR exists and no refs given, review `git diff` of the current
branch against its upstream base.
