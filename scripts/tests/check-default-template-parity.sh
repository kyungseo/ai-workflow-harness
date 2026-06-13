#!/usr/bin/env bash
# check-default-template-parity.sh — source canonical ↔ default tracked variant parity.
#
# Scope: source repo에만 존재하는 default tracked template pair를 점검한다.
#   - .cursor/rules/workflow.mdc -> scripts/templates/default/.cursor/rules/workflow.mdc
#   - .claude/rules/git-workflow.md -> scripts/templates/default/.claude/rules/git-workflow.md
#
# Pair registry (keep explicit to make coverage omissions visible):
#   1) workflow_mdc
#   2) git_workflow_rule
#
# 비교 방식:
#   - workflow_mdc: canonical에서 work-doc routing row만 제거한 expected default를 재구성
#   - git_workflow_rule: canonical에서 default 허용 변환(advisory preface 추가, source-gitflow-only
#     섹션 제거/치환)을 적용해 expected default를 재구성
#
# Usage:
#   bash scripts/tests/check-default-template-parity.sh
#   bash scripts/tests/check-default-template-parity.sh --root <repo-root>
#
# Exit:
#   0 = PASS/SKIP, 1 = FAIL, 2 = usage error
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
usage: check-default-template-parity.sh [--root <repo-root>]
EOF
}

ROOT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      ROOT="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage
      exit 2
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
REPO_ROOT="${ROOT:-${DEFAULT_ROOT}}"

WORKFLOW_CANONICAL="${REPO_ROOT}/.cursor/rules/workflow.mdc"
WORKFLOW_DEFAULT="${REPO_ROOT}/scripts/templates/default/.cursor/rules/workflow.mdc"
GIT_CANONICAL="${REPO_ROOT}/.claude/rules/git-workflow.md"
GIT_DEFAULT="${REPO_ROOT}/scripts/templates/default/.claude/rules/git-workflow.md"

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

emit_expected_workflow_default() {
  local src="$1"
  awk '!/^\| Create presentation\/report\/review material \| `skills\/workflow\/work-doc\.md` \|$/' "${src}"
}

emit_expected_git_default() {
  local src="$1"
  awk '
BEGIN {
  skipping_branch=0
  skipping_tracking=0
  replacing_branch_flow=0
}
{
  if ($0 == "# Git Workflow Rules") {
    print $0
    print ""
    print "## Enforcement Posture (advisory-only)"
    print ""
    print "This scaffold uses the generic workflow: **no git hooks are installed**, so the branch-isolation, finalization-bundling, and commit-message gates below are **advisory** — they rely on the agent and committer honoring them, not on runtime enforcement (advisory-only; use `--workflow source-gitflow` to enable hook enforcement)."
    print "To enable runtime hook enforcement, re-scaffold with `--workflow source-gitflow`."
    print ""
    print "Project-specific gate paths: this repository may list extra protected/finalization"
    print "paths in `.harness/gate-config` (`[protected]` / `[finalization]` sections, one glob"
    print "per line). Because this is a generic scaffold there are no hooks to enforce them, so"
    print "treat any paths listed there as **advisory input** — honor them as protected (avoid"
    print "direct `develop`/`main` edits) and as finalization (bundle with substantive work) the"
    print "same way as the defaults below."
    next
  }

  if ($0 == "## Branch Isolation Check") {
    skipping_branch=1
    next
  }
  if (skipping_branch == 1) {
    if ($0 == "Commit Approval:") {
      skipping_branch=0
      print $0
    }
    next
  }

  if ($0 ~ /^- If an Active Work file exists and all Done Criteria are checked/) {
    next
  }

  if ($0 == "Tracking-only commits: the finalization-bundling gate exists to stop finalization being split *off* substantive work. A **pure tracking-only commit** — registration with no substantive work to bundle (e.g. `/work-register` adding a backlog row, a DR record, STATUS housekeeping) — is a legitimate exception, not a new commit type. Do **not** loosen the gate for it; use the existing override trailer with a tracking-only reason so a durable record stays in history:") {
    skipping_tracking=1
    next
  }
  if (skipping_tracking == 1) {
    if ($0 == "## Commit Message Format") {
      skipping_tracking=0
      print $0
    }
    next
  }

  if ($0 == "## Branch Flow") {
    print $0
    print ""
    print "When the user expresses branch merge intent (merging, opening a PR),"
    print "if this repository has `docs/GIT-WORKFLOW.md`, load it and follow its branch and PR guidance. Otherwise, follow the project-specific branch policy."
    # Branch Flow부터 EOF: default variant는 위 2-line summary로 대체하고 이후 source-gitflow-only detail 섹션은 제거한다.
    replacing_branch_flow=1
    next
  }
  if (replacing_branch_flow == 1) {
    next
  }

  print $0
}
' "${src}"
}

normalize_file() {
  local src="$1"
  local dest="$2"
  perl -0pe 's/\n+\z/\n/' "${src}" > "${dest}"
}

check_pair() {
  local label="$1"
  local canonical="$2"
  local tracked="$3"
  local emitter="$4"
  local expected="${TMP_DIR}/${label}.expected"
  local expected_norm="${TMP_DIR}/${label}.expected.norm"
  local tracked_norm="${TMP_DIR}/${label}.tracked.norm"

  if [[ ! -f "${canonical}" || ! -f "${tracked}" ]]; then
    echo "SKIP (${label}): source-only pair file missing"
    return 0
  fi

  "${emitter}" "${canonical}" > "${expected}"
  normalize_file "${expected}" "${expected_norm}"
  normalize_file "${tracked}" "${tracked_norm}"

  if diff -u "${expected_norm}" "${tracked_norm}" > "${TMP_DIR}/${label}.diff"; then
    echo "OK (${label})"
  else
    echo "FAIL (${label}): tracked default drifted from reconstructed expected variant"
    cat "${TMP_DIR}/${label}.diff"
    return 1
  fi
}

RC=0
check_pair "workflow_mdc" "${WORKFLOW_CANONICAL}" "${WORKFLOW_DEFAULT}" emit_expected_workflow_default || RC=1
check_pair "git_workflow_rule" "${GIT_CANONICAL}" "${GIT_DEFAULT}" emit_expected_git_default || RC=1

exit "${RC}"
