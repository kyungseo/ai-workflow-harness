#!/usr/bin/env bash
# create-harness.sh — generic AI workflow harness scaffolding.
#
# Usage:
#   scripts/create-harness.sh [flags] <project-name> [target-dir]
#
# Flags:
#   --dry-run, -n              Print the real create/skip plan without writing.
#   --existing, -e             Overlay mode for an existing project.
#                              Existing files are not overwritten.
#   --profile <name>           Optional extras: generic (default), spring-boot.
#
# Defaults:
#   New mode       — TARGET must not exist; creates everything fresh.
#   Existing mode  — TARGET is required and must point to an existing project.
#   target-dir     — temp/<project-name>/ under this template root (new mode only).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# ── Parse flags ──────────────────────────────────────────────────────────────
DRY_RUN=false
MODE="new"
PROFILE="generic"

while [[ "${1:-}" == --* || "${1:-}" == -* ]]; do
  case "${1}" in
    --dry-run|-n)
      DRY_RUN=true
      shift
      ;;
    --existing|-e)
      MODE="existing"
      shift
      ;;
    --profile)
      PROFILE="${2:?--profile requires a value: generic or spring-boot}"
      shift 2
      ;;
    --profile=*)
      PROFILE="${1#--profile=}"
      shift
      ;;
    *)
      echo "Unknown flag: $1" >&2
      exit 1
      ;;
  esac
done

case "${PROFILE}" in
  generic|spring-boot) ;;
  *)
    echo "ERROR: unsupported profile '${PROFILE}'. Use generic or spring-boot." >&2
    exit 1
    ;;
esac

PROJECT_NAME="${1:?Usage: $0 [--dry-run] [--existing] [--profile generic|spring-boot] <project-name> [target-dir]}"

if [[ "${MODE}" == "existing" ]]; then
  if [[ -z "${2:-}" ]]; then
    echo "ERROR: --existing requires <existing-project-root>." >&2
    echo "Usage: $0 --existing <project-name> <existing-project-root>" >&2
    exit 1
  fi
  TARGET_ROOT="$2"
else
  TARGET_ROOT="${2:-${TEMPLATE_ROOT}/temp/${PROJECT_NAME}}"
fi

# ── Guards ──────────────────────────────────────────────────────────────────
if [[ "${MODE}" == "new" && -d "${TARGET_ROOT}" ]]; then
  echo "ERROR: '${TARGET_ROOT}' already exists. Use --existing to overlay." >&2
  exit 1
fi

if [[ "${MODE}" == "existing" && ! -d "${TARGET_ROOT}" ]]; then
  echo "ERROR: existing project root does not exist: '${TARGET_ROOT}'." >&2
  exit 1
fi

TODAY="$(date +%Y-%m-%d)"

# ── Helpers ──────────────────────────────────────────────────────────────────
rel() {
  local path="$1"
  echo "${path#${TARGET_ROOT}/}"
}

ensure_dir() {
  local dir="$1"
  if [[ "${DRY_RUN}" == true ]]; then
    return
  fi
  mkdir -p "${dir}"
}

can_write() {
  local dst="$1"
  if [[ "${MODE}" == "existing" && -f "${dst}" ]]; then
    echo "  skip  : $(rel "${dst}")"
    return 1
  fi

  if [[ "${DRY_RUN}" == true ]]; then
    echo "  create: $(rel "${dst}")"
    return 1
  fi

  ensure_dir "$(dirname "${dst}")"
  return 0
}

adapt() {
  local src="$1" dst="$2"
  if can_write "${dst}"; then
    sed "s/base-msa-template/${PROJECT_NAME}/g" "${src}" > "${dst}"
    echo "  create: $(rel "${dst}")"
  fi
}

write_text() {
  local dst="$1" content="$2"
  if can_write "${dst}"; then
    printf "%s" "${content}" > "${dst}"
    echo "  create: $(rel "${dst}")"
  fi
}

touch_file() {
  local dst="$1"
  if can_write "${dst}"; then
    : > "${dst}"
    echo "  create: $(rel "${dst}")"
  fi
}

copy_prompt() {
  local name="$1"
  adapt "${TEMPLATE_ROOT}/prompts/${name}" "${TARGET_ROOT}/prompts/${name}"
}

if [[ "${DRY_RUN}" == true ]]; then
  echo "Dry-run [mode: ${MODE}, profile: ${PROFILE}] — target: ${TARGET_ROOT}"
else
  echo "Scaffolding AI workflow harness [mode: ${MODE}, profile: ${PROFILE}]"
  echo "  Project : ${PROJECT_NAME}"
  echo "  Target  : ${TARGET_ROOT}"
fi
echo ""

# ── Directory structure ──────────────────────────────────────────────────────
for dir in \
  "${TARGET_ROOT}/docs/backlog" \
  "${TARGET_ROOT}/docs/decisions" \
  "${TARGET_ROOT}/docs/harness-protocol" \
  "${TARGET_ROOT}/docs/works" \
  "${TARGET_ROOT}/docs/archive" \
  "${TARGET_ROOT}/docs/archive/docs/works" \
  "${TARGET_ROOT}/docs/retrospectives" \
  "${TARGET_ROOT}/docs/reports" \
  "${TARGET_ROOT}/docs/presentations" \
  "${TARGET_ROOT}/docs/troubleshooting" \
  "${TARGET_ROOT}/.claude/rules" \
  "${TARGET_ROOT}/.claude/commands" \
  "${TARGET_ROOT}/.cursor/rules" \
  "${TARGET_ROOT}/prompts"; do
  ensure_dir "${dir}"
done

# ── Root files ───────────────────────────────────────────────────────────────
adapt "${TEMPLATE_ROOT}/CLAUDE.md"     "${TARGET_ROOT}/CLAUDE.md"
adapt "${TEMPLATE_ROOT}/AGENTS.md"     "${TARGET_ROOT}/AGENTS.md"
adapt "${TEMPLATE_ROOT}/.claudeignore" "${TARGET_ROOT}/.claudeignore"
adapt "${TEMPLATE_ROOT}/.cursorignore" "${TARGET_ROOT}/.cursorignore"
adapt "${TEMPLATE_ROOT}/.gitignore"    "${TARGET_ROOT}/.gitignore"

# ── Harness protocol docs ────────────────────────────────────────────────────
adapt "${TEMPLATE_ROOT}/docs/AGENT-WORKFLOW.md" "${TARGET_ROOT}/docs/AGENT-WORKFLOW.md"

if [[ "${DRY_RUN}" != true && "${PROFILE}" == "generic" ]]; then
  perl -0pi -e 's/## Project Constants\n\n- Runtime: Java 21\+\n- Framework: Spring Boot 3\.5\.x\n- Build: Gradle wrapper\n- Architecture: Spring Boot microservices template\n- Base package: `io\.kyungseo\.msa`\n- Active state file: `docs\/STATUS\.md`\n\n## Verification Defaults\n\n- Java unit\/module change: `\.\/gradlew test`\n- Build\/config change: `\.\/gradlew build`\n- Gateway 또는 integration flow: 관련 checkpoint에 정의된 검증\n- Documentation-only change: diff와 링크 확인/## Project Constants\n\n- Runtime: [fill in]\n- Framework: [fill in]\n- Build: [fill in]\n- Architecture: [fill in]\n- Base package\/module: [fill in]\n- Active state file: `docs\/STATUS.md`\n\n## Verification Defaults\n\n- Unit\/module change: [fill in]\n- Build\/config change: [fill in]\n- Integration flow: 관련 checkpoint에 정의된 검증\n- Documentation-only change: diff와 링크 확인/s' "${TARGET_ROOT}/docs/AGENT-WORKFLOW.md"
fi

adapt "${TEMPLATE_ROOT}/docs/HARNESS-PROTOCOL.md"        "${TARGET_ROOT}/docs/HARNESS-PROTOCOL.md"
adapt "${TEMPLATE_ROOT}/docs/HARNESS-QUICK-REFERENCE.md" "${TARGET_ROOT}/docs/HARNESS-QUICK-REFERENCE.md"
adapt "${TEMPLATE_ROOT}/docs/WORKFLOW-MANUAL.md"         "${TARGET_ROOT}/docs/WORKFLOW-MANUAL.md"

for f in "${TEMPLATE_ROOT}"/docs/harness-protocol/*.md; do
  adapt "$f" "${TARGET_ROOT}/docs/harness-protocol/$(basename "$f")"
done

adapt "${TEMPLATE_ROOT}/docs/decisions/DECISION-TEMPLATE.md" \
      "${TARGET_ROOT}/docs/decisions/DECISION-TEMPLATE.md"

write_text "${TARGET_ROOT}/docs/troubleshooting/README.md" "# Troubleshooting

증상별 원인 분석과 조치 기록이다.

## 인덱스

| 증상 | 환경 | 파일 |
| --- | --- | --- |

## 작성 규칙

- 파일명: \`lowercase-hyphenated.md\`
- 구성: 증상 -> 원인 -> 조치 -> 검증 -> 관련 문서
- 해결 안 된 이슈는 \`docs/STATUS.md\` Blockers에 등록 후 해결 시 이 디렉터리로 이동
- 관련 결정이 DR-worthy이면 \`docs/decisions/DR-*.md\`로 별도 기록하고 역참조
"

# ── Claude Code config ───────────────────────────────────────────────────────
for f in docs-workflow.md git-workflow.md infra.md; do
  adapt "${TEMPLATE_ROOT}/.claude/rules/${f}" "${TARGET_ROOT}/.claude/rules/${f}"
done

if [[ "${PROFILE}" == "spring-boot" ]]; then
  adapt "${TEMPLATE_ROOT}/.claude/rules/java-spring.md" "${TARGET_ROOT}/.claude/rules/java-spring.md"
  adapt "${TEMPLATE_ROOT}/.claude/rules/testing.md" "${TARGET_ROOT}/.claude/rules/testing.md"
fi

for f in "${TEMPLATE_ROOT}"/.claude/commands/*.md; do
  adapt "$f" "${TARGET_ROOT}/.claude/commands/$(basename "$f")"
done

write_text "${TARGET_ROOT}/.claude/settings.json" '{
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
            "command": "python3 -c \"print('\''[hook] 세션 종료 전 확인: Work가 완료됐다면 /close를 먼저 실행하고, 그다음 /done으로 validation, Approval Matrix에 따른 상태 변경 필요 여부, DR-worthy 결정, commit 상태를 보고하세요.'\'')\""
          }
        ]
      }
    ]
  }
}
'

# ── Cursor config and rules ──────────────────────────────────────────────────
adapt "${TEMPLATE_ROOT}/.cursor/config.json" "${TARGET_ROOT}/.cursor/config.json"

for f in coding.mdc debugging.mdc execution.mdc git-commit.mdc output-format.mdc safety-critical.mdc workflow.mdc; do
  adapt "${TEMPLATE_ROOT}/.cursor/rules/${f}" "${TARGET_ROOT}/.cursor/rules/${f}"
done

if [[ "${PROFILE}" == "spring-boot" ]]; then
  adapt "${TEMPLATE_ROOT}/.cursor/rules/java-spring.mdc" "${TARGET_ROOT}/.cursor/rules/java-spring.mdc"
  adapt "${TEMPLATE_ROOT}/.cursor/rules/role-backend.mdc" "${TARGET_ROOT}/.cursor/rules/role-backend.mdc"
  adapt "${TEMPLATE_ROOT}/.cursor/rules/testing.mdc" "${TARGET_ROOT}/.cursor/rules/testing.mdc"
fi

# ── Prompts ──────────────────────────────────────────────────────────────────
for f in \
  00-generic-task.prompt.md \
  01-scaffold-project.prompt.md \
  03-add-single-feature.prompt.md \
  05-debug-error.prompt.md \
  06-write-tests-first.prompt.md \
  07-refactor-code.prompt.md \
  09-api-integration.prompt.md \
  15-write-readme.prompt.md \
  16-code-review.prompt.md \
  17-reproduce-and-fix.prompt.md \
  19-design-feature.prompt.md \
  20-summarize-work.prompt.md \
  22-minimal-diff.prompt.md \
  README.md \
  claude-session-start.md \
  codex-session-start.md \
  cursor-session-start.md; do
  copy_prompt "$f"
done

if [[ "${PROFILE}" == "spring-boot" ]]; then
  for f in \
    02-scaffold-service.prompt.md \
    04-security-review.prompt.md \
    08-split-service.prompt.md \
    10-add-validation.prompt.md \
    11-add-resilience.prompt.md \
    12-performance-fix.prompt.md \
    13-add-metrics.prompt.md \
    14-write-migration.prompt.md \
    18-add-cache.prompt.md \
    21-create-layer.prompt.md; do
    copy_prompt "$f"
  done
fi

# ── Generated README ─────────────────────────────────────────────────────────
write_text "${TARGET_ROOT}/README.md" "# ${PROJECT_NAME}

> [프로젝트 한 줄 설명 — 채워주세요]

## AI Workflow Harness

이 프로젝트는 Claude Code / Codex / Cursor 공통 AI 워크플로우 하네스를 포함합니다.

| 파일 | 역할 |
| --- | --- |
| \`CLAUDE.md\` | Claude Code 진입점 |
| \`AGENTS.md\` | Codex 진입점 |
| \`docs/STATUS.md\` | 현재 작업 상태 |
| \`docs/HARNESS-QUICK-REFERENCE.md\` | 세션 실행 규칙 요약 |
| \`docs/WORKFLOW-MANUAL.md\` | 사용자용 워크플로우 가이드 |
| \`docs/AGENT-WORKFLOW.md\` | 공통 운영 규칙 |
| \`docs/works/\` | Work 파일 (큰 작업의 SSoT) |
| \`.claude/commands/\` | \`/start\`, \`/pick\`, \`/register\`, \`/work\`, \`/close\`, \`/done\` 등 |
| \`prompts/\` | 세션 시작 및 태스크 프롬프트 라이브러리 |

### 첫 세션

**Claude Code:**
\`\`\`bash
claude        # Claude Code 열기
/start        # 하네스 로딩 확인 및 현재 상태 요약
\`\`\`

**Codex:** \`prompts/codex-session-start.md\` 내용을 세션 시작 시 붙여넣는다.

**Cursor:** \`prompts/cursor-session-start.md\` 내용을 세션 시작 시 붙여넣는다.

## 사전 작업

스캐폴딩 직후 아래 파일을 채운 뒤 첫 세션을 시작한다.

1. \`docs/STATUS.md\` — 프로젝트 목표와 Phase 설명
2. \`docs/PLAN-SUMMARY.md\` — 기술 스택, 포트, 패키지 구조
3. \`docs/backlog/PHASE1.md\` — 초기 작업 항목 \`P1-001~\`
4. \`docs/AGENT-WORKFLOW.md\` — Project Constants와 Verification Defaults

---

*Scaffolded ${TODAY} — [AI Workflow Harness](docs/WORKFLOW-MANUAL.md)*
"

# ── Skeleton docs ─────────────────────────────────────────────────────────────
write_text "${TARGET_ROOT}/docs/STATUS.md" "# STATUS.md — ${PROJECT_NAME}

## Current State

| 항목 | 내용 |
| --- | --- |
| Phase | Phase 1 — [프로젝트 목표 한 줄] |
| Active plan | — |
| Product backlog | \`docs/backlog/PHASE1.md\` |
| Harness backlog | \`docs/backlog/HARNESS.md\` |
| Last updated | ${TODAY} |

## Active Work

| ID | Priority | Status | Work File |
| --- | --- | --- | --- |

## Blockers And Open Questions

| ID | Status | Question | Decision Needed |
| --- | --- | --- | --- |

## Recent Decisions

*(없음)*

## Next Actions

1. 이 파일과 \`docs/PLAN-SUMMARY.md\`를 프로젝트 정보로 업데이트
2. \`docs/backlog/PHASE1.md\`에 초기 작업 항목 등록
3. \`docs/AGENT-WORKFLOW.md\` Project Constants와 Verification Defaults 채우기
4. Claude Code: \`/start\`로 첫 세션 시작 | Codex: \`prompts/codex-session-start.md\` 사용 | Cursor: \`prompts/cursor-session-start.md\` 사용
"

write_text "${TARGET_ROOT}/docs/PLAN-SUMMARY.md" "# PLAN-SUMMARY.md — ${PROJECT_NAME}

> 전체 근거와 상세 아키텍처: \`docs/PLAN.md\`

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
"

write_text "${TARGET_ROOT}/docs/PLAN.md" "# PLAN.md — ${PROJECT_NAME}

> 요약: \`docs/PLAN-SUMMARY.md\`

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
"

write_text "${TARGET_ROOT}/docs/backlog/PHASE1.md" "# Product Backlog — Phase 1

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
"

write_text "${TARGET_ROOT}/docs/backlog/HARNESS.md" "# Harness Backlog

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
"

write_text "${TARGET_ROOT}/docs/works/README.md" "# docs/works/

Work 파일 디렉토리. 큰 작업 단위의 Single Source of Truth.

카테고리 서브디렉토리와 그 안의 README.md는 첫 Work 파일 생성 시 함께 만든다.
Work 파일 스펙: \`docs/decisions/DR-013-work-file-spec.md\`
공통 운영 규칙: \`docs/harness-protocol/03-work-items-and-naming.md\` Work File Rules

## 카테고리

| 카테고리 | 경로 | 용도 |
| --- | --- | --- |
| phase1/ | docs/works/phase1/ | Phase 1 작업 |
| phase2/ | docs/works/phase2/ | Phase 2 작업 |
| harness/ | docs/works/harness/ | Harness 개선 작업 |

## Lifecycle

| Status | Location | Meaning |
| --- | --- | --- |
| Candidate | \`docs/works/{category}/\` 또는 backlog only | 착수 전 후보. 큰 작업은 Work 파일 초안을 가질 수 있다 |
| Active | \`docs/works/{category}/\` | \`docs/STATUS.md\` Active Work에 pointer 존재 |
| Done | \`docs/works/{category}/\` | 완료 검증 통과, archive 대기 가능 |
| Archived | \`docs/archive/docs/works/{category}/\` | 완전 종결 |
"

touch_file "${TARGET_ROOT}/docs/archive/.gitkeep"
touch_file "${TARGET_ROOT}/docs/archive/docs/works/.gitkeep"
touch_file "${TARGET_ROOT}/docs/retrospectives/.gitkeep"
touch_file "${TARGET_ROOT}/docs/reports/.gitkeep"
touch_file "${TARGET_ROOT}/docs/presentations/.gitkeep"

echo ""
if [[ "${DRY_RUN}" == true ]]; then
  echo "Dry-run complete. No files were written."
else
  echo "Done [mode: ${MODE}, profile: ${PROFILE}]"
  echo ""
  echo "  Harness scaffolded at: ${TARGET_ROOT}"
fi
echo ""
echo "Required before first session (fill in):"
echo "  docs/STATUS.md         — 프로젝트 목표와 Phase 설명"
echo "  docs/PLAN-SUMMARY.md   — 기술 스택, 포트, 패키지 구조"
echo "  docs/backlog/PHASE1.md — 초기 작업 항목 P1-001~"
echo "  docs/AGENT-WORKFLOW.md — Project Constants와 Verification Defaults"
echo ""
if [[ "${PROFILE}" == "generic" ]]; then
  echo "Profile: generic"
  echo "  Spring Boot/MSA-specific rules and prompts were not included."
  echo "  Use --profile spring-boot for this template's Java/Spring extras."
else
  echo "Profile: spring-boot"
  echo "  Included Java/Spring rules and Spring Boot prompt bundle."
fi
echo ""
echo "First session:"
echo "  cd ${TARGET_ROOT}"
echo "  claude        # Claude Code 열기"
echo "  /start        # 하네스 로딩 확인 및 현재 상태 요약"
