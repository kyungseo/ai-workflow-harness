---
id: HRN-027
priority: P2
status: Archived
risk: L2
scope: backlog pruning 정책 수립 + 실행, superseded DR archive 정책 수립
appetite: 0.5d
planned_start: 2026-05-23
planned_end:
actual_end: 2026-05-24
---

# HRN-027: Backlog pruning + DR archive 정책 정비

## Context

작업이 누적됨에 따라 `docs/backlog/HARNESS.md`의 Done/Superseded 항목과
`docs/decisions/` DR 파일이 무한 증가하는 구조적 gap이 존재한다.

DR-014(archive policy)는 Work 파일·문서 버전·Phase archive는 다루지만
backlog 항목 pruning과 superseded DR 처리 정책이 없다.

**현황:**
- `docs/backlog/HARNESS.md` 59줄 — Done/Superseded 14개가 대부분
- `docs/decisions/` DR 10개, 현재는 모두 Accepted
- Superseded DR 발생 시 처리 정책 미정의

## Done Criteria

- [x] `docs/backlog/HARNESS.md` Done/Superseded 14개 항목 삭제 (Candidate + Deferred Ideas 유지)
- [x] Backlog pruning 정책 `docs/HARNESS-PROTOCOL.md`에 추가 — Done 항목 제거 시점과 방법
- [x] Superseded DR archive 정책 `docs/HARNESS-PROTOCOL.md`에 추가 — `docs/archive/docs/decisions/`로 git mv
- [x] `docs/decisions/README.md` DR 인덱스 생성 — ID, 제목, status, 한 줄 요약
- [x] `docs/HARNESS-PROTOCOL.md` cascade 감사 범위에 "Accepted DR만 확인, Superseded는 archive 이후 제외" 명시
- [x] `docs/retrospectives/README.md` 인덱스 생성 — 날짜, 제목, 주제/scope, 핵심 결론 한 줄
- [x] `docs/HARNESS-PROTOCOL.md` retrospective archive 정책 추가 — 보관 기준 및 archive 시점
- [x] `docs/HARNESS-PROTOCOL.md` cascade 감사 범위에 retrospective 확인 기준 명시 (최신 또는 관련 1개)
- [x] `git diff --check` 통과
- [x] `grep "| Done\|Superseded" docs/backlog/HARNESS.md` 결과 없음 확인

## Verification

```bash
git diff --check
grep "| Done\|Superseded" docs/backlog/HARNESS.md
```

## Risk

| Risk | 대응 |
|------|------|
| Done 항목 삭제 후 참조 필요 시 | git history로 복원 가능 — reversal cost Low |
| HARNESS-PROTOCOL.md 정책 위치 선정 | backlog 섹션과 DR 섹션에 각각 추가 |

Reversal cost: Low — git revert 한 커밋으로 복원

## Checkpoints

- [x] HARNESS.md Done/Superseded 항목 삭제
- [x] HARNESS-PROTOCOL.md backlog pruning 정책 추가
- [x] HARNESS-PROTOCOL.md superseded DR archive 정책 + cascade 감사 범위 명시
- [x] docs/decisions/README.md DR 인덱스 생성
- [x] docs/retrospectives/README.md 인덱스 생성
- [x] HARNESS-PROTOCOL.md retrospective archive 정책 + cascade 감사 범위 명시
- [x] 전체 커밋

## Discovery

- 완료 항목 탐색 경로 안내 필요성 발견 — HARNESS-PROTOCOL.md, WORKFLOW-MANUAL.md, HARNESS.md 3곳에 git log 경로 추가.
- 2026-05-24 archived: 모든 Done Criteria 충족.
