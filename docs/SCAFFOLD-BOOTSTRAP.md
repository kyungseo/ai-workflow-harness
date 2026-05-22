# Scaffold Bootstrap Guide

이 문서는 `scripts/create-harness.sh`로 새 프로젝트 또는 기존 프로젝트에 하네스를 심은 직후,
빈 `STATUS.md`, `PLAN-SUMMARY.md`, backlog, Work index를 프로젝트 identity에 맞게 부팅하는 기준이다.

Scaffold된 프로젝트에는 project-local checklist인 `docs/BOOTSTRAP.md`가 생성된다.
이 source repository에서는 `docs/SCAFFOLD-BOOTSTRAP.md`가 그 산출물의 설계 기준이다.

## Boot Sequence

1. Project identity를 정한다: 이름, 한 줄 설명, 주요 사용자, production 성격, 공개/배포 방식.
2. Product track을 먼저 만든다: 제품 목표와 Phase 1 범위에서 `docs/backlog/PHASE1.md` 후보를 도출한다.
3. Harness track을 분리한다: AI workflow, command/rule, prompt, scaffold 개선은 `docs/backlog/HARNESS.md`에 둔다.
4. Core 문서를 채운다: `STATUS.md`, `PLAN-SUMMARY.md`, `PLAN.md`, `AGENT-WORKFLOW.md`.
5. Work 파일 필요 여부를 판단한다: 작은 L1 Product track 작업은 Quick Mode, 큰 작업은 `docs/works/{category}/`에 Work 파일을 만든다.
6. Example pack을 검토한다: 선택한 stack-specific pack이 실제 프로젝트 path, role, package placeholder와 맞는지 확인한다.

## Required Setup Items

| 범주 | 채울 위치 | 확인할 내용 |
| --- | --- | --- |
| Project identity | `docs/BOOTSTRAP.md`, `docs/PLAN-SUMMARY.md`, `README.md` | 이름, 목적, 사용자, production 성격, 공개/배포 방식 |
| Current state | `docs/STATUS.md` | Phase, Active Work, OQ, Next Actions |
| Product backlog | `docs/backlog/PHASE1.md` | P1-001~ 후보, Done Criteria, Verification, Preconditions |
| Harness backlog | `docs/backlog/HARNESS.md` | HRN-001~ 후보, command/rule/prompt/scaffold 개선 항목 |
| Work tracking | `docs/works/phase1/`, `docs/works/harness/` | 큰 작업의 Work 파일과 index |
| Workflow constants | `docs/AGENT-WORKFLOW.md` | Project Constants, Verification Defaults |
| Example pack | `.claude/rules/`, `.cursor/rules/`, `prompts/` | stack-specific glob, role naming, placeholder, optional 여부 |

## Harness Adjustment Proposals

첫 세션의 AI는 Product backlog만 만들지 않고, 도입 프로젝트의 identity에 맞춰 하네스 자체에서 바꿔야 할 항목도 제안해야 한다.
아래 항목은 즉시 수정하지 않고 Harness backlog 후보 또는 state-change proposal로 분리한다.

- README, `PLAN-SUMMARY.md`, `AGENTS.md`, `CLAUDE.md`의 project identity 문구.
- `docs/AGENT-WORKFLOW.md`의 Project Constants와 Verification Defaults.
- `.claude/rules/`, `.cursor/rules/`의 role 이름, glob, alwaysApply 조건.
- `prompts/`의 description, placeholder, stack-specific example pack 포함 여부.
- `docs/backlog/HARNESS.md`에 등록할 HRN-001~ 후보와 Work 파일 필요 여부.

## Example Pack Review

`generic` profile은 framework를 가정하지 않는다.
`spring-boot` 같은 example pack을 포함했다면 다음 항목을 첫 세션에서 확인한다.

- Rule glob이 실제 source path와 맞는가.
- Role 파일명이 실제 역할과 맞는가. backend 전용이 아니면 `role-backend` 같은 이름을 쓰지 않는다.
- Prompt가 특정 organization, package, service naming에 고정되어 있지 않은가.
- README/manual에서 해당 pack이 optional example임을 알 수 있는가.
- 필요 없는 pack은 제거하거나 Harness backlog에 정리 작업으로 등록했는가.

## First Prompt

```text
docs/BEHAVIOR-PRINCIPLES.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md, docs/BOOTSTRAP.md를 읽어줘.

이 프로젝트를 scaffold 직후 부팅하려고 해.
프로젝트 identity, production 성격, Product track backlog, Harness track 정비 항목,
example pack 정비 필요 여부를 분리해서 제안해줘.

파일 수정은 내 승인 전까지 하지 마.
```
