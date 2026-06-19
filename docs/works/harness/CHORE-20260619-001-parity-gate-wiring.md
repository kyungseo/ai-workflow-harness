---
id: CHORE-20260619-001
priority: P2
status: Done
risk: L2
scope: Deterministic source-parity 검사 2종(check-default-template-parity.sh, check-surface-mirror-parity.sh)을 pre-commit + CI에 배선해 drift window를 닫을지, 무배선 유지가 나은지 재검토(DR-036 부분 재검토)하고 결론을 DR로 기록한다.
appetite: 0.5d
planned_start: 2026-06-19
planned_end: 2026-06-19
actual_end: 2026-06-19
related_dr: [DR-040, DR-036, DR-033, DR-020]
related_troubleshooting: []
related_work: []
---

# CHORE-20260619-001: Deterministic source-parity 검사 CI/pre-commit 배선 검토

## Top Summary

- **목표:** `check-default-template-parity.sh`·`check-surface-mirror-parity.sh` 2종을 commit/CI 시점에 자동 실행해 template/mirror drift를 도입 시점에 차단하거나, 무배선 유지가 낫다는 결론을 DR로 기록한다.
- **Discovery:** backlog의 "Deterministic source-parity 검사 CI/pre-commit 배선 검토 (DR-036 부분 재검토)" candidate 착수. backlog row에는 Work ID를 기입하지 않는다(병렬 NNN 충돌 방지).
- **author/driver:** Claude. **red-team reviewer:** Codex (plan 1회 + result 1회).
- **핵심 판단(잠정):** Option (a) 배선. DR-036의 무배선 근거("이미 ci.yml·pre-commit에서 강제됨")가 이 2종에는 **적용되지 않음** — 이 둘은 manual runner(tier0b/0c)에서만 실행되어 어떤 자동 표면에서도 강제되지 않는 enforcement 공백. 따라서 재론이 아니라 다른 fact pattern.

## Trigger (실측)

FEAT-20260618-001에서 source `.cursor/rules/workflow.mdc`의 `work-brief` routing row가 template default(`scripts/templates/default/**`)에 미동기된 drift가 #196(2026-06-15)~release 직전까지 약 2.5주 무탐지. release gate full sweep(`run-harness-checks --all`)이 안전망으로 main 전에 잡았으나, 도입~탐지 사이 window가 실재.

## 사전 확인 결과

| 항목 | 결과 |
|---|---|
| 두 스크립트 실측 런타임 | 각 ~50ms (deterministic, false-positive≈0) |
| 자동 표면 호출 여부 | **없음** — runner tier0b/0c(manual-only)에서만 실행 |
| pre-commit 패턴 | DR-closure가 existence-guard로 source-only 배선(adopter no-op) — 동일 패턴 재사용 가능 |
| ci.yml | scaffold assertion 다수, 두 parity 스크립트 호출 **없음** |
| adopter 안전성 | source 부재 시 스크립트 자체 SKIP(N/A), exit 0 |
| DR-036 residual note | 본 항목을 이미 "별도 backlog candidate(CI↔SSoT parity)"로 예고 |

## Scope / Plan

| # | 대상 | 변경 |
|---|---|---|
| C1 | `.github/workflows/ci.yml` | 신규 step 1개 — 두 스크립트 **직접 호출**(runner 경유 ✗ → 중복 부활 회피). **PR backstop**(server-side, PR→main/develop). direct develop push·PR 이전 미커버 → 그 구간은 pre-commit 담당 |
| C2 | `tools/git-hooks/pre-commit` | DR-closure 블록 다음 existence-guard 호출 추가 — source-only no-op in adopter. 조기 차단 |
| C3 | `docs/decisions/DR-040-*.md` (신규) | 배선 결정 + "DR-036 범위 밖" 근거. DR-036 residual cross-link |
| C4 | `docs/backlog/HARNESS.md` | candidate 정리 + Deferred "mirror atomicity(CI/hook)" 항목 정합(흡수) |

**배선 정책 결정점(Codex red-team 핵심):**
- (가) 표면: CI(필수) + pre-commit(조기) 둘 다 권고. "CI-only로 충분" 반론 검토.
- (나) pre-commit 무조건 실행 권고(staged-path gate 복잡도 회피).
- (다) 직접 호출 권고(runner 무배선 letter 보존).

## Done Criteria

- [x] 의도적 drift 주입 시 pre-commit + CI(로컬 시뮬)가 차단됨을 실증
- [x] adopter(소스 부재) 시 SKIP/no-op 정상 실증
- [x] DR-040 기록(배선 결정 + DR-036 범위 구분), DR-036 residual cross-link, DR README 인덱스 갱신
- [x] backlog candidate + Deferred mirror-atomicity 항목 정합 (candidate row 제거는 work-close)
- [x] Codex red-team: plan 1회 + result 1회 반영
- [x] 사용자 최종 리뷰 후 Done (2026-06-19 승인)

## Verification

- 의도적 drift 주입(template/mirror 한쪽 변경) → `tools/git-hooks/pre-commit` 차단 확인 + ci.yml step 로컬 시뮬(스크립트 직접 exit code)
- adopter 시뮬(`--root` 빈/소스 부재 디렉토리)로 SKIP 확인
- `sh -n tools/git-hooks/pre-commit`, ci.yml yaml 정합
- Surface: tool surface(hook/CI) · scaffold(adopter SKIP)

## 리스크 / 되돌리기 비용

- **Reversal cost: Low** — step/호출 추가만, 제거로 원복. 구조 부채 없음.
- pre-commit ~100ms 증가(무시 가능), false-positive≈0.
- 최대 리스크: 결정이 DR-036 재론으로 비칠 위험 → DR-040에서 fact-pattern 차이 명시로 차단.

## Checkpoints

- (착수) Work 파일 생성, feature/parity-gate-wiring branch, plan 사용자 승인 완료.
- (CP1) Codex plan red-team **조건부 승인**. 반영: ① C1 "authoritative"→"PR backstop"(ci.yml은 push:develop 없음, direct develop push 미커버) ② DR-040은 독립 보완 DR(supersede/amend ✗) ③ single-commit atomicity 요구 DR 명시 ④ CI step fail-fast 위치(scaffold 생성 전). CI+pre-commit 이중·직접 호출·무조건 실행은 권고대로 유지.
- (CP2) 구현 완료: ci.yml step(C1), pre-commit 호출(C2), DR-040+README(C3), backlog Deferred 정합(C4).
- (CP3) 검증 통과: drift 주입 시 양 script exit 1 차단, 복원 후 PASS, adopter `--root` SKIP exit 0, pre-commit hook end-to-end exit 0(실제 변경 staged).
- (CP4) Codex result red-team **Approved (one P3 note)**. P3 반영: ci.yml step 주석에 `push->main` 추가. P1/P2 결함 없음. 4대 조건 반영 확인됨.

## Next Actions

1. Codex plan red-team 의뢰 → 피드백 반영
2. C1~C4 구현
3. drift 주입 검증 + adopter SKIP 검증
4. Codex result red-team → 반영
5. `/work-close` + commit (STATUS pointer 제거 번들)
