---
paths:
  - "infra/**"
  - ".devcontainer/**"
  - "**/Dockerfile"
  - "**/docker-compose*.yml"
  - ".github/workflows/**"
---

# Infrastructure Rules

MUST:

- Treat infrastructure, deployment, and environment changes as high-impact.
- State the risk and reversal cost before implementation.
- Prefer render, dry-run, or read-only verification before applying changes.
- Keep local, dev, staging, and production assumptions explicit.

NEVER:

- Run `kubectl`, `terraform`, cloud provider CLIs, or destructive Docker/database commands without explicit approval.
- Store secrets in tracked files.
- Expose Actuator, internal services, or databases publicly by default.
