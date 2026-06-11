#!/usr/bin/env bash
# run-harness-checks.sh — harness 검증 척추 runner (thin orchestrator).
#
# 기준 문서: docs/maintainer/HARNESS-TEST-TAXONOMY.md (source-only maintainer 문서)
#
# 역할: 기존 deterministic 검증을 tier별로 호출하고 exit code를 집계한다.
#   검증 로직은 기존 스크립트에 위임한다(재구현 금지 — runner는 호출 선택 + 집계만).
#
# Tier:
#   --tier0          syntax/무결성. 생성 없음 (bash -n create-harness.sh, git diff --check)
#   --tier1 <target> 제공된 기존 target만 검사. 생성 없음 (closure + invariants <target>)
#   --tier2          temp/harness-tests/<scenario>-<ts>/에 scaffold 실제 생성 후 invariants + cleanup
#   --all            tier0 + source-level tier1(closure) + tier2(실제 생성 포함). exit code 누적
#
# Graceful skip (adopter-safe): 이 runner는 scaffold로 ship될 수 있다. adopter repo에는
#   scripts/create-harness.sh / maintainer 검증 스크립트가 없을 수 있으므로, 부재 시 해당
#   step을 SKIP(N/A)으로 빠지고 실패로 치지 않는다. adopter repo에서 runner가 깨지지 않는다.
#
# 사용: bash scripts/tests/run-harness-checks.sh {--tier0 | --tier1 <target> | --tier2 | --all}
# exit 0 = 전부 PASS/SKIP, 1 = 하나 이상 FAIL, 2 = usage error
#
# Note: POSIX-syntax 안전(process substitution 미사용) — pre-commit 'sh -n' 통과 지향.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

CREATE_SH="${REPO_ROOT}/scripts/create-harness.sh"
INVARIANTS="${SCRIPT_DIR}/check-scaffold-invariants.sh"
CLOSURE="${SCRIPT_DIR}/check-shipped-dr-closure.sh"

RC=0
mark_fail() { RC=1; }

usage() {
  cat >&2 <<'EOF'
usage: run-harness-checks.sh {--tier0 | --tier1 <target-dir> | --tier2 | --all}

  --tier0          syntax/무결성. 생성 없음.
  --tier1 <target> 제공된 기존 target만 검사. 생성 없음 (target 인자 필수).
  --tier2          temp/harness-tests/...에 scaffold 실제 생성 후 검사 + cleanup.
  --all            tier0 + source-level tier1(closure) + tier2.
                   주의: --all과 --tier2는 실제 scaffold를 생성한다(repo-local temp/만 사용).

  adopter-safe: create-harness.sh / 검증 스크립트 부재 시 해당 step은 SKIP(N/A).
EOF
}

# ── Tier 0: syntax / 무결성 (생성 없음) ──────────────────────────────────────
run_tier0() {
  echo "== Tier 0: syntax / 무결성 =="
  if [[ -f "${CREATE_SH}" ]]; then
    if bash -n "${CREATE_SH}"; then
      echo "  OK: bash -n create-harness.sh"
    else
      echo "  FAIL: bash -n create-harness.sh"; mark_fail
    fi
  else
    echo "  SKIP (N/A): scripts/create-harness.sh 없음"
  fi
  # verification spine의 executable SSoT인 source test scripts 자체도 syntax 검사 대상이다.
  local ts
  for ts in "${SCRIPT_DIR}"/*.sh; do
    [[ -f "${ts}" ]] || continue
    if bash -n "${ts}"; then
      echo "  OK: bash -n $(basename "${ts}")"
    else
      echo "  FAIL: bash -n $(basename "${ts}")"; mark_fail
    fi
  done
  if git -C "${REPO_ROOT}" diff --check; then
    echo "  OK: git diff --check (whitespace)"
  else
    echo "  FAIL: git diff --check (whitespace 오류)"; mark_fail
  fi
}

# ── Tier 1: shipped DR closure (source-level, 생성 없음) ─────────────────────
run_closure() {
  echo "== Tier 1: shipped DR closure (source-level) =="
  if [[ -f "${CLOSURE}" ]]; then
    if bash "${CLOSURE}"; then
      echo "  OK: shipped DR closure"
    else
      echo "  FAIL: shipped DR closure"; mark_fail
    fi
  else
    echo "  SKIP (N/A): check-shipped-dr-closure.sh 없음"
  fi
}

# ── invariants 호출 (제공된 target 검사 — 생성 없음) ─────────────────────────
run_invariants_on() {
  local target="$1"
  if [[ ! -f "${INVARIANTS}" ]]; then
    echo "  SKIP (N/A): check-scaffold-invariants.sh 없음"
    return 0
  fi
  if bash "${INVARIANTS}" "${target}"; then
    echo "  OK: invariants (${target#${REPO_ROOT}/})"
  else
    echo "  FAIL: invariants (${target#${REPO_ROOT}/})"; mark_fail
  fi
}

# ── Tier 1 진입 (target 필수, 생성 없음) ─────────────────────────────────────
run_tier1() {
  local target="$1"
  if [[ -z "${target}" ]]; then
    echo "ERROR: --tier1은 <target-dir> 인자가 필수입니다 (생성하지 않음)." >&2
    usage
    exit 2
  fi
  if [[ ! -d "${target}" ]]; then
    echo "ERROR: target dir 없음: ${target}" >&2
    exit 2
  fi
  run_closure
  echo "== Tier 1: invariants on provided target =="
  run_invariants_on "${target}"
}

# ── 단일 모드 생성→검사→cleanup (label, create-harness 추가 플래그...) ───────
# create-harness.sh 인자 순서: [flags...] <name> <target>. 마지막에 name+target을 붙인다.
gen_and_check() {
  local label="$1"; shift
  local base="${REPO_ROOT}/temp/harness-tests"
  local gen="${base}/sim-${label}-$(date +%Y%m%d-%H%M%S)-$$"
  mkdir -p "${base}"
  echo "  [${label}] 생성: ${gen#${REPO_ROOT}/}"
  if "${CREATE_SH}" "$@" run-harness-checks-sim "${gen}" >/dev/null 2>&1; then
    run_invariants_on "${gen}"
  else
    echo "  FAIL: [${label}] scaffold 생성 실패"
    mark_fail
  fi
  rm -rf "${gen}"
  echo "  [${label}] cleanup 완료"
}

# ── Tier 2: scaffold 실제 생성 후 검사 (repo-local temp/) ────────────────────
# check-scaffold-invariants.sh no-arg와 동일 coverage: default minimal + --with-optional +
# --workflow source-gitflow 세 모드. source-gitflow는 GIT-WORKFLOW.md/hooks 등 shipped 표면을
# leak-scan 대상에 포함시키므로 반드시 함께 생성·검사한다.
run_tier2() {
  echo "== Tier 2: scaffold 실제 생성 후 검사 (temp/, default + --with-optional + source-gitflow) =="
  if [[ ! -f "${CREATE_SH}" ]]; then
    echo "  SKIP (N/A): scripts/create-harness.sh 없음 — 생성 불가"
    return 0
  fi
  gen_and_check "default"
  gen_and_check "optional" --with-optional
  gen_and_check "gitflow" --workflow source-gitflow
}

# ── 디스패치 ─────────────────────────────────────────────────────────────────
MODE="${1:-}"
case "${MODE}" in
  --tier0) run_tier0 ;;
  --tier1) run_tier1 "${2:-}" ;;
  --tier2) run_tier2 ;;
  --all)
    run_tier0
    run_closure
    run_tier2
    ;;
  -h|--help) usage; exit 0 ;;
  *) usage; exit 2 ;;
esac

echo ""
if [[ "${RC}" -eq 0 ]]; then
  echo "OVERALL: PASS (FAIL 없음; SKIP은 N/A)"
else
  echo "OVERALL: FAIL"
fi
exit "${RC}"
