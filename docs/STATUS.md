# STATUS.md

AI Workflow Harness repository의 현재 프로젝트 상태 문서다.
이 파일은 dashboard로 유지하고, 작업별 세부 계획과 기록은 `docs/works/`에 둔다.

Last updated: 2026-07-13 (CHORE-20260713-007 완료 — safety rule layer 4툴 정규화, DR-044)

## Current State

| Field | Value |
| --- | --- |
| Current phase | AWH-004 — Maintenance & Adoption |
| Current focus | Durability follow-up(축②③④ evidence-gated, backlog W6), UF intake 반영, planning-pack evidence review |
| Project plan | `docs/PLAN.md` |
| Harness backlog | `docs/backlog/HARNESS.md` |
| Quick reference | `docs/HARNESS-QUICK-REFERENCE.md` |
| Harness protocol | `docs/HARNESS-PROTOCOL.md` |
| Repository visibility | Public release ready |

## Work Context Rule

이 파일은 현재 작업 상태의 dashboard다.
세션 시작 시에는 `Current State`, `Active Work`, `Blockers And Open Questions`, `Next Actions`만 확인한다.
상세 실행 흐름은 `docs/AGENT-WORKFLOW.md`를 따른다.

## Active Work

| ID | Title | Work File |
| --- | --- | --- |

## Blockers And Open Questions

| ID | Status | Question | Decision Needed |
| --- | --- | --- | --- |

## Recent Decisions

| Date | Decision | Reason | Reversal Cost |
| --- | --- | --- | --- |
| 2026-07-13 | CHORE-20260713-007 / DR-044(Accepted): **safety rule layer 4툴 정규화(축 A)** — canonical SSoT `skills/safety/`(A1 실행 안전 always / A2 infra 안전 path-scoped, English — DR-007 amend), adapter는 thin projection(load directive+bootstrap guard, 전문 복제 금지), Codex/AG는 root `AGENTS.md` Safety Rule Layer 절로 소비(**repo-local 안전 surface 0 → 4툴 확보**). 승인 경계는 state-changing/destructive 한정 — read-only·bounded temp cleanup 허용(R1 실사용 결함 교정: 안전 rule이 deterministic runner를 차단하던 문제 해소, reviewer 독립 `--all` exit 0). scaffold default 편입(manifest tracked +5), `check-rule-surface-parity.sh` Tier 0d/2c 신설. evidence 경계: Codex current-entry runtime + AG contract/static (over-claim 금지). cross-review R0/R1(request-changes)→R1b(approve) | tool 간 safety coverage 비대칭(구조 결함) 해소 + 신규 scaffold default 일관성 — 사고 실적 아닌 구조 근거 (1-day bounded parity slice) | Medium |
| 2026-07-13 | CHORE-20260713-006 / upgrade 절차 diet: `docs/maintainer/ADOPTER-UPGRADE-AGENT-FIRST.md` **신설 — manifest-target upgrade의 default entry**(route 판정식 SSoT: "4개 조건 전부 충족 AND fallback override 없음 → default" + non-negotiable gate 4 + 최소 체크리스트 8단계). 기존 playbook은 **fallback 재배치**(pre-manifest·manual·고위험 — safety surface 전부 보존, Phase 4·6은 양 route 공용 authoritative). Layer T T0에 target clean·branch policy probe 명령 보강. two-route fresh-session simulation 2건 PASS + cross-review 5라운드(R0/R1/R1b request-changes → R1c approve) 후 default 전환 확정. **bounded heuristic 범용 DR 승격은 보류** — evidence가 manifest 보유 harness upgrade domain 한정, DR-034 amendment 입력 문구로만 기록(W6 P3) | 절차 문서를 default 계약 경로와 fallback 절차 경로로 이층화해 upgrade 노동을 줄이되, unobserved residual 경로(pre-manifest·external manual)의 safety surface는 보존 | Low~Medium |
| 2026-07-13 | toolstead 1.5.0 **fresh-session canary 성공**(toolstead PR #41, source Work 없음 — backlog candidate 직접 종결): 비오염 세션이 playbook·과거 기록 없이 계약(manifest)+도구(`--check` 자가 발견)만으로 upgrade 완수 — rebaseline 해법(tag-pinned worktree 재생성) 독립 재발명, hash 세대 함정 자가 진단, 83/83/0, 질문 0회·스텝 ~8. **R1-Codex-F6 canary gate 충족 → Upgrade 절차 diet(P1 승격) 착수 개방**, bounded heuristic DR 승격 재평가 trigger 발동(diet Work decision 항목). **fleet 4/4 released baseline — version-skew 잔존 0** | 절차 문서의 필요성을 비오염 실측으로 최종 검증 — diet gate의 마지막 조건 충족 | Low |
| 2026-07-13 | CHORE-20260713-005: fleet upgrade to 1.5.0 — spring(#82)·ai-deck(#53)·rfx(#13) 3건 agent-first 완료. post-hoc `--check`(clean tag) 전건 provenance match·skew 0·source-updated 0: spring 87/80/7(정제 rule 7종 = 신규 accepted-drift, **AGENT-WORKFLOW framework-pure 전환 — DR-043 migration 값 유실 0 확인**), ai-deck 83/70/13(전건 보존), rfx 77/76/1. 모든 manifest가 신규 contract(provenance 3필드·hash_mode canonical·generated_at=rebaseline) 획득. **toolstead는 의도적 보류 — fresh-session canary**(diet gate 겸용, backlog P1) | fleet를 released tag 균일 baseline으로 정렬해 후속 upgrade 비용 최소화 + canary 측정 기회 보존 | Low |
| 2026-07-13 | CHORE-20260713-004 / release `ai-workflow-v1.5.0`: source develop→main 1.5.0 minor 릴리즈. 구성 = DR-043 framework-pure AGENT-WORKFLOW + `/cross-review` workflow 신설 + manifest contract 정비(-003). cross-agent readiness(R1 conditional → F1~F3 반영 → R1b 기계 교정 → release-go), half-implemented 0, **MINOR 판정 적정**(reviewer 확인). release note 호환성 4항목(**DR-043 one-time migration 필수** 명시, "조치 불요"는 hash_mode/provenance 한정) + `/cross-review` manual-relay 경계. **fleet upgrade는 release Work에서 분리**(R1-F3 lifecycle deadlock 해소) — backlog W6 P1(spring·ai-deck·rfx + toolstead fresh-session canary 보류) | fleet 균일 baseline 요구를 DR-028 정합 경로(released tag)로 충족 — develop 직접 반영안은 version-skew 재생산이라 기각 | Medium |
| 2026-07-13 | CHORE-20260713-003: manifest contract 정비 — `--check` parser **python3 단일화**(fail closed, pretty-print/compact 정상 판정), manifest **structured provenance**(`source_ref`/`source_commit`/`source_dirty`) + version-skew 4분류 판정(same-version+commit-delta만 WARN), `hash_mode` canonical `source_template_raw`+legacy alias, `generated_at`=rebaseline 날짜 계약, per-file hash=authoritative 우선순위 playbook 문서화. behavior matrix 20 case + invariant delegation 회귀 tier2 편입. legacy adopter 하위호환 유지(toolstead 83/83). cross-review 5라운드(R0 request-changes→R0b approve→R1 request-changes→R1b request-changes→R1c approve) — reviewer가 구현 결함 5건+2건을 실측 fixture로 적발·교정 | version-skew 3/3 실측과 CP2 pretty-print 함정의 구조적 해소 — upgrade 절차 diet(agent-first 정식화)의 선행 계약 확보 | Low~Medium |
| 2026-07-13 | CHORE-20260713-002: ai-deck 1.3.0→1.4.0 agent-first upgrade replay 성공(`--check` 78/65/13, accepted-drift 13/13 보존, reviewer 독립 재검증 hash 78/78) → **축② provisional 해제 확정 — "manifest 보유 heterogeneous target의 agent-first upgrade 방향" 한정**(비오염 operator·external manual adopter·pre-manifest 경로는 residual). 후속 W6 등록: upgrade 절차 diet(canary gate — 비오염 1건 또는 fresh-session canary 재검증 전 default 전환·playbook 삭제 금지), DR-034 manifest-target 분기 amend(pre-manifest shadow baseline 유효 유지). version-skew 3/3 실측(ai-deck도 1.4.0 직전 develop 스냅샷) → manifest contract 정비 근거 확정. ai-deck PR #52 merged. cross-review R1(Codex conditional→consensus, 해제 가 판정) | agent-first 방향의 bounded validation을 reviewer 독립 검증 하에 확정하고 driver self-판정을 방지(사용자 지적으로 review 추가) | Low |
| 2026-07-13 | CHORE-20260713-001: 3주 휴면 후 direction review — **전면 rewrite 불필요** 공식화, 4축 판정(① policy retain / ② upgrade refactor-**provisional** / ③ projection rule-surface 한정 / ④ enforcement 보완, brief `harness-longterm-durability-review-20260713`). rfx-hub 1.2.1→1.4.0 agent-first upgrade 실험(rfx PR #12 merged)으로 축② feasibility 실증(71/72 in-sync) — heterogeneous replay(ai-deck) 전까지 script/playbook 축소 금지. spring UF-01~08 intake(신규 7행+details, UF-04 흡수), adopter 4-repo 정정(version-skew 2건 발견), backlog W6 cluster 등록. bounded heuristic("deterministic contract·verification 있을 때 agent 위임 기본 후보")은 DR 아닌 brief 가설. cross-review R0/R0b/R1/R1b(Claude driver / Codex reviewer) 합의 종결 | stale backlog 위에서 P1을 고르는 순서 오류 방지 + 사용자 방향 가설("절차 기계장치 대신 checklist+agent")의 evidence-bounded 검증 | Low |## Next Actions

> backlog는 확정 실행 계획이 아니라 의견 있는 portfolio view다. live 후보의 단일 source는 `docs/backlog/HARNESS.md`이며, 각 항목 착수 시 `/work-plan`에서 논리성·합리성·현재 product 적용 맥락을 다시 검토한다. 별도 Seq 축은 유지하지 않는다(CHORE-20260610-011 (B)).

W1~W4(Validation Spine / Adopter Transition 기반 / Workflow IA Diet / Enforcement & Lifecycle)의 기반 작업은 종결됐다. 2026-07-13 direction review(CHORE-20260713-001) 결과 **전면 rewrite 불필요**가 공식화됐고, 실행 후속은 backlog **W6. Durability Follow-up** cluster가 evidence-gated로 관리한다(판정 상세: brief `harness-longterm-durability-review-20260713.md`).

- **첫 착수 추천 (막힘 없이 착수 가능한 P1):** Happy path / glossary / operator layering compression. (Upgrade 절차 diet = CHORE-20260713-006 완료 — 축② 종결. Safety rule layer 정규화 = CHORE-20260713-007 완료 — 축 A 종결, DR-044.)
- **handoff-backed P1:** First concrete planning-pack evidence review (`spring-modular-template` handoff 결과 + fresh no-code follow-up). Spring repo의 PRODUCT backlog normalization 결과는 이 source evidence review의 입력으로만 소비한다.
- **W6 P2 후속:** UF-06 auto-merge default → thin-adapter화(순서 고정), UF-08 scaffold deny quick-fix, UF-01 product CI seam. P3: DR-034 manifest-target 분기 amend.
- **monitor-only / deferred:** upgrade helper residual(P3 — manifest contract 정비가 축ⓐ 흡수 가능), planning-pack skeleton/scaffold integration(trigger-gated), Spring modular/product engineering option-pack(trigger-gated, UF-04 evidence 흡수됨).
- **gated 후속:** DR-034 promotion/amend 판단(agent-first replay 결과 입력), DR namespace successor(DR-042 Policy Horizon gated), internal managed mode(P2), packaging revisit(P3), sub-agent autonomy(P3, dormant), project-state template pack(P2) 등은 backlog의 gate 기준을 따른다.
