# repo-health-full

Conditional detail slice for `/repo-health --full`.

Load this file only after `skills/workflow/repo-health.md` when the invocation includes `--full`.

## File Reading Order

**Phase 4 — Alignment Check (--full only)**
`.cursor/rules/*.mdc` (frontmatter paths만) → `prompts/README.md` (인덱스만, 개별 파일 금지)

**Phase 5 — Implementation Sync (--full, Area F only)**
```bash
# 최근 30일 변경된 workflow/tool/scaffold 파일 목록
git log --since="30 days ago" --name-only --format="" | sort -u | rg "^(AGENTS.md|CLAUDE.md|README.md|docs/|prompts/|scripts/|\\.agents/|\\.codex/|\\.claude/|\\.cursor/|\\.github/)"
```
변경 파일 목록을 기반으로 관련 문서만 선택적 확인.
`docs/decisions/DR-*.md` 상태 확인:
```bash
rg -n "^# |^Status:" docs/decisions
```
제목과 Status 필드만 추출. 내용 읽기는 통합 후보로 의심되는 쌍에만 한정.

변경 surface에 `docs/decisions/**` 또는 shipped canonical/adapter/rule/prompt가 포함되면 shipped DR reference closure를 확인한다(source repo 전용; script가 없으면 N/A):
```bash
bash scripts/tests/check-shipped-dr-closure.sh
```
위반은 mode-a(self-describe) 또는 mode-b(`Linked DRs:` frontmatter)로 처리한다. 정책·HOW는 `docs/maintainer/VERIFICATION-COMMANDS.md` Layer I.

## Inspection Areas

### C. Tool Feature Alignment (--full)

- `.claude/settings.json`: `defaultMode`, `permissions.deny` 목록 현행성, hooks 설정
- `.agents/skills/`: Codex command skill frontmatter와 대응 command coverage
- `.codex/hooks.json`: Codex hook 설정 현행성
- MCP 서버 설정 상태 및 실제 활용 가능성
- Phase 2에서 읽은 rule/command 기반으로 중복 instruction·비효율 탐지
  (추가 파일 로드 없이 이미 확인한 내용에서 판단)

### D. Vibe Coding / Prompt Engineering (--full)

- plan→approve→implement 3단계가 모든 command에 명시적으로 강제되는가
  (Phase 2 목록 확인 시 의심 항목만 내용 확인)
- 트리거 조건이 "상황에 따라"처럼 모호하게 기술된 항목
- 각 command의 출력 형식이 명시되어 있는가
- `prompts/README.md` 인덱스 기준으로 Phase 2 대비 누락 유형 확인
  (개별 prompt 파일은 로드하지 않는다)

### F. Implementation Sync (--full)

Phase 5의 git log 결과를 기준으로, 변경된 구현 파일 유형별로 관련 문서만 선택 확인한다.

| 변경 파일 유형 | 확인 대상 문서 |
|---------------|---------------|
| `AGENTS.md`, `CLAUDE.md` | `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`, 관련 session prompt |
| `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md` | `.claude/commands/*.md`, `.claude/rules/*.md`, `.agents/skills/*/SKILL.md`, `.codex/hooks.json`, `.cursor/rules/*.mdc`, `prompts/*session-start.md` |
| `docs/STATUS.md`, `docs/PLAN.md`, `docs/PLAN-SUMMARY.md` | Active Work 파일, `docs/works/*/README.md`, 관련 backlog |
| `.github/workflows/*.yml` | `docs/GIT-WORKFLOW.md`, `.cursor/rules/execution.mdc`, `README.md` CI 항목 |
| `.claude/commands/*.md`, `.agents/skills/*/SKILL.md`, `.claude/rules/*.md`, `.codex/hooks.json` | `docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md`, 대응 `.agents/skills/` 또는 `.claude/commands/`, 대응 `.cursor/rules/*.mdc` |
| `.cursor/rules/*.mdc` | `docs/AGENT-WORKFLOW.md`, 대응 `.claude/rules/*.md`, 관련 session prompt |
| `scripts/create-harness.sh`가 존재할 때 | `README.md`, `docs/WORKFLOW-MANUAL.md`, fresh scaffold 산출물 |
| `prompts/*.md` | `prompts/README.md`, `docs/AGENT-WORKFLOW.md` context routing, scaffold profile 포함 여부 |
| `docs/decisions/DR-*.md` (신규 Accepted) | `docs/STATUS.md` Recent Decisions, 연관 backlog Done Criteria |
| `docs/*.md` (신규 사용자/운영 문서) | 해당 문서가 참조하는 command/rule/script/CI 파일과 실제 내용 대조 |

STATUS.md Recent Decisions는 **최근 8개 rolling window**, 항목 품질(후속 행동을 바꾸는 판단만), DR-worthy 항목의 대응 DR 존재 여부를 점검한다.
전체 이력 점검은 명시적 요청 시에만 진행한다.

`docs/HARNESS-MAINTAINER-GUIDE.md`는 아래 변경이 감지될 때만 읽는다:
- 새 도구 도입 (git hooks 등)
- scaffold 절차 또는 convention 정책 변경

`docs/PLAN.md`는 제목·섹션 헤더 수준만 확인한다:
```bash
rg -n "^## |^### " docs/PLAN.md
```
