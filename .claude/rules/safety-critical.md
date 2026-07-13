---
paths:
  - "**"
---

# Safety-Critical Rules (A1)

CRITICAL: Load and follow `skills/safety/safety-critical.md` (canonical SSoT) before any destructive, privileged, or secret-touching action.

Fail-closed bootstrap guard: if the canonical file cannot be read, do not run destructive or privileged commands (`rm -rf`, `sudo`, `kubectl`, `terraform`, cloud provider CLIs) and do not read or expose `.env`, secrets, credentials, or tokens without explicit user approval.
