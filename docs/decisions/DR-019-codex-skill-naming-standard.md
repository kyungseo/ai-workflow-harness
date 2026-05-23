# DR-019: Codex Skill Naming Standard — `workflow-{name}` Prefix

Date: 2026-05-24
Status: Accepted
Supersedes: (해당 없음 — HRN-028 Work 파일 Discovery에 `harness-{name}` 설계 근거 기록됨)

## Question

Codex skill 디렉토리(`.agents/skills/`)의 naming prefix를 무엇으로 할 것인가?

## Decision

`.agents/skills/workflow-{name}/` prefix를 사용한다.

suffix mapping 규칙: `.claude/commands/{name}.md` ↔ `.agents/skills/workflow-{name}/SKILL.md`

## Options Considered

| 선택지 | 장점 | 단점 |
|---|---|---|
| `{name}` (prefix 없음) | 짧고 Claude command와 1:1 대응 | Codex skill list에서 일반 project skill(`work`, `debug`, `doc`)과 trigger ambiguity 발생 |
| `source-command-{name}` | 출처 명시 | verbose, 의미 불명확 (HRN-028 이전 방식) |
| `command-{name}` | Claude command와 suffix 1:1 대응 명확 | 미래에 command mirror가 아닌 harness capability로 확장 시 misleading |
| `harness-{name}` | harness 소유권 명확, 구조 변경에 강함 | product/harness track 양쪽을 다루는 skill에 harness-only scope로 읽힘 (HRN-028 채택, HRN-029에서 교체) |
| `workflow-{name}` | skill이 하는 일(workflow 실행) 표현, product/harness track 양쪽 scope 포함 | `.claude/commands/`와의 직접 대응은 문서/health check에서 설명 필요 |

## Rationale

`workflow-{name}`은 세 가지 요구를 동시에 만족한다.

1. **Trigger isolation**: Codex skill list에서 일반 project skill과 namespace가 분리된다.
2. **Scope accuracy**: `workflow-work`, `workflow-close`는 product track과 harness track 양쪽에 적용되는 skill임을 이름에서 직관적으로 전달한다. `harness-work`처럼 harness-only scope로 오해할 여지가 없다.
3. **Structural stability**: Claude command 구조가 변경되거나 Codex skill이 독자적인 절차를 갖더라도 이름의 의미가 유지된다.

진화 경로: `{name}` (ambiguous) → `source-command-{name}` (verbose) → `harness-{name}` (HRN-028) → `workflow-{name}` (HRN-029, 최종)

## Consequences

- 신규 skill 추가 시 반드시 `workflow-{name}/` 디렉토리명과 `name: "workflow-{name}"` frontmatter를 사용한다.
- health/cascade 검증 시 suffix mapping 기준: `.claude/commands/{name}.md`와 `.agents/skills/workflow-{name}/SKILL.md`의 누락/초과 여부를 확인한다.
- `.agents/skills/*/` 동적 순회를 사용하는 `scripts/create-harness.sh`는 prefix 변경에 영향받지 않는다.

## Reversal Cost

Medium — 11개 SKILL.md 내부, cascade 문서 전체, scaffold 산출물 참조 재갱신 필요.

## Linked Backlog Items

- HRN-028: Command / Skill 네이밍 체계 정비 (harness-{name} 채택)
- HRN-029: Codex Skill Prefix `harness-*` → `workflow-*` Rename (workflow-{name} 최종 확정)
