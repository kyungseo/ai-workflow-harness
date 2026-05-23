---
name: "source-command-work"
description: "backlog에서 지정 항목을 찾아 Work 파일 확인, Pre-check 3종, 계획 수립을 수행하고 승인 대기한다"
---

# source-command-work

Use this skill when the user asks to run the migrated source command `work`.

## Command Template

docs/STATUS.md를 확인한 뒤 $ARGUMENTS 항목을 진행할 backlog에서 찾아 계획을 세워줘.

- `P{n}-*`, `PRE-*`: docs/backlog/PHASE{n}.md
- `HRF-*`, `HRN-*`: docs/backlog/HARNESS.md
- 항목 위치가 불명확하면 두 backlog에서 ID만 검색하고, 관련 없는 상세는 읽지 마.

## Work File Check

작업 착수 전 `docs/works/{category}/` 에 해당 ID의 Work 파일이 있는지 확인해줘.

- **디렉토리 자체가 없으면**: 생성 계획에 `mkdir -p docs/works/{category}/` 포함.
- **Work 파일이 있으면**: 파일을 로드해 Plan, Done Criteria, Checkpoints를 계획에 반영해줘.
- **Work 파일이 없으면**: `docs/HARNESS-PROTOCOL.md` Work File Decomposition과 Quick Mode 기준을 확인해줘. Product track surface의 L1 Quick Mode에 해당하면 Work 파일 없이 진행하고, harness/workflow surface 변경 또는 Quick Mode 비대상이면 Work 파일 생성을 기본값으로 검토해 계획에 포함할지 판단해줘 (승인 후 생성).

Work 파일 생성 시 함께 수행할 것:
1. `docs/works/{category}/README.md`가 없으면 먼저 생성 (Active/Done/Archived 테이블 포함)
2. 착수 전 분해나 메모는 backlog 항목 또는 계획 제안에 남기고, Work 파일은 생성하지 않음
3. 사용자가 해당 Work 착수를 승인하면 Work 파일 frontmatter를 `status: Active`로 두고 README Active 테이블에 행 추가
4. State update: 대상 Work ID를 명시하고 STATUS.md Active Work에 포인터 추가 제안

## Pre-check (Before Planning)

**0. 기존 Active Work Discovery 확인**
STATUS.md에 이미 Active Work가 있으면:
- 해당 Work 파일의 Discovery 섹션에 현재 진행 상황이 기록되어 있는지 확인해줘.
- 미기록 상태(비어 있거나 "착수 후 기록" 상태)라면, 새 작업 계획 전에 사용자에게 기록을 요청해줘 (이때 기록 내용 제안 할 것).
- 사용자가 기록 불필요 확인 시 그대로 진행해줘.

**1. PLAN.md 강제 로드 조건 확인**
다음 중 하나라도 해당하면 반드시 docs/PLAN.md를 로드하고 계획에 반영해줘:
- 신규 서비스·모듈 생성
- Cross-service interaction 구현
- Infra·배포 방식 변경
- DB schema 변경

Harness 구조, command, rule, workflow protocol 변경이면 `docs/HARNESS-PROTOCOL.md`를 필요한 범위만 로드해줘.
완료된 harness refactor의 배경 근거가 필요하고 해당 파일이 실제 존재할 때만 `docs/archive/docs/HARNESS-REFACTOR-PLAN.md`를 참고해줘.
`HRN-*`, `PRE-*`, `DOC-*` 또는 계획·아이디어 성격이 강한 작업이면 `docs/retrospectives/`에서 최신/관련 회고 1개만 선택해 반복 리스크와 우선순위 근거를 확인해줘.

**2. Troubleshooting 관련 이슈 확인**
작업이 기존에 발생한 비자명 이슈(오류, 환경 설정 문제 등)와 관련된 경우 `docs/troubleshooting/`에 관련 기록이 있는지 확인해줘.
있으면 계획에 참조로 포함하고, 새로 해결된 이슈가 있으면 `/done` 시 기록을 제안해줘.

**3. Codex Rule Reference 확인**
Codex에는 `.claude/rules/*.md`와 같은 path-scoped 자동 rule 체계가 없으므로, 코드·문서·테스트·infra 파일을 수정할 계획이면 관련 rule을 수동 reference로 확인해줘.

- `.claude/rules/*.md`가 있으면 전체 내용을 일괄 로드하지 말고, 각 파일의 `paths` frontmatter 또는 제목만 보고 변경 대상 경로와 매칭되는 rule만 읽어.
- 매칭된 rule은 Claude command가 아니라 project-local guidance로만 적용해.
- 매칭 rule이 없으면 기존 코드 스타일과 `docs/AGENT-WORKFLOW.md` Verification Defaults를 기준으로 계획해.
- L1 Quick Mode라도 실제 수정 대상이 rule path와 매칭되면 해당 rule 확인 여부를 계획에 한 줄로 명시해.

**4. 위험도 판단**
작업을 아래 기준으로 분류하고 계획 서두에 선언해줘:
- **L1 (안전)**: Product track surface의 버그 수정, 테스트 코드, 문서 소폭 수정 → 계획 간소화, 승인 후 진행
- **L2 (일반)**: 일반 기능 구현, 설정 변경, harness/workflow surface 변경 → 계획 상세화, 승인 후 진행
- **L3 (구조 변경)**: 아키텍처·인증·인프라·DB schema 변경 → PLAN.md 로드 필수, 엄격 승인

## Plan Items

계획에는 반드시 아래 내용을 포함해줘.

1. 위험도: L1 / L2 / L3
2. 실행 모드: Quick Mode / Standard Work / Full Work
3. 현재 코드/문서에서 확인해야 할 파일
4. 구현 또는 문서 변경 범위
5. Done Criteria
6. Verification
7. 리스크와 되돌리기 비용
8. Codex rule reference 확인 결과: 매칭 rule 파일 또는 `Not Applicable`
9. docs/STATUS.md에 반영해야 할 상태 변경 제안
10. 상태 머신 단계: INIT / PLAN / APPROVAL / EXECUTE / VALIDATE / CHECKPOINT / END / FAIL / RECOVER

계획을 보고한 뒤 "진행할까요?"로 끝내고 승인 대기해줘.

docs/STATUS.md 변경은 즉시 수행하지 말고 Approval Matrix state rules에 맞게 먼저 제안해줘.
Active Work pointer 추가/제거는 대상 Work ID를 명시한 1줄 제안으로 충분하다.
Phase completion criteria, Current phase/focus, Recent Decisions 변경은 `STATUS Update Proposal`로 보고하고 변경 섹션, 변경 이유, 변경 후 상태, 되돌리기 비용을 포함해야 한다.
사용자가 명시적으로 승인한 뒤에만 STATUS.md를 수정해줘.

계획에 도구·아키텍처·정책 결정이 포함된 경우, 승인 후 구현 시작 전에 DR-worthy 결정 목록을 제시하고 기록 여부를 물어봐.
DR-worthy 기준: 도구/프레임워크 선택, 아키텍처 경계 정책, reversal cost Medium 이상, 복수 컴포넌트 영향.
