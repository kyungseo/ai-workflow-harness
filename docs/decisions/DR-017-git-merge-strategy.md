# DR-017: Git 머지 전략 및 Branch Flow 규칙

Date: 2026-05-20
Status: Accepted

## Question

feature→develop, develop→main 머지 전략을 어떻게 정하고, Branch Flow 절차를 AI 도구 instruction에 어떻게 포함할 것인가?

## Decision

**머지 전략:**
- feature → develop: Regular merge 기본. WIP 커밋이 많아 히스토리가 지저분할 때만 Squash 선택.
- develop → main: 항상 Merge commit (Regular merge).

**Branch Flow 규칙 포함 방식 (AI 도구 instruction):**
- `.claude/rules/git-workflow.md`, `AGENTS.md`, `.cursor/rules/workflow.mdc` 각각에 NEVER 가드레일만 인라인으로 유지.
- 상세 절차(SSoT)는 `docs/GIT-WORKFLOW.md` §2·§3에만 정의하고 rules 파일은 포인터로 참조.
- Flow 변경 시 `docs/GIT-WORKFLOW.md` 한 곳만 수정.

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| Regular merge 기본 (채택) | 커밋 히스토리 보존, bisect 가능, Conventional Commits 구조 유지 | WIP 커밋이 섞이면 히스토리 지저분 |
| Squash 고정 | develop 히스토리 깔끔 | 개별 커밋 추적 불가, feature 내 맥락 손실 |
| Rebase merge | 선형 히스토리 유지 | force-push 위험, 충돌 해결 복잡 |

| Branch Flow 포함 방식 | 장점 | 단점 |
|---|---|---|
| SSoT + 포인터 (채택) | 변경 시 1곳만 수정, DRY | merge intent 시 docs 파일 on-demand 로드 필요 |
| 전 파일 인라인 | 즉시 참조 | 4곳 중복, Flow 변경 시 전수 수정 필요 |

## Rationale

이 프로젝트는 Conventional Commits를 잘 준수하고 있어 feature 브랜치의 개별 커밋이 의미 있는 단위다. Squash로 일괄 압축하면 그 정보가 손실된다. Squash는 WIP 커밋이 많을 때의 선택적 도구로 남긴다.

develop→main은 Merge commit으로 feature 단위 커밋이 main에도 보존되도록 한다.

Branch Flow SSoT는 `docs/GIT-WORKFLOW.md`가 이미 상세 절차를 정의하고 있어 중복 없이 활용 가능하다. NEVER 가드레일만 rules 파일에 남겨 on-demand 로드 없이도 치명적 실수(직접 merge)를 방지한다.

## Consequences

- `.claude/rules/git-workflow.md` — Branch Flow 섹션: NEVER 가드레일 + docs/GIT-WORKFLOW.md 포인터
- `AGENTS.md`, `.cursor/rules/workflow.mdc` — 동일 구조 반영
- `docs/GIT-WORKFLOW.md` §2-3 — 머지 전략, Post-PR 절차, 다음 브랜치 제안 단계 포함
- PR 생성 시 커밋 구조를 보고 Regular merge/Squash 판단 (WIP 여부 기준)

## Reversal Cost

Low — `docs/GIT-WORKFLOW.md`와 rules 파일 수정만으로 전환 가능. 코드 변경 없음.

## Linked Backlog Items

- HRN-FUT-007: Branch Flow SSoT context 효율화 장기 검토
- DOC-001: `docs/GIT-WORKFLOW.md` 생성 (연계 문서)
