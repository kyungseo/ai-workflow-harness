# work-close

Canonical workflow procedure for `/work-close`.

이 파일은 workflow 상세 절차의 SSoT다. Tool-specific surface는 아래 adapter만 가진다.

| Tool | Adapter |
| --- | --- |
| Claude Code | `.claude/commands/work-close.md` |
| Codex | `.agents/skills/workflow-work-close/SKILL.md` |
| Antigravity | Codex adapter 재사용: `.agents/skills/workflow-work-close/SKILL.md` |
| Cursor | `.cursor/rules/workflow.mdc` |

Adapter는 Step 0, hard-stop 요약, entry mechanism, fallback만 보유한다. 상세 절차, checklist, cascade 판단은 이 canonical 파일을 따른다.

## Procedure

**Work 완료 처리 명령이다. 세션을 종료하지 않는다.**

Work Done 처리가 끝나면 다음 작업을 계속 진행하면 된다.
세션 전체 요약이 필요하면 이후에 `/session-summary`을 실행한다.

## Work Done Processing

**1. 대상 Work 확인**

Active Work가 여러 개면 대상 Work ID를 먼저 확인한다. 하나뿐이면 그대로 진행한다.

**2. Done Criteria 확인**

Work 파일의 Done Criteria를 전부 체크했는지 확인한다.
미충족 항목이 있으면 다음 형식으로 별도 경고 블록을 출력하고, 이후 내용과 분리된 독립 단계로 진행 여부를 묻는다:

```
⚠️ Done Criteria 미완료 항목
- [ ] {항목 1}
- [ ] {항목 2}

위 항목이 완료되지 않았습니다. Done 처리를 계속하시겠습니까?
```

사용자가 명시적으로 계속을 확인한 뒤에만 3단계로 넘어간다.
Done Criteria에 사용자 최종 리뷰, final review, 검토 후 Done 같은 명시적 리뷰 조건이 있으면 해당 리뷰 확인을 완료하기 전 Done 처리하지 않는다.
전역 사용자 리뷰를 모든 Work에 강제하지 않는다.

**3. Work 파일 Done 처리 (Approval Matrix state detail — 사용자 확인 후)**

대상 Work ID를 명시하고 사용자 확인을 받은 뒤:

- Work 파일 frontmatter: `status: Done`, `actual_end: YYYY-MM-DD` 기입
- Done Criteria 항목을 전부 체크 표시로 업데이트

**4. Work Index 업데이트 (Work 파일 상태 변경)**

`docs/works/{category}/README.md`에서 해당 Work를 Active → Done (archive pending) 테이블로 이동한다.

**5. Backlog row 제거 (Work Done 처리와 동일 commit)**

해당 Work가 backlog 항목에서 착수된 경우, backlog에서 해당 항목을 제거한다.
`docs/backlog/HARNESS.md`와 `docs/backlog/PRODUCT.md`는 **2단 구조**를 사용하므로 두 위치를 모두 제거해야 한다:

1. **Summary 표**에서 해당 행 제거
2. **Details 섹션**에서 해당 `####` 블록 전체(헤더 + Task/Dependencies/Done Criteria/Verification 필드 + 구분선 `---`) 제거

두 위치 중 하나만 제거하면 broken reference 상태가 된다. backlog에서 착수된 항목이 아니면 이 단계를 건너뛴다.

**6. STATUS 영향 섹션 제안 (Approval Matrix state detail)**

대상 Work ID를 명시한 1줄 제안 후 승인을 받은 뒤 `docs/STATUS.md` Active Work 행을 제거한다.
Active Work pointer 제거 후, 이 Work 완료로 인해 Next Actions·Recent Decisions 등 관련 섹션이 stale해졌는지 함께 확인하고, 필요한 항목을 같은 STATUS update proposal에 포함한다.
Recent Decisions에 항목을 추가할 때는 최근 8개 rolling window를 유지한다. 초과분 제거 전 DR-worthy 항목이면 대응 DR 존재 여부를 확인한다.

**6b. PLAN impact 확인 (T5 — recommended/warning soft)**

Work closeout 시 이 Work의 결과가 `docs/PLAN.md`의 roadmap/milestone 방향에 영향을 주는지 판단한다.
영향 있음이면 PLAN 갱신/후속 작업을 Approval Matrix proposal로 제안하고, 없으면 보고만 한다.
PLAN 작성 완료를 Work Done의 hard-stop으로 강제하지 않는다. PLAN lifecycle/drain 규칙이 있으면 `docs/PLAN.md`의 Roadmap Lifecycle 규칙을 따른다.
PLAN 변경이 있거나 예상되면 `docs/PLAN-SUMMARY.md` stale 여부도 함께 판정한다. PLAN-SUMMARY는 PLAN/STATUS에서 파생된 derived summary이므로 자체 이력을 누적하지 않고 stale 확인만 수행한다.
archive 대기 Done Work가 여러 개 쌓여 있다면(5개 이상 기준), 이번 Work의 T5 판정과 별개로 PLAN 누적 드리프트 가능성을 함께 보고한다. 개별 T5가 "영향 없음"이었더라도 여러 Work 완료가 쌓이면 PLAN이 현실과 멀어질 수 있다.

**7. Commit/PR finalization 관계 확인**

`/work-close`는 Work Done 처리이며 commit/PR finalization gate를 대체하지 않는다.
이미 commit 또는 PR이 필요한 변경이 있으면 commit/PR 전 gate(`/session-summary` 또는 git workflow rule)에서 STATUS Finalization과 Tracking Finalization을 별도로 보고한다.

**[branch isolation 확인]** `docs/GIT-WORKFLOW.md`에 `policy_type: source-gitflow` marker가 있을 때만 활성화한다. marker가 없으면 이 단계를 건너뛰고 commit 전략 안내로 진행한다.

```bash
grep -q "policy_type: source-gitflow" docs/GIT-WORKFLOW.md 2>/dev/null || echo "generic mode — branch isolation 확인 건너뜀"
git branch --show-current
git diff --name-only --cached
```

source-gitflow marker 있는 경우:
- `develop` 또는 `main`에서 protected workflow 파일이 staged된 경우: 보고하고 `feature/*` branch 이동을 제안한다. Work Done 처리 자체는 계속 진행 가능하다.
- `feature/*` 또는 staged protected files 없음 → commit 전략 안내로 진행한다.
- merge commit (`.git/MERGE_HEAD` 존재) → 면제.
- git repository가 없는 초기 상태 → Not Applicable.

**[commit 전략 안내] close 상태 변경을 번들할지 별도 commit으로 분리할지 결정하기**

`/work-close`는 lifecycle finalization gate이며, commit 전략은 현재 branch context에 따라 아래 단계로 판단한다.

**단계 1: branch 확인**

```bash
git branch --show-current
git log develop..HEAD --oneline
```

- branch가 develop 또는 main → **별도 close commit** (현행 유지, 아래 단계 생략)
- branch 정보 확인 불가 → **별도 close commit** (아래 단계 생략)
- `feature/*` 패턴이고 `develop..HEAD`에 commit 있음 → 단계 2로

**단계 2: push 여부 확인**

```bash
git rev-parse --verify --quiet "origin/$(git branch --show-current)"
```

- 실패 (remote branch 없음) → **미push 확정** — 번들(amend) 권장
  - close state 변경(Work Done, Work Index, STATUS pointer)을 마지막 work commit에 포함할 것을 제안한다
  - 안내: "[권장] 마지막 work commit에 번들(git commit --amend) / [대안] 별도 close commit"
- 성공 (remote branch 있음, push 이력 있음) → 단계 3으로

**단계 3: PR 열림 여부 확인 (optional)**

gh CLI가 설치되어 있으면 시도한다. 실패는 validation failure가 아니다 — 감지 불가 fallback으로 처리한다.

```bash
gh pr list --head $(git branch --show-current) --state open 2>/dev/null
```

- PR 없음 (gh 성공, 결과 빈값) → **사용자 선택 유도**
  - 안내: "push되었으나 PR이 아직 없는 상태입니다. amend가 가능하나 신중하게 판단하세요. [선택] 번들(amend) / [기본] 별도 close commit"
- PR 있음 (gh 성공, PR 확인됨) → **별도 close commit 또는 squash merge 권장**
  - 안내: "PR이 열려 있습니다. --amend는 위험하므로 별도 close commit 또는 squash merge를 권장합니다."
- gh 실패/미설치 → **감지 불가 fallback**
  - 안내: "PR opened 여부를 확인할 수 없습니다. push 여부, PR 개설 여부, 공유 branch 여부를 직접 확인해 주세요."
  - 사용자가 "PR 없고 개인 branch"를 확인하면 번들 선택 가능; 확인 불가이거나 공유 상태면 별도 close commit 권장

"공유 branch" 여부는 git만으로 안정적으로 감지할 수 없으므로 사용자 확인 항목으로 다룬다.

---

## Archive Processing (Optional)

Done 처리 완료 후 아래 질문을 한다:

> 지금 바로 archive하겠습니까? (아니면 다음 `/session-start`·`/work-resume` 시 처리)

**사용자가 지금 archive 승인하면:**

1. Work 파일 frontmatter `status: Archived` 기입
2. Discovery에 archive 이유와 일자 기록
3. git repository가 없으면 `git mv` 대신 plain `mv` 또는 archive 보류를 제안한다. git repository가 있으면: `git mv docs/works/{category}/{file}.md docs/archive/docs/works/{category}/`
4. live `docs/works/{category}/README.md`에서 Done 행을 제거하고, archive-side `docs/archive/docs/works/{category}/README.md`의 Archived 인덱스에 Work 파일 경로(`docs/archive/docs/works/{category}/{file}.md`)를 추가한다. archive-side README가 없으면 이때 생성한다. **append 규율:** archive-side 인덱스가 큰 경우 전체를 읽지 말고 테이블 헤더 행을 anchor로 그 바로 다음에 prepend한다(최신이 위). 인덱스는 편의 도구이고 진실은 archive 파일 자체이므로, 인덱스가 비대해지면 `ls`·`grep`으로 조회 가능하다.

**사용자가 나중으로 미루면:** 그대로 둔다. `/session-start`·`/work-resume`에서 archive 대기로 보고된다.

---

## Completion Report

Done 처리 후 아래 형식으로 보고하고 세션을 계속한다.

```
Work Done 완료: {Work ID}

- 대상 Work: {ID}
- Done 처리: status: Done, actual_end: {날짜}
- Archive: {지금 처리 / 보류}
- STATUS.md: Active Work {ID} pointer 제거 {승인 대기 / 완료}
- Commit/PR Finalization: 별도 gate에서 STATUS/Tracking 확인 {필요 / 해당 없음}
```
