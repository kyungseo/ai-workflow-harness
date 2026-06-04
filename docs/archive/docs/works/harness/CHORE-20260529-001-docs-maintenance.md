---
id: CHORE-20260529-001
priority: P2
status: Archived
risk: Medium
scope: Done Work 파일 2개 archive 처리 및 harness 핵심 문서 현행화 점검·수정
appetite: 1d
planned_start: 2026-05-29
planned_end: 2026-05-29
actual_end: 2026-05-29
related_dr: []
related_troubleshooting: []
---

# CHORE-20260529-001: 문서 정비 및 현행화

## Plan

### 배경

CHORE-20260528-001, CHORE-20260528-002가 Done 상태이나 archive 미처리 상태로 Work Index에 잔류 중이다.
동시에 최근 harness 변경(slice & pointer 전역 룰, 병렬 작업 제어 모델)이 핵심 문서에 정확히 반영됐는지 현행화 점검이 필요하다.

### 범위

- **Phase A**: Done Work 2개 archive (git mv → docs/archive/docs/works/harness/)
- **Phase B**: Harness 핵심 문서 현행화 점검 (HARNESS-PROTOCOL.md, HARNESS-QUICK-REFERENCE.md, AGENT-WORKFLOW.md, HARNESS-NAMING-RULES.md, HARNESS-PARALLEL-WORK-CONTROLS.md)
- **Phase C**: Work 파일 생성 및 STATUS.md 마무리
- **Phase D**: 사용자 지정 점검 및 현행화

### Done Criteria

- [x] CHORE-20260528-001, CHORE-20260528-002 → docs/archive/docs/works/harness/ 이동 완료
- [x] docs/works/harness/README.md Done(Archive Pending) → Archived 반영 완료
- [x] harness 핵심 문서 5개 현행화 점검 완료 (stale 수정 또는 이상 없음 확인)
- [x] Phase D 사용자 지정 점검 완료
- [x] docs/STATUS.md Last updated 갱신

### Verification

- git diff --check 통과
- 수정 문서 내 cross-reference·링크 정합성 확인
- canonical → tool-specific cascade 확인 (AGENT-WORKFLOW.md 수정 시)

## Discovery

### Phase A: Done Work archive

- 대상: CHORE-20260528-001, CHORE-20260528-002
- archive 경로: docs/archive/docs/works/harness/ (기존 패턴 확인 완료)

## Checkpoints

### CP-1: Phase A・B 완료 (2026-05-29)

**Phase A: Done Work archive**
- CHORE-20260528-001 → `docs/archive/docs/works/harness/` git mv 완료
- CHORE-20260528-002 → `docs/archive/docs/works/harness/` git mv 완료
- `docs/works/harness/README.md`: Done(Archive Pending) 행 제거, Active에 CHORE-20260529-001 추가, Archived 행 추가 필요 (→ CP-2에서 처리)

**Phase B: Harness 핵심 문서 현행화 점검**
- `docs/HARNESS-PROTOCOL.md`: §16 slice & pointer 원칙, §17 HARNESS-PARALLEL-WORK-CONTROLS.md 조건부 pointer 정상 ✅
- `docs/HARNESS-QUICK-REFERENCE.md`: 현행 workflow 반영 완료, stale 없음 ✅
- `docs/AGENT-WORKFLOW.md`: Context Routing 표 — HARNESS-PARALLEL-WORK-CONTROLS.md·HARNESS-RECOVERY-VALIDATION.md 조건부 로드 항목 정상 ✅
- `docs/HARNESS-NAMING-RULES.md`: ID 형식(TYPE-YYYYMMDD-NNN), NNN 재배정 절차 현행 ✅
- `docs/HARNESS-PARALLEL-WORK-CONTROLS.md`: CHORE-20260528-001 신규 작성 문서, 완결 ✅

**Phase C 잔여 작업**: README Archived 행 추가, STATUS.md Last updated 갱신 (commit 시 함께)

### CP-2: Phase C·D 완료 (2026-05-29)

**Phase C**
- docs/works/harness/README.md Archived 테이블에 CHORE-20260528-001, 002 행 추가 완료 ✅
- STATUS.md Active Work pointer 추가 완료 (session 시작 시) ✅

**Phase D: 사용자 지정 점검 및 현행화**
- DR-020 Deferred 항목 해소 (Merge 방식 제한 → ruleset 차단 미적용, DR-017 운영 정책으로 결정)
- DR-018 전면 현행화 (Java/Gradle → docs/scaffold 기준)
- HARNESS.md HRN-FUT-005 제거 (결정 완료)
- Post-PR Merge Cleanup 규칙 추가 (.claude/rules/git-workflow.md, .cursor/rules/workflow.mdc, AGENTS.md) — feature→develop / develop→main 두 경로 분리, GIT-WORKFLOW.md 존재 가드 적용
- PLAN.md §4 Current Milestone, §5 Keep As Core, §7 Roadmap, §9 Open Questions 현행화
- PLAN-SUMMARY.md Key Operating Decisions, Core Files 표 현행화
- HARNESS-QUICK-REFERENCE.md §2·§3·§4·§5 제거 (AGENT-WORKFLOW.md 중복 제거), 251줄 → 158줄, Command Taxonomy 복원
- HARNESS-PROTOCOL.md: DR-011 dead link 제거, Commit References 섹션 제거, §16·§17 현행 확인
- HARNESS-STRUCTURE.md: §3 Retrospectives 경로 추가, §4 QR 설명 현행화, §9 Document Priority Hierarchy 추가, §10 Work File Lifecycle 추가
- DR-013 related_commits 필드 제거 (Work 파일 frontmatter, HARNESS-PROTOCOL.md §12, scripts/create-harness.sh)
- HARNESS.md backlog: Pre-commit/commit-msg hook 항목, HARNESS-STRUCTURE→ARCHITECTURE rename 항목 등록
- SCAFFOLD-BOOTSTRAP.md: DR 3개 누락 검토 완료 (이상 없음)

**Decisions (no DR needed)**
- HARNESS-QUICK-REFERENCE.md §2·§3·§4·§5 제거: AGENT-WORKFLOW.md 자동 로드로 완전 커버 확인 (시뮬레이션 완료)
- related_commits 필드 제거: 0% fill rate, git log --grep이 더 신뢰할 수 있는 대체 수단
- HARNESS-PROTOCOL.md DR-011 참조 제거: 규칙이 inline에 명시되어 있어 rationale pointer 불필요
