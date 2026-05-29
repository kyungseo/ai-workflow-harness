---
id: CHORE-20260529-002
priority: P2
status: Done
risk: Medium
scope: docs/HARNESS-STRUCTURE.md → docs/HARNESS-ARCHITECTURE.md rename 및 11개 파일 38개 참조 cascade 정합성 + scaffold 검증 + 사용자 workflow 시뮬레이션
appetite: 1d
planned_start: 2026-05-29
planned_end: 2026-05-29
actual_end: 2026-05-29
related_dr: []
related_troubleshooting: []
---

# CHORE-20260529-002: HARNESS-STRUCTURE → HARNESS-ARCHITECTURE rename

## Plan

### 배경

`docs/HARNESS-STRUCTURE.md`는 원래 `ARCHITECTURE.md`로 시작했다가 rename됐다.
현재 파일 내용(System Overview, Session Flow, Context Routing, Tool Surface Model, Scaffold Flow 등)은 "구조" 이상의 아키텍처 범위를 다루므로, 더 포괄적인 `HARNESS-ARCHITECTURE.md`로 되돌린다.

### 변경 파일 목록

| 파일 | 참조 수 | 비고 |
|---|---|---|
| `docs/HARNESS-STRUCTURE.md` | — | git mv 대상 |
| `README.md` | 2 | — |
| `docs/WORKFLOW-MANUAL.md` | 22 | 가장 많음 |
| `docs/HARNESS-PROTOCOL.md` | 6 | 설명 "현재 구조" → "현재 아키텍처" 포함 |
| `docs/HARNESS-QUICK-REFERENCE.md` | 1 | — |
| `docs/HARNESS-MAINTAINER-GUIDE.md` | 1 | — |
| `docs/PLAN.md` | 1 | "(구 ARCHITECTURE.md)" 주석 제거 포함 |
| `docs/PLAN-SUMMARY.md` | 1 | "(구 ARCHITECTURE)" 주석 제거 포함 |
| `.claude/commands/record-decision.md` | 1 | — |
| `.agents/skills/workflow-record-decision/SKILL.md` | 1 | — |
| `scripts/create-harness.sh` | 2 | 설명 "구조와 정보 흐름" → "아키텍처와 정보 흐름" 포함 |

**변경 제외:**
- `docs/works/harness/CHORE-20260529-001-docs-maintenance.md` — Done Work, 이력 보존
- `docs/backlog/HARNESS.md` — 이 Work 완료 시 해당 행 제거

### Done Criteria

- [x] `git mv docs/HARNESS-STRUCTURE.md docs/HARNESS-ARCHITECTURE.md` 완료, 파일 헤더 수정
- [x] 11개 파일 38개 참조 전수 교체 완료
- [x] `PLAN.md` `(구 ARCHITECTURE.md)` 주석 제거
- [x] `PLAN-SUMMARY.md` `(구 ARCHITECTURE)` 주석 제거
- [x] `bash -n scripts/create-harness.sh` 통과
- [x] scaffold `--dry-run --profile generic` 통과
- [x] scaffold 실제 생성 후 `HARNESS-ARCHITECTURE.md` 존재, `HARNESS-STRUCTURE.md` 잔존 없음 확인
- [x] scaffold 생성 repo `/start` 시뮬레이션 — STATUS.md, BOOTSTRAP.md 참조 정상 확인
- [x] `grep -r "HARNESS-STRUCTURE" /tmp/arch-test-real` 결과 없음
- [x] `docs/STATUS.md` Last updated 갱신

### Verification

```bash
bash -n scripts/create-harness.sh
scripts/create-harness.sh --dry-run --profile generic arch-test /tmp/arch-test
scripts/create-harness.sh --profile generic arch-test /tmp/arch-test-real
grep -r "HARNESS-STRUCTURE" /tmp/arch-test-real  # 결과 없어야 함
grep -r "HARNESS-ARCHITECTURE" /tmp/arch-test-real  # 존재해야 함
```

## Discovery

### Pre-execution: 누락 파일 발견

계획 단계 전체 파일 트리 스캔에서 `README.md` (2개 참조) 누락 확인 후 추가.
최초 검색 범위에 root-level `.md` 파일이 포함되지 않아 발생. 전체 트리 스캔으로 보완.

## Checkpoints

### CP-1: Phase A·B·C 완료 (2026-05-29)

**Phase A**: git mv 완료, 파일 헤더 수정 ✅
**Phase B**: 10개 파일 replace_all 완료, 설명 문구 업데이트 포함 ✅
- README.md (2개) — 전체 스캔에서 발견, 계획 보완
- HARNESS-PROTOCOL.md (6개) + 설명 "현재 구조" → "현재 아키텍처"
- WORKFLOW-MANUAL.md (22개), HARNESS-QUICK-REFERENCE.md, HARNESS-MAINTAINER-GUIDE.md
- PLAN.md — "(구 ARCHITECTURE.md)" 주석 제거
- PLAN-SUMMARY.md — "(구 ARCHITECTURE)" 주석 제거
- record-decision.md, SKILL.md, create-harness.sh

**Phase C: Verification**
- `bash -n scripts/create-harness.sh` ✅
- scaffold dry-run ✅
- scaffold 실제 생성 `/tmp/arch-test-real` ✅
  - `grep -r "HARNESS-STRUCTURE" /tmp/arch-test-real` → 결과 없음 ✅
  - `docs/HARNESS-ARCHITECTURE.md` 존재 ✅
  - STATUS.md, BOOTSTRAP.md, CLAUDE.md, AGENTS.md, AGENT-WORKFLOW.md 참조 정상 ✅
