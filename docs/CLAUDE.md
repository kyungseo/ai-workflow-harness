# docs/CLAUDE.md

This file contains project operating rules for Claude Code.
It should stay phase-neutral so the same structure can be reused in other projects.

## Context Sources

Use these sources to understand project context.
This is a reference priority order, NOT the implementation process:

1. `CLAUDE.md` — shared operating contract
2. `docs/CLAUDE.md` — project operating rules
3. `docs/STATUS.md` — current state, active work, checkpoints, blockers
4. `docs/PLAN.md` — approved plan and architecture reference
5. `docs/backlog/*.md` or `docs/decisions/*.md` — candidate work and unresolved decisions
6. `docs/TODO/*.md` — completed phase task breakdowns or explicitly assigned detailed task lists
7. `docs/archive/*.md` — historical reference only

## Session Startup

MUST:

1. Read `CLAUDE.md`.
2. Read this file.
3. Read only the top/current sections of `docs/STATUS.md`.
4. Read the active plan or backlog only when needed for the requested work.
5. Summarize current state, proposed steps, verification, and risks before broad changes.

MUST NOT read all of `docs/PLAN.md`, all archived status, or all TODO files unless the task requires historical reconstruction.

## Work Management Model

The files below manage work context and state.
Actual execution still follows: plan -> approval -> implementation -> verification -> status update.

Every active item should have:

- ID
- priority
- status
- scope
- dependencies
- done criteria
- verification
- owner/notes when useful

Use `docs/STATUS.md` for the live board.
Use backlog files for candidate work.
Use `docs/TODO/*.md` only when a phase intentionally needs detailed task decomposition or when reviewing completed phase details.
Use archive files for completed phase history.

## Legacy Phase Task Files

`docs/TODO/TODO-BLOCK*.md` is NOT discarded.
Those files are Phase 1 detailed task breakdowns and remain useful for historical reconstruction, implementation rationale, and checkpoint details.

For new phases, default to:

- `docs/backlog/PHASE{n}.md` for prioritized candidate work.
- `docs/STATUS.md` for active work and checkpoint state.
- `docs/TODO/PHASE{n}/...` only when a large phase needs finer-grained task files.

Do not load Phase 1 TODO block files by default during Phase 2 work.

## Approval Boundaries

MUST wait for user approval before:

- starting implementation after a multi-step plan
- expanding scope beyond the approved item
- changing infrastructure, secrets, database data, or deployment behavior
- updating historical or strategic documents beyond the current task

Small, explicitly requested documentation updates may proceed directly.

## Project Constants

- Runtime: Java 21+
- Framework: Spring Boot 3.5.x
- Build: Gradle wrapper
- Architecture: Spring Boot microservices template
- Base package: `io.kyungseo.msa`
- Active state file: `docs/STATUS.md`
- Phase 1 archive: `docs/archive/phase1-status.md`
- Phase 1 plan archive: `docs/archive/phase1-plan.md`

## Verification Defaults

Prefer the narrowest valid verification:

- Java unit/module change: `./gradlew test`
- Build/config change: `./gradlew build`
- Gateway or integration flow: use the relevant documented checkpoint
- Documentation-only change: inspect diff and links

If verification cannot be run, report why and name the remaining risk.

## Documentation Rules

MUST:

- Keep `docs/STATUS.md` short and current.
- Move completed phase detail to `docs/archive/`.
- Keep `docs/PLAN.md` focused on approved direction, not task logs.
- Keep backlog entries actionable and verifiable.

NEVER duplicate the same long rule block across multiple instruction files.
