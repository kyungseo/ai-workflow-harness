---
id: CHORE-20260611-004
priority: P1
status: Archived
risk: L2
scope: harness 행동을 유도하는 내용을 agent-side 지속 컨텍스트(Claude memory, Codex 전역 profile, Cursor user-level rules)에 저장하지 않는다는 cross-agent 정책을 harness 문서로 명문화하고, 현존 Claude memory 4개 파일의 처리 방향을 결정·실행한다. 정책의 hard-gate 강제화는 범위에서 제외한다.
appetite: 0.5d
planned_start: 2026-06-11
planned_end: 2026-06-11
actual_end: 2026-06-11
related_dr: []
related_troubleshooting: []
related_work: [CHORE-20260611-001, CHORE-20260611-002, CHORE-20260611-003]
---

# CHORE-20260611-004: Harness dev/test noise scope policy

## Top Summary

- **목표:** "이 repo의 harness 행동을 유도하는 내용은 agent-side 지속 컨텍스트에 저장하지 않는다"를 cross-agent(Claude/Codex/Cursor) 정책으로 harness 문서에 명문화하고, harness 동작이 "harness 문서만으로" 유도되는지 검증 가능한 상태를 만든다.
- **핵심 판단:** 정책이 겨냥하는 대상은 **repo 밖 agent-side 지속 컨텍스트**(Claude `~/.claude/.../memory/`, Codex 전역 profile, Cursor user-level rules)다. in-repo harness-owned 표면(`.cursor/rules/`, `.agents/skills/`, `.claude/commands/`, `.claude/rules/`)은 harness 자체이므로 SSoT의 일부이며 정책 대상이 아니다.
- **역설 발견:** 이미 존재하는 `memory/feedback_memory_scope.md`가 "워크플로우 규칙 memory 저장 금지" 원칙을 담고 있으나 Claude 한정이고, 그 원칙 자체가 agent-side 컨텍스트(memory)에만 존재한다. cross-agent 정책은 harness 문서(SSoT)로 승격되어야 한다.
- **author/driver:** Claude (A). **reviewer:** Codex (B). 합의 전 구현 보류.

## Problem Statement

AI agent가 harness 운영 행동 패턴(cascade 점검 규칙, commit bundling 방침, approval gate 습관 등)을 agent-side 지속 컨텍스트에 저장하면 두 가지 문제가 생긴다.

1. **검증 오염:** harness의 올바른 동작이 "harness 문서만으로" 유도되는지 검증할 수 없다. agent-side 컨텍스트가 행동을 보정하면, 문서가 비어 있어도 agent가 "기억"으로 올바르게 동작해 문서 결함이 가려진다.
2. **도구 간 불균등:** agent마다(Claude/Codex/Cursor) 지속 컨텍스트 보정 여부가 달라, 동일 harness 문서에 대한 검증 조건이 도구별로 달라진다.

이 원칙은 "harness docs = SSoT" 방향의 전제이며, `harness workflow 검증 테스트 체계 정립`(P1) 항목의 선행 조건이다.

## Conceptual Model (Scope Boundary)

| 분류 | 위치 | harness 행동 SSoT 여부 | 정책 대상 |
| --- | --- | --- | --- |
| in-repo harness-owned 표면 | `.claude/commands/`, `.claude/rules/`, `.cursor/rules/`, `.agents/skills/`, `docs/`, `skills/` | **SSoT의 일부** (버전 관리·검증 대상) | 대상 아님 |
| agent-side 지속 컨텍스트 | Claude `~/.claude/<proj>/memory/`, Codex 전역 profile/config, Cursor user-level(global) rules | SSoT 아님 (repo 밖, per-user/per-agent) | **정책 대상 (harness 행동 저장 금지)** |

핵심 구분선: **"repo에 commit되어 모든 도구·사용자가 동일하게 보는가"** vs **"특정 agent/사용자의 로컬 지속 컨텍스트인가"**. 후자에 harness 운영 행동을 넣으면 검증이 오염된다.

## Classification Test (무엇이 금지인가)

agent-side 지속 컨텍스트에 저장된 항목을 다음 기준으로 분류한다.

- **금지(harness 행동 패턴):** harness 운영 메커니즘을 유도/보정하는 내용. 예) cascade 점검 규칙, commit bundling, approval gate 절차, STATUS/Work 처리 순서, branch isolation 습관. → harness 문서가 SSoT여야 하므로 agent-side 저장 금지.
- **허용(harness 행동 아님):** harness 운영과 무관한 개인/일반 맥락. 예) 사용자 프로필·역할, 커뮤니케이션 스타일 선호, 외부 시스템 포인터(URL/대시보드), repo 무관 일반 안전 습관.
- **경계(판단 필요):** 일반 AI 행동 원칙이면서 harness 문서(`BEHAVIOR-PRINCIPLES.md`)에도 인코딩된 항목(예: pushback 원칙). 이미 문서가 SSoT인 내용을 memory가 중복 보유하면 검증 오염 위험.

**판정 룰 (R0 반영, Codex):** 저장된 내용이 **이 harness의 repo-specific operational instruction**을 구체적으로 유도하면 금지, repo 무관 일반 선호면 허용.

- **금지 신호:** repo명/경로, Work·STATUS lifecycle, gate/trigger/cascade, DR closure, branch-flow, commit bundling, approval 절차 등 운영 절차를 유도하는 내용.
- **허용 신호:** repo와 무관한 일반 커뮤니케이션 스타일·안전 선호·사용자 프로필·외부 시스템 포인터.
- 경계 항목(BEHAVIOR 중복 원칙)은 repo-specific operational 유도가 없으면 유지 가능하나, BEHAVIOR 중복만 있으면 pointer 축소를 기본으로 한다.

## Existing Claude Memory Audit (현황)

> 측정: 2026-06-11, `~/.claude/projects/-Users-kyungseo-dev-home-vibe-ai-workflow-harness/memory/`. backlog가 언급한 cascade-verification·T11 memory는 이미 부재(이전 세션 정리됨).

| 파일 | type | 내용 | 1차 분류 | 처리 후보 |
| --- | --- | --- | --- | --- |
| `user_profile.md` | user | 사용자 역할·기술수준·커뮤니케이션 스타일 | 허용 | 유지 |
| `feedback_destructive_commands.md` | feedback | rm -rf 등 파괴적 명령 사전 경고 (일반 안전) | 허용(경계) | 유지 (harness 메커니즘 아님) |
| `feedback_active_pushback.md` | feedback | 비효율·비논리 제안 시 능동 pushback. `BEHAVIOR-PRINCIPLES.md §1`에 이미 인코딩 | 경계 | OQ-3: 축소/pointer화 vs 유지 |
| `feedback_memory_scope.md` | feedback | "워크플로우 규칙 memory 저장 금지" + 저장 전 승인. Claude 한정 governance | 경계 | OQ-3: harness 문서로 승격 후 memory는 pointer로 축소 |

## Scope / Plan (착수 승인 + Codex 합의 후 실행)

1. **정책 명문화 위치 결정 (OQ-1).** 1차안: `docs/BEHAVIOR-PRINCIPLES.md`에 신규 원칙 섹션 추가 — 이미 모든 AI 도구 적용 cross-agent 전역 문서이고 충돌 우선순위 1위라 정책의 자연스러운 거처. 대안: 별도 정책 문서. → Codex 합의.
2. **정책 본문 작성.** Conceptual Model(scope boundary) + Classification Test(금지/허용/경계) + "harness docs = SSoT" 연결을 간결히 기술. core 문서 비대화를 피하기 위해 원칙은 짧게, 상세 분류 예시는 필요 시 pointer.
3. **Claude memory 처리 실행 (OQ-3).**
   - `feedback_memory_scope.md`: cross-agent 원칙을 harness 문서로 승격한 뒤, memory 파일은 제거 또는 "정책은 `BEHAVIOR-PRINCIPLES.md` 참조" pointer로 축소.
   - `feedback_active_pushback.md`: BEHAVIOR-PRINCIPLES §1 중복분 처리. harness-specific 운영 유도가 없으므로 pointer 축소를 기본으로 결정·실행.
   - `user_profile.md`, `feedback_destructive_commands.md`: 유지(근거 기록).
   - `MEMORY.md` 인덱스 정합 갱신. (확인: `MEMORY.md`는 실제 Claude memory 인덱스이며 위 4개 파일을 가리킴 — 2026-06-11 검증.)
   - **외부 memory 변경 절차 (R0 P1 반영):** Claude `memory/`는 repo 밖이라 PR diff로 검토/복구되지 않는다. 따라서 (a) 모든 memory 추가·축소·삭제는 **사용자 명시 승인 후** 실행하고, (b) 삭제·축소 전 **원문·경로·처리 결과를 본 Work 파일(Checkpoints/Discovery)에 기록**해 복구 근거를 남긴다. git revert로 복원되지 않음을 전제한다.
4. **Codex/Cursor agent-side 표면 점검 방침 정의 (OQ-4).** Codex 전역 profile과 Cursor user-level rules는 repo 밖이라 이 세션에서 직접 grep 불가. 정책 + self-audit checklist를 두고, 각 도구 사용자가 점검하도록 한다. (in-repo `.agents/skills/`·`.cursor/rules/`는 harness-owned이므로 정책 대상 아님을 명시.) **한계 명시 (R0 P2 반영):** Codex/Cursor 표면은 **owner attestation 또는 reviewer self-audit로만 확인 가능**하며, 자동 검증·hard-gate 대상이 아니다.
5. **검증.** agent별 지속 컨텍스트에 harness 행동 패턴 잔존 여부 확인(Claude memory grep), 정책 문서 cascade 점검.

## Done Criteria

- [x] cross-agent 관점에서 harness dev/test 노이즈 방지 원칙이 harness 문서에 명문화됨 (`BEHAVIOR-PRINCIPLES.md` §6).
- [x] scope boundary(in-repo harness-owned vs agent-side 지속 컨텍스트)와 금지/허용 분류 기준이 정책에 포함됨.
- [x] `feedback_memory_scope.md`의 원칙이 harness 문서로 승격되고, memory 파일 처리(pointer 축소)가 실행됨.
- [x] `feedback_active_pushback.md` 중복분 처리(pointer 축소), 나머지 2개 유지 근거 기록, `MEMORY.md` 정합.
- [x] Codex/Cursor agent-side 표면 점검 방침(self-audit + owner attestation 한계)이 `BEHAVIOR-PRINCIPLES.md` §6에 정의됨.
- [x] 원칙이 "harness docs = SSoT" 방향과 일관됨을 확인.

## Verification

- Claude `memory/` grep (harness 행동 패턴: cascade/commit bundling/approval/STATUS 절차): **금지(operational instruction) 항목 0건**, 허용/분류된 hit 2건 — (1) `user_profile.md` "cascade 영향을 스스로 포착한다"(사용자 사고 스타일 서술, instruction 아님), (2) `feedback_memory_scope.md` §6 정책 pointer(SSoT 참조). 둘 다 R1에서 허용 판정.
- 정책 문서가 `BEHAVIOR-PRINCIPLES.md`(또는 합의된 위치)에 반영되고 in-repo/agent-side 경계를 명확히 기술하는지 확인.
- cascade: 정책이 `AGENT-WORKFLOW.md`/관련 문서에서 참조되어야 하면 pointer 정합 점검.
- `git diff --check`, shipped DR closure(`bash scripts/tests/check-shipped-dr-closure.sh`).
- DR 신설 시(OQ-5) `docs/decisions/README.md` 인덱스 정합.

## Risk / Reversal

- **리스크 1 (over-removal):** 정당한 user/profile·안전 memory까지 과도 삭제하면 사용자 맥락 손실. → Classification Test로 금지/허용을 명확히 구분, 경계 항목은 Codex 합의 후 처리.
- **리스크 2 (정책 무실효):** Codex/Cursor agent-side 컨텍스트는 repo 밖이라 hard-gate 불가. 문서 정책 + self-audit에 머물면 실효성이 사용자 준수에 의존. → 강제화는 본 Work 범위 밖(`문서-only 규칙 강제화` backlog로 분리), 본 Work는 원칙·경계·Claude memory 실집행까지.
- **리스크 3 (core 문서 비대화):** BEHAVIOR-PRINCIPLES에 긴 체크리스트 추가 시 Simplicity First 위반. → 원칙은 짧게, 상세는 pointer.
- **되돌리기 비용:** Low~Medium. 문서 추가/memory 파일 변경이며 branch 단위 revert 가능. 단 memory 삭제는 repo 밖이라 git revert로 복원되지 않으므로, 삭제 전 내용 보존(transcript 기록)·승인 선행.

## Checkpoints

- 2026-06-11 — Work 파일 + plan 작성, Active 등록. Codex R0 Conditional Approve → must-fix 3건 반영(R0a).
- 2026-06-11 — 구현: `BEHAVIOR-PRINCIPLES.md` §6 신설, Claude memory 2개 pointer 축소, `MEMORY.md` 정합.
- 2026-06-11 — Archived: Done work 정리(routine), `/work-close` archive step. PR #143 merge 후 동일 세션 archive.

### Memory 변경 복구 기록 (§3 절차 — repo 밖, git revert 불가)

> 사용자 구현 승인(2026-06-11) 하에 실행. 아래는 축소 전 원문 보존.

**`feedback_memory_scope.md` (축소 전 원문):**

```
워크플로우 규칙, 프로젝트 상태, 결정 사항은 memory에 저장하지 않는다.
**Why:** harness 문서(AGENT-WORKFLOW.md, STATUS.md, DR 파일)가 SSoT다. memory에 규칙을 저장하면 harness 문서가 실제로 작동하는지 검증이 안 되고, 두 소스 간 drift가 발생한다.
**How to apply:** memory 저장 대상은 사용자 프로필, 커뮤니케이션 스타일, 외부 시스템 포인터에 한정한다. 워크플로우 피드백은 harness 문서에 직접 반영하고 memory에는 넣지 않는다.
memory에 무언가를 저장하기 전에 반드시 사용자 승인을 받는다. 저장 후 통보가 아니라 "이 내용을 memory에 저장하겠습니다 — 승인하시겠습니까?" 형태로 먼저 묻는다.
**Why:** 사용자가 memory scope를 직접 제어하길 원함. harness dev/test 노이즈 방지 원칙과 결합해 저장 전 판단 기회를 확보한다.
```

→ 처리: harness scope 원칙은 `BEHAVIOR-PRINCIPLES.md` §6로 승격. memory는 "변경 전 승인" 사용자 선호 + §6 pointer만 남김.

**`feedback_active_pushback.md` (축소 전 원문 요지):** 능동 pushback 원칙 + repo-specific anecdote(DR-017 squash 관례 위반 사례)가 Why로 포함됨. → 처리: 일반 pushback 원칙의 SSoT는 `BEHAVIOR-PRINCIPLES.md` §1. repo-specific DR-017 anecdote 제거, pointer로 축소.

## Cross-Agent Review And Discussion

이 Work는 A(Claude)가 author/driver로 Work 파일+plan 및 구현을 담당하고,
B(Codex)가 plan review와 result review를 수행한다.
합의 전에는 구현하지 않는다.

### Round Log

| Round | Reviewer | Type | Summary | Required Changes / Decision | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Codex | Plan Review | 방향 조건부 동의. in-repo harness-owned 표면과 repo 밖 agent-side 지속 컨텍스트를 가른 모델은 타당. | Must-fix 3건: (1) 외부 memory 변경 승인/증빙/복구 절차를 plan에 추가, (2) STATUS Last updated를 CHORE-004 Planning Active로 정합화, (3) 금지/허용 판정 룰을 repo-specific operational instruction 기준으로 명확화. OQ-1 BEHAVIOR-PRINCIPLES 채택, OQ-5 DR defer. | Conditional Approve |
| R0a | Claude | Plan Revision | Must-fix 3건 반영: 외부 memory 절차(Scope §3)·owner attestation 한계(§4)·판정 룰(Classification Test)·STATUS Last updated 정합화. | 조건 충족 — 합의 대기 | Addressed |
| R1 | Codex | Result Review | §6 본문은 R0 합의와 일치·adopter-neutral. memory 처리(pushback 축소, memory_scope governance 유지) 적절. user_profile cascade hit 허용 타당. | P2: Verification "잔존 0" → "금지 0건, 허용/분류 hit 기록"으로 정정. 보완 후 close 가능 | Conditional Approve |
| R1a | Claude | Result Revision | Verification 기록을 "금지 항목 0건 + 허용/분류 hit 2건"으로 정정. | 조건 충족 — close 진행 가능 | Addressed |

### Consensus Log

| Topic | Consensus | Source Round | Status |
| --- | --- | --- | --- |
| 정책 명문화 위치 | `docs/BEHAVIOR-PRINCIPLES.md`에 짧은 신규 섹션. 별도 문서는 과함 | R0 (OQ-1) | Agreed |
| 금지/허용 분류 기준 | repo-specific operational instruction 유도 시 금지, repo 무관 일반 선호는 허용 (판정 룰 명문화) | R0 (OQ-2) | Agreed |
| memory 파일 개별 처리 | `memory_scope` 승격 후 pointer 축소/제거, `active_pushback` BEHAVIOR 중복만이면 pointer 축소, 나머지 2개 유지 | R0 (OQ-3) | Agreed |
| 외부 memory 변경 절차 | 사용자 승인 후 실행 + 삭제·축소 전 원문/경로/결과 Work 기록 | R0 (P1) | Agreed |
| Codex/Cursor 확인 방식 | self-audit checklist + owner attestation 한계 명시 (자동검증·hard-gate 아님) | R0 (OQ-4) | Agreed |
| DR 격상 | 본 Work에서는 DR 미신설. 강제화/장기 enforcement 설계 시 격상 | R0 (OQ-5) | Agreed |

### Plan-Level Open Questions

| ID | Question | Owner | Status |
| --- | --- | --- | --- |
| OQ-1 | 정책 명문화 위치 | Claude + Codex | Resolved — `BEHAVIOR-PRINCIPLES.md` 신규 섹션 |
| OQ-2 | 금지/허용 경계 crisp화 | Claude + Codex | Resolved — repo-specific operational 판정 룰 추가 |
| OQ-3 | 현존 memory 4개 개별 처리 | Claude + Codex | Resolved — 승격/pointer 축소/유지 확정 |
| OQ-4 | Codex/Cursor agent-side 확인 방식 | Claude + Codex | Resolved — self-audit + owner attestation 한계 명시 |
| OQ-5 | DR 격상 여부 | Claude + Codex | Resolved — 본 Work 미신설, 향후 enforcement 시 격상 |
