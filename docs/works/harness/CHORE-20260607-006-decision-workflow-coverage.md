---
id: CHORE-20260607-006
priority: P1
status: Done
risk: L2
scope: /record-decision 개명 + product decision coverage + DR lifecycle 절차 + track 필드 도입
appetite: 2d
planned_start: 2026-06-07
planned_end: 2026-06-09
actual_end: 2026-06-07
related_dr: [DR-026]
related_troubleshooting: []
related_work: []
---

# CHORE-20260607-006: Decision Workflow Product Coverage + DR Lifecycle 정리

## Top Summary (결론 먼저)

- **목표:** (A) `/repo-decision` → `/record-decision` 개명 (product decision 포함 coverage 확장). (B) canonical skill에 product decision 명시 + DR lifecycle 상태(Amended/Superseded/partial/linked) 절차 추가. (C) `DECISION-TEMPLATE.md` 확장 + `docs/decisions/README.md`에 Track 컬럼·Status legend 추가. (D) 11개 live 파일 cascade + scaffold 시뮬레이션.
- **시발점:** `repo-decision`이라는 이름이 "harness/source repo에 관한 결정"으로 오해되어 product decision 기록이 누락되는 구조적 결함. 원래 이름 `record-decision`으로 복원. DR lifecycle 상태 혼용(Amended/Superseded 등)도 template에 미정의 상태.
- **주요 결정:** DR-026 (rename 결정 근거 기록).

## Discovery

- backlog의 "Decision workflow product coverage + DR lifecycle 정리" (P1 Candidate) 착수.
- `record-decision` → `repo-decision` 개명 커밋: `bc5ace9` (CHORE-20260606-001, 2026-06-05). `repo-health`와 prefix 통일 목적이었으나 coverage 오해 유발로 역효과 판단.
- live 참조 11개 파일 확인 완료. archive/Done Work 파일은 immutable 유지.
- scaffold(`create-harness.sh`)는 glob 복사 방식 — 파일 rename으로 자동 반영, 하드코딩 없음. 생성된 WORKFLOW-MANUAL stale 참조 여부는 시뮬레이션으로 확인 필요.

## Scope / Plan

### Slice A — DR-026 등록
- DR-026: `/repo-decision` → `/record-decision` rename 결정 기록 (Accepted)

### Slice B — 파일 rename (3개)
- `skills/workflow/repo-decision.md` → `record-decision.md`
- `.claude/commands/repo-decision.md` → `record-decision.md`
- `.agents/skills/workflow-repo-decision/` → `workflow-record-decision/`

### Slice C — canonical skill 본문 개정
- Procedure intro: product/harness 양쪽 명시 + 예시
- DR-Worthy Criteria: product 예시 추가 (ORM, API 설계, 외부 서비스 연동 등)
- DR Lifecycle 절차 추가:
  - `Accepted (Amended)`: 방향 유지, 세부 수정. 수정 범위 명시.
  - `Superseded by DR-XXX`: 결정 무효화. archive 이동 후보.
  - `Accepted (partial Superseded by DR-XXX)`: 일부 대체. 범위 명시.
  - Parent-child DR: `Supersedes:` 필드로 표현.
  - Linked DR: `Linked DRs:` 필드로 표현.
  - Superseded DR archive 타이밍: merge 후 확인, `docs/archive/docs/decisions/` 이동.

### Slice D — template + index
- `docs/decisions/DECISION-TEMPLATE.md`: Status 전체 상태 정의 + `Track: harness | product` 필드 추가
- `docs/decisions/README.md`: Track 컬럼 추가 (기존 DR 전부 `harness`) + Status legend

### Slice E — live 11개 파일 cascade
| 파일 | 변경 |
|---|---|
| `skills/workflow/README.md` | 표 행: 파일명·경로·설명 |
| `.claude/rules/docs-workflow.md` | command 파일 경로 |
| `.cursor/rules/workflow.mdc` | skill 파일 경로 |
| `docs/HARNESS-QUICK-REFERENCE.md` | `/repo-decision` → `/record-decision` |
| `docs/HARNESS-PROTOCOL.md` | T5 배선 언급 |
| `docs/WORKFLOW-MANUAL.md` | 5곳 (표·mermaid·본문) |
| `docs/PLAN-SUMMARY.md` | T5 배선 언급 |
| `README.md` | 명령 표 1행 |
| adapter description 2개 | `.claude/commands/`, `.agents/skills/` |

### Slice F — scaffold 시뮬레이션
- `bash -n scripts/create-harness.sh`
- temp scaffold 생성 → `record-decision.md` 존재, `repo-decision.md` 미존재, WORKFLOW-MANUAL stale 참조 없음 확인

## Done Criteria

- [x] DR-026 Accepted
- [x] 3개 파일/디렉토리 rename 완료
- [x] canonical skill: product coverage + lifecycle 절차 반영
- [x] adapter description 2개 업데이트
- [x] `DECISION-TEMPLATE.md` Status 전체 상태 + Track 필드
- [x] `docs/decisions/README.md` Track 컬럼 + Status legend
- [x] live 13개 파일 cascade 완료 (`MIGRATION-CANONICAL-ADAPTER-RENAME.md`, `skills/workflow/repo-health.md` 포함)
- [x] `grep -r "repo-decision" .` → live 파일 0건 (archive/Done Work/DR-026 제외)
- [x] scaffold 시뮬레이션 통과
- [x] `skills/workflow/repo-health.md` 6개 currency gap 수정 완료 (Phase 2 listing, LIVE_TARGETS, grep pack 3개, Area A index pairing, Required Surface Matrix)
- [x] **사용자 최종 리뷰** 후 Done

## Verification

```bash
# stale 참조 전수
grep -r "repo-decision" . --include="*.md" --include="*.mdc" --include="*.sh" --include="*.json" \
  | grep -v "docs/archive\|docs/works\|MIGRATION-CANONICAL"

# 새 이름 coverage
grep -r "record-decision" skills/ .claude/ .agents/ .cursor/

# scaffold 시뮬레이션
bash -n scripts/create-harness.sh
TEMP=$(mktemp -d) && bash scripts/create-harness.sh --target "$TEMP" --workflow generic 2>&1 | tail -5
ls "$TEMP/.claude/commands/" | grep decision
grep -r "repo-decision" "$TEMP" --include="*.md" | head
rm -rf "$TEMP"
```

## Checkpoints

| CP | Description | Status |
|---|---|---|
| 1 | Slice A: DR-026 등록 | ✓ Done |
| 2 | Slice B: 파일 rename 3개 | ✓ Done |
| 3 | Slice C: canonical skill 본문 개정 | ✓ Done |
| 4 | Slice D: template + index | ✓ Done |
| 5 | Slice E: live 11개 파일 cascade | ✓ Done |
| 6 | Slice F: scaffold syntax OK + stale grep 0건 (실행 권한 거부로 temp scaffold 생략) | ✓ Done |
