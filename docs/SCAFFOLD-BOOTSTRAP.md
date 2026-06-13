# Scaffold Bootstrap Guide

이 문서는 `scripts/create-harness.sh`로 새 프로젝트 또는 기존 프로젝트에 하네스를 심은 직후,
빈 `STATUS.md`, `PLAN-SUMMARY.md`, backlog, Work index를 프로젝트 identity에 맞게 부팅하는 기준이다.

Scaffold된 프로젝트에는 project-local checklist인 `docs/BOOTSTRAP.md`가 생성된다.
이 source repository에서는 `docs/SCAFFOLD-BOOTSTRAP.md`가 그 산출물의 설계 기준이다.
Daily `/session-start`는 `docs/BOOTSTRAP.md` 존재 여부를 확인하지 않는다.
Scaffold 직후 generated `docs/STATUS.md` Next Actions가 bootstrap/onboarding을 가리킬 때만 이 checklist를 후속으로 읽는다.

## Boot Sequence

1. git repository 상태를 확인한다: `git status` 또는 `ls .git/`으로 현재 디렉토리가 git repository인지 확인한다. `git status`가 not a git repository 메시지로 실패하면 no-git bootstrap 상태로 보고, 사용자 승인 후 `git init`과 initial commit 절차를 진행한다. git repository가 없는 동안 commit/PR/branch workflow는 `Not Applicable`로 처리한다.
2. Project identity를 정한다: 이름, 한 줄 설명, 주요 사용자, production 성격, 공개/배포 방식.
3. Project Initialization baseline을 확정한다 (code development가 필요한 프로젝트만 해당): `docs/PLAN-SUMMARY.md` Implementation Baseline 표의 Runtime/Framework/Build/package 등을 결정하고 Readiness를 업데이트한다. code development가 없는 프로젝트는 Not Applicable로 처리한다. baseline이 비어 있으면 기능 후보를 만들지 않고 Project Initialization을 첫 후보로 제안한다.
4. Product track을 만든다: 제품 목표와 초기 범위에서 `docs/backlog/PRODUCT.md` 후보를 도출한다. 3단계 baseline이 완료된 뒤에만 feature candidate을 등록한다.
5. Harness track을 분리한다: AI workflow, command/rule, prompt, scaffold 개선은 `docs/backlog/HARNESS.md`에 둔다.
6. Core 문서를 채운다: `STATUS.md`, `PLAN-SUMMARY.md`, `PLAN.md`, `AGENT-WORKFLOW.md`.
7. Work 파일 필요 여부를 판단한다: 작은 L1 Product track 작업은 Quick Mode, 큰 작업은 `docs/works/{category}/`에 Work 파일을 만든다.
8. Example pack을 검토한다: 선택한 stack-specific pack이 실제 프로젝트 path, role, package placeholder와 맞는지 확인한다.
9. Bootstrap이 끝나면 `docs/STATUS.md` Next Actions에서 scaffold bootstrap/onboarding 항목을 제거하거나 다음 실제 작업으로 교체한다.

## Required Setup Items

| 범주 | 채울 위치 | 확인할 내용 |
| --- | --- | --- |
| Git repository | (shell) | git repo 있음/없음 확인, 없으면 `git init` 여부·default branch·initial commit 결정 |
| Project identity | `docs/BOOTSTRAP.md`, `docs/PLAN-SUMMARY.md`, `README.md` | 이름, 목적, 사용자, production 성격, 공개/배포 방식 |
| Implementation Baseline | `docs/PLAN-SUMMARY.md` Implementation Baseline | Runtime/Framework/Build/package/module/Data storage/Profiles 결정 및 Readiness 업데이트 (code development 프로젝트만) |
| Current state | `docs/STATUS.md` | Phase, Active Work, OQ, Next Actions |
| Product backlog | `docs/backlog/PRODUCT.md` | baseline 완료 후 초기 작업 후보, Done Criteria, Verification, Preconditions (Work ID는 /work-plan 착수 시 확정) |
| Harness backlog | `docs/backlog/HARNESS.md` | harness 개선 후보, command/rule/prompt/scaffold 개선 항목 (Work ID는 /work-plan 착수 시 확정) |
| Work tracking | `docs/works/product/`, `docs/works/harness/` | 큰 작업의 Work 파일과 index |
| Workflow constants | `docs/AGENT-WORKFLOW.md` | Project Constants, Verification Defaults |
| Example pack | `.claude/rules/`, `.cursor/rules/` | stack-specific glob, role naming, optional 여부 |

## Harness Adjustment Proposals

첫 세션의 AI는 Product backlog만 만들지 않고, 도입 프로젝트의 identity에 맞춰 하네스 자체에서 바꿔야 할 항목도 제안해야 한다.
아래 항목은 즉시 수정하지 않고 Harness backlog 후보 또는 state-change proposal로 분리한다.

- README, `PLAN-SUMMARY.md`, `AGENTS.md`, `CLAUDE.md`의 project identity 문구.
- `docs/AGENT-WORKFLOW.md`의 Project Constants와 Verification Defaults.
- `.claude/rules/`, `.cursor/rules/`의 role 이름, glob, alwaysApply 조건.
- `prompts/`의 session-start fallback description과 project naming.
- `docs/backlog/HARNESS.md`에 등록할 harness 개선 후보와 Work 파일 필요 여부 (Work ID는 /work-plan 착수 시 확정).

## Example Pack Review

`generic` profile은 framework를 가정하지 않는다.
`spring-boot` 같은 example pack을 포함했다면 다음 항목을 첫 세션에서 확인한다.

- Rule glob이 실제 source path와 맞는가.
- Role 파일명이 실제 역할과 맞는가. backend 전용이 아니면 `role-backend` 같은 이름을 쓰지 않는다.
- Prompt가 특정 organization, package, service naming에 고정되어 있지 않은가.
- README/manual에서 해당 pack이 optional example임을 알 수 있는가.
- 필요 없는 pack은 제거하거나 Harness backlog에 정리 작업으로 등록했는가.

## Completion Rule

Bootstrap onboarding은 `docs/STATUS.md` Next Actions의 pointer로만 재진입된다.
따라서 checklist를 채우고 Product/Harness backlog 후보를 만든 뒤에는 반드시 `docs/STATUS.md` Next Actions에서 scaffold bootstrap/onboarding 항목을 제거하거나 다음 실제 작업으로 교체한다.
이 항목이 남아 있으면 daily `/session-start`가 매 세션 bootstrap 후속 작업을 계속 제안한다.

## First Session Prompt

`docs/STATUS.md` Next Actions가 scaffold bootstrap/onboarding을 가리킬 때 아래 prompt를 사용한다.

```text
docs/BEHAVIOR-PRINCIPLES.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md, docs/BOOTSTRAP.md를 읽어줘.

이 프로젝트를 scaffold 직후 부팅하려고 해.
다음 순서로 제안해줘:

1. 프로젝트 identity와 production 성격 확인
2. Product Definition: 제품 목표, 주요 사용자, 성공 기준
3. Project Initialization: PLAN-SUMMARY.md Implementation Baseline 결정 (코드 개발 프로젝트만)
4. Implementation Baseline이 비어 있으면 feature candidate 대신 Project Initialization을 첫 후보로 제안
5. Harness track 정비 항목, example pack 정비 필요 여부

파일 수정은 내 승인 전까지 하지 마.
```
