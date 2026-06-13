---
policy_slice: recovery-validation
---

# HARNESS-RECOVERY-VALIDATION.md

`docs/HARNESS-PROTOCOL.md` §15에서 추출한 Recovery/Validation policy slice다.
failure state 진입, `/repo-health` 조건부 validation 확인, commit approval 판단 시에만 로드한다. `/session-start`, `/work-select`, 일반 `/work-plan`·`/work-close`·`/session-summary` 흐름에서는 로드하지 않는다.

**경계:** 이 파일은 **판단·정책(WHETHER/WHEN — 진행해도 되나)**이다. 검증을 실행할 **구체 명령 카탈로그(HOW)**는 source repo의 `docs/maintainer/VERIFICATION-COMMANDS.md`를 참조한다 (adopter repo에는 없을 수 있는 source-only 문서).

## Failure Conditions

- STATUS 불일치를 보고하지 않음
- 사용자 승인 없이 `docs/STATUS.md` 수정
- 승인 없이 구현
- 검증 실패 상태로 checkpoint 생성
- 작업 범위가 승인된 plan 밖으로 확장
- 동일 오류 2회 반복
- context limit 또는 정보 부족 상태에서 추측 진행
- `Done` 작업을 신규 작업 분리 없이 계속 수정
- 사용자 승인 없이 Work 파일을 `Archived`로 이동

## Recovery Flow

```text
FAIL -> report -> options -> user decision -> PLAN
```

Report includes:

- Failure type
- Root cause
- Affected files/state
- Recovery options
- Recommended path

## Validation Checklist

- 변경 파일이 plan 범위 안에 있는가
- 가장 좁은 검증을 실행했는가
- 검증을 못 했다면 이유를 기록했는가
- Work 파일 checkpoint/discovery 변경을 대상 Work ID와 함께 보고했는가
- Work 파일 Done 처리 또는 archive 이동에 사용자 확인이 있었는가
- `STATUS.md` 갱신이 필요한가
- `STATUS.md` 갱신이 필요하면 Approval Matrix에 맞는 제안과 사용자 승인이 있었는가
- commit/PR 전 STATUS Finalization 결과(`STATUS.md` 변경 필요 yes/no와 이유)를 보고했는가
- `docs/STATUS.md` 변경이 확정되었다면 실질 변경과 같은 commit에 포함되었는가 (실질 변경 commit 후 별도 STATUS commit 금지)
- commit/PR 전 Tracking Finalization 결과(backlog/Work/DR 변경 필요 yes/no와 이유)를 보고했는가
  - `docs/PLAN-SUMMARY.md`는 상태 필드를 갖지 않는다 — Tracking Finalization 확인 대상에서 제외.
  - Work ID collision 확인: 신규 Work ID가 target branch(프로젝트 통합/release branch; source repo에서는 develop/main)의 `docs/works/` 파일과 충돌하지 않는지 확인한다 (병렬 branch NNN 충돌 방지).
- DR/Work 파일/archive/cascade가 필요한가
- (source repo 전용 — adopter repo N/A) shipped 표면(core canonical·shipped DR seed·adapter/rule/prompt)에 `DR-NNN` 인용을 추가·변경했다면, 그 DR이 scaffold seed에 닫혀 있는가. seed 밖이면 canonical은 self-describe, DR 파일 lineage는 `Linked DRs:` frontmatter로 처리하고 `scripts/tests/check-shipped-dr-closure.sh`로 검증했는가 (HOW: `docs/maintainer/VERIFICATION-COMMANDS.md` Layer I)
- 다음 세션이 `STATUS.md`만 보고 재개 가능한가

## Commit Approval

git repository가 없는 bootstrap 초기 상태에서는 아래 git 명령 대신 `Not Applicable`로 보고하고, 문서/파일 검증만 진행한다.

develop → main release PR 생성 전에 `docs/GIT-WORKFLOW.md` §3 release gate를 수행한다 (source repo 전용). scaffold product repo는 project-specific release criteria를 따른다.

Commit 전:

1. `git status`
2. `git add <files>`
3. `git status`
4. `git diff --cached`

`VALIDATE` 실패 상태에서는 commit하지 않는다.
Commit 전 승인은 risk level과 무관하게 항상 별도로 받는다.

L3 이상 작업은 논리 단계별 commit을 기본값으로 한다.

- 한 commit은 하나의 검증 가능한 목적을 담는다.
- 대형 문서·하네스 변경은 상태판, backlog, command/rule, protocol, prompt 같은 변경 축을 가능한 한 분리한다.
- rollback plan은 파일 복구뿐 아니라 어떤 commit 또는 단계까지 되돌릴 수 있는지 설명한다.
- 여러 축을 하나의 commit에 묶어야 한다면 이유와 부분 rollback 비용을 종료 요약에 남긴다.

## CI / Manual / Hook 책임 경계

enforcement는 세 층으로 분리한다.

**CI Required — 기계 검증 (fail on violation):**

| 항목 | 명령 |
| --- | --- |
| Commit whitespace | `git diff-tree --check -r HEAD` |
| Scaffold shell syntax | `bash -n scripts/create-harness.sh` |
| Scaffold dry-run | `scripts/create-harness.sh --dry-run ...` |
| Scaffold phrase scan | temp 생성 후 source-only phrase 검출 시 fail — `.github/workflows/ci.yml` 참조 |
| Stale runtime identity | `grep -RInE 'Spring Boot ...'` live docs scan |

위 CI 명령의 상세·확장판(전체 Layer·release 전수 점검)은 `docs/maintainer/VERIFICATION-COMMANDS.md` Layer A 및 Release Full Sweep을 참조한다.

**Human Review Checklist — PR body 기재 (develop→main):**

- README 첫인상이 public user에게 자연스러운가
- Active Work 없음, Open Blocker 없음 (`docs/STATUS.md` 확인)
- scaffold output에 source-only gate 문구가 없는가
- release에서 public baseline 선언 가능한가

**Hook — local pre-commit warning (source repo 전용):**

`tools/git-hooks/pre-commit`은 harness source repo에서만 운영한다.
develop/main에서 protected files 직접 staged 시 WARNING 출력 (exit 0).
scaffold product repo에는 기본 미포함 — `docs/HARNESS-MAINTAINER-GUIDE.md` §10 참조.
