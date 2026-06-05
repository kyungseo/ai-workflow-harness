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
#   - Optional-pack(HARNESS-ARCHITECTURE/MAINTAINER-GUIDE/WORKFLOW-MANUAL, 확장 prompt)은
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
  find "${TARGET}/prompts" -type f -name '*session-start.md' 2>/dev/null
}

optional_files() {
  local f
  for f in docs/HARNESS-ARCHITECTURE.md docs/HARNESS-MAINTAINER-GUIDE.md docs/WORKFLOW-MANUAL.md; do
    [[ -f "${TARGET}/${f}" ]] && echo "${TARGET}/${f}"
  done
  find "${TARGET}/prompts" -type f -name '*.md' ! -name '*session-start.md' ! -name 'README.md' 2>/dev/null
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
    for dr in $(grep -ohE 'DR-[0-9]{3}' "${file}" | sort -u); do
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
      for dr in $(grep -ohE 'DR-[0-9]{3}' "${file}" | sort -u); do
        dr_exists "${dr}" || echo "  REPORT: ${file#${TARGET}/} -> ${dr} (optional doc dangling)"
      done
    done < "${TMPLIST}"
  else
    echo "  (optional pack 부재 — default minimal)"
  fi

  # [2] no-source-only-leakage (core A-class hard-fail)
  echo ""
  echo "== [2] no-source-only-leakage (core A-class hard-fail) =="
  local LEAK_PATTERN='ai-workflow-harness|/Users/|/home/[a-z]'
  local leak_hits=0
  core_files > "${TMPLIST}"
  while IFS= read -r file; do
    [[ -z "${file}" ]] && continue
    if grep -nHE "${LEAK_PATTERN}" "${file}" >/dev/null 2>&1; then
      grep -nHE "${LEAK_PATTERN}" "${file}" | sed "s|${TARGET}/|  LEAK: |"
      leak_hits=1
      FAIL=1
    fi
  done < "${TMPLIST}"
  [[ "${leak_hits}" -eq 0 ]] && echo "  OK: core A-class에 source-only 식별자/경로 누수 없음"

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
    for f5 in '"manifest_version"' '"harness_version"' '"hash_mode": "normalized_source_template"' '"framework_files"'; do
      grep -q "${f5}" "${manifest}" || { echo "  FAIL: manifest 필드 누락: ${f5}"; c5_fail=1; }
    done
    # 갓 생성한 target은 source 대비 drift 0이어야 한다(자기일관성)
    if grep -q '"path"' "${manifest}"; then
      local drift_line
      drift_line="$("${REPO_ROOT}/scripts/create-harness.sh" --check "${TARGET}" 2>/dev/null | grep 'summary:')"
      if ! printf '%s' "${drift_line}" | grep -q ', 0 drifted'; then
        echo "  FAIL: --check 자기일관성 위반 → ${drift_line}"
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
fi

echo ""
if [[ "${GLOBAL_FAIL}" -eq 0 ]]; then
  echo "OVERALL: PASS (all modes green)"
else
  echo "OVERALL: FAIL"
fi
exit "${GLOBAL_FAIL}"
