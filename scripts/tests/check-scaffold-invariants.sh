#!/usr/bin/env bash
# check-scaffold-invariants.sh — slice 1b direction-invariant tests.
#
# 방향(DR-021~024)과 무관하게 영구 참인 scaffold 출력 불변식을 검증한다.
#   1) no-dangling-reference : core A-class 문서의 DR-NNN 참조가 target에 실재하는가
#   1r) Optional-pack report-only : optional docs의 dangling은 경고만(default에선 부재)
#   2) no-source-only-leakage : core A-class 출력에 source-only 식별자/경로가 누수됐는가
#   3) decisions/README index <-> DR 파일 closure
#   4) root README 파일표 <-> optional docs on-disk 일치 (S5, 모드 무관)
#
# Scope (DR-021 boundary):
#   - core A-class (hard-fail): entrypoint/protocol/rule/command/skill/cursor/session-start/decisions
#   - Optional-pack(HARNESS-ARCHITECTURE/MAINTAINER-GUIDE/WORKFLOW-MANUAL)은
#     default minimal scaffold에 부재(slice #9, DR-021). --with-optional에서만 포함되며
#     이때 companion DR(DR-017/DR-020) closure가 [1]/[3]으로 hard-fail 검증된다.
#
# Modes:
#   - 인자 없으면 default minimal + --with-optional 두 모드를 각각 생성·검사한다.
#   - target-dir 인자를 주면 그 target만 검사한다.
#
# Usage:
#   scripts/tests/check-scaffold-invariants.sh [target-dir]
#
# Note: POSIX-syntax 안전(process substitution 미사용) — pre-commit 'sh -n' 통과용.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

TARGET_ARG="${1:-}"
TMPLIST="$(mktemp)"
GEN_BASE=""
GLOBAL_FAIL=0
TARGET=""

cleanup() {
  rm -f "${TMPLIST}"
  [[ -n "${GEN_BASE}" ]] && rm -rf "${GEN_BASE}"
  return 0  # EXIT trap이 exit code를 덮어쓰지 않게 한다(target 인자 모드에서 GEN_BASE="" → [[ ]] false=1 누수 방지)
}
trap cleanup EXIT

# ── helpers (global ${TARGET} 기준) ──────────────────────────────────────────
dr_exists() {
  local x
  for x in "${TARGET}"/docs/decisions/"$1"-*.md; do
    [[ -e "${x}" ]] && return 0
  done
  return 1
}

# core A-class 파일 목록을 stdout으로
core_files() {
  local f
  for f in \
    CLAUDE.md AGENTS.md \
    docs/BEHAVIOR-PRINCIPLES.md docs/AGENT-WORKFLOW.md \
    docs/HARNESS-PROTOCOL.md docs/HARNESS-NAMING-RULES.md \
    docs/HARNESS-RECOVERY-VALIDATION.md docs/HARNESS-PARALLEL-WORK-CONTROLS.md \
    docs/HARNESS-QUICK-REFERENCE.md; do
    [[ -f "${TARGET}/${f}" ]] && echo "${TARGET}/${f}"
  done
  find "${TARGET}/docs/decisions" "${TARGET}/.claude/rules" "${TARGET}/.claude/commands" \
       "${TARGET}/.agents/skills" "${TARGET}/.cursor/rules" \
       -type f \( -name '*.md' -o -name '*.mdc' \) 2>/dev/null
  find "${TARGET}/skills/workflow" -type f -name '*.md' 2>/dev/null
  find "${TARGET}/skills/safety" -type f -name '*.md' 2>/dev/null
  find "${TARGET}/prompts" -type f -name '*session-start.md' 2>/dev/null
}

optional_files() {
  local f
  for f in docs/HARNESS-ARCHITECTURE.md docs/HARNESS-MAINTAINER-GUIDE.md docs/WORKFLOW-MANUAL.md; do
    [[ -f "${TARGET}/${f}" ]] && echo "${TARGET}/${f}"
  done
  find "${TARGET}/prompts" -type f -name '*.md' ! -name '*session-start.md' ! -name 'README.md' 2>/dev/null
}

# leak-scan 전용 파일 목록: core A-class + source-gitflow shipped adapt text set.
# [2] no-source-only-leakage 전용이다. [1] no-dangling-reference/[3] closure는 core_files만
# 쓴다(같은 목록을 모든 check에 쓰면 DR closure 범위가 의도치 않게 커지므로 분리).
# source-gitflow extras는 --workflow source-gitflow target에만 존재하므로 [[ -f ]]로 가드한다.
leak_scan_files() {
  core_files
  local f
  for f in \
    docs/GIT-WORKFLOW.md \
    .github/workflows/harness-validate.yml \
    tools/git-hooks/pre-commit tools/git-hooks/commit-msg \
    tools/git-hooks/install.sh tools/git-hooks/lib/gate-lists.sh; do
    [[ -f "${TARGET}/${f}" ]] && echo "${TARGET}/${f}"
  done
  return 0  # 마지막 [[ -f ]] && 가 false(1)로 끝나도 set -e가 호출부를 죽이지 않게 한다
}

# ── 단일 target 검사 (global ${TARGET}, ${GLOBAL_FAIL} 갱신) ─────────────────
check_target() {
  local FAIL=0
  local file dr

  # [1] no-dangling-reference (core A-class hard-fail)
  echo ""
  echo "== [1] no-dangling-reference (core A-class hard-fail) =="
  core_files > "${TMPLIST}"
  while IFS= read -r file; do
    [[ -z "${file}" ]] && continue
    for dr in $(grep -vE '^Linked DRs:' "${file}" | grep -ohE 'DR-[0-9]{3}' | sort -u); do
      if ! dr_exists "${dr}"; then
        echo "  FAIL: ${file#${TARGET}/} -> ${dr} (target에 DR 파일 없음)"
        FAIL=1
      fi
    done
  done < "${TMPLIST}"
  [[ "${FAIL}" -eq 0 ]] && echo "  OK: core A-class DR 참조 모두 실재"

  # [1r] Optional-pack report-only
  echo ""
  echo "== [1r] no-dangling-reference (Optional-pack report-only) =="
  optional_files > "${TMPLIST}"
  if [[ -s "${TMPLIST}" ]]; then
    while IFS= read -r file; do
      [[ -z "${file}" ]] && continue
      for dr in $(grep -vE '^Linked DRs:' "${file}" | grep -ohE 'DR-[0-9]{3}' | sort -u); do
        dr_exists "${dr}" || echo "  REPORT: ${file#${TARGET}/} -> ${dr} (optional doc dangling)"
      done
    done < "${TMPLIST}"
  else
    echo "  (optional pack 부재 — default minimal)"
  fi

  # [2] no-source-only-leakage (core A-class + source-gitflow shipped, hard-fail)
  echo ""
  echo "== [2] no-source-only-leakage (core A-class + source-gitflow shipped, hard-fail) =="
  local LEAK_PATTERN='ai-workflow-harness|/Users/|/home/[a-z]'
  local leak_hits=0
  leak_scan_files > "${TMPLIST}"
  while IFS= read -r file; do
    [[ -z "${file}" ]] && continue
    if grep -nHE "${LEAK_PATTERN}" "${file}" >/dev/null 2>&1; then
      grep -nHE "${LEAK_PATTERN}" "${file}" | sed "s|${TARGET}/|  LEAK: |"
      leak_hits=1
      FAIL=1
    fi
  done < "${TMPLIST}"
  [[ "${leak_hits}" -eq 0 ]] && echo "  OK: core A-class + source-gitflow shipped에 source-only 식별자/경로 누수 없음"

  # [3] decisions/README index <-> DR 파일 closure
  echo ""
  echo "== [3] decisions/README index closure (hard-fail) =="
  local readme="${TARGET}/docs/decisions/README.md"
  local c3_fail=0 n f
  if [[ ! -f "${readme}" ]]; then
    echo "  FAIL: docs/decisions/README.md 없음"
    c3_fail=1
  else
    for dr in $(grep -oE 'DR-[0-9]{3}' "${readme}" | sort -u); do
      dr_exists "${dr}" || { echo "  FAIL: README가 ${dr} 나열하나 DR 파일 없음"; c3_fail=1; }
    done
    for f in "${TARGET}"/docs/decisions/DR-*.md; do
      [[ -e "${f}" ]] || continue
      n="$(basename "${f}" | grep -oE 'DR-[0-9]{3}')"
      grep -q "${n}" "${readme}" || { echo "  FAIL: ${n} 복사됐으나 README index 미등재"; c3_fail=1; }
    done
  fi
  if [[ "${c3_fail}" -eq 0 ]]; then
    echo "  OK: README index <-> DR 파일 closure 일치"
  else
    FAIL=1
  fi

  # [4] root README 파일표 <-> optional docs on-disk 일치 (S5, 모드 무관)
  echo ""
  echo "== [4] root README <-> optional docs 일치 (hard-fail) =="
  local root_readme="${TARGET}/README.md"
  local c4_fail=0 doc base_doc on_disk in_readme
  if [[ ! -f "${root_readme}" ]]; then
    echo "  FAIL: root README.md 없음"
    c4_fail=1
  else
    for doc in HARNESS-ARCHITECTURE.md HARNESS-MAINTAINER-GUIDE.md WORKFLOW-MANUAL.md; do
      on_disk=0; in_readme=0
      [[ -f "${TARGET}/docs/${doc}" ]] && on_disk=1
      grep -q "docs/${doc}" "${root_readme}" && in_readme=1
      if [[ "${on_disk}" -ne "${in_readme}" ]]; then
        echo "  FAIL: ${doc} on-disk=${on_disk} != README-listed=${in_readme}"
        c4_fail=1
      fi
    done
  fi
  if [[ "${c4_fail}" -eq 0 ]]; then
    echo "  OK: root README 파일표가 optional docs 출력과 일치"
  else
    FAIL=1
  fi

  # [5] .harness/manifest.json 존재·shape + --check 자기일관성 (Q4)
  echo ""
  echo "== [5] manifest + --check 자기일관성 (hard-fail) =="
  local manifest="${TARGET}/.harness/manifest.json"
  local c5_fail=0 f5
  if [[ ! -f "${manifest}" ]]; then
    echo "  FAIL: .harness/manifest.json 없음"
    c5_fail=1
  else
    # Manifest 해석은 --check와 동일하게 JSON grammar 기준(python3)으로 판정한다
    # (CHORE-20260713-003 R1-F3: formatting-sensitive grep은 --check가 지원하는
    # compact/pretty JSON을 거부해 parser 계약이 갈라진다). hash_mode 계약과
    # canonical provenance 필수화는 --check validator가 SSoT로 강제하므로(아래
    # 자기일관성 호출에서 invalid manifest는 exit 2 → FAIL로 잡힘) 여기서는
    # invariant 고유 필드(manifest_version 등)의 존재만 JSON으로 확인한다.
    if [[ -n "${HARNESS_CHECK_FORCE_NO_PYTHON:-}" ]] || ! command -v python3 >/dev/null 2>&1; then
      echo "  FAIL: manifest 필드 검사에 python3 필요 (--check와 동일한 fail-closed 계약)"
      c5_fail=1
    elif ! python3 - "${manifest}" <<'PY'
import json, sys
try:
    m = json.load(open(sys.argv[1], encoding="utf-8"))
except (OSError, ValueError) as e:
    sys.stderr.write("  FAIL: manifest JSON parse 실패: %s\n" % e); sys.exit(1)
missing = [k for k in ("manifest_version", "harness_version", "framework_files") if k not in m]
if missing:
    sys.stderr.write("  FAIL: manifest 필드 누락: %s\n" % ", ".join(missing)); sys.exit(1)
PY
    then
      c5_fail=1
    fi
    # 갓 생성한 target은 source 대비 drift 0이어야 한다(자기일관성).
    # --check는 조건 없이 항상 호출한다(R1b-F1: 과거 '"path"' substring guard는
    # entry 없는 invalid manifest를 검사 없이 통과시켰다). --check 실패(invalid
    # manifest exit 2, untracked exit 3 포함)는 set -euo pipefail로 스크립트가
    # 중간 종료되지 않도록 exit code를 잡아 명시적 FAIL로 변환한다.
    local check_out drift_line check_rc
    check_rc=0
    check_out="$("${REPO_ROOT}/scripts/create-harness.sh" --check "${TARGET}" 2>&1)" || check_rc=$?
    if [[ "${check_rc}" -ne 0 ]]; then
      echo "  FAIL: --check 실패 (exit ${check_rc}) — invalid manifest 또는 판정 불가"
      printf '%s\n' "${check_out}" | tail -3 | sed 's/^/    /'
      c5_fail=1
    else
      drift_line="$(printf '%s' "${check_out}" | grep 'summary:' || true)"
      if ! printf '%s' "${drift_line}" | grep -q ', 0 drifted'; then
        echo "  FAIL: --check 자기일관성 위반 → ${drift_line:-summary 출력 없음}"
        c5_fail=1
      fi
    fi
  fi
  if [[ "${c5_fail}" -eq 0 ]]; then
    echo "  OK: manifest 형식 + --check 자기일관성(drift 0)"
  else
    FAIL=1
  fi

  echo ""
  if [[ "${FAIL}" -eq 0 ]]; then
    echo "RESULT: PASS"
  else
    echo "RESULT: FAIL"
    GLOBAL_FAIL=1
  fi
}

# ── 모드 디스패치 ────────────────────────────────────────────────────────────
if [[ -n "${TARGET_ARG}" ]]; then
  TARGET="${TARGET_ARG}"
  if [[ ! -d "${TARGET}" ]]; then
    echo "ERROR: target dir 없음: ${TARGET}" >&2
    exit 2
  fi
  echo "### MODE: provided target (${TARGET})"
  check_target
else
  GEN_BASE="$(mktemp -d)"

  echo "### MODE: default minimal"
  TARGET="${GEN_BASE}/default/proj"
  "${REPO_ROOT}/scripts/create-harness.sh" invariant-check-proj "${TARGET}" >/dev/null
  check_target

  echo ""
  echo "### MODE: --with-optional"
  TARGET="${GEN_BASE}/withopt/proj"
  "${REPO_ROOT}/scripts/create-harness.sh" --with-optional invariant-check-proj "${TARGET}" >/dev/null
  check_target

  echo ""
  echo "### MODE: --workflow source-gitflow"
  TARGET="${GEN_BASE}/gitflow/proj"
  "${REPO_ROOT}/scripts/create-harness.sh" --workflow source-gitflow invariant-check-proj "${TARGET}" >/dev/null
  check_target
fi

echo ""
if [[ "${GLOBAL_FAIL}" -eq 0 ]]; then
  echo "OVERALL: PASS (all modes green)"
else
  echo "OVERALL: FAIL"
fi
exit "${GLOBAL_FAIL}"
