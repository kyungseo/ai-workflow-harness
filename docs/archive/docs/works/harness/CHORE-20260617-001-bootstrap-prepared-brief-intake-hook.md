---
id: CHORE-20260617-001
priority: P1
status: Archived
risk: L2
scope: BOOTSTRAP/onboarding에 prepared-brief intake hook 추가 — 입력 방식 안내 + session-start 선질문
appetite: 1d
planned_start: 2026-06-17
planned_end: 2026-06-17
actual_end: 2026-06-17
related_dr: []
related_troubleshooting: []
related_work: []
---

## Top Summary (결론 먼저)

scaffold-fresh onboarding이 "준비된 project brief가 있으면 적시에 받아 반영"하는 intake 경로를 갖도록 BOOTSTRAP/session-start를 보강한다.
시발점: rfx-hub live onboarding에서 미리 만든 핸드오프를 onboarding이 알아서 받지 않아 수동으로 끼워넣어야 했음.
비목표: planning-pack 산출물 포맷 자체 정의(이미 source-only 문서 존재), rfx-hub clean 재온보딩 end-to-end exercise(후속 validation), import candidate review(broader candidate scope).

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
|---|---|---|---|
| 1 | `scripts/create-harness.sh` | BOOTSTRAP 템플릿 heredoc (intro·§8) | intake preamble + §8 prompt step 0 추가 대상 |
| 2 | `skills/workflow/session-start.md` | Bootstrap-State Rule | 선질문 bullet 추가 대상 |
| 3 | `scripts/create-harness.sh` | README 템플릿 "### 첫 세션" | user-facing mirror |
| 4 | `docs/maintainer/PRODUCT-STARTER-PLANNING-PACK.md` | — | source-only 확인용(인용 금지 가드) |

Trigger: backlog candidate 착수 (HARNESS.md "First concrete planning-pack exercise (rfx-hub) + BOOTSTRAP prepared-brief intake hook + import review") / user observation: 준비된 brief를 onboarding이 적시에 안내·intake하지 못함

## Scope

prepared-brief intake hook을 generic onboarding 표면에 추가한다. 사용자가 미리 정리한 brief를 onboarding 시작 시 받아 §1·§2(·§4) 초안에 반영하고, 없으면 §1·§2 일괄 제출 또는 대화형으로 진행하며, 온보딩 종료 후에도 보강 가능함을 안내한다.

**가드:** shipped BOOTSTRAP 템플릿은 source-only(`docs/maintainer/…`) 경로를 인용하지 않는다. brief 포맷은 generic하게 기술한다. rfx-hub copy는 이번에 동기화하지 않는다(곧 삭제→재scaffold로 이 변경을 검증할 대상).

변경 표면:
- BOOTSTRAP intro preamble("온보딩 입력 방식") — 정의 + 3경로 + anytime-augment
- BOOTSTRAP §8 First Session Prompt — "0. brief intake" step prepend
- session-start Bootstrap-State Rule — 선질문+설명+3경로+anytime bullet
- README "### 첫 세션" — 간결 mirror

## Done Criteria

- [x] BOOTSTRAP intro에 "온보딩 입력 방식" preamble(정의·3경로·anytime) 추가
- [x] BOOTSTRAP §8 prompt에 brief intake step prepend
- [x] session-start Bootstrap-State Rule에 선질문 bullet 추가
- [x] README "### 첫 세션"에 mirror 추가
- [x] shipped BOOTSTRAP 템플릿에 source-only 경로 인용 없음(grep 확인 — 0건)
- [x] fresh temp-scaffold가 intake preamble·§8 step 포함해 렌더 (parity)
- [x] canonical↔adapter cascade clean (session-start adapter pointer-only 유지)

## Verification

- `bash -n scripts/create-harness.sh`
- fresh temp scaffold 후 BOOTSTRAP intro/§8 + README 첫 세션 diff parity
- `grep -n "docs/maintainer" <generated BOOTSTRAP>` → 0건
- session-start adapter 3종 grep → 출력 포맷 미복제 확인
- `git diff --check`

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1  | 4개 surface 구현 | ✓ 완료 |
| 2  | 검증(bash -n, parity, cascade, ship-guard) | ✓ 완료 |
| 3  | commit/PR | ✓ 완료 |

## Next Actions

- ✓ 4개 surface 편집
- ✓ 검증 실행
- ✓ /work-close (Done) + commit/PR
- ○ (candidate 후속) rfx-hub clean 재온보딩 end-to-end exercise + import review

## Discovery

backlog의 "First concrete planning-pack exercise (rfx-hub) + BOOTSTRAP prepared-brief intake hook + import review" candidate 착수.
이 Work는 candidate 중 **intake hook 구현** 부분만 다룬다. rfx-hub 재온보딩 end-to-end exercise와 import review는 candidate에 남는 후속 scope.
사용자 보강: brief 의미 설명 / 없을 때 일괄제출 옵션 / anytime-augment 안내 / README 반영 — 모두 반영. "붙여넣을 새 템플릿"은 §1·§2 기존 필드 재사용으로 대체(planning-pack source-only 인용 회피).
