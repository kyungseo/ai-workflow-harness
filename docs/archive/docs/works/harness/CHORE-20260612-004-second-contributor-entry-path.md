---
id: CHORE-20260612-004
priority: P1
status: Archived
risk: L2
scope: CHORE-20260612-003 G1/G2 Critical gap 보강. scaffold target README.md에 clone 시나리오용 GIT-WORKFLOW §0-1 포인터를 추가하고, GIT-WORKFLOW.md §0-1에 "Clone from existing remote" 하위 절을 추가한다. 변경은 scaffold template/script에만 적용하며, 기존 scaffolded repo 소급 수정은 범위 밖이다.
appetite: 0.5d
planned_start: 2026-06-12
planned_end: 2026-06-12
actual_end: 2026-06-12
related_dr: [DR-020, DR-021]
related_work: [CHORE-20260612-003, CHORE-20260606-008, CHORE-20260606-011]
---

# CHORE-20260612-004: Source-Gitflow Second-Contributor Entry Path 보강

## Top Summary

- **목표:** CHORE-20260612-003에서 발견한 두 가지 Critical gap을 닫는다. second-contributor가 `README.md`만 보고 `sh tools/git-hooks/install.sh` 경로를 찾을 수 있어야 하고, `GIT-WORKFLOW.md §0-1`에 clone 경로가 명확히 분리되어야 한다.
- **왜 지금:** W2 Adopter Transition의 직접 후속. 외부 contributor 온보딩 friction을 evidence 기반으로 즉시 닫을 수 있는 small-scope 항목이다.
- **핵심 경계:** scaffold template 파일 2곳만 변경한다 — `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md`, `scripts/create-harness.sh` (README write_text 블록). 기존 scaffolded repo 소급 적용 없음. generic target 변경 없음.

## Background / Facts

- **G1 (entry-path discoverability failure):** source-gitflow scaffold target README.md "사전 작업" 섹션이 초기 설정(`docs/BOOTSTRAP.md §0`)만 안내하고 clone 시나리오를 가리키지 않음. 설계 의도는 "hook guidance는 GIT-WORKFLOW.md로 위임"이었으나 clone 진입로가 README에서 끊김.
- **G2 (Clone 경로 부재):** `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md §0-1`에 "Fresh repo"(초기 설정자)와 "Existing repo"(overlay 적용자) 분기만 있고 "Clone from existing remote"(두 번째 contributor) 경로가 없음. "Existing repo"는 이미 local repo 안에 있다는 전제로 시작해 clone 진입 경로와 맥락이 다름.
- **설계 방향:** README는 GIT-WORKFLOW.md를 권위로 유지한다(기존 설계 존중). README에서 hook install 명령을 직접 복제하지 않고 — drift surface 증가 방지 — clone 시나리오에서 GIT-WORKFLOW §0-1을 읽으라는 분기형 pointer로 명확히 갈라준다. 실제 명령은 GIT-WORKFLOW §0-1 "Clone from existing remote" 절이 담당한다.
- **CHORE-20260612-003 검증 한계:** "bootstrap 완료 후 later-contributor clone" 시나리오는 이번 변경으로 커버 가능하지만 검증 없이 "자연스럽게 커버"로 단정하지 않는다. Done Criteria에 명시적 확인 단계를 포함한다.

## Scope / Plan

> 구현 전 Codex R0 plan review 대상.

### 변경 파일

| 파일 | 변경 내용 |
| --- | --- |
| `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md` | §0-1에 "### Clone from existing remote" 하위 절 추가 (Existing repo 이후, GitHub Ruleset 이전) |
| `scripts/create-harness.sh` | README write_text 블록 "사전 작업" 섹션에 clone 시나리오 → GIT-WORKFLOW §0-1 pointer 1줄 추가 |

### 변경 상세

**GIT-WORKFLOW.md 추가 내용 (§0-1, Existing repo 다음):**

```markdown
### Clone from existing remote

이미 remote repository가 있고 두 번째 contributor로 참여하는 경우에 사용하는 경로다.

```bash
git clone <git-url>
cd <repo-name>
sh tools/git-hooks/install.sh
```

- `tools/git-hooks/install.sh`는 pre-commit·commit-msg hook을 `.git/hooks/`에 설치한다.
- 설치하지 않으면 commit message 형식 강제가 동작하지 않는다.
- branch/release 정책과 PR 절차는 §1·§2를 확인한다.
```

**README write_text 블록 변경 (create-harness.sh, 사전 작업 섹션):**

현재 단일 문장("git repository는 자동으로 초기화되지 않는다. 첫 세션에서 `docs/BOOTSTRAP.md` §0 ...")을 source-gitflow일 때 **두 경로를 명시적으로 분기**하는 형태로 교체한다:

```
- 최초 설정 (git repository 미초기화): 첫 세션에서 \`docs/BOOTSTRAP.md\` §0 Repository Setup을 따라 초기화 여부를 먼저 결정한다.
- 이미 존재하는 repo에 추가 contributor로 합류: \`docs/GIT-WORKFLOW.md §0-1\` Clone 경로를 먼저 확인한다.
```

`ENFORCEMENT_NOTE`와 혼재되지 않도록 source-gitflow 전용 조건 블록(`CLONE_NOTE`)으로 분리하고, generic workflow에는 이 분기를 추가하지 않는다.

### 실행 단계

1. **Codex R0 plan review** — 방향·범위·변경 최소성 red team 검토
2. **template 변경**: `GIT-WORKFLOW.md §0-1`에 Clone 절 추가
3. **script 변경**: `create-harness.sh` README 블록에 clone pointer 추가
4. **검증**: `bash -n scripts/create-harness.sh` + temp/ re-scaffold + blind onboarding pass 재현
5. **Codex R1 result review**
6. **work-close + PR**

### 파일 범위

| 파일 | 역할 |
| --- | --- |
| `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md` | 변경 대상 (template) |
| `scripts/create-harness.sh` | 변경 대상 (README 생성 블록) |
| `temp/harness-tests/clone-vfy-004-*/` | 검증용 — cleanup 대상 |
| 이 Work 파일 | SSoT |
| `docs/STATUS.md` | Active Work pointer |

**수정하지 않는 파일**: 기존 scaffolded repo의 GIT-WORKFLOW.md, README.md 일체

## Done Criteria

- [x] `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md §0-1`에 "Clone from existing remote" 절 추가
- [x] `scripts/create-harness.sh` README source-gitflow 섹션에 bootstrap vs later-contributor 분기형 pointer 추가
- [x] re-scaffold 후 blank-state 재현: README만 보고 clone 시나리오 → hook install 경로 발견 가능
- [x] later-contributor 경로 추적: README 분기 → GIT-WORKFLOW §0-1 Clone 절 → `sh tools/git-hooks/install.sh` 흐름이 BOOTSTRAP.md 없이도 완결됨을 확인 (grep 기반 trace 완료, install.sh PRESENT)
- [x] `bash -n scripts/create-harness.sh` 통과
- [x] `bash scripts/tests/check-shipped-dr-closure.sh` 통과 (pre-commit gate)
- [x] Codex R0 + R1 review 완료, review 결과 Round Log에 기록

## Round Log

### R0 — Plan Review (Codex, 2026-06-12)

> 리뷰 지침:
> - 내적 정합성에 그치지 말고, 방향 자체가 정당한지 red team 시각으로 검토한다.
> - "README에 pointer 1줄 추가 + GIT-WORKFLOW에 Clone 절 추가"가 G1/G2를 닫기에 충분한가?
> - 기존 설계(hook guidance는 GIT-WORKFLOW로 위임)를 존중하는 접근이 맞는가, 아니면 README에서 더 직접적으로 안내해야 하는가?
> - 변경 범위가 적정한가? 빠진 surface나 불필요한 추가가 있는가?

**Review 결과:** Conditional hold.
- 2파일 범위 적정. GIT-WORKFLOW.md 위임 설계 유지 방향 수용.
- **필수 변경 1:** README pointer가 bootstrap 보조 문장(supplementary line)이 아니라 명시적 분기형(path fork)이어야 함. "이 repo를 새로 부팅하는 첫 maintainer는 BOOTSTRAP.md, 이미 존재하는 source-gitflow repo에 추가 contributor로 합류하는 경우는 GIT-WORKFLOW §0-1 Clone 경로를 먼저 확인한다." 수준의 명시성 요구.
- **필수 변경 2:** Background의 "bootstrap 완료 후 later-contributor도 자연스럽게 커버" 문구가 검증 없이 강함. 검증에 명시적 later-contributor 시나리오를 추가하거나 claim을 약화해야 함.

**수용/반영 내용:**
- 필수 변경 1 수용: README "사전 작업" 섹션을 bootstrap vs later-contributor 분기형으로 교체 (CLONE_NOTE 변수로 source-gitflow 전용 분기)
- 필수 변경 2: "자연스럽게 커버" claim 약화 + Done Criteria에 later-contributor 경로 추적 검증 단계 명시적 추가

---

### R1 — Result Review (Codex, 2026-06-12)

**Review 결과:** Approved. Blocking finding 없음. README가 bootstrap vs later-contributor 분기형으로 바뀌었고, GIT-WORKFLOW §0-1에 Clone 절이 추가되어 G1/G2를 실질적으로 닫음. generic/source-gitflow 분기도 생성 결과에서 의도대로 확인됨.

**Residual risk:** 기존 scaffolded repo는 소급 수정되지 않음 — 범위상 허용된 한계(Work file line 21에 명시).

**수용/반영 내용:** Required changes 없음. 범위 내 완료.
