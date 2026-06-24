# STATUS.md

AI Workflow Harness repository의 현재 프로젝트 상태 문서다.
이 파일은 dashboard로 유지하고, 작업별 세부 계획과 기록은 `docs/works/`에 둔다.

Last updated: 2026-06-24 (spring-modular handoff/backlog alignment)

## Current State

| Field | Value |
| --- | --- |
| Current phase | AWH-004 — Maintenance & Adoption |
| Current focus | Adopter evidence/backlog alignment, spring-modular handoff follow-up, planning-pack evidence review |
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
| 2026-06-24 | CHORE-20260624-003: 구버전 manifest-target upgrade helper / accepted-drift schema는 **defer / monitor-only** 결정(설계 Work). DR-043이 AGENT-WORKFLOW accepted-drift(가장 구체적 `[5]` 반복 case)를 닫아 schema(축 ⓑ) 근거 약화, 절차는 playbook/Layer T로 닫힘(축 ⓐ 노동만 잔존). 새 helper/schema 미구현, low-cost `--check output 개선`만 trigger-gated future. numeric trigger(adopter upgrade 2건+ 동일 rebaseline 오류 또는 AGENT-WORKFLOW 외 framework accepted-drift 반복) 충족 시 후속 Work. DR-034 Draft 유지(non-promotion). backlog residual downscope. cross-review R0/R1(Codex approve) | 표본 2건으로 도구/schema를 과대 설계하지 않고 evidence-bounded defer | Low |
| 2026-06-24 | CHORE-20260624-002 / DR-043(Accepted Amended): framework-owned core 문서(`AGENT-WORKFLOW.md`)는 product-specific 값을 담지 않고 pointer만 둔다. product runtime/build/architecture/base-package + project 검증 명령의 home = `PLAN-SUMMARY.md` Implementation Baseline(scaffold가 이미 생성하는 owned 섹션; derived 규칙은 그 섹션만 예외). framework convention(`Active state file`)·Verification framework defaults는 AGENT-WORKFLOW 유지. 기존 adopter는 one-time migration(분류 gate, 값 유실 방지) 필수. EXECUTE-전 home을 PLAN.md→PLAN-SUMMARY로 amend(scaffold 현실 보존). cross-review R0/R1(Codex), N3 replay로 spring divergence=product 값뿐 확인 | CHORE-20260624-001에서 남은 `AGENT-WORKFLOW.md` 단일 accepted-drift(adopter upgrade마다 invariant `[5]` 반복 실패)의 근본 원인을 닫기 위해 | Medium |
| 2026-06-24 | CHORE-20260624-001: spring-modular-template framework surface를 `ai-workflow-v1.4.0` tag baseline으로 upgrade. shadow re-scaffold(spring-boot/source-gitflow)로 11개 framework 파일 adapt-render + `.harness/manifest.json` whole-replace rebaseline, `docs/AGENT-WORKFLOW.md` accepted-drift 보존. `--check` 82/81/1(AGENT 단일 accepted), invariant `[1]~[4] OK`/`[5] expected`. cross-review(R0/R0b/R1, Claude driver·Codex reviewer): R0b에서 `--check` source-updated=manifest hash 신호라 content copy만으론 drift 미해소 + adapt-render 필수 발견. spring PR #13(feature→develop)+#14(develop→main) merged. source-only maintainer 보강 3건(playbook Phase4·6, VERIFICATION T2 — shipped baseline 무영향) | manifest-target adopter를 released baseline으로 정합화하고 upgrade 절차 공백(rebaseline/adapt-render/profile match)을 maintainer 문서에 못박기 위해 | Medium |
| 2026-06-22 | CHORE-20260622-002 / release `ai-workflow-v1.4.0`: source `develop→main` 1.4.0 minor 릴리즈. cross-agent(A=Claude/B=Codex, R1·R2) readiness 합의(release-go 조건부, half-implemented 0). VERSION 1.3.0→1.4.0(DR-028 MINOR, v1.3.0 tag 충돌 해소), §3-1 Public Clean Baseline final gate PASS, 사용자 친화 release note(compatibility 3항목). DR-034 Draft·spring framework upgrade는 명시적 non-blocking | 1.3.0 이후 develop 누적분(DR namespace policy·adopter playbook·source-ref baseline·parity gate·archive surfacing)을 의도적 release 이벤트로 공개 | Medium |
| 2026-06-22 | CHORE-20260622-001: DR namespace 방향을 cross-agent red-team(R1~R4)으로 검토 후 **① high-band 유지** 확정(②b product-only prefix·③ directory는 deferred successor). DR-042에 `Policy Horizon / Deferred Successor` amendment(1.x 단기 정책, prefix 전환 시 fixture-driven token-grammar spike 전제, `--check` product tracking Deferred). `spring-modular-template` product DR `001/030~033 → 800~804` real-apply + spring `main` 반영(PR #11/#12). ai-deck와 함께 high-band 적용 adopter 2건. DR-034는 무변화(spring=manifest target, #1 UNMET) | 구조적으론 prefix/directory가 깔끔하나 현재 adopter 수·도구 blast radius·ai-deck 매몰 비용을 고려해 단기 비용 최적해로 high-band 유지. 후회 방지로 successor 경로를 정책에 명시 | Medium |
| 2026-06-21 | CHORE-20260621-006 / DR-028 amendment: adopter upgrade/apply evidence의 source-ref baseline 기본값을 released `main`/release tag로 명시. `develop`/current checkout probe는 pre-release tracking 예외 라벨과 source branch/HEAD/`git describe` 기록 필수. `scripts/create-harness.sh --check`는 source ref를 출력하고 clean release tag가 아니면 WARN을 낸다. DR-034에는 manifest baseline vs source-ref baseline 경계를 cross-pointer로 분리 | CHORE-005에서 `VERSION=1.3.0` parity가 main/develop 차이를 가리는 blind spot을 확인했고, upgrade evidence가 operator checkout에 따라 비결정적으로 해석되는 문제를 닫기 위해 | Medium |
| 2026-06-21 | CHORE-20260621-004 / DR-042: adopter/product DR namespace를 high-band로 분리(framework/source=799번 이하, product/adopter-local=800–999번, 정확히 3자리 `DR-NNN`만 허용, `PDR-`/4자리 ID는 도구 cascade 전 금지). `ai-deck-compiler` 실제 apply 완료(PR #51 merged): product DR `014/021/022/023` → `801/802/803/804`, decision-index 생성, `--check` 78/65/13 with accepted-drift, invariant `[1]~[4]` PASS(`[5]` expected). DR-034 actual target migration evidence 1건 확보, 단 Accepted 승격은 보류하고 Draft 유지 | CHORE-003에서 발견한 real-apply blocker(product DR namespace collision)를 정책으로 닫고 실제 adopter repo까지 적용하기 위해 | Medium |
| 2026-06-21 | CHORE-20260621-003: ai-deck real-apply 직전 rehearsal(temp result tree). migration body는 defend 가능(framework surface migration + source-retired 20 제거 + 3-way 30블록 stance 보존 + accepted-drift 13 + leak 0, `--check` 78/65/13, invariant 0-drift fail은 F1 expected). 그러나 실제 ai-deck apply 미수행 → real-apply blocker로 adopter product DR namespace 충돌 발견(framework `DR-014-archive` vs adopter `DR-014-ppt` + product `021/022/023` 번호공간). DR-034 "실제 target migration" condition은 **UNMET** — promotion evidence 후보만 기록(Draft 유지). 후속 Work(reserved high-band 정책 + DR renumber cascade + decision-index + real apply)로 re-scope. Claude A / Codex B cross-agent. RF2: `PDR-`는 `DR-[0-9]{3}` 도구 cascade 없이 quick fix 금지 | 정책 공백을 temp 검증이 아니라 실제 apply 경로에서 발견한 것이 차별 가치 | Medium |
## Next Actions

> backlog는 확정 실행 계획이 아니라 의견 있는 portfolio view다. live 후보의 단일 source는 `docs/backlog/HARNESS.md`이며, 각 항목 착수 시 `/work-plan`에서 논리성·합리성·현재 product 적용 맥락을 다시 검토한다. 별도 Seq 축은 유지하지 않는다(CHORE-20260610-011 (B)).

W1~W4(Validation Spine / Adopter Transition 기반 / Workflow IA Diet / Enforcement & Lifecycle)의 기반 작업은 종결됐다. 현재 live 후보와 우선순위·gate는 `docs/backlog/HARNESS.md`를 참조한다.

- **지금 막힘 없이 착수 가능한 P1:** Happy path / glossary / operator layering compression.
- **handoff-backed P1:** First concrete planning-pack evidence review (`spring-modular-template` handoff 결과 + fresh no-code follow-up). Spring repo의 PRODUCT backlog normalization 결과는 이 source evidence review의 입력으로만 소비한다.
- **monitor-only / deferred:** adopter upgrade accepted-drift 표현 + upgrade helper(CHORE-20260624-001 residual, P3), planning-pack skeleton/scaffold integration(trigger-gated), Spring modular/product engineering option-pack(trigger-gated, source-ready 아님).
- **gated 후속:** DR-034 promotion 판단(high-band 적용 adopter 2건=ai-deck+spring이나 둘 다 manifest/agent-mediated 경로 → #1 pre-manifest shadow baseline 여전히 UNMET), DR namespace successor(②b/③) 재검토(DR-042 Policy Horizon trigger gated), internal managed mode(walkthrough 후, P2), packaging revisit(P3), sub-agent autonomy(P3, dormant), project-state template pack(P2) 등은 backlog의 gate 기준을 따른다.
