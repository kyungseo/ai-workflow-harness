---
id: CHORE-20260606-003
priority: P2
status: Done
risk: High
scope: Phase 2 slice #11 follow-up - WORKFLOW-MANUAL.md deep rewrite. canonical 실행 규칙 재호스팅을 제거하고 manual을 user-facing teaching/walkthrough 문서로 재정의한다.
appetite: 1w
planned_start: 2026-06-06
planned_end: 2026-06-13
actual_end: 2026-06-05
related_dr: [DR-007, DR-021, DR-023]
related_troubleshooting: []
related_work: [CHORE-20260604-001, CHORE-20260606-002]
---

# CHORE-20260606-003: WORKFLOW-MANUAL Deep Rewrite

## Top Summary

- **목표:** `docs/WORKFLOW-MANUAL.md`(1790 lines)에서 canonical/README가 이미 소유한 실행 규칙 카탈로그 재호스팅을 제거하고, manual을 "WHY·세션 흐름·worked example·notation 중심의 user-facing teaching 문서 + canonical SSoT 단방향 pointer"로 재정의한다.
- **최종 산출:** `docs/WORKFLOW-MANUAL.md`를 user-facing teaching manual로 축약하고, canonical/README 재호스팅을 제거했다. D2b State/Work teaching, §4 diagrams, §5 worked examples, D7c manual setup path는 보존했다.
- **역할 구성:** Claude가 plan/구현/R42 보정을 담당했고, Codex가 R38/R41/R43 리뷰와 최종 R43 source README relative-link hotfix를 담당했다.
- **출처:** slice #11(CHORE-20260606-002) R33/R36에서 manual deep rewrite를 기본 out-of-scope로 분리 → 이 Work가 그 후속이다. parent §8-4·§10-b의 "manual/guide rewrite는 별도 실행 Work" 합의 적용.
- **비목표:** README/quick-reference/onboarding 재개편(slice #11에서 완료), canonical/adapter 절차 변경, scaffold 구조 변경, 신규 audience 문서 분리(R33 P2-1에서 반대 확정), `--upgrade` 구현, **upgrade/migration 절차 상세 설계**(P4는 user-facing 안내까지만; 절차 상세는 필요 시 별도 backlog 후보).
- **상태 변경:** 이 Work는 `docs/STATUS.md` Active Work pointer를 추가하지 않았으므로 제거할 pointer는 없었다. `/work-close`에서 stale Next Actions를 현재 후속 후보 기준으로 갱신했다.

## Context Manifest

| 순서 | 파일 | 확인 내용 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/works/harness/CHORE-20260606-002-user-facing-doc-overhaul.md` | R33 P1-1/P2-1, R36 P2-a, manual narrow-fix 범위 | 이 deep rewrite의 직접 상류, 이미 적용된 manual 변경 |
| 2 | `docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md` | §8 user-facing decoupling, §10-b, OQ-11 | manual decoupling 원칙 SSoT |
| 3 | `docs/WORKFLOW-MANUAL.md` | §1~§7 + Appendix A/B/C 전 구간 | 개편 대상 본문 |
| 4 | `README.md` | §2 Document Layers, §7 Command Map, §10 Adoption, §11 Key Documents, §12 Layout | manual이 위임할 forward pointer 대상 |
| 5 | `docs/AGENT-WORKFLOW.md` | Approval Matrix, Risk Levels, Context Routing | §5 Approval/Risk 재호스팅의 SSoT |
| 6 | `docs/HARNESS-PROTOCOL.md` | Trigger 정의/cascade | §7 Trigger Reference 재호스팅의 SSoT |
| 7 | `docs/SCAFFOLD-ONBOARDING-GUIDE.md` | 첫 세션/onboarding 절차 | Appendix B 재호스팅의 SSoT |
| 8 | `skills/workflow/*.md` | command별 canonical 절차 | §5 Slash Command 재호스팅의 SSoT |
| 9 | `scripts/create-harness.sh` | manual은 Optional pack 복사 대상 | --with-optional target DR-citation/leak 검증 범위 |
| 10 | `scripts/tests/check-scaffold-invariants.sh` | optional pack 포함 invariant | manual 변경 회귀 검증 |
| 11 | `docs/decisions/DR-007-language-policy.md` | 한국어 primary + Bilingual Rules | manual 언어 기준 |

## Defect And Scope Inventory

manual 1790 lines 중 재호스팅(canonical/README가 SSoT인 내용을 manual이 다시 서술) 구간:

| ID | 구간 | 추정 lines | SSoT(위임 대상) | 처리 |
| --- | --- | --- | --- | --- |
| D1 | §2 Directory Structure (100-198) | ~98 | README §12 Repository Layout | file tree 카탈로그 제거 → 개념 1단락 + README §12 pointer |
| D2a | §3 per-file 역할 카탈로그 (293-599 중 순수 per-file 설명) | ~280 | README §11 Key Documents + §2 Document Layers | per-file 역할 catalog 제거 → pointer. 최대 중복 |
| D2b | §3 State/Work teaching 자산 (STATUS 섹션 관계 :324, Work item routing :392, archive/update safety, Work file lifecycle/template :521) | ~120 | AGENT-WORKFLOW STATUS Rules / HARNESS-PROTOCOL / DR-013 | **보존** — "초보가 상태 파일을 어떻게 읽나"는 README §6만으로 얇아진다. compact teaching 섹션 유지 + pointer. (R38 P1-2) |
| D3 | §3-0 Document Hierarchy mermaid (213-289) | ~77 | README §2 Document Layers mermaid(이미 canonical+adapter 반영) | 중복 다이어그램 제거 또는 README §2 pointer. manual 고유 정보 없으면 삭제 |
| D4 | §5 Approval Matrix + Risk Level Classification (857-900) | ~44 | AGENT-WORKFLOW Approval Matrix / Risk Levels | 표 재호스팅 제거 → 개념 + pointer |
| D5 | §6 Decision Record Operations + DR template (953-1034) | ~82 | `skills/workflow/repo-decision.md` + DECISION-TEMPLATE | when-to-DR 개념 유지, 절차/템플릿 재호스팅은 pointer |
| D6 | §7 Trigger Reference T1-T9 + Cascade Overview + Index (1035-1348) | ~313 | HARNESS-PROTOCOL Trigger 시스템 | T1-T9 카탈로그 제거 → "어떤 변경이 어떤 점검을 부르는가" user-facing 요약 + pointer |
| D7a | Appendix B script scaffold quick-start (1389-1490) | ~100 | README §10 Adoption | scaffold 명령 카탈로그 제거 → README §10 pointer |
| D7b | Appendix B first-session/onboarding 서술 (1490-1559) | ~70 | README §10 + `docs/BOOTSTRAP.md` (둘 다 target-copied) | onboarding pointer로 위임. **SCAFFOLD-ONBOARDING-GUIDE는 source-only라 pointer 금지** (R38 P1-1) |
| D7c | Appendix B Manual Init Checklist + Claude-Assisted Init Prompt (1560-1763) | ~200 | manual 고유 (no-script 수동 구성 경로) | **보존 + 현행화** — README/guide로 완전 대체 불가. line 1683 old 파일명(`start.md`/`pick.md`/...)을 새 adapter 이름으로 갱신 필수 (R38 P1-3) |

manual이 **고유하게 소유**(다른 곳에 없는 user-facing teaching value, 유지 대상):

| 구간 | 유지 이유 |
| --- | --- |
| §1 Overview (problems solved, core principles, reading path, notation, diagram color key) | notation/color key/reading path는 manual 고유 |
| §4 Workflow Diagrams (full session lifecycle, task execution, tool entry comparison, context load decision) | 가장 자세한 교육용 다이어그램. manual의 핵심 가치 |
| §5 Usage Pattern Examples (901-952) | worked example. 다른 문서에 없는 구체 흐름 |
| Appendix A Prompt Library Usage | prompts/ 사용 안내. light, 유지 또는 pointer |
| Appendix C Language Rules Summary | DR-007 user-facing 요약. 유지 또는 pointer |

## Plan

### Execution Classification

| 항목 | 판단 |
| --- | --- |
| Risk Level | L2 user-facing/harness documentation surface. 단일 파일이지만 ~1300 lines 제거로 reversal cost High → L3-grade plan/review 운영 |
| Execution Mode | Full Work |
| State Machine | INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END. 현재 PLAN/R37 draft 단계 |
| Branch | `feature/chore-20260606-003-workflow-manual-deep-rewrite` |
| Approval | 사용자 plan scope 승인 + Codex R38 plan review 후 구현. commit 전 별도 Approval Matrix 승인 |
| Blast radius | manual은 Optional pack — source repo + `--with-optional` target만 영향. minimal scaffold 무영향 |
| Rollback | 단일 파일, 한 PR. stage별 commit 후보로 분리하되 partial merge 금지 |

### P1. Rewrite Principle

manual의 새 정의: **"왜 이 harness인가 + 세션이 어떻게 흐르는가 + 언제 무엇을 하는가"를 다이어그램과 worked example로 가르치는 user-facing 문서.** 실행 규칙의 권위 표(Approval Matrix, Risk Levels, Trigger 정의, command 절차, 문서 카탈로그, file tree, scaffold 명령)는 재호스팅하지 않고 canonical/README로 **단방향 pointer**한다.

- 제거 기준: 동일 정보의 SSoT가 canonical/README에 있고 manual 버전이 drift 위험만 만드는 카탈로그/표.
- 유지 기준: 다른 문서에 없는 teaching 자산(개념 설명, 교육용 다이어그램, worked example, notation).
- 금지: canonical→manual 역참조 신설(이미 #11에서 제거), Approval Matrix/Risk/Trigger 표 재호스팅, manual에서만 갱신되는 "사실" 보유.

### P2. Stage Plan

각 stage는 독립 리뷰 단위. stale-grep/link/mermaid는 매 stage 후 점검.

| Stage | 대상 | 처리 | 검증 |
| --- | --- | --- | --- |
| S1 | D2a §3 catalog + D1 §2 + D3 §3-0 | per-file 역할 카탈로그·file tree·중복 hierarchy 다이어그램 제거 → "문서 계층 이해 + 어디를 읽나" 개념 1~2단락 + README §2/§11/§12 pointer | 제거된 고유 정보 0 확인, README pointer 유효 |
| S1b | D2b §3 State/Work teaching | STATUS 관계·Work routing·archive safety·Work lifecycle/template을 compact teaching 섹션으로 보존 + AGENT-WORKFLOW/HARNESS-PROTOCOL/DR-013 pointer | 초보용 상태-파일 설명 보존 |
| S2 | D4 §5 + §5 Usage Examples | Approval Matrix/Risk 표 제거 → 개념 + AGENT-WORKFLOW pointer. command→use-case 표와 worked example은 유지 | Approval/Risk 권위는 AGENT-WORKFLOW만 |
| S3 | D6 §7 Trigger Reference | T1-T9 카탈로그·cascade overview·index 제거 → "변경 유형 → 점검 대상" user-facing 요약 + HARNESS-PROTOCOL pointer | trigger 정의 SSoT는 HARNESS-PROTOCOL만 |
| S4 | D5 §6 DR Ops + D7a/D7b Appendix B | DR when/why 개념 유지·절차는 repo-decision pointer. scaffold quick-start·first-session 카탈로그 제거 → README §10 + `docs/BOOTSTRAP.md` pointer (둘 다 target-copied) | scaffold triple-maintenance 해소, **source-only pointer 금지** |
| S4b | D7c Appendix B manual-setup checklist + Claude-assisted init prompt | no-script 수동 구성 경로 보존 + 현행화. line 1683 old 파일명을 새 adapter 이름으로 갱신 | manual 고유 경로 보존, old-name 0 |
| S5 | §1, §4, Appendix A/C, TOC | 유지 구간 light 정리, stale 참조 수정, TOC/anchor 재정합, manual 자기참조 잔재 제거 | TOC↔heading 일치, mermaid sanity |

commit boundary: S1~S5를 묶어 한 PR. 중간 stale/link FAIL 상태를 commit하지 않도록 stage별 점검 후 통합 또는 2~3개 논리 commit으로 분리.

### P3. Optional-Pack Leak Guard

manual은 `--with-optional`로 target에 복사된다. 따라서 slice 4/9 DR-citation 함정과 dangling-pointer 함정이 manual에도 적용된다.

**Target-safe pointer allowlist (R38 P1-1 반영, `scripts/create-harness.sh` copy 로직 실측):**

| 분류 | 문서 | manual pointer 허용 |
| --- | --- | --- |
| minimal+optional 복사 | `README.md`(생성), `docs/BOOTSTRAP.md`(생성), `docs/AGENT-WORKFLOW.md`(생성), `docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md`, `docs/HARNESS-NAMING-RULES.md`, `docs/HARNESS-RECOVERY-VALIDATION.md`, `docs/HARNESS-PARALLEL-WORK-CONTROLS.md`, `skills/workflow/`, `docs/STATUS.md`/`PLAN.md`/`PLAN-SUMMARY.md`(생성 skeleton), DR-007/008/013/014 | ✅ |
| optional-only 복사 | `docs/HARNESS-ARCHITECTURE.md`, `docs/HARNESS-MAINTAINER-GUIDE.md`, `docs/WORKFLOW-MANUAL.md`(자기), DR-017/020 | ✅ (optional 문맥) |
| **source-only (미복사)** | **`docs/SCAFFOLD-ONBOARDING-GUIDE.md`, `docs/SCAFFOLD-BOOTSTRAP.md`, `docs/MIGRATION-CANONICAL-ADAPTER-RENAME.md`, `docs/retrospectives/`, `docs/archive/`, `docs/works/`, `docs/decisions/DR-019/021/022/023/024`** | ❌ optional target에서 dangling — relative-link pointer 금지 |

- manual에 target 미복사 DR(DR-019/021/022/023/024 등)을 새로 인용하지 않는다. 기존 인용이 있으면 행동 기준으로 치환하거나 제거.
- onboarding pointer는 SCAFFOLD-ONBOARDING-GUIDE가 아니라 **README §10 + `docs/BOOTSTRAP.md`**로 위임한다(둘 다 target-copied).
- 이번 slice는 scaffold copy matrix를 넓히지 않는다. 따라서 fresh `--with-optional` 기대값 86 tracked는 고정이며, copy 대상을 바꾸면 이 값과 invariant 기대값도 함께 갱신해야 한다(R38 P2).

### P4. Upgrade/Migration User-Facing Guidance (사용자 추가 범위)

범위 한정: **절차 재설계가 아니라 "사용자가 길을 잃지 않게 하는 안내"까지만.** upgrade/migration 절차 상세는 이번 slice 비목표이고, 필요하면 별도 backlog 후보로 등록한다.

| 항목 | 처리 |
| --- | --- |
| 신규 scaffold adoption(README §10)과 별개로, **이미 harness를 쓰는 repo가 canonical/adapters/no-alias로 넘어갈 때 시작점** | manual에 짧은 안내 1블록 추가: 새 command 이름은 target-safe taxonomy(README §7 Command Map / HARNESS-QUICK-REFERENCE Command Taxonomy)에서 확인, 실제 전환 단계는 "**source repo가 제공하는 migration note 참조**" 수준으로 prose 안내 |
| `MIGRATION-CANONICAL-ADAPTER-RENAME.md` 성격 | source repo 사용자/maintainer용 migration note. **target 미복사(source-only)** 확인됨. optional target manual에서 relative-link로 가리키면 dangling |
| pointer 방식 | manual에서 migration note를 **relative markdown link로 걸지 않는다.** "source repo의 migration note" 라는 prose 설명으로 두고, target-safe link는 README/Quick Reference command taxonomy로만 건다 |
| old → new 전환 설명 | historical/migration note 범위 안에서만 서술. old command 이름을 **실행 가능한 현행 command처럼 보이지 않게** 한다(no-alias 구조 유지). 표기 시 "구 이름(now `/new`)" 식 historical 문맥 |

이 안내는 §1 Overview 또는 Appendix B(adoption-adjacent) 근처에 1블록으로 넣고, S4/S4b stage에 포함한다. 새 섹션을 크게 만들지 않는다(Simplicity First).

## Done Criteria

- [x] §3 per-file 역할 카탈로그, §2 file tree, §3-0 중복 hierarchy 다이어그램이 개념 설명 + README pointer로 대체된다(D1/D2a/D3).
- [x] §3 State/Work teaching 자산(STATUS 관계, Work routing, archive safety, Work lifecycle/template)이 compact teaching 섹션으로 보존된다(D2b, R38 P1-2).
- [x] §5 Approval Matrix/Risk Level 표 재호스팅이 제거되고 AGENT-WORKFLOW pointer로 위임된다. command→use-case 표와 worked example은 보존(D4).
- [x] §7 Trigger T1-T9 카탈로그가 user-facing "변경→점검" 요약 + HARNESS-PROTOCOL pointer로 대체된다(D6).
- [x] §6 DR 절차/템플릿과 Appendix B scaffold quick-start/first-session이 canonical/README §10/`docs/BOOTSTRAP.md` pointer로 위임된다(D5/D7a/D7b).
- [x] Appendix B manual-setup checklist + Claude-assisted init prompt가 보존·현행화되고 line 1683 old 파일명이 새 adapter 이름으로 갱신된다(D7c, R38 P1-3).
- [x] manual 고유 teaching 자산(§1 notation/principles, §4 diagrams, §5 worked examples, Appendix A/C)이 보존된다 — 제거된 고유 정보 0.
- [x] canonical→manual 역참조 신설 0, Approval/Risk/Trigger 권위 표 재호스팅 0.
- [x] manual에 target 미복사 DR 신규 인용 0, **source-only 문서 pointer 0**(R38 P1-1).
- [x] (P4) manual의 upgrade/migration 안내가 source-only 문서(`MIGRATION-CANONICAL-ADAPTER-RENAME.md` 등)에 대한 **깨진 relative link를 만들지 않는다**. migration note는 "source repo 참조" prose, target-safe link는 README/Quick Reference command taxonomy로만.
- [x] (P4) old command → new command 전환 설명이 **historical/migration note 범위를 넘지 않는다**.
- [x] (P4) no-alias 구조에서 old command 이름을 **실행 가능한 현행 command처럼 보이게 쓰지 않는다**.
- [x] TOC↔heading anchor 일치, 내부 링크 유효, mermaid fence/node 정합, old command name stale 0(slash + bare filename 양쪽 grep).
- [x] scaffold invariant default+`--with-optional` PASS, fresh `--with-optional` `--check` 0 drifted, `git diff --check` PASS.
- [x] Codex R38 plan review 합의 후 구현, result review 승인 후 `/work-close`. commit/PR/merge는 별도 Approval Matrix 단계.

## Verification

| Check | Command / Method | Expected |
| --- | --- | --- |
| Branch isolation | `git branch --show-current` | feature/chore-20260606-003-... |
| Whitespace | `git diff --check` | PASS |
| Shell syntax | `bash -n scripts/create-harness.sh` | PASS (manual은 문서지만 scaffold 표 변경 시) |
| TOC/anchor | manual TOC 링크 ↔ heading slug 대조 | 모든 TOC anchor가 heading에 대응 |
| Internal links | manual 내부/상호 문서 링크 grep + 존재 확인 | dangling 0 |
| Target anchor compatibility (R41 P2) | manual의 anchored cross-doc link가 **fresh `--with-optional` target에서** 파일+anchor 모두 실재하는지. generated 문서(README, AGENT-WORKFLOW)는 source와 heading 구조가 달라 anchor 미보장 → README는 anchorless, anchored link는 copied 문서(HARNESS-QUICK-REFERENCE 등)만 | broken anchor 0 (target 기준) |
| Mermaid sanity | 수정 mermaid fence 닫힘 + node 참조 정합 | 깨진 fence/undefined node 0 |
| Old-name grep | refined slash/skill/path 패턴 **+ bare filename** `start.md\|pick.md\|work.md\|done.md\|resume.md\|close.md\|debug.md\|doc.md\|health.md\|register.md\|record-decision.md` (R38 P2) | migration/historical 외 0 |
| DR leak guard | manual에서 DR-019/021/022/023/024 grep | 0 (또는 행동 기준 치환) |
| Pointer 정합 | manual pointer 대상이 실재 + **target-safe**인지(README §2/§7/§10/§11/§12, AGENT-WORKFLOW Approval/Risk, HARNESS-PROTOCOL Trigger, `docs/BOOTSTRAP.md`). **source-only 문서(SCAFFOLD-ONBOARDING-GUIDE/SCAFFOLD-BOOTSTRAP/MIGRATION-CANONICAL-ADAPTER-RENAME) relative-link pointer 0** (R38 P1-1/P2) | 모두 실재 + target-safe |
| Migration 안내(P4) | manual의 migration/upgrade 블록에서 `MIGRATION-CANONICAL-ADAPTER-RENAME` relative-link grep + old-name이 현행 실행 command처럼 쓰였는지 점검 | relative-link 0, old name은 historical 문맥만 |
| Scaffold invariant | `scripts/tests/check-scaffold-invariants.sh` | default + `--with-optional` PASS |
| Fresh optional scaffold | `--with-optional` 생성 후 `--check` | 86 tracked / 0 drifted, manual 포함, DR 누수 0 |
| Content preservation | §4 diagrams + §5 worked examples + notation 보존 확인 | 제거된 고유 정보 0 |
| Cross-agent | Codex R38 plan review, result review | P0/P1 none or resolved |

## Checkpoints

| CP | 내용 | 상태 |
| --- | --- | --- |
| CP0 | Branch isolation, manual 구조 진단, Work 파일 + R37 plan draft | Done |
| CP1 | Codex R38 plan review(Changes requested) + R39 Claude 반영 | Done |
| CP1b | 사용자 scope approval | Done |
| CP2 | S1/S1b §2 file tree·§3-0·per-file catalog 제거 + STATUS/Work teaching 보존 | Done |
| CP3 | S2 §5 Approval/Risk 표 위임 + command 표·worked example 보존 | Done |
| CP4 | S3 §7 Trigger T1-T9 카탈로그 제거 + "변경→점검" 요약 위임 | Done |
| CP5 | S4 §6 DR template 위임 + Appendix B D7a/D7b 위임 + D7c 보존·현행화 + P4 migration | Done |
| CP6 | S5 TOC/anchor/T-ref/double-heading/mermaid 재정합 | Done |
| CP7 | self-validation PASS + Codex result review | Done |
| CP8 | `/work-close` + commit approval 준비 | Done |

## Cross-Agent Review

### Round Log

| Round | Agent | Summary | Status |
| --- | --- | --- | --- |
| R37 | Claude | Plan draft. manual deep rewrite — D1-D7 재호스팅 inventory, 유지 자산 식별, P1 rewrite principle, S1-S5 stage plan, optional-pack leak guard, verification matrix 제안 | Codex review requested |
| R38 | Codex | Plan review: Changes requested. P0 없음, P1 3건(SCAFFOLD-ONBOARDING-GUIDE pointer는 source-only라 optional target dangling, D2 §3 과대분할로 State/Work teaching 손실 위험, D7 Appendix B에 manual-setup 고유 경로+old 파일명) + P2 3건 | Claude 반영 |
| R39 | Claude | R38 전면 수용. 3 P1 사실 직접 검증(copy matrix·line 1683 old name·§3 teaching 실재) 후 plan 갱신: D2→D2a/D2b, D7→D7a/D7b/D7c, P3 target-safe allowlist 정정, verification bare-filename grep + source-only pointer 0 추가 | 사용자 구현 승인 대기 |
| R40 | Claude | 구현 완료 + self-validation. manual 1790→919줄(~49% 축소). S1-S5 + P4 적용, D2b/D7c teaching·§4 diagrams·worked example 보존. 모든 검증 PASS(아래 R40 블록) | Codex result review 요청 |
| R41 | Codex | Result review: Changes requested. P0 없음, P1 1건 — manual의 source README anchor(`#12`/`#2`/`#11`/`#10`/`#7`)가 generated target README(heading 구조 상이)에서 dangling. "target-safe=파일+anchor 존재" 기준 강화. P2 2건(새 heading 한국어, anchor-compat 검증 추가) | Claude 반영 |
| R42 | Claude | R41 P1 수용·검증·수정. target README anchor 부재 직접 확인 후 manual의 README anchor 7개 모두 제거(→ source repo README anchorless + "source repo" 문맥 명시), command은 target-copied `HARNESS-QUICK-REFERENCE.md#command-taxonomy`로. P2: 신규 heading 6개 English Title Case화, anchor-compat 검증 추가. 재검증 PASS | Codex 재리뷰 요청 |
| R43 | Codex | 재리뷰에서 source repo README prose가 여전히 relative markdown link로 target README에 연결되는 의미상 오류를 발견. 사용자 요청으로 Codex가 직접 README relative link를 prose로 치환하고 target-safe anchored link를 `HARNESS-QUICK-REFERENCE.md#command-taxonomy`만 남김 | Resolved |

### R37 Claude Plan Draft

**결론:** manual은 1790 lines 중 ~1300 lines(D1-D7)가 canonical/README 재호스팅이다. 이를 user-facing teaching 자산(§1 notation, §4 diagrams, §5 worked examples)만 남기고 단방향 pointer로 위임한다. canonical→manual 역참조는 #11에서 이미 제거됐으므로, 이번 Work는 manual→canonical forward pointer만 정리한다.

Codex 검토 요청(code-review stance, P0/P1 우선):

1. **재호스팅 inventory(D1-D7):** 제거 대상 구간과 SSoT 매핑이 정확한가? 잘못 "중복"으로 분류해 manual 고유 정보를 잃을 위험은 없는가? 특히 §3 per-file 설명에 README §11에 없는 고유 nuance가 있는지.
2. **유지 자산 경계:** §4 diagrams·§5 worked examples·notation을 "유지"로 둔 판단이 맞는가, 아니면 일부도 README/quick-reference로 위임 가능한가?
3. **source/scaffold boundary:** manual은 Optional pack이다. pointer 대상이 target에 실제 복사되는 문서인지(P3 leak guard)와, --with-optional target에서 깨진 pointer가 생기지 않는지.
4. **canonical/adapter/no-alias drift:** 축약 과정에서 old command name 재유입, Approval/Risk/Trigger 표 재호스팅 잔존, canonical→manual 역참조 재신설 위험.
5. **검증 재현 가능성:** verification matrix(TOC/anchor, mermaid, DR leak, fresh --with-optional --check 0 drifted)가 deep rewrite 회귀를 잡기에 충분한가? 누락 검증은?
6. **stage/commit boundary:** S1-S5 분리와 단일 PR 통합이 ~1300 lines 제거의 리뷰/rollback 단위로 적절한가?

### R38 Codex Plan Review

**결론: Changes requested.** P0 없음. 방향은 맞으나 현재 plan대로면 optional target dangling pointer + manual 고유 학습 정보 손실 위험. P1 3건 반영 후 구현 착수 가능.

- **P1-1:** `SCAFFOLD-ONBOARDING-GUIDE.md`는 `--with-optional`이 복사하지 않는다(`create-harness.sh`는 HARNESS-ARCHITECTURE/MAINTAINER-GUIDE/WORKFLOW-MANUAL만 복사). manual에 이 guide pointer를 넣으면 optional target에서 dangling. → pointer는 target-safe 문서로 제한, guide는 source-only 참고로.
- **P1-2:** D2 §3 전체를 per-file 카탈로그로 보면 STATUS 섹션 관계(:324)·Work item routing(:392)·archive/update safety·Work file lifecycle/template(:521) 같은 teaching 자산을 잃는다. → D2a(catalog 제거)/D2b(State/Work teaching compact 보존)로 분할.
- **P1-3:** Appendix B에는 script scaffold 외 "no-script 수동 구성 checklist"(:1560)와 Claude-assisted init prompt(:1724)가 있어 README/guide로 완전 대체 불가. 보존 시 old 파일명(:1683 `start.md`/`pick.md`/...)을 새 adapter 이름으로 갱신 필수. → D7a/D7b/D7c 분할.
- **P2:** ① old-name grep에 bare filename(`start.md|pick.md|...`) 추가. ② fresh optional 86 tracked는 copy matrix 불변 전제에서만 고정. ③ SCAFFOLD-BOOTSTRAP 등 source-only 참조도 optional target dangling 대상으로 명시.

### R39 Claude Response To R38

**R38 전면 수용.** P1 3건은 모두 사실로 직접 재확인했다:

- **P1-1 검증:** `scripts/create-harness.sh`의 `--with-optional` 블록은 HARNESS-ARCHITECTURE/MAINTAINER-GUIDE/WORKFLOW-MANUAL만 복사하고 `SCAFFOLD-ONBOARDING-GUIDE`/`SCAFFOLD-BOOTSTRAP`는 스크립트 어디에도 복사 대상이 없음(source-only) 확인. → P3에 target-safe allowlist 표 추가, onboarding pointer를 README §10 + `docs/BOOTSTRAP.md`로 변경.
- **P1-2 검증:** §3에 STATUS 관계·Work routing·archive safety·Work lifecycle/template teaching 자산 실재 확인. → D2a/D2b 분할, S1b stage 추가, Done Criteria에 D2b 보존 항목 추가.
- **P1-3 검증:** `docs/WORKFLOW-MANUAL.md:1683`에 old 파일명(`start.md, pick.md, register.md, work.md, resume.md, debug.md, doc.md, close.md, done.md, record-decision.md, health.md`) 잔존 확인(#11 narrow fix가 bare filename grep을 못 잡아 누락). → D7a/D7b/D7c 분할, S4b stage 추가, Done Criteria에 D7c 보존+현행화 항목 추가.
- **P2 수용:** old-name grep에 bare filename 패턴 추가, 86 tracked 고정 전제 명시, source-only 참조(SCAFFOLD-BOOTSTRAP 등) pointer 0을 verification에 추가.

plan 갱신 완료. 구현은 사용자 승인 후 착수.

### R40 Claude Implementation Summary

구현 완료. Codex result review를 요청한다.

**규모:** `docs/WORKFLOW-MANUAL.md` 1790 → 919 lines (~49% 축소, ~871 lines 제거).

**적용 내역(stage별):**

- **S1/S1b (§2·§3):** §2 중복 mermaid 3종(2-0/2-1/2-2) + File tree → README §12/§2 pointer. §3 Document Hierarchy mermaid(D3) + per-file 역할 카탈로그(D2a, CLAUDE/BEHAVIOR/AGENT-WORKFLOW/PLAN-SUMMARY/ARCH/MAINTAINER/PROTOCOL/QUICK-REF/backlog/decisions/archive/retrospectives) + 재호스팅 절차(archive 이동·STATUS 안전 업데이트·실패 복구) + Work 상세 절차/YAML 템플릿/Approval 상태표 → 위임. **D2b 보존:** STATUS 섹션 개념·상관관계 + 관계 mermaid + 헷갈리는 상황 매핑 + Work Item Routing Flow mermaid + Work 라이프사이클 개념·생성 트리거.
- **S2 (§5):** Approval Matrix 전표 + Risk Level 표·mermaid → 개념 + AGENT-WORKFLOW pointer. command→use-case 표·Usage Pattern Examples·repo-health cadence 보존.
- **S3 (§7):** Trigger Cascade Overview mermaid + Trigger Index + T1-T9 상세(~207 lines) → "변경→점검" user-facing 요약표 + HARNESS-PROTOCOL pointer.
- **S4 (§6·AppB):** §6 DR File Structure 템플릿 → DECISION-TEMPLATE/DR-008 pointer(When-to-DR·DR Lifecycle mermaid 보존). Appendix B Quick Start scaffold(D7a)·First Session Guide(D7b) → README §10 + `docs/BOOTSTRAP.md` pointer. **D7c 보존+현행화:** Manual Initialization Checklist + Claude-Assisted Init Prompt 유지, old 파일명(`start.md`/`pick.md`/...)을 canonical+adapter 새 이름으로 갱신.
- **S5:** TOC stale anchor(2-0/2-1/2-2, 3-0, Work File Lifecycle, Risk Gate, Cascade Overview) 정리, §1 notation의 T1~T9 → Trigger 일반화, §6 mermaid의 orphan `T5` 라벨 제거, Work 섹션 double-heading 병합.
- **P4 (사용자 추가):** Appendix B에 "이미 하네스를 쓰던 repo의 canonical/adapter/no-alias 전환" 안내 1블록. 새 이름은 README §7/Quick Reference로, 전환 절차는 source migration note **prose 참조**(relative-link 금지).

**Self-validation (전부 PASS):**

- `git diff --check` PASS
- 깨진 내부 anchor 0 (제거 섹션 참조 grep)
- old command name 0 (slash + bare filename `*.md` 양쪽)
- source-only relative-link pointer 0 (SCAFFOLD-ONBOARDING-GUIDE/SCAFFOLD-BOOTSTRAP/MIGRATION-CANONICAL)
- source-only DR(019/021/022/023/024) 인용 0
- mermaid fence 균형(8 mermaid, 총 26 fence 짝수)
- `scripts/tests/check-scaffold-invariants.sh` default+`--with-optional` OVERALL PASS
- fresh `--with-optional` scaffold `--check`: **86 tracked / 0 drifted**, manual(919 lines) 포함
- generated target manual: old-name 0, source-only DR 0, 깨진 source-only link 0
- target pointer 실재 확인: README/AGENT-WORKFLOW/HARNESS-PROTOCOL/HARNESS-QUICK-REFERENCE/BOOTSTRAP/DR-013/DR-014/DECISION-TEMPLATE/DR-008 모두 target-safe

**보존 확인(제거된 고유 정보 0):** §1 notation/principles/color key, §4 Workflow Diagrams 4종, §5 worked Usage Examples, §6 When-to-DR + DR Lifecycle, D2b STATUS/Work teaching, D7c manual-setup checklist + Claude-assisted prompt, Appendix A/C.

Codex result review = R41. commit/PR는 사용자 승인 후 별도 단계.

### R41 Codex Result Review

**결론: Changes requested.** P0 없음, P1 1건. D2b/D7c 보존·old-name historical 처리·source-only migration note 무링크는 잘 반영. 단 optional target에서 README section anchor가 깨진다.

- **P1:** manual은 optional pack으로 target에 복사되는데, manual이 source README anchor(`#12-repository-layout`/`#2-document-layers`/`#11-key-documents`/`#10-new-project-adoption`/`#7-command-map`)를 직접 가리킨다. fresh `--with-optional` target의 generated README는 `## AI Workflow Harness`/`### Workflow 구조` 정도만 있고 numbered anchor가 없어 dangling. R38 "target-safe pointer" 기준은 파일 존재뿐 아니라 anchor 존재까지 포함해야 한다. → README link는 anchor 없이 `../README.md`로 낮추거나 target-copied 문서의 안정 anchor로 돌리고, source README 특정 section 참조는 source-only 문맥으로 제한.
- **P2:** ① 새/유지 heading 중 한국어 title이 남음(DR-007 Bilingual, 비차단이나 새로 만진 heading은 English Title Case 권장). ② 검증 matrix에 "target scaffold README anchor compatibility" 추가 권장.

### R42 Claude Response To R41

**R41 P1 수용.** target README anchor 부재를 직접 확인했다 — fresh `--with-optional` target의 generated README headings = `# {project}`, `## AI Workflow Harness`, `### Workflow 구조`, `### 첫 세션`, `## 사전 작업`뿐. manual이 가리키던 README anchor 7개 전부 dangling 확정. 다른 doc 링크(AGENT-WORKFLOW/HARNESS-PROTOCOL/DR/BOOTSTRAP)는 anchorless라 무해.

**수정:**

- manual의 README anchor 7개(line 102/143/144/260/278/670/678) 모두 제거 → `../README.md`(anchorless) + "source repo의 README {섹션명}" 문맥으로 명시. source README 구조 의존 제거.
- command 이름 참조(구 line 678)는 target-copied **`HARNESS-QUICK-REFERENCE.md#command-taxonomy`**로 전환(target에 `### Command Taxonomy` 실재 확인). README Command Map은 source 문맥 보조로만.
- **P2-①:** 신규 heading 6개 English Title Case화 — `3-0. Reading the Document Hierarchy`, `Reading and Writing Work Files`, `Tool Surface (...)`, `Authoring a DR`, `Apply via Scaffold (Recommended)`, `Migrating an Existing Harness Repo to Canonical/Adapter/No-Alias`. (anchor를 참조하는 곳 없어 안전)
- **P2-②:** Verification matrix에 "Target anchor compatibility" 항목 추가.

**재검증 PASS:** manual의 `README.md#` anchor 0, 유일 anchored link `HARNESS-QUICK-REFERENCE.md#command-taxonomy`가 target에 실재, fresh `--with-optional --check` 86 tracked/0 drifted, target manual broken README anchor 0, scaffold invariants OVERALL PASS, old-name·source-only·DR leak 0, `git diff --check` PASS.

Codex 재리뷰 = R43.

### R43 Codex Follow-Up And Direct Fix

R42에서 README section anchor dangling은 해소됐지만, `source repo의 [README](../README.md)` 형태가 optional target에서는 generated target README로 연결되는 의미상 오류가 남아 있었다. 사용자 요청에 따라 Codex가 직접 수정했다.

- `docs/WORKFLOW-MANUAL.md`의 source repo README 참조는 markdown relative link 없이 prose로만 남겼다.
- manual에 남은 cross-doc anchored link는 target-copied `docs/HARNESS-QUICK-REFERENCE.md#command-taxonomy`뿐이다.
- `WORKFLOW-MANUAL deep rewrite` backlog 후보를 제거했고, 후속으로 발견된 scaffold target maintenance/update caution note 후보는 `docs/backlog/HARNESS.md`에 별도 Candidate로 남겼다.
- `docs/STATUS.md` Active Work pointer는 애초에 없어서 제거하지 않았다. stale Next Actions는 CHORE-20260606-003 완료 이후 후보 기준으로 갱신했다.
- Work 파일과 Work index를 Done 처리했다. Archive는 보류한다.

## Discovery

- Branch Isolation Check: `develop` clean에서 protected workflow edit 금지 확인 후 `feature/chore-20260606-003-workflow-manual-deep-rewrite` branch 생성.
- Round 연속성: slice #11이 R36(Claude approval)으로 종료. 역할 전환(Claude 구현 / Codex 리뷰)에 따라 이번 slice 첫 cross-agent 기여는 이 Claude plan draft = R37. Codex plan review는 R38, 이후 Claude 구현 요약 R39, Codex result review R40 순. (사용자 Codex 핸드오프 메시지의 round를 R38로 두면 됨.)
- STATUS drift: slice #13/#11 merge(#76/#77) 후 `docs/STATUS.md` Next Actions #1이 여전히 #13/#11을 미완으로 서술. 이 Work 구현 단계에서 STATUS Next Actions 갱신을 state-change 제안에 포함 예정(현재 미수정).
- Manual 구조 진단: 1790 lines, §1-§7 + Appendix A/B/C. §3 Component Role Reference(~400)와 Appendix B New Project Initialization(~374)이 최대 중복. §7 Trigger Reference(~313)는 HARNESS-PROTOCOL 중복.
- Work ID 날짜: 직전 두 slice가 `CHORE-20260606-001/002`라 sequence 연속성을 위해 `-003`/2026-06-06으로 맞췄다. 다른 날짜를 원하면 파일 rename으로 정정 가능(Low cost).
- Optional-pack note: manual은 default minimal scaffold에 없고 `--with-optional` + source repo에만 존재. blast radius 제한적이나 DR-citation leak guard는 동일 적용.
- R36 P2-a 연계: 이 Work가 slice #11에서 이연한 manual deep rewrite를 실제로 수행하므로, R36 P2-a(backlog 미등록 우려)는 이 Work 등록으로 해소된다.
- P4 추가(사용자 범위): R39 이후 사용자가 upgrade/migration user-facing 안내를 plan에 추가 요청. `scripts/create-harness.sh`와 fresh target 실측으로 `MIGRATION-CANONICAL-ADAPTER-RENAME.md`가 source-only(미복사)임을 재확인했고, manual은 현재 migration을 사실상 미언급(순수 추가). P4는 R38 dangling-pointer 방어선의 연장이라 plan 방향과 일치한다. scope 추가가 작고 user-facing 한정이므로 별도 plan-review 라운드를 강제하지 않고 Codex result review(R40)에서 함께 확인한다. 절차 상세는 비목표로 두고 필요 시 backlog 후보로 등록한다.
- Closeout: R43 direct fix 이후 source README relative links를 제거했다. `/work-close` 처리로 `actual_end: 2026-06-05`, Work index Done 이동, stale STATUS Next Actions 갱신, 완료된 backlog candidate 제거를 반영했다. Commit/PR은 별도 승인 단계로 남긴다.
