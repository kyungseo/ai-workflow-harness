#!/usr/bin/env bash
# check-onboarding-flows.sh — deterministic onboarding/core hook verification.
#
# Scope:
#   - Layer J-OB deterministic core:
#       OB0 scaffold 4-mode generation (generic/source-gitflow/optional/existing)
#       OB1 generic bootstrap pointers
#       OB3 source-gitflow bootstrap/hook surfaces
#       OB4 optional-pack presence + invariants
#       OB5 existing overlay preservation + --check drift 0
#   - Layer Q core:
#       source-gitflow hook install + main protected-file hard-stop
#       develop tracking-state warning (with explicit finalization override)
#       feature branch normal commit PASS
#
# Non-goal:
#   - Layer J interactive/human-run session behavior simulation
#   - OB2 exception-path inspection (static grep + mv 조작 성격 — document content
#     검증이지 scaffold generation smoke가 아니므로 human-run catalog 유지)
#   - repo-health integration or runner wiring
#
# Usage:
#   bash scripts/tests/check-onboarding-flows.sh
#   bash scripts/tests/check-onboarding-flows.sh --root <repo-root>
#
# Exit:
#   0 = PASS/SKIP, 1 = FAIL, 2 = usage error
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
usage: check-onboarding-flows.sh [--root <repo-root>]
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

CREATE_SH="${REPO_ROOT}/scripts/create-harness.sh"
INVARIANTS="${REPO_ROOT}/scripts/tests/check-scaffold-invariants.sh"

BASE_DIR="${REPO_ROOT}/temp/harness-tests"
RUN_DIR="${BASE_DIR}/onboarding-$(date +%Y%m%d-%H%M%S)-$$"
GEN_GENERIC="${RUN_DIR}/generic"
GEN_GITFLOW="${RUN_DIR}/gitflow"
GEN_OPTIONAL="${RUN_DIR}/optional"
GEN_EXISTING="${RUN_DIR}/existing"

FAIL=0

cleanup() {
  rm -rf "${RUN_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*"
  FAIL=1
}

ok() {
  echo "OK: $*"
}

require_file() {
  local path="$1"
  local label="$2"
  if [[ -f "${path}" ]]; then
    ok "${label}"
  else
    fail "${label} missing (${path#${REPO_ROOT}/})"
  fi
}

require_absent() {
  local path="$1"
  local label="$2"
  if [[ -e "${path}" ]]; then
    fail "${label} leaked (${path#${REPO_ROOT}/})"
  else
    ok "${label}"
  fi
}

require_grep() {
  local pattern="$1"
  local path="$2"
  local label="$3"
  if grep -qE "${pattern}" "${path}"; then
    ok "${label}"
  else
    fail "${label} (${path#${REPO_ROOT}/})"
  fi
}

check_drift_zero() {
  local target="$1"
  local label="$2"
  local summary
  if ! summary="$("${CREATE_SH}" --check "${target}" 2>/dev/null | grep 'summary:')"; then
    fail "${label}: --check summary unavailable"
    return
  fi
  if printf '%s' "${summary}" | grep -q ', 0 drifted'; then
    ok "${label}: --check drift 0"
  else
    fail "${label}: ${summary}"
  fi
}

if [[ ! -f "${CREATE_SH}" ]]; then
  echo "SKIP: scripts/create-harness.sh 없음 (source-only helper N/A)"
  exit 0
fi

mkdir -p "${BASE_DIR}" "${GEN_EXISTING}"
printf 'existing fixture\n' > "${GEN_EXISTING}/my-existing-file.md"

echo "== OB0: scaffold 4-mode generation =="
if "${CREATE_SH}" onboard-generic "${GEN_GENERIC}" >/dev/null; then
  ok "generic scaffold generated"
else
  fail "generic scaffold generation"
fi
if "${CREATE_SH}" --workflow source-gitflow onboard-gitflow "${GEN_GITFLOW}" >/dev/null; then
  ok "source-gitflow scaffold generated"
else
  fail "source-gitflow scaffold generation"
fi
if "${CREATE_SH}" --with-optional onboard-optional "${GEN_OPTIONAL}" >/dev/null; then
  ok "optional scaffold generated"
else
  fail "optional scaffold generation"
fi
if "${CREATE_SH}" --existing onboard-existing "${GEN_EXISTING}" >/dev/null; then
  ok "existing overlay scaffold generated"
else
  fail "existing overlay scaffold generation"
fi

echo "== OB1: generic bootstrap pointers =="
require_file "${GEN_GENERIC}/docs/BOOTSTRAP.md" "generic BOOTSTRAP.md"
require_grep 'BOOTSTRAP|bootstrap|onboarding' "${GEN_GENERIC}/docs/STATUS.md" "generic STATUS bootstrap pointer"
require_grep 'bootstrap|BOOTSTRAP' "${GEN_GENERIC}/skills/workflow/session-start.md" "session-start bootstrap pointer"
require_grep 'git status|git init|not a git repository|no-git' "${GEN_GENERIC}/docs/BOOTSTRAP.md" "BOOTSTRAP git init guidance"
require_grep 'STATUS\.md|Next Actions.*제거|다음 실제 작업' "${GEN_GENERIC}/docs/BOOTSTRAP.md" "BOOTSTRAP post-bootstrap STATUS guidance"
require_grep 'work-register|work-select|Active Work|Next Actions|STATUS\.md' "${GEN_GENERIC}/docs/BOOTSTRAP.md" "BOOTSTRAP next-action guidance"

echo "== OB3: source-gitflow surfaces =="
require_file "${GEN_GITFLOW}/docs/GIT-WORKFLOW.md" "source-gitflow GIT-WORKFLOW"
require_file "${GEN_GITFLOW}/.github/workflows/harness-validate.yml" "source-gitflow harness-validate workflow"
require_file "${GEN_GITFLOW}/tools/git-hooks/install.sh" "source-gitflow install hook"
require_grep 'policy_type: source-gitflow' "${GEN_GITFLOW}/docs/GIT-WORKFLOW.md" "source-gitflow policy marker"
require_grep 'feature/|--base develop|base develop' "${GEN_GITFLOW}/docs/GIT-WORKFLOW.md" "source-gitflow feature PR guidance"
require_absent "${GEN_GENERIC}/docs/GIT-WORKFLOW.md" "generic GIT-WORKFLOW absence"

echo "== OB4: optional-pack surfaces =="
require_file "${GEN_OPTIONAL}/docs/HARNESS-ARCHITECTURE.md" "optional HARNESS-ARCHITECTURE"
require_file "${GEN_OPTIONAL}/docs/HARNESS-MAINTAINER-GUIDE.md" "optional HARNESS-MAINTAINER-GUIDE"
require_file "${GEN_OPTIONAL}/docs/WORKFLOW-MANUAL.md" "optional WORKFLOW-MANUAL"
require_grep 'HARNESS-ARCHITECTURE|HARNESS-MAINTAINER|WORKFLOW-MANUAL' "${GEN_OPTIONAL}/README.md" "optional README listings"
require_absent "${GEN_GENERIC}/docs/HARNESS-ARCHITECTURE.md" "generic optional-doc absence (architecture)"
require_absent "${GEN_GENERIC}/docs/WORKFLOW-MANUAL.md" "generic optional-doc absence (workflow-manual)"
if [[ -f "${INVARIANTS}" ]]; then
  if bash "${INVARIANTS}" "${GEN_OPTIONAL}" >/dev/null; then
    ok "optional invariants"
  else
    fail "optional invariants"
  fi
else
  echo "SKIP: check-scaffold-invariants.sh 없음"
fi

echo "== OB5: existing overlay =="
require_file "${GEN_EXISTING}/my-existing-file.md" "existing user file preserved"
require_file "${GEN_EXISTING}/.harness/manifest.json" "existing overlay manifest"
check_drift_zero "${GEN_EXISTING}" "existing overlay"

echo "== Layer Q core: source-gitflow hook functional check =="
(
  cd "${GEN_GITFLOW}"
  git init -b main >/dev/null 2>&1 || {
    git init >/dev/null 2>&1
    git checkout -b main >/dev/null 2>&1
  }
  git config user.name "AWH Test"
  git config user.email "awh@example.com"
  bash tools/git-hooks/install.sh >/dev/null
  git add .
  git commit -m "chore: initial scaffold" >/dev/null 2>&1

  printf '\n# hook main scenario\n' >> docs/STATUS.md
  git add docs/STATUS.md
  if git commit -m "docs: main protected status update" > "${RUN_DIR}/q-main.log" 2>&1; then
    echo "Q-MAIN: unexpected PASS"
    exit 11
  fi
  if ! grep -q "Committing protected workflow files directly on 'main' is not allowed." "${RUN_DIR}/q-main.log"; then
    echo "Q-MAIN: expected main hard-stop message missing"
    cat "${RUN_DIR}/q-main.log"
    exit 12
  fi
  git restore --staged docs/STATUS.md >/dev/null 2>&1 || true
  git checkout -- docs/STATUS.md >/dev/null 2>&1 || true

  git checkout -b develop >/dev/null 2>&1 || git checkout develop >/dev/null 2>&1
  printf '\n# hook develop scenario\n' >> docs/STATUS.md
  git add docs/STATUS.md
  if ! git commit \
    -m "docs: develop tracking update" \
    -m "AWH-Gate-Override: finalization-split" \
    -m "AWH-Gate-Reason: deterministic hook warning scenario" \
    > "${RUN_DIR}/q-develop.log" 2>&1; then
    echo "Q-DEVELOP: unexpected FAIL"
    cat "${RUN_DIR}/q-develop.log"
    exit 13
  fi
  if ! grep -q "WARNING: Committing tracking-state workflow files directly on 'develop'." "${RUN_DIR}/q-develop.log"; then
    echo "Q-DEVELOP: expected develop warning missing"
    cat "${RUN_DIR}/q-develop.log"
    exit 14
  fi

  git checkout -b feature/hook-test >/dev/null 2>&1
  printf 'feature pass\n' > hook-test.txt
  git add hook-test.txt
  if ! git commit -m "test: feature hook pass" > "${RUN_DIR}/q-feature.log" 2>&1; then
    echo "Q-FEATURE: unexpected FAIL"
    cat "${RUN_DIR}/q-feature.log"
    exit 15
  fi
) && ok "hook functional core" || fail "hook functional core"

[[ "${FAIL}" -eq 0 ]] && echo "RESULT: PASS" || echo "RESULT: FAIL"
exit "${FAIL}"
