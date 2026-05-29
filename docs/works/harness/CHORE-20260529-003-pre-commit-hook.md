---
id: CHORE-20260529-003
priority: P2
status: Done
risk: Medium
scope: pre-commit/commit-msg hook 내용 검토·수정, hard block 전환, 설치, 관련 문서 현행화
appetite: 0.5d
planned_start: 2026-05-29
planned_end: 2026-05-29
actual_end: 2026-05-29
related_dr: []
related_troubleshooting: []
---

# CHORE-20260529-003: pre-commit/commit-msg hook 검토·정비·설치

## Plan

### 배경

- 오늘 세션에서 pre-commit hook이 미설치 상태임을 발견
- commit-msg hook도 존재하나 미설치, `build` type 누락 확인
- pre-commit warning-only 정책(OQ-2 from HRN-039)이 수개월 운영 안정화 후 hard block 전환 조건 충족
- GIT-WORKFLOW.md, README.md, HARNESS-MAINTAINER-GUIDE.md가 commit-msg hook을 미언급

### Production Repo 영향

없음. `tools/git-hooks/`는 Source repo 전용. scaffold는 이 디렉토리를 product repo로 복사하지 않음.

### 범위

- Phase A: `commit-msg` hook `build` type 추가
- Phase B: `pre-commit` hook warning → hard block (exit 1) 전환 (사용자 결정: Yes)
- Phase C: `sh tools/git-hooks/install.sh` 실행
- Phase D: GIT-WORKFLOW.md §6, README.md, HARNESS-MAINTAINER-GUIDE.md 현행화

### Done Criteria

- [x] `commit-msg` hook에 `build` type 추가
- [x] `pre-commit` hook hard block(exit 1) 전환 완료
- [x] `sh tools/git-hooks/install.sh` 완료 (`ls .git/hooks/` 확인)
- [x] hook 동작 검증 완료 (invalid 차단, build type 통과, shell syntax OK)
- [x] GIT-WORKFLOW.md §6 섹션명 "Git Hooks"로 변경, pre-commit/commit-msg 모두 기술
- [x] README.md git-hooks 설명 현행화
- [x] HARNESS-MAINTAINER-GUIDE.md commit-msg 추가 (line 21, §10)
- [x] STATUS.md Recent Decisions 기록
- [x] source-gitflow 템플릿 GIT-WORKFLOW.md §6 보완 (project-specific hook 작성 가이드 추가)

### Verification

```bash
ls .git/hooks/pre-commit .git/hooks/commit-msg
git commit -m "invalid message" --allow-empty    # → 차단 확인
git commit -m "build: test" --allow-empty        # → 통과 확인 (build type)
```

## Discovery

### 진단 결과 (착수 전)

- `commit-msg` hook: 존재, exit 1 hard block, `build` type 누락
- `pre-commit` hook: 존재, exit 0 warning-only, protected list 정확
- 양쪽 모두 `.git/hooks/`에 미설치
- GIT-WORKFLOW.md §6: pre-commit만 언급, commit-msg 누락
- README.md line 654: `# pre-commit hook` 설명만
- HARNESS-MAINTAINER-GUIDE.md: pre-commit만 언급

## Checkpoints

### CP-1: 전체 완료 (2026-05-29)

**Phase A**: commit-msg `build` type 추가 ✅
**Phase B**: pre-commit exit 0 → exit 1 hard block 전환 ✅ (OQ-2 해소)
**Phase C**: install.sh 실행 → .git/hooks/pre-commit, commit-msg symlink 설치 ✅
**Phase D**: 문서 현행화 ✅
- GIT-WORKFLOW.md §6 "Pre-commit Hook" → "Git Hooks", commit-msg 섹션 추가
- README.md git-hooks 설명 업데이트
- HARNESS-MAINTAINER-GUIDE.md line 21, §10 commit-msg 추가
**Verification**: invalid commit message 차단 ✅, build type 통과 ✅, shell syntax OK ✅
**STATUS.md**: Recent Decisions 기록 ✅
