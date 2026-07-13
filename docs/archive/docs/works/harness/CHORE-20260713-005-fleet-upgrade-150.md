---
id: CHORE-20260713-005
priority: P1
status: Archived
risk: L2
scope: spring-modular-template·ai-deck-compiler·rfx-hub를 ai-workflow-v1.5.0 released tag 기준으로 agent-first upgrade(CHORE-20260713-002 체크리스트). rebaseline 시 manifest가 신규 contract(provenance 3필드·hash_mode canonical·generated_at=rebaseline 날짜) 획득. spring은 DR-043 one-time migration 완료 상태 확인 후 AGENT-WORKFLOW framework-pure 교체(accepted-drift 해소), 대신 product-local 정제 rule 7종을 신규 accepted-drift로 보존(UF-04 evidence). toolstead는 비범위 — fresh-session canary 보류.
appetite: 0.5d
planned_start: 2026-07-13
planned_end: 2026-07-13
actual_end: 2026-07-13
related_dr: [DR-028, DR-043]
related_work: [CHORE-20260713-004, CHORE-20260713-002]
---

# CHORE-20260713-005: Fleet upgrade to 1.5.0 — 3 repo agent-first

## Top Summary

1.5.0 release(CHORE-20260713-004) 직후 fleet를 clean tag baseline으로 정렬한다. backlog W6 P1 candidate 착수. 핵심 판단(recon 실측):

| Repo | update | 신규 | 보존(accepted-drift) | 특이사항 |
| --- | --- | --- | --- | --- |
| spring | 6 (AGENT-WORKFLOW 포함) | +5 (cross-review·docs/user) | **rule 7종**(.claude/rules 3 + .cursor/rules 4 — 6/30 product-local 정제, UF-04 evidence) | **DR-043 migration 완료 확인**(PLAN-SUMMARY가 base package·gradle 검증 포함 전값 보유) → AGENT-WORKFLOW framework-pure 교체로 기존 accepted-drift 해소 |
| ai-deck | 4 | +5 | 기존 13종 유지 | AGENT-WORKFLOW·QUICK-REF 등은 base가 150에서 변해도 custom 보존(accepted-drift 지속) |
| rfx | 6 (AGENT-WORKFLOW 포함) | +5 | .gitignore 1종 | PLAN-SUMMARY 값 보유 확인 완료(오늘 -001 CP2) |

Manifest rebaseline은 1.5.0 신규 contract로: `source_ref: ai-workflow-v1.5.0` / `source_commit: f9bc74d…` / `source_dirty: false` / `hash_mode: source_template_raw` / `generated_at: 2026-07-13`(rebaseline 날짜 계약).

## Done Criteria

- [x] 3 repo가 1.5.0 baseline으로 upgrade — post-hoc `--check`(clean tag)에서 provenance **match**(skew 0) + 기대 drift만 잔존(spring 87/80/7 / ai-deck 83/70/13 / rfx 77/76/1, 전부 locally-modified·source-updated 0)
- [x] spring AGENT-WORKFLOW framework-pure 전환 + 값 유실 없음 확인 기록(CP1 — PLAN-SUMMARY가 base package·gradle 검증 포함 전값 보유)
- [x] 각 repo feature branch → PR → merge (spring #82, ai-deck #53, rfx #13)
- [x] toolstead canary 보류 기록 — backlog 후보를 canary-only로 재정의(측정 조건·체크리스트 포함)
- [x] 사용자 최종 리뷰 (2026-07-13 close 승인)

## Verification

- repo별 post-hoc `--check`(1.5.0 clean tag worktree — provenance 4분류 출력 확인), 보존 파일 무변경 diff 확인, `git diff --check`. Surface: adopter cascade.

## Risk / Reversal Cost

- spring rule 7종 오판(보존해야 할 정제본을 덮어씀) → recon diff로 식별 완료 + 적용 후 무변경 검증. 각 repo feature branch rollback 용이. **Reversal Cost: Low.**

## Discovery

- Archived: 2026-07-13 — close 시 즉시 archive(사용자 승인). 다음 세션 = clean idle + toolstead canary 추천 상태.

- 착수: 2026-07-13, backlog W6 "Fleet upgrade to 1.5.0" candidate 착수. cross-agent review는 생략(방법은 -002에서 검증·해제 확정, 대상 분류는 recon 실측 — 결과는 사용자 최종 리뷰로 확인).

## Checkpoints

### CP1 — Fleet upgrade 3건 완료 (2026-07-13)

| Repo | PR | post-hoc `--check` (clean 1.5.0 tag) | Provenance |
| --- | --- | --- | --- |
| spring-modular-template | #82 merged (93b66fa) | **87 / 80 / 7** — drift 전부 locally-modified(정제 rule 7종 보존), source-updated 0 | match — `ai-workflow-v1.5.0 @ f9bc74d`, dirty:false, skew 0 |
| ai-deck-compiler | #53 merged (230b504) | **83 / 70 / 13** — accepted-drift 13 전건 보존 | match(동일) |
| rfx-hub | #13 merged (230d386) | **77 / 76 / 1** — `.gitignore`만 advisory | match(동일) |

- spring **AGENT-WORKFLOW framework-pure 전환 완료** — DR-043 migration 상태 사전 확인(PLAN-SUMMARY Implementation Baseline이 base package·gradle 검증 포함 전값 보유, 유실 0), 기존 단일 accepted-drift 해소. 신규 accepted-drift set = product-local 정제 rule 7종(UF-04 evidence와 일치).
- 모든 manifest가 신규 contract 획득: provenance 3필드(clean tag·full commit·dirty:false) + `hash_mode: source_template_raw` + `generated_at: 2026-07-13`(rebaseline 날짜 계약 준수).
- **fleet 상태: 3/4 repo가 1.5.0 clean tag baseline + provenance. version-skew 잔존 0**(toolstead만 legacy — canary에서 해소 예정).
- toolstead: **착수하지 않음** — fresh-session canary 보류(diet canary gate 겸용). backlog W6에 canary 항목 유지 필요.
