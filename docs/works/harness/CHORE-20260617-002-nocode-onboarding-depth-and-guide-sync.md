---
id: CHORE-20260617-002
priority: P1
status: Done
risk: L2
scope: no-code onboarding depth (PLAN.md 목표 라우팅 + 운영-모델 step) + SCAFFOLD-ONBOARDING-GUIDE 정합/cascade
appetite: 1d
planned_start: 2026-06-17
planned_end: 2026-06-17
actual_end: 2026-06-17
related_dr: []
related_troubleshooting: []
related_work: [CHORE-20260617-001]
---

## Top Summary (결론 먼저)

no-code/content 프로젝트가 BOOTSTRAP의 code-centricity로 얇게 부팅되는 문제(PLAN.md 미작성, 운영-모델 step 부재)를 보강하고, SCAFFOLD-ONBOARDING-GUIDE를 BOOTSTRAP과 정합시킨다.
시발점: rfx-hub(content/research, no-code) 첫 대화형 온보딩 실측 — backlog "No-code/content onboarding depth" candidate.
함께: CHORE-20260617-001 intake hook의 GUIDE cascade 누락(§8 prompt step0) 동반 closure.
비목표: 코드 프로젝트 경로 변경(무회귀), planning-pack import review, intake hook 재설계.

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
|---|---|---|---|
| 1 | `scripts/create-harness.sh` | BOOTSTRAP §2/§3/§6 템플릿 | gap 1(목표 라우팅)·gap 2(운영-모델 step) 적용 |
| 2 | `docs/SCAFFOLD-ONBOARDING-GUIDE.md` | §2표·§7 diagram·§8/§16 prompt·§10·§11 | BOOTSTRAP 정합 + #209 cascade |
| 3 | `docs/backlog/HARNESS.md` | No-code onboarding depth 후보 | 착수 대상 |

Trigger: backlog candidate 착수 (No-code/content onboarding depth) / rfx-hub 실측 finding

## Scope

세 묶음:
- **A. gap 1 (PLAN.md 목표 라우팅):** BOOTSTRAP §2에 PLAN.md `## 목표` 작성(코드 무관) 추가, §6 Fill Order에서 목표(전 프로젝트) vs Project Initialization Plan(코드)을 분리. GUIDE §10과 일치시켜 모순 해소.
- **B. gap 2 (no-code 운영-모델 step):** BOOTSTRAP §3에 content/research/no-code 분기 — Implementation Baseline N/A 유지하되 운영/콘텐츠 모델(artifact 구조·taxonomy·수집/분류/재사용 workflow)을 PLAN.md에 기록하는 경량 step. 코드 경로 무회귀.
- **C. GUIDE 동기화:** §8·§16 복제 prompt에 step0(brief intake) 추가, intake 언급, §11/§7/§2표 no-code 분기 갱신.

**가드:** shipped BOOTSTRAP 템플릿은 source-only 경로 비인용. 코드 프로젝트 온보딩 경로 무변경.

## Done Criteria

- [x] BOOTSTRAP §2가 PLAN.md `## 목표`를 코드 무관 라우팅 (gap 1)
- [x] BOOTSTRAP §3에 no-code 운영-모델 step 추가, 코드 경로 무회귀 (gap 2)
- [x] BOOTSTRAP §6 Fill Order가 목표(전 프로젝트) vs Project Init(코드) 분리
- [x] GUIDE §8·§16 prompt에 step0 반영 (#209 cascade closure) — 2곳 parity 확인
- [x] GUIDE §10/§11/§7/§2표가 BOOTSTRAP과 정합 (+§8 step3 reword)
- [x] fresh no-code scaffold 시뮬레이션 + GUIDE prompt parity 확인
- [x] ship-guard: BOOTSTRAP 템플릿에 source-only 경로 비인용 (0건)

## Verification

- `bash -n scripts/create-harness.sh`
- fresh no-code/code scaffold 양쪽 BOOTSTRAP 렌더 확인
- BOOTSTRAP §8 ↔ GUIDE 복제 prompt step0 parity grep
- `grep -n "docs/maintainer" <generated BOOTSTRAP>` → 0
- `git diff --check`

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1  | BOOTSTRAP §2/§3/§6/§8 편집 | ✓ 완료 |
| 2  | GUIDE 동기화 (6곳) | ✓ 완료 |
| 3  | 검증 (bash -n, parity, ship-guard) | ✓ 완료 |
| 4  | /work-close + commit/PR | → 진행 중 |

## Next Actions

- ✓ BOOTSTRAP 템플릿 편집
- ✓ GUIDE 편집
- ✓ 검증
- → /work-close + commit 승인 요청

## Discovery

backlog "No-code/content onboarding depth" candidate 착수. CHORE-20260617-001 intake hook과 sibling — 둘 다 rfx-hub 실측에서 도출, GUIDE cascade를 공유.
설계: gap 1은 GUIDE §10이 이미 기대하는 라우팅에 BOOTSTRAP을 맞추는 방향(모순 해소). gap 2 운영-모델 step은 PLAN.md Initial Structure를 재활용해 최소 기록.
