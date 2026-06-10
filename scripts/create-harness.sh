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
#   --workflow <name>          Workflow mode: generic (default), source-gitflow.
#                              source-gitflow adds docs/GIT-WORKFLOW.md with
#                              policy_type: source-gitflow marker and full
#                              Gitflow branch isolation rules.
#   --with-optional            Include the Optional source pack (DR-021): heavy
#                              framework docs (HARNESS-ARCHITECTURE,
#                              HARNESS-MAINTAINER-GUIDE, WORKFLOW-MANUAL),
#                              extended prompt bundle, and their companion DRs
#                              (DR-017, DR-020 — reference closure). Default
#                              output is minimal.
#   --check <target-dir>       Report-only drift check. Reads the target's
#                              .harness/manifest.json and compares each tracked
#                              framework file against the current source
#                              template (normalized hash). Does not scaffold.
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
WORKFLOW_MODE="generic"
WITH_OPTIONAL=false
CHECK_MODE=false

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
    --workflow)
      WORKFLOW_MODE="${2:?--workflow requires a value: generic or source-gitflow}"
      shift 2
      ;;
    --workflow=*)
      WORKFLOW_MODE="${1#--workflow=}"
      shift
      ;;
    --with-optional)
      WITH_OPTIONAL=true
      shift
      ;;
    --check)
      CHECK_MODE=true
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

case "${WORKFLOW_MODE}" in
  generic|source-gitflow) ;;
  *)
    echo "ERROR: unsupported workflow '${WORKFLOW_MODE}'. Use generic or source-gitflow." >&2
    exit 1
    ;;
esac

# --check mode takes a single positional <target-dir> and skips scaffolding setup.
if [[ "${CHECK_MODE}" == true ]]; then
  CHECK_TARGET="${1:?Usage: $0 --check <target-dir>}"
else
  PROJECT_NAME="${1:?Usage: $0 [--dry-run] [--existing] [--profile generic|spring-boot] [--workflow generic|source-gitflow] [--with-optional] <project-name> [target-dir]}"

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
fi

# ── Guards (scaffold modes only) ─────────────────────────────────────────────
if [[ "${CHECK_MODE}" != true ]]; then
  if [[ "${MODE}" == "new" && -d "${TARGET_ROOT}" ]]; then
    echo "ERROR: '${TARGET_ROOT}' already exists. Use --existing to overlay." >&2
    exit 1
  fi

  if [[ "${MODE}" == "existing" && ! -d "${TARGET_ROOT}" ]]; then
    echo "ERROR: existing project root does not exist: '${TARGET_ROOT}'." >&2
    exit 1
  fi
fi

TODAY="$(date +%Y-%m-%d)"

# Harness version (manifest baseline). Root VERSION file is the single bump point.
if [[ -f "${TEMPLATE_ROOT}/VERSION" ]]; then
  HARNESS_VERSION="$(tr -d ' \t\n\r' < "${TEMPLATE_ROOT}/VERSION")"
else
  HARNESS_VERSION="0.0.0-dev"
fi
SOURCE_IDENTITY="ai-workflow-harness"

# ── Helpers ──────────────────────────────────────────────────────────────────
rel() {
  local path="$1"
  echo "${path#${TARGET_ROOT}/}"
}

# sha256 of a file's raw bytes (portable: Linux sha256sum / macOS shasum).
sha256_of() {
  local f="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "${f}" | awk '{print $1}'
  else
    shasum -a 256 "${f}" | awk '{print $1}'
  fi
}

# Manifest accumulator: adapt() appends one JSON object per framework file.
# Hash basis = normalized source-template hash (DR-021/023 / OQ-10):
# the source file before single-token substitution, so it is project-agnostic.
MANIFEST_ROWS=""

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
    # Record this framework-owned file in the manifest accumulator.
    # path = target-relative, src = template-relative (re-hash anchor for --check).
    local rel_dst rel_src h
    rel_dst="$(rel "${dst}")"
    rel_src="${src#${TEMPLATE_ROOT}/}"
    h="$(sha256_of "${src}")"
    MANIFEST_ROWS="${MANIFEST_ROWS}    {\"path\": \"${rel_dst}\", \"src\": \"${rel_src}\", \"sha256\": \"${h}\"},
"
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

# ── --check: report-only drift diagnostic ────────────────────────────────────
# Compares each framework file recorded in the target manifest against the
# current source template (normalized hash). Report-only; writes nothing.
# Statuses: in-sync / source-updated (primary) / locally-modified (advisory) /
#           source-missing / target-missing.
# source-updated takes precedence: when the source template changed, local edits
# cannot be cleanly separated without an at-generation snapshot.
# Exit: 0 = clean or drift-only, 2 = invalid manifest, 3 = untracked target.
do_check() {
  local target="$1"
  local manifest="${target}/.harness/manifest.json"

  if [[ ! -d "${target}" ]]; then
    echo "ERROR: target dir not found: ${target}" >&2
    return 2
  fi
  if [[ ! -f "${manifest}" ]]; then
    echo "untracked target / pre-manifest scaffold: ${target}"
    echo "  (.harness/manifest.json 없음 — manifest 도입 이전 scaffold이거나 harness 비대상)"
    echo "  migration note: --check만으로 범위를 판단하지 말고 command/skill/rule inventory를 먼저 작성하세요."
    return 3
  fi

  # field extractor for my own controlled single-line JSON format
  local field
  field() { grep "\"$1\"" "${manifest}" | head -1 | sed -E "s/.*\"$1\": \"?([^\",]*)\"?.*/\1/"; }

  local m_version m_project
  m_version="$(field harness_version)"
  m_project="$(field project_name)"
  if [[ -z "${m_version}" || -z "${m_project}" ]] || ! grep -q '"framework_files"' "${manifest}"; then
    echo "ERROR: invalid manifest (harness_version/project_name/framework_files 누락): ${manifest}" >&2
    echo "migration note: manifest가 오래되었거나 불완전하면 command/skill/rule inventory를 먼저 작성하세요." >&2
    return 2
  fi

  # Enforcement posture from workflow_mode. workflow_mode is intentionally NOT in
  # the invalid-manifest set above: an old/partial manifest without it degrades to
  # `unknown` rather than failing. The label reflects deployed hook *files* only —
  # workflow_mode does not prove `.git/hooks` installation, so source-gitflow is
  # reported `hook-capable`, never `hook-gated` (no overclaim of active enforcement).
  local m_workflow posture
  # `|| true`: workflow_mode is optional (degrade target). Under `set -euo pipefail`
  # a missing field makes field()'s grep fail and pipefail would abort the script,
  # so tolerate the empty result and fall through to the `unknown` posture.
  m_workflow="$(field workflow_mode || true)"
  case "${m_workflow}" in
    generic)        posture="advisory-only (no hook files)" ;;
    source-gitflow) posture="hook-capable (source-gitflow hook files present; run tools/git-hooks/install.sh to activate)" ;;
    *)              posture="unknown (workflow_mode not recorded)" ;;
  esac

  # Project gate config (Class B, not in framework_files). Report-only: presence +
  # count of active (non-comment, non-blank, non-section-header) path entries. A
  # missing config is advisory (defaults only), never counted as drift.
  local gate_cfg gate_entries gate_line
  gate_cfg="${target}/.harness/gate-config"
  if [[ -f "${gate_cfg}" ]]; then
    gate_entries="$(grep -vE '^[[:space:]]*(#|\[|$)' "${gate_cfg}" | grep -cE '[^[:space:]]' || true)"
    gate_line=".harness/gate-config present (${gate_entries} project path(s))"
  else
    gate_line="none (.harness/gate-config absent; defaults only)"
  fi

  echo "harness --check: ${target}"
  echo "  manifest version : ${m_version}   (current source: ${HARNESS_VERSION})"
  [[ "${m_version}" != "${HARNESS_VERSION}" ]] && echo "  version delta    : ${m_version} -> ${HARNESS_VERSION}"
  echo "  enforcement      : ${posture}"
  echo "  gate config      : ${gate_line}"
  echo ""

  local total=0 insync=0 drift=0
  local line rel_dst rel_src recorded cur_src_hash tgt_hash rendered_hash status
  local check_list
  check_list="$(mktemp)"

  # iterate framework_files entries: select by "path" (entry-only; avoids the
  # hash_algorithm metadata line). '|| true' so an empty set does not trip set -e.
  grep '"path"' "${manifest}" > "${check_list}" 2>/dev/null || true
  if [[ ! -s "${check_list}" ]]; then
    echo "ERROR: invalid manifest (framework_files 엔트리 없음): ${manifest}" >&2
    rm -f "${check_list}"
    return 2
  fi
  while IFS= read -r line; do
    [[ "${line}" == *'"path"'* ]] || continue
    rel_dst="$(printf '%s' "${line}" | sed -E 's/.*"path": "([^"]*)".*/\1/')"
    rel_src="$(printf '%s' "${line}" | sed -E 's/.*"src": "([^"]*)".*/\1/')"
    recorded="$(printf '%s' "${line}" | sed -E 's/.*"sha256": "([^"]*)".*/\1/')"
    total=$((total + 1))

    if [[ ! -f "${TEMPLATE_ROOT}/${rel_src}" ]]; then
      status="source-missing"
    elif [[ ! -f "${target}/${rel_dst}" ]]; then
      status="target-missing"
    else
      cur_src_hash="$(sha256_of "${TEMPLATE_ROOT}/${rel_src}")"
      if [[ "${cur_src_hash}" != "${recorded}" ]]; then
        # source evolved since scaffold (primary signal). Local edits cannot be
        # cleanly separated without an at-generation snapshot, so report
        # source-updated.
        status="source-updated"
      else
        # source unchanged: forward-render the current template with the target's
        # project name (same substitution adapt() used) and compare to the target
        # file. Forward rendering is reliable; reverse-normalizing over-replaces
        # common project-name substrings.
        rendered_hash="$(sed "s/${SOURCE_IDENTITY}/${m_project}/g" "${TEMPLATE_ROOT}/${rel_src}" | sha256_of /dev/stdin)"
        tgt_hash="$(sha256_of "${target}/${rel_dst}")"
        if [[ "${tgt_hash}" != "${rendered_hash}" ]]; then
          status="locally-modified"
        else
          status="in-sync"
        fi
      fi
    fi

    if [[ "${status}" == "in-sync" ]]; then
      insync=$((insync + 1))
    else
      drift=$((drift + 1))
      echo "  [${status}] ${rel_dst}"
    fi
  done < "${check_list}"
  rm -f "${check_list}"

  echo ""
  echo "summary: ${total} tracked, ${insync} in-sync, ${drift} drifted"
  echo "  (source-updated=primary signal, locally-modified=advisory)"
  return 0
}

if [[ "${CHECK_MODE}" == true ]]; then
  do_check "${CHECK_TARGET}"
  exit $?
fi

if [[ "${DRY_RUN}" == true ]]; then
  echo "Dry-run [mode: ${MODE}, profile: ${PROFILE}, workflow: ${WORKFLOW_MODE}] — target: ${TARGET_ROOT}"
else
  echo "Scaffolding AI workflow harness [mode: ${MODE}, profile: ${PROFILE}, workflow: ${WORKFLOW_MODE}]"
  echo "  Project : ${PROJECT_NAME}"
  echo "  Target  : ${TARGET_ROOT}"
fi
echo ""

# ── Directory structure ──────────────────────────────────────────────────────
for dir in \
  "${TARGET_ROOT}/docs/backlog" \
  "${TARGET_ROOT}/docs/decisions" \
  "${TARGET_ROOT}/docs/works" \
  "${TARGET_ROOT}/docs/works/product" \
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
  "${TARGET_ROOT}/.harness" \
  "${TARGET_ROOT}/skills/workflow" \
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
adapt "${TEMPLATE_ROOT}/docs/HARNESS-NAMING-RULES.md"         "${TARGET_ROOT}/docs/HARNESS-NAMING-RULES.md"
adapt "${TEMPLATE_ROOT}/docs/HARNESS-RECOVERY-VALIDATION.md"  "${TARGET_ROOT}/docs/HARNESS-RECOVERY-VALIDATION.md"
adapt "${TEMPLATE_ROOT}/docs/HARNESS-PARALLEL-WORK-CONTROLS.md" \
      "${TARGET_ROOT}/docs/HARNESS-PARALLEL-WORK-CONTROLS.md"
adapt "${TEMPLATE_ROOT}/docs/HARNESS-QUICK-REFERENCE.md"      "${TARGET_ROOT}/docs/HARNESS-QUICK-REFERENCE.md"

# Optional source pack (DR-021): heavy framework docs. Default scaffold excludes
# them to keep target context minimal; --with-optional opts in.
if [[ "${WITH_OPTIONAL}" == true ]]; then
  adapt "${TEMPLATE_ROOT}/docs/HARNESS-ARCHITECTURE.md"      "${TARGET_ROOT}/docs/HARNESS-ARCHITECTURE.md"
  adapt "${TEMPLATE_ROOT}/docs/HARNESS-MAINTAINER-GUIDE.md"  "${TARGET_ROOT}/docs/HARNESS-MAINTAINER-GUIDE.md"
  adapt "${TEMPLATE_ROOT}/docs/WORKFLOW-MANUAL.md"           "${TARGET_ROOT}/docs/WORKFLOW-MANUAL.md"
fi

adapt "${TEMPLATE_ROOT}/docs/decisions/DECISION-TEMPLATE.md" \
      "${TARGET_ROOT}/docs/decisions/DECISION-TEMPLATE.md"
adapt "${TEMPLATE_ROOT}/docs/decisions/DR-007-language-policy.md" \
      "${TARGET_ROOT}/docs/decisions/DR-007-language-policy.md"
adapt "${TEMPLATE_ROOT}/docs/decisions/DR-008-docs-filename-standard.md" \
      "${TARGET_ROOT}/docs/decisions/DR-008-docs-filename-standard.md"
adapt "${TEMPLATE_ROOT}/docs/decisions/DR-013-work-file-spec.md" \
      "${TARGET_ROOT}/docs/decisions/DR-013-work-file-spec.md"
adapt "${TEMPLATE_ROOT}/docs/decisions/DR-014-archive-policy.md" \
      "${TARGET_ROOT}/docs/decisions/DR-014-archive-policy.md"
adapt "${TEMPLATE_ROOT}/docs/decisions/DR-027-troubleshooting-retrospective-spec.md" \
      "${TARGET_ROOT}/docs/decisions/DR-027-troubleshooting-retrospective-spec.md"
adapt "${TEMPLATE_ROOT}/docs/decisions/DR-029-dr-registration-triage-draft-lifecycle.md" \
      "${TARGET_ROOT}/docs/decisions/DR-029-dr-registration-triage-draft-lifecycle.md"

# Optional-pack companion DRs (DR-021 reference closure): the Optional source pack
# docs reference DR-020 (HARNESS-MAINTAINER-GUIDE), which transitively cites DR-017.
# Copy them only with --with-optional so default minimal output does not re-inflate.
OPTIONAL_DR_ROWS=""
if [[ "${WITH_OPTIONAL}" == true ]]; then
  adapt "${TEMPLATE_ROOT}/docs/decisions/DR-017-git-merge-strategy.md" \
        "${TARGET_ROOT}/docs/decisions/DR-017-git-merge-strategy.md"
  adapt "${TEMPLATE_ROOT}/docs/decisions/DR-020-github-repo-settings.md" \
        "${TARGET_ROOT}/docs/decisions/DR-020-github-repo-settings.md"
  OPTIONAL_DR_ROWS="| DR-017 | Git 머지 전략 | — | Accepted (Amended) | feature→develop: Squash 기본 / Regular 예외; develop→main: Regular Merge 원칙 |
| DR-020 | GitHub Repository Settings Policy | — | Accepted | repo visibility·branch ruleset·merge 방식 운영 정책 |
"
fi

write_text "${TARGET_ROOT}/docs/decisions/README.md" "# Decision Records

이 프로젝트의 결정 근거(WHY) 인덱스다.
각 DR은 하나의 결정 이유를 기록한다.

cascade 감사 시 이 인덱스의 Accepted DR만 확인 대상이다.
Superseded DR은 \`docs/archive/docs/decisions/\`로 이동한다.

**Status legend:**
- \`Accepted\` — 최종 확정
- \`Accepted (Amended)\` — 확정 후 세부 수정됨. DR 본문에 수정 범위 명시.
- \`Accepted (일부 Deferred)\` — 일부 항목 보류. DR 본문에 보류 범위 명시.
- \`Superseded by DR-XXX\` — 전체 대체됨. archive 이동 후보.
- \`Draft\` — 초안. 아직 확정 전(선택 보류). cascade 감사 대상 아님.
- \`Draft (Dropped)\` — 채택하지 않기로 한 Draft. 폐기 사유 명시 후 archive 이동, 번호 retire (DR-029).

**Track legend:** \`harness\` = AI workflow·명령·프로토콜 결정 / \`product\` = 적용 프로젝트의 기능·아키텍처 결정

| ID | Title | Date | Status | Track | 요약 |
|----|-------|------|--------|-------|------|
| DR-007 | 파일 유형별 작성 언어 원칙 | — | Accepted | harness | 문서·command·prompt·hook은 Korean primary + English technical terms |
| DR-008 | docs/ 파일명 대소문자 표준 | — | Accepted | harness | \`docs/\` 파일명은 UPPER-KEBAB-CASE |
| DR-013 | Work 파일 기반 작업 단위 체계 | — | Accepted | harness | \`docs/works/{category}/{ID}-{topic}.md\`, Active/Done/Archived 3단계, \`related_work\` 필드 포함 |
| DR-014 | Archive 구조 정책 | — | Accepted | harness | \`docs/archive/\` 하위 경로 mirror 방식 |
| DR-027 | Troubleshooting / Retrospective 파일 최소 스펙 | — | Accepted | harness | frontmatter(symptom/track/category/status, date/track/type/scope/author) 도입. track 필드로 harness·product 구분 |
| DR-029 | DR Registration Triage + Draft DR Lifecycle | — | Accepted | harness | DR 등록 3-way triage(Accepted/Draft/OQ·backlog) + Draft 승격·\`Draft (Dropped)\`·repo-health hygiene surfacing |
${OPTIONAL_DR_ROWS}
위 DR들은 harness가 동반하는 foundational decision이다.
이 프로젝트 고유의 결정은 \`DR-{NNN}-{topic}.md\`(\`docs/decisions/DECISION-TEMPLATE.md\` 사용)로 추가하고 이 인덱스에 등록한다.
"

write_text "${TARGET_ROOT}/docs/troubleshooting/README.md" "# Troubleshooting

증상별 원인 분석과 조치 기록이다.

## Frontmatter 스펙 (DR-027)

\`\`\`yaml
---
symptom: {한 줄 증상}
track: harness | product
category: {e.g. workflow, scaffold, command, git, tool, feature, api, data, infra, …}
environment: {e.g. Claude Code, Codex, Cursor, 공통, 기타}
status: Resolved | Unresolved | Workaround
related_dr: []
---
\`\`\`

\`track\`: harness = AI workflow·명령·프로토콜 이슈 / product = 적용 프로젝트의 기능·인프라 이슈
\`category\`: 예시 목록이며 열거형으로 제한하지 않는다.

## 인덱스

| 증상 | 환경 | 파일 |
| --- | --- | --- |

## 작성 규칙

- 파일명: \`lowercase-hyphenated.md\`
- 구성: 증상 -> 원인 -> 조치 -> 검증 -> 변경 내역 -> 관련 문서
- 해결 안 된 이슈는 \`docs/STATUS.md\` Blockers에 등록 후 해결 시 이 디렉터리로 이동
- 관련 결정이 DR-worthy이면 \`docs/decisions/DR-*.md\`로 별도 기록하고 역참조
"

# ── Claude Code config ───────────────────────────────────────────────────────
for f in docs-workflow.md infra.md; do
  adapt "${TEMPLATE_ROOT}/.claude/rules/${f}" "${TARGET_ROOT}/.claude/rules/${f}"
done

# git-workflow.md: source-gitflow uses source repo (branch isolation included),
# generic uses minimal template (commit naming/format only, no branch isolation).
if [[ "${WORKFLOW_MODE}" == "source-gitflow" ]]; then
  adapt "${TEMPLATE_ROOT}/.claude/rules/git-workflow.md" \
        "${TARGET_ROOT}/.claude/rules/git-workflow.md"
else
  adapt "${TEMPLATE_ROOT}/scripts/templates/default/.claude/rules/git-workflow.md" \
        "${TARGET_ROOT}/.claude/rules/git-workflow.md"
fi

if [[ "${PROFILE}" == "spring-boot" ]]; then
  adapt "${TEMPLATE_ROOT}/.claude/rules/java-spring.md" "${TARGET_ROOT}/.claude/rules/java-spring.md"
  adapt "${TEMPLATE_ROOT}/.claude/rules/testing.md" "${TARGET_ROOT}/.claude/rules/testing.md"
fi

# ── Canonical workflow procedures ────────────────────────────────────────────
for f in "${TEMPLATE_ROOT}"/skills/workflow/*.md; do
  adapt "$f" "${TARGET_ROOT}/skills/workflow/$(basename "$f")"
done

for f in "${TEMPLATE_ROOT}"/.claude/commands/*.md; do
  adapt "$f" "${TARGET_ROOT}/.claude/commands/$(basename "$f")"
done

# ── Source-gitflow extras ────────────────────────────────────────────────────
# Adds docs/GIT-WORKFLOW.md with policy_type: source-gitflow marker.
# The marker activates Branch Isolation Check in work-plan/work-close commands and skills.
# Uses scaffold-safe template (no source-repo-only references).
if [[ "${WORKFLOW_MODE}" == "source-gitflow" ]]; then
  adapt "${TEMPLATE_ROOT}/scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md" \
        "${TARGET_ROOT}/docs/GIT-WORKFLOW.md"
  adapt "${TEMPLATE_ROOT}/scripts/templates/source-gitflow/.github/workflows/harness-validate.yml" \
        "${TARGET_ROOT}/.github/workflows/harness-validate.yml"

  # Gate hooks are deployed only for source-gitflow targets (opt-in). Generic targets
  # stay advisory-only (no tools/git-hooks). Copied from the live tools/git-hooks/ via
  # adapt() so they are recorded as framework-owned files in the manifest. adapt() does
  # not set permissions, so exec hooks get +x explicitly afterward.
  ensure_dir "${TARGET_ROOT}/tools/git-hooks/lib"
  adapt "${TEMPLATE_ROOT}/tools/git-hooks/pre-commit" \
        "${TARGET_ROOT}/tools/git-hooks/pre-commit"
  adapt "${TEMPLATE_ROOT}/tools/git-hooks/commit-msg" \
        "${TARGET_ROOT}/tools/git-hooks/commit-msg"
  adapt "${TEMPLATE_ROOT}/tools/git-hooks/install.sh" \
        "${TARGET_ROOT}/tools/git-hooks/install.sh"
  adapt "${TEMPLATE_ROOT}/tools/git-hooks/lib/gate-lists.sh" \
        "${TARGET_ROOT}/tools/git-hooks/lib/gate-lists.sh"
  if [[ "${DRY_RUN}" != true ]]; then
    for hook in pre-commit commit-msg install.sh; do
      [[ -f "${TARGET_ROOT}/tools/git-hooks/${hook}" ]] && chmod +x "${TARGET_ROOT}/tools/git-hooks/${hook}"
    done
  fi
fi

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
            "command": "python3 -c \"print('\''[hook] 세션 종료 전 확인: Work가 완료됐다면 /work-close를 먼저 실행하고, 그다음 /session-summary로 validation, STATUS/Tracking Finalization, Approval Matrix에 따른 상태 변경 필요 여부, DR-worthy 결정, commit 상태를 보고하세요.'\'')\""
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
# Always: session-start prompts + README. These are A-class (session bootstrap).
for f in \
  README.md \
  claude-session-start.md \
  codex-session-start.md \
  cursor-session-start.md; do
  copy_prompt "$f"
done

# Optional source pack (DR-021): extended generic prompt bundle. Default excludes
# them to keep target minimal; --with-optional opts in.
if [[ "${WITH_OPTIONAL}" == true ]]; then
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
    22-minimal-diff.prompt.md; do
    copy_prompt "$f"
  done
fi

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

# ── Project gate config seed (.harness/gate-config) ──────────────────────────
# Class B (project-owned) seed: lets the target ADD its own protected/finalization
# paths without editing framework-owned tools/git-hooks/lib/gate-lists.sh. Written
# with write_text so it is NOT recorded in the manifest framework_files set and
# survives a harness upgrade. Seeded with commented examples only → zero active
# entries → default gate behavior until the target opts in.
write_text "${TARGET_ROOT}/.harness/gate-config" '# Project gate config (.harness/gate-config) — project-owned, add-only.
#
# Extend the harness default protected/finalization path lists with paths specific
# to THIS repository, WITHOUT editing framework-owned tools/git-hooks/lib/gate-lists.sh
# (that file is recorded in the manifest and overwritten on a harness upgrade).
# This file survives upgrades.
#
# Format: one glob pattern per line, under a section header.
#   - Whole-line comments (#...) and blank lines are ignored. Inline comments are
#     NOT supported: "infra/**  # note" is treated as one literal pattern, so keep
#     comments on their own line.
#   - Patterns are shell case-globs: * also matches "/", so infra/* covers infra/a/b.
#   - add-only: you can ADD paths here; framework defaults cannot be removed.
#
# In a hook-gated (source-gitflow) target the git hooks read this file directly.
# In a generic (advisory-only) target it has no hooks; the agent honors it as
# advisory input per .claude/rules/git-workflow.md.
#
# [protected]    block direct commits to these on develop/main (branch isolation)
# [finalization] treat these as tracking/finalization files (DR-025 bundling gate)
#
# Examples (uncomment and adapt to this repository):

[protected]
# infra/**
# db/schema.sql
# .github/workflows/deploy.yml

[finalization]
# docs/PRODUCT-STATUS.md
'

# ── Harness manifest (.harness/manifest.json) ────────────────────────────────
# Records harness version + framework-owned file list/hash so the target knows
# its baseline and `--check` can report drift. Framework files were accumulated
# by adapt(); B-class seeds (write_text) are intentionally excluded.
if [[ "${DRY_RUN}" != true ]]; then
  # strip trailing comma+newline from the accumulated rows
  MANIFEST_BODY="${MANIFEST_ROWS%,
}"
  write_text "${TARGET_ROOT}/.harness/manifest.json" "{
  \"manifest_version\": 1,
  \"harness_version\": \"${HARNESS_VERSION}\",
  \"source_identity\": \"${SOURCE_IDENTITY}\",
  \"generated_at\": \"${TODAY}\",
  \"profile\": \"${PROFILE}\",
  \"workflow_mode\": \"${WORKFLOW_MODE}\",
  \"with_optional\": ${WITH_OPTIONAL},
  \"project_name\": \"${PROJECT_NAME}\",
  \"hash_algorithm\": \"sha256\",
  \"hash_mode\": \"normalized_source_template\",
  \"framework_files\": [
${MANIFEST_BODY}
  ]
}
"
fi

# ── Generated README ─────────────────────────────────────────────────────────
# Optional source pack (DR-021) file-table rows appear only with --with-optional,
# so the default README does not list docs the minimal scaffold did not create.
OPTIONAL_README_ROWS=""
HARNESS_DOC_LINK="docs/HARNESS-QUICK-REFERENCE.md"
if [[ "${WITH_OPTIONAL}" == true ]]; then
  OPTIONAL_README_ROWS="| \`docs/HARNESS-ARCHITECTURE.md\` | harness 아키텍처와 정보 흐름 시각화 (optional pack) |
| \`docs/HARNESS-MAINTAINER-GUIDE.md\` | 유지보수·convention 가이드 (optional pack) |
| \`docs/WORKFLOW-MANUAL.md\` | 사용자용 워크플로우 가이드 (optional pack) |
"
  HARNESS_DOC_LINK="docs/WORKFLOW-MANUAL.md"
fi

# Generic targets carry no git hooks, so the workflow gates are advisory-only.
# Surface that posture in the README (cross-tool/human front-door). Source-gitflow
# targets get hook/CI/bootstrap guidance via docs/GIT-WORKFLOW.md instead, so this
# note is generic-only to avoid an advisory-vs-enforced contradiction.
ENFORCEMENT_NOTE=""
if [[ "${WORKFLOW_MODE}" != "source-gitflow" ]]; then
  ENFORCEMENT_NOTE="
### Workflow enforcement (advisory-only)

이 scaffold는 generic workflow라 **git hook을 설치하지 않는다**. branch isolation, finalization bundling, commit message gate는 런타임 강제가 아니라 **advisory**(agent·committer가 지키는 honor-system, DR-025 기준)다.
런타임 hook 강제가 필요하면 \`--workflow source-gitflow\`로 다시 scaffold한다.
"
fi

write_text "${TARGET_ROOT}/README.md" "# ${PROJECT_NAME}

> [프로젝트 한 줄 설명 — 채워주세요]

## AI Workflow Harness

이 프로젝트는 Claude Code / Codex / Cursor 공통 AI 워크플로우 하네스를 포함합니다.
하네스는 Product track과 Harness track을 함께 운영하도록 설계되어 있습니다.
첫 세션에서는 프로젝트 identity, Product Definition, Project Initialization baseline을 먼저 정리한 뒤 Product track backlog를 만들고,
AI workflow 자체의 개선과 example pack 정비는 Harness track으로 분리합니다.

| Track | 목적 | 주요 파일 |
| --- | --- | --- |
| Product track | 실제 제품/서비스/콘텐츠 작업과 product backlog | \`docs/backlog/PRODUCT.md\`, \`docs/works/product/\` |
| Harness track | AI workflow, command/rule, prompt, scaffold, process 개선 | \`docs/backlog/HARNESS.md\`, \`docs/works/harness/\` |

| 파일 | 역할 |
| --- | --- |
| \`CLAUDE.md\` | Claude Code 진입점 |
| \`AGENTS.md\` | Codex 진입점 |
| \`docs/BEHAVIOR-PRINCIPLES.md\` | 전역 행동 원칙 |
| \`docs/STATUS.md\` | 현재 작업 상태 |
| \`docs/HARNESS-QUICK-REFERENCE.md\` | 세션 실행 규칙 요약 |
| \`docs/BOOTSTRAP.md\` | scaffold 직후 프로젝트 부팅 checklist |
| \`docs/AGENT-WORKFLOW.md\` | 공통 운영 규칙 |
${OPTIONAL_README_ROWS}| \`docs/works/\` | Work 파일 (큰 작업의 SSoT) |
| \`skills/workflow/\` | workflow 상세 절차의 canonical SSoT |
| \`.claude/commands/\` | \`/session-start\`, \`/work-select\`, \`/work-register\`, \`/work-plan\`, \`/work-close\`, \`/session-summary\` 등 |
| \`.agents/skills/\` | Codex workflow adapter |
| \`.codex/hooks.json\` | Codex hook 설정 |
| \`prompts/\` | 세션 시작 및 태스크 프롬프트 라이브러리 |

### Workflow 구조

- \`skills/workflow/{name}.md\`: command별 canonical 절차
- \`.claude/commands/{name}.md\`: Claude Code slash command adapter
- \`.agents/skills/workflow-{name}/SKILL.md\`: Codex adapter
- \`.cursor/rules/workflow.mdc\`: Cursor intent routing

사용자는 command 이름으로 진입하고, 상세 절차는 canonical workflow가 소유한다.

### 첫 세션

**Claude Code:**
\`\`\`bash
claude        # Claude Code 열기
/session-start        # 하네스 로딩 확인 및 현재 상태 요약
\`\`\`

**Codex:** repo root의 \`AGENTS.md\`를 기본 진입점으로 사용하고, 세션 첫 요청은 \`/session-start\` intent로 시작한다. \`prompts/codex-session-start.md\`는 수동 bootstrap이 필요한 fallback이다.

**Cursor:** \`prompts/cursor-session-start.md\` 내용을 세션 시작 시 붙여넣는다.

## 사전 작업

git repository는 자동으로 초기화되지 않는다. 첫 세션에서 \`docs/BOOTSTRAP.md\` §0 Repository Setup을 따라 초기화 여부를 먼저 결정한다.
\`--workflow source-gitflow\`를 선택하지 않았다면 branch/release policy는 이 target project가 직접 정한다.
${ENFORCEMENT_NOTE}

### Framework Files & Updating

이 project에는 harness가 생성한 framework-owned 파일과, 이 project가 직접 채워야 하는 project-owned 파일이 함께 있다.

| 구분 | 의미 | 예시 |
| --- | --- | --- |
| framework-owned | harness source에서 생성된 workflow 파일. 가능하면 직접 고치기보다 source 업데이트와 비교한다. | entrypoint, command/skill/rule, protocol, prompt |
| project-owned | 이 project의 실제 상태와 계획을 담는 파일. 첫 세션에서 채워야 한다. | \`docs/STATUS.md\`, backlog, Work 파일, project decision |

Harness source clone에서 \`scripts/create-harness.sh --check /path/to/project\`를 실행하면 manifest를 기준으로 framework 파일이 source 대비 \`in-sync\`, \`source-updated\`, \`locally-modified\`인지 보고한다.
현재 자동 upgrade 기능은 제공하지 않는다. 이미 적용한 harness를 최신 source와 맞추려면 \`--check\` 결과를 보고 필요한 파일만 수동으로 selective migration한다.

스캐폴딩 직후 첫 \`/session-start\`에서는 \`docs/STATUS.md\` Next Actions를 확인한다.
Next Actions가 scaffold bootstrap/onboarding을 가리키면 \`docs/BOOTSTRAP.md\`를 §0부터 순서대로 채운다.
Bootstrap onboarding에 사용할 prompt는 \`docs/BOOTSTRAP.md\` §8에 있다.

1. \`docs/STATUS.md\` — 프로젝트 목표와 Current phase(focus) 설명
2. \`docs/PLAN-SUMMARY.md\` Project Summary — 제품 목표와 핵심 workflow
3. \`docs/PLAN-SUMMARY.md\` Implementation Baseline — Runtime/Framework/Build/package 결정 (코드 개발 프로젝트)
4. \`docs/PLAN.md\` Project Initialization Plan — stack 선택 근거와 초기 구조
5. \`docs/backlog/PRODUCT.md\` — baseline 완료 후 도출한 초기 작업 항목 (Work ID는 /work-plan 착수 시 확정)
6. \`docs/BEHAVIOR-PRINCIPLES.md\` — 전역 행동 원칙 확인
7. \`docs/AGENT-WORKFLOW.md\` — Project Constants와 Verification Defaults

---

*Scaffolded ${TODAY} with [AI Workflow Harness](https://github.com/kyungseo/ai-workflow-harness). Local workflow reference: [${HARNESS_DOC_LINK}](${HARNESS_DOC_LINK}).*

*Harness framework origin: AI Workflow Harness, Copyright (c) Kyungseo Park <Kyungseo.Park@gmail.com>, licensed under Apache License 2.0. This notice applies to the scaffolded harness framework files, not to this project's own product code or content.*
"

# ── Skeleton docs ─────────────────────────────────────────────────────────────
write_text "${TARGET_ROOT}/docs/STATUS.md" "# STATUS.md — ${PROJECT_NAME}

## Current State

| Field | Value |
| --- | --- |
| Current phase | [프로젝트 focus 또는 목표 한 줄 — 단계(phase) 운영은 optional] |
| Active plan | — |
| Bootstrap checklist | \`docs/BOOTSTRAP.md\` |
| Project backlog | \`docs/backlog/PRODUCT.md\` |
| Harness backlog | \`docs/backlog/HARNESS.md\` |
| Last updated | ${TODAY} |

## Work Context Rule

이 파일은 현재 작업 상태의 dashboard다.
세션 시작 시에는 \`Current State\`, \`Active Work\`, \`Blockers And Open Questions\`, \`Next Actions\`만 확인한다.
상세 실행 흐름은 \`docs/AGENT-WORKFLOW.md\`를 따른다.

## Active Work

| ID | Title | Work File |
| --- | --- | --- |

## Blockers And Open Questions

| ID | Status | Question | Decision Needed |
| --- | --- | --- | --- |

## Recent Decisions

*(없음)*

## Next Actions

1. Scaffold bootstrap onboarding: \`docs/BOOTSTRAP.md\`를 §0부터 순서대로 채운다
2. §1 Project Identity, §2 Product Definition 완료 후 \`docs/PLAN-SUMMARY.md\` Project Summary 업데이트
3. §3 Project Initialization: \`docs/PLAN-SUMMARY.md\` Implementation Baseline 채우기 (코드 개발 프로젝트만)
4. Implementation Baseline 완료 후 \`docs/backlog/PRODUCT.md\`에 초기 작업 후보 등록 (Work ID는 /work-plan 착수 시 확정)
5. \`docs/AGENT-WORKFLOW.md\` Project Constants와 Verification Defaults 채우기
6. AI workflow 개선 항목은 \`docs/backlog/HARNESS.md\`로 분리
7. Claude Code: \`/session-start\`로 첫 세션 시작 | Codex: \`AGENTS.md\` 확인 후 \`/session-start\` intent 실행 | Cursor: \`prompts/cursor-session-start.md\` 사용
"

write_text "${TARGET_ROOT}/docs/BOOTSTRAP.md" "# BOOTSTRAP.md — ${PROJECT_NAME}

Scaffold 직후 이 파일을 먼저 채운다. 목표는 빈 harness를 프로젝트 identity와 production 성격에 맞게 부팅하는 것이다.

## 0. Repository Setup

- [ ] git repository 초기화 여부 확인: \`git status\` 또는 \`ls .git/\` 실행. \`git status\`가 not a git repository 메시지로 실패하면 no-git bootstrap 상태로 판단
- [ ] git repository가 없으면 사용자 승인 후 \`git init\`, default branch 결정, initial commit 여부 결정
- [ ] git repository가 없는 동안 commit/PR/branch workflow, \`git diff\` 기반 검증은 \`Not Applicable\`로 처리
- [ ] \`--existing\` overlay인 경우: 기존 branch/remote 정책을 먼저 확인하고, harness Gitflow를 무조건 강제하지 않는다
- [ ] \`docs/GIT-WORKFLOW.md\`에 \`policy_type: source-gitflow\` marker가 있으면 §0-1 Environment Bootstrap의 fresh-repo/existing-repo 분기를 따른다

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

제품 목표와 성공 기준을 먼저 확정한다. 이 단계가 완료되지 않으면 product backlog를 만들지 않는다.

- [ ] 초기 목표를 한 문장으로 정리
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

> 이 단계가 완료(또는 Not Applicable 처리)되지 않으면 \`docs/backlog/PRODUCT.md\`에 기능 후보를 등록하지 않는다.
> 기능 candidate 제안 전에 Implementation Baseline Readiness를 먼저 확인한다.

## 4. Product Backlog Derivation

§2 Product Definition과 §3 Project Initialization이 완료된 뒤 Product track backlog를 도출한다.

- [ ] \`docs/backlog/PRODUCT.md\` Backlog에 초기 작업 후보 등록 — Summary 표 + Details 블록 동시 작성 (Work ID는 /work-plan 착수 시 확정)
- [ ] 각 후보에 Done Criteria, Verification, Dependencies 작성
- [ ] 즉시 착수할 항목이 있으면 \`docs/STATUS.md\` Active Work로 올릴 내용 제안
- [ ] 큰 작업이면 \`docs/works/product/\`에 Work 파일 생성 여부 판단
- [ ] 완료 후 \`docs/STATUS.md\` Next Actions에서 scaffold bootstrap onboarding 항목 제거 또는 다음 실제 작업으로 교체

## 5. Harness Track Setup

AI workflow 자체의 조정은 Harness track으로 분리한다.

- [ ] tool entrypoint(\`AGENTS.md\`, \`CLAUDE.md\`)가 프로젝트에 맞는지 확인
- [ ] \`docs/AGENT-WORKFLOW.md\` Verification Defaults 작성
- [ ] \`README.md\`, \`docs/PLAN-SUMMARY.md\`, \`AGENTS.md\`, \`CLAUDE.md\`에 프로젝트 identity 보정이 필요한지 확인
- [ ] \`.claude/rules/\`, \`.cursor/rules/\`, \`prompts/\`에 role/rule/prompt naming 보정이 필요한지 확인
- [ ] command/rule/prompt 조정이 필요하면 \`docs/backlog/HARNESS.md\`에 후보 등록 (Work ID는 /work-plan 착수 승인 시 확정)
- [ ] \`docs/works/harness/\` Work 파일이 필요한 규모인지 판단

## 6. Core Document Fill Order

1. \`docs/BOOTSTRAP.md\` — identity, production 성격, setup checklist
2. \`docs/STATUS.md\` — Current phase(focus), Active Work, OQ, Next Actions
3. \`docs/PLAN-SUMMARY.md\` Project Summary — 프로젝트 요약, 제품 목표
4. \`docs/PLAN-SUMMARY.md\` Implementation Baseline — Runtime/Framework/Build/package 결정 (코드 프로젝트)
5. \`docs/PLAN.md\` Project Initialization Plan — stack 선택 근거, 초기 구조 (코드 프로젝트)
6. \`docs/backlog/PRODUCT.md\` — Product track backlog (baseline 완료 후)
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
항목이 남아 있으면 daily \`/session-start\`가 매 세션 bootstrap 후속 작업을 계속 제안한다.
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

### Product Backlog Readiness Checklist

*(PLAN-SUMMARY.md Implementation Baseline이 Ready 상태여야 product feature 후보 등록 가능)*

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

## Roadmap

*(채워야 함 — 단계(phase) 운영은 optional. 필요 시 milestone을 Current phase 라벨로 두고 product backlog를 PRODUCT-P{n}으로 분할: DR-031)*

- 목표:
- 범위:
"

write_text "${TARGET_ROOT}/docs/backlog/PRODUCT.md" "# Product Backlog

## 상태 요약

| 항목 | 내용 |
| --- | --- |
| 제품 목표 | — |
| 주요 사용자 | — |
| 범위 | — |
| 상태 | In Progress |

> **Baseline Gate**: \`docs/PLAN-SUMMARY.md\` Implementation Baseline이 비어 있으면 feature candidate은 Not Ready로 보고하고, 첫 후보로 Project Initialization을 제안한다.
> code development가 필요한 프로젝트: 첫 후보는 Project Initialization (Work ID는 /work-plan 착수 시 확정).
> code development가 없는 프로젝트(content/research/no-code 운영 등): 해당 project type의 baseline/setup 작업으로 대체.

제품 목표에서 도출한 후보 작업을 우선 등록한다.
AI workflow, command/rule, prompt, scaffold 개선은 \`docs/backlog/HARNESS.md\`로 분리한다.

## Backlog

### Summary

<!-- 항목 등록 시 Summary 표에 행 추가 + Details 섹션에 블록 추가 (2단 동시 작성) -->

| ID | Priority | Status | Risk | Title |
| --- | --- | --- | --- | --- |

---

### Details

<!-- 항목 등록 형식:

#### {Title}

**Task:** {상세 설명}

**Dependencies:** {선행 조건 또는 관련 Work/DR}

**Done Criteria:** {완료 판단 기준}

**Verification:** {검증 방법. 변경이 건드리는 surface 명시: tool surface · adopter cascade · canonical · scaffold · README/GUIDE/MANUAL 중 해당 항목}

---
-->

## Done
"

write_text "${TARGET_ROOT}/docs/backlog/HARNESS.md" "# Harness Backlog

AI workflow, command/rule, prompt, scaffold, process 개선 후보를 관리한다.

> Done/Superseded 항목은 이 파일에서 제거된다.
> 완료 이력: Work 파일이 있는 항목은 \`docs/works/harness/README.md\` Archived 테이블, Work 파일이 없는 항목(Quick Mode)은 \`git log --grep=\"{ID}\"\`로 확인한다.

## Backlog

### Summary

<!-- 항목 등록 시 Summary 표에 행 추가 + Details 섹션에 블록 추가 (2단 동시 작성) -->

| ID | Priority | Status | Risk | Title |
| --- | --- | --- | --- | --- |

---

### Details

<!-- 항목 등록 형식:

#### {Title}

**Task:** {상세 설명}

**Dependencies:** {선행 조건 또는 관련 Work/DR}

**Done Criteria:** {완료 판단 기준}

**Verification:** {검증 방법. 변경이 건드리는 surface 명시: tool surface · adopter cascade · canonical · scaffold · README/GUIDE/MANUAL 중 해당 항목}

---
-->

## Deferred Ideas

| ID | Topic | Decision Point |
| --- | --- | --- |
"

write_text "${TARGET_ROOT}/docs/works/README.md" "# docs/works/

Work 파일 디렉토리. 큰 작업 단위의 Single Source of Truth.

Work 파일 스펙: \`docs/decisions/DR-013-work-file-spec.md\`
공통 운영 규칙: \`docs/HARNESS-PROTOCOL.md\` Work File Rules

## 카테고리

| 카테고리 | 경로 | 용도 |
| --- | --- | --- |
| product/ | \`docs/works/product/\` | Product track 작업 |
| harness/ | \`docs/works/harness/\` | Harness track 개선 작업 |

## Lifecycle

| Status | Location | Meaning |
| --- | --- | --- |
| Active | \`docs/works/{category}/\` | \`docs/STATUS.md\` Active Work에 pointer 존재 |
| Done | \`docs/works/{category}/\` | 완료 검증 통과, archive 대기 가능 |
| Archived | \`docs/archive/docs/works/{category}/\` | 완전 종결 |

Backlog \`Candidate\`는 후보 pool이다. Work 파일은 착수 승인 후 \`Active\` 상태로 생성한다.
"

write_text "${TARGET_ROOT}/docs/works/product/README.md" "# Product Work Index

Product track 작업 인덱스다.

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
write_text "${TARGET_ROOT}/docs/retrospectives/README.md" "# Retrospectives

회고 인덱스.

cascade 감사 시 최신 1개 또는 해당 topic 관련 1개만 참조한다. 전체 목록 스캔은 하지 않는다.

## Frontmatter 스펙 (DR-027)

\`\`\`yaml
---
date: YYYY-MM-DD
track: harness | product
type: {e.g. session, phase, incident, process, …}
scope: {무엇에 대한 회고인지 한 줄}
author: \"agent:{model-name} | human\"
related_work: []
---
\`\`\`

\`track\`: harness = AI workflow·프로세스 회고 / product = 적용 프로젝트의 기능·개발 회고
\`type\`: 예시 목록이며 열거형으로 제한하지 않는다.

섹션 구성 최솟값: **결론** (필수) → 내용 (자유) → **Revisit Triggers** (권장) → **연결** (해당 시)

## 인덱스

| 날짜 | 파일 | 주제/Scope | 핵심 결론 |
|------|------|-----------|---------|
"
touch_file "${TARGET_ROOT}/docs/reports/.gitkeep"
touch_file "${TARGET_ROOT}/docs/presentations/.gitkeep"

echo ""
if [[ "${DRY_RUN}" == true ]]; then
  echo "Dry-run complete. No files were written."
else
  echo "Done [mode: ${MODE}, profile: ${PROFILE}, workflow: ${WORKFLOW_MODE}]"
  echo ""
  echo "  Harness scaffolded at: ${TARGET_ROOT}"
fi
echo ""
echo "Bootstrap onboarding targets (propose/fill during first session):"
echo "  docs/BOOTSTRAP.md      — 프로젝트 identity와 production 성격 기반 setup checklist"
echo "  docs/STATUS.md         — 프로젝트 목표와 Current phase(focus) 설명"
echo "  docs/PLAN-SUMMARY.md   — Project Summary와 Implementation Baseline"
echo "  docs/PLAN.md           — Project Initialization Plan"
echo "  docs/backlog/PRODUCT.md — baseline 완료 후 도출한 초기 작업 항목 (Work ID는 /work-plan 착수 시 확정)"
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
if [[ "${WORKFLOW_MODE}" == "source-gitflow" ]]; then
  echo "Workflow: source-gitflow"
  echo "  Gate hooks deployed at tools/git-hooks/ (branch isolation + DR-025 finalization gate)."
  echo "  After git init, install them with: sh tools/git-hooks/install.sh"
  echo "  Environment bootstrap runbook: docs/GIT-WORKFLOW.md §0-1"
  echo "  Tune project-specific protected/finalization paths in .harness/gate-config (add-only, upgrade-safe)."
  echo "  Do not edit framework-owned tools/git-hooks/lib/gate-lists.sh — it is overwritten on harness upgrade."
fi
if [[ ! -d "${TARGET_ROOT}/.git" ]]; then
  echo "Note: git repository is not initialized. Follow docs/BOOTSTRAP.md §0 to decide when to run git init."
  echo "  Until then, commit/PR/branch workflow is Not Applicable."
fi
echo ""
echo "First session:"
echo "  cd ${TARGET_ROOT}"
echo "  claude        # Claude Code 열기"
echo "  /session-start        # 하네스 로딩 확인 및 현재 상태 요약"
echo "  codex         # Codex 사용 시 AGENTS.md 확인 후 /session-start intent로 시작"
