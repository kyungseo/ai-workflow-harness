---
id: HRN-031
priority: P2
status: Active
risk: Medium
scope: docs/WORKFLOW-MANUAL-SUMMARY.md removal, README/manual/protocol/CI/scaffold/cascade reference cleanup
appetite: 0.5d
planned_start: 2026-05-24
planned_end:
actual_end:
related_dr: [DR-013]
related_commits: []
related_troubleshooting: []
---

# HRN-031: Remove Redundant Workflow Manual Summary

## Context

`docs/WORKFLOW-MANUAL-SUMMARY.md`는 원래 `docs/WORKFLOW-MANUAL.md`의 condensed guide였지만,
현재 `README.md`가 public front-door와 summary 역할을 대부분 흡수했다.
`README.md`는 `WORKFLOW-MANUAL-SUMMARY-PUBLIC.md` 기반으로 재작성되었고,
live repository에는 `WORKFLOW-MANUAL-SUMMARY-PUBLIC.md`가 존재하지 않는다.

따라서 live user-facing summary 문서가 `README.md`와
`docs/WORKFLOW-MANUAL-SUMMARY.md`로 이중화되어 drift 비용이 생긴다.

단순 파일 삭제는 안전하지 않다.
현재 `scripts/create-harness.sh`, `.github/workflows/ci.yml`,
`docs/WORKFLOW-MANUAL.md`, `docs/HARNESS-PROTOCOL.md`,
`.claude/commands/health.md`, `.agents/skills/workflow-health/SKILL.md`,
`README.md`가 summary 문서를 live surface로 참조한다.
이 참조를 함께 정리하지 않으면 CI 실패, scaffold 실패, cascade guide drift가 발생할 수 있다.

## Impact Review

| Surface | Current Coupling | Risk If Only Deleted | Required Treatment |
| --- | --- | --- | --- |
| `docs/WORKFLOW-MANUAL-SUMMARY.md` | live condensed user-facing guide | 파일 삭제 자체는 가능하나 참조가 남으면 broken path 발생 | 삭제 |
| `README.md` | User-Facing References 표가 summary를 live doc으로 소개 | 공개 front-door가 제거 문서를 안내 | summary row 제거 또는 README가 summary 역할을 담당한다고 정리 |
| `docs/WORKFLOW-MANUAL.md` | 첫머리와 scaffold 포함 파일 표에서 summary를 안내 | manual 첫 reading path가 dead link가 됨 | quick path를 `README.md` 또는 `HARNESS-QUICK-REFERENCE.md`로 재지정 |
| `docs/HARNESS-PROTOCOL.md` | Document Lifecycle / Information Architecture에서 summary를 user-facing doc으로 분류 | protocol이 없는 문서를 live role로 유지 | user-facing workflow docs에서 summary 제거 |
| `.github/workflows/ci.yml` | stale runtime identity scan FILES에 summary 포함 | CI가 `expected path not found`로 실패 | FILES 배열에서 summary 제거 |
| `scripts/create-harness.sh` | source summary를 target으로 복사하고 generated README에 목록 표시 | scaffold 실행 중 source path 없음으로 실패 가능 | copy line과 generated README 목록 제거 |
| `.claude/commands/health.md` | scaffold cascade 확인 대상에 `WORKFLOW-MANUAL-SUMMARY*.md` 포함 | `/health --cascade`가 삭제 문서를 검사 대상으로 오인 | cascade row에서 summary 제거 |
| `.agents/skills/workflow-health/SKILL.md` | Codex health workflow가 동일 cascade 대상을 참조 | Codex `/health` 절차가 삭제 문서를 검사 대상으로 오인 | cascade row에서 summary 제거 |
| `.cursor/rules/*`, prompts | 직접 path 참조는 현재 없음 | 영향 낮음 | final `rg`로 재확인 |
| `docs/HARNESS-MAINTAINER-GUIDE.md` | `public summary` 표현으로 user-facing layer를 설명 | 삭제 후 summary 문서가 live 문서처럼 읽힐 수 있음 | `README.md` 역할로 명시할지 확인 후 정리 |
| Archive | `docs/archive/docs/WORKFLOW-MANUAL-SUMMARY-ai-workflow-v1.0.0.md` 존재 | historical traceability는 보존됨 | archive는 수정하지 않음 |

## Plan

### Step 1 - Live Reference Audit

- `rg -n "WORKFLOW-MANUAL-SUMMARY|WORKFLOW-MANUAL\\*|public summary"`로 live reference를 재확인한다.
- `docs/archive/` 아래 historical reference는 수정 대상에서 제외한다.
- `docs/STATUS.md` Recent Decisions의 `WORKFLOW-MANUAL-SUMMARY-PUBLIC.md` 언급은 historical decision record이므로 기본적으로 유지한다.
- `summary` 일반 단어는 fail 조건이 아니라 수동 검토 대상으로만 다룬다.

### Step 2 - Align CI, Scaffold, And Cascade References

- `.github/workflows/ci.yml` stale runtime identity scan의 `FILES` 배열에서 summary path를 제거한다.
- `scripts/create-harness.sh`에서 `docs/WORKFLOW-MANUAL-SUMMARY.md` 복사 라인을 제거한다.
- scaffold generated README의 파일 목록에서 summary row를 제거한다.
- `.claude/commands/health.md`와 `.agents/skills/workflow-health/SKILL.md`의 scaffold cascade 대상에서 `WORKFLOW-MANUAL-SUMMARY*.md`를 제거한다.

### Step 3 - Align User-Facing Documentation

- `README.md`에서 `docs/WORKFLOW-MANUAL-SUMMARY.md` live reference를 제거한다.
- `docs/WORKFLOW-MANUAL.md`의 quick reading path를 다음 원칙으로 조정한다.
  - 공개/빠른 개요: `README.md`
  - 세션 실행 quick reference: `docs/HARNESS-QUICK-REFERENCE.md`
  - 전체 사용자 매뉴얼: `docs/WORKFLOW-MANUAL.md`
- `docs/WORKFLOW-MANUAL.md`의 scaffold 포함 파일 표에서 `WORKFLOW-MANUAL-SUMMARY.md`를 제거한다.
- `docs/HARNESS-PROTOCOL.md`의 Document Lifecycle / Information Architecture에서 summary 문서 역할을 제거한다.
- `docs/HARNESS-MAINTAINER-GUIDE.md`의 `public summary` 표현이 삭제 후에도 의미가 맞는지 확인하고, 필요하면 `README.md` 역할로 명시한다.

### Step 4 - Remove Live Summary Document

- `docs/WORKFLOW-MANUAL-SUMMARY.md`를 삭제한다.
- archive snapshot은 유지한다.
- Step 2와 Step 3 변경, 파일 삭제는 하나의 implementation patch / commit 단위로 묶어 중간 상태에서 CI나 scaffold가 깨지지 않게 한다.

### Step 5 - Validate No Workflow Damage

- Shell syntax와 scaffold dry-run으로 삭제가 script 실행을 깨지 않는지 확인한다.
- Fresh scaffold 생성 결과에서 summary 파일이 생성되지 않고, generated README가 summary를 안내하지 않는지 확인한다.
- CI stale runtime identity scan과 동일한 expected-path check가 삭제 문서를 요구하지 않는지 확인한다.
- Live docs에 broken `WORKFLOW-MANUAL-SUMMARY` reference가 남지 않았는지 확인한다.

## Done Criteria

- [ ] `docs/WORKFLOW-MANUAL-SUMMARY.md`가 live docs에서 제거된다.
- [ ] `README.md`, `docs/WORKFLOW-MANUAL.md`, `docs/HARNESS-PROTOCOL.md`가 삭제 후 문서 계층을 일관되게 설명한다.
- [ ] `.github/workflows/ci.yml`이 삭제된 summary 파일을 expected path로 검사하지 않는다.
- [ ] `scripts/create-harness.sh`가 삭제된 summary 파일을 복사하지 않고, generated README에도 안내하지 않는다.
- [ ] `.claude/commands/health.md`와 `.agents/skills/workflow-health/SKILL.md` cascade 대상이 삭제 후 surface와 일치한다.
- [ ] `docs/HARNESS-MAINTAINER-GUIDE.md`의 `public summary` 표현이 README 역할과 충돌하지 않는다.
- [ ] `docs/archive/`의 historical summary snapshot은 보존된다.
- [ ] `rg` 확인 결과 live surface에 `WORKFLOW-MANUAL-SUMMARY` dead reference가 남지 않는다.
- [ ] 사용자 리뷰 후 `/close` 전 최종 검증 결과가 Work 파일에 반영된다.

## Verification

```bash
git diff --check
bash -n scripts/create-harness.sh
./scripts/create-harness.sh --dry-run --profile generic hrn-031-check /private/tmp/hrn-031-check
./scripts/create-harness.sh --profile generic hrn-031-check /private/tmp/hrn-031-check
test ! -e /private/tmp/hrn-031-check/docs/WORKFLOW-MANUAL-SUMMARY.md
rg -n "WORKFLOW-MANUAL-SUMMARY\\.md|WORKFLOW-MANUAL-SUMMARY\\*\\.md|WORKFLOW-MANUAL-SUMMARY-PUBLIC\\.md" \
  README.md docs scripts .github .claude .agents .cursor prompts AGENTS.md CLAUDE.md \
  -g '!docs/archive/**' -g '!docs/works/**'
rg -n "public summary" \
  README.md docs scripts .github .claude .agents .cursor prompts AGENTS.md CLAUDE.md \
  -g '!docs/archive/**' -g '!docs/works/**'
```

구현 완료 후 첫 번째 `rg` 예상 결과:

- `docs/WORKFLOW-MANUAL-SUMMARY.md` live path 참조 없음.
- `WORKFLOW-MANUAL-SUMMARY*.md` cascade 참조 없음.
- `WORKFLOW-MANUAL-SUMMARY-PUBLIC.md` 참조 중 `docs/STATUS.md` L51 Recent Decisions row 1건은 historical decision record이므로 의도적으로 유지. 그 외 참조 없음.

두 번째 `rg`의 `public summary` 결과는 fail 조건이 아니라 수동 검토 대상이다.
삭제 후 live 문서가 별도 summary 파일을 암시하지 않고 `README.md` 역할을 가리키면 통과로 본다.

temp scaffold 경로가 이미 존재하면 `/private/tmp/hrn-031-check-*` 형식의 새 경로를 사용하거나, 이 Work에서 생성한 것임을 확인한 후에만 해당 경로를 삭제한다.

## Risks

| Risk | Impact | Mitigation |
| --- | --- | --- |
| CI expected-path check가 삭제된 파일을 여전히 참조 | PR/push CI 실패 | `.github/workflows/ci.yml` 업데이트 후 동등한 local grep/path check 실행 |
| scaffold copy line이 삭제된 source를 참조 | `create-harness.sh` runtime 실패 | adapt line 제거 후 `bash -n`, dry-run, real generic scaffold 실행 |
| user-facing docs가 제거된 quick summary를 가리킴 | broken docs path, onboarding 혼란 | quick 개요는 `README.md`로, 실행 quick reference는 `HARNESS-QUICK-REFERENCE.md`로 재지정 |
| implementation 중간 상태에서 CI/scaffold가 깨짐 | partial patch 또는 중간 commit이 실패 상태를 남김 | CI/scaffold 참조 정리와 파일 삭제를 하나의 patch/commit 단위로 처리 |
| Codex health skill mirror 누락 | Claude `/health`와 Codex `workflow-health` 절차 drift | `.claude/commands/health.md`와 `.agents/skills/workflow-health/SKILL.md`를 함께 수정 |
| 검증 `rg`가 일반 `summary` 단어로 false positive 발생 | 정상 문맥을 실패로 오판 | dead path 검증과 일반 wording 수동 검토를 분리 |
| archive reference 실수로 편집 | historical record 왜곡 | `docs/archive/` 제외 조건 확인 외 수정 금지 |
| README 과부하 | 신규 사용자 condensed path 상실 | README는 public summary, `WORKFLOW-MANUAL.md`는 상세 가이드로 역할 유지 |

Reversal cost: Low to Medium.
파일은 git 또는 archived v1.0.0 snapshot에서 복구할 수 있지만, CI/scaffold/docs 전반의 참조를 함께 재도입해야 한다.

## Codex Rule Reference

- `.claude/rules/docs-workflow.md` — 이 Work가 `docs/**/*.md`, `.claude/**/*.md`, workflow 문서를 변경하므로 적용된다.
- `.claude/rules/git-workflow.md` — commit/PR로 진행될 경우에만 적용된다.
- 계획된 파일 범위에는 Java, 테스트, infra 관련 rule이 적용되지 않는다.

## STATUS Update Proposal

명시적 승인 없이 `docs/STATUS.md`를 수정하지 않는다.

이 계획이 승인된 후 제안하는 상태 변경:

> `docs/STATUS.md` Active Work에 HRN-031 pointer(`docs/works/harness/HRN-031-remove-workflow-manual-summary.md`)를 추가한다.

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| CP-1 | Impact review 및 Work plan 작성 | Done |
| CP-2 | 사용자 리뷰 및 scope 승인 | Todo |
| CP-3 | CI/scaffold/health cascade 정렬 | Todo |
| CP-4 | Summary 삭제 및 live reference 정리 | Todo |
| CP-5 | Verification 및 최종 검토 | Todo |

## Discovery

- `README.md`가 이미 public summary 역할을 흡수했고, `docs/WORKFLOW-MANUAL-SUMMARY-PUBLIC.md`는 live 파일이 아니다.
- `.github/workflows/ci.yml`은 현재 `docs/WORKFLOW-MANUAL-SUMMARY.md`를 expected live path로 검사한다. 삭제와 동일 구현에서 반드시 함께 수정해야 한다.
- `scripts/create-harness.sh`는 현재 `docs/WORKFLOW-MANUAL-SUMMARY.md`를 복사한다. script 정리 없이 source 파일을 삭제하면 scaffold가 실패한다.
- `docs/archive/docs/WORKFLOW-MANUAL-SUMMARY-ai-workflow-v1.0.0.md`가 v1.0.0 historical 버전을 보존하므로, live 삭제가 traceability를 제거하지 않는다.
- `.agents/skills/workflow-health/SKILL.md`도 `.claude/commands/health.md`와 같은 cascade 대상 문구를 갖고 있어 함께 정리해야 한다.
- `WORKFLOW-MANUAL-SUMMARY` dead path 검증과 `summary` 일반 단어 검토를 분리해야 false positive 없이 삭제 영향을 검증할 수 있다.

---

**Claude Code Review (2026-05-24)**

계획 검토 후 발견한 누락 및 리스크를 기록한다. 실행 전 반영 여부를 결정한다.

**[R-1] `.agents/skills/workflow-health/SKILL.md` 누락 — High**

Impact Review와 Step 4에 `.claude/commands/health.md`는 포함됐지만 `.agents/skills/workflow-health/SKILL.md` L239도 동일하게 `WORKFLOW-MANUAL-SUMMARY*.md` 패턴을 참조한다. Step 4 정리 대상과 Done Criteria에 명시적으로 추가해야 한다.

**[R-2] Step 실행 순서 리스크 — Medium**

현재 순서: Step 2(파일 삭제) → Step 4(CI/scaffold 수정). Step 2 실행 직후 Step 4 전 시점에서 scaffold가 실행되거나 CI가 돌면 즉시 실패한다. Step 4를 Step 2보다 먼저 수행하거나, 두 단계를 하나의 atomic commit으로 묶는 것을 권장한다.

**[R-3] `docs/WORKFLOW-MANUAL.md` L1446 누락 — Medium**

Step 3는 WORKFLOW-MANUAL.md L7(quick reading path)만 언급한다. L1446에도 scaffold copy 목록에 `WORKFLOW-MANUAL-SUMMARY.md`가 포함되어 있다. Step 3 또는 Step 4 처리 대상에 명시적으로 추가해야 한다.

**[R-4] 현재 세션에서 `ci.yml`이 이미 수정됨 — 참고**

이번 세션 commit `5341b71`에서 ci.yml stale check에 `docs/WORKFLOW-MANUAL-SUMMARY.md`를 파일 존재 검증 대상으로 추가했다. Step 4에서 이 항목을 FILES 배열에서 다시 제거해야 한다.

**[R-5] `HARNESS-MAINTAINER-GUIDE.md` 검사 조건 모호 — Low**

Step 3에 "필요 시 확인"으로 처리됐다. Step 1의 `rg` 대상에 명시적으로 포함시켜 결과에 따라 수정 여부를 결정하는 방식이 더 안전하다.
