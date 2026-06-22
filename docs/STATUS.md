# STATUS.md

AI Workflow Harness repository의 현재 프로젝트 상태 문서다.
이 파일은 dashboard로 유지하고, 작업별 세부 계획과 기록은 `docs/works/`에 둔다.

Last updated: 2026-06-22 (CHORE-20260622-003 closeout)

## Current State

| Field | Value |
| --- | --- |
| Current phase | AWH-004 — Maintenance & Adoption |
| Current focus | 1.4.0 minor 릴리즈 prep (develop→main), adopter upgrade/migration, onboarding 현행화 |
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
| 2026-06-22 | CHORE-20260622-002 / release `ai-workflow-v1.4.0`: source `develop→main` 1.4.0 minor 릴리즈. cross-agent(A=Claude/B=Codex, R1·R2) readiness 합의(release-go 조건부, half-implemented 0). VERSION 1.3.0→1.4.0(DR-028 MINOR, v1.3.0 tag 충돌 해소), §3-1 Public Clean Baseline final gate PASS, 사용자 친화 release note(compatibility 3항목). DR-034 Draft·spring framework upgrade는 명시적 non-blocking | 1.3.0 이후 develop 누적분(DR namespace policy·adopter playbook·source-ref baseline·parity gate·archive surfacing)을 의도적 release 이벤트로 공개 | Medium |
| 2026-06-22 | CHORE-20260622-001: DR namespace 방향을 cross-agent red-team(R1~R4)으로 검토 후 **① high-band 유지** 확정(②b product-only prefix·③ directory는 deferred successor). DR-042에 `Policy Horizon / Deferred Successor` amendment(1.x 단기 정책, prefix 전환 시 fixture-driven token-grammar spike 전제, `--check` product tracking Deferred). `spring-modular-template` product DR `001/030~033 → 800~804` real-apply + spring `main` 반영(PR #11/#12). ai-deck와 함께 high-band 적용 adopter 2건. DR-034는 무변화(spring=manifest target, #1 UNMET) | 구조적으론 prefix/directory가 깔끔하나 현재 adopter 수·도구 blast radius·ai-deck 매몰 비용을 고려해 단기 비용 최적해로 high-band 유지. 후회 방지로 successor 경로를 정책에 명시 | Medium |
| 2026-06-21 | CHORE-20260621-006 / DR-028 amendment: adopter upgrade/apply evidence의 source-ref baseline 기본값을 released `main`/release tag로 명시. `develop`/current checkout probe는 pre-release tracking 예외 라벨과 source branch/HEAD/`git describe` 기록 필수. `scripts/create-harness.sh --check`는 source ref를 출력하고 clean release tag가 아니면 WARN을 낸다. DR-034에는 manifest baseline vs source-ref baseline 경계를 cross-pointer로 분리 | CHORE-005에서 `VERSION=1.3.0` parity가 main/develop 차이를 가리는 blind spot을 확인했고, upgrade evidence가 operator checkout에 따라 비결정적으로 해석되는 문제를 닫기 위해 | Medium |
| 2026-06-21 | CHORE-20260621-004 / DR-042: adopter/product DR namespace를 high-band로 분리(framework/source=799번 이하, product/adopter-local=800–999번, 정확히 3자리 `DR-NNN`만 허용, `PDR-`/4자리 ID는 도구 cascade 전 금지). `ai-deck-compiler` 실제 apply 완료(PR #51 merged): product DR `014/021/022/023` → `801/802/803/804`, decision-index 생성, `--check` 78/65/13 with accepted-drift, invariant `[1]~[4]` PASS(`[5]` expected). DR-034 actual target migration evidence 1건 확보, 단 Accepted 승격은 보류하고 Draft 유지 | CHORE-003에서 발견한 real-apply blocker(product DR namespace collision)를 정책으로 닫고 실제 adopter repo까지 적용하기 위해 | Medium |
| 2026-06-21 | CHORE-20260621-003: ai-deck real-apply 직전 rehearsal(temp result tree). migration body는 defend 가능(framework surface migration + source-retired 20 제거 + 3-way 30블록 stance 보존 + accepted-drift 13 + leak 0, `--check` 78/65/13, invariant 0-drift fail은 F1 expected). 그러나 실제 ai-deck apply 미수행 → real-apply blocker로 adopter product DR namespace 충돌 발견(framework `DR-014-archive` vs adopter `DR-014-ppt` + product `021/022/023` 번호공간). DR-034 "실제 target migration" condition은 **UNMET** — promotion evidence 후보만 기록(Draft 유지). 후속 Work(reserved high-band 정책 + DR renumber cascade + decision-index + real apply)로 re-scope. Claude A / Codex B cross-agent. RF2: `PDR-`는 `DR-[0-9]{3}` 도구 cascade 없이 quick fix 금지 | 정책 공백을 temp 검증이 아니라 실제 apply 경로에서 발견한 것이 차별 가치 | Medium |
| 2026-06-21 | CHORE-20260621-002: ai-deck-compiler pre-manifest baseline-acquisition 재실측(temp-only). current source `78 tracked → 0 drifted` 수렴은 `CLAUDE.md`/`AGENTS.md`/`.gitignore`+session-start prompt 포함 32개 locally-modified를 덮어쓴 **overwrite-convergence**이며 preservation-safe 아님. DR-034에 customized framework entrypoint=blind overwrite 금지·manual merge 규칙 durable 추가. 실제 target apply 미수행 → backlog 후보를 real adopter 마이그레이션 residual로 re-scope. internal managed gate defer. Codex A / Claude B cross-agent | 가장 오래된 adopter에서 baseline 경로 regression 재확인 + customized-entrypoint 보존 공백을 정책에 못박기 위해 | Medium |
| 2026-06-21 | CHORE-20260621-001: archive-burial 방지를 backlog auto-row가 아닌 lightweight triage prompt로 한정. `/work-close`는 Done 처리 중(archive 결정 전) `Needs-Triage:` 메모를 Work `Discovery`에 남기고, archive-now 경로에서는 그 메모를 한 번 더 재표면화한다. `/session-start`는 archive 대기 Work에서 `Needs-Triage:` 줄만 읽어 fallback surface를 제공하며, stronger mechanism/DR은 2nd occurrence gate 뒤의 backlog residual로 유지 | auth-session buried-case는 adopter repo 1건이므로 source harness self-governance를 넘는 일반 메커니즘으로 과대 규약화하지 않고, lightweight closeout triage와 durable residual만 먼저 닫기 위해 | Low |
| 2026-06-20 | CHORE-20260620-003: Planning-pack template/scaffold integration은 first real walkthrough 전 low-regret decision으로 제한. D-24 no-copy 경계 유지, source template/checklist=1:many·target prepared brief/planning-pack instance=1:1(`code-product-informed`), `PRODUCT-STARTER-PLANNING-PACK.md`는 source-only guide 유지. `workflow-session-start`는 현행 manual 경로/텍스트 입력 default 유지, repo 밖/`.harness/planning-pack/` auto-scan 비채택. `create-harness.sh` 자동 배포·skeleton 경로·`.harness` seed·sibling convention은 first real walkthrough 이후 후보로 defer. Resolver metadata는 planning-pack model에서 제외하고 product engineering option-pack 후보로 route-out | 실제 `scaffold -> session-start -> bootstrap` walkthrough evidence 없이 경로·자동배포·자동탐색을 확정하면 CHORE-002의 evidence-bounded decision 원칙을 깨므로, 지금 안전한 경계만 닫고 residual을 live backlog에 남김 | Low |
## Next Actions

> backlog는 확정 실행 계획이 아니라 의견 있는 portfolio view다. live 후보의 단일 source는 `docs/backlog/HARNESS.md`이며, 각 항목 착수 시 `/work-plan`에서 논리성·합리성·현재 product 적용 맥락을 다시 검토한다. 별도 Seq 축은 유지하지 않는다(CHORE-20260610-011 (B)).

W1~W4(Validation Spine / Adopter Transition 기반 / Workflow IA Diet / Enforcement & Lifecycle)는 종결됐다. 현재 live 후보와 우선순위·gate는 `docs/backlog/HARNESS.md`를 참조한다.

- **지금 막힘 없이 착수 가능한 P1:** Happy path / glossary / operator layering compression. (이전 P1 `spring-modular-template` product DR namespace renumber/apply는 CHORE-20260622-001로 완료 — high-band 유지 결정 + spring `main` 반영)
- **외부 전제가 있는 P1:** 첫 concrete product planning-pack exercise (실제 product 착수 필요)
- **후속(별도 진행, backlog 등록됨):** `spring-modular-template` framework surface upgrade(CHORE-005 잔여 7 drift apply — renumber와 분리, cross-agent+단계 승인으로 진행), DR namespace successor(②b/③) 재검토(DR-042 Policy Horizon trigger gated)
- **릴리즈 (CHORE-20260622-002, 완료처리):** source `develop→main` 1.4.0 릴리즈 — cross-agent readiness 합의(release-go 조건부) + VERSION 1.4.0 bump + §3-1 final gate PASS 후 release event 실행. Work는 Archived
- **gated 후속:** DR-034 promotion 판단(high-band 적용 adopter 2건=ai-deck+spring이나 둘 다 manifest/agent-mediated 경로 → #1 pre-manifest shadow baseline 여전히 UNMET), internal managed mode(walkthrough 후, P2), packaging revisit(P3), sub-agent autonomy(P3, dormant), Spring Boot MSA pack(P2), template pack(P2) 등은 backlog의 gate 기준을 따른다
