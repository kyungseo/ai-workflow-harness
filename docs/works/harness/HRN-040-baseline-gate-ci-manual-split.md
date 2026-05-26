---
id: HRN-040
priority: P1
status: Active
risk: L2
scope: Public Clean Baseline Gate 범위 명확화 — source/scaffold 분리, CI/manual split, hook applicability 정책
appetite: 1.5d
planned_start:
planned_end:
actual_end:
related_dr: []
related_commits: []
related_troubleshooting: []
---

# HRN-040: Public Clean Baseline Gate 범위 명확화 및 CI/Manual/Hook 분리

## Context

HRN-036에서 develop→main PR 전 Public Clean Baseline Gate를 도입했다.
이 gate는 `ai-workflow-harness` source repo를 public release snapshot으로 유지하기 위한 기준이다.

HRN-039(branch isolation enforcement) 완료 후 아래 두 가지 문제가 명확해졌다.

**Phrase leakage:** `docs/GIT-WORKFLOW.md` 자체는 scaffold에 복사되지 않지만, 이 파일을
참조하는 scaffold 복사 대상 파일 4개(`AGENTS.md`, `.claude/rules/git-workflow.md`,
`docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md`)에 "§3-1 Public Clean
Baseline Gate" 표현 및 `docs/GIT-WORKFLOW.md` load 지시가 잔류한다. product repo에서
정의 없는 문서를 load하라는 지시와 gate 정의 없는 참조가 함께 남는 상태.

**`docs/GIT-WORKFLOW.md` load 지시 문제 (OQ-1 즉시 결정):** `AGENTS.md`와
`.claude/rules/git-workflow.md`가 `docs/GIT-WORKFLOW.md`를 load하라고 지시하는데,
scaffold product repo에는 이 파일이 없다. 단순 phrase 제거로는 해결되지 않으며,
"해당 repo에 git workflow 문서가 있으면 따른다, 없으면 project-specific branch/release
policy를 먼저 확인한다"로 조건부 표현으로 변경해야 한다.

**Hook applicability 미명시:** `tools/git-hooks/pre-commit`은 scaffold 미복사이나,
scaffold product repo에 branch isolation hook을 적용해야 하는지 여부가 문서에 없다.

추가로 CI의 paths filter에 `tools/git-hooks/**`가 누락되어 있고,
CI/manual/hook 책임 경계 기준 문서도 없다.

## Problem Statement

| 문제 | 영향 |
| --- | --- |
| scaffold 복사 파일 4개(`AGENTS.md` 포함)에 source-only gate 참조 잔류 | product repo에서 gate 정의 없는 참조 발생 |
| `AGENTS.md`·`.claude/rules/git-workflow.md`가 없는 `docs/GIT-WORKFLOW.md` load 지시 | scaffold repo에서 존재하지 않는 문서 load 시도 |
| scaffold product repo hook 적용 여부 미명시 | product 개발 주 작업 repo에 harness hook 과도 적용 위험 |
| CI paths에 `tools/git-hooks/**` 누락 | hook 변경 시 CI 미트리거 |
| CI/manual/hook 책임 경계 미문서화 | gate 역할 중복·누락 위험 |
| source vs scaffold release gate 명칭 혼용 | product repo maintainer 혼란 |

## Goal

- `Public Clean Baseline Gate`를 source repo 전용으로 명확히 scope-qualify한다.
- scaffold 복사 파일 4개의 source-only phrase와 존재하지 않는 문서 load 지시를 조건부 표현으로 조정한다.
- `docs/GIT-WORKFLOW.md` load 지시를 "해당 repo에 git workflow 문서가 있으면 따른다, 없으면 project-specific policy 확인"으로 변경한다 (OQ-1 즉시 결정).
- scaffold phrase scan을 CI Required fail로 운영한다 (OQ-3 즉시 결정).
- CI Required / Human Review 항목을 분리하고 문서화한다.
- scaffold product repo hook 정책(기본 미포함 + optional 안내)을 명시한다.
- CI paths에 `tools/git-hooks/**` 추가 및 CI 보강 항목을 반영한다.

## Scope

### In Scope

- `AGENTS.md` — §3-1 참조 + `docs/GIT-WORKFLOW.md` load 지시를 조건부 표현으로 변경
- `.claude/rules/git-workflow.md` — 동일 조건부 표현 변경
- `docs/HARNESS-PROTOCOL.md` — §3-1 참조 scope-qualify; CI/manual/hook 책임 경계 단락 추가
- `docs/HARNESS-QUICK-REFERENCE.md` — §3-1 참조 scope-qualify
- `docs/GIT-WORKFLOW.md` — §6 hook 안내에 source repo 전용 명시
- `docs/HARNESS-MAINTAINER-GUIDE.md` — scaffold product repo hook 정책(기본 미포함 + optional install 안내) 추가
- `.github/workflows/ci.yml` — paths에 `tools/git-hooks/**` 추가; `git diff --check` step; scaffold phrase scan step (CI Required fail)

### Out Of Scope

- scaffold에 `docs/GIT-WORKFLOW.md` 자체 추가 여부 (OQ-1)
- product repo에 맞는 Project Baseline Gate 실제 정의 (product 별 자율)
- hook hard block 전환 (HRN-039 OQ-2 잔여)
- scaffold hook config 파라미터화 (OQ-2)

## Source vs Scaffold Gate 명명

| Gate 이름 | 적용 대상 | 위치 |
| --- | --- | --- |
| Public Clean Baseline Gate | `ai-workflow-harness` source repo | `docs/GIT-WORKFLOW.md` §3-1 — source only |
| Project Baseline / Release Criteria | scaffold product repo | product별 별도 정의 (BOOTSTRAP.md 등) |
| Bootstrap / Project Initialization Gate | scaffold 직후 no-git 초기 상태 | `docs/BOOTSTRAP.md` 기준 |

## CI / Human Review / Hook 책임 분리

### CI Required (자동 fail)

| 항목 | 현재 상태 |
| --- | --- |
| `bash -n scripts/create-harness.sh` | ✅ 기존 |
| scaffold dry-run | ✅ 기존 |
| stale runtime identity scan | ✅ 기존 |
| `git diff --check` | ❌ 추가 필요 |
| paths filter에 `tools/git-hooks/**` | ❌ 추가 필요 |

### CI Required (추가 — fail)

- generated temp scaffold content scan — `§3-1`, `Public Clean Baseline` 검출 시 CI fail. scan 대상은 실제 생성된 temp scaffold output이며 source docs 아님

### Human Review Checklist (PR body 기재)

- README 첫인상이 public user에게 자연스러운가
- Active Work 없음, Open Blocker 없음
- scaffold output에 source-only gate 문구가 없는가
- release에서 public baseline 선언 가능한가

## Hook Applicability 정책

| 대상 | 정책 |
| --- | --- |
| source repo | 현행 유지. branch isolation warning + shell syntax check |
| scaffold product repo | **기본 미포함**. hook install 안내 없음 |
| optional 안내 | `docs/HARNESS-MAINTAINER-GUIDE.md`에 "product-specific hook 커스텀 가이드" 추가 |
| scaffold no-git 초기 상태 | 현행: BRANCH="" fallback + AI rule Not Applicable ✅ 유지 |

미포함 이유:
- product repo lint/test/pre-commit stack과 충돌 위험
- protected files 목록이 harness source 전용 개념 (STATUS.md, AGENTS.md 등)
- product branch naming이 Gitflow와 다를 수 있음 (OQ-2)

## Applicable Surface

| 파일 | scaffold 복사 | 변경 내용 |
| --- | --- | --- |
| `AGENTS.md` | ✅ | §3-1 참조 + `docs/GIT-WORKFLOW.md` load 지시 → 조건부 표현으로 변경 |
| `.claude/rules/git-workflow.md` | ✅ | 동일 조건부 표현 변경 |
| `docs/HARNESS-PROTOCOL.md` | ✅ | §3-1 참조 scope-qualify; CI/manual/hook 경계 단락 추가 |
| `docs/HARNESS-QUICK-REFERENCE.md` | ✅ | §3-1 참조 scope-qualify |
| `docs/GIT-WORKFLOW.md` | ❌ | §6 hook 안내에 "source repo 전용" 명시 |
| `docs/HARNESS-MAINTAINER-GUIDE.md` | ✅ | scaffold hook 정책 + optional install 안내 추가 |
| `.github/workflows/ci.yml` | ❌ | paths 보강; `git diff --check`; scaffold phrase scan (CI Required fail) |

## Plan

### CP-1 — Phrase leakage 수정 + load 지시 조건부 변경 (scaffold 복사 파일 4개)

`AGENTS.md`, `.claude/rules/git-workflow.md` — `docs/GIT-WORKFLOW.md` load 지시를 조건부 표현으로 변경, §3-1 참조 제거.
`docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md` — §3-1 참조를 source-scope-qualified 표현으로 조정.

### CP-2 — Hook applicability 명시

`docs/GIT-WORKFLOW.md` §6에 "source repo 전용" 명시.
`docs/HARNESS-MAINTAINER-GUIDE.md`에 scaffold product repo hook 정책 추가.

### CP-3 — CI 보강

`.github/workflows/ci.yml`:
- `paths:` 에 `tools/git-hooks/**` 추가
- `git diff --check` step 추가
- generated temp scaffold content scan step 추가 (CI Required fail)

### CP-4 — HARNESS-PROTOCOL.md CI/manual/hook 책임 경계 단락

CI Required / CI Warning / Human Review 분류를 HARNESS-PROTOCOL.md에 단락으로 기술.

### CP-5 — Validation

```bash
# source 파일 scan (GIT-WORKFLOW.md, STATUS.md, archive, active Work 파일 외에 없어야 함)
rg "Public Clean Baseline|§3-1" AGENTS.md CLAUDE.md docs .claude .agents prompts scripts \
  | grep -v "archive\|GIT-WORKFLOW\.md\|STATUS\.md\|HRN-040"

# scaffold 실제 생성 후 content scan (--dry-run은 파일을 쓰지 않아 불가)
scripts/create-harness.sh --profile generic ci-phrase-check /tmp/ci-phrase-check
if rg "§3-1|Public Clean Baseline" /tmp/ci-phrase-check; then echo "FAIL: phrase found in scaffold output"; exit 1; fi
echo "OK: no phrase found"
rm -rf /tmp/ci-phrase-check

git diff --check
sh -n scripts/create-harness.sh
```

## Verification Scenarios

| # | 시나리오 | 기대 결과 |
| --- | --- | --- |
| V1 | source repo develop→main release | Public Clean Baseline Gate 전체 수행. CI Required 통과 + Human Review checklist 기재 |
| V2 | scaffold 직후 no-git repo | branch isolation Not Applicable. hook 설치 안내 없음 |
| V3 | generated temp scaffold content scan | "§3-1", "Public Clean Baseline" 없음 |
| V4 | CI path filter: `tools/git-hooks/pre-commit` 수정 | CI 트리거됨 |
| V5 | product repo release | source-only gate 참조 없음. Project Baseline/Release Criteria 적용 |

## Done Criteria

- [x] `AGENTS.md`의 `docs/GIT-WORKFLOW.md` load 지시 + §3-1 참조가 조건부 표현으로 변경됨.
- [x] `.claude/rules/git-workflow.md`의 `docs/GIT-WORKFLOW.md` load 지시 + §3-1 참조가 조건부 표현으로 변경됨.
- [x] `docs/HARNESS-PROTOCOL.md` §3-1 참조가 source-scope-qualified로 조정됨; CI/manual/hook 경계 단락 추가됨.
- [x] `docs/HARNESS-QUICK-REFERENCE.md` §3-1 참조가 source-scope-qualified로 조정됨.
- [x] `docs/GIT-WORKFLOW.md` §6 hook 안내에 source repo 전용 명시.
- [x] `docs/HARNESS-MAINTAINER-GUIDE.md`에 scaffold product repo hook 정책(기본 미포함 + optional install 안내) 추가 (§10 신설).
- [x] `.github/workflows/ci.yml` paths에 `tools/git-hooks/**` 추가.
- [x] CI에 `git diff-tree --check -r HEAD` step 추가.
- [x] CI에 scaffold output source-only phrase scan step 추가 (CI Required fail).
- [x] `rg "Public Clean Baseline|§3-1" AGENTS.md CLAUDE.md docs .claude .agents prompts scripts` 결과가 `docs/GIT-WORKFLOW.md`, `docs/STATUS.md`, archive 파일, `docs/works/harness/HRN-040-baseline-gate-ci-manual-split.md` 외에 없음 확인.
- [x] scaffold 실제 temp 생성 후 phrase 없음 확인. `rg "§3-1|Public Clean Baseline" /tmp/ci-phrase-check2` exit 1 (no match) 확인.
- [x] Verification 시나리오 V1–V5 통과.
- [x] `git diff --check`, `sh -n scripts/create-harness.sh` 통과.

## Open Questions

| ID | Question | Decision Needed |
| --- | --- | --- |
| OQ-1 | ~~scaffold output에 `docs/GIT-WORKFLOW.md` 자체를 추가해야 하는가?~~ **Decided:** 미복사 유지. 대신 load 지시를 "해당 repo에 git workflow 문서가 있으면 따른다, 없으면 project-specific branch/release policy를 먼저 확인한다"로 조건부 표현으로 변경. | Closed |
| OQ-2 | scaffold product repo에서 hook이 필요하면 어떤 형태로 제공하는가 — optional template, config-driven, 아니면 manual? | product 도입 사례 확보 후 결정 |
| OQ-3 | ~~CI warning/report-only 항목의 fail 기준: scaffold phrase scan은 warning으로 충분한가?~~ **Decided:** fail. deterministic leakage이므로 CI Required fail로 운영. scan 대상은 생성된 temp scaffold output. | Closed |

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| CP-1 | Phrase leakage 수정 + load 지시 조건부 변경 (scaffold 복사 파일 4개) | Pending |
| CP-2 | Hook applicability 명시 | Pending |
| CP-3 | CI 보강 | Pending |
| CP-4 | HARNESS-PROTOCOL.md CI/manual/hook 경계 단락 | Pending |
| CP-5 | Validation | Pending |

## Discovery

- 2026-05-26: HRN-039 완료 후 phrase leakage(scaffold 복사 파일 4개 — AGENTS.md 포함)와 hook applicability 미명시 문제 확인. CI paths `tools/git-hooks/**` 누락 병행 발견. OQ-1(GIT-WORKFLOW.md load 지시 조건부 변경)·OQ-3(phrase scan CI fail) 즉시 결정. HRN-040으로 등록.
