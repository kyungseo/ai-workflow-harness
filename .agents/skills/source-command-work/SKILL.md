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

**2. troubleshooting 선행 확인**
다음 조건에 해당하면 `docs/troubleshooting/` 디렉토리를 확인해줘:
- 이전에 실패한 이력이 있는 작업
- 환경 설정, 인증, 외부 서비스 연동 관련 작업

**3. Risk Level 선언**
계획 제시 전에 이 작업의 Risk Level을 L1 / L2 / L3 중 하나로 선언해줘.

## Plan Format

계획은 아래 항목을 포함해줘.

1. 현재 상태 머신 단계 (INIT → PLAN)
2. Risk Level
3. 변경 범위 (Scope)
4. 변경 예정 파일 목록
5. 검증 방법
6. 리스크와 되돌리기 비용
7. docs/STATUS.md 반영 필요 여부

승인 전에는 수정하지 마.
