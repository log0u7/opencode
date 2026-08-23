---
description: Plan mode: finalize and switch. Build mode: execute the plan
# Requires OPENCODE_EXPERIMENTAL_PLAN_MODE=1 for plan_exit/plan_enter tools
# on opencode <= 1.18.x; otherwise fall back to manual Tab switch.
# Make it permanent:
#   echo 'export OPENCODE_EXPERIMENTAL_PLAN_MODE=1' >> ~/.bashrc && source ~/.bashrc
---

$ARGUMENTS = optional path to a plan file.

If plan mode is active:
0. Safeguard: locate the plan in this order:
   a) $ARGUMENTS if provided
   b) the current plan file announced by the system
      ("No plan file exists yet... create your plan at <path>")
    c) a plan generated in this conversation but not yet saved
    Cases a or b: go to step 1.
    Case c only: first write the plan to the current plan file (write
    is allowed for that path only); if no path announced, default to
    `.opencode/plans/go-<slug>.md` in worktree (or `~/.local/share/opencode/plans/`),
    then go to step 1.
   None of the three: STOP immediately: write no todo, do NOT call
   plan_exit. Report that no plan exists and ask for the plan path or
   the task to plan.
1. Read the plan file.
 2. Review the existing todo list from context. If missing or incomplete,
    create it with todowrite: one entry per plan step, first one pending.
 3. Immediately call plan_exit to switch to the build agent. If tool unavailable in this environment, instruct user to switch manually (Tab).

 Otherwise (build agent):
 1. Read the plan file ($ARGUMENTS if provided, otherwise the most recent
    existing plan). If the handoff message contains literal `{{plan}}` (unresolved),
    list `.opencode/plans/` and `~/.local/share/opencode/plans/`, take the
    newest file, and read it.
2. FIRST ACTION before any edit/bash: if no todo list exists for this
   plan, create it with todowrite (one entry per step, first one
   in_progress). If one already exists, continue it as is.
 3. Execute step by step. Mark each item completed as soon as its work
    is done, never batch. Newly discovered work = new todo added
    immediately. Aligned with the AGENTS.md Handoff rule. Be terse: no
    narration of decisions, no restating of todos; act, update statuses.