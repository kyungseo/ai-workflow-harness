---
id: HRN-028
priority: P2
status: Archived
risk: L2
scope: .agents/skills/ source-command-{name} → harness-{name} rename, .claude/commands/ 현행 유지
appetite: 1d
planned_start: 2026-05-24
planned_end:
actual_end: 2026-05-24
---

# HRN-028: Command / Skill 네이밍 체계 정비

## Context

현재 두 가지 네이밍 문제가 존재한다.

1. `.agents/skills/source-command-{name}/` — `source-command-` prefix가 불필요하게 verbose하고 의미가 불명확하다.
2. `.claude/commands/`의 명령 이름이 카테고리 구분 없이 flat하여 `close`(Work Done)와 `done`(세션 종료)처럼 혼동하기 쉬운 이름이 공존한다.

이 두 문제를 하나의 작업으로 해결한다. 새 명명 체계가 확정되면 `.agents/skills/` 디렉토리 이름은 `.claude/commands/` 파일명과 1:1 대응하도록 정렬한다.

## Naming Design

### 현재 카테고리

| 카테고리 | 현재 명령 | 역할 |
| --- | --- | --- |
| Session lifecycle | `start`, `pick`, `done` | 세션 상태 파악, 작업 선택, 세션 종료 |
| Work lifecycle | `work`, `resume`, `close` | Work 착수, 재개, Done 처리 |
| Utility / Analysis | `debug`, `doc`, `health`, `record-decision`, `register` | 분석·등록·기록 |

### 핵심 문제

1. `close` (Work Done 처리) vs `done` (세션 종료) — 이름만 봐서는 역할 구분이 어렵다.
2. `work` 단독으로는 카테고리가 드러나지 않는다.
3. `.agents/skills/source-command-{name}/` — prefix가 verbose하고 의미가 불명확하다.

### 옵션 A — 완전 대칭 prefix

모든 명령에 카테고리 prefix를 적용한다.

| 카테고리 | 현재 | 변경 후 |
| --- | --- | --- |
| Session | `start` | `session-start` |
| Session | `pick` | `session-pick` |
| Session | `done` | `session-done` |
| Work | `work` | `work-start` |
| Work | `resume` | `work-resume` |
| Work | `close` | `work-done` |
| Utility | `debug`, `doc`, `health`, `register`, `record-decision` | 변경 없음 |

- 장점: 완전한 대칭, 카테고리가 이름에서 즉시 드러남
- 단점: `start`, `pick`처럼 이미 명확한 이름도 길어짐. `session-` prefix가 불필요하게 느껴질 수 있음.

### 옵션 B — 혼동 지점만 교정 (권장)

실제로 혼동이 발생하는 명령만 rename하고 나머지는 유지한다.

| 현재 | 변경 후 | 이유 |
| --- | --- | --- |
| `start` | `start` (유지) | 세션 시작으로 이미 명확 |
| `pick` | `work-pick` | Work 선택이라는 의미 명시 |
| `done` | `session-done` | `work-done`과 혼동 방지 — 가장 중요한 rename |
| `work` | `work-start` | `work-resume`과 짝 맞춤 |
| `resume` | `work-resume` | Work lifecycle 일관성 |
| `close` | `work-done` | 역할이 "Work를 Done 처리"임을 명시 |
| Utility 5개 | 변경 없음 | 카테고리 자명 |

- 장점: 실질적 혼동 해소, 변경 범위 최소화, `start`처럼 이미 직관적인 이름은 그대로
- 단점: Session lifecycle이 `start` 하나만 prefix 없이 남아 비대칭

### 옵션 C — work-* 계열만 통일

Work lifecycle 전체를 `work-*`로 통일하고 session/utility는 현행 유지.

| 현재 | 변경 후 |
| --- | --- |
| `work` | `work-start` |
| `resume` | `work-resume` |
| `close` | `work-done` |
| `pick` | `work-pick` |
| `done` | `session-done` (세션 종료와 Work Done 구분을 위해 최소 변경) |
| 나머지 | 유지 |

- 장점: Work 계열이 완전히 통일됨. `done` 하나만 추가 rename
- 단점: 옵션 B와 거의 동일 — `pick`을 Work lifecycle로 볼 것인지 Session으로 볼 것인지 해석 차이

### `.agents/skills/` 연동

어느 옵션을 선택하든 `.agents/skills/` 디렉토리는 `.claude/commands/` 파일명과 1:1 대응한다.

```
.claude/commands/work-done.md  →  .agents/skills/work-done/SKILL.md
.claude/commands/work-start.md →  .agents/skills/work-start/SKILL.md
```

`source-command-` prefix는 어느 옵션에서든 제거된다.

### 권장 방향

**옵션 B 또는 C** — Work lifecycle을 `work-*`로 통일하고 `done` → `session-done`으로 rename.
`start`, `pick`의 처리만 결정하면 된다.

- `pick` → `work-pick`으로 rename하면 "Work를 고르는 행위"가 명시되어 자연스럽다.
- `start`는 유지해도 세션 시작으로 충분히 명확하다.

**최종 결정 필요 항목:**
1. `pick` → `work-pick` 또는 유지?
2. `start` → `session-start` 또는 유지?

## Done Criteria

확정 결정: `.claude/commands/` 현행 유지, `.agents/skills/source-command-{name}` → `harness-{name}` rename.

- [x] 명명 체계 결정: `harness-{name}` (Plan Review Addendum 2 — 2026-05-24)
- [x] `.agents/skills/source-command-{name}/` → `.agents/skills/harness-{name}/` 디렉토리 rename (git mv × 11)
- [x] 각 `SKILL.md` frontmatter `name`, 제목, "migrated source command" 문구를 `harness-{name}` 기준으로 수정
- [x] `AGENTS.md` skill path 참조를 `.agents/skills/harness-{name}/SKILL.md`로 수정
- [x] `docs/HARNESS-PROTOCOL.md` Cascade Matrix `source-command-*` → `harness-*` 수정
- [x] `.claude/commands/health.md` 및 `.agents/skills/harness-health/SKILL.md` 내부 `source-command-*` 참조 수정
- [x] cascade 문서 정렬 확인 및 suffix mapping 규칙 추가 (README.md, WORKFLOW-MANUAL.md, HARNESS-QUICK-REFERENCE.md, PLAN-SUMMARY.md, prompts/README.md, prompts/codex-session-start.md)
- [x] `.claude/commands/{name}.md` ↔ `.agents/skills/harness-{name}/SKILL.md` suffix mapping 규칙을 health/cascade 문서에 명시
- [x] `scripts/create-harness.sh` 검증 (`bash -n` 통과) — Codex 검증 완료 (2026-05-24)
- [x] scaffold 실제 생성 검증: generic / spring-boot 생성 후 `source-command-*` 재도입 없음 확인 — Codex 검증 완료 (2026-05-24)
- [x] `git diff --check` 통과
- [x] `rg -n "source-command-" . --include="*.md" --include="*.sh" --include="*.json"` 결과 없음 (Work 파일 내 설계 기록 제외)

## Verification

```bash
bash -n scripts/create-harness.sh
git diff --check
grep -r "source-command" . --include="*.md" --include="*.sh"
```

## Risk

| Risk | 대응 |
| --- | --- |
| 명령 이름 변경 시 사용자 muscle memory 영향 | 신중한 이름 선택, HARNESS-QUICK-REFERENCE 조기 업데이트 |
| 참조 누락으로 stale path 발생 | grep으로 source-command + 구 명령명 전수 확인 |
| scaffold 동작 변경 | bash -n + dry-run 검증 |

Reversal cost: Medium — 명령 이름 변경은 문서 참조 전반 영향

## Checkpoints

- [x] 명명 체계 결정: `harness-{name}` 확정
- [x] `.agents/skills/` rename (git mv × 11) + SKILL.md 내부 수정
- [x] `AGENTS.md` + `HARNESS-PROTOCOL.md` + `health` 참조 수정
- [x] cascade 문서 정렬 + suffix mapping 규칙 추가
- [x] git diff --check 통과 + 커밋 (bee5735) — bash -n / scaffold 검증은 권한 거부로 미완료

## Discovery

(작업 중 발견 사항 기록)

### Plan Review — 2026-05-24

검토 의견: HRN-028의 문제의식은 타당하지만, 현재 초안처럼 `.claude/commands/` slash command rename과 `.agents/skills/` prefix 제거를 한 작업으로 묶으면 변경 범위가 과도하게 커진다.

두 문제의 성격이 다르다.

- `.agents/skills/source-command-{name}/` 제거는 내부 Codex skill hygiene이며, 사용자-facing command contract를 바꾸지 않는다.
- `.claude/commands/*.md` rename은 `/start`, `/pick`, `/work`, `/resume`, `/close`, `/done` 같은 사용자-facing workflow contract를 바꾸며, README, manual, quick reference, prompts, hooks, Cursor rules, scaffold 산출물까지 흔든다.

권장 설계는 새 **Option D**다.

| Surface | 권장 |
| --- | --- |
| `.claude/commands/` | 현행 유지: `start`, `pick`, `work`, `resume`, `close`, `done`, ... |
| `.agents/skills/` | `source-command-{name}` → `{name}`로 rename |
| `SKILL.md` frontmatter | `name: "source-command-work"` → `name: "work"`처럼 단순화 |
| `AGENTS.md` | `.agents/skills/{name}/SKILL.md` 기준으로 command mapping 수정 |
| Health command/skill | `source-command-*` 전제 제거, command file명과 skill directory 1:1 비교로 변경 |

`/close`와 `/done` 혼동은 실제로 중요한 문제지만, 현재 quick reference, manual, hook, command description에서 이미 "Work Done 처리"와 "Session summary"를 강하게 분리하고 있다. 따라서 slash command rename은 비용 대비 효과가 작다. 계속 혼동이 발생하면 별도 HRN으로 분리해 사용자-facing command rename만 독립 검토하는 편이 안전하다.

수정된 실행 범위 제안:

1. `.agents/skills/source-command-*` 디렉토리를 `.agents/skills/{name}`으로 `git mv`.
2. 각 `SKILL.md`의 `name`, 제목, "migrated source command" 문구를 새 이름 기준으로 정리.
3. `AGENTS.md`의 skill path 문구를 `.agents/skills/{name}/SKILL.md`로 수정.
4. `.claude/commands/health.md`와 `.agents/skills/health/SKILL.md`의 `source-command-*` 참조를 새 비교 방식으로 수정.
5. `docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md`, `docs/WORKFLOW-MANUAL.md`, `README.md`, `prompts/README.md`, `prompts/codex-session-start.md`, `scripts/create-harness.sh`에서 stale path/reference를 정리.

필수 검증:

```bash
rg -n "source-command-|\\.agents/skills/source-command" AGENTS.md README.md docs prompts scripts .agents .claude .cursor
find .agents/skills -maxdepth 2 -name SKILL.md | sort
bash -n scripts/create-harness.sh
git diff --check
```

Scaffold 검증:

```bash
rm -rf /private/tmp/hrn-028-generic-sim
scripts/create-harness.sh hrn-028-generic-sim /private/tmp/hrn-028-generic-sim
rg -n "source-command-|\\.agents/skills/source-command" /private/tmp/hrn-028-generic-sim
find /private/tmp/hrn-028-generic-sim/.agents/skills -maxdepth 2 -name SKILL.md | sort
```

필요하면 `--profile spring-boot` scaffold도 추가로 생성해 optional profile rule/prompt 복사에 영향이 없는지 확인한다.

### Plan Review Addendum — 2026-05-24

추가 검토: Claude command와 Codex skill은 namespace와 trigger 방식이 다르므로 같은 naming 기준을 적용하면 안 된다.

Claude의 `.claude/commands/work.md`, `.claude/commands/done.md` 같은 짧은 이름은 충돌 위험이 낮다. Claude command는 사용자가 `/work`, `/done`처럼 명시적으로 호출하는 slash command namespace 안에 있고, 프로젝트 feature skill이나 일반 task 이름과 자연스럽게 분리된다.

반면 Codex skill은 `name`과 `description`이 trigger 판단의 주요 표면이며, system/plugin/project skill 목록과 함께 노출된다. 따라서 `.agents/skills/work`, `.agents/skills/done`, `.agents/skills/doc`, `.agents/skills/debug`처럼 너무 일반적인 이름은 동작은 가능하더라도 trigger ambiguity가 커진다.

따라서 Plan Review의 Option D는 다음처럼 보정하는 것이 더 안전하다.

| Surface | 권장 보정 |
| --- | --- |
| `.claude/commands/` | 현행 유지: `work.md`, `done.md`, `close.md`, ... |
| `.agents/skills/` | `source-command-{name}` → `command-{name}` |
| 대응 관계 | `.claude/commands/{name}.md` ↔ `.agents/skills/command-{name}/SKILL.md` |
| `SKILL.md` frontmatter | `name: "command-work"`, `name: "command-done"`처럼 command namespace 명시 |

이 방식은 세 가지 요구를 동시에 만족한다.

- Claude slash command 이름은 짧고 익숙한 현행 contract를 유지한다.
- Codex skill은 `command-*` namespace로 일반 skill 이름과 구분한다.
- `source-command-*`의 장황함은 제거하면서도 `.claude/commands/{name}.md`와 suffix 기준 1:1 대응은 유지한다.

최종 권장안: **`.claude/commands`는 rename하지 않고, `.agents/skills/source-command-{name}`만 `.agents/skills/command-{name}`으로 rename한다.**

### Plan Review Addendum 2 — 2026-05-24

추가 의견: `command-{name}`과 `harness-{name}` 중에서는 `harness-{name}`이 더 안정적인 선택일 수 있다.

`command-{name}`은 `.claude/commands/{name}.md`와의 1:1 mirror 관계를 이름에 직접 드러낸다. 현재 구조에서는 읽기 쉽고 대응 관계도 명확하다. 다만 미래에 Codex skill이 Claude command와 완전히 같은 절차가 아니라 harness workflow capability로 확장되면, `command-*` 이름은 "command에서 파생된 skill"이라는 현재 구현 세부에 묶일 수 있다.

`harness-{name}`은 skill의 소유권과 목적을 더 넓게 표현한다. 이 skill들은 단순히 Claude command 복사본이 아니라 AI Workflow Harness가 제공하는 반복 workflow capability다. 따라서 `.claude/commands/` 구조가 바뀌거나 Codex skill이 독자적인 보강 절차를 갖더라도 이름의 의미가 유지된다.

비교:

| Prefix | 장점 | 리스크 |
| --- | --- | --- |
| `command-{name}` | `.claude/commands/{name}.md`와 suffix 기준 1:1 대응이 즉시 보임 | 미래에 command mirror가 아닌 harness capability가 되면 misleading해질 수 있음 |
| `harness-{name}` | harness 소유 skill임이 명확하고 구조 변경에 강함 | `.claude/commands/`와의 직접 대응은 문서나 health check에서 설명해야 함 |

최종 설계 후보를 다음처럼 좁힌다.

| Surface | 권장 |
| --- | --- |
| `.claude/commands/` | 현행 유지 |
| `.agents/skills/` | `source-command-{name}` → `harness-{name}` |
| 대응 관계 | `.claude/commands/{name}.md` ↔ `.agents/skills/harness-{name}/SKILL.md` |
| `SKILL.md` frontmatter | `name: "harness-work"`, `name: "harness-done"`처럼 harness namespace 명시 |

현재 판단: **`harness-{name}`을 우선 권장**한다. 이유는 이 repository의 skill들이 특정 command 파일의 단순 alias가 아니라, harness workflow를 Codex에서 수행하기 위한 tool surface이기 때문이다. 단, health/cascade 문서에는 `.claude/commands/{name}.md`와 `.agents/skills/harness-{name}/SKILL.md`의 suffix mapping 규칙을 명시해야 한다.
