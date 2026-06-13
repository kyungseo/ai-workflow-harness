---
id: CHORE-20260611-002
priority: P1
status: Archived
risk: L2
scope: 신규 product 착수 예정 메모를 HARNESS backlog에 반영한다. source-first product planning pack, scaffold repo 실행, source repo option-pack import loop를 추가하고 기존 coding guide pack 후보를 Spring Boot MSA TDD product engineering option-pack 후보로 재정의한다.
appetite: 0.25d
planned_start: 2026-06-11
planned_end: 2026-06-11
actual_end: 2026-06-11
related_dr: [DR-021, DR-023, DR-031]
related_troubleshooting: []
related_work: [CHORE-20260611-001]
---

# CHORE-20260611-002: Product starter pack backlog 반영

## Top Summary

- **목표:** 다음 신규 product 착수 전에 source repo에서 planning pack을 만들고, scaffold repo 실행 결과를 source repo option-pack 후보로 반입하는 loop를 backlog에 반영한다.
- **핵심 판단:** 기존 `Coding canonical optional pack`은 범위가 좁다. PRD/TRD/code conventions/user flow/DB design/screen/tasks/test structure/loop 절차까지 포함할 수 있는 product engineering pack 후보로 재정의한다.
- **범위:** backlog와 STATUS Next Actions 조정만 수행한다. 실제 base-msa-template 분석과 option-pack 구현은 후속 Work에서 다룬다.

## Scope / Plan

1. W2 Adopter Transition에 `Product starter planning pack + feedback import loop` 추가.
2. W5 Future / Optional의 coding guide pack을 `Spring Boot MSA TDD option-pack` 후보로 재정의.
3. STATUS Next Actions에 다음 product 착수 전 검토해야 할 항목으로 반영.

## Done Criteria

- [x] source-first planning pack → scaffold repo 주입 → source import loop가 backlog에 명시됨.
- [x] base-msa-template 분석 범위와 초기 하네스 잔재 제외 원칙이 backlog에 반영됨.
- [x] product-local harness 후보(PRD/TRD/code conventions/user flow/DB design/screen/tasks/test/loop)가 backlog에 반영됨.
- [x] 기존 coding guide pack 후보가 product engineering option-pack 후보로 재정의됨.

## Verification

- `rg`로 신규 항목과 option-pack 재정의 문구 확인.
- `git diff --check`
- `bash scripts/tests/check-shipped-dr-closure.sh`

## Risk / Reversal

- **리스크:** product-specific 계획이 source harness backlog에 너무 이르게 고정될 수 있다.
- **완화:** 실제 option-pack 편입은 product repo에서 검증된 뒤 별도 Work로 판단한다고 명시.
- **되돌리기 비용:** Low. 문서 후보 조정이며 branch 단위 revert 가능.

## Checkpoints

- 2026-06-11 — 사용자 제공 신규 product 착수 메모를 backlog portfolio에 반영. `Product starter planning pack + feedback import loop` 추가, `Spring Boot MSA TDD option-pack` 후보 재정의, STATUS Next Actions 갱신.

## Discovery

- CHORE-20260611-001 완료 후 사용자 추가 메모로 착수한 follow-up backlog 보완.
- Archived 2026-06-11: Done work 정리(routine), `/work-close` archive step.
