---
id: CHORE-20260622-003
priority: P2
status: Archived
risk: L2
scope: optional cross-agent review relay workflow를 canonical 절차와 tool adapter로 추가한다. 기본 프로세스 gate로 강제하지 않고, driver/reviewer 역할·round packet·findings·driver response·user decision gate를 표준화한다.
appetite: 0.5d
planned_start: 2026-06-22
planned_end: 2026-06-22
actual_end: 2026-06-22
related_dr: []
related_troubleshooting: []
related_work: []
---

# CHORE-20260622-003: Optional Cross-Agent Review Workflow

## Top Summary

사용자는 cross-agent review(author/driver + red-team reviewer) 패턴을 선호하지만, 이를 repo 기본 프로세스나 hard gate로 녹이면 다른 사용자·다른 agent 구성에 과도한 ceremony를 강제할 수 있다.

이번 Work는 그 패턴을 **optional workflow skill**로 만든다. 목적은 agent orchestration 자동화가 아니라, 사람이 다른 agent에게 전달해야 하는 review packet과 reviewer 응답 ingest, driver response, user decision gate를 표준화해 relay 비용을 줄이는 것이다.

핵심 경계:

- cross-agent review는 선택적 workflow다. 기본 gate가 아니다.
- 특정 tool 고정 역할을 두지 않는다. `driver`, `reviewer`, `specialist`, `arbiter/user` 역할로 표현한다.
- reviewer는 red-team 기본 태도를 가진다. 문장 정합성뿐 아니라 방향, scope, evidence, hidden cost, reversal cost를 의심한다.
- driver는 reviewer 의견을 자동 수용하지 않고 `accept / revise / defend / needs-user`로 응답한다.
- state change, scope expansion, commit/PR/merge, Work Done은 기존 Approval Matrix를 우회하지 않는다.

## Collaboration Workflow

| Role | Agent | Responsibility |
| --- | --- | --- |
| Driver | Codex | Work 파일, canonical workflow, adapter, routing, validation, Claude review relay packet 작성 |
| Reviewer | Claude | red-team reviewer. 선택적 workflow가 hard gate처럼 굳는 위험, 다자/다라운드 모델, user decision gate, cascade 누락을 의심 |
| Owner | User | 방향 승인, 구현 승인, 최종 승인, `/work-close`, commit, PR, merge 승인 |

Cross-agent 라운드와 합의는 아래 `Cross-Agent Review And Discussion`에 누적한다.

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/maintainer/SOURCE-REPO-OPERATIONS.md` | 작업 lifecycle review row | cross-agent review가 optional이며 tool-neutral이어야 한다는 기존 기준 |
| 2 | `docs/retrospectives/harness-v1-2-readiness-retrospective-20260615.md` | §2.4 | cross-agent review의 품질 효과와 external validation 한계 |
| 3 | `docs/HARNESS-PROTOCOL.md` | Work File Rules, Trigger/Cascade, Tool Surface Cascade Matrix | L2 workflow surface와 cascade 기준 |
| 4 | `skills/workflow/README.md` | Commands table | 새 canonical workflow와 adapter index 반영 기준 |
| 5 | `skills/workflow/work-plan.md` | Approval/plan gate | user decision gate와 Approval Matrix 경계 재사용 |
| 6 | `.cursor/rules/workflow.mdc` + `scripts/templates/default/.cursor/rules/workflow.mdc` | Step 0 table | Cursor routing과 default-template parity 동기화 |
| 7 | `scripts/create-harness.sh` | canonical workflow / command / Codex skill copy loops | 새 workflow scaffold 포함 여부 확인 |

## Scope

### Slice A — Canonical Procedure

- `skills/workflow/cross-review.md`를 추가한다.
- `start / request / ingest / respond / user decision gate / close-or-next-round` 흐름을 정의한다.
- role defaults와 reviewer red-team posture, driver response posture를 포함한다.

### Slice B — Tool Adapters

- `.claude/commands/cross-review.md`를 추가한다.
- `.agents/skills/workflow-cross-review/SKILL.md`를 추가한다.
- `.cursor/rules/workflow.mdc`에 optional cross-review routing row를 추가한다.
- `scripts/templates/default/.cursor/rules/workflow.mdc`도 parity 기준에 맞춰 갱신한다.

### Slice C — User-Facing Indexes

- `skills/workflow/README.md` command index를 갱신한다.
- `docs/HARNESS-QUICK-REFERENCE.md`와 `README.md` command map에 optional cross-review를 추가한다.

### Slice D — Validation And Review Relay

- scaffold copy loop가 새 파일을 자동 포함하는지 dry-run으로 확인한다.
- Claude reviewer에게 전달할 R0 result review packet을 생성한다.

### Slice E — User Manual

- `docs/user/CROSS-REVIEW-MANUAL.md`를 추가해 사용자에게 기본 메커니즘, 사용 상황, 구체적 요청 방식, 절차를 설명한다.
- README, Quick Reference, scaffold copy surface에서 manual 발견 경로를 정렬한다.

## Non-Goals

- cross-agent review를 기본 workflow hard gate로 만들지 않는다.
- 특정 agent 조합(Codex/Claude)을 repo 규칙으로 고정하지 않는다.
- sub-agent spawn/automation engine을 만들지 않는다.
- reviewer 응답을 자동으로 파일에 적용하는 parser나 script를 만들지 않는다.
- Approval Matrix, `/work-plan`, `/work-close`, commit/PR gate를 대체하지 않는다.

## Files

| File | Plan |
| --- | --- |
| `skills/workflow/cross-review.md` | 신규 canonical procedure |
| `.claude/commands/cross-review.md` | Claude adapter |
| `.agents/skills/workflow-cross-review/SKILL.md` | Codex/Antigravity adapter |
| `.cursor/rules/workflow.mdc` | Cursor routing row 추가 |
| `scripts/templates/default/.cursor/rules/workflow.mdc` | default template parity row 추가 |
| `skills/workflow/README.md` | command index row 추가 |
| `docs/HARNESS-QUICK-REFERENCE.md` | command map row 추가 |
| `README.md` | command map row 추가 |
| `docs/user/README.md` | 사용자 guide index 추가 |
| `docs/user/CROSS-REVIEW-MANUAL.md` | cross-review 사용자 manual 추가 |
| `scripts/create-harness.sh` | default scaffold에 user manual 포함 |
| `docs/STATUS.md` | Active Work pointer 추가 |
| `docs/works/harness/README.md` | Active Work row 추가 |

## Done Criteria

- [x] canonical cross-review procedure가 optional relay protocol임을 명확히 한다.
- [x] driver/reviewer/specialist/arbiter 역할과 기본 태도가 정의된다.
- [x] reviewer red-team posture가 방향·scope·evidence·hidden cost·reversal cost까지 의심하도록 정의된다.
- [x] driver response가 `accept / revise / defend / needs-user`로 표준화된다.
- [x] user decision gate가 Approval Matrix를 우회하지 않도록 정의된다.
- [x] Claude/Codex/Antigravity/Cursor adapter/routing surface가 정렬된다.
- [x] scaffold dry-run에서 새 workflow 파일들이 포함된다.
- [x] Claude R0 result review packet이 준비된다.
- [x] 사용자 manual이 추가되고 README/Quick Reference/scaffold surface에서 발견 가능하다.

## Verification

```bash
git diff --check
bash scripts/tests/run-harness-checks.sh --tier0
bash scripts/tests/check-default-template-parity.sh
bash scripts/create-harness.sh --dry-run cross-review /tmp/awh-cross-review
```

수동 확인:

- `scripts/create-harness.sh` glob/adapt 루프가 신규 canonical, Claude command, Codex skill을 포함하는지 확인.
- `.cursor/rules/workflow.mdc`와 default template parity가 의도대로 유지되는지 확인.
- `docs/maintainer/SOURCE-REPO-OPERATIONS.md`의 optional/tool-neutral review 원칙과 충돌하지 않는지 확인.

## Checkpoints

| ID | Checkpoint | Status |
| --- | --- | --- |
| C1 | Work tracking + Active pointer 생성 | Done |
| C2 | canonical + adapter + routing 작성 | Done |
| C3 | command map/index 갱신 | Done |
| C4 | validation 실행 | Done |
| C5 | Claude R0 result review packet 작성 | Done |
| C6 | 사용자 manual 추가 및 scaffold 포함 확인 | Done |

## Cross-Agent Review And Discussion

### R0 Request To Reviewer

````markdown
Claude에게:

이 repo(ai-workflow-harness)의 `CHORE-20260622-003 Optional Cross-Agent Review Workflow` 구현 결과를 red-team reviewer로 검토해줘.

## 대상

작업 브랜치: `feature/chore-20260622-003-workflow-cross-review`

주요 변경 파일:
- `skills/workflow/cross-review.md`
- `.claude/commands/cross-review.md`
- `.agents/skills/workflow-cross-review/SKILL.md`
- `.cursor/rules/workflow.mdc`
- `scripts/templates/default/.cursor/rules/workflow.mdc`
- `skills/workflow/README.md`
- `docs/HARNESS-QUICK-REFERENCE.md`
- `README.md`
- `docs/works/harness/CHORE-20260622-003-workflow-cross-review.md`
- `docs/works/harness/README.md`
- `docs/STATUS.md`

## 맥락

사용자는 cross-agent review(author/driver + red-team reviewer)를 선호하지만, 이 repo의 기본 프로세스나 hard gate로 강제하고 싶지는 않다고 했다. 그래서 이번 구현은 cross-agent review를 optional workflow로 추가하는 방향이다.

목표는 agent orchestration 자동화가 아니라, 사람이 다른 agent에게 매번 전달해야 하는 review packet과 reviewer 응답 ingest, driver response, user decision gate를 표준화해 relay 비용을 줄이는 것이다.

## 구현 의도

- `/cross-review`는 optional workflow다. 기본 workflow gate가 아니다.
- agent 이름을 고정하지 않고 `driver`, `reviewer`, `specialist`, `arbiter/user` 역할로 모델링한다.
- reviewer 기본 태도는 red-team이다. 문장 정합성뿐 아니라 방향 자체, scope, evidence, hidden cost, reversal cost를 의심한다.
- driver는 reviewer 의견을 자동 수용하지 않고 `accept / revise / defend / needs-user`로 응답한다.
- user decision gate가 필요한 경우 진행을 멈추고 사용자 선택을 요구한다.
- Approval Matrix, `/work-plan`, `/work-close`, commit/PR gate를 대체하지 않는다.

## 검증 결과

```bash
git diff --check
bash scripts/tests/check-default-template-parity.sh
bash scripts/tests/run-harness-checks.sh --tier0
bash scripts/create-harness.sh --dry-run cross-review /tmp/awh-cross-review
```

결과:
- `git diff --check`: PASS
- default template parity: PASS
- tier0: PASS
- scaffold dry-run: PASS. `skills/workflow/cross-review.md`, `.claude/commands/cross-review.md`, `.agents/skills/workflow-cross-review/SKILL.md`가 dry-run output에 포함됨.

## 반드시 검토할 축

1. optional workflow 경계가 충분히 선명한가? 혹시 사실상 hard gate처럼 읽히는 문구가 남아 있나?
2. `driver/reviewer/specialist/arbiter` 역할 모델이 2자뿐 아니라 3자 이상 review에도 버틸 수 있나?
3. reviewer red-team posture가 충분히 강한가? "내용 정합성"뿐 아니라 방향 자체를 의심하도록 설계됐나?
4. driver response(`accept / revise / defend / needs-user`)와 user decision gate가 실제로 중간 승인/쟁점 충돌을 처리하기 충분한가?
5. 기존 `docs/maintainer/SOURCE-REPO-OPERATIONS.md`의 "single-agent 또는 cross-agent 모두 가능, 도구 고정 금지" 원칙과 충돌하지 않는가?
6. Cursor routing/default template parity, scaffold inclusion, command map 반영 중 빠진 cascade가 있나?
7. 과설계나 과한 ceremony가 있나? 있다면 어떤 문구/단계를 줄여야 하나?

## 출력 형식

- Verdict: approve / conditional / request-changes / reject
- Must-fix findings
- Nice-to-have findings
- Residual risk
- Suggested wording, if needed

## 제약

- 파일 수정 금지. 검토 의견만 줘.
- 큰 방향("optional workflow로 둔다", "기본 gate로 강제하지 않는다", "특정 tool 고정 역할 금지")은 재론하지 말고, 구현 품질과 잔여 리스크만 검토해줘.
- 리뷰어는 red-team 관점으로 봐줘. 특히 이 workflow가 나중에 몰래 mandatory process처럼 굳을 위험을 강하게 의심해줘.
````

### R0 Reviewer Findings

Verdict: conditional

| ID | Severity | Finding | Recommendation |
| --- | --- | --- | --- |
| R0-F1 | P1 | Claude adapter는 `disable-model-invocation: true`라 명시 호출만 되지만, Codex/AG skill trigger가 넓어 "red-team으로 봐줘" 같은 일상 표현만으로 relay ceremony가 자동 기동될 수 있다. Optional workflow가 도구별로 사실상 auto-on이 되는 위험. | Codex SKILL body의 trigger를 `/cross-review` 명시 호출 또는 cross-agent review relay 명시 요청으로 좁히고, 단순 review/red-team 언급만으로는 자동 기동하지 않는다고 명시한다. |
| R0-F2 | P3 | 다수 reviewer 시 `Rn-F1` finding ID가 충돌할 수 있다. | finding ID에 reviewer key를 넣는다. 예: `R0-RevA-F1`. |
| R0-F3 | P3 | 2자·1라운드 간단 review에는 packet/findings/response/round log/consensus log 템플릿이 과해 보일 수 있다. | 최소 사용 경로를 명시한다. |
| R0-F4 | P3 | `SOURCE-REPO-OPERATIONS.md`의 `Cross-Agent Review`와 canonical/Work의 `Cross-Agent Review And Discussion` 명칭이 미세하게 다르다. | 두 표현이 같은 대상임을 canonical에 명시한다. |

### R0 Driver Response

| Finding | Decision | Response | Follow-up |
| --- | --- | --- | --- |
| R0-F1 | accept | `.agents/skills/workflow-cross-review/SKILL.md` trigger를 명시 호출/명시 relay 요청으로 축소하고, review/red-team 언급만으로 자동 기동하지 않는다고 명시했다. | 검증 재실행 |
| R0-F2 | accept | canonical `Reviewer Findings` 예시를 `Rn-RevA-F1`로 바꾸고, 다수 reviewer 시 reviewer key 포함 규칙을 추가했다. | 검증 재실행 |
| R0-F3 | accept | canonical Procedure 앞에 `Minimal Path`를 추가해 2자 1라운드는 relay packet/findings/driver response만으로 충분하다고 명시했다. | 검증 재실행 |
| R0-F4 | accept | canonical Boundary에 `Cross-Agent Review And Discussion`이 `SOURCE-REPO-OPERATIONS.md`의 `Cross-Agent Review` 관례와 같은 대상이라고 명시했다. | 검증 재실행 |

### R1 Reviewer Findings

Verdict: approve

| ID | Severity | Finding | Recommendation |
| --- | --- | --- | --- |
| R1-RevA-F1 | info | R0 must-fix가 정확히 닫혔다. `.agents/skills/workflow-cross-review/SKILL.md`의 trigger narrowing으로 Claude `disable-model-invocation: true`와 대칭이 확보됐고, 자동 기동 경로가 차단됐다. | 추가 조치 없음 |
| R1-RevA-F2 | info | R0 nice-to-have 3건도 반영됐다. multi-reviewer finding ID, `Minimal Path`, section naming equivalence가 canonical에 들어갔다. | 추가 조치 없음 |
| R1-RevA-F3 | P3 | Codex/AG intent routing과 Claude `disable-model-invocation`의 도구별 invocation 억제 비대칭은 모든 workflow skill의 공통 구조다. 이 Work의 blocker는 아니며 cross-review trigger narrowing으로 적절히 대증 처리됐다. | 별도 backlog 후보로 둔다 |

### R1 Driver Response

| Finding | Decision | Response | Follow-up |
| --- | --- | --- | --- |
| R1-RevA-F1 | accept | R0-F1 closure를 확인했다. | 없음 |
| R1-RevA-F2 | accept | R0-F2~F4 closure를 확인했다. | 없음 |
| R1-RevA-F3 | revise | 공통 invocation 억제 비대칭은 이 Work 범위 밖이다. 현재 Work에는 residual risk로만 기록하고, 별도 backlog 후보로 남긴다. | work-close 시 backlog 등록 여부 판단 |

### R2 Reviewer Findings

Verdict: approve

| ID | Severity | Finding | Recommendation |
| --- | --- | --- | --- |
| R2-RevA-F1 | P3 | 매뉴얼이 Basic Flow, role, driver response를 canonical과 일부 재서술하므로 향후 canonical 변경 시 drift 위험이 있다. | 매뉴얼 상단에 절차 SSoT는 `skills/workflow/cross-review.md`라는 pointer를 추가한다. |
| R2-RevA-F2 | P3 | 매뉴얼 예시에 Codex/Claude 실명이 등장해 scaffold target 사용자가 도구 고정으로 오해할 수 있다. | 예시일 뿐 도구 고정이 아니라는 문장을 추가한다. |

### R2 Driver Response

| Finding | Decision | Response | Follow-up |
| --- | --- | --- | --- |
| R2-RevA-F1 | accept | `docs/user/CROSS-REVIEW-MANUAL.md` 상단에 canonical SSoT pointer를 추가했다. | 검증 재실행 |
| R2-RevA-F2 | accept | Multi-round 예시 앞에 Codex/Claude는 예시일 뿐 특정 tool을 역할로 고정하지 않는다고 명시했다. | 검증 재실행 |

### Round Log

| Round | Driver | Reviewer(s) | Objective | Verdict | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Codex | Claude | result review | conditional | addressed |
| R1 | Codex | Claude | R0 follow-up | approve | closed |
| R2 | Codex | Claude | manual + closeout review | approve | addressed |

### Consensus Log

| Topic | Status | Notes |
| --- | --- | --- |
| Optional workflow boundary | agreed | F1 trigger 축소로 도구별 auto-on 위험을 줄임 |
| Multi-reviewer finding IDs | agreed | reviewer key 포함 |
| Lightweight usage | agreed | Minimal Path 추가 |
| Section naming | agreed | `Cross-Agent Review` / `Cross-Agent Review And Discussion` 동등 대상 명시 |
| Tool invocation suppression asymmetry | deferred | cross-review에서는 trigger narrowing으로 처리. workflow skill 전반의 공통 구조는 별도 backlog 후보 |
| User manual SSoT boundary | agreed | manual은 사용 맥락 중심, 절차 SSoT는 canonical workflow |
| Tool role examples | agreed | Codex/Claude 예시는 역할 예시일 뿐 tool 고정 아님 |

## Discovery

- 2026-06-22: 사용자 승인으로 `CHORE-20260622-003` 착수. Branch Isolation Check 결과 `develop + source-gitflow`라 `feature/chore-20260622-003-workflow-cross-review` 브랜치로 분리 후 진행.
- 2026-06-22: `skills/workflow/cross-review.md`, Claude adapter, Codex/Antigravity adapter, Cursor routing, default Cursor template, command indexes를 추가했다. `scripts/create-harness.sh`는 glob/adapt loop로 신규 canonical/command/skill을 자동 포함하므로 수정 불필요.
- 2026-06-22: Validation PASS — `git diff --check`, `bash scripts/tests/check-default-template-parity.sh`, `bash scripts/tests/run-harness-checks.sh --tier0`, `bash scripts/create-harness.sh --dry-run cross-review /tmp/awh-cross-review`.
- 2026-06-22: Claude R0 conditional review 반영. F1 trigger narrowing, multi-reviewer finding ID, Minimal Path, section naming equivalence를 반영했다.
- 2026-06-22: R0 반영 후 Validation PASS — `git diff --check`, `bash scripts/tests/check-default-template-parity.sh`, `bash scripts/tests/run-harness-checks.sh --tier0`, `bash scripts/create-harness.sh --dry-run cross-review /tmp/awh-cross-review`.
- 2026-06-22: Claude R1 follow-up verdict `approve`. Remaining blocker 없음. Residual risk로 workflow skill 전반의 invocation suppression asymmetry를 별도 후보로 기록했다.
- 2026-06-22: 사용자 요청으로 `docs/user/CROSS-REVIEW-MANUAL.md`와 `docs/user/README.md`를 추가했다. README/Quick Reference/source scaffold copy surface를 함께 갱신했다.
- 2026-06-22: 사용자 manual 추가 후 Validation PASS — `git diff --check`, `bash scripts/tests/check-default-template-parity.sh`, `bash scripts/tests/run-harness-checks.sh --tier0`, `bash scripts/create-harness.sh --dry-run cross-review /tmp/awh-cross-review`. Dry-run output에 `docs/user/README.md`, `docs/user/CROSS-REVIEW-MANUAL.md` 포함 확인.
- 2026-06-22: Work Done 처리 후 Validation PASS — `git diff --check`, `bash scripts/tests/check-default-template-parity.sh`, `bash scripts/tests/run-harness-checks.sh --tier0`, `bash scripts/create-harness.sh --dry-run cross-review /tmp/awh-cross-review`.
- 2026-06-22: Claude R2 manual + closeout review verdict `approve`. Nice-to-have로 manual SSoT pointer와 tool role example caveat를 반영했다.
- 2026-06-22: R2 반영 후 Validation PASS — `git diff --check`, `bash scripts/tests/check-default-template-parity.sh`, `bash scripts/tests/run-harness-checks.sh --tier0`, `bash scripts/create-harness.sh --dry-run cross-review /tmp/awh-cross-review`.
- Needs-Triage: workflow skill 전반의 tool invocation suppression asymmetry — cross-review는 trigger narrowing으로 닫았지만, Codex/AG intent routing과 Claude `disable-model-invocation` 비대칭은 전체 workflow skill 공통 구조라 다음 후보 선별 시 별도 검토 가치가 있다.
- 2026-06-23: Archived. 위 Needs-Triage 항목은 `docs/backlog/HARNESS.md`에 lean P3 후보("Workflow skill tool invocation suppression asymmetry 검토")로 등록 후 archive 처리. brief `rule-asset-generalization-strategy-20260622.md`의 option-pack 작업(축 A P1 / 축 B P2)과는 별개 surface임을 확인.
