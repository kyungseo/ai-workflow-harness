# Safety-Critical Rules (A1 — Execution Safety)

Canonical rule document (SSoT) for destructive, privileged, and secret-touching actions.
This is not an invokable Codex skill — tool adapters project this rule (see `skills/safety/README.md`).
Applies always, on every path, in every session.

CRITICAL: Safety rules override convenience.

NEVER run destructive or privileged state-changing commands without explicit user approval:

- `rm -rf` outside bounded temp cleanup (see Allowed below)
- `sudo`
- state-changing `kubectl`, `terraform`, or cloud provider CLI actions (apply, create, delete, scale, rotate, ...)
- commands that delete data, reset history, rotate secrets, or mutate shared infrastructure

NEVER:

- Make infrastructure or environment changes unless the user explicitly asks for that exact action.
- Read or expose `.env`, secret files, credentials, full tokens, or password values unless the user explicitly approves a specific need.

Allowed without approval:

- Read-only / query / render / validate / dry-run commands that do not read or expose secrets (e.g. `kubectl get`, `terraform validate`, `terraform show`, cloud `describe`/`list`).
- Bounded temp cleanup: removing a unique temp directory that the same process or session created, after verifying its path or prefix (e.g. repo-local `temp/` test workspaces, `mktemp` results). Deleting user, persistent, or shared paths stays approval-gated.

MUST:

- Ask before any operation with irreversible or hard-to-reverse impact.
- Prefer read-only inspection commands when diagnosing infrastructure or environment issues.
- Explain the risk and reversal cost before proposing high-impact actions.
- After explicit user approval of a specific command for a specific purpose, proceed without re-asking for that same approved action; approval does not extend to different targets or repeated destructive scope.
