# STATUS.md

AI Workflow Harness repository의 현재 프로젝트 상태 문서다.
이 파일은 dashboard로 유지하고, 작업별 세부 계획과 기록은 `docs/works/`에 둔다.

Last updated: 2026-06-18 (release-prep: FEAT-20260618-001 archive + 1.3.0 target 정렬)

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
| 2026-06-20 | CHORE-20260620-001: `spring-modular-template` 5+ 사이클(FEAT-001~005, DR-030~033) code-product evidence review. 산출물을 durable routing payload로 — archive 결정 매몰 gap을 신규 candidate `Archive decision surfacing`으로 승격(auth-session 사례), resolver concept(`provides/requires/conflicts/modes`,`selected/resolved_packs`)을 template/scaffold 후보에, pack import principle/impl 분리를 option-pack 후보에, D-21 document-set delta를 신규 D-21 candidate에 등록. code-product only(no-code·manual adopter 미검증, 별도 gate). Codex B R1 request-changes→durable 강화, result conditional-approve→D-21 backlog 승격·3단 표 fix 반영. 구현·scaffold 미선점 | harness가 product 5사이클에 뒤처지지 않게 evidence 환류, archive-burial 재발 방지 | Low |
| 2026-06-19 | CHORE-20260619-001 / DR-040: deterministic source-parity 검사 2종(default-template, surface-mirror)을 pre-commit + ci.yml에 직접 배선. runner는 무배선 유지(DR-036 불변) — 이 둘은 manual runner에서만 실행되던 enforcement 공백이라 DR-036 "이미 강제됨" 논거 밖(독립 보완). CI=PR(main/develop)+push(main) backstop, pre-commit=commit 조기 차단, single-commit atomicity 요구, adopter SKIP. Codex red-team plan 조건부승인→반영, result Approved(P3 1건 반영) | template/mirror drift window를 release→commit/PR 시점으로 앞당김 | Low |
| 2026-06-18 | FEAT-20260618-001 / DR-039: Antigravity(Gemini 기반)를 4번째 지원 도구로 추가 — 별도 미러·진입 파일 없이 Codex `.agents/` surface consumer로 piggyback. root AGENTS.md 자동 로드 + `.agents/skills/` 자동 소비 실측 확정, 도구 나열 surface Claude→Codex→Antigravity→Cursor 정합, BEHAVIOR §6 self-audit 보강. cross-agent R1~R3(A=Claude/B=Codex/C=Antigravity) 반영. 부수: 선재 default-template-parity drift(work-brief row) 동반 수정. Exit Trigger로 엔진 분화 시 격리 재검토 | multi-agent 이식성 확장 + adopter 수요(실사용) | Medium |
| 2026-06-15 | CHORE-20260615-005: /work-brief canonical에 brief→DR soft handoff hook 강화(Phase 5 checklist + Phase 6 item 3) — Accepted-ready 수렴 시 /record-decision 제안, 강제 아님. adapter 무변경(canonical-only) | brief의 pre-decision 특성상 DR-worthy 결정이 묻히는 silent drift를 soft prompt로 보정(hard gate/진공 최적화 회피) | Low |
| 2026-06-15 | CHORE-20260615-004: docs/briefs/ live category 신설 + 방향성 문서 4건 retrospective→brief 재분류, /work-brief surface(canonical+3 adapter)·core routing·user-facing·scaffold·repo-health cascade 정합. archive snapshot no-action. Claude R1 Approved(F1~F3 Low: defer/keep/known-pattern) | 회고와 방향 비교 문서를 분리해 IA 정합 | Medium |
| 2026-06-15 | CHORE-20260615-003: `docs/maintainer/VERSIONING.md` 릴리즈 노트 템플릿에 `검증` 섹션을 필수화하고, 검증 command는 예시가 아닌 해당 릴리즈의 실제 최종 evidence set 전체를 fenced code block으로 남기도록 기준을 명문화 | `v1.2.1` release note 작성 과정에서 검증 표기 방식이 세션 판단에 의존했다. 승인 근거를 정직하게 남기되, 탐색·디버깅·재시도 명령은 제외해 릴리즈 노트 길이와 신뢰성을 함께 관리하기 위해 | Low |
| 2026-06-15 | CHORE-20260615-002 / DR-007 amend: 언어 정책을 DR-007 단일 authoritative SSoT로 통합 — Non-File Surfaces(commit/PR/agent console behavioral)+Default·Override 흡수, 산재 정의 정리(MAINTAINER-GUIDE=pure pointer, WORKFLOW-MANUAL Appendix C=최소 digest, GIT-WORKFLOW §5/rules=directive+pointer), AGENTS.md commit/PR/console inline(Codex 도달 fix), BEHAVIOR §5 console convention, README adopter note. DR-030은 전략-only로 경계 정리(Draft). Cross-agent(A=Claude/B=Codex) R1~R3: B P1(단일 override 모순)·P2(DR-030 내부 모순) 수용→DR-007 "authoritative SSoT+mirror 목록 규정"으로 재구성. 릴리즈=독립 PATCH(정합성 복구). 사용자 최종 승인 | Medium |
| 2026-06-14 | CHORE-20260614-001: post-release 결과 검증 최소 보완 — release "절차 수행"이 아니라 "결과 정합"을 잡는 1줄씩을 기존 절차에 흡수. sync 검증(`develop..main` empty)은 generic이라 루트 `GIT-WORKFLOW.md` §3-4 + scaffold 템플릿 §3-4 양쪽에 범용문, tag 정합(`ai-workflow-v{VERSION}`)은 source-only라 `VERSIONING.md` §3 step5에만. 독립 절차 블록 신설은 과잉으로 기각(§3-4/§2-5/VERSIONING 중복). release-prep §3-0 템플릿 반영도 leak-safe 재확인. Claude red-team(plan+result)+사용자 승인 | Low |
| 2026-06-13 | CHORE-20260613-020: W1~W5 완료 후 전체 정렬 검토 — `HARNESS-MAINTAINER-GUIDE.md` §5 Validation에 validation spine runner row, §9에 version-release sweep pointer(§3-1/Release Full Sweep/VERSIONING) 추가, `VERIFICATION-COMMANDS.md` scripts/tests cascade note를 3→6 스크립트로 현행화. 산출물 역추적 매트릭스(검증스크립트 6×3 문서, DR 30/30, command 등재) 검증 — gap은 MAINTAINER-GUIDE에 집중, README 2건(PLAN-SUMMARY/SCAFFOLD-BOOTSTRAP)은 의도된 제외/무관으로 비범위. **CHORE-20260613-017/018/019 archive 처리 동반.** Claude red-team(plan+result)+사용자 승인 | Low |

## Next Actions

> backlog는 확정 실행 계획이 아니라 의견 있는 portfolio view다. live 후보의 단일 source는 `docs/backlog/HARNESS.md`이며, 각 항목 착수 시 `/work-plan`에서 논리성·합리성·현재 product 적용 맥락을 다시 검토한다. 별도 Seq 축은 유지하지 않는다(CHORE-20260610-011 (B)).

W1~W4(Validation Spine / Adopter Transition 기반 / Workflow IA Diet / Enforcement & Lifecycle)는 종결됐다. 현재 live 후보와 우선순위·gate는 `docs/backlog/HARNESS.md`를 참조한다.

- **지금 막힘 없이 착수 가능한 P1:** Happy path / glossary / operator layering compression
- **외부 전제가 있는 P1:** `ai-deck-compiler` first real walkthrough (adopter target 접근 필요 — internal managed·packaging·DR-034의 선행 허브), 첫 concrete product planning-pack exercise (실제 product 착수 필요)
- **gated 후속:** internal managed mode(walkthrough 후, P2), packaging revisit(P3), sub-agent autonomy(P3, dormant), Spring Boot MSA pack(P2), template pack(P2) 등은 backlog의 gate 기준을 따른다
