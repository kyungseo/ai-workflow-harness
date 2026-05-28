# HARNESS-PARALLEL-WORK-CONTROLS.md

병렬 branch/agent 운영 시 발생할 수 있는 충돌 유형별 manual-first 해소 runbook이다.
상시 로드 대상이 아니다. Work ID 충돌, STATUS/index merge conflict, DR 번호 충돌, command/skill mirror drift, scaffold drift window 판단이 필요할 때만 로드한다.

Work ID·DR ID 형식과 번호 재배정 핵심 규칙: `docs/HARNESS-NAMING-RULES.md`
commit/PR 전 Validation Checklist·Commit Approval: `docs/HARNESS-RECOVERY-VALIDATION.md`
Hard enforcement(CI/hook/script automation)는 이 문서 범위 밖이며, 실제 pain point 발생 시 별도 L3 Work로 등록한다.

> **적용 범위:** 이 문서는 source repo(Gitflow: `feature/* → develop → main`) 기준이다.
> Scaffold product repo는 project-specific `docs/GIT-WORKFLOW.md`가 이 규칙보다 우선한다.

---

## Work ID NNN 충돌 해소

`docs/HARNESS-NAMING-RULES.md` §NNN 재배정 절차를 따른다. 요약:

1. merge 대상 branch(`develop` 등)의 `docs/works/` 파일 목록 기준으로 다음 NNN을 결정한다.
2. 외부 참조(PR description, commit body)가 있으면 변경 비용을 보고하고 사용자 승인 후 조정한다.
3. Work 파일명·frontmatter `id`·STATUS pointer·Work index row를 새 NNN으로 일괄 업데이트한다.
4. 날짜(`<YYYYMMDD>`)는 착수/등록일 의미를 보존하므로 변경하지 않는다.

## STATUS.md Active Work 충돌 해소

두 feature branch가 각각 Active Work row를 추가하고 merge conflict가 발생한 경우:

1. 충돌한 STATUS.md Active Work 표를 Work 파일 frontmatter 기준으로 재구성한다.
2. `docs/works/{category}/` 하위의 `status: Active` Work 파일 목록을 기준으로 Active Work 표를 재작성한다.
3. 충돌을 일으킨 두 row는 모두 보존한다 (어느 쪽도 삭제하지 않는다).
4. Merge commit 후 STATUS.md Active Work 표가 실제 `docs/works/` Active 파일 목록과 일치하는지 확인한다.

## Work Index 충돌 해소

`docs/works/{category}/README.md` Active 테이블에 동시 row 추가 충돌이 발생한 경우:

1. STATUS.md 해소와 동일 원칙: 두 row 모두 보존.
2. `docs/works/{category}/` 실제 파일 목록을 기준으로 index를 재작성한다.
3. Work 파일 frontmatter `status`가 진실이다. index의 Active/Done/Archived 위치는 frontmatter 기준으로 조정한다.

## Command/Skill Mirror Atomicity

workflow command를 수정하는 Work의 CP 또는 commit에는 반드시 대응 skill을 함께 포함한다.

- `.claude/commands/{name}.md` 변경 → `.agents/skills/workflow-{name}/SKILL.md` 동일 CP/commit에 포함
- `.agents/skills/workflow-{name}/SKILL.md` 변경 → `.claude/commands/{name}.md` 동일 CP/commit에 포함
- mirror pair를 분리 commit해야 하는 경우, commit message에 `mirror pending: {pair}` 명시 후 즉시 후속 commit으로 완성한다.

## DR Global Sequence 충돌 해소

`docs/HARNESS-NAMING-RULES.md` §DR-ID 병렬 충돌 처리를 따른다. 요약:

1. 먼저 merge된 DR이 해당 번호를 유지한다.
2. 나중에 merge되는 DR은 번호를 재배정한다.
3. DR 파일명·문서 내부 DR 번호/상태 표기·연결 backlog·STATUS Recent Decisions·Work 파일 reference를 새 번호로 업데이트한다.
4. 외부 참조가 있으면 변경 비용을 보고하고 사용자 승인 후 조정한다.
