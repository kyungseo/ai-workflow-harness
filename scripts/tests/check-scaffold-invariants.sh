#!/usr/bin/env bash
# check-scaffold-invariants.sh — slice 1b direction-invariant tests.
#
# 방향(DR-021~024)과 무관하게 영구 참인 scaffold 출력 불변식을 검증한다.
#   1) no-dangling-reference : core A-class 문서의 DR-NNN 참조가 target에 실재하는가
#   2) no-source-only-leakage : core A-class 출력에 source-only 식별자/경로가 누수됐는가
#   3) decisions/README index <-> DR 파일 closure (D2 seed)
#
# Scope (DR-021 boundary):
#   - core A-class (hard-fail): entrypoint/protocol/rule/command/skill/cursor/session-start/decisions
#   - Optional-pack (report-only): HARNESS-ARCHITECTURE/MAINTAINER-GUIDE/WORKFLOW-MANUAL, 확장 prompt
#     -> minimal-output 하류 slice(#9, DR-021)가 default 제외로 해소할 known debt
#
# Usage:
#   scripts/tests/check-scaffold-invariants.sh [target-dir]
#   인자 없으면 temp scaffold를 생성해 검사 후 정리한다.
#
# Note: POSIX-syntax 안전(process substitution 미사용) — pre-commit 'sh -n' 통과용.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

TARGET="${1:-}"
CLEANUP=false
TMPLIST="$(mktemp)"
if [[ -z "${TARGET}" ]]; then
  TARGET="$(mktemp -d)/harness-invariant-check"
  CLEANUP=true
  echo "[setup] generic temp scaffold 생성: ${TARGET}"
  "${REPO_ROOT}/scripts/create-harness.sh" invariant-check-proj "${TARGET}" >/dev/null
fi

if [[ ! -d "${TARGET}" ]]; then
  echo "ERROR: target dir 없음: ${TARGET}" >&2
  exit 2
fi

cleanup() {
  rm -f "${TMPLIST}"
  [[ "${CLEANUP}" == true ]] && rm -rf "$(dirname "${TARGET}")"
}
trap cleanup EXIT

# ── helpers ──────────────────────────────────────────────────────────────────
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

FAIL=0

# ── 1) no-dangling-reference (core A-class hard-fail) ────────────────────────
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

# ── 1r) Optional-pack report-only / known debt ──────────────────────────────
echo ""
echo "== [1r] no-dangling-reference (Optional-pack report-only / known debt) =="
optional_files > "${TMPLIST}"
while IFS= read -r file; do
  [[ -z "${file}" ]] && continue
  for dr in $(grep -ohE 'DR-[0-9]{3}' "${file}" | sort -u); do
    dr_exists "${dr}" || echo "  REPORT: ${file#${TARGET}/} -> ${dr} (minimal-output 하류 제거 대상)"
  done
done < "${TMPLIST}"

# ── 2) no-source-only-leakage (core A-class hard-fail) ──────────────────────
echo ""
echo "== [2] no-source-only-leakage (core A-class hard-fail) =="
# source-only 식별자/경로: un-substituted source identity, absolute local path
LEAK_PATTERN='ai-workflow-harness|/Users/|/home/[a-z]'
leak_hits=0
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

# ── 3) decisions/README index <-> DR 파일 closure (D2 seed) ──────────────────
echo ""
echo "== [3] decisions/README index closure (D2 seed hard-fail) =="
readme="${TARGET}/docs/decisions/README.md"
c3_fail=0
if [[ ! -f "${readme}" ]]; then
  echo "  FAIL: docs/decisions/README.md 없음 (D2 seed 누락)"
  c3_fail=1
else
  # rows -> files
  for dr in $(grep -oE 'DR-[0-9]{3}' "${readme}" | sort -u); do
    dr_exists "${dr}" || { echo "  FAIL: README가 ${dr} 나열하나 DR 파일 없음"; c3_fail=1; }
  done
  # files -> rows
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

echo ""
if [[ "${FAIL}" -eq 0 ]]; then
  echo "RESULT: PASS (core A-class invariants green)"
else
  echo "RESULT: FAIL"
fi
exit "${FAIL}"
