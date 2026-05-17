---
id: HRF-002
priority: P0
status: Done
risk: High
scope: Work 파일 체계 도입, docs/works/ 구조 정비, STATUS 전환, AI 도구 정렬, 시뮬레이션 검증
appetite: 2w
planned_start: 2026-05-18
planned_end: 2026-05-31
actual_end: 2026-05-18
related_dr: [DR-013, DR-014]
related_commits: [3288155, 4ebb5c9, 44202d1, ad9ed2f, 3955806, 89b22bb, 604e4b9, 2779ba9, e24fe5e, 6da7fe5, 8561c3b]
related_troubleshooting: []
---

## Plan

Work 파일을 작업 단위의 Single Source of Truth로 도입하고, STATUS.md를 Phase 대시보드 + 포인터로 축소한다.
docs/TODO/ 디렉토리를 docs/works/로 재명명하여 Work 파일 체계의 홈으로 삼고,
archive 구조를 경로 미러링 방식으로 정비한다.

**Alternatives 검토:**
- STATUS.md 확장 유지 — 롤링 윈도우로 이력 소실 불가피, 채택 안 함
- GitHub Issues 도입 — 오프라인 불가, git repo 외부 이력, 현 규모에 과함

전체 실행 계획은 `/Users/kyungseo/.claude/plans/soft-knitting-quill.md` 참조.

## Done Criteria

- [x] DR-013, DR-014 작성 및 승인
- [x] docs/TODO/ → docs/works/ 리네이밍, 소문자 통일
- [x] archive 구조 정비 (경로 미러링 기반)
- [x] STATUS.md 포인터 형식 전환 완료
- [x] AI 도구 정렬: Claude commands/rules, Codex AGENTS.md, Cursor rules, prompts 일관성 확인
- [x] 하네스 문서 업데이트 (AGENT-WORKFLOW.md, HARNESS-PROTOCOL.md 등)
- [x] 3개 AI 도구 시뮬레이션 갭 없음
- [x] README/매뉴얼 정렬 완료
- [x] `/health` 통과

## Verification

```bash
# 디렉토리 소문자 확인
find docs/ -type d | sort

# 구 경로 참조 잔존 확인 (0건이어야 함)
grep -rn "docs/TODO" . --include="*.md" --include="*.sh" --include="*.mdc" | grep -v "archive\|\.git\|DR-013"

# STATUS.md 간결성
wc -l docs/STATUS.md  # 60줄 이내 목표

# health 실행
# /health
```

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1 | Phase 0: git tag hrf-002-start, STATUS 스냅샷 | Done |
| 2 | Phase A: DR-013, DR-014 작성, HARNESS.md HRF-002 등록 | Done |
| 3 | Phase B: 데이터 클린징, STATUS 구조 전환 | Done |
| 4 | Phase C: docs/works/ 리네이밍, archive 구조, Work 파일 생성 | Done |
| 5 | Phase D: STATUS.md 리팩토링 완료 | Done |
| 6 | Phase E: AI 도구 정렬 (Claude/Codex/Cursor/prompts) | Done |
| 7 | Phase F: 하네스 문서 업데이트 | Done |
| 8 | Phase G: 시뮬레이션 검증 | Done |
| 9 | Phase H: README/매뉴얼 정렬 | Done |
| 10 | Phase I: /health 최종 검증, G3 시뮬레이션, DR-015, HRN-017 등록 | Done |

## Discovery

- macOS case-insensitive FS에서 git mv 시 동일 내용 파일 간 리네임 추적이 교차될 수 있음.
  실제 파일 위치는 정확하므로 커밋 결과에는 영향 없음.
- docs/works/PHASE2/ (빈 디렉토리)는 git이 추적하지 않아 OS mv로 처리함.
- TODO-BLOCK*.md 파일들은 Phase 1 완료 당시 작업 단위로, 구형 형식(Work 파일 이전).
  docs/works/phase1/에 유지하되, 신규 Work 파일과 형식이 다름에 유의.
- Work 파일 공통 규칙(실제 저장소 상태 우선 원칙)은 개별 Work 파일이 아닌
  docs/harness-protocol/03-work-items-and-naming.md Work File Rules 섹션에 위치.
  DR-013이 해당 섹션을 권위 문서로 참조하도록 업데이트함.
