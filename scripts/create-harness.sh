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
    sed "s/ai-workflow-harness/${PROJECT_NAME}/g" "${src}" > "${dst}"
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
  "${TARGET_ROOT}/docs/works" \
  "${TARGET_ROOT}/docs/works/phase1" \
  "${TARGET_ROOT}/docs/works/harness" \
  "${TARGET_ROOT}/docs/archive" \
  "${TARGET_ROOT}/docs/archive/docs/works" \
  "${TARGET_ROOT}/docs/archive/snapshots" \
  "${TARGET_ROOT}/docs/retrospectives" \
  "${TARGET_ROOT}/docs/reports" \
  "${TARGET_ROOT}/docs/presentations" \
  "${TARGET_ROOT}/docs/troubleshooting" \
  "${TARGET_ROOT}/.claude/rules" \
  "${TARGET_ROOT}/.claude/commands" \
  "${TARGET_ROOT}/.cursor/rules" \
  "${TARGET_ROOT}/.agents/skills" \
  "${TARGET_ROOT}/.codex" \
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
adapt "${TEMPLATE_ROOT}/docs/BEHAVIOR-PRINCIPLES.md" "${TARGET_ROOT}/docs/BEHAVIOR-PRINCIPLES.md"
adapt "${TEMPLATE_ROOT}/docs/AGENT-WORKFLOW.md" "${TARGET_ROOT}/docs/AGENT-WORKFLOW.md"

adapt "${TEMPLATE_ROOT}/docs/HARNESS-PROTOCOL.md"          "${TARGET_ROOT}/docs/HARNESS-PROTOCOL.md"
adapt "${TEMPLATE_ROOT}/docs/HARNESS-QUICK-REFERENCE.md"   "${TARGET_ROOT}/docs/HARNESS-QUICK-REFERENCE.md"
adapt "${TEMPLATE_ROOT}/docs/HARNESS-STRUCTURE.md"         "${TARGET_ROOT}/docs/HARNESS-STRUCTURE.md"
adapt "${TEMPLATE_ROOT}/docs/HARNESS-MAINTAINER-GUIDE.md"  "${TARGET_ROOT}/docs/HARNESS-MAINTAINER-GUIDE.md"
adapt "${TEMPLATE_ROOT}/docs/WORKFLOW-MANUAL.md"           "${TARGET_ROOT}/docs/WORKFLOW-MANUAL.md"

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

# ── Codex skills ─────────────────────────────────────────────────────────────
for skill_dir in "${TEMPLATE_ROOT}"/.agents/skills/*/; do
  skill_name="$(basename "${skill_dir}")"
  ensure_dir "${TARGET_ROOT}/.agents/skills/${skill_name}"
  adapt "${skill_dir}SKILL.md" "${TARGET_ROOT}/.agents/skills/${skill_name}/SKILL.md"
done

adapt "${TEMPLATE_ROOT}/.codex/hooks.json" "${TARGET_ROOT}/.codex/hooks.json"

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
            "command": "python3 -c \"print('\''[hook] 세션 종료 전 확인: Work가 완료됐다면 /close를 먼저 실행하고, 그다음 /done으로 validation, STATUS/Tracking Finalization, Approval Matrix에 따른 상태 변경 필요 여부, DR-worthy 결정, commit 상태를 보고하세요.'\'')\""
          }
        ]
      }
    ]
  }
}
'

# ── Cursor config and rules ──────────────────────────────────────────────────
for f in behavior-principles.mdc coding.mdc debugging.mdc execution.mdc git-commit.mdc output-format.mdc role-harness-maintainer.mdc safety-critical.mdc workflow.mdc; do
  adapt "${TEMPLATE_ROOT}/.cursor/rules/${f}" "${TARGET_ROOT}/.cursor/rules/${f}"
done

if [[ "${PROFILE}" == "spring-boot" ]]; then
  adapt "${TEMPLATE_ROOT}/.cursor/rules/java-spring.mdc" "${TARGET_ROOT}/.cursor/rules/java-spring.mdc"
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
하네스는 Product track과 Harness track을 함께 운영하도록 설계되어 있습니다.
첫 세션에서는 프로젝트 identity, Product Definition, Project Initialization baseline을 먼저 정리한 뒤 Product track backlog를 만들고,
AI workflow 자체의 개선과 example pack 정비는 Harness track으로 분리합니다.

| Track | 목적 | 주요 파일 |
| --- | --- | --- |
| Product track | 실제 제품/서비스/콘텐츠 작업과 Phase backlog | \`docs/backlog/PHASE1.md\`, \`docs/works/phase1/\` |
| Harness track | AI workflow, command/rule, prompt, scaffold, process 개선 | \`docs/backlog/HARNESS.md\`, \`docs/works/harness/\` |

| 파일 | 역할 |
| --- | --- |
| \`CLAUDE.md\` | Claude Code 진입점 |
| \`AGENTS.md\` | Codex 진입점 |
| \`docs/BEHAVIOR-PRINCIPLES.md\` | 전역 행동 원칙 |
| \`docs/STATUS.md\` | 현재 작업 상태 |
| \`docs/HARNESS-QUICK-REFERENCE.md\` | 세션 실행 규칙 요약 |
| \`docs/HARNESS-STRUCTURE.md\` | harness 구조와 정보 흐름 시각화 |
| \`docs/HARNESS-MAINTAINER-GUIDE.md\` | 유지보수·convention 가이드 |
| \`docs/BOOTSTRAP.md\` | scaffold 직후 프로젝트 부팅 checklist |
| \`docs/WORKFLOW-MANUAL.md\` | 사용자용 워크플로우 가이드 |
| \`docs/AGENT-WORKFLOW.md\` | 공통 운영 규칙 |
| \`docs/works/\` | Work 파일 (큰 작업의 SSoT) |
| \`.claude/commands/\` | \`/start\`, \`/pick\`, \`/register\`, \`/work\`, \`/close\`, \`/done\` 등 |
| \`.agents/skills/\` | Codex command skill |
| \`.codex/hooks.json\` | Codex hook 설정 |
| \`prompts/\` | 세션 시작 및 태스크 프롬프트 라이브러리 |

### 첫 세션

**Claude Code:**
\`\`\`bash
claude        # Claude Code 열기
/start        # 하네스 로딩 확인 및 현재 상태 요약
\`\`\`

**Codex:** repo root의 \`AGENTS.md\`를 기본 진입점으로 사용하고, 세션 첫 요청은 \`/start\` intent로 시작한다. \`prompts/codex-session-start.md\`는 수동 bootstrap이 필요한 fallback이다.

**Cursor:** \`prompts/cursor-session-start.md\` 내용을 세션 시작 시 붙여넣는다.

## 사전 작업

git repository는 자동으로 초기화되지 않는다. 첫 세션에서 \`docs/BOOTSTRAP.md\` §0 Repository Setup을 따라 초기화 여부를 먼저 결정한다.

스캐폴딩 직후 첫 \`/start\`에서는 \`docs/STATUS.md\` Next Actions를 확인한다.
Next Actions가 scaffold bootstrap/onboarding을 가리키면 \`docs/BOOTSTRAP.md\`를 §0부터 순서대로 채운다.
Bootstrap onboarding에 사용할 prompt는 \`docs/BOOTSTRAP.md\` §8에 있다.

1. \`docs/STATUS.md\` — 프로젝트 목표와 Phase 설명
2. \`docs/PLAN-SUMMARY.md\` Project Summary — 제품 목표와 핵심 workflow
3. \`docs/PLAN-SUMMARY.md\` Implementation Baseline — Runtime/Framework/Build/package 결정 (코드 개발 프로젝트)
4. \`docs/PLAN.md\` Project Initialization Plan — stack 선택 근거와 초기 구조
5. \`docs/backlog/PHASE1.md\` — baseline 완료 후 도출한 초기 작업 항목 (Work ID는 /work 착수 시 확정)
6. \`docs/BEHAVIOR-PRINCIPLES.md\` — 전역 행동 원칙 확인
7. \`docs/AGENT-WORKFLOW.md\` — Project Constants와 Verification Defaults

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
| Bootstrap checklist | \`docs/BOOTSTRAP.md\` |
| Project backlog | \`docs/backlog/PHASE1.md\` |
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

1. Scaffold bootstrap onboarding: \`docs/BOOTSTRAP.md\`를 §0부터 순서대로 채운다
2. §1 Project Identity, §2 Product Definition 완료 후 \`docs/PLAN-SUMMARY.md\` Project Summary 업데이트
3. §3 Project Initialization: \`docs/PLAN-SUMMARY.md\` Implementation Baseline 채우기 (코드 개발 프로젝트만)
4. Implementation Baseline 완료 후 \`docs/backlog/PHASE1.md\`에 초기 작업 후보 등록 (Work ID는 /work 착수 시 확정)
5. \`docs/AGENT-WORKFLOW.md\` Project Constants와 Verification Defaults 채우기
6. AI workflow 개선 항목은 \`docs/backlog/HARNESS.md\`로 분리
7. Claude Code: \`/start\`로 첫 세션 시작 | Codex: \`AGENTS.md\` 확인 후 \`/start\` intent 실행 | Cursor: \`prompts/cursor-session-start.md\` 사용
"

write_text "${TARGET_ROOT}/docs/BOOTSTRAP.md" "# BOOTSTRAP.md — ${PROJECT_NAME}

Scaffold 직후 이 파일을 먼저 채운다. 목표는 빈 harness를 프로젝트 identity와 production 성격에 맞게 부팅하는 것이다.

## 0. Repository Setup

- [ ] git repository 초기화 여부 확인: \`git status\` 또는 \`ls .git/\` 실행. \`git status\`가 not a git repository 메시지로 실패하면 no-git bootstrap 상태로 판단
- [ ] git repository가 없으면 사용자 승인 후 \`git init\`, default branch 결정, initial commit 여부 결정
- [ ] git repository가 없는 동안 commit/PR/branch workflow, \`related_commits\`, \`git diff\` 기반 검증은 \`Not Applicable\`로 처리
- [ ] \`--existing\` overlay인 경우: 기존 branch/remote 정책을 먼저 확인하고, harness Gitflow를 무조건 강제하지 않는다

## 1. Project Identity

| 항목 | 내용 |
| --- | --- |
| 프로젝트 이름 | ${PROJECT_NAME} |
| 한 줄 설명 | — |
| 주요 사용자 | — |
| production 성격 | product / service / library / content / research / internal tool / other |
| 배포 또는 공개 방식 | private / public / internal / hosted / package / other |
| 핵심 성공 기준 | — |

## 2. Product Definition

제품 목표와 성공 기준을 먼저 확정한다. 이 단계가 완료되지 않으면 Phase 1 backlog를 만들지 않는다.

- [ ] Phase 1 목표를 한 문장으로 정리
- [ ] 주요 사용자와 첫 사용 시나리오 정리
- [ ] 핵심 성공 기준 정의 (§1 Project Identity에서 채운 항목 재확인)
- [ ] \`docs/PLAN-SUMMARY.md\` Project Summary를 이 정보로 업데이트

## 3. Project Initialization

코드 개발이 필요한 프로젝트만 해당한다. code development가 없는 프로젝트(content/research/no-code 운영 등)는 이 단계를 Not Applicable로 처리한다.

- [ ] \`docs/PLAN-SUMMARY.md\` Implementation Baseline 표의 항목을 하나씩 결정한다
- [ ] 결정된 항목은 Readiness를 Ready로 업데이트한다
- [ ] 코드 개발이 필요 없는 항목은 Readiness를 Not Applicable로 표시한다
- [ ] 결정 근거는 \`docs/PLAN.md\` Project Initialization Plan에 기록한다
- [ ] \`docs/AGENT-WORKFLOW.md\` Project Constants 작성 (Runtime, Framework, Build, Base package/module, Architecture)

> 이 단계가 완료(또는 Not Applicable 처리)되지 않으면 \`docs/backlog/PHASE1.md\`에 기능 후보를 등록하지 않는다.
> 기능 candidate 제안 전에 Implementation Baseline Readiness를 먼저 확인한다.

## 4. Phase 1 Backlog Derivation

§2 Product Definition과 §3 Project Initialization이 완료된 뒤 Product track backlog를 도출한다.

- [ ] \`docs/backlog/PHASE1.md\` Active Candidates에 초기 작업 후보 등록 (Work ID는 /work 착수 시 확정)
- [ ] 각 후보에 Done Criteria, Verification, Preconditions 작성
- [ ] 즉시 착수할 항목이 있으면 \`docs/STATUS.md\` Active Work로 올릴 내용 제안
- [ ] 큰 작업이면 \`docs/works/phase1/\`에 Work 파일 생성 여부 판단
- [ ] 완료 후 \`docs/STATUS.md\` Next Actions에서 scaffold bootstrap onboarding 항목 제거 또는 다음 실제 작업으로 교체

## 5. Harness Track Setup

AI workflow 자체의 조정은 Harness track으로 분리한다.

- [ ] tool entrypoint(\`AGENTS.md\`, \`CLAUDE.md\`)가 프로젝트에 맞는지 확인
- [ ] \`docs/AGENT-WORKFLOW.md\` Verification Defaults 작성
- [ ] \`README.md\`, \`docs/PLAN-SUMMARY.md\`, \`AGENTS.md\`, \`CLAUDE.md\`에 프로젝트 identity 보정이 필요한지 확인
- [ ] \`.claude/rules/\`, \`.cursor/rules/\`, \`prompts/\`에 role/rule/prompt naming 보정이 필요한지 확인
- [ ] command/rule/prompt 조정이 필요하면 \`docs/backlog/HARNESS.md\`에 후보 등록 (Work ID는 /work 착수 승인 시 확정)
- [ ] \`docs/works/harness/\` Work 파일이 필요한 규모인지 판단

## 6. Core Document Fill Order

1. \`docs/BOOTSTRAP.md\` — identity, production 성격, setup checklist
2. \`docs/STATUS.md\` — 현재 phase, Active Work, OQ, Next Actions
3. \`docs/PLAN-SUMMARY.md\` Project Summary — 프로젝트 요약, 제품 목표
4. \`docs/PLAN-SUMMARY.md\` Implementation Baseline — Runtime/Framework/Build/package 결정 (코드 프로젝트)
5. \`docs/PLAN.md\` Project Initialization Plan — stack 선택 근거, 초기 구조 (코드 프로젝트)
6. \`docs/backlog/PHASE1.md\` — Product track backlog (baseline 완료 후)
7. \`docs/backlog/HARNESS.md\` — Harness track backlog
8. \`docs/AGENT-WORKFLOW.md\` — Project Constants, Verification Defaults

## 7. Example Pack Review

\`generic\` profile이면 아래 항목은 기본적으로 포함되지 않는다. \`spring-boot\` 또는 다른 stack-specific pack을 선택했다면 프로젝트 identity에 맞게 정비한다.

- [ ] 포함된 example pack이 실제 production 성격과 맞는지 확인
- [ ] stack-specific rule glob이 실제 source path와 맞는지 확인
- [ ] role 파일명이 역할과 일치하는지 확인 (예: backend 전용이 아니면 \`role-backend\` 같은 이름을 쓰지 않음)
- [ ] prompt description과 package/path placeholder가 프로젝트명이나 조직명으로 고정되어 있지 않은지 확인
- [ ] README와 manual에 example pack이 optional임을 명시
- [ ] 필요 없는 example pack은 제거하거나 \`docs/backlog/HARNESS.md\`에 정리 작업으로 등록

## 8. First Session Prompt

\`\`\`text
docs/BEHAVIOR-PRINCIPLES.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md, docs/BOOTSTRAP.md를 읽어줘.

이 프로젝트를 scaffold 직후 부팅하려고 해.
다음 순서로 제안해줘:

1. 프로젝트 identity와 production 성격 확인 (§1)
2. Product Definition: 제품 목표, 주요 사용자, 성공 기준 (§2)
3. Project Initialization: PLAN-SUMMARY.md Implementation Baseline 결정 (§3, 코드 개발 프로젝트만)
4. Implementation Baseline이 비어 있으면 feature candidate 대신 Project Initialization을 첫 후보로 제안
5. Harness track 정비 항목, example pack 정비 필요 여부 (§5, §7)

파일 수정은 내 승인 전까지 하지 마.
\`\`\`

## 9. Completion Rule

Bootstrap onboarding은 \`docs/STATUS.md\` Next Actions의 pointer로만 다시 발견된다.
이 checklist를 채우고 Product/Harness backlog 후보를 만든 뒤에는 \`docs/STATUS.md\` Next Actions에서 scaffold bootstrap onboarding 항목을 제거하거나 다음 실제 작업으로 교체한다.
항목이 남아 있으면 daily \`/start\`가 매 세션 bootstrap 후속 작업을 계속 제안한다.
"

write_text "${TARGET_ROOT}/docs/PLAN-SUMMARY.md" "# PLAN-SUMMARY.md — ${PROJECT_NAME}

> 전체 근거와 상세 아키텍처: \`docs/PLAN.md\`

## Project Summary

| 항목 | 내용 |
| --- | --- |
| 프로젝트 목표 | — |
| 주요 사용자 | — |
| production 성격 | — |
| 배포 또는 공개 방식 | — |
| 제품 핵심 workflow | — |
| AI 작업 도구 | Claude Code / Codex / Cursor |
| 주요 제약 조건 | — |

## Implementation Baseline

코드 개발이 없는 프로젝트(content/research/no-code 운영 등)는 전체 표를 Not Applicable로 처리한다.
baseline이 비어 있으면 feature candidate은 Not Ready로 보고하고, 첫 후보로 Project Initialization을 제안한다.

| 항목 | 결정 내용 | Readiness |
| --- | --- | --- |
| Runtime / Language | — | Not Started |
| Framework / Library | — | Not Started |
| Build tool | — | Not Started |
| Base package / Module | — | Not Started |
| Module shape | — | Not Started |
| Data storage | — | Not Started |
| Profiles / Environments | — | Not Started |
| Verification defaults | — | Not Started |

*(Readiness: Not Started / Partial / Ready / Not Applicable)*

## Core Architecture

*(entrypoint, state files, product/harness backlog, decision records, validation flow를 채워야 함)*

## Verification Defaults

*(채워야 함)*

## Active References

*(채워야 함)*
"

write_text "${TARGET_ROOT}/docs/PLAN.md" "# PLAN.md — ${PROJECT_NAME}

> 요약: \`docs/PLAN-SUMMARY.md\`

## 목표

*(채워야 함)*

## Project Initialization Plan

*(code development가 필요한 프로젝트만 작성. 코드 개발이 없으면 Not Applicable로 표기한다.)*

### Stack Choices

*(Runtime, Framework, Build tool, Base package/module, Module shape 결정 근거)*

### Initial Structure

*(directory/package 구조, 실행 entrypoint, local run command)*

### Dependency Rationale

*(의존성 선택 이유와 추가 기준)*

### Phase 1 Readiness Checklist

*(PLAN-SUMMARY.md Implementation Baseline이 Ready 상태여야 Phase 1 feature 후보 등록 가능)*

- [ ] Runtime / Language 확정
- [ ] Framework / Library 확정
- [ ] Build tool 확정
- [ ] Base package / Module 확정
- [ ] Data storage 확정 또는 Not Applicable
- [ ] Profiles / Environments 확정
- [ ] Verification defaults 확정

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
| 제품 목표 | — |
| 주요 사용자 | — |
| Phase 1 범위 | — |
| 상태 | In Progress |

## Active Candidates

> **Baseline Gate**: \`docs/PLAN-SUMMARY.md\` Implementation Baseline이 비어 있으면 feature candidate은 Not Ready로 보고하고, 첫 후보로 Project Initialization을 제안한다.
> code development가 필요한 프로젝트: 첫 후보는 Project Initialization (Work ID는 /work 착수 시 확정).
> code development가 없는 프로젝트(content/research/no-code 운영 등): 해당 project type의 baseline/setup 작업으로 대체.

제품 목표에서 도출한 후보 작업을 우선 등록한다.
AI workflow, command/rule, prompt, scaffold 개선은 \`docs/backlog/HARNESS.md\`로 분리한다.

<!-- 작업 항목 형식:
**[Project Initialization]** | Priority: P0 | Scope: 한 줄 설명
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

<!-- 작업 항목 형식 (Work ID는 /work 착수 승인 시 CHORE-YYYYMMDD-NNN 형식으로 확정):
**[작업 제목]** | Priority: P2 | Scope: 한 줄 설명
- Done Criteria:
- Verification:
-->

## Done
"

write_text "${TARGET_ROOT}/docs/works/README.md" "# docs/works/

Work 파일 디렉토리. 큰 작업 단위의 Single Source of Truth.

Work 파일 스펙: \`docs/decisions/DR-013-work-file-spec.md\`
공통 운영 규칙: \`docs/HARNESS-PROTOCOL.md\` Work File Rules

## 카테고리

| 카테고리 | 경로 | 용도 |
| --- | --- | --- |
| phase1/ | \`docs/works/phase1/\` | Product track Phase 1 작업 |
| harness/ | \`docs/works/harness/\` | Harness track 개선 작업 |

## Lifecycle

| Status | Location | Meaning |
| --- | --- | --- |
| Active | \`docs/works/{category}/\` | \`docs/STATUS.md\` Active Work에 pointer 존재 |
| Done | \`docs/works/{category}/\` | 완료 검증 통과, archive 대기 가능 |
| Archived | \`docs/archive/docs/works/{category}/\` | 완전 종결 |

Backlog \`Candidate\`는 후보 pool이다. Work 파일은 착수 승인 후 \`Active\` 상태로 생성한다.
"

write_text "${TARGET_ROOT}/docs/works/phase1/README.md" "# Phase 1 Work Index

Product track Phase 1 작업 인덱스다.

## Active

| ID | Title | Priority | Start | Work File |
| --- | --- | --- | --- | --- |

## Done (Archive Pending)

| ID | Title | actual_end | Hold Reason |
| --- | --- | --- | --- |

## Archived

| ID | Title | actual_end | Archive |
| --- | --- | --- | --- |
"

write_text "${TARGET_ROOT}/docs/works/harness/README.md" "# Harness Work Index

Harness track 작업 인덱스다.

## Active

| ID | Title | Priority | Start | Work File |
| --- | --- | --- | --- | --- |

## Done (Archive Pending)

| ID | Title | actual_end | Hold Reason |
| --- | --- | --- | --- |

## Archived

| ID | Title | actual_end | Archive |
| --- | --- | --- | --- |
"

touch_file "${TARGET_ROOT}/docs/archive/.gitkeep"
touch_file "${TARGET_ROOT}/docs/archive/docs/works/.gitkeep"
touch_file "${TARGET_ROOT}/docs/archive/snapshots/.gitkeep"
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
echo "Bootstrap onboarding targets (propose/fill during first session):"
echo "  docs/BOOTSTRAP.md      — 프로젝트 identity와 production 성격 기반 setup checklist"
echo "  docs/STATUS.md         — 프로젝트 목표와 Phase 설명"
echo "  docs/PLAN-SUMMARY.md   — Project Summary와 Implementation Baseline"
echo "  docs/PLAN.md           — Project Initialization Plan"
echo "  docs/backlog/PHASE1.md — baseline 완료 후 도출한 초기 작업 항목 (Work ID는 /work 착수 시 확정)"
echo "  docs/AGENT-WORKFLOW.md — Project Constants와 Verification Defaults"
echo ""
if [[ "${PROFILE}" == "generic" ]]; then
  echo "Profile: generic"
  echo "  Spring Boot example-pack rules and prompts were not included."
  echo "  Use --profile spring-boot only when Java/Spring examples are useful."
else
  echo "Profile: spring-boot"
  echo "  Included Java/Spring example rules and Spring Boot prompt bundle."
fi
if [[ ! -d "${TARGET_ROOT}/.git" ]]; then
  echo "Note: git repository is not initialized. Follow docs/BOOTSTRAP.md §0 to decide when to run git init."
  echo "  Until then, commit/PR/branch workflow is Not Applicable."
fi
echo ""
echo "First session:"
echo "  cd ${TARGET_ROOT}"
echo "  claude        # Claude Code 열기"
echo "  /start        # 하네스 로딩 확인 및 현재 상태 요약"
echo "  codex         # Codex 사용 시 AGENTS.md 확인 후 /start intent로 시작"
