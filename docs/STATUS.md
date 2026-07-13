# STATUS.md

AI Workflow Harness repository의 현재 프로젝트 상태 문서다.
이 파일은 dashboard로 유지하고, 작업별 세부 계획과 기록은 `docs/works/`에 둔다.

Last updated: 2026-07-13 (fleet upgrade to 1.5.0 — 3/4 완료, toolstead canary 보류)

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
| 2026-07-13 | CHORE-20260713-005: fleet upgrade to 1.5.0 — spring(#82)·ai-deck(#53)·rfx(#13) 3건 agent-first 완료. post-hoc `--check`(clean tag) 전건 provenance match·skew 0·source-updated 0: spring 87/80/7(정제 rule 7종 = 신규 accepted-drift, **AGENT-WORKFLOW framework-pure 전환 — DR-043 migration 값 유실 0 확인**), ai-deck 83/70/13(전건 보존), rfx 77/76/1. 모든 manifest가 신규 contract(provenance 3필드·hash_mode canonical·generated_at=rebaseline) 획득. **toolstead는 의도적 보류 — fresh-session canary**(diet gate 겸용, backlog P1) | fleet를 released tag 균일 baseline으로 정렬해 후속 upgrade 비용 최소화 + canary 측정 기회 보존 | Low |
| 2026-07-13 | CHORE-20260713-004 / release `ai-workflow-v1.5.0`: source develop→main 1.5.0 minor 릴리즈. 구성 = DR-043 framework-pure AGENT-WORKFLOW + `/cross-review` workflow 신설 + manifest contract 정비(-003). cross-agent readiness(R1 conditional → F1~F3 반영 → R1b 기계 교정 → release-go), half-implemented 0, **MINOR 판정 적정**(reviewer 확인). release note 호환성 4항목(**DR-043 one-time migration 필수** 명시, "조치 불요"는 hash_mode/provenance 한정) + `/cross-review` manual-relay 경계. **fleet upgrade는 release Work에서 분리**(R1-F3 lifecycle deadlock 해소) — backlog W6 P1(spring·ai-deck·rfx + toolstead fresh-session canary 보류) | fleet 균일 baseline 요구를 DR-028 정합 경로(released tag)로 충족 — develop 직접 반영안은 version-skew 재생산이라 기각 | Medium |
| 2026-07-13 | CHORE-20260713-003: manifest contract 정비 — `--check` parser **python3 단일화**(fail closed, pretty-print/compact 정상 판정), manifest **structured provenance**(`source_ref`/`source_commit`/`source_dirty`) + version-skew 4분류 판정(same-version+commit-delta만 WARN), `hash_mode` canonical `source_template_raw`+legacy alias, `generated_at`=rebaseline 날짜 계약, per-file hash=authoritative 우선순위 playbook 문서화. behavior matrix 20 case + invariant delegation 회귀 tier2 편입. legacy adopter 하위호환 유지(toolstead 83/83). cross-review 5라운드(R0 request-changes→R0b approve→R1 request-changes→R1b request-changes→R1c approve) — reviewer가 구현 결함 5건+2건을 실측 fixture로 적발·교정 | version-skew 3/3 실측과 CP2 pretty-print 함정의 구조적 해소 — upgrade 절차 diet(agent-first 정식화)의 선행 계약 확보 | Low~Medium |
| 2026-07-13 | CHORE-20260713-002: ai-deck 1.3.0→1.4.0 agent-first upgrade replay 성공(`--check` 78/65/13, accepted-drift 13/13 보존, reviewer 독립 재검증 hash 78/78) → **축② provisional 해제 확정 — "manifest 보유 heterogeneous target의 agent-first upgrade 방향" 한정**(비오염 operator·external manual adopter·pre-manifest 경로는 residual). 후속 W6 등록: upgrade 절차 diet(canary gate — 비오염 1건 또는 fresh-session canary 재검증 전 default 전환·playbook 삭제 금지), DR-034 manifest-target 분기 amend(pre-manifest shadow baseline 유효 유지). version-skew 3/3 실측(ai-deck도 1.4.0 직전 develop 스냅샷) → manifest contract 정비 근거 확정. ai-deck PR #52 merged. cross-review R1(Codex conditional→consensus, 해제 가 판정) | agent-first 방향의 bounded validation을 reviewer 독립 검증 하에 확정하고 driver self-판정을 방지(사용자 지적으로 review 추가) | Low |
| 2026-07-13 | CHORE-20260713-001: 3주 휴면 후 direction review — **전면 rewrite 불필요** 공식화, 4축 판정(① policy retain / ② upgrade refactor-**provisional** / ③ projection rule-surface 한정 / ④ enforcement 보완, brief `harness-longterm-durability-review-20260713`). rfx-hub 1.2.1→1.4.0 agent-first upgrade 실험(rfx PR #12 merged)으로 축② feasibility 실증(71/72 in-sync) — heterogeneous replay(ai-deck) 전까지 script/playbook 축소 금지. spring UF-01~08 intake(신규 7행+details, UF-04 흡수), adopter 4-repo 정정(version-skew 2건 발견), backlog W6 cluster 등록. bounded heuristic("deterministic contract·verification 있을 때 agent 위임 기본 후보")은 DR 아닌 brief 가설. cross-review R0/R0b/R1/R1b(Claude driver / Codex reviewer) 합의 종결 | stale backlog 위에서 P1을 고르는 순서 오류 방지 + 사용자 방향 가설("절차 기계장치 대신 checklist+agent")의 evidence-bounded 검증 | Low |
| 2026-06-24 | CHORE-20260624-003: 구버전 manifest-target upgrade helper / accepted-drift schema는 **defer / monitor-only** 결정(설계 Work). DR-043이 AGENT-WORKFLOW accepted-drift(가장 구체적 `[5]` 반복 case)를 닫아 schema(축 ⓑ) 근거 약화, 절차는 playbook/Layer T로 닫힘(축 ⓐ 노동만 잔존). 새 helper/schema 미구현, low-cost `--check output 개선`만 trigger-gated future. numeric trigger(adopter upgrade 2건+ 동일 rebaseline 오류 또는 AGENT-WORKFLOW 외 framework accepted-drift 반복) 충족 시 후속 Work. DR-034 Draft 유지(non-promotion). backlog residual downscope. cross-review R0/R1(Codex approve) | 표본 2건으로 도구/schema를 과대 설계하지 않고 evidence-bounded defer | Low |
| 2026-06-24 | CHORE-20260624-002 / DR-043(Accepted Amended): framework-owned core 문서(`AGENT-WORKFLOW.md`)는 product-specific 값을 담지 않고 pointer만 둔다. product runtime/build/architecture/base-package + project 검증 명령의 home = `PLAN-SUMMARY.md` Implementation Baseline(scaffold가 이미 생성하는 owned 섹션; derived 규칙은 그 섹션만 예외). framework convention(`Active state file`)·Verification framework defaults는 AGENT-WORKFLOW 유지. 기존 adopter는 one-time migration(분류 gate, 값 유실 방지) 필수. EXECUTE-전 home을 PLAN.md→PLAN-SUMMARY로 amend(scaffold 현실 보존). cross-review R0/R1(Codex), N3 replay로 spring divergence=product 값뿐 확인 | CHORE-20260624-001에서 남은 `AGENT-WORKFLOW.md` 단일 accepted-drift(adopter upgrade마다 invariant `[5]` 반복 실패)의 근본 원인을 닫기 위해 | Medium |
| 2026-06-24 | CHORE-20260624-001: spring-modular-template framework surface를 `ai-workflow-v1.4.0` tag baseline으로 upgrade. shadow re-scaffold(spring-boot/source-gitflow)로 11개 framework 파일 adapt-render + `.harness/manifest.json` whole-replace rebaseline, `docs/AGENT-WORKFLOW.md` accepted-drift 보존. `--check` 82/81/1(AGENT 단일 accepted), invariant `[1]~[4] OK`/`[5] expected`. cross-review(R0/R0b/R1, Claude driver·Codex reviewer): R0b에서 `--check` source-updated=manifest hash 신호라 content copy만으론 drift 미해소 + adapt-render 필수 발견. spring PR #13(feature→develop)+#14(develop→main) merged. source-only maintainer 보강 3건(playbook Phase4·6, VERIFICATION T2 — shipped baseline 무영향) | manifest-target adopter를 released baseline으로 정합화하고 upgrade 절차 공백(rebaseline/adapt-render/profile match)을 maintainer 문서에 못박기 위해 | Medium |
## Next Actions

> backlog는 확정 실행 계획이 아니라 의견 있는 portfolio view다. live 후보의 단일 source는 `docs/backlog/HARNESS.md`이며, 각 항목 착수 시 `/work-plan`에서 논리성·합리성·현재 product 적용 맥락을 다시 검토한다. 별도 Seq 축은 유지하지 않는다(CHORE-20260610-011 (B)).

W1~W4(Validation Spine / Adopter Transition 기반 / Workflow IA Diet / Enforcement & Lifecycle)의 기반 작업은 종결됐다. 2026-07-13 direction review(CHORE-20260713-001) 결과 **전면 rewrite 불필요**가 공식화됐고, 실행 후속은 backlog **W6. Durability Follow-up** cluster가 evidence-gated로 관리한다(판정 상세: brief `harness-longterm-durability-review-20260713.md`).

- **첫 착수 추천:** **toolstead 1.5.0 fresh-session canary upgrade** (W6, P1) — **반드시 새 세션에서** 최소 체크리스트만으로 수행(diet canary gate 겸용, 절차 playbook 참조 금지). 완료 시 fleet 4/4 + skew 잔존 0. 그 다음 **Upgrade 절차 diet**(P2 — canary 측정이 gate 판정 입력). fleet 3건(spring·ai-deck·rfx)은 CHORE-20260713-005로 완료됨.
- **지금 막힘 없이 착수 가능한 P1:** Happy path / glossary / operator layering compression, Safety rule layer 정규화(축 A).
- **handoff-backed P1:** First concrete planning-pack evidence review (`spring-modular-template` handoff 결과 + fresh no-code follow-up). Spring repo의 PRODUCT backlog normalization 결과는 이 source evidence review의 입력으로만 소비한다.
- **W6 P2 후속:** UF-06 auto-merge default → thin-adapter화(순서 고정), UF-08 scaffold deny quick-fix, UF-01 product CI seam. P3: DR-034 manifest-target 분기 amend.
- **monitor-only / deferred:** upgrade helper residual(P3 — manifest contract 정비가 축ⓐ 흡수 가능), planning-pack skeleton/scaffold integration(trigger-gated), Spring modular/product engineering option-pack(trigger-gated, UF-04 evidence 흡수됨).
- **gated 후속:** DR-034 promotion/amend 판단(agent-first replay 결과 입력), DR namespace successor(DR-042 Policy Horizon gated), internal managed mode(P2), packaging revisit(P3), sub-agent autonomy(P3, dormant), project-state template pack(P2) 등은 backlog의 gate 기준을 따른다.
