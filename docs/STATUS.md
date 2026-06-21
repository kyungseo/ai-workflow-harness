# STATUS.md

AI Workflow Harness repository의 현재 프로젝트 상태 문서다.
이 파일은 dashboard로 유지하고, 작업별 세부 계획과 기록은 `docs/works/`에 둔다.

Last updated: 2026-06-21 (CHORE-20260621-002 close)

## Current State

| Field | Value |
| --- | --- |
| Current phase | AWH-004 — Maintenance & Adoption |
| Current focus | 1.3.0 minor 릴리즈, adopter upgrade/migration, onboarding 현행화 |
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
| 2026-06-21 | CHORE-20260621-002: ai-deck-compiler pre-manifest baseline-acquisition 재실측(temp-only). current source `78 tracked → 0 drifted` 수렴은 `CLAUDE.md`/`AGENTS.md`/`.gitignore`+session-start prompt 포함 32개 locally-modified를 덮어쓴 **overwrite-convergence**이며 preservation-safe 아님. DR-034에 customized framework entrypoint=blind overwrite 금지·manual merge 규칙 durable 추가. 실제 target apply 미수행 → backlog 후보를 real adopter 마이그레이션 residual로 re-scope. internal managed gate defer. Codex A / Claude B cross-agent | 가장 오래된 adopter에서 baseline 경로 regression 재확인 + customized-entrypoint 보존 공백을 정책에 못박기 위해 | Medium |
| 2026-06-21 | CHORE-20260621-001: archive-burial 방지를 backlog auto-row가 아닌 lightweight triage prompt로 한정. `/work-close`는 Done 처리 중(archive 결정 전) `Needs-Triage:` 메모를 Work `Discovery`에 남기고, archive-now 경로에서는 그 메모를 한 번 더 재표면화한다. `/session-start`는 archive 대기 Work에서 `Needs-Triage:` 줄만 읽어 fallback surface를 제공하며, stronger mechanism/DR은 2nd occurrence gate 뒤의 backlog residual로 유지 | auth-session buried-case는 adopter repo 1건이므로 source harness self-governance를 넘는 일반 메커니즘으로 과대 규약화하지 않고, lightweight closeout triage와 durable residual만 먼저 닫기 위해 | Low |
| 2026-06-20 | CHORE-20260620-003: Planning-pack template/scaffold integration은 first real walkthrough 전 low-regret decision으로 제한. D-24 no-copy 경계 유지, source template/checklist=1:many·target prepared brief/planning-pack instance=1:1(`code-product-informed`), `PRODUCT-STARTER-PLANNING-PACK.md`는 source-only guide 유지. `workflow-session-start`는 현행 manual 경로/텍스트 입력 default 유지, repo 밖/`.harness/planning-pack/` auto-scan 비채택. `create-harness.sh` 자동 배포·skeleton 경로·`.harness` seed·sibling convention은 first real walkthrough 이후 후보로 defer. Resolver metadata는 planning-pack model에서 제외하고 product engineering option-pack 후보로 route-out | 실제 `scaffold -> session-start -> bootstrap` walkthrough evidence 없이 경로·자동배포·자동탐색을 확정하면 CHORE-002의 evidence-bounded decision 원칙을 깨므로, 지금 안전한 경계만 닫고 residual을 live backlog에 남김 | Low |
| 2026-06-20 | CHORE-20260620-002 / DR-041: D-21 document-set 경계 결정. Evidence 있는 4개 surface만 2축(ownership/nature)으로 판정 — `ADOPTER-RENAME`은 seed checklist=scaffold-seed, leak-check contract=source-template-owned; `TEMPLATE-ACCEPTANCE`는 shipped adopter artifact이되 pack evidence pointer만 유지; product DR set은 product-owned 적용 기록. `pack/{name}/README.md`를 supported runnable pack canonical local documentation으로 채택하고, D-21 design original §6.4의 `docs/packs/*` 경로 가정만 부분 supersede. `code-product-informed`, 첫 non-code/manual adopter에서 재검토 | product evidence가 `docs/packs/*`가 아니라 pack-local README에 수렴했고, D-21 전체가 아니라 경로 가정만 좁게 정리해야 후속 pack/scaffold 작업의 문서 위치 drift를 줄일 수 있음 | Medium |
| 2026-06-20 | CHORE-20260620-001: `spring-modular-template` 5+ 사이클(FEAT-001~005, DR-030~033) code-product evidence review. 산출물을 durable routing payload로 — archive 결정 매몰 gap을 신규 candidate `Archive decision surfacing`으로 승격(auth-session 사례), resolver concept(`provides/requires/conflicts/modes`,`selected/resolved_packs`)을 template/scaffold 후보에, pack import principle/impl 분리를 option-pack 후보에, D-21 document-set delta를 신규 D-21 candidate에 등록. code-product only(no-code·manual adopter 미검증, 별도 gate). Codex B R1 request-changes→durable 강화, result conditional-approve→D-21 backlog 승격·3단 표 fix 반영. 구현·scaffold 미선점 | harness가 product 5사이클에 뒤처지지 않게 evidence 환류, archive-burial 재발 방지 | Low |
| 2026-06-19 | CHORE-20260619-001 / DR-040: deterministic source-parity 검사 2종(default-template, surface-mirror)을 pre-commit + ci.yml에 직접 배선. runner는 무배선 유지(DR-036 불변) — 이 둘은 manual runner에서만 실행되던 enforcement 공백이라 DR-036 "이미 강제됨" 논거 밖(독립 보완). CI=PR(main/develop)+push(main) backstop, pre-commit=commit 조기 차단, single-commit atomicity 요구, adopter SKIP. Codex red-team plan 조건부승인→반영, result Approved(P3 1건 반영) | template/mirror drift window를 release→commit/PR 시점으로 앞당김 | Low |
| 2026-06-18 | FEAT-20260618-001 / DR-039: Antigravity(Gemini 기반)를 4번째 지원 도구로 추가 — 별도 미러·진입 파일 없이 Codex `.agents/` surface consumer로 piggyback. root AGENTS.md 자동 로드 + `.agents/skills/` 자동 소비 실측 확정, 도구 나열 surface Claude→Codex→Antigravity→Cursor 정합, BEHAVIOR §6 self-audit 보강. cross-agent R1~R3(A=Claude/B=Codex/C=Antigravity) 반영. 부수: 선재 default-template-parity drift(work-brief row) 동반 수정. Exit Trigger로 엔진 분화 시 격리 재검토 | multi-agent 이식성 확장 + adopter 수요(실사용) | Medium |
| 2026-06-15 | CHORE-20260615-005: /work-brief canonical에 brief→DR soft handoff hook 강화(Phase 5 checklist + Phase 6 item 3) — Accepted-ready 수렴 시 /record-decision 제안, 강제 아님. adapter 무변경(canonical-only) | brief의 pre-decision 특성상 DR-worthy 결정이 묻히는 silent drift를 soft prompt로 보정(hard gate/진공 최적화 회피) | Low |
## Next Actions

> backlog는 확정 실행 계획이 아니라 의견 있는 portfolio view다. live 후보의 단일 source는 `docs/backlog/HARNESS.md`이며, 각 항목 착수 시 `/work-plan`에서 논리성·합리성·현재 product 적용 맥락을 다시 검토한다. 별도 Seq 축은 유지하지 않는다(CHORE-20260610-011 (B)).

W1~W4(Validation Spine / Adopter Transition 기반 / Workflow IA Diet / Enforcement & Lifecycle)는 종결됐다. 현재 live 후보와 우선순위·gate는 `docs/backlog/HARNESS.md`를 참조한다.

- **지금 막힘 없이 착수 가능한 P1:** Happy path / glossary / operator layering compression
- **외부 전제가 있는 P1:** `ai-deck-compiler` 실제 adopter 마이그레이션 (baseline-acquisition 재실측=CHORE-20260621-002 완료, real apply 잔여 — manifest baseline + customized entrypoint merge + decision-index closure → DR-034 promotion·internal managed·packaging 선행 허브), 첫 concrete product planning-pack exercise (실제 product 착수 필요)
- **gated 후속:** internal managed mode(walkthrough 후, P2), packaging revisit(P3), sub-agent autonomy(P3, dormant), Spring Boot MSA pack(P2), template pack(P2) 등은 backlog의 gate 기준을 따른다
