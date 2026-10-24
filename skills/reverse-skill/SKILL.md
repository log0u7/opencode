---
name: reverse-skill
description: >
  Router for the reverse-skill repository (zhaoxuya520/reverse-skill, submodule at
  vendor/reverse-skill): authorized reverse engineering, security analysis, CTF
  challenges, and defensive testing. Use for binary/protocol/APK analysis,
  crackmes, CTF tasks, or when the user says RE, reversing, or CTF.
---

# reverse-skill router (OpenCode wrapper)

The repository at `~/.config/opencode/vendor/reverse-skill/` is the canonical,
client-neutral implementation. This wrapper is the OpenCode entry point only.

1. Read `~/.config/opencode/vendor/reverse-skill/RULES.md` first. Do not treat
   the presence of this skill, a target name, or a sample path as authorization:
   authorization comes from the repository's scope contract.
2. Route before acting: run `skills/scripts/master-route.sh "<user task>"` from
   the repository root (default writes `work/master-route-<ts>/route-scope.md`).
   It outputs the PRIMARY skill path and a one-line justification from
   `skills/config/routing.json`.
3. Before any target action, create and validate the case: run
   `skills/scripts/case-init.sh` to produce `work/<case>/scope.md` (authorization,
   target, network profile), then `skills/scripts/case-guard.sh` on the case root
   and require exit 0. No ACT while authorization is not granted.
4. Open the selected `skills/<PRIMARY>/SKILL.md` and follow its task-specific
   instructions.
5. Resolve tools only through the generated `skills/tool-index.md`. If it is
   missing, generate it with `skills/scripts/refresh-tool-index.sh` (manifest
   capabilities only). Do not register MCP servers or install tools unless the
   user explicitly requested that action.

Offline samples and explicitly authorized targets only. If the case cannot be
authorized through the scope contract, stop and ask the user.
