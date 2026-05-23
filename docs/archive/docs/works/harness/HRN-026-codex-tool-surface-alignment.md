---
id: HRN-026
priority: P1
status: Archived
risk: L2
scope: Codex tool surface (.agents/skills, .codex/hooks), cascade/trigger 반영, AGENTS.md 재정비
appetite: 1d
planned_start: 2026-05-23
planned_end:
actual_end: 2026-05-23
---

# HRN-026: Codex tool surface 정렬 — skills 완성, cascade 반영, AGENTS.md 재정비

## Context

Codex가 프로젝트를 처음 열 때 `.agents/skills/`와 `.codex/hooks.json`을 자동 생성했다.
기존에는 AGENTS.md 인라인 command table이 Codex의 주요 command 실행 지침이었고,
`.agents/skills/`가 없어도 동작하긴 했다. 그러나 skill 파일이 일부만 생성된 상태이고
cascade/trigger 체계에도 이 경로들이 반영되지 않은 구조적 gap이 존재한다.

**현황:**
- `.agents/skills/` 6개 (start, pick, close, doc, done, health)
- `.claude/commands/` 11개 — debug, record-decision, register, resume, work 5개 누락
- `.codex/hooks.json` PostToolUse hook에 Spring Boot 잔재(`.java` → gradlew) 존재
- Cascade Matrix, T11, scaffold, PLAN-SUMMARY.md에 `.agents/`, `.codex/` 경로 미반영

## Done Criteria

- [ ] `.codex/hooks.json` Java/Spring PostToolUse hook 제거, generic Stop hook만 유지
- [ ] 누락 5개 Codex skill 생성 (debug, record-decision, register, resume, work) — 각 `.claude/commands/*.md` 기반
- [ ] AGENTS.md command table 역할 재정비 — skill 완성 후 상세 절차 중복 제거, 경량 index 또는 제거로 정리
- [ ] `PLAN-SUMMARY.md` Core Architecture Tool Surfaces 계층에 `.agents/skills/**`, `.codex/hooks.json` 추가
- [ ] `docs/HARNESS-PROTOCOL.md` Tool Surface Cascade Matrix — `.agents/skills/` + `.codex/hooks.json` 행 추가
- [ ] `docs/HARNESS-PROTOCOL.md` T11 trigger — `.agents/`, `.codex/` 경로 명시
- [ ] `docs/HARNESS-QUICK-REFERENCE.md` trigger 섹션 — tool surface 항목 추가
- [ ] `scripts/create-harness.sh` — `.agents/skills/` 디렉토리 생성 + skill 파일 복사, `.codex/hooks.json` 복사 추가
- [ ] `bash -n scripts/create-harness.sh` 통과
- [ ] `git diff --check` 통과

## Verification

```bash
bash -n scripts/create-harness.sh
git diff --check
```

scaffold dry-run으로 `.agents/`, `.codex/` 생성 여부 확인.
`.agents/skills/` 11개, `.codex/hooks.json` (Stop hook만) 생성 확인.

## Risk

| Risk | 대응 |
|------|------|
| skill 내용이 `.claude/commands/*.md`와 drift 발생 | skill 생성 시 원본 command 파일 직접 참조하여 동기화 |
| scaffold 변경으로 기존 dry-run 실패 | `bash -n` 먼저 통과 확인 후 진행 |

Reversal cost: Low — 파일 추가/편집이 대부분, scaffold는 신규 프로젝트에만 영향

## Checkpoints

- [x] .codex/hooks.json 정리 완료
- [x] 누락 5개 skill 생성 완료
- [x] AGENTS.md command table 재정비 완료
- [x] PLAN-SUMMARY.md + HARNESS-PROTOCOL.md + HARNESS-QUICK-REFERENCE.md cascade 반영 완료
- [x] create-harness.sh 수정 + bash -n 통과
- [x] 전체 커밋

## Discovery

- cascade audit에서 4개 파일 추가 누락 발견: HARNESS-STRUCTURE.md Tool Mirrors subgraph, HARNESS-MAINTAINER-GUIDE.md Tool-specific layer + scaffold checklist, WORKFLOW-MANUAL.md 도구 수(10→11) + T11 표, README.md Document Layers + Repository Layout — 모두 동일 commit에 포함.
- 2026-05-23 archived: 모든 Done Criteria 충족, cascade 반영 완료.
