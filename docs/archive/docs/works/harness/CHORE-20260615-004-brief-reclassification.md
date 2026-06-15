---
id: CHORE-20260615-004
priority: P1
status: Archived
actual_end: 2026-06-15
risk: L2
scope: `docs/briefs/`를 live category로 공식화하고, 기존 방향성 문서를 retrospective에서 brief로 재분류하며, `/work-brief` surface·core protocol·user-facing docs·scaffold까지 최소 cascade를 맞춘다. 이미 진행된 변경을 소급 추적하며, Claude review round로 분류 정합과 과잉 주장 여부를 다시 검토한다.
appetite: 0.5d
planned_start: 2026-06-15
planned_end: 2026-06-15
related_dr: [DR-007, DR-008, DR-013, DR-027]
related_troubleshooting: []
related_work: [CHORE-20260611-011, CHORE-20260612-002, CHORE-20260613-004]
---

# CHORE-20260615-004: Brief Taxonomy + Retrospective Reclassification

> **주의:** 이 Work 파일은 이미 진행한 변경을 **소급 정리**한 예외 케이스다. 새 Work 파일 작성 예제로 재사용하지 말고, 일반적인 흐름은 최근의 비소급 Work 파일을 참고한다.

## Top Summary

- **목표:** `docs/briefs/`를 retrospective/DR와 구분되는 live category로 고정하고, 관련 문서/skill/scaffold/cascade를 현재 분류에 맞춘다.
- **왜 지금:** `harness-workflow-engine-vs-manual-first-20260615.md`가 회고보다 방향 비교 문서에 가까웠고, 같은 성격의 문서 3건도 함께 이동해야 했다. 병렬 작업 중 최소 정합만 먼저 맞춘 뒤, authoritative taxonomy와 review surface를 Codex 쪽에서 보강했다.
- **현재 상태:** live reclassification과 `/work-brief` surface 추가, README/manual/protocol/scaffold cascade, moved brief 내부 링크·용어 정리는 반영됨. Work 추적과 Claude review package가 아직 없었다.
- **핵심 경계:** archive snapshot의 역사 보존을 깨지 않는다. `docs/STATUS.md` Active pointer는 별도 승인 없이 수정하지 않는다. commit/merge는 이번 Work 범위가 아니다.

## Candidate / Backlog Link

- 별도 backlog candidate에서 시작한 작업이 아니라, 사용자 직접 지시와 Claude/Codex 병렬 작업 중 발생한 **in-flight reclassification**을 소급 추적한다.
- follow-up 성격의 잔여 판단은 이 Work의 `Discovery`와 Claude review 결과를 바탕으로 backlog 분리 여부를 다시 결정한다.

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/briefs/README.md` | 전체 | brief taxonomy와 frontmatter spec의 authoritative 진입점 |
| 2 | `skills/workflow/work-brief.md` | 전체 | 새 command/skill의 canonical 절차 확인 |
| 3 | `docs/HARNESS-PROTOCOL.md` | Retrospective And Brief Loading, Document Role Distinction, Update Rules | brief와 retrospective의 역할 경계 및 cascade 반영 확인 |
| 4 | `README.md`, `docs/WORKFLOW-MANUAL.md`, `docs/HARNESS-QUICK-REFERENCE.md` | command/docs map | user-facing entrypoint와 `/work-brief` 노출 확인 |
| 5 | `scripts/create-harness.sh` | docs scaffold block | scaffold에도 `docs/briefs/`와 `work-brief`가 생성되는지 확인 |
| 6 | `docs/briefs/harness-*.md`, `docs/retrospectives/README.md` | moved docs + source index | moved brief self-description/links와 source index 정합 확인 |

Trigger: user request "회고가 아니라 brief로 가야 할 것 같으니 지금 정리하자", 이후 "늦었지만 work 파일 만들고 claude와 라운드 진행".

## Scope

1. 이미 반영된 live reclassification 변경을 Work SSoT로 소급 정리한다.
2. `docs/works/harness/README.md` Active row를 추가한다. `docs/STATUS.md` Active pointer는 승인 없이라 수정하지 않는다.
3. Claude가 review하기 쉽도록 변경 지점을 군집별로 정리한다.
4. archive된 retrospective 재분류 필요 여부를 별도 점검하고, 실제 no-action이면 근거를 기록한다.

## Non-Goals

- `docs/STATUS.md` Active Work pointer 추가 또는 Recent Decisions 갱신.
- archive-side historical snapshot의 본문/링크 대량 수정.
- 이번 Work 안에서의 commit, PR, merge.
- brief taxonomy를 다시 다른 category로 재분류하는 추가 IA 개편.

## Files

### Tracking

| 파일 | 계획 |
| --- | --- |
| `docs/works/harness/CHORE-20260615-004-brief-reclassification.md` | Work SSoT |
| `docs/works/harness/README.md` | Active row 추가 |

### Changed Surfaces

| Cluster | 파일 |
| --- | --- |
| Taxonomy / command | `docs/briefs/README.md`, `skills/workflow/work-brief.md`, `.claude/commands/work-brief.md`, `.agents/skills/workflow-work-brief/SKILL.md`, `skills/workflow/README.md`, `.cursor/rules/workflow.mdc` |
| Core protocol / routing | `README.md`, `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md`, `docs/WORKFLOW-MANUAL.md`, `docs/HARNESS-ARCHITECTURE.md`, `docs/HARNESS-NAMING-RULES.md`, `docs/decisions/DR-008-docs-filename-standard.md` |
| Verification / scaffold / backlog | `skills/workflow/repo-health.md`, `skills/workflow/repo-health-cascade.md`, `skills/workflow/work-plan.md`, `skills/workflow/work-select.md`, `skills/workflow/work-doc.md`, `docs/backlog/HARNESS.md`, `scripts/create-harness.sh` |
| Reclassified docs | `docs/briefs/harness-identity-policy-first-20260608.md`, `docs/briefs/harness-distribution-plugin-model-20260608.md`, `docs/briefs/harness-internal-managed-upgrade-20260615.md`, `docs/briefs/harness-workflow-engine-vs-manual-first-20260615.md`, `docs/retrospectives/README.md` |

## Done Criteria

- [x] `feature/*` branch에서 작업하도록 branch isolation을 회복한다.
- [x] `docs/briefs/` taxonomy, `/work-brief` canonical/adapter, user-facing docs map, scaffold 생성 surface가 live 기준으로 정렬된다.
- [x] moved brief 4건의 live 링크와 자기지칭 용어가 현재 분류와 충돌하지 않게 정리된다.
- [x] `docs/backlog/HARNESS.md`의 live broken link가 새 brief 경로로 교정된다.
- [x] `git diff --check`, `check-shipped-dr-closure.sh`, scaffold dry-run이 통과한다.
- [x] 이 Work 파일과 `docs/works/harness/README.md` Active row가 생성된다.
- [x] Claude review round를 위한 변경 지점/검토 포인트가 문서화된다.
- [x] archive된 retrospective 재분류 필요 여부가 근거와 함께 기록된다.

## Verification

Executed:

```bash
git diff --check
bash scripts/tests/check-shipped-dr-closure.sh
bash scripts/create-harness.sh --dry-run brief-reclass-smoke
rg -n "docs/retrospectives/harness-(distribution-plugin-model|identity-policy-first|internal-managed-upgrade)|공동 회고 형식|이 회고|11개 command" README.md docs scripts skills .claude .agents .cursor
```

Expected follow-up check after Work tracking write:

```bash
git diff --check
rg -n "CHORE-20260615-004|brief-reclassification" docs/works/harness/README.md docs/works/harness/CHORE-20260615-004-brief-reclassification.md
git branch --show-current
```

## Risk / Reversal Cost

| Item | Assessment |
| --- | --- |
| Risk level | L2 — harness/workflow surface + scaffold |
| Reversal cost | Medium. 문서/skill/scaffold surface가 함께 엮여 있어 일부만 되돌리면 drift가 생긴다 |
| Main risk | `brief`를 새 category로 만들면서 retrospective/DR와의 경계를 과장하거나, 반대로 user-facing/manual/scaffold 중 일부를 놓쳐 hidden drift를 남기는 것 |
| Secondary risk | moved brief 본문에서 "회고"라는 표현을 무리하게 제거해 역사적 문맥까지 왜곡하는 것 |
| Control | live surface 중심 정렬, archive snapshot no-action 원칙, Claude review에서 taxonomy/claim 과대 여부 재검토 |

## Open Questions

| ID | Question | Default Assumption |
| --- | --- | --- |
| OQ-1 | archive된 retrospective 자체를 `docs/archive/docs/briefs/`로 재분류해야 하는가? | 기본값은 No. archive는 snapshot immutability를 우선하고, live taxonomy fix와 분리한다 |
| OQ-2 | moved brief 내부에서 "회고"라는 단어가 남아 있는 문맥을 모두 제거해야 하는가? | No. 자기지칭/분류 충돌만 정리하고, readiness retrospective 같은 실제 retrospective 참조는 유지한다 |
| OQ-3 | 이번 Work에서 `docs/STATUS.md` Active pointer까지 추가할 것인가? | No. 사용자 승인 없이는 Work 파일 + works README까지만 |

## Approval / State

| Item | Status |
| --- | --- |
| 위험도 | L2 |
| 실행 모드 | Standard Work |
| Branch Isolation | PASS — `feature/chore-20260615-004-brief-reclassification` |
| Tool rule reference | `.claude/rules/docs-workflow.md` 수동 적용. DR-007 준수 필요 |
| PLAN 영향 | 없음. IA/cascade 정합 Work이며 roadmap 방향 변경은 아님 |
| STATUS proposal | 현재는 `docs/STATUS.md` 변경 없음. 필요 시 별도 승인 후 Active pointer 제안 |
| State machine | VALIDATE 완료. CHECKPOINT(`/work-close` 여부 판단) 대기 |

## Cross-Agent Review And Discussion

> 이번 세션 역할: Codex = author/driver, Claude = reviewer. 이 Work는 소급 정리이므로, 아래 `Changed Surfaces`와 `Review Focus`를 Claude의 1차 읽기 순서로 사용한다.

### Review Focus

1. **taxonomy claim이 과장되지 않았는가**
   - `docs/briefs/README.md`, `docs/HARNESS-PROTOCOL.md`, `skills/workflow/work-brief.md`
2. **entrypoint/canonical/user-facing/scaffold cascade가 빠진 곳이 없는가**
   - `README.md`, `docs/WORKFLOW-MANUAL.md`, `docs/HARNESS-QUICK-REFERENCE.md`, `skills/workflow/repo-health*.md`, `scripts/create-harness.sh`
3. **moved brief 본문이 새 분류와 충돌하지 않는가**
   - `docs/briefs/harness-*.md`, `docs/retrospectives/README.md`
4. **archive 재분류를 live fix와 섞지 않았는가**
   - `docs/archive/docs/retrospectives/`, `docs/archive/docs/works/**`는 근거 기록만 하고, snapshot rewrite는 하지 않았는지 확인

### Claude Review Request

Claude review 요청 시 우선 확인할 변경 군집:

| Cluster | 검토 질문 |
| --- | --- |
| Taxonomy / command | brief가 retrospective/DR 사이의 중복 category가 아니라, 실제 사용 가치가 있는 독립 분류로 정의됐는가? `/work-brief`가 과잉 command가 아닌가? |
| Core protocol / routing | `AGENT-WORKFLOW`/`HARNESS-PROTOCOL`/README/manual 사이에 brief load rule과 command map drift가 없는가? |
| Verification / scaffold | repo-health가 brief index를 감사하도록 바뀐 것이 적절한가? scaffold가 `docs/briefs/README.md`와 `work-brief`를 빠짐없이 생성하는가? |
| Reclassified docs | moved brief 4건 중 아직 회고 자기지칭, stale path, 과도한 claim이 남아 있지 않은가? |
| Archive no-action | archive retrospective 자체는 재분류 대상이 아니라고 본 판단이 타당한가? |

### Round Log

| Round | Reviewer | Type | Findings | Codex Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Claude | Pre-work coordination | 병렬 작업 충돌을 피하기 위해 moved brief 실파일과 source index 최소 정합만 먼저 맞추고, authoritative taxonomy/workflow/cascade는 Codex 쪽에서 진행하기로 분리 | 반영 완료. Claude는 moved docs와 source index 최소 정합, Codex는 taxonomy/workflow/scaffold/cascade와 최종 review package 담당 | Accepted |
| R1 | Claude | Result Review | Approved. 사용자가 지정한 4개 위험(taxonomy 과장, cascade 누락, moved brief self-ref/link 충돌, archive no-action 판단)은 모두 실측 통과. Low 3건만 남음: F1 moved brief frontmatter `type: process` 유지, F2 `/work-brief` default scaffold ship vs `/work-doc` B-class 불일치 질문, F3 `create-harness.sh`의 briefs README inline template drift 가능성 | F1은 **defer**. enum은 open이고 invalid는 아니므로 commit 차단 사유 아님. 다만 taxonomy polish 가치가 있어 후속 선택 과제로 남긴다. F2는 **default 유지** 쪽으로 기록. `/work-brief`는 niche 산출물 생성보다 live 문서 분류/triage 기능이 강해 `/work-doc`보다 기본 surface 가치가 크다. F3는 **known pattern으로 수용**. 현재 scaffold 패턴 전반의 inline template 복제 특성 일부이며, `repo-health` cascade 감사 대상에 briefs가 이미 편입돼 있어 drift는 탐지 가능하다. 필요 시 template dedup은 별도 후속으로 분리 | Approved |

## Next Actions

- 현재 diff를 기준으로 commit 묶음 범위와 message 전략 정리
- `/work-close`로 Done 처리할지, low findings(F1~F3)를 추가 polish 없이 닫을지 판단
- archive retrospective reclassification이 실제로 필요하다는 새 finding이 생기면 별도 후속 Work 또는 backlog candidate로 분리

## Discovery

- 2026-06-15: user가 `harness-workflow-engine-vs-manual-first-20260615.md`가 회고보다 brief에 가깝다고 문제제기했고, `docs/decisions/` 또는 `docs/briefs/` 재분류 필요성을 제안했다.
- 2026-06-15: Claude가 병렬 작업 중 moved brief 실파일, `docs/retrospectives/README.md`, `docs/briefs/README.md` 최소 정합을 맞췄고, Codex는 그 위에서 taxonomy/skill/scaffold/cascade를 확장했다.
- 2026-06-15: branch isolation 위반 상태(`develop`에서 protected files 수정 중)를 뒤늦게 확인했고, 현재 변경분을 유지한 채 `feature/chore-20260615-004-brief-reclassification`으로 이동해 회복했다.
- 2026-06-15: live surface 기준으로는 `README`, `WORKFLOW-MANUAL`, `HARNESS-PROTOCOL`, `repo-health`, `create-harness.sh`까지 brief category를 반영했다.
- 2026-06-15: archive retrospective 재분류는 새로 확인했다. `docs/archive/docs/retrospectives/`에는 이번에 moved한 4개 live 문서의 archive copy가 없었고, old path는 주로 archive-side Work snapshot 안에 남아 있었다. 이는 historical record라 현재는 no-action이 더 안전하다고 판단한다.
- 2026-06-15: user가 추가로 언급한 `README/manual/guide`, `scaffold`는 이미 이번 diff에서 반영 대상이었다. 따라서 새 review에서는 이 두 축을 "추가 작업 제안"이 아니라 "이미 반영된 군집 검토"로 다루는 편이 맞다.
- 2026-06-15: Claude R1 결과는 Approved이며 must-fix는 없었다. 남은 F1~F3는 모두 low로, 현재 commit을 막지 않는 polish/판단 항목으로 분류한다.
- 2026-06-15: `/work-brief` default ship 여부는 `/work-doc`와 달리 "문서 산출물 생성"이 아니라 "live 문서 분류 triage" 성격이 강하다는 차이로 방어 가능하다고 판단했다. 다만 이 판단은 향후 command surface diet 논의에서 다시 열 수 있다.
- 2026-06-15: closeout(PR #196 merge) 후 archive 처리. `status: Archived`로 전환하고 `docs/archive/docs/works/harness/`로 이동, live index에서 제거하고 archive-side index에 등재한다.
