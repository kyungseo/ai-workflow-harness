---
id: CHORE-20260611-003
priority: P1
status: Archived
risk: L2
scope: product starter planning pack 및 option-pack 관련 backlog를 마무리하기 전에 maintainer verification catalog, recovery validation 문서, scripts 구조를 검토하고 HARNESS backlog에 사전 보강 항목을 반영한다.
appetite: 0.25d
planned_start: 2026-06-11
planned_end: 2026-06-11
actual_end: 2026-06-11
related_dr: [DR-021, DR-023, DR-031]
related_troubleshooting: []
related_work: [CHORE-20260608-003, HRN-034, CHORE-20260611-001, CHORE-20260611-002]
---

# CHORE-20260611-003: Product pack verification backlog 사전 보강

## Top Summary

- **목표:** product starter planning pack과 Spring Boot MSA TDD option-pack 후보를 실행하기 전에 검증 문서와 scripts 구조의 빠진 축을 backlog에 반영한다.
- **핵심 판단:** `docs/maintainer/VERIFICATION-COMMANDS.md`는 scaffold/onboarding 검증 layer가 충분하지만, product starter planning pack, product-local harness, product repo → source repo import loop를 다루는 별도 layer가 없다.
- **범위:** 실제 `VERIFICATION-COMMANDS.md` 구현은 후속 Work로 남기고, HARNESS backlog와 STATUS Next Actions에 사전 보강 항목을 추가한다.

## Scope / Plan

1. `docs/maintainer/VERIFICATION-COMMANDS.md`, `docs/HARNESS-RECOVERY-VALIDATION.md`, `scripts/` 구조를 검토한다.
2. product starter/import loop 검증이 기존 Layer J/J-OB/T에 흡수 가능한지 판단한다.
3. 필요한 경우 HARNESS backlog에 별도 보강 항목을 추가하고 product starter/option-pack 항목과 연결한다.
4. STATUS Next Actions가 새 W1 검증 보강 항목을 가리키도록 조정한다.

## Done Criteria

- [x] maintainer verification catalog와 recovery validation의 역할 경계가 검토됨.
- [x] scripts 구조상 즉시 필요한 helper가 있는지 판단함.
- [x] `Product pack verification layer 보강` 항목이 HARNESS backlog에 추가됨.
- [x] product starter planning pack과 Spring Boot MSA TDD option-pack 후보에 해당 검증 layer 선행/연계가 반영됨.
- [x] STATUS Next Actions에 W1 후보로 반영됨.

## Verification

- `rg`로 신규 항목과 관련 포인터 확인.
- `git diff --check`
- `bash scripts/tests/check-shipped-dr-closure.sh`

## Risk / Reversal

- **리스크:** 검증 layer 항목이 실제 implementation 없이 backlog만 늘릴 수 있다.
- **완화:** W1 Validation Spine에 배치해 product starter 착수 전 검증 체계 보강으로 분리하고, scripts helper는 반복 필요가 확인될 때만 추가하도록 명시했다.
- **되돌리기 비용:** Low. 문서 후보 조정이며 branch 단위 revert 가능.

## Checkpoints

- 2026-06-11 — `VERIFICATION-COMMANDS.md`, `HARNESS-RECOVERY-VALIDATION.md`, `scripts/` 구조를 검토하고 product pack 검증 layer 후보를 backlog에 추가.

## Discovery

- `VERIFICATION-COMMANDS.md`는 Layer J/J-OB/Q로 scaffold, onboarding, hook simulation을 이미 다룬다.
- Layer T는 upgrade/migration placeholder이므로 product starter/import loop를 여기에 섞으면 역할이 흐려진다.
- `HARNESS-RECOVERY-VALIDATION.md`는 policy/judgment 문서로 유지하고 concrete commands는 maintainer catalog에 두는 구조가 적절하다.
- `scripts/`에는 `create-harness.sh`, `check-scaffold-invariants.sh`, `check-shipped-dr-closure.sh`만 있다. product planning pack/import helper는 아직 없으며, 현재는 checklist layer가 우선이다.
- Archived 2026-06-11: Done work 정리(routine), `/work-close` archive step.
