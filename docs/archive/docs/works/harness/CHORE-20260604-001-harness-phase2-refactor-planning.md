---
id: CHORE-20260604-001
priority: P1
status: Archived
risk: High
scope: ai-workflow-harness Phase 2 진입을 위한 전체 workflow, process gate, docs IA, scaffold 구조, AI tool surface, command/skill/settings/test/release flow의 대대적 리팩토링 검토와 실행 계획 수립
appetite: 3d
planned_start: 2026-06-04
planned_end: 2026-06-07
actual_end: 2026-06-04
related_dr: [DR-007, DR-013, DR-017, DR-019, DR-020]
related_troubleshooting: []
related_work: [CHORE-20260605-001, CHORE-20260605-002, CHORE-20260605-003, CHORE-20260605-004, CHORE-20260605-005, CHORE-20260605-006, CHORE-20260606-001, CHORE-20260606-002, CHORE-20260606-003, CHORE-20260606-004, CHORE-20260606-005]
---

# CHORE-20260604-001: Harness Phase 2 Refactor Planning

## Executive Summary

`ai-workflow-harness`는 v1.0.8 기준 public baseline과 maintenance 정리를 마쳤다.
이제 다음 단계는 기능 추가가 아니라, 실제 adoption 경험에서 드러난 구조적 마찰을 바탕으로
하네스 자체를 Phase 2로 재정의하는 것이다.

이번 Work의 목적은 바로 파일을 이동하거나 command를 고치는 것이 아니다.
전체 workflow, 발생하는 process, gate, 문서 관계, scaffold 산출물, AI 도구별 실행 표면,
settings/hook/CI/test/release flow를 한 번에 펼쳐 놓고, 효율적인 것과 제거할 것,
보강할 것, 대담하게 바꿀 것을 판단하는 planning Work다.

이 Work는 Codex와 Claude가 함께 검토한다.
하단의 `Cross-Agent Review And Discussion` 섹션에 상호 리뷰, 반박, 합의, 후속 PR 분해안을 기록한다.

## Why This Work Exists

### 1. v1.0.x는 public baseline을 만들었고, 이제 adoption feedback이 들어왔다

v1.0.x까지의 핵심 성과는 다음과 같다.

- source repository를 public-ready 상태로 정리했다.
- `STATUS.md`, Work file, backlog, DR, Approval Matrix, `/close`/`/done` 분리 등 stateful workflow를 안정화했다.
- Claude Code, Codex, Cursor 표면을 대체로 정렬했다.
- `scripts/create-harness.sh`로 generic / source-gitflow scaffold를 생성할 수 있게 했다.
- v1.0.8에서 maintenance 변경과 archive state까지 정리했다.

하지만 ai-deck-compiler 적용 과정에서 하네스가 실제 downstream repo에 들어갔을 때의 마찰이 드러났다.
이 마찰은 단순한 문구 오류라기보다, source repo와 scaffold target repo의 책임 경계가 아직 명확하지 않다는 신호다.

### 2. Source repo와 scaffold target repo가 섞인다

현재 scaffold는 target repo에 운영에 필요한 최소 runtime surface만 주는 것이 아니라,
source maintainer 성격의 문서와 넓은 prompt library까지 함께 복사한다.

대표적인 의심 지점:

- `docs/HARNESS-ARCHITECTURE.md`, `docs/HARNESS-MAINTAINER-GUIDE.md`, `docs/WORKFLOW-MANUAL.md`가 target repo에 기본 복사된다.
- prompt library가 session-start 3종 외에도 다수 복사된다.
- target repo가 하네스를 "사용"하는 저장소인지, 하네스를 "개발"하는 저장소인지 AI가 혼동할 수 있다.
- source repo 전용 release / git / public baseline 정책이 target repo에서 과한 gate로 느껴질 수 있다.

Phase 2에서는 target repo에 필요한 것을 `runtime pack`, `onboarding pack`, `optional reference pack`, `source-only maintainer pack`으로 나누는 방향을 검토한다.

### 3. PLAN.md가 살아있는 문서로 작동하지 않는다

`PLAN.md`는 WHY와 장기 방향의 SSoT가 되어야 한다.
하지만 실제 workflow에서는 Work가 진행되어도 그 결과가 `PLAN.md` 또는 phase plan으로 역류하는 trigger가 약하다.

현재 문제 가설:

- bootstrap에서는 `PLAN.md` 작성이 "이전 예정"으로 밀릴 수 있다.
- feature candidate은 `PLAN-SUMMARY.md` Implementation Baseline만 보고도 시작될 수 있다.
- Work Done 후 `STATUS.md`와 Work file은 갱신되지만, `PLAN.md` 업데이트 필요 여부는 강한 gate가 아니다.
- phase와 plan의 관계가 애매하다. phase는 backlog grouping인지, milestone인지, planning horizon인지 분명하지 않다.

Phase 2에서는 `PLAN.md`를 "초기 작성 문서"가 아니라 다음 조건에서 반드시 검토되는 living document로 재정의한다.

- scaffold bootstrap 완료
- phase 시작 / phase 종료
- architecture boundary 변경
- workflow/gate/scaffold 정책 변경
- Work 결과가 product direction 또는 harness direction을 바꿀 때

### 4. Gate가 많아졌지만, gate 간 목적 구분은 더 선명해야 한다

현재 하네스는 manual-first safety를 위해 여러 gate를 가진다.

- Scope approval
- State-change approval
- Commit approval
- Branch isolation
- Public Clean Baseline Gate
- Bootstrap gate
- PLAN force-load condition
- `/close` Done Criteria gate
- `/done` session summary / finalization gate
- CI / hook / validation gate

gate 자체가 문제는 아니다.
문제는 어떤 gate가 source repo 전용인지, target repo 기본값인지, project-specific override인지,
AI tool runtime에서 hard stop인지 warning인지가 아직 충분히 분리되어 있지 않다는 점이다.

Phase 2에서는 gate를 늘리는 것이 아니라, gate를 계층화한다.

| Layer | 목적 | 예시 |
| --- | --- | --- |
| Universal safety | 모든 repo에서 필요한 최소 안전장치 | scope before edit, validation before commit |
| Project runtime | target repo가 자기 일에 맞게 채우는 규칙 | test command, build command, branch policy |
| Source maintainer | ai-workflow-harness source repo 전용 | public release gate, source-gitflow, scaffold cascade |
| Optional strict mode | 팀 또는 repo가 명시 opt-in하는 강한 규칙 | protected files hard block, release checklist |

### 5. Phase2 refactor 전에 v1.0.8 release baseline을 먼저 정리했다

이 Work는 v1.0.8 release 이후 시작한다.
v1.0.8은 Phase2 착수 전 maintenance baseline이다.

반영된 전제:

- `main`과 `develop`은 `ai-workflow-v1.0.8` release commit으로 정렬됐다.
- archive pending Work 상태가 `Archived`로 정리됐다.
- LICENSE 저작권자, hook 보정, architecture rename, 문서 정비가 release 기준점에 포함됐다.

따라서 Phase 2는 미정리 maintenance diff 위에서 시작하지 않고, public release snapshot 이후의 별도 설계 작업으로 진행한다.

## Working Thesis

Phase 2의 핵심 방향은 다음과 같다.

1. **하네스 source repo는 generator / maintainer / policy source다.**
   source repo에는 전체 설명, maintainer guide, release policy, scaffold 구현, public open 절차가 남는다.

2. **scaffold target repo는 product work runtime만 받아야 한다.**
   target repo에는 AI가 실제 작업을 운영하는 데 필요한 entrypoint, workflow core, state/tracking skeleton, 최소 command/skill/settings만 둔다.

3. **default scaffold는 작고 중립적이어야 한다.**
   `source-gitflow`, public release gate, maintainer docs, generator scripts, 넓은 prompt library는 기본값이 아니라 opt-in 또는 source-only여야 한다.

4. **PLAN.md는 phase/work/decision의 상위 방향 계약이어야 한다.**
   Work가 끝날 때 PLAN 영향 여부를 묻고, phase 변경 시 PLAN과 backlog를 함께 정렬한다.

5. **AI tool별 차이는 entry/runtime에서만 흡수한다.**
   Claude command, Codex skill, Cursor rule은 같은 canonical workflow를 mirror하되,
   도구별 기능 차이를 무리하게 숨기지 않는다.

6. **gate는 "많이"가 아니라 "정확한 위치"가 중요하다.**
   동일한 경고가 여러 문서에 흩어져 반복되는 구조보다, canonical gate와 tool-specific enforcement 위치를 분리한다.

7. **public/open/release 절차는 별도 playbook 지식과 연결한다.**
   GitHub 공개, sensitive sweep, release note, repo settings, post-public verification은
   `/Users/kyungseo/dev-home/vibe/public-release-playbook`를 실제 정비 시 참고한다.
   이 repo 안으로 모든 open 절차를 복사하지 않고, 필요한 gate와 link만 둔다.

## Scope

이번 Work는 planning / review / decomposition이다.

### In Scope

- 전체 workflow map 재작성
- session start → plan → approval → execute → validate → close → done → commit → PR → release까지의 process flow 검토
- gate inventory와 계층화
- docs IA 검토: `docs/` 유지, `harness/` 분리, source-only / target-runtime 분류
- `PLAN.md`, `PLAN-SUMMARY.md`, `STATUS.md`, Work, backlog, DR, phase 관계 재정의
- scaffold 산출물 분류: default / optional / source-only / target-specific
- scaffold 후 onboarding process 재설계: bootstrap fill order, PLAN/STATUS/backlog 연결, cleanup/close 기준
- prompt 복사 정책 재검토
- `scripts/create-harness.sh` 기본 포함 여부와 generator 책임 경계 검토
- AI 도구별 surface 검토: `CLAUDE.md`, `AGENTS.md`, `.claude/commands`, `.agents/skills`, `.cursor/rules`, `.codex/hooks.json`
- settings/hook/CI/test validation 모델 검토
- Git/release/open flow에서 source repo 정책과 target repo 정책 분리
- user-facing 문서 대대적 개편 범위 설정: `README.md`를 시작점으로 `WORKFLOW-MANUAL.md`, `SCAFFOLD-ONBOARDING-GUIDE.md` 등 사용자 매뉴얼/가이드를 새 output contract에 맞게 전면 재작성하는 순서와 분리 단위
- Phase 2 implementation roadmap 작성
- DR-worthy decision 후보 식별

### Out Of Scope

- 이번 Work 안에서 대규모 파일 이동 실행
- command/skill/scaffold 실제 rewrite
- `public-release-playbook` 자체 수정
- target repo(ai-deck-compiler 등) 직접 수정
- release tag 추가 생성

## Review Axes

### Axis 1. End-To-End Workflow

질문:

- 사용자가 "작업 시작"을 말했을 때 AI가 어떤 순서로 무엇을 읽어야 하는가?
- `/start`, `/pick`, `/work`, `/resume`, `/close`, `/done`, `/health`의 책임 경계가 명확한가?
- command 이름만 보고 session 대상인지, Work 대상인지, repository state 대상인지 이해할 수 있는가?
- session flow가 실제 사람의 생각 흐름과 맞는가, 아니면 문서 체계 때문에 돌아가는가?
- "작업 중단 후 재개"와 "새 작업 시작"이 충분히 다르게 처리되는가?
- Work plan의 scope 축소, 확장, split, follow-up 전환이 명시적으로 기록되는가?
- Work가 끝난 뒤 PLAN/DR/backlog/STATUS에 무엇이 역류해야 하는가?
- 작업 변경 commit, Work close state update commit, archive cleanup commit의 경계가 명확한가?

검토 방향:

- current flow를 sequence diagram으로 다시 그린다.
- 실제 사용 intent 기준으로 command를 재분류한다.
- `/close`와 `/done`의 역할 분리는 유지하되, finalization 중복은 줄인다.
- Work lifecycle command와 session lifecycle command의 이름/alias를 재검토한다.
- commit 전 finalization gate가 "close해야 할 상태 정리"와 "archive처럼 optional hygiene인 상태 정리"를 구분하게 한다.

### Axis 2. Process And Gate Model

질문:

- 각 gate의 목적과 적용 범위가 분리되어 있는가?
- source repo 전용 gate가 target repo에 새는가?
- target repo가 자체 build/test command를 쉽게 선언할 수 있는가?
- hard block, warning, report-only의 기준이 일관적인가?
- public release, clean baseline, archive cleanup, bootstrap completion처럼 특정 상황에서만 강제되는 gate가 평시 workflow에 과하게 새고 있지 않은가?
- gate가 mandatory / conditional mandatory / recommended / optional hygiene 중 어디에 속하는가?

검토 방향:

- gate inventory를 만든다.
- Universal / Project Runtime / Source Maintainer / Optional Strict Mode로 분류한다.
- release/open/clean-baseline 전용 gate와 평시 Work lifecycle gate를 분리한다.
- archive, public release, clean baseline, bootstrap cleanup 등 강제성 있는 항목은 조건과 owner를 명확히 다시 분류한다.
- gate별 owner file과 tool enforcement 위치를 한 줄로 지정한다.

### Axis 3. Document Information Architecture

질문:

- `docs/`에 모든 것이 들어가는 구조가 유지 가능한가?
- `harness/` 또는 `.harness/` 같은 별도 namespace가 필요한가?
- 사람이 읽는 문서와 AI runtime 문서가 섞이지 않는가?
- source maintainer guide와 target runtime guide를 구분할 수 있는가?

검토 방향:

- 모든 live doc을 아래 분류로 inventory한다.
  - Source-only maintainer
  - Generated runtime
  - Generated onboarding
  - Optional reference
  - Archive/history
- 즉시 이동하지 않고, 먼저 target IA 후보를 2안 이상 비교한다.

### Axis 4. PLAN / Phase / Work / Backlog / DR Lifecycle

질문:

- `PLAN.md`는 무엇을 관리해야 하는가?
- phase는 milestone인가, planning horizon인가, backlog grouping인가?
- Work Done 후 어떤 조건에서 PLAN 또는 DR 업데이트가 필요한가?
- backlog candidate과 Work file 생성 사이의 책임 경계가 충분히 작동하는가?

검토 방향:

- `PLAN.md` 업데이트 trigger를 명시한다.
- `/close` 또는 commit finalization에 "PLAN impact yes/no"를 포함할지 검토한다.
- phase transition 시 STATUS만 바꾸지 않고 PLAN/backlog와 함께 정렬하는 rule을 설계한다.

### Axis 5. Scaffold Model

질문:

- default scaffold에 무엇을 넣고 무엇을 빼야 하는가?
- prompt library 전체 복사가 정말 필요한가?
- generated repo에 `scripts/create-harness.sh` 또는 `scripts/templates`가 들어가야 하는가?
- `docs/BOOTSTRAP.md`는 완료 후 삭제, archive, pointer 제거 중 무엇이 맞는가?
- scaffold 직후 onboarding flow가 어떤 순서로 project identity, validation defaults, PLAN, STATUS, backlog를 채워야 하는가?
- onboarding 완료를 어떤 기준으로 판정하고, 완료 후 어떤 문서와 prompt/rule pointer를 정리해야 하는가?
- `--existing` overlay와 future `--upgrade` / `--refresh`는 어떻게 구분되는가?

검토 방향:

- scaffold pack을 재분류한다.
  - `runtime-core`
  - `onboarding`
  - `tool-claude`
  - `tool-codex`
  - `tool-cursor`
  - `workflow-source-gitflow`
  - `example-spring-boot`
  - `maintainer-docs` (source-only 또는 optional)
- default output을 "작게" 만드는 방향을 우선 검토한다.
- bootstrap cleanup rule을 source docs와 generated docs 양쪽에 반영할지 검토한다.
- scaffold 후 onboarding은 단순 체크리스트가 아니라 generated repo의 첫 operational lifecycle로 재설계한다.
- `PLAN.md`가 bootstrap 중 "이전 예정"으로 밀리지 않도록 fill order와 soft/hard gate 경계를 다시 정의한다.

### Axis 6. AI Tool Surface

질문:

- Claude command와 Codex skill mirror는 현재 수준이 적절한가?
- Cursor rule은 command가 없으므로 어디까지 instruction을 가져야 하는가?
- tool-specific 파일이 canonical workflow를 과도하게 복제하는가?
- `Non-Negotiable Preflight` 또는 `Step 0 Mandatory Gate`를 어디에 두어야 하는가?

검토 방향:

- command/skill별 responsibility matrix를 만든다.
- `/work`, `/close`에는 Step 0 gate를 둘지 검토한다.
- entrypoint(`AGENTS.md`, `CLAUDE.md`)는 thin 유지하되 downstream preflight가 빠지지 않게 한다.

### Axis 7. Settings, Hooks, CI, Tests

질문:

- `tools/git-hooks`는 source repo 전용으로 유지해야 하는가?
- generated repo는 어떤 validation defaults를 가져야 하는가?
- CI는 source scaffold 검증과 target project 검증을 어떻게 분리해야 하는가?
- scaffold test는 shell script 실행만으로 충분한가, snapshot/assertion 기반 테스트가 필요한가?

검토 방향:

- source repo test suite 후보를 설계한다.
  - shell syntax
  - generic scaffold file list assertion
  - source-gitflow scaffold file list assertion
  - no source-only leakage assertion
  - generated startup flow simulation
- target repo에는 project-specific validation placeholder만 생성하는 방향을 검토한다.

### Axis 8. Git, Release, Public Open Flow

질문:

- `docs/GIT-WORKFLOW.md`의 source-gitflow 정책은 source repo 전용으로 충분히 표시되는가?
- target repo 기본 Git policy는 어느 정도까지 제공해야 하는가?
- public release / repo open 절차는 이 repo에 얼마나 포함해야 하는가?

검토 방향:

- source repo release/open checklist는 `docs/GIT-WORKFLOW.md`와 release gate에 최소화한다.
- 실제 GitHub 공개, sensitive sweep, repo settings, social/release note, post-public verification은 `/Users/kyungseo/dev-home/vibe/public-release-playbook`를 참조한다.
- target repo에는 public open playbook 전체를 복사하지 않고, 필요 시 external reference만 둔다.

### Axis 9. Cleanup / Removal Candidates

대담하게 제거 또는 축소를 검토할 후보:

- default scaffold의 maintainer docs 복사
- default scaffold의 prompt library 전체 복사
- target repo의 `WORKFLOW-MANUAL.md` 기본 복사
- target repo의 `HARNESS-ARCHITECTURE.md` 기본 복사
- target repo의 `HARNESS-MAINTAINER-GUIDE.md` 기본 복사
- source-style Gitflow의 default 노출
- 중복된 finalization 문구
- 오래된 optional Spring Boot example pack의 기본 위치
- `PLAN.md`와 `PLAN-SUMMARY.md`의 중복 설명

삭제는 바로 실행하지 않는다.
각 후보는 "source에서 제거", "scaffold에서 제외", "optional pack으로 이동", "archive", "link로 대체" 중 하나로 분류한다.

### Axis 10. Migration And Reversal

질문:

- 이미 scaffold된 repo는 어떻게 따라올 수 있는가?
- breaking change를 release note로만 안내해도 되는가?
- `--upgrade` 또는 수동 migration guide가 필요한가?
- Phase 2 변경을 작게 되돌릴 수 있는 PR 단위로 나눌 수 있는가?

검토 방향:

- Phase 2 execution PR을 작은 slices로 분해한다.
- scaffold output breaking change는 migration note를 남긴다.
- `--existing` overlay와 upgrade/refresh를 혼동하지 않게 한다.

## Initial Refactor Direction

Codex 1차 판단은 다음과 같다.

### Direction A. Source / Target Split

`ai-workflow-harness` source repo는 full knowledge base를 유지한다.
scaffold target repo는 operational runtime만 받는다.

초기 후보:

| Surface | Source repo | Default scaffold |
| --- | --- | --- |
| `README.md` | public intro + adoption guide | 짧은 project onboarding README |
| `docs/WORKFLOW-MANUAL.md` | 유지 | 기본 제외 또는 link |
| `docs/HARNESS-ARCHITECTURE.md` | 유지 | 기본 제외 또는 optional |
| `docs/HARNESS-MAINTAINER-GUIDE.md` | 유지 | 제외 |
| `prompts/*.prompt.md` | 유지 | session-start 3종 + README만 기본 |
| `scripts/create-harness.sh` | 유지 | 제외 |
| `docs/GIT-WORKFLOW.md` | source policy | `--workflow source-gitflow` opt-in |

### Direction B. PLAN Lifecycle 강화

`PLAN.md`는 다음 정보를 관리한다.

- project goal and non-goals
- phase strategy
- architecture and workflow boundary
- major decisions not yet DR-worthy
- living roadmap

Work closeout에는 다음 질문을 추가하는 방향을 검토한다.

```text
PLAN Impact: 이번 Work 결과가 PLAN.md / PLAN-SUMMARY.md / Phase 계획에 반영되어야 하는가?
```

### Direction C. Scaffold Output을 테스트 가능한 product로 취급

`scripts/create-harness.sh`는 단순 copy script가 아니라 scaffold product generator다.
따라서 Phase 2에서는 generated file matrix와 assertion test가 필요하다.

후보:

- expected file list fixture
- generic scaffold no-source-only-leakage check
- source-gitflow marker check
- prompt copy policy check
- README first-screen / bottom attribution check

### Direction D. Tool Runtime Preflight 강화

`CLAUDE.md` / `AGENTS.md`는 thin entrypoint를 유지한다.
다만 generated target repo에는 tool별로 다음 preflight가 빠지지 않아야 한다.

- branch / git state 확인
- `docs/STATUS.md` current sections 확인
- Active Work 우선
- bootstrap pointer 조건부 확인
- project-specific validation defaults 확인
- workflow/status/backlog/work 변경은 L2로 취급
- state/commit/PR/merge는 Approval Matrix 이후

이 preflight는 root entrypoint에 모두 넣을지, command/skill Step 0으로 둘지 비교한다.

## Deliverables

> 이 Work는 Cross-Agent Review로 **방향 합의 · DR 후보 · OQ · Slicing**을 산출했다.
> inventory/diagram/matrix 같은 구체 문서 산출물은 slice 0~ 실행 Work로 이관한다(planning/implementation 분리, Done Criteria 재정의).

방향 합의 완료 — 이 Work 산출물:

- [x] Claude review 반영 (Claude Review Notes §1~10)
- [x] Codex/Claude 합의·unresolved 기록 (Codex Re-Review, Consensus Log, OQ-1~18)
- [x] DR-worthy decision 후보 목록 (Decision Candidates)
- [x] Phase 2 execution roadmap (Follow-Up PR Slicing Draft, slice 0~13)
- [x] 제거/보강/유지/optional 이동 후보 (Axis 9 + §5·§6·§8 논의)

방향 합의 완료 — 구체 문서화는 실행 Work로 이관:

- [x] Current surface inventory → slice 1
- [x] Source-only / target-runtime / optional 분류표 → slice 0·1
- [x] End-to-end workflow diagram 초안 → slice 0
- [x] Gate inventory와 계층화 (2D taxonomy 방향 확정) → slice 7
- [x] PLAN / Phase / Work / Backlog / DR lifecycle 재설계안 (§7 확정) → slice 3
- [x] Scaffold pack 전략·default output 축소안 (§6 확정) → slice 9
- [x] Scaffold 후 onboarding process 재설계안 → slice 4
- [x] AI tool surface responsibility matrix (§5 canonical+adapter) → slice 13
- [x] settings/hooks/CI/test 개선 후보 → slice 10
- [x] Git/open/public release 참조 경계 (OQ-6 방향) → slice 12

## Verification

이번 Work 자체의 검증:

- `git diff --check`
- Work file 링크와 경로 확인
- `docs/works/harness/README.md` Active row 확인
- Phase 2 실행 계획이 실제 PR 단위로 분해 가능한지 self-review

후속 implementation Work의 검증 후보:

- `bash -n scripts/create-harness.sh`
- generic scaffold dry-run / actual generation
- source-gitflow scaffold dry-run / actual generation
- generated file list assertion
- generated stale/source-only leakage search
- command/skill mirror diff audit
- README / onboarding / generated STATUS first-session simulation

## Risk And Reversal Cost

### Risk

- 넓은 범위를 한 번에 고치면 tool surface drift가 발생할 수 있다.
- source repo 문서를 줄이려다 maintainer context를 잃을 수 있다.
- scaffold target을 작게 만들면 beginner onboarding 설명이 부족해질 수 있다.
- command/skill mirror 수정은 Claude/Codex 간 차이를 다시 만들 수 있다.
- Git/release gate를 단순화하다 public release safety가 약해질 수 있다.

### Reversal Cost

High.
Phase 2 implementation이 실제 파일 이동, scaffold output 변경, command/skill rewrite를 포함하면
이미 scaffold된 downstream repo와 사용자의 습관에 영향을 준다.
따라서 이번 Work에서는 planning과 slicing을 먼저 확정하고, implementation은 작은 PR 단위로 나눈다.

## Status Update Proposal

이 Work를 active로 진행하려면 별도 승인 후 `docs/STATUS.md` Active Work에 아래 row를 추가한다.

| ID | Title | Work File |
| --- | --- | --- |
| CHORE-20260604-001 | Harness Phase 2 Refactor Planning | `docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md` |

STATUS 변경은 이 Work 파일 생성과 같은 commit에 포함할 수 있지만, Approval Matrix에 따라 사용자 승인이 필요하다.

## Cross-Agent Review And Discussion

이 섹션은 Claude와 Codex가 함께 리뷰하고 합의하기 위한 공간이다.
각 도구는 자기 관점에서 "과감하게 바꿀 것"과 "건드리면 위험한 것"을 분리해서 기록한다.

### Codex Initial Review

Codex 1차 판단:

- Phase 2의 핵심은 문서 축소가 아니라 source/target 책임 경계 재정의다.
- default scaffold는 지금보다 작아져야 한다.
- maintainer docs와 workflow manual은 source repo에 남기되 target repo 기본 복사는 재검토해야 한다.
- prompt library 전체 복사는 target repo에서 noise가 될 가능성이 높다.
- `PLAN.md`는 closeout/finalization gate와 연결되어야 살아난다.
- Gitflow와 Public Clean Baseline Gate는 source-style opt-in으로 더 명확히 격리해야 한다.
- scaffold output은 테스트 가능한 product로 다뤄야 한다.

### Claude Review Notes

작성: Claude (claude-sonnet-4-6), 2026-06-04. source repo 실제 파일 근거 기반 비판적 리뷰.

#### 결론 먼저

Codex의 핵심 진단(**source/target 책임 경계 미분리**)은 옳고, 추상적 가설이 아니라 source repo에서 재현 가능한 결함으로 확인됐다.
다만 이 Work 자체의 가장 큰 risk는 진단이 아니라 **scope다.** 10개 Axis · 13개 deliverable을 `appetite: 3d`에 한 번에 펼치는 구성은 `BEHAVIOR-PRINCIPLES.md` §2 Simplicity / §3 Surgical Changes와 충돌한다.
권고: 가장 확실하고 reversal cost 낮은 결함부터 좁혀 닫고(저비용·고확실성), breaking change를 동반하는 split은 DR로 분리해 뒤로 미룬다.

#### 진단을 추상 가설에서 재현 가능한 결함으로 끌어내린 근거

이번 리뷰의 1차 가치는 Codex가 "의심 지점"으로 둔 항목을 실측한 것이다.

| # | Codex 가설 | 실측 근거 | 판정 |
| --- | --- | --- | --- |
| A | maintainer/manual 문서가 target에 복사된다 | `scripts/create-harness.sh:215-217` — `HARNESS-ARCHITECTURE.md`(280줄), `HARNESS-MAINTAINER-GUIDE.md`(212줄), `WORKFLOW-MANUAL.md`(1790줄)를 무조건 `adapt` 복사 | **확정** |
| B | target에 dangling reference가 생긴다 | scaffold가 복사하는 DR은 **007/008/013** 3개뿐(`scripts/create-harness.sh:219-226`)인데, 같이 복사되는 `HARNESS-MAINTAINER-GUIDE.md`는 **DR-020**, `HARNESS-NAMING-RULES.md`는 **DR-011**을 참조 → target에서 깨진 참조. (`WORKFLOW-MANUAL.md`의 **DR-001**은 Codex 정정대로 direct link보다 filename 예시/historical 언급에 가까워 OQ-9의 integrity test로 판정 보류) | **DR-020/011 확정** |
| C | DR 인덱스 규칙이 target에서 작동하지 않는다 | `docs/decisions/README.md`는 scaffold 미복사(`grep -c = 0`). 그런데 복사된 `HARNESS-PROTOCOL.md:394`는 "cascade 감사 시 `docs/decisions/README.md` 인덱스의 Accepted DR만 확인"을 규정 → target에서 실행 불가능한 규칙 | **확정(신규 발견)** |
| D | PLAN.md가 living document로 작동하지 않는다 | `PLAN.md`는 `문서 버전 v0.1 / 작성일 2026-05-22` 이후 갱신 흔적 없음. Roadmap(`PLAN.md:116-119`)은 `AWH-003/004` 미착수로 멈춰 있는데, 실제 작업은 `STATUS.md`에서 `CHORE-YYYYMMDD-NNN` 체계로 진행 중 → roadmap과 실작업이 단절 | **확정** |

핵심 정정: 처음 세웠던 "핵심 canonical 문서가 dangling DR을 참조한다"는 가설은 **틀렸다.**
`HARNESS-PROTOCOL.md`(DR-007/013)와 `AGENT-WORKFLOW.md`(DR-007/008)의 참조는 복사되는 3개 DR로 모두 커버된다.
dangling은 **무거운 maintainer/manual 계층(B·C)에서만** 발생한다. 이 사실은 오히려 Codex의 처방을 정밀화한다 — 문제는 "DR을 더 복사하라"가 아니라 **무거운 문서를 애초에 target 기본값에서 빼라**는 것이다.

#### 1. 동의하는 방향

- **Direction A (source/target split).** 근거 A·B·C가 직접 뒷받침. 단 "복사 여부 재검토"가 아니라 **기본 제외 + source link**가 맞다. dangling reference는 문서를 빼면 자동 소멸한다.
- **Direction C (scaffold = 테스트 가능한 product).** 근거 B·C는 file-list assertion이 아니라 **link/reference integrity test**로만 잡힌다. 이 테스트가 없었기 때문에 dangling이 지금까지 남았다. Phase 2에서 가장 ROI 높은 단일 항목.
- **Gate 계층화(Axis 2).** gate 마찰은 가설이 아니라 이미 발생한 사실이다 — `STATUS.md:41` Recent Decision(2026-05-29)이 "solo 프로젝트에서 housekeeping마다 PR 강제는 과도한 마찰"을 명시적으로 인정하고 develop hard block을 완화했다. 계층화 방향에 동의.

#### 2. 반대하거나 위험하다고 보는 방향

- **OQ-2 (`docs/`와 `harness/` 물리 분리) — 반대(현 단계).** 물리 이동은 모든 cross-reference, 자동 로드 경로, `scripts/create-harness.sh` 경로, `HARNESS-PROTOCOL.md:469-483` Tool Surface Cascade Matrix를 동시에 깨뜨린다. reversal cost High. **pack 분류(논리 태깅)로 먼저 해결하고, 물리 이동은 마지막 수단.** `PLAN.md:346` "이동은 참조 비용과 자동 로드 영향을 함께 검토한다"가 이미 같은 경고를 한다.
- **OQ-3 (generated repo에 `PLAN.md` 작성 완료를 feature work hard gate) — 반대.** 이미 Baseline Gate(`PLAN-SUMMARY.md` Implementation Baseline, scaffold가 생성하는 `PHASE1.md:705`)가 존재한다. PLAN.md까지 hard gate면 bootstrap 마찰이 이중이 되고, content/research/no-code 프로젝트(scaffold가 명시적으로 지원, `BOOTSTRAP.md` §3 "Not Applicable")는 PLAN.md가 거의 비어도 정상인데 거짓 차단이 발생한다. **soft gate(closeout 질문)가 맞다.**
- **Direction B가 스스로 Thesis 6을 위반할 위험.** Thesis 6은 "gate는 많이가 아니라 정확한 위치"인데, Direction B의 "closeout에 PLAN Impact 질문 추가"는 새 gate 신설이다. 그런데 `HARNESS-PROTOCOL.md:423` **T5(PLAN 영향 결정 → PLAN 확인)가 이미 존재한다.** 문제는 trigger 부재가 아니라 **T5가 `/close`·commit finalization 흐름에 실제로 연결되지 않은 것.** 신설이 아니라 **기존 T5를 closeout에 배선**하는 문제로 재정의해야 한다.

#### 3. 추가로 봐야 할 surface (문서가 다루지 않은 것)

- **ID 체계 cascade 미완(신규).** `PLAN.md`는 `AWH-001~004`, `STATUS.md`/Work는 `CHORE-YYYYMMDD-NNN`. 2026-05-27 전환 결정(`STATUS.md:42`)이 PLAN.md와 retrospective에 cascade되지 않았다. source/target split을 논하기 전에 **source repo 자신의 ID 체계부터 단절**돼 있다. Axis 4에 ID lifecycle 항목 추가 필요.
- **PLAN.md가 source/target 미분리의 표본.** `PLAN.md:90-93` "Kept As Core"는 `HARNESS-ARCHITECTURE.md`/`HARNESS-MAINTAINER-GUIDE.md`를 **source에서 유지**하기로 한 결정인데, scaffold는 같은 두 문서를 **target에도 복사**한다(근거 A). "source에서 keep"과 "target에 ship"이 한 결정에 뭉개져 있다 — split의 필요성을 PLAN.md 자신이 증거로 보여준다.
- **3중 mirror의 실측 부피.** `/work`+`/close` 한 쌍만으로 Claude command 239줄 + Codex skill 259줄 + Cursor `workflow.mdc` 98줄. 11개 command 전체로는 수천 줄이 `HARNESS-PROTOCOL.md:469` T11 cascade로 **수동 동기화**된다. drift는 사고가 아니라 구조적 필연. Axis 6은 "responsibility matrix 작성"을 넘어 **canonical 1곳 + tool은 thin pointer**로의 단일화 가능성까지 봐야 한다.

#### 4. Implementation slicing 제안 (Codex 8-slice 재배열)

원칙: **breaking change 없는 고확실성 결함을 먼저 닫고, downstream 영향이 있는 split을 DR 뒤로.** reversal cost를 slice마다 라벨링한다.

| 순서 | Slice | 내용 | 방향 의존 | Breaking | Reversal |
| --- | --- | --- | --- | --- | --- |
| 0 | **방향 결정** | source/target(A/B) layer 경계 + canonical workflow 구조 + gate 계층의 TO-BE 합의. 이게 진짜 "리팩토링" | — | No | Low |
| 1a | 현존 결함 수선 | dangling DR(020/011/001), `decisions/README` 미복사, AWH↔CHORE ID drift, PLAN 좀비 복구 | 무관(선행) | No | Low |
| 1b | 불변식 테스트 | no-dangling-reference / no-source-only-leakage assertion. 방향과 무관하게 영구 참 | 무관(선행) | No | Low |
| 2 | 계약 테스트 | file-list / output-contract assertion. slice 0 확정 **후**라야 의미 | 의존 | No | Low |
| 3 | **DR: A/B boundary + canonical** | scaffold pack 축소 + canonical+adapter 전환을 breaking으로 명시, migration note 포함 | 의존 | **Yes** | **High** |
| 4 | 적용 | canonical 단일화, scaffold minimal output, manifest/upgrade | 의존 | **Yes** | High |
| 5 | User-facing docs 재작성 | README/onboarding을 새 output contract에 맞게 | 의존 | No | Low |

**사용자 Q&A(2026-06-04) 반영 — 순서 정정:** 앞선 초안은 "inventory+test 무조건 선행"을 1순위로 뒀으나 부정확했다. **계약(file-list) 테스트는 방향(slice 0)의 함수이므로 선행 불가** — 방향 전에 짜면 곧 폐기된다. 선행 가능한 것은 방향과 무관한 **불변식 테스트(1b)와 현존 결함 수선(1a)뿐**이다. 진짜 1순위는 slice 0(방향 결정)이며 scaffold·test·manifest는 모두 그 하류다.

#### 5. Canonical + Adapter 구조 (Axis 6 핵심 처방 — 사용자 Q3)

mirror 부피 문제의 해법은 "responsibility matrix 작성"을 넘어 **canonical SSoT 1벌 + 도구별 thin adapter**다. 가설이 아니라 **사용자의 `ai-deck-compiler`에서 이미 작동 검증된 패턴**이다.

- `skills/create-deck.md` **837줄**(canonical 도메인 지식) ← `.claude/commands/create-deck.md` **115줄**(thin pointer: "skills/create-deck.md를 로드해서 따라줘", "세부는 skills/create-deck.md를 따른다"), `.agents/skills/create-deck/SKILL.md` 1.2KB 어댑터.
- 결정적 관찰: 이 패턴이 거기서 **도메인 skill에만** 적용됐고 **워크플로우 skill(start/work/close)에는 미적용** — 루트 `skills/`에 워크플로우 항목이 없다.

하네스는 정반대다. work 절차가 Claude command(96줄)+Codex skill(110줄)+Cursor `workflow.mdc`에 각자 self-contained 3벌, canonical 0개, `HARNESS-PROTOCOL.md:469` T11 수동 cascade로 동기화.

처방: 워크플로우 절차를 공통 canonical 위치(루트 `skills/` 또는 동급)에 1벌로 모으고, `.claude/commands/`·`.agents/skills/`·`.cursor/rules/`는 핵심 절차만 자체 포함하고 세부는 canonical에 위임하는 얇은 adapter로 전환한다. scaffold도 canonical 1벌+얇은 adapter만 복사 → mirror 부피와 target context weight를 **동시** 감소.

제약(비판적): ① Claude command의 "로드 지시"는 `@` 하드 import가 아니라 런타임 자연어 유도라 100% 결정적이지 않다 → adapter는 핵심 절차를 자체 포함하는 hybrid여야 안전. ② 워크플로우는 도메인보다 도구별 실행 메커니즘 차이가 크다(slash 자동 인식 vs `AGENTS.md` routing vs Cursor rule) → 그 차이가 정확히 "도구 고유=가볍게"의 자리. ③ breaking change(scaffold output 구조 변경)이므로 slice 3 DR 뒤.

#### 6. Scaffold 배포 / 업그레이드 / 마이그레이션 모델 (사용자 Q4)

**진단: 현재 scaffold는 one-shot fork-by-copy다.** bootstrap엔 적절하나 lifecycle이 구조적으로 없다.

- `adapt()`=`sed` 치환 복사(`create-harness.sh:137-143`). 복사 순간 source↔target 연결이 끊긴다.
- target에 버전/manifest 0 (스크립트에 version/manifest 생성 없음, README `Scaffolded ${TODAY}` 날짜 문자열뿐). target은 자기가 어느 하네스 버전에서 나왔는지 모른다.
- `--existing`은 기존 파일 skip만(`create-harness.sh:121-135`) → 변경된 framework 파일은 영영 stale.
- **실물 증거**: `harness-scaffold-lab/`이 5/25 scaffold 후 멈춤. source는 그 뒤 5/27(ID 체계 전환)·5/29(hook 정비)로 진화했으나 lab은 못 따라옴. "fork가 어떻게 stale되는가"의 살아있는 표본.

근본 원인: scaffold가 두 종류를 한 평면에 섞는다.

- **(A) framework**: `HARNESS-PROTOCOL`, command/skill, `BEHAVIOR-PRINCIPLES` — source 소유, 업그레이드 대상.
- **(B) project state**: `STATUS`/`PLAN`/backlog/works/decisions — target 소유, 불가침.

copy는 둘을 구분하지 않으니 (A)만 갱신할 방법이 없다 → 업그레이드 불가.

대안 비교(배포 / 업그레이드 / AI도구 루트경로 호환 기준):

| 모델 | 업그레이드 | AI도구 루트경로 | 평가 |
| --- | --- | --- | --- |
| 현재 copy-sed | ❌ 없음 | ✅ | bootstrap OK, lifecycle 부재 |
| npm/pip 패키지 | `npm update` | ❌ `node_modules`는 `.claude/` 경로 불가 | 순수형 부적합 |
| git submodule/subtree | pull | △ | UX 최악, sed 치환 충돌 |
| **layer 분리 + manifest + `--upgrade`** (Rails `app:update`식) | 3-way merge | ✅ 루트 생성 유지 | **유망, 단 구현비용** |

권고: copy를 버리지 말고 **"one-shot fork" → "tracked install"로 승격**. 점진 4단계.

1. **Layer 경계 확정**(A/B 분리) — Q3 canonical 구조의 하류. 선행.
2. **Manifest 도입**: target에 `.harness/manifest.json`(harness version, profile, framework 파일+hash). 비용 작음, 즉시 가능. 마이그레이션 note가 "어느 버전에서 오는가"를 알려면 이게 전제.
3. **`--check`(drift 리포트)**: framework 파일이 source 대비 얼마나 벗어났나 보고. 풀 자동 머지 없이도 업그레이드 가능성 확보.
4. **`--upgrade`(3-way merge)**: base(배포 시점) vs current(target) vs new. 안 건드린 framework 자동 갱신, 커스텀은 충돌 표시, (B)는 불가침. 비용 큼 → target 다수+고통 실측 후(Simplicity First, deferred).

구현 리스크: sed 치환된 파일은 source와 hash가 다르므로 hash는 "치환 전 정규화" 기준이어야 한다. npm 모델 부적합 이유는 AI 도구가 `.claude/`·`CLAUDE.md`·`docs/`를 repo 루트 고정 경로에서 읽기 때문 — "루트 직접 생성"은 옳고 빠진 건 *추적*이다.

#### 7. PLAN.md 구조 평가 — 좀비 · 단일 파일 · 비대화 (사용자 Q1 + 후속 Q&A)

##### 7-a. 좀비 확진

`PLAN.md`는 파일로는 하나로 존재하나 living document로는 죽어 있다. 최근 커밋 2개가 전부 rename/정비 cascade(`HARNESS-STRUCTURE→ARCHITECTURE rename` 등)로, 내용 진화가 아니라 다른 작업에 딸려 touch된 것이다. `문서 버전 v0.1` 유지, Roadmap은 `AWH-003/004`에서 멈춤, ID 체계는 PLAN(`AWH-*`)과 STATUS/Work(`CHORE-*`)로 분기. 즉 "cascade로 파일은 만져지나 의미 갱신 trigger가 없는" 상태다(T5가 closeout에 미배선).

##### 7-b. "단일 파일이 문제인가" — 아니다. 변경 주기 혼합이 문제다

PLAN은 변경 주기가 다른 3종을 한 파일에 묶는다.

| 구성요소 | 누적 압력 | 본래 위치 |
| --- | --- | --- |
| Charter (목표·non-goals·boundary) | 거의 불변 | PLAN.md (안정) |
| Roadmap (phase 전략·현재 horizon) | 자주 변함 | 갱신 trigger와 연동돼야 살아있음 |
| Decision rationale (L3 근거) | 이벤트성 | **DR로 빠질 자리** |

핵심: 한 파일에 묶이면 **가장 느린 것(charter)의 안정성이 가장 빠른 것(roadmap)의 갱신을 가린다.** 단일 파일 자체가 아니라 변경 주기 혼합 + trigger 부재의 합작이 박제의 원인이다.

단일 PLAN을 압박하는 3개 축:

- **시간축**: phase가 닫혀도 그 상세가 PLAN에 남으면 단조 증가. STATUS는 rolling window+archive로 시간축을 관리하나 PLAN은 메커니즘 0.
- **트랙축**: backlog는 `PHASE{n}.md`(product) / `HARNESS.md`(harness)로 이미 분리됐는데 PLAN은 하나 → 비대칭. scaffold 생성 `PLAN.md`(`create-harness.sh:639-689`)는 product 템플릿(`Project Initialization Plan`/`기술 스택 선택 근거`/`Phase 계획`)인데 source repo PLAN.md는 harness 계획 → **같은 파일명이 두 의미, 비표면화.** 게다가 target은 harness track(`HARNESS.md`)도 운영하나 harness 방향 계획처가 없다.
- **계층축**: goal(불변)+roadmap(가변)+L3근거(DR감)가 한 diff 평면에 섞임.

##### 7-c. 비대화와 죽음은 같은 뿌리의 두 증상

```text
PLAN에 lifecycle(들어오는 trigger + 나가는 cascade)이 없다
   ├─ 갱신 안 함 → 죽음    (현재: AWH-003에서 박제)
   └─ 갱신 함    → 비대화  (살아났을 때의 미래)
```

결정적 비대칭(근거): STATUS Recent Decisions에는 **"최근 8개 rolling window 유지"** 제동이 명시돼 있으나(`HARNESS-PROTOCOL.md:496`), PLAN에는 배출 장치가 **하나도 없다.** 즉 이 하네스는 누적 비대화가 나쁘다는 걸 알고 STATUS엔 제동을 걸었으나 PLAN엔 빠뜨렸다.

검증(자기 반박): PLAN이 무한정 커지는 건 아니다. 비대화는 오직 **"닫힌 phase 상세를 PLAN에 남기는 습관"과 "L3 근거를 DR로 안 빼는 습관"에서만** 발생한다. Charter+미래 roadmap만 있으면 PLAN은 상수 크기에 수렴한다. 따라서 "구조적으로 비대해지는가"의 답은 **"배출 cascade와 작성 규율이 있으면 아니오, 없으면 예"** — 현재는 없으니 살아나는 순간 비대화 위험이 실재한다.

##### 7-d. 처방 — 분할이 아니라 lifecycle 배선

죽음과 비대화를 한 처방이 동시에 해결한다.

| Trigger | 역할 | 막는 증상 |
| --- | --- | --- |
| **T5 ↔ closeout/phase-transition 배선** (들어오는 문) | Work/phase 결과를 PLAN에 반영 | 죽음 |
| **T3 ↔ PLAN 포함** (나가는 문) | 닫힌 phase 상세 → `docs/archive/` 배출 | 비대화 |
| **DR 규율** (옆문) | L3 근거는 PLAN이 아니라 DR로 | 계층 비대화 |

개선 옵션:

| 옵션 | 내용 | 평가 |
| --- | --- | --- |
| **A. current-only + archive drain** | PLAN은 현재+미래만, 닫힌 phase는 `docs/archive/plan/PHASE{n}.md`로 cascade, PLAN엔 링크 한 줄 | **권장.** 파일 수 안 늘림(작은 target 친화) + 크기 O(현재 phase), trigger 1개(T3 확장)만 추가, 기존 완료→archive 패턴과 동일 |
| B. Charter / phase-plan 분리 | phase 계획을 `PHASE{n}.md`로 흡수 | 이중 관리는 줄지만 장기 roadmap 자리가 애매 |
| C. lazy split (임계 분할) | 작을 땐 하나, phase 누적·N줄 초과 시 분할 | 분할 시점 trigger 필요, 분할 자체가 리팩토링. **규모가 강제할 때의 최후 수단** |

작은 target(`demo-todo-cli` 등)에서 PLAN을 미리 쪼개면 관리 파일만 늘어 **더 빨리 죽는다.** 비대화는 분할이 아니라 배출구로 막는다 — STATUS가 rolling window로 하듯이.

##### 7-e. 선결 위치와 Codex 검토용 질문

함의: PLAN이 죽으면 source/target 경계 같은 상위 결정의 기록처가 사라진다. 따라서 **PLAN 복구(7-d lifecycle 배선)는 slice 0(방향 결정)과 묶인 선결 과제**다 — split을 PLAN이 죽은 채로 결정하면 결정 근거가 증발한다.

Codex 검토 요청 질문:

1. target `PLAN.md`를 product-only로 한정하면 harness 방향 계획처를 **target에 둘 것인가, source 독점(A layer)으로 둘 것인가?** target maintainer의 harness 커스터마이징 의도 기록 위치가 남는다.
2. roadmap을 STATUS로 흡수하면 STATUS 비대 위험. **경량 `ROADMAP` 섹션/파일이 임계 규모에서 필요한가?**
3. PLAN 시간축에 STATUS의 rolling-window를 복제할지, **archive cascade(옵션 A)만으로 충분한지.**

#### 8. User-facing ↔ canonical 양방향 참조 제거 (사용자 Q5)

> **Codex 재검토 미반영 신규 항목** — 이 §8은 Codex Re-Review(2026-06-04) 작성 이후 추가됐다. 다음 Codex 패스에서 검토 대상.

사용자 지시: 사용자 매뉴얼/가이드(`WORKFLOW-MANUAL.md`, `SCAFFOLD-ONBOARDING-GUIDE.md`)와 하네스 canonical 문서 간 상호 참조를 제거한다. 내용이 중복되는데 한 쪽이 다른 쪽을 가리키는 순간 SSoT가 무너지기 때문이다.

실측 근거 — 양방향 결합이 실재:

| 방향 | 실측 | 평가 |
| --- | --- | --- |
| manual → canonical (정방향) | `WORKFLOW-MANUAL`이 `AGENT-WORKFLOW` 24 · `HARNESS-PROTOCOL` 24 · `BEHAVIOR-PRINCIPLES` 16 · `QUICK-REFERENCE` 10 참조 | 방향은 옳으나(원본 지목) 횟수 과다 → 재서술+참조 = 중복+봉합 |
| canonical → manual (역방향) | `HARNESS-PROTOCOL` 6곳 + `AGENT-WORKFLOW` 1곳 (`HARNESS-PROTOCOL.md:166` cascade 감사 대상에 manual 포함) | **SSoT 역전.** 실행 규칙 원본이 사용자 문서를 가리킴 → canonical 변경이 manual cascade 부담을 생성 |
| guide ↔ source docs graph | `SCAFFOLD-ONBOARDING-GUIDE`→canonical 11, `GIT-WORKFLOW`·`HARNESS-ARCHITECTURE`→guide 역참조 | canonical 양방향이라기보다 source docs graph 결합. 가이드도 중복+참조 봉합 위험을 가진다 |

정밀화(비판적): "모두 제거"의 본질은 *참조 금지*가 아니라 **"중복을 만들고 참조로 봉합하지 마라"**다. 두 방향을 구분 처리한다.

- **역방향(canonical → manual): 즉시 제거.** canonical은 user-facing의 존재를 몰라야 한다. `HARNESS-PROTOCOL.md`의 cascade matrix(`:166`)·load map·anti-pattern·document map에서 manual/guide 언급을 빼고, user-facing 문서 관리는 user-facing 쪽 단독 책임으로 단방향화한다.
- **정방향(manual → canonical): 횟수를 줄여 단방향 위임만 남김.** manual은 규칙을 재서술하지 않고(중복 제거) 사용자 흐름·예시·WHY만 소유한다. 규칙이 필요하면 링크 1개로 위임한다.

종착점: 두 문서의 **소유 주제가 겹치지 않게 경계를 그으면 참조는 자연히 0에 수렴한다.** manual = 사용자 흐름/예시/WHY, canonical = 실행 규칙. 겹침이 없으면 가리킬 일도 없다.

메타 관찰: 이 논점은 §5(canonical+adapter mirror)·§6(scaffold A/B)·§7(PLAN SSoT)와 **같은 뿌리**다. 이 하네스의 반복 결함은 일관되게 **"중복을 만들고 cross-reference로 봉합"**이다.

#### Phase 2 1순위 재정의 (Q1·Q2·Q3·Q4·Q5 종합)

앞선 초안의 1순위(inventory+test)는 철회한다. 종합된 1순위:

1. **slice 0 — 방향 결정**: A/B layer 경계 + canonical workflow 구조(Q3) + gate 계층.
2. **PLAN 복구(Q1)** + T5↔closeout 배선: 위 방향 결정의 기록처.
3. 병행: 현존 결함 수선(1a) + 불변식 테스트(1b).

scaffold lifecycle(Q4)·user-facing decoupling(Q5)·계약 테스트·canonical 적용은 모두 1·2의 하류다.

**통합 원칙:** surface마다 SSoT 1개, 나머지는 thin · 단방향 참조. §5·§6·§7·§8은 모두 "중복+cross-reference 봉합"이라는 한 뿌리의 증상이며, Phase 2는 이를 surface별로 끊는 작업이다.

#### Open Questions에 대한 Claude 입장 요약

| OQ | Claude 입장 |
| --- | --- |
| OQ-1 (MANUAL 제외+link) | **찬성.** dangling/context-weight 둘 다 해소. |
| OQ-2 (docs/ vs harness/ 물리 분리) | **현 단계 반대.** pack 논리 분류 우선, 물리 이동은 최후. |
| OQ-3 (PLAN.md hard gate) | **반대.** soft closeout 질문(기존 T5 배선)으로. |
| OQ-4 (prompts session-start 3종만) | **찬성, 단 generic profile 한정.** 현재 generic도 task prompt 13종 복사(`scripts/create-harness.sh:331-350`)되는 것이 과다. |
| OQ-5 (hook/CI enforcement 안내) | source는 강제, target은 **placeholder + 주석 안내**(generated `settings.json`처럼). |
| OQ-6 (public-release-playbook link vs 요약) | **link만.** 요약 복제는 또 다른 drift surface. |

#### 비판적 마무리

이 Work의 진짜 위험은 "무엇을 바꿀까"가 아니라 **"한 번에 얼마나 바꿀까"**, 그리고 **"무엇을 먼저"**다.
근거 A~D는 명확하지만, 10축 동시 리팩토링으로 묶으면 `Risk And Reversal Cost`의 "tool surface drift"를 스스로 유발한다.
사용자 Q&A(2026-06-04) 반영 후 첫 착수는 **slice 0(방향 결정: A/B 경계 + canonical 구조 + gate 계층) + PLAN 복구**다. 이것이 정해져야 scaffold·test·manifest의 대상이 정의된다(Q2). 현존 결함 수선(1a)과 불변식 테스트(1b)만 방향과 병행해 먼저 닫고, breaking change(canonical 단일화·scaffold minimal output·upgrade 엔진)는 그 위에서 DR로 진행한다.

### Codex Re-Review Of Claude Notes

작성: Codex, 2026-06-04. Claude Review Notes를 source repo와 `ai-deck-compiler` 실제 파일 기준으로 재검토.

#### 1. Slice 순서 정정 — 동의

Claude의 "slice 0(방향 결정)이 1순위이고 scaffold·test·manifest는 그 하류"라는 정정에 동의한다.
내 8-slice 초안은 inventory와 scaffold 계약 테스트를 너무 이르게 배치했다.

근거:

- `scripts/create-harness.sh`의 현재 default output은 maintainer/manual 문서와 prompt library를 넓게 복사한다(`scripts/create-harness.sh:215-217`, `331-350`). 어떤 file-list가 옳은지는 "default scaffold를 작게 만들 것인가"라는 방향 결정 없이는 정할 수 없다.
- 반면 방향과 무관한 불변식은 선행 가능하다. 예: generated output에 source-only leakage 또는 dangling reference가 없어야 한다는 검사는 output contract가 바뀌어도 유지된다.
- `HARNESS-PROTOCOL.md`도 tool/scaffold 변경 시 cascade 확인을 요구하지만(`docs/HARNESS-PROTOCOL.md:469-483`), cascade 대상 자체는 source/target boundary 결정 이후 재정의되어야 한다.

따라서 합의안:

1. **slice 0**: A/B layer 경계, canonical workflow 구조, gate 계층, PLAN lifecycle 방향 결정
2. 병행 가능: 현존 결함 수선(1a), 방향 불변 테스트(1b)
3. 그 뒤: file-list/output-contract test, scaffold minimal output, manifest/upgrade

#### 2. Canonical + Adapter 구조 — 조건부 동의

Claude가 제안한 Canonical+Adapter는 mirror 부피 해소책으로 적절하다.
`ai-deck-compiler`의 `create-deck` 패턴은 실제 근거가 있다.

- `skills/create-deck.md`: 837 lines
- `.claude/commands/create-deck.md`: 115 lines, `skills/create-deck.md`를 로드하고 핵심 gate만 유지
- `.agents/skills/create-deck/SKILL.md`: thin routing, 상세는 `skills/create-deck.md`를 따름
- 현재 하네스 `/work` 표면은 `.claude/commands/work.md` 96 lines, `.agents/skills/workflow-work/SKILL.md` 110 lines, `.cursor/rules/workflow.mdc` 98 lines로 self-contained mirror가 반복된다.

다만 workflow skill에는 도메인 skill보다 더 강한 제약이 있다.

- Claude command의 "로드해서 따라줘"는 `@file` hard import가 아니므로, 자연어 로드 지시만으로는 결정성이 약하다.
- Codex는 `AGENTS.md` skill routing과 `.agents/skills/*/SKILL.md`를 통해 동작하고, Cursor는 command가 아니라 rule 기반이다. 세 도구의 실행 mechanism 차이는 domain skill보다 크다.
- workflow command는 branch/state/approval gate처럼 실패 시 damage가 큰 절차를 다룬다. wrapper가 너무 얇으면 core gate를 놓칠 수 있다.

따라서 조건부 합의:

- canonical 1벌을 만든다.
- adapter는 완전 thin pointer가 아니라 **hybrid adapter**로 둔다.
- adapter 자체에는 Step 0 / hard stop / tool-specific entry mechanism / fallback만 남긴다.
- 세부 절차, 검토축, cascade matrix, checklist는 canonical으로 이동한다.
- 이 전환은 scaffold output 구조를 바꾸므로 DR 뒤에 실행한다.

#### 3. Scaffold 모델 — 조건부 동의

"one-shot fork → tracked install" 진단에 동의한다.
현재 `adapt()`는 sed 치환 복사이고(`scripts/create-harness.sh:137-143`), target에는 harness version/manifest가 없다.
`--existing`도 기존 파일 skip 중심이라 framework layer의 drift를 보고하지 못한다.

다만 Claude가 3-way merge를 solo 단계에서 deferred로 둔 경계도 적절하다.
지금 바로 `--upgrade` 엔진을 만들면 문제 해결보다 merge policy 설계가 더 커진다.

권장 순서:

1. A/B layer 경계 결정
2. `.harness/manifest.json` 설계
3. `--check` drift report
4. 실제 target repo가 늘고 upgrade pain이 반복될 때 `--upgrade` 3-way merge 검토

추가 조건:

- manifest는 target-owned file과 framework-owned file을 명확히 구분해야 한다.
- sed 치환 후 hash 문제는 "정규화된 template hash" 또는 "rendered output hash" 중 하나를 결정해야 한다.
- source-only 문서 제외와 manifest 도입 순서가 충돌하지 않게 해야 한다. manifest가 추적할 framework file list는 slice 0의 산물이다.

#### 4. PLAN 진단 — 동의, 단 target harness customization 기록 위치는 미해결

Claude의 "죽음과 비대화가 같은 뿌리이고, 해법은 분할이 아니라 lifecycle 배선"이라는 진단에 동의한다.

근거:

- source `PLAN.md`는 `문서 버전 v0.1`, 작성일 2026-05-22 상태이며(`docs/PLAN.md:3-4`), Roadmap은 `AWH-003/004`에서 멈춰 있다(`docs/PLAN.md:112-119`).
- `HARNESS-PROTOCOL.md`에는 T5(PLAN 영향 결정)가 이미 있다(`docs/HARNESS-PROTOCOL.md:421-423`). 따라서 새 gate를 발명하기보다 T5를 `/close`, phase transition, commit finalization과 배선하는 것이 맞다.
- STATUS Recent Decisions는 rolling window 규칙이 있지만(`docs/HARNESS-PROTOCOL.md:496`), PLAN에는 archive drain이 없다.

합의안:

- generated repo에서 `PLAN.md` 작성 완료를 hard gate로 두지 않는다.
- `PLAN Impact`는 "새 gate"가 아니라 기존 T5 배선으로 재정의한다.
- PLAN은 current/future 중심으로 유지하고, 닫힌 phase 상세는 archive cascade로 배출한다.
- L3 근거는 PLAN에 계속 축적하지 않고 DR로 분리한다.

미해결:

- target `PLAN.md`가 product-only라면, target maintainer가 하네스 커스터마이징 방향을 어디에 기록할지 결정해야 한다.

#### 5. §7-e Codex Answers

**Q1. target `PLAN.md`를 product-only로 한정하면 harness 방향 계획처를 target에 둘 것인가, source 독점(A layer)으로 둘 것인가?**

조건부 답변: default target에서는 source 독점(A layer)을 기본값으로 두되, target-local harness customization이 실제로 발생하면 `docs/backlog/HARNESS.md`와 Work file에 기록하고, 반복·장기 방향이 생길 때만 `docs/HARNESS-PLAN.md` 같은 optional target-local plan을 둔다.

이유:

- 작은 target repo에서 product PLAN과 harness PLAN을 처음부터 둘로 나누면 파일 수가 늘고 둘 다 죽을 가능성이 높다.
- target의 하네스 변경은 대부분 project-specific adaptation이므로 Work/DR로 충분할 수 있다.
- 단, target이 자체 AI workflow를 적극 커스터마이징하는 repo가 되면 source 독점은 부족하다. 이때 optional local harness plan이 필요하다.

따라서 이 항목은 OQ로 유지한다.

**Q2. roadmap을 STATUS로 흡수하면 STATUS 비대 위험. 경량 `ROADMAP` 섹션/파일이 임계 규모에서 필요한가?**

답변: 지금은 별도 `ROADMAP` 파일을 만들지 않는다. PLAN의 Roadmap 섹션을 current/future horizon으로 유지하고, STATUS는 dashboard로만 둔다.

조건:

- roadmap 항목이 닫힌 phase 상세를 계속 보존하기 시작하면 archive cascade로 배출한다.
- roadmap이 여러 parallel horizon을 다뤄 PLAN을 압박하면 그때 `ROADMAP.md` 또는 `docs/roadmap/` 분리를 검토한다.

즉 임계 규모 전까지는 PLAN 내부 Roadmap + archive drain으로 충분하다.

**Q3. PLAN 시간축에 STATUS rolling-window를 복제할지, archive cascade(옵션 A)만으로 충분한지.**

답변: archive cascade(옵션 A)만으로 충분하다. STATUS의 rolling-window는 최근 의사결정 visibility를 위한 dashboard 제동이고, PLAN은 "현재와 미래 방향"의 계약이므로 같은 rolling-window를 복제하면 의미가 흐려진다.

대신 PLAN에는 다음 규칙이 필요하다.

- 현재 phase / 다음 horizon만 유지
- 닫힌 phase 상세는 archive로 이동
- PLAN에는 archived phase link 한 줄만 유지
- DR-worthy 근거는 DR로 이동

#### 6. Claude 근거에 대한 정밀화

대체로 동의하되 한 지점은 정밀화가 필요하다.

- `HARNESS-MAINTAINER-GUIDE.md`의 DR-020 참조와 `HARNESS-NAMING-RULES.md`의 DR-011 예시는 실제로 확인된다.
- `docs/decisions/README.md`가 scaffold에서 미복사되는 것도 확인된다.
- 다만 `WORKFLOW-MANUAL.md`의 DR-001은 현재 직접 깨진 링크라기보다 file naming 예시 또는 historical decision 언급에 가까워 보인다. 따라서 dangling reference 범위는 "DR-020/DR-011 확정, DR-001은 generated reference integrity test로 재확인"으로 표현하는 편이 정확하다.

#### 7. Updated Codex Position

Codex Initial Review 중 아래 항목을 수정한다.

- "scaffold output은 테스트 가능한 product"는 유지하되, **file-list 계약 테스트는 slice 0 이후**로 이동한다.
- "PLAN Impact 질문 추가"는 유지하지 않고, **기존 T5를 closeout/phase-transition에 배선**하는 것으로 수정한다.
- "default scaffold 축소"는 유지하되, 선행 작업은 **A/B boundary DR**이다.
- "Canonical+Adapter"는 채택 후보로 격상하되, full thin pointer가 아니라 hybrid adapter를 전제로 한다.

#### 8. §8 Re-Review (Q5) — Conditional Agreement

Claude Review Notes §8의 "User-facing ↔ canonical 양방향 참조 제거" 진단에는 조건부 동의한다.
실측 근거는 대체로 재현된다.

- `WORKFLOW-MANUAL.md`는 canonical 문서를 많이 참조한다. occurrence count 기준 `AGENT-WORKFLOW=24`, `HARNESS-PROTOCOL=24`, `BEHAVIOR-PRINCIPLES=16`, `HARNESS-QUICK-REFERENCE=10`이다.
- canonical 쪽도 `WORKFLOW-MANUAL.md`를 알고 있다. `docs/HARNESS-PROTOCOL.md:166`은 user-facing workflow 변경 또는 cascade 감사 시 manual을 로드하도록 하고, `docs/HARNESS-PROTOCOL.md:168`, `177`, `325`, `353`도 manual을 문서 지도/anti-pattern에 포함한다. `docs/AGENT-WORKFLOW.md:68`도 manual 로드 조건을 둔다.
- `SCAFFOLD-ONBOARDING-GUIDE.md`는 canonical 문서를 참조한다. occurrence count 기준 `AGENT-WORKFLOW=8`, `BEHAVIOR-PRINCIPLES=2`, `HARNESS-QUICK-REFERENCE=1`이다.
- 다만 "guide ↔ canonical"의 역방향은 정밀화가 필요하다. `SCAFFOLD-ONBOARDING-GUIDE.md`를 직접 참조하는 위치는 `docs/HARNESS-PROTOCOL.md`/`docs/AGENT-WORKFLOW.md`/`docs/BEHAVIOR-PRINCIPLES.md`/`docs/HARNESS-QUICK-REFERENCE.md`에서는 확인되지 않았고, `docs/HARNESS-ARCHITECTURE.md:59`, `142`, `docs/GIT-WORKFLOW.md:167`처럼 source/user-facing-adjacent 문서에서 확인된다. 따라서 guide 결합은 "canonical 양방향"보다는 "source docs graph의 user-facing guide 결합"으로 표현하는 편이 정확하다.

검토 초점별 판단:

1. **역방향 제거 — 조건부 동의.** canonical 문서가 user-facing manual/guide의 최신성을 직접 책임지면 SSoT 경계가 흐려진다. `docs/HARNESS-PROTOCOL.md:166` 같은 역참조는 Phase 2의 목표 상태에서는 제거하는 것이 맞다. 다만 즉시 제거만 하면 transition 중 user-facing 최신성 감사가 빠질 수 있다. 따라서 역방향 제거와 함께 user-facing slice의 acceptance criteria에 "manual/guide가 실행 규칙을 재서술하지 않는가", "사용자-visible workflow 변경만 manual에서 반영되는가"를 둬야 한다.
2. **정방향 decouple 정도 — 조건부 동의.** 정방향을 완전 0으로 강제하면 manual이 self-contained해지며 실행 규칙을 다시 쓰는 중복이 늘 수 있다. 적정선은 "단방향 위임만 유지"다. manual/guide는 사용자 흐름, 예시, WHY를 소유하고, 실행 규칙은 canonical 링크 1개 또는 섹션 단위 pointer로 위임한다. 참조 0은 소유 주제가 완전히 분리된 뒤 자연스럽게 도달할 수 있는 목표 상태이지, 첫 PR의 hard target은 아니다.
3. **메타 관찰 — 동의.** §5 mirror, §6 scaffold, §7 PLAN, §8 user-facing은 모두 "중복 생성 후 cross-reference로 봉합"이라는 같은 구조적 결함이다. Phase 2 통합 원칙은 "surface마다 SSoT 1개, 나머지는 thin·단방향"으로 묶는 것이 타당하다.
4. **Slice 배치 — 조건부 동의.** decoupling 원칙은 slice 0 방향 결정의 산물이어야 한다. 실제 manual/guide rewrite와 reverse-reference 제거는 별도 user-facing 정비 slice로 둔다. 이유는 source/target boundary, canonical+adapter 구조, scaffold default output이 정해져야 user-facing 문서가 무엇을 설명하고 무엇을 위임할지 결정되기 때문이다.

Codex 결론:

- §8은 Phase 2 핵심 원칙에 포함한다.
- `WORKFLOW-MANUAL.md`/`SCAFFOLD-ONBOARDING-GUIDE.md`는 canonical 실행 규칙을 재서술하지 않는 user-facing surface로 재정의한다.
- canonical 문서에서 manual/guide를 cascade 책임 대상으로 들고 있는 역참조는 제거 후보로 둔다.
- 단, 정방향 링크는 "중복 없는 단방향 위임"으로 남길 수 있으며, OQ-11에서 최종 decouple 정도를 결정한다.

#### 9. Declarative Procedure Vs Runtime Behavior (Claude Supplement)

Claude 보완 제안의 핵심 진단에 동의한다.
현재 문제는 "규칙이 문서에 없는 것"이 아니라, 문서의 권장 절차가 실제 command/skill 실행 행동으로 강제되지 않는다는 점이다.

확인 근거:

- `.claude/commands/close.md:49-52`와 `.agents/skills/workflow-close/SKILL.md:55-58`은 `/close`가 commit/PR finalization gate를 대체하지 않는다고 말한다.
- 하지만 바로 뒤 `.claude/commands/close.md:68-110`, `.agents/skills/workflow-close/SKILL.md:74-116`은 close 상태 변경을 amend로 번들할지 별도 close commit으로 분리할지 판단하는 긴 commit 전략 분기를 포함한다.
- `.claude/commands/close.md:79-80`, `.agents/skills/workflow-close/SKILL.md:85-86`은 branch가 `develop`/`main`이거나 확인 불가하면 **별도 close commit**으로 빠지는 fallback을 둔다.
- `docs/AGENT-WORKFLOW.md:152-158`은 STATUS/Tracking finalization을 실질 변경과 같은 commit에 포함하라고 이미 말한다. 즉 canonical 의도와 `/close` runtime guidance 사이에 tension이 있다.
- `.claude/commands/start.md:11`은 archive 대기 Work가 있으면 clean idle이 아니라고 판단한다. 이 역시 archive를 optional hygiene라기보다 미정리 부채처럼 보이게 만든다.

Codex 답변:

1. **옵션 A(`/close` commit-agnostic)를 선호한다.** `/close`는 Work Done state edit까지만 수행하고 commit 전략을 소유하지 않는 편이 가장 구조적이다. 그러면 "별도 close commit"을 만드는 책임이 `/close`에서 사라진다. 단, 상태 변경이 working tree에 남은 채 다음 작업과 섞이는 리스크가 있으므로 commit gate가 즉시 이어지는 정상 경로를 canonical로 둬야 한다.
2. **옵션 A만으로는 충분하지 않다.** commit gate에는 preflight hard-stop 또는 explicit override가 필요하다. 질문은 "이 변경이 직전 work의 causal finalization인가?"이고, 답이 yes이면 기본은 같은 commit에 bundling(amend 포함)이다. 별도 state-only commit은 PR opened/shared branch/이미 push된 공개 이력/사용자 명시 승인 같은 예외로 제한한다.
3. **preflight hard-stop은 manual-first와 충돌하지 않는다.** manual-first는 사람이 이해 가능한 절차를 문서화한다는 뜻이지, runtime에서 중요한 분기를 무시해도 된다는 뜻이 아니다. conditional mandatory gate를 action 직전에 표면화하는 것은 manual-first를 실제 행동으로 집행하는 보강이다.
4. **Gate strictness taxonomy는 2D여야 한다.** 기존 mandatory / conditional mandatory / recommended / optional hygiene는 강제 대상 축이다. 여기에 enforcement mode 축을 추가한다: `hard-stop`, `warning`, `report-only`, `silent`.
5. **archive는 on-demand hygiene으로 재정의한다.** 평시에는 silent 또는 누적 임계 초과 시 report-only가 적절하다. public release/clean baseline 같은 특정 gate에서만 conditional mandatory로 올린다.
6. **scope 변경 gate는 비대칭이어야 한다.** 확장은 승인 필요, 축소는 보고 중심, Done Criteria 축소는 품질 회피 가능성이 있으므로 별도 확인, split은 신규 Work/register 절차로 둔다.

2D taxonomy 예시:

| Item | Strictness | Enforcement Mode | Note |
| --- | --- | --- | --- |
| causal work finalization bundling | conditional mandatory | hard-stop / explicit override | Work 변경과 Work Done/STATUS/index finalization은 기본 같은 commit |
| archive cleanup | optional hygiene | silent 또는 threshold report-only | 평시 부채로 취급하지 않음 |
| public release gate | conditional mandatory | hard-stop | release/open 실행 직전만 강제 |
| clean baseline gate | conditional mandatory 또는 recommended | warning → release 직전 hard-stop 후보 | 평시 workflow 마찰을 피해야 함 |
| bootstrap completion | conditional mandatory | warning 또는 hard-stop | feature work 진입 조건과 project type에 따라 다름 |

결론:

- Phase 2의 Work lifecycle slice는 `/close`의 commit 책임 범위를 재설계해야 한다.
- Codex 1차 선호안은 **`/close` commit-agnostic + commit gate hard-stop/explicit override** 조합이다.
- 별도 close commit을 허용하더라도 default fallback이 되어서는 안 된다.
- command naming 변경은 breaking change로 다룬다. Phase 2에서는 legacy runtime alias를 유지하지 않는 방향을 기본값으로 두고, old -> new mapping은 migration note / release note에서만 설명한다.

#### 10. no-alias rename 전파 순서 + User-facing 대대적 개편 (Claude 보완 + 사용자 추가 범위)

**10-a. no-alias rename의 전파 순서 의존성 (Claude 보완, Codex 합의)**

legacy alias를 남기지 않기로 한 이상 command rename은 단순 naming cleanup이 아니라 이미 scaffold된 target과 active adoption repo의 workflow entrypoint를 깨는 breaking change다. 따라서 단독 선행을 금지하고 순서 제약을 둔다.

```text
A/B boundary + canonical+adapter 방향 결정 (slice 0)
  → tracked install / --check 최소 경로 설계 (Q4)
  → canonical+adapter 전환 + command rename을 같은 breaking slice로 적용 (§5)
  → scaffold target migration 검증
```

근거: §6에서 확인한 stale 문제(`harness-scaffold-lab`이 source 진화를 못 따라옴)가 그대로 재현된다. migration note(문서)는 필요조건이지 충분조건이 아니며, 최소한 `--check`로 "이 target이 어느 harness surface에서 drift났는지"를 보여주는 장치가 있어야 no-alias rename을 책임 있게 진행할 수 있다.

**cross-repo 책임 경계:** active target migration은 source repo Work가 직접 실행할 수 없다. source가 rename PR + `--check` + migration note를 **제공**하고, `ai-deck-compiler` 같은 active target은 자기 repo에서 **별도 migration Work로 수용**한다. 이는 Q4의 A/B layer(framework=source 소유, project state=target 소유)와 같은 선이다.

**10-b. User-facing 문서 대대적 개편 (사용자 추가 범위)**

Phase 2 리팩토링이 거의 모든 surface를 건드리므로, `README.md`를 시작점으로 `WORKFLOW-MANUAL.md`·`SCAFFOLD-ONBOARDING-GUIDE.md` 등 user-facing 문서를 전면 재작성한다.

- §8(user-facing decoupling)이 "무엇을 빼고 어디에 위임할지"를 정한다면, 10-b는 그 위에서 "남은 user-facing 문서를 새 output contract로 전면 재작성"하는 적용 작업이다.
- 진실 원천이 바뀐다: source/target boundary(Q4), canonical+adapter command(§5), gate taxonomy(§9), command rename(no alias)이 확정되면 README/manual/guide의 거의 모든 설명이 stale해진다. 부분 수정이 아니라 전면 개편이 필요한 이유다. README는 public front-door이자 adoption 진입점이므로 시작점으로 적절하다.
- **순서 제약(하류 작업):** boundary·canonical·gate·naming이 먼저 굳어야 user-facing 문서가 무엇을 설명할지 정해진다(§8-4 Codex 판단과 동일). 굳기 전 재작성을 시작하면 두 번 쓴다.
- **범위 주의:** `WORKFLOW-MANUAL.md`는 1790줄(§진단표 A)이다. 전면 재작성은 큰 작업이므로 별도 실행 Work로 분리하고, README → 핵심 흐름 → 상세 매뉴얼/가이드 순의 단계적 개편을 권한다.

### Open Questions

| ID | Question | Owner | Status |
| --- | --- | --- | --- |
| CHORE-20260604-001/OQ-1 | default scaffold에서 `docs/WORKFLOW-MANUAL.md`를 제외하고 source link로 대체할 것인가? | Codex + Claude | Open |
| CHORE-20260604-001/OQ-2 | `docs/`와 `harness/`를 물리적으로 분리할 가치가 있는가, 아니면 pack 분류만으로 충분한가? | Codex + Claude | Open |
| CHORE-20260604-001/OQ-3 | generated repo에 `PLAN.md` 작성 완료를 feature work의 hard gate로 둘 것인가? | Codex + Claude | Open |
| CHORE-20260604-001/OQ-4 | target repo 기본 prompts는 session-start 3종만 둘 것인가? | Codex + Claude | Open |
| CHORE-20260604-001/OQ-5 | source repo hook/CI enforcement를 scaffold target에 어떤 형태로 안내할 것인가? | Codex + Claude | Open |
| CHORE-20260604-001/OQ-6 | `public-release-playbook`를 source repo release gate에서 link만 할지, 요약 checklist를 둘지? | Codex + Claude | Open |
| CHORE-20260604-001/OQ-7 | target-local harness customization 방향 기록처를 Work/DR만으로 둘 것인가, optional `docs/HARNESS-PLAN.md`를 둘 것인가? | Codex + Claude | Open |
| CHORE-20260604-001/OQ-8 | Canonical+Adapter 전환 시 adapter에 남길 minimum hard-stop 절차의 범위는 어디까지인가? | Codex + Claude | Open |
| CHORE-20260604-001/OQ-9 | generated reference integrity test에서 dangling reference를 어떤 수준으로 판정할 것인가? direct link, filename mention, historical example을 구분해야 하는가? | Codex + Claude | Open |
| CHORE-20260604-001/OQ-10 | manifest hash 기준은 normalized template hash인가, rendered output hash인가? | Codex + Claude | Resolved — normalized source-template hash (단일 토큰 치환이라 project-agnostic). CHORE-20260605-006 R20, DR 신설 안 함 |
| CHORE-20260604-001/OQ-11 | user-facing manual/guide의 canonical 참조를 완전 0까지 줄일 것인가, 중복 없는 단방향 위임 pointer는 유지할 것인가? | Codex + Claude | Open |
| CHORE-20260604-001/OQ-12 | `/close`를 commit-agnostic Work Done state edit으로 제한할 것인가, commit 전략까지 소유하게 둘 것인가? | Codex + Claude | Open |
| CHORE-20260604-001/OQ-13 | causal finalization bundling을 commit gate의 conditional mandatory hard-stop으로 둘 것인가, warning/recommended로 둘 것인가? | Codex + Claude | Open |
| CHORE-20260604-001/OQ-14 | 별도 state-only close commit을 허용하는 예외 조건은 무엇인가? PR opened, shared branch, pushed history, 사용자 override를 어떻게 판정할 것인가? | Codex + Claude | Open |
| CHORE-20260604-001/OQ-15 | command naming을 session/work/repository-state 대상이 드러나게 변경할 때 legacy runtime alias를 유지하지 않는 breaking change로 진행할 것인가? migration note의 old -> new mapping 범위, 그리고 이 rename을 Q4 upgrade path(최소 `--check`)·§5 canonical+adapter 전환과 어떤 순서/묶음으로 진행할 것인가(단독 선행 금지)? | Codex + Claude | Open |
| CHORE-20260604-001/OQ-16 | archive pending을 clean idle 차단 조건에서 제외하고 on-demand hygiene으로 전환할 것인가? 누적 임계 report 기준은 무엇인가? | Codex + Claude | Open |
| CHORE-20260604-001/OQ-17 | active target migration strategy: no-alias rename 시 `ai-deck-compiler` 같은 active target을 어떻게 따라오게 할 것인가? source 제공분(rename PR, `--check`, migration note)과 target 책임분(자기 repo 별도 migration Work)의 경계는? | Codex + Claude | Open |
| CHORE-20260604-001/OQ-18 | user-facing 대대적 개편을 전면 일괄로 할 것인가 단계적(README → 흐름 → 상세)으로 할 것인가? 별도 실행 Work로 분리하는 기준과 boundary 확정 대비 착수 시점은? | Codex + Claude | Open |

### Decision Candidates

| Candidate | DR-worthy | Reason |
| --- | --- | --- |
| Source / scaffold target responsibility boundary | Yes | scaffold output, docs IA, command/skill policy에 광범위 영향 |
| Default scaffold pack 축소 | Yes | downstream generated surface의 breaking change 가능 |
| PLAN lifecycle gate 강화 | Yes | Work closeout, phase transition, bootstrap gate에 영향 |
| Scaffold onboarding lifecycle 재설계 | Yes | generated repo의 첫 operational flow, bootstrap cleanup, PLAN/STATUS/backlog fill order에 영향 |
| Work lifecycle and finalization semantics | Yes | scope 변경, commit/close/archive 경계, command naming에 광범위 영향 |
| Gate strictness taxonomy | Yes | archive/public release/clean baseline/bootstrap 같은 조건부 강제 gate가 평시 workflow에 새는 문제를 조정 |
| Commit gate runtime enforcement | Yes | 문서 권장과 실제 commit 행동의 괴리를 막기 위한 hard-stop/override 정책 |
| Command taxonomy rename without legacy aliases | Yes | session/work/repository-state 대상이 이름에 드러나도록 breaking change를 수용하고 runtime alias drift를 제거. Q4 upgrade·§5 canonical 전환과 동일 slice 전제 |
| User-facing documentation overhaul | Yes | README/manual/guide 전면 재작성. source/target·canonical·gate·naming 확정의 하류이며 adoption 표면 전체에 영향 |
| Git/release policy source-only boundary | Maybe | DR-017 / DR-020과 연결됨 |
| `public-release-playbook` external reference policy | Maybe | repo 간 책임 경계 결정 |

### Consensus Log

| Date | Topic | Consensus | Remaining Risk |
| --- | --- | --- | --- |
| 2026-06-04 | Slice priority | slice 0 방향 결정(A/B boundary, canonical workflow, gate 계층)과 PLAN lifecycle 복구가 1순위. 현존 결함 수선과 방향 불변 테스트만 병행 가능. | file-list/output-contract test를 너무 빨리 만들면 방향 결정 후 폐기될 수 있음 |
| 2026-06-04 | Source/target split | maintainer/manual 문서는 default scaffold에서 제외하고 source link 또는 optional pack으로 전환하는 방향에 잠정 합의. | beginner onboarding 설명 부족 가능성, OQ-1 최종 결정 필요 |
| 2026-06-04 | Physical `docs/` split | 현 단계 물리 이동은 보류. pack 논리 분류로 먼저 해결. | logical tag만으로도 source/target 혼선이 남으면 후속 물리 분리 재검토 |
| 2026-06-04 | PLAN lifecycle | `PLAN.md` hard gate 신설은 반대. 기존 T5를 `/close`, phase transition, commit finalization에 배선하고 archive drain으로 비대화를 막는 방향에 합의. | target-local harness customization 기록처 미정 |
| 2026-06-04 | Work lifecycle finalization | Work scope 축소/확장/split, 작업 commit과 state cleanup commit의 경계, command 이름의 대상 명확성을 Phase 2에서 재검토한다. | command rename 범위, migration note 범위, state-only follow-up commit 허용 조건 미정 |
| 2026-06-04 | Gate strictness | archive뿐 아니라 public release, clean baseline, bootstrap completion 등 강제성 있는 gate를 mandatory / conditional mandatory / recommended / optional hygiene로 재분류한다. | release safety를 낮추지 않으면서 평시 workflow 마찰을 줄이는 기준 필요 |
| 2026-06-04 | Runtime enforcement | 선언적 문서 권장만으로는 commit bundling 같은 중요 행동이 지켜지지 않는다. gate taxonomy에 enforcement mode(hard-stop/warning/report-only/silent)를 추가한다. | hard-stop 과다로 manual workflow가 뻣뻣해질 위험 |
| 2026-06-04 | `/close` commit responsibility | Codex 선호안은 `/close` commit-agnostic + commit gate hard-stop/explicit override 조합이다. close는 state edit, commit bundling 판단은 commit gate가 소유한다. | close 후 commit 전 다음 작업을 시작하면 working tree state가 섞일 수 있음 |
| 2026-06-04 | Command naming breaking change | 새 command taxonomy는 legacy runtime alias 없이 설계한다. old -> new mapping은 runtime surface가 아니라 migration note / release note에만 둔다. no-alias rename은 단독 선행 금지 — Q4 upgrade/`--check` 경로 위에서 §5 canonical+adapter 전환과 같은 breaking slice로 묶는다. | migration 안내(문서)만으로는 부족(§6 stale 재현 위험). Q4 `--check`/migration path 전제. `ai-deck-compiler` 등 active target은 자기 repo 별도 migration Work 필요(cross-repo 경계, OQ-17) |
| 2026-06-04 | User-facing documentation overhaul | Phase 2가 거의 모든 surface를 바꾸므로 README를 시작점으로 manual/guide를 전면 재작성한다. boundary·canonical·gate·naming 확정의 하류이며 별도 실행 Work로 분리한다. | 전면 vs 단계적 개편, 착수 시점(boundary 확정 대비), WORKFLOW-MANUAL 1790줄 재작성 규모(OQ-18) |
| 2026-06-04 | Canonical+Adapter | mirror 부피 해소책으로 채택 후보. 단 full thin pointer가 아니라 hard-stop을 adapter에 남기는 hybrid adapter 전제. | 자연어 로드 결정성, Cursor rule mechanism, scaffold breaking change |
| 2026-06-04 | Scaffold lifecycle | one-shot fork에서 tracked install로 가는 방향에 합의. manifest와 `--check`는 선행 후보, `--upgrade` 3-way merge는 pain이 반복될 때까지 deferred. | manifest hash 기준과 framework/state file 경계 미정 |
| 2026-06-04 | Scaffold onboarding lifecycle | scaffold 후 onboarding process를 Phase 2 리팩토링 대상에 포함한다. bootstrap fill order, cleanup/close, PLAN/STATUS/backlog 연결을 별도 slice에서 다룬다. | hard gate를 늘려 bootstrap 마찰을 키우지 않도록 soft/hard boundary 결정 필요 |
| 2026-06-04 | User-facing decoupling | user-facing manual/guide와 canonical 실행 규칙은 SSoT를 분리한다. 역방향(canonical → manual/guide) 참조는 제거 후보, 정방향은 중복 없는 단방향 위임만 유지하는 방향에 합의. | 정방향 참조를 0까지 줄일지, transition 중 user-facing freshness 감사를 어디에 둘지 미정 |
| 2026-06-04 | Public/open playbook | `public-release-playbook`는 link/reference로만 둔다. checklist 요약 복제는 drift surface가 되므로 보류. | source release gate와 external playbook 사이의 최소 pointer 위치 결정 필요 |

### Follow-Up PR Slicing Draft

초기 slicing 후보:

1. Inventory only: live docs/tool/scaffold surface 분류표 추가
2. Scaffold output contract: default/source-gitflow generated file matrix 정의
3. PLAN lifecycle: PLAN impact gate와 bootstrap hardening 설계
4. Scaffold onboarding lifecycle: bootstrap fill order, cleanup/close, PLAN/STATUS/backlog 연결 재설계
5. Work lifecycle and finalization semantics: scope 변경, commit/close/archive 경계, command naming 재설계(no legacy runtime alias). 설계 단계 — 실제 rename 적용은 slice 13(canonical+adapter 전환)과 같은 breaking slice로 결합
6. Commit gate runtime enforcement: causal finalization bundling hard-stop/override 설계
7. Gate strictness taxonomy: mandatory / conditional mandatory / recommended / optional hygiene × hard-stop/warning/report-only/silent 분류
8. Tool preflight: `/work`, `/close`, entrypoint Step 0 정렬
9. Scaffold minimal output: prompt/docs/source-only exclusion 1차 적용
10. Scaffold tests: generated file assertion과 leakage search 추가
11. User-facing 대대적 개편: README를 시작점으로 `WORKFLOW-MANUAL.md`·`SCAFFOLD-ONBOARDING-GUIDE.md` 전면 재작성(decoupling + 새 output contract). 규모가 크므로 별도 실행 Work로 분리, README → 핵심 흐름 → 상세 순 단계적 진행
12. Release/open boundary: `public-release-playbook` reference 반영
13. Canonical+adapter 전환 + command rename 동시 적용 (breaking; Q4 `--check` 경로 위에서만, 단독 선행 금지). slice 5 naming 설계의 실제 적용 단위
