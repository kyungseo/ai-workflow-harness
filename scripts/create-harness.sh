#!/usr/bin/env bash
# create-harness.sh — AI workflow harness scaffolding.
#
# Usage:
#   scripts/create-harness.sh [flags] <project-name> [target-dir]
#
# Flags:
#   --dry-run, -n      Print file tree without creating anything.
#   --existing, -e     Overlay mode: add harness to an existing project.
#                      Existing files are not overwritten.
#
# Defaults:
#   New mode    — TARGET must not exist; creates everything fresh.
#   Existing    — TARGET is the existing project root; only adds new files.
#   target-dir  — temp/<project-name>/ under this template root (new mode only).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# ── Parse flags ──────────────────────────────────────────────────────────────
DRY_RUN=false
MODE="new"

while [[ "${1:-}" == --* || "${1:-}" == -* ]]; do
  case "${1}" in
    --dry-run|-n)   DRY_RUN=true;     shift ;;
    --existing|-e)  MODE="existing";  shift ;;
    *) echo "Unknown flag: $1" >&2; exit 1 ;;
  esac
done

PROJECT_NAME="${1:?Usage: $0 [--dry-run] [--existing] <project-name> [target-dir]}"
TARGET_ROOT="${2:-${TEMPLATE_ROOT}/temp/${PROJECT_NAME}}"

# ── Dry-run: print tree and exit ─────────────────────────────────────────────
if [[ "${DRY_RUN}" == true ]]; then
  echo "Dry-run [mode: ${MODE}] — would target: ${TARGET_ROOT}"
  echo ""
  echo "$(basename "${TARGET_ROOT}")/"
  echo "├── CLAUDE.md"
  echo "├── AGENTS.md"
  echo "├── README.md              (generated skeleton)"
  echo "├── .claudeignore"
  echo "├── .cursorignore"
  echo "├── .gitignore"
  echo "├── docs/"
  echo "│   ├── STATUS.md          (skeleton)"
  echo "│   ├── PLAN.md            (skeleton)"
  echo "│   ├── PLAN-SUMMARY.md    (skeleton)"
  echo "│   ├── AGENT-WORKFLOW.md"
  echo "│   ├── HARNESS-PROTOCOL.md"
  echo "│   ├── HARNESS-QUICK-REFERENCE.md"
  echo "│   ├── WORKFLOW-MANUAL.md"
  echo "│   ├── backlog/"
  echo "│   │   ├── PHASE1.md      (skeleton)"
  echo "│   │   └── HARNESS.md     (skeleton)"
  echo "│   ├── decisions/"
  echo "│   │   └── DECISION-TEMPLATE.md"
  echo "│   ├── harness-protocol/"
  for f in "${TEMPLATE_ROOT}"/docs/harness-protocol/*.md; do
    echo "│   │   └── $(basename "$f")"
  done
  echo "│   ├── archive/.gitkeep"
  echo "│   ├── retrospectives/.gitkeep"
  echo "│   └── troubleshooting/.gitkeep"
  echo "├── .claude/"
  echo "│   ├── settings.json      (generated)"
  echo "│   ├── rules/"
  for f in "${TEMPLATE_ROOT}"/.claude/rules/*.md; do
    echo "│   │   └── $(basename "$f")"
  done
  echo "│   └── commands/"
  for f in "${TEMPLATE_ROOT}"/.claude/commands/*.md; do
    echo "│       └── $(basename "$f")"
  done
  echo "├── .cursor/"
  echo "│   └── rules/"
  for f in "${TEMPLATE_ROOT}"/.cursor/rules/*.mdc; do
    echo "│       └── $(basename "$f")"
  done
  echo "└── prompts/"
  for f in "${TEMPLATE_ROOT}"/prompts/*.md; do
    echo "    └── $(basename "$f")"
  done
  if [[ "${MODE}" == "existing" ]]; then
    echo ""
    echo "Existing mode: files already present in target will be skipped."
    echo "Skeleton docs (STATUS.md, PLAN*.md, backlog/*.md) created only if absent."
  fi
  exit 0
fi

# ── Guard ────────────────────────────────────────────────────────────────────
if [[ "${MODE}" == "new" && -d "${TARGET_ROOT}" ]]; then
  echo "ERROR: '${TARGET_ROOT}' already exists. Use --existing to overlay." >&2
  exit 1
fi

echo "Scaffolding AI workflow harness [mode: ${MODE}]"
echo "  Project : ${PROJECT_NAME}"
echo "  Target  : ${TARGET_ROOT}"
echo ""

# ── Helpers ──────────────────────────────────────────────────────────────────

# adapt: copy src → dst substituting project name; skip if exists in existing mode
adapt() {
  local src="$1" dst="$2"
  if [[ "${MODE}" == "existing" && -f "${dst}" ]]; then
    echo "  skip  : ${dst#${TARGET_ROOT}/}"
    return
  fi
  sed "s/base-msa-template/${PROJECT_NAME}/g" "${src}" > "${dst}"
  echo "  create: ${dst#${TARGET_ROOT}/}"
}

# safe_write_check: return 0 (write) or 1 (skip) in existing mode
can_write() {
  local dst="$1"
  if [[ "${MODE}" == "existing" && -f "${dst}" ]]; then
    echo "  skip  : ${dst#${TARGET_ROOT}/}"
    return 1
  fi
  return 0
}

# ── Directory structure ──────────────────────────────────────────────────────
mkdir -p \
  "${TARGET_ROOT}/docs/backlog" \
  "${TARGET_ROOT}/docs/decisions" \
  "${TARGET_ROOT}/docs/harness-protocol" \
  "${TARGET_ROOT}/docs/archive" \
  "${TARGET_ROOT}/docs/retrospectives" \
  "${TARGET_ROOT}/docs/troubleshooting" \
  "${TARGET_ROOT}/.claude/rules" \
  "${TARGET_ROOT}/.claude/commands" \
  "${TARGET_ROOT}/.cursor/rules" \
  "${TARGET_ROOT}/prompts"

# ── Root files ───────────────────────────────────────────────────────────────
adapt "${TEMPLATE_ROOT}/CLAUDE.md"     "${TARGET_ROOT}/CLAUDE.md"
adapt "${TEMPLATE_ROOT}/AGENTS.md"     "${TARGET_ROOT}/AGENTS.md"
adapt "${TEMPLATE_ROOT}/.claudeignore" "${TARGET_ROOT}/.claudeignore"
adapt "${TEMPLATE_ROOT}/.cursorignore" "${TARGET_ROOT}/.cursorignore"
adapt "${TEMPLATE_ROOT}/.gitignore"    "${TARGET_ROOT}/.gitignore"

# ── Harness protocol docs ────────────────────────────────────────────────────
adapt "${TEMPLATE_ROOT}/docs/AGENT-WORKFLOW.md"          "${TARGET_ROOT}/docs/AGENT-WORKFLOW.md"
adapt "${TEMPLATE_ROOT}/docs/HARNESS-PROTOCOL.md"        "${TARGET_ROOT}/docs/HARNESS-PROTOCOL.md"
adapt "${TEMPLATE_ROOT}/docs/HARNESS-QUICK-REFERENCE.md" "${TARGET_ROOT}/docs/HARNESS-QUICK-REFERENCE.md"
adapt "${TEMPLATE_ROOT}/docs/WORKFLOW-MANUAL.md"         "${TARGET_ROOT}/docs/WORKFLOW-MANUAL.md"

for f in "${TEMPLATE_ROOT}"/docs/harness-protocol/*.md; do
  adapt "$f" "${TARGET_ROOT}/docs/harness-protocol/$(basename "$f")"
done

adapt "${TEMPLATE_ROOT}/docs/decisions/DECISION-TEMPLATE.md" \
      "${TARGET_ROOT}/docs/decisions/DECISION-TEMPLATE.md"

# ── Claude Code config ───────────────────────────────────────────────────────
for f in "${TEMPLATE_ROOT}"/.claude/rules/*.md; do
  adapt "$f" "${TARGET_ROOT}/.claude/rules/$(basename "$f")"
done

for f in "${TEMPLATE_ROOT}"/.claude/commands/*.md; do
  adapt "$f" "${TARGET_ROOT}/.claude/commands/$(basename "$f")"
done

DST="${TARGET_ROOT}/.claude/settings.json"
if can_write "${DST}"; then
  # Retain security deny-list and Stop hook; strip project-specific PostToolUse hook
  cat > "${DST}" << 'JSON'
{
  "permissions": {
    "defaultMode": "plan",
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./.claude/settings.local.json)",
      "Read(./secrets/**)",
      "Read(./**/*.key)",
      "Read(./**/*.pem)",
      "Read(./**/*.crt)",
      "Bash(sudo *)",
      "Bash(rm -rf*)",
      "Bash(rm -r *)",
      "Bash(kubectl *)",
      "Bash(terraform *)"
    ]
  },
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 -c \"print('[hook] 세션 종료 전 확인: /done 절차로 validation, STATUS Update Proposal 필요 여부, DR-worthy 결정, commit 상태를 보고했는지 확인하세요.')\""
          }
        ]
      }
    ]
  }
}
JSON
  echo "  create: .claude/settings.json"
fi

# ── Cursor rules ─────────────────────────────────────────────────────────────
for f in "${TEMPLATE_ROOT}"/.cursor/rules/*.mdc; do
  adapt "$f" "${TARGET_ROOT}/.cursor/rules/$(basename "$f")"
done

# ── Prompts ──────────────────────────────────────────────────────────────────
for f in "${TEMPLATE_ROOT}"/prompts/*.md; do
  adapt "$f" "${TARGET_ROOT}/prompts/$(basename "$f")"
done

# ── Generated README ─────────────────────────────────────────────────────────
TODAY="$(date +%Y-%m-%d)"

DST="${TARGET_ROOT}/README.md"
if can_write "${DST}"; then
  sed -e "s/__PROJECT__/${PROJECT_NAME}/g" \
      -e "s/__DATE__/${TODAY}/g" \
      > "${DST}" << 'HEREDOC'
# __PROJECT__

> [프로젝트 한 줄 설명 — 채워주세요]

## AI Workflow Harness

이 프로젝트는 Claude Code / Codex / Cursor 공통 AI 워크플로우 하네스를 포함합니다.

| 파일 | 역할 |
| --- | --- |
| `CLAUDE.md` | Claude Code 진입점 |
| `AGENTS.md` | Codex 진입점 |
| `docs/STATUS.md` | 현재 작업 상태 |
| `docs/HARNESS-QUICK-REFERENCE.md` | 세션 실행 규칙 요약 |
| `docs/WORKFLOW-MANUAL.md` | 워크플로우 전체 가이드 |
| `docs/AGENT-WORKFLOW.md` | 공통 운영 규칙 |
| `.claude/commands/` | `/start`, `/pick`, `/register`, `/work`, `/done` 등 |
| `prompts/` | 세션 시작 및 태스크 프롬프트 라이브러리 |

### 첫 세션

```bash
claude        # Claude Code 열기
/start        # 하네스 로딩 확인 및 현재 상태 요약
```

## 사전 작업

스캐폴딩 직후 아래 파일을 채운 뒤 첫 세션을 시작한다.

1. `docs/STATUS.md` — 프로젝트 목표와 Phase 설명
2. `docs/PLAN-SUMMARY.md` — 기술 스택, 포트, 패키지 구조
3. `docs/backlog/PHASE1.md` — 초기 작업 항목 `P1-001~`

---

*Scaffolded __DATE__ — [AI Workflow Harness](docs/WORKFLOW-MANUAL.md)*
HEREDOC
  echo "  create: README.md"
fi

# ── Skeleton docs ─────────────────────────────────────────────────────────────
DST="${TARGET_ROOT}/docs/STATUS.md"
if can_write "${DST}"; then
  sed -e "s/__PROJECT__/${PROJECT_NAME}/g" \
      -e "s/__DATE__/${TODAY}/g" \
      > "${DST}" << 'HEREDOC'
# STATUS.md — __PROJECT__

## Current State

| 항목 | 내용 |
| --- | --- |
| Phase | Phase 1 — [프로젝트 목표 한 줄] |
| Active plan | — |
| Product backlog | `docs/backlog/PHASE1.md` |
| Harness backlog | `docs/backlog/HARNESS.md` |
| Last updated | __DATE__ |

## Active Work

| ID | Scope | Status | Branch | Done Criteria |
| --- | --- | --- | --- | --- |

## Checkpoints

*(없음)*

## Blockers And Open Questions

| ID | Question | Status |
| --- | --- | --- |

## Recent Decisions

*(없음)*

## Next Actions

1. 이 파일과 `docs/PLAN-SUMMARY.md`를 프로젝트 정보로 업데이트
2. `docs/backlog/PHASE1.md`에 초기 작업 항목 등록
3. Claude Code에서 `/start`로 첫 세션 시작
HEREDOC
  echo "  create: docs/STATUS.md"
fi

DST="${TARGET_ROOT}/docs/PLAN-SUMMARY.md"
if can_write "${DST}"; then
  sed -e "s/__PROJECT__/${PROJECT_NAME}/g" \
      > "${DST}" << 'HEREDOC'
# PLAN-SUMMARY.md — __PROJECT__

> 전체 근거와 상세 아키텍처: `docs/PLAN.md`

## 기술 스택

| 항목 | 내용 |
| --- | --- |
| Runtime | — |
| Framework | — |
| Build | — |
| DB | — |
| 주요 라이브러리 | — |

## 서비스 / 포트 매핑

| 서비스 | 포트 |
| --- | --- |

## 핵심 아키텍처 결정

*(채워야 함)*

## 패키지 구조

*(채워야 함)*
HEREDOC
  echo "  create: docs/PLAN-SUMMARY.md"
fi

DST="${TARGET_ROOT}/docs/PLAN.md"
if can_write "${DST}"; then
  sed -e "s/__PROJECT__/${PROJECT_NAME}/g" \
      > "${DST}" << 'HEREDOC'
# PLAN.md — __PROJECT__

> 요약: `docs/PLAN-SUMMARY.md`

## 목표

*(채워야 함)*

## 기술 스택 선택 근거

*(채워야 함)*

## 아키텍처 상세

*(채워야 함)*

## Phase 계획

### Phase 1

- 목표:
- 범위:
HEREDOC
  echo "  create: docs/PLAN.md"
fi

DST="${TARGET_ROOT}/docs/backlog/PHASE1.md"
if can_write "${DST}"; then
  cat > "${DST}" << 'HEREDOC'
# Product Backlog — Phase 1

## 상태 요약

| 항목 | 내용 |
| --- | --- |
| Phase | Phase 1 |
| 목표 | — |
| 상태 | In Progress |

## Active Candidates

<!-- 작업 항목 형식:
**P1-001** | Priority: P0 | Scope: 한 줄 설명
- Done Criteria:
- Verification:
- Preconditions:
-->

## Done
HEREDOC
  echo "  create: docs/backlog/PHASE1.md"
fi

DST="${TARGET_ROOT}/docs/backlog/HARNESS.md"
if can_write "${DST}"; then
  cat > "${DST}" << 'HEREDOC'
# Harness Backlog

## 상태 요약

| 항목 | 내용 |
| --- | --- |
| 목표 | AI 워크플로우 하네스 개선 및 유지 |
| 상태 | Active |

## Active Candidates

<!-- 작업 항목 형식:
**HRN-001** | Priority: P2 | Scope: 한 줄 설명
- Done Criteria:
- Verification:
-->

## Done
HEREDOC
  echo "  create: docs/backlog/HARNESS.md"
fi

# ── Empty directory placeholders ─────────────────────────────────────────────
touch "${TARGET_ROOT}/docs/archive/.gitkeep"
touch "${TARGET_ROOT}/docs/retrospectives/.gitkeep"
touch "${TARGET_ROOT}/docs/troubleshooting/.gitkeep"

# ── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "Done [mode: ${MODE}]"
echo ""
echo "  Harness scaffolded at: ${TARGET_ROOT}"
echo ""
echo "Required before first session (fill in):"
echo "  docs/STATUS.md         — 프로젝트 목표와 Phase 설명"
echo "  docs/PLAN-SUMMARY.md   — 기술 스택, 포트, 패키지 구조"
echo "  docs/backlog/PHASE1.md — 초기 작업 항목 P1-001~"
echo ""
echo "Adapt for your language/framework (or delete if not applicable):"
echo "  .claude/rules/java-spring.md  — Spring Boot 코딩 규칙"
echo "  .cursor/rules/java-spring.mdc — Spring Boot Cursor 규칙"
echo "  .claude/settings.json         — PostToolUse hook (언어 특화 시 추가)"
echo ""
echo "Spring Boot-specific prompts (delete if not using Spring Boot):"
echo "  prompts/02-scaffold-service.prompt.md"
echo "  prompts/04-security-review.prompt.md"
echo "  prompts/08-split-service.prompt.md"
echo "  prompts/10-add-validation.prompt.md"
echo "  prompts/11-add-resilience.prompt.md"
echo "  prompts/12-performance-fix.prompt.md"
echo "  prompts/13-add-metrics.prompt.md"
echo "  prompts/14-write-migration.prompt.md"
echo "  prompts/18-add-cache.prompt.md"
echo "  prompts/21-create-layer.prompt.md"
echo ""
echo "First session:"
echo "  cd ${TARGET_ROOT}"
echo "  claude        # Claude Code 열기"
echo "  /start        # 하네스 로딩 확인 및 현재 상태 요약"
