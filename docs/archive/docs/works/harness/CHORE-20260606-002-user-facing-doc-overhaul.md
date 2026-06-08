---
id: CHORE-20260606-002
priority: P1
status: Archived
risk: High
scope: Phase 2 slice #11 - canonical+adapter/no-alias command 구조를 source user-facing 문서와 scaffold target 설명에 반영한다.
appetite: 1w
planned_start: 2026-06-06
planned_end: 2026-06-13
actual_end: 2026-06-05
related_dr: [DR-007, DR-021, DR-023, DR-024]
related_troubleshooting: []
related_work: [CHORE-20260604-001, CHORE-20260606-003]
---

# CHORE-20260606-002: User-Facing Documentation Overhaul

## Top Summary

- **목표:** slice #13 이후 확정된 canonical `skills/workflow/` + hybrid adapter + no-alias command rename 구조를 사용자가 직접 읽는 문서와 generated scaffold 설명에 반영한다.
- **이번 Work 산출:** user-facing README/front-door 개편, quick reference/onboarding/generated scaffold text 정렬, manual narrow fix, canonical→manual 역참조 제거, Claude R36 승인, Work Done 처리.
- **구현 전제:** 충족됨 — R33 plan review, R35 구현, R36 result review 승인 완료.
- **비목표:** `ai-deck-compiler` target migration, commit gate runtime enforcement, archive semantics 재설계, scaffold PLAN/template 후속, `--upgrade` 구현.
- **상태 변경:** `docs/STATUS.md` Active Work pointer는 추가하지 않았으므로 제거할 pointer도 없다. Work 파일과 Work index만 Done으로 정리한다.

## Context Manifest

| 순서 | 파일 | 확인 내용 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md` | §10-b, OQ-11, OQ-18, user-facing decoupling 합의 | 이번 slice의 부모 planning SSoT |
| 2 | `docs/works/harness/CHORE-20260606-001-canonical-adapter-rename.md` | R31 결과, Discovery, no-alias rename/scaffold/manifest PASS | slice #13 완료 상태와 후속 boundary 확인 |
| 3 | `docs/MIGRATION-CANONICAL-ADAPTER-RENAME.md` | old -> new mapping, no runtime alias, active target migration 경계 | historical/migration note 예외 기준 |
| 4 | `README.md` | public front-door, command table, source/scaffold boundary, adoption path | 1차 개편 대상 |
| 5 | `docs/WORKFLOW-MANUAL.md` | command 설명, lifecycle 흐름, scaffold section, cascade/runbook 과밀 | 2차 개편 대상 |
| 6 | `docs/SCAFFOLD-ONBOARDING-GUIDE.md` | scaffold 직후 첫 세션, generated docs fill order, `/session-start` 예시 | target onboarding 설명 정합성 |
| 7 | `docs/HARNESS-QUICK-REFERENCE.md` | daily workflow command table, cascade summary | 짧은 user-facing reference |
| 8 | `prompts/README.md`, `prompts/*session-start.md` | session-start prompt surface와 command names | 필요한 경우만 cascade |
| 9 | `scripts/create-harness.sh` | generated README/STATUS/BOOTSTRAP/PLAN/backlog user-facing text | scaffold target 문구 반영 대상 |
| 10 | `docs/decisions/DR-007-language-policy.md` | docs/prompts/skills 언어 정책 | 신규/수정 문서는 한국어 primary + Bilingual Rules |
| 11 | `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md` | path-scoped docs/git guidance | Codex 수동 적용 rule reference |
| 12 | `docs/HARNESS-PROTOCOL.md` | Work File Decomposition, T11/T12/T14 cascade | user-facing/manual 변경 L2 및 verification 기준 |

## Scope Inventory

| Area | Current Signal | Proposed Treatment |
| --- | --- | --- |
| README front-door | 새 command 이름은 대체로 반영됐지만 source repo, scaffold product repo, canonical/scaffold 설명이 한 흐름에 길게 섞인다. | README를 먼저 정리해 adoption path, source/target boundary, command table의 기준 문서로 만든다. |
| `WORKFLOW-MANUAL.md` | 새 command 표와 예시는 반영됐지만 긴 runbook/cascade/trigger 설명이 user-facing manual에 과밀하게 남아 있다. | 실행 규칙 재서술을 줄이고 사용자 흐름/예시/WHY 중심으로 재배치한다. canonical 세부 규칙은 중복 없는 단방향 pointer만 유지한다. |
| `SCAFFOLD-ONBOARDING-GUIDE.md` | target 첫 세션 예시는 새 이름을 쓰지만 scaffold target과 source maintainer 책임 경계가 더 선명해야 한다. | generated target이 해야 할 onboarding과 source repo가 제공하는 framework/migration surface를 분리한다. |
| `HARNESS-QUICK-REFERENCE.md` | command table은 새 이름이나 cascade 문구가 source/tool/user/scaffold를 압축해 설명한다. | daily command reference는 짧게 유지하고, source maintainer용 cascade는 필요 최소 pointer로 둔다. |
| Prompts | session-start prompts는 새 names를 반영한다. | README/manual/guide 변경 후 stale command/boundary 문구가 있으면 좁게 수정한다. |
| Scaffold generated README/BOOTSTRAP/STATUS/backlog | target README가 canonical location, command adapters, bootstrap flow를 설명한다. | target runtime 설명은 source-only DR 번호나 maintainer policy를 새로 인용하지 않고, target이 실제 갖는 파일과 첫 세션 행동만 설명한다. |
| Migration note | old command names의 허용된 historical/migration note다. | old names는 이 문서와 source-only historical DR/retrospective 외 user-facing runtime 설명에서 제거한다. |

## Plan

### Execution Classification

| 항목 | 판단 |
| --- | --- |
| Risk Level | L2 harness/workflow/user-facing/scaffold documentation surface. 사용자 adoption 경로 전체에 닿고 reversal cost가 High라 cross-agent review 필수 |
| Execution Mode | Full Work |
| State Machine | INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END. 현재는 PLAN/R32 review 전 단계 |
| Branch | `feature/chore-20260606-002-user-facing-doc-overhaul` |
| Approval | Claude R32 plan review와 사용자 scope approval 후 구현. commit 전 별도 Approval Matrix 승인 |
| Tool Rule Reference | `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md` 수동 적용 |
| STATUS Update Proposal | CHORE-20260606-002를 `docs/STATUS.md` Active Work에 추가할지 사용자 승인 필요. 승인 전에는 STATUS 미수정 |

### P1. Stage Strategy

이번 Work는 **README부터 단계적으로 진행하되, manual/guide/scaffold text까지 같은 Work 안에서 묶는 방식**을 제안한다.

| Stage | Scope | Review Gate |
| --- | --- | --- |
| S1 | `README.md` front-door, command table, source/scaffold boundary 재정리 | README diff가 user-facing contract로 적절한지 Claude 확인 |
| S2 | `docs/HARNESS-QUICK-REFERENCE.md` 정렬 + `docs/WORKFLOW-MANUAL.md` stale old-name/source-target 오류만 좁게 보정 | manual deep rewrite는 후속 Work로 분리 |
| S3 | `docs/SCAFFOLD-ONBOARDING-GUIDE.md`와 `scripts/create-harness.sh` generated README/STATUS/BOOTSTRAP/backlog 문구 정렬 | source repo 문서와 scaffold target 문서 경계 확인 |
| S4 | `prompts/README.md`, `prompts/*session-start.md` stale command/boundary 문구만 좁게 수정 | prompt surface가 session-start runtime을 오염시키지 않는지 확인 |

`WORKFLOW-MANUAL.md` deep rewrite는 이번 Work의 fallback이 아니라 **기본 out-of-scope**로 둔다. 단, stale old command name과 source/target boundary 오류는 이번 Work에서 남기지 않는다.

### P2. Source Repo Vs Scaffold Target Boundary

| Surface | Owns | User-Facing Rule |
| --- | --- | --- |
| Source repo README/manual/quick reference | harness source maintainer와 adopter가 읽는 설명 | source repo가 framework, scaffold script, migration note, release policy를 소유한다는 점을 명시한다. |
| Scaffold generated README/BOOTSTRAP/STATUS/backlog | target repo 첫 운영자 | target이 실제 수행할 onboarding, product/harness track, first `/session-start`만 설명한다. source-only release/public baseline 정책은 기본값처럼 보이지 않게 한다. |
| Optional pack manual | source-owned heavy reference | target minimal scaffold에는 없을 수 있음을 유지한다. 필요 시 source link 또는 `--with-optional`로 접근한다. |
| Active target migration | target repo | source는 migration note와 `--check`만 제공한다. target-local product commands/skills는 target에서 보존한다. |

### P3. Canonical Mention Policy

- Daily user-facing command table은 `/session-start`, `/work-plan`, `/work-close`, `/session-summary`, `/repo-health` 같은 command 이름과 tool별 entry behavior를 먼저 보여준다.
- `skills/workflow/`는 "workflow 상세 절차의 canonical SSoT"로 한 번 설명하되, 일반 사용자가 매번 직접 읽어야 하는 것처럼 쓰지 않는다.
- `.claude/commands/`, `.agents/skills/`, `.cursor/rules/workflow.mdc`는 hybrid adapter로 설명한다. adapter 세부 hard-stop은 canonical/adapter 파일이 소유한다.
- manual/guide는 실행 규칙을 길게 재서술하지 않고 사용자 흐름, 예시, WHY, source/target boundary를 소유한다.
- README는 adopter가 처음 보는 front-door이므로 주요 구조/흐름 다이어그램은 유지할 수 있다. 단, canonical trigger matrix나 Approval Matrix 전문을 중복 재호스팅하지 않고, 개념 이해용 다이어그램 + 권위 문서 pointer로 제한한다.

### P4. Old Command Name Policy

- `/start`, `/done`, `/pick`, `/register`, `/work`, `/resume`, `/close`, `/debug`, `/doc`, `/health`, `/record-decision`은 runtime alias로 설명하지 않는다.
- old -> new mapping은 `docs/MIGRATION-CANONICAL-ADAPTER-RENAME.md`와 immutable source-only historical DR/retrospective만 허용한다.
- README/manual/guide/quick-reference/prompts/generated scaffold text에서 old command가 필요하면 "migration/historical note"라고 명시한 좁은 문맥만 허용한다. 기본 방침은 user-facing runtime 설명에서 제거다.

### P5. Scaffold DR Citation Policy

- generated scaffold runtime docs에는 target에 복사되지 않는 DR 번호를 새로 인용하지 않는다.
- target README/BOOTSTRAP/STATUS/backlog는 target이 실제 보유하는 파일과 행동만 설명한다.
- source README/manual은 필요 시 DR-021/DR-023/DR-024를 source maintainer 문맥에서만 언급한다. adoption/runtime flow에는 DR 번호보다 행동 기준을 우선한다.

## Done Criteria

- [x] README가 source repo front-door, command taxonomy, scaffold adoption path, source/target boundary를 새 구조 기준으로 설명한다.
- [x] `docs/WORKFLOW-MANUAL.md`는 stale old-name/source-target 오류만 좁게 보정하고, deep rewrite는 후속 Work 후보로 남긴다.
- [x] `docs/SCAFFOLD-ONBOARDING-GUIDE.md`가 scaffold target 첫 세션과 source repo 책임 경계를 혼동 없이 설명한다.
- [x] `docs/HARNESS-QUICK-REFERENCE.md`가 daily command reference와 cascade guidance를 새 canonical+adapter 구조에 맞춘다.
- [x] `scripts/create-harness.sh`가 생성하는 README/STATUS/BOOTSTRAP/backlog 문구가 target runtime 기준으로 정렬된다.
- [x] 필요한 경우 `prompts/README.md`와 session-start prompts의 stale command/boundary 문구를 좁게 수정한다.
- [x] canonical 문서가 user-facing manual/guide를 평시 load/cascade 책임 대상으로 역참조하지 않는다. 정방향 단방향 pointer는 허용한다.
- [x] old command names는 migration note/source-only historical 문맥 외 user-facing runtime 설명에서 제거된다.
- [x] scaffold runtime 문서에 target 미복사 DR 번호를 새로 인용하지 않는다.
- [x] Claude 결과 검토 후 `/work-close`로 Work Done 처리한다. commit 승인, PR `--base develop`, merge는 별도 Approval Matrix 단계로 진행한다.

## Verification

| Check | Command / Method | Expected |
| --- | --- | --- |
| Branch isolation | `git branch --show-current` | `feature/chore-20260606-002-user-facing-doc-overhaul` |
| Whitespace | `git diff --check` | PASS |
| Shell syntax | `bash -n scripts/create-harness.sh` | PASS |
| Stale old-name grep | `rg -n "/(start|done|pick|register|work|resume|close|debug|doc|health|record-decision)\\b|workflow-(start|done|pick|register|work|resume|close|debug|doc|health|record-decision)\\b" README.md docs/WORKFLOW-MANUAL.md docs/SCAFFOLD-ONBOARDING-GUIDE.md docs/HARNESS-QUICK-REFERENCE.md prompts scripts/create-harness.sh` | migration/historical 예외 외 0 |
| New command consistency | README/manual/quick-reference/generated README command tables compare against `.claude/commands/*.md` and `.agents/skills/workflow-*/SKILL.md` suffixes | 11 commands aligned |
| README anchors | TOC and key section links inspect | No broken local anchor introduced |
| Mermaid sanity | README mermaid blocks inspect for closed fences and valid node references | No obvious syntax break |
| Scaffold invariant default | `scripts/tests/check-scaffold-invariants.sh` | PASS for default minimal |
| Scaffold invariant optional | `scripts/tests/check-scaffold-invariants.sh` | PASS for `--with-optional` path |
| Fresh scaffold generated text | temp default + `--with-optional` generation, then grep target README/BOOTSTRAP/STATUS/backlog for old names/source-only DR leakage | PASS |
| Generated target boundary | temp README/BOOTSTRAP/STATUS/backlog grep/read-through | source-only Gitflow/public baseline policy is not presented as target default |
| Source/target boundary read-through | README -> onboarding guide -> generated target README flow inspection | No source-only policy presented as target default |
| Cross-agent review | Claude review R33+ after Codex implementation | P0/P1 none or resolved |

## Checkpoints

| Checkpoint | Description | Status |
| --- | --- | --- |
| CP1 | Work file + R32 Codex plan draft 작성 | Done |
| CP2 | Claude R33 plan review 수신 | Done |
| CP3 | Plan 합의 및 사용자 구현 승인 | Done |
| CP4 | S1 README/front-door 구현 | Done |
| CP5 | S2 manual/quick-reference 구현 | Done |
| CP6 | S3 scaffold onboarding/generated text 구현 | Done |
| CP7 | S4 prompts 정렬 및 self-validation | Done |
| CP8 | Claude result review | Done |
| CP9 | `/work-close` 완료, commit approval 준비 | Done |

## Cross-Agent Review

### Round Log

| Round | Agent | Summary | Status |
| --- | --- | --- | --- |
| R32 | Codex | Plan 초안. README-first staged execution, source/target boundary, canonical mention policy, old-name removal policy, scaffold DR citation policy, verification matrix 제안 | Claude review requested |
| R33 | Claude | Plan review: 수정 후 승인. 방향 타당. P1 3건(manual deep rewrite 분리를 default로, 역방향 참조 제거/OQ-11 scope 명시, README 중복 재서술 thin + stale Document Layers diagram), P2 4건(신규 문서 분리 반대, beginner flow 미세조정, verification 보강, generated target boundary 명시) | R33 review 블록 |
| R34 | Codex | R33 반영 결정: 신규 top-level manual 분리 없음, README impact diagram은 개념용으로 유지/갱신, `WORKFLOW-MANUAL.md` deep rewrite는 후속 Work, 역방향 canonical→manual/guide 참조 제거는 이번 Work 포함 | 구현 착수 |
| R35 | Codex | 구현 완료 + self-validation. README front-door/diagram 갱신, quick-reference/onboarding/generated README/manual narrow fix, canonical reverse-reference 제거, stale grep/scaffold invariant/fresh scaffold `--check` PASS | Claude result review requested |
| R36 | Claude | 결과 검토 + 직접 재검증. R33 P1 3건/P2 4건 모두 반영 확인, Codex self-validation(68/86 0 drifted 포함) 재현 PASS. **승인.** P0/P1 없음, P2 2건(이연 manual rewrite backlog 미등록, README mermaid layout-hint cosmetic) 비차단 | R36 review 블록 |

### R32 Codex Plan Draft

**결론:** 이번 slice는 README만 고치고 끝내기엔 adoption 경로가 다시 어긋난다. 다만 `WORKFLOW-MANUAL.md`가 크므로 README를 먼저 contract로 세우고, manual/guide/scaffold text를 같은 Work 안에서 단계별로 따라오게 하는 방식을 제안한다.

검토 요청:

1. **Scope:** README-first staged execution이 맞는가, 아니면 S1 README 후 manual deep rewrite를 별도 Work로 즉시 분리해야 하는가?
2. **Boundary:** source README/manual과 generated scaffold target README/BOOTSTRAP의 책임 경계가 충분히 선명한가?
3. **Canonical mention:** `skills/workflow/`를 user-facing 문서에서 한 번 설명하고 daily flow에서는 command 중심으로 유지하는 기준이 적절한가?
4. **Old-name policy:** migration note/source-only historical 예외 외 user-facing runtime 설명에서 old command names를 제거하는 기준이 충분히 엄격한가?
5. **Scaffold DR citation:** generated target runtime docs에 target 미복사 DR 번호를 새로 인용하지 않는 방침이 slice 4/9 재발을 막기에 충분한가?
6. **Verification:** stale old-name grep, scaffold invariant 양쪽 모드, `git diff --check`, command table consistency 외 추가해야 할 검증이 있는가?

### R33 Claude Plan Review

**결론: 수정 후 승인.** 방향은 타당하고 필요하다 — README/manual은 이미 canonical SSoT(Approval Matrix=AGENT-WORKFLOW, trigger=HARNESS-PROTOCOL, command 절차=skills/workflow)를 광범위하게 재서술하고 있어, rename 반영만으로 끝내면 중복 구조가 그대로 남는다. 다만 착수 전 **scope를 줄이고 decoupling의 누락된 절반을 명시**해야 한다. 아래 P1 3건 반영 후 구현 착수를 권한다.

**먼저 blank-slate 관점 결론(사용자 요청):** 이 repo는 audience 분리가 *없어서* 문제인 게 아니라 *중복*이 문제다. 이미 README(adopter front-door) / WORKFLOW-MANUAL(human deep reference) + HARNESS-QUICK-REFERENCE(AI 실행 reference) / SCAFFOLD-ONBOARDING-GUIDE(onboarding) / HARNESS-ARCHITECTURE·MAINTAINER-GUIDE(system·maintainer, Optional pack)로 3 audience가 존재한다. 따라서 `ai-deck-compiler`식 USER-MANUAL/SYSTEM-MANUAL 신규 분리는 **반대**한다(P2-1). 백지에서 다시 써도 자연스러운 구조는 "README=개념+단일 권위 pointer, 깊이는 canonical/manual로 위임"이다. 이번 개편의 실질 가치는 rename이 아니라 **README에서 규칙 표 재서술을 빼내 pointer로 바꾸는 것**이다.

**P1 (착수 전 반영 권장):**

- **P1-1 Scope/staging (OQ-18 응답) — manual deep rewrite 분리를 fallback이 아니라 default로.** 이번 Work = `README.md` + `HARNESS-QUICK-REFERENCE.md` + `SCAFFOLD-ONBOARDING-GUIDE.md` + `create-harness.sh` generated text + `prompts/`(adoption-critical path). `WORKFLOW-MANUAL.md`(1790 lines)는 이번 Work에서 **stale old-name + source/target boundary 오류 제거만** 하고, 깊은 재구조화는 후속 Work로 분리한다. 근거: (a) parent §8-4·§10-b가 "manual/guide rewrite는 별도 실행 Work로 분리"를 이미 합의, (b) manual은 Optional pack이라 minimal scaffold에 없음 → adoption 우선순위가 낮음, (c) front-door contract 정리와 1790줄 manual 재구조화를 한 diff에 섞으면 리뷰 단위가 무너진다. R32의 "S2 축소 escape hatch"를 기본 동작으로 승격하면 된다.
- **P1-2 Decoupling의 누락된 절반 — 역방향 참조 제거/OQ-11 scope를 명시.** R32는 새 구조를 user-facing 문서 *안으로* 반영하는 데만 집중하고, parent가 user-facing decoupling 결정에 묶은 **canonical → user-facing 역방향 참조 제거**를 다루지 않는다. 구체 대상: `docs/HARNESS-PROTOCOL.md:166/168/177/325/353`, `docs/AGENT-WORKFLOW.md:68`가 `WORKFLOW-MANUAL.md`/`SCAFFOLD-ONBOARDING-GUIDE.md`를 load 대상으로 가리킨다. 이 역참조를 두면 SSoT 경계가 흐려지고 OQ-11이 실질 미해결로 남는다. 선택: (a) 이번 Work에 역참조 audit/제거 + OQ-11 최종 decouple 정도 결정을 포함하거나, (b) 명시적으로 out-of-scope 선언 + 소유 Work를 지정한다. **지금은 침묵 상태라 P1.** 권장: 정방향 단방향 pointer는 유지(OQ-11 "중복 없는 위임"), 역방향만 이번 Work에서 제거.
- **P1-3 README 역할 재정의 + stale diagram (IA 핵심).** ① `README.md:146-222` §2 Document Layers mermaid가 DR-023 이후 stale다 — canonical `skills/workflow/` 노드가 없고 `.claude/commands` 등만 "Reusable Surfaces"로 그려 새 SSoT 계층이 누락됐다. 이번 Work에서 갱신 필수. ② §5(Approval Matrix 전체 표 재호스팅), §3 Session Lifecycle, §8 Trigger를 개념+단일 pointer로 thin하게 줄인다는 README 목표를 plan에 명시할 것. 현재 Done Criteria의 README 항목은 "설명한다" 수준이라 *중복 제거*라는 핵심 의도가 빠져 있다.

**P2:**

- **P2-1 신규 audience 문서 분리 반대(위 결론 근거).** rename 직후 새 top-level manual을 만들면 cascade surface만 늘린다. 더 작은 대안: 기존 4개 문서의 경계를 선명히 하고 중복을 제거한다. 신규 파일 0.
- **P2-2 Beginner 5-step flow — 구조는 이미 충족, 깊이만 조정.** 개념→gate→trigger→scaffold→onboarding은 README §1-2 / §5 / §8 / §10 / §10+guide로 이미 순서대로 매핑된다. 조정점: (a) §8 Trigger는 이미 개념+pointer로 적정 — **확장하지 말 것**(canonical trigger matrix 재서술 금지 기준 충족), (b) 과서술된 쪽은 §5 gate이므로 여기를 thin, (c) onboarding handoff 체인(README §10 → SCAFFOLD-ONBOARDING-GUIDE → BOOTSTRAP)이 끊기지 않는지 read-through 검증.
- **P2-3 Verification 보강 4건:** (a) README anchor/TOC 링크 정합성 — README는 큰 TOC+다수 `#anchor`라 재구조화 시 깨지기 쉽다, (b) mermaid syntax sanity — README/manual이 mermaid 의존이 크고 §2 diagram을 손댄다, (c) command-table consistency를 "command tables"로 뭉치지 말고 **README §7 + HARNESS-QUICK-REFERENCE Command Taxonomy + (분리 후) WORKFLOW-MANUAL §5 + generated README + README §2 canonical 노드**를 명시 대상에 포함, (d) stale old-name grep 패턴 정제 — R32 검증의 `(start|done|...|work|doc|close)\b`는 bare 영단어 false-positive가 많다. R31 교훈대로 `/old`(슬래시) + `workflow-old` + `commands/old.md` 패턴으로 좁힐 것.
- **P2-4 generated target boundary를 구체 assert로.** verification matrix의 "boundary read-through"를 "generated target README/BOOTSTRAP/STATUS/backlog가 source-only Gitflow/public-baseline 정책을 target default처럼 노출하지 않는다"는 명시 check item으로 박을 것. README §9가 "scaffold repo는 Gitflow 강제 안 함"을 이미 올바르게 framing하므로 그 framing을 generated text에 mirror하면 된다.

**6대 검토 질문 직접 응답:**

1. **Scope:** README-first는 맞되 같은 Work에 manual deep rewrite를 묶지 말 것 → P1-1(분리 default).
2. **Boundary:** P2 boundary 표는 선명하다. generated target에 source-only 정책 비노출만 assert로 추가(P2-4).
3. **Canonical mention:** P3 적절. `skills/workflow/`를 1회 SSoT로 설명 + daily는 command 중심 동의. 단 README §2 diagram에 canonical 노드 추가가 전제(P1-3).
4. **Old-name policy:** P4 기준 충분. grep 패턴만 정제(P2-3d).
5. **Scaffold DR citation:** P5는 slice 4/9 재발 방지에 충분(R31에서 동일 기준이 PASS로 검증됨). fresh-scaffold grep 유지.
6. **Verification:** P2-3 4건 추가 권장.

**미검토/위임:** 실제 문장 재작성 품질은 구현 후 result review(R-round)에서 본다. OQ-11 최종 decouple 정도(정방향 pointer를 0까지 줄일지)는 사용자 판단 1건으로 남긴다 — 권장은 정방향 단방향 pointer 유지·역방향 제거.

### R34 Codex Response To R33

R33을 반영해 scope를 조정한다.

- **P1-1 수용:** 이번 Work에서 `WORKFLOW-MANUAL.md` deep rewrite를 기본 out-of-scope로 둔다. stale old-name, source/target boundary 오류, command table consistency처럼 adoption-critical 오류만 좁게 보정한다.
- **P1-2 수용:** canonical 문서가 user-facing manual/guide를 평시 load/cascade 책임 대상으로 역참조하는 구조는 이번 Work에서 제거한다. 정방향 단방향 pointer는 유지한다.
- **P1-3 수용:** README는 adopter front-door로 재정의하고, Approval Matrix/trigger 전문 재호스팅을 줄인다. 다만 사용자가 요청한 "impact 있는 README" 관점을 반영해 전체 architecture와 기본 flow를 잡는 주요 다이어그램은 유지·갱신한다.
- **P2-1 수용:** `USER-MANUAL.md`/`SYSTEM-MANUAL.md` 같은 신규 top-level audience 문서는 만들지 않는다. 기존 README, quick reference, workflow manual, scaffold onboarding guide의 경계를 선명히 한다.
- **P2-3/P2-4 수용:** README anchor, mermaid sanity, command table consistency, generated target boundary assert를 verification에 추가한다. stale grep은 slash command / skill name / old path 중심으로 좁혀 false-positive를 줄인다.

### R35 Codex Implementation Summary

구현 완료. Claude result review를 요청한다.

변경 요약:

- `README.md`: Quick Start beginner flow 추가, Document Layers diagram에 canonical `skills/workflow/` + adapter 계층 반영, Approval Matrix 전문 재호스팅을 concept+pointer로 축소, command map에 canonical/adapters 관계 명시, scaffold adoption diagram과 repository layout 갱신.
- `docs/HARNESS-QUICK-REFERENCE.md`: Command Taxonomy에 canonical/adapters 관계 추가, cascade 문구를 user-facing docs 중심으로 조정.
- `docs/SCAFFOLD-ONBOARDING-GUIDE.md`: target onboarding 문서임을 명확히 하고 source repo vs target project 책임 경계 및 `source-gitflow` opt-in 경계를 추가.
- `scripts/create-harness.sh`: generated README에 workflow 구조(canonical/adapters)와 target branch/release policy 경계 문구 추가.
- `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`: `WORKFLOW-MANUAL.md`를 평시 load/cascade 책임 대상으로 직접 가리키는 역방향 참조 제거.
- `docs/WORKFLOW-MANUAL.md`: deep rewrite 없이 stale scaffold file table, canonical/adapters 설명, old command list, diagram node 오류만 좁게 보정.

검증 결과:

- PASS `git diff --check`
- PASS `bash -n scripts/create-harness.sh`
- PASS `bash -n scripts/tests/check-scaffold-invariants.sh`
- PASS `scripts/tests/check-scaffold-invariants.sh` — default minimal + `--with-optional` OVERALL PASS
- PASS stale old-name grep 정제 패턴 — migration/historical 예외 외 old slash command/old skill/old path 없음
- PASS command surface list — 11 Claude commands + 11 Codex adapters aligned
- PASS fresh scaffold default `--check`: 68 tracked, 68 in-sync, 0 drifted
- PASS fresh scaffold optional `--check`: 86 tracked, 86 in-sync, 0 drifted
- PASS generated target boundary grep — source-only Gitflow/public baseline 정책을 target default처럼 노출하지 않음. `Gitflow` 잔존은 "`--existing` overlay에서 무조건 강제하지 않는다" 방어 문장뿐
- README/Manual mermaid fence sanity: modified markdown fences close. Mermaid semantic rendering은 별도 renderer 없이 수동 sanity check 수준

### R36 Claude Result Review

**결론: 승인.** R33에서 제기한 P1 3건과 P2 4건이 모두 반영됐고, Codex self-validation을 직접 재현해 PASS를 확인했다. **P0/P1 결함 없음.** P2 2건은 commit/close 단계의 비차단 항목이다. 다음 단계 `/work-close` -> commit approval -> PR `--base develop` 진행에 동의한다.

**R33 findings 반영 판정:**

| R33 finding | 판정 | 근거 |
| --- | --- | --- |
| P1-1 manual deep rewrite 분리 default | 반영 | `WORKFLOW-MANUAL.md` 변경이 stale scaffold 표(복사→optional 정정), old command list(`start/pick/work/...`→new names), canonical/adapter 설명, diagram node 오류만으로 narrow. 1790줄 deep 재구조화 없음. plan S2도 "deep rewrite 후속 Work"로 갱신됨 |
| P1-2 역방향 참조 제거 | 반영 | `docs/AGENT-WORKFLOW.md`(Context Routing의 manual load 문장 + Optional pack 주의에서 manual 제거), `docs/HARNESS-PROTOCOL.md`(load map row·anti-pattern·document map·classification table의 manual 참조 5곳 제거 + 단방향 위임 문장으로 교체). `WORKFLOW-MANUAL.md` 자체의 self-load row도 제거. **canonical→manual 평시 load/cascade 역참조 0 확인.** `skills/workflow/repo-health.md`의 manual 참조는 제거 대상이 아님 — `/repo-health --cascade`의 forward audit target이고 Optional-pack N/A 가드가 있어 parent가 요구한 "transition 중 user-facing freshness 감사"가 여기 산다(정상) |
| P1-3① stale Document Layers diagram | 반영 | README §2 mermaid에 `Canonical Workflow`(skills/workflow/README+{name}) + `Tool Adapters`(commands/codex-skills/cursor) subgraph 추가, `SCRIPT→canonical/adapter` edge 추가, 구 `RULES`/`SKILLS` node id를 `CLAUDE_RULES`/`CODEX_SKILLS`로 정리. undefined node 참조 없음 |
| P1-3② README 중복 thin | 반영 | §5 Approval Matrix 전체 L1/L2/L3 표 제거 → 개념 + 4-gate 요약표 + "상세는 AGENT-WORKFLOW Approval Matrix가 SSoT" pointer. §3 lifecycle diagram·§8 trigger(이미 thin)는 유지(사용자 요청한 architecture/flow diagram 보존과 일치) |
| P2-1 신규 문서 분리 반대 | 반영 | USER-MANUAL/SYSTEM-MANUAL 신설 없음. 기존 4문서 경계 정리 |
| P2-2 beginner flow | 반영 | Quick Start에 5-step flow(README→scaffold→session-start→BOOTSTRAP→work cycle), §2에 5-concept 구조. §8 trigger 확장 안 함, §5 gate를 thin |
| P2-3 verification 보강 | 반영 | anchor/TOC·mermaid sanity·command-table consistency·refined grep가 self-validation에 포함 |
| P2-4 generated target boundary assert | 반영 | generated README/BOOTSTRAP에 "source-gitflow 미선택 시 target이 branch/release 직접 결정" 방어 문구. grep 결과 source-only 정책의 target-default 노출 0 |

**직접 재검증(Codex 주장 재현):**

- PASS `git diff --check`, `bash -n scripts/create-harness.sh`
- PASS `scripts/tests/check-scaffold-invariants.sh` OVERALL (default + `--with-optional`)
- PASS fresh scaffold `--check`: default **68 tracked / 0 drifted**, `--with-optional` **86 tracked / 0 drifted**(WORKFLOW-MANUAL/skills/workflow 포함 확인)
- PASS refined stale old-name grep — user-facing surface에 old runtime command/skill/path 0
- PASS generated target DR 누수 — fresh target에 DR-019/021/022/023/024 인용 0
- PASS generated target boundary — Gitflow 잔존은 "강제하지 않는다" 방어 문구뿐
- PASS command-table consistency — 11 new command이 README §7 + HARNESS-QUICK-REFERENCE Taxonomy + WORKFLOW-MANUAL §5에 일관 존재
- PASS README anchor/TOC — 15개 anchor 전부 heading 대응, mermaid node 참조 무결

**Findings:**

- **P0/P1: 없음.**
- **P2-a (Tracking, commit/close 단계):** 이연한 `WORKFLOW-MANUAL.md` deep-rewrite가 `docs/backlog/HARNESS.md`/STATUS Next Actions에 후속 candidate로 미등록이다. Work 파일 plan/Discovery에만 deferral이 기록돼 이 Work close 후 누락될 수 있다. `/work-close` 전 Tracking Finalization에서 HARNESS backlog candidate 또는 Next Action으로 등록 권장.
- **P2-b (cosmetic):** README §2 mermaid의 layout-hint `ARCHIVE ~~~ COMMANDS`(주석 "place reusable surfaces below")가 의미상 stale다 — `COMMANDS`가 `Reusable Surfaces`에서 `Tool Adapters` subgraph로 이동했다. 렌더링은 정상이라 비차단. 다음 손댈 때 정리.

**미검토/위임:** mermaid semantic 렌더링은 별도 renderer 없이 fence/node 정합 수준까지만 확인했다. commit message/PR 본문/merge는 사용자 승인 후 별도 단계.

## Discovery

- Branch Isolation Check: `develop` + source-gitflow mode에서 protected workflow edit 금지 확인 후 `feature/chore-20260606-002-user-facing-doc-overhaul` branch로 전환했다.
- STATUS current sections: Active Work와 Blockers/OQ 없음. Next Actions는 slice #13 이후 user-facing 개편을 후속으로 가리키지만 STATUS Active pointer는 아직 추가하지 않았다.
- Work index: `CHORE-20260606-002-user-facing-doc-overhaul.md`는 없었고, `docs/works/harness/README.md` Active 섹션도 비어 있었다.
- Parent §10-b: user-facing 문서는 README를 시작점으로 manual/guide를 전면 재작성하되, `WORKFLOW-MANUAL.md` 규모 때문에 README -> 핵심 흐름 -> 상세 manual/guide 순 단계적 개편을 권한다.
- Parent OQ-11: canonical 참조를 완전 0으로 줄이는 것보다 "중복 없는 단방향 위임 pointer"를 유지하는 방향이 잠정 합의다.
- Parent OQ-18: 전면 일괄 vs 단계적 개편의 분기점이 이번 Work의 핵심 plan 질문이다.
- Slice #13 R31: canonical 11개(+README), hybrid adapter, no-alias rename, scaffold/manifest, migration note가 7대 기준 PASS. old command names는 migration note + source-only historical DR/retrospective 외 runtime surface에서 제거됐다고 검토됐다.
- Migration note: source는 rename PR + canonical/adapters + `--check` + migration note를 제공하고, active target은 자기 repo에서 selective migration을 수행한다.
- Current README: new command names와 source/scaffold boundary가 상당 부분 반영됐으나, public front-door에 command table, cascade, source Gitflow, adoption, file tree가 길게 공존한다.
- Current `WORKFLOW-MANUAL.md`: new command names는 반영됐지만 command table, trigger/cascade, scaffold flow, hook 설정 등 실행 규칙 재서술이 많아 user-facing/manual과 canonical의 SSoT 경계가 흐릴 수 있다.
- Current `SCAFFOLD-ONBOARDING-GUIDE.md`: `/session-start` 중심 첫 세션 흐름은 새 이름을 사용한다. target onboarding과 source maintainer policy가 섞이는지 implementation 때 정밀 점검한다.
- Current `scripts/create-harness.sh`: generated README/STATUS/BOOTSTRAP/PLAN/backlog는 새 command names를 사용하고, `skills/workflow/` canonical과 adapters를 target에 생성한다. 이 문구가 source-only DR/policy를 새로 누수하지 않게 유지해야 한다.
- Tool rule reference: `.claude/rules/docs-workflow.md`와 `.claude/rules/git-workflow.md`가 이번 docs/work/scaffold 변경에 매칭된다. Codex에서 수동 적용한다.
- DR-007: `docs/*.md`, `prompts/*.md`, `skills/workflow/*.md`, `.agents/skills/*/SKILL.md`는 한국어 primary + Bilingual Rules 적용 대상이다.
- User preference note: README는 사용자가 처음 접하는 main surface이므로 주요 구조/흐름 다이어그램은 중복처럼 보여도 유지할 가치가 있다. 구현에서는 canonical trigger/Approval Matrix 전문 복제는 줄이고, overall architecture와 기본 flow를 잡는 diagram은 갱신해 남겼다.
- R33 implementation note: 신규 `USER-MANUAL.md`/`SYSTEM-MANUAL.md` 분리는 하지 않았다. 기존 4개 문서 경계를 선명히 하는 쪽으로 구현했다.
- Closeout note: R36 승인 후 P2-a Tracking 항목으로 `WORKFLOW-MANUAL deep rewrite`를 `docs/backlog/HARNESS.md` Candidate에 등록했다. STATUS Active pointer는 이 Work 착수 때 추가하지 않았으므로 `docs/STATUS.md` 변경 없이 Work file과 Work index만 Done으로 정리한다. `actual_end`는 현재 실행 환경 날짜 `2026-06-05` 기준으로 기록했다.
