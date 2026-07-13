# Infrastructure Rules (A2 — Infra Safety)

Canonical rule document (SSoT) for infrastructure, deployment, and environment work.
This is not an invokable Codex skill — tool adapters project this rule (see `skills/safety/README.md`).
Applies path-scoped: when working on `infra/**`, `.devcontainer/**`, Dockerfile, or docker-compose files.

MUST:

- Treat infrastructure, deployment, and environment changes as high-impact.
- State the risk and reversal cost before implementation.
- Prefer render, dry-run, or read-only verification before applying changes.
- Keep local, dev, staging, and production assumptions explicit.

NEVER:

- Run state-changing `kubectl`, `terraform`, or cloud provider CLI actions (apply, create, delete, scale), or destructive Docker/database commands, without explicit approval. Read-only / query / render / validate / dry-run inspection that does not read secrets is allowed.
- Store secrets in tracked files.
- Expose Actuator, internal services, or databases publicly by default.
