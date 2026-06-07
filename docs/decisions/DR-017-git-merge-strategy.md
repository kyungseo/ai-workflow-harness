# DR-017: Git 머지 전략 및 Branch Flow 규칙

Date: 2026-05-20
Status: Accepted (Amended 2026-06-07)

## Question

feature→develop, develop→main 머지 전략을 어떻게 정하고, Branch Flow 절차를 AI 도구 instruction에 어떻게 포함할 것인가?

## Decision

**머지 전략 (2026-06-07 Amended):**
- feature → develop: Squash merge 기본. work-close 단일 커밋 패턴과 일치하고 develop 히스토리를 기능 단위로 간결하게 유지한다. 커밋 단위 이력을 반드시 보존해야 할 경우에만 Regular merge를 예외 선택한다.
- develop → main: Regular Merge (Merge commit) 원칙. develop 브랜치의 커밋 히스토리와 feature 단위 커밋을 main에 보존한다. Fast-Forward가 가능하면 허용한다.

**Branch Flow 규칙 포함 방식 (AI 도구 instruction):**
- `.claude/rules/git-workflow.md`, `AGENTS.md`, `.cursor/rules/workflow.mdc` 각각에 NEVER 가드레일만 인라인으로 유지.
- 상세 절차(SSoT)는 `docs/GIT-WORKFLOW.md` §2·§3에만 정의하고 rules 파일은 포인터로 참조.
- 상세 Flow 변경 시 `docs/GIT-WORKFLOW.md`를 수정한다. 단, NEVER 가드레일의 의미가 바뀌면 tool surface cascade(`AGENTS.md`, `.claude/rules/git-workflow.md`, `.cursor/rules/workflow.mdc`)도 함께 확인한다.

## Amendment History

| Date | Change |
|------|--------|
| 2026-05-20 | 최초 결정: Regular merge 기본, Squash는 WIP 커밋 많을 때만 선택 |
| 2026-06-07 | feature→develop을 Squash 기본으로 변경. 실제 work-close 단일 커밋 패턴과 정합, 반복 squash 실수 교정, develop 히스토리 간결성 확보 |

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| Regular merge 기본 (원래 채택) | 커밋 히스토리 보존, bisect 가능 | WIP 커밋 섞이면 지저분; work-close 단일 커밋 패턴에서는 이점 없음 |
| Squash 기본 (현재 채택) | develop 히스토리 기능 단위 단일 커밋, work-close 패턴 일치 | 커밋 단위 추적 필요 시 예외 처리 필요 |
| Rebase merge | 선형 히스토리 유지 | force-push 위험, 충돌 해결 복잡 |

| Branch Flow 포함 방식 | 장점 | 단점 |
|---|---|---|
| SSoT + 포인터 (채택) | 변경 시 1곳만 수정, DRY | merge intent 시 docs 파일 on-demand 로드 필요 |
| 전 파일 인라인 | 즉시 참조 | 4곳 중복, Flow 변경 시 전수 수정 필요 |

## Rationale

work-close 절차가 정착되면서 feature 브랜치는 사실상 단일 커밋 구조가 됐다. 이 패턴에서 Regular merge와 Squash merge의 결과는 동일하지만, 의도를 명시적으로 Squash 기본으로 정렬하면 AI 도구가 `gh pr merge --squash`를 일관되게 선택하게 된다. Squash가 관례이지만 정책은 Regular merge라는 불일치가 반복적인 혼선을 만들었다.

develop→main은 Merge commit을 유지하여 feature 단위 커밋이 main에도 보존되도록 한다.

## Consequences

- `.claude/rules/git-workflow.md` — Post-PR Merge Cleanup: feature→develop은 `--squash`, develop→main은 `--merge`
- `AGENTS.md`, `.cursor/rules/workflow.mdc` — Branch Flow 포인터 유지 (가드레일 의미 변화 없음)
- `docs/GIT-WORKFLOW.md` §2·§3 — 머지 전략 수정 반영
- `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md` — 동일 반영
- `docs/decisions/DR-020-github-repo-settings.md` — Resolved 항목 정합 갱신

## Reversal Cost

Low — `docs/GIT-WORKFLOW.md`와 rules 파일 수정만으로 전환 가능. 코드 변경 없음.

## Linked Backlog Items

- HRN-FUT-007: Branch Flow SSoT context 효율화 장기 검토
- DOC-001: `docs/GIT-WORKFLOW.md` 생성 (연계 문서)
