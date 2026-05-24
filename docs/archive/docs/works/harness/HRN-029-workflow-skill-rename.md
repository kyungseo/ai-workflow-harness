---
id: HRN-029
priority: P2
status: Archived
risk: L2
scope: .agents/skills/harness-{name}/ → workflow-{name}/ rename, SKILL.md 내부 + cascade 문서 갱신
appetite: 0.5d
planned_start: 2026-05-24
planned_end: 2026-05-24
actual_end: 2026-05-24
---

# HRN-029: Codex Skill Prefix `harness-*` → `workflow-*` Rename

## Context

HRN-028에서 `.agents/skills/source-command-*`를 `harness-{name}`으로 rename했다. 이후 운영 중 `harness-work`, `harness-close` 등의 prefix가 harness 전용 scope를 암시한다는 문제가 드러났다. 실제로 이 skill들은 product track과 harness track 양쪽을 모두 처리하며, scaffold된 프로젝트에서도 동일하게 사용된다.

`workflow-{name}` prefix는 skill이 하는 일(workflow 실행)을 정확히 표현하고, product/harness track 구분 없이 harness가 제공하는 workflow capability임을 명확히 드러낸다.

## Done Criteria

- [x] `.agents/skills/harness-{name}/` → `.agents/skills/workflow-{name}/` 디렉토리 rename (git mv × 11)
- [x] 각 `SKILL.md` frontmatter `name`, 제목, invoke description을 `workflow-{name}` 기준으로 수정
- [x] `AGENTS.md` skill path 참조를 `workflow-{name}/SKILL.md`로 수정
- [x] `docs/HARNESS-PROTOCOL.md` cascade matrix `harness-{name}/SKILL.md` → `workflow-{name}/SKILL.md` 수정
- [x] `.claude/commands/health.md` 및 `.agents/skills/workflow-health/SKILL.md` suffix mapping `harness-*` → `workflow-*` 수정
- [x] `README.md`, `docs/WORKFLOW-MANUAL.md`, `prompts/README.md` 참조 갱신
- [x] 회고 파일 현재 상태 테이블 갱신 (역사적 서술 유지, stale naming 정리)
- [x] `grep -rn "skills/harness-"` 결과 없음 (docs/works/, docs/archive/ 제외)

## Verification

```bash
grep -rn "skills/harness-" . --include="*.md" --include="*.json" --include="*.sh" \
  | grep -v "docs/works/" | grep -v "docs/archive/"
# 기대: 역사적 서술(회고 narrative 섹션) 외 결과 없음
```

## Risk

| Risk | 대응 |
| --- | --- |
| cascade 누락으로 stale `harness-*` 참조 잔존 | grep 전수 확인으로 검증 |
| scaffold `.agents/skills/*/` 동적 순회이므로 script 변경 불필요 | bash -n 검증 불필요 (HRN-028 이미 통과) |

Reversal cost: Low — 문서/디렉토리 rename이며 runtime logic 변경 없음

## Checkpoints

- [x] 명명 이유 확인 및 HRN-029 등록
- [x] git mv × 11 + SKILL.md × 11 내부 수정
- [x] AGENTS.md, HARNESS-PROTOCOL.md, health.md cascade 갱신
- [x] README.md, WORKFLOW-MANUAL.md, prompts/README.md 참조 갱신
- [x] 회고 파일 stale naming 정리
- [x] grep 최종 검증 통과

## Discovery

### 명명 결정 — 2026-05-24

`harness-*`는 HRN-028 Plan Review Addendum 2에서 채택됐다. 당시 `command-{name}` 대비 장점은 "harness 소유 skill임이 명확하고 구조 변경에 강하다"는 것이었다.

실운영에서 드러난 추가 문제: `harness-work`, `harness-close` 등이 harness-only scope로 읽혀 product track 작업에도 동일 skill을 쓴다는 사실을 직관적으로 전달하지 못한다. `workflow-*`는 "이 skill이 하는 일"에 초점을 맞추므로 양쪽 track에 걸친 scope를 자연스럽게 표현한다.

suffix mapping 규칙: `.claude/commands/{name}.md` ↔ `.agents/skills/workflow-{name}/SKILL.md`
