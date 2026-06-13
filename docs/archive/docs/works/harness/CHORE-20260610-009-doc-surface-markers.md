---
id: CHORE-20260610-009
priority: P2
status: Archived
risk: L2
scope: docs user/maintainer 표면 정리 요청을 "물리 이동" 대신 DR-021 logical marker로 처리(방안 A). #3 maintainer/README에 audience×distribution 분류 표 추가, #2 P1 "optional pack 재정의" 백로그에 docs/ 물리 레이아웃 재검토 라우팅, DR-021 Amendment History에 재검토 의문 기록(결정 불변). 물리 이동·scaffold 변경·DR 뒤집기 없음.
appetite: 0.25d
planned_start: 2026-06-10
planned_end: 2026-06-10
actual_end: 2026-06-10
related_dr: [DR-021]
related_troubleshooting: []
related_work: [CHORE-20260610-001]
---

# CHORE-20260610-009: Doc surface logical markers (방안 A)

## Top Summary

- **배경:** docs/ 하위에 user surface 문서를 모으자는 요청. 딥 영향도 체크 결과 4개 후보(WORKFLOW-MANUAL, SCAFFOLD-ONBOARDING-GUIDE, HARNESS-ARCHITECTURE, HARNESS-MAINTAINER-GUIDE)의 물리 이동은 **DR-021("물리 이동 보류, logical marker로 식별")과 maintainer/README("optional pack·온보딩 문서는 docs/ 루트 유지")를 정면으로 뒤집고**, ~50 참조 + scaffold rewiring + invariants test 변경을 요구함이 확인됨.
- **결정(사용자 A 채택):** 물리 이동하지 않는다. 목표(표면 명확화)는 DR-021이 채택한 수단(logical marker)으로 달성한다.
- **DR 개선 의문(사용자):** "DR-021 자체 개선 여지" 제기됨. reversal cost 논거가 flat-path 참조 방식에 종속된다는 관점은 재검토 가치 있음 → 즉흥 뒤집기 대신 P1 "optional pack 재정의"로 라우팅.

## 왜 maintainer/ 이동이 범주 오류인가

- `docs/maintainer/`는 "scaffold 어떤 옵션에서도 target에 복사되지 않는 source-only" 디렉토리(DR-021 Amendment 2026-06-10).
- HARNESS-ARCHITECTURE/MAINTAINER-GUIDE는 `--with-optional`로 **target에 복사되는** optional-pack → "절대 미배포" 디렉토리에 넣으면 불변식 위반.

## Scope / Plan

| # | 파일 | 작업 |
| --- | --- | --- |
| #3 | `docs/maintainer/README.md` | "여기에 두지 않는 것" 산문 → audience × distribution(core/optional-pack/source-only) 분류 표 (logical marker) |
| #2 | `docs/backlog/HARNESS.md` | P1 "Prompt surface diet + optional pack 재정의"에 docs/ 물리 레이아웃 재검토 + DR-021 reversal-cost(flat-path 종속) 재고 라우팅 |
| 기록 | `docs/decisions/DR-021-source-target-boundary.md` | Amendment History에 재검토 의문 라우팅 1줄 (결정 불변) |

## Done Criteria

- [x] maintainer/README에 audience × distribution 분류 표 추가, 기존 boundary 의미 보존
- [x] backlog P1 항목에 docs/ 레이아웃 재검토 + DR-021 논거 재고 라우팅 명시 (CHORE-20260610-009 링크)
- [x] DR-021 Amendment History에 재검토 의문 기록(결정 불변 명시)
- [x] 물리 이동 0 / scaffold·invariants test 무변경 확인, `git diff --check` clean, DR closure green

## Verification 결과

- 물리 이동 0: `scripts/create-harness.sh`(5)·`check-scaffold-invariants.sh`(1)가 여전히 `docs/` 루트 경로 참조, 4개 파일 위치 불변.
- `git diff --check` clean, shipped DR closure green(DR-021 seed 닫힘).
- 변경 5파일: maintainer/README(표), backlog/HARNESS(P1 라우팅), DR-021(amendment), works/README(index), Work 파일 신규.

## Verification

- `git diff --check`
- `grep -rn "docs/HARNESS-ARCHITECTURE\|docs/WORKFLOW-MANUAL" scripts/` 결과 불변(이동 없음 확인)
- `bash scripts/tests/check-shipped-dr-closure.sh` green (DR-021은 seed 닫힘 확인)

## Risk / Reversal

- 리스크: Low. 문서 marker 추가만, 코드·scaffold·경로 무변경.
- 되돌리기: Low. 표/문구 제거. branch 단위.

## Checkpoints

- (착수) 2026-06-10 branch `feature/chore-20260610-009-doc-surface-markers` + Work 파일.

## Next Actions

- maintainer/README 표 → backlog 라우팅 → DR-021 amendment → 검증 → `/work-close`.
