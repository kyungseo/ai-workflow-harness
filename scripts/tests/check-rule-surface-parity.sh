#!/usr/bin/env bash
# check-rule-surface-parity.sh — Safety rule layer surface parity (CHORE-20260713-007)
#
# skills/safety/ canonical(A1 always / A2 path-scoped)과 4툴 adapter/entry의 정합을 검사한다.
# workflow mirror parity(check-surface-mirror-parity.sh)와는 별도다 — 적용 메커니즘이 다르다
# (호출형 command vs always/path-scoped rule).
#
# 검사 범위 (내용 동등성은 검사하지 않는다 — adapter는 thin projection):
#   [a] canonical A1/A2 존재
#   [b] 각 adapter/entry의 canonical pointer 존재 (literal fixed-string)
#   [c] scope semantics — Claude A1 always·A2 path / Cursor A1 alwaysApply·A2 glob /
#       AGENTS.md A1 session-start·A2 conditional
#   [c2] thin projection invariant — adapter에 canonical 전문(MUST:/NEVER: 블록, 다중 bullet) 재유입 탐지
#   [d] create-harness.sh copy matrix (실제 copy loop 라인 anchored)
#   [e] (--scaffold 모드) temp generic scaffold 실생성: 파일 7종(canonical 3 + adapter 4)
#       + generated AGENTS.md routing + manifest tracked entry 신규 5개 path 전건 (python3 exact match)
#
# 사용: bash scripts/tests/check-rule-surface-parity.sh [--scaffold]

set -euo pipefail
cd "$(dirname "$0")/../.."

FAIL=0
ok()   { echo "  OK: $1"; }
fail() { echo "  FAIL: $1"; FAIL=1; }

A1_CANON="skills/safety/safety-critical.md"
A2_CANON="skills/safety/infra.md"

echo "== [a] canonical A1/A2 존재 =="
for f in "${A1_CANON}" "${A2_CANON}"; do
  [[ -f "$f" ]] && ok "$f" || fail "$f 없음"
done

echo "== [b] adapter/entry canonical pointer (literal) =="
declare -a PTR_CHECKS=(
  ".claude/rules/safety-critical.md:${A1_CANON}"
  ".claude/rules/infra.md:${A2_CANON}"
  ".cursor/rules/safety-critical.mdc:${A1_CANON}"
  ".cursor/rules/infra.mdc:${A2_CANON}"
  "AGENTS.md:${A1_CANON}"
  "AGENTS.md:${A2_CANON}"
)
for pair in "${PTR_CHECKS[@]}"; do
  file="${pair%%:*}"; canon="${pair#*:}"
  if [[ -f "$file" ]] && grep -qF "$canon" "$file"; then
    ok "$file -> $canon"
  else
    fail "$file 에 $canon pointer 없음"
  fi
done

echo "== [c] scope semantics =="
grep -Eq '^\s*-\s*"\*\*"' .claude/rules/safety-critical.md \
  && ok "Claude A1 always (paths: \"**\")" || fail "Claude A1 paths \"**\" 아님"
grep -qF '"infra/**"' .claude/rules/infra.md \
  && ok "Claude A2 path-scoped (infra/**)" || fail "Claude A2 infra path scope 없음"
grep -q '^alwaysApply: true$' .cursor/rules/safety-critical.mdc \
  && ok "Cursor A1 alwaysApply: true" || fail "Cursor A1 alwaysApply true 아님"
grep -q '^globs: infra/\*\*' .cursor/rules/infra.mdc && grep -q '^alwaysApply: false$' .cursor/rules/infra.mdc \
  && ok "Cursor A2 glob-scoped" || fail "Cursor A2 glob scope/alwaysApply false 아님"
grep -qF 'At session start, load and follow `skills/safety/safety-critical.md`' AGENTS.md \
  && ok "AGENTS.md A1 session-start 로드 지시" || fail "AGENTS.md A1 session-start 지시 없음"
grep -qF 'When working on infrastructure' AGENTS.md \
  && ok "AGENTS.md A2 conditional 로드 지시" || fail "AGENTS.md A2 conditional 지시 없음"

echo "== [c2] thin projection invariant (adapter 전문 재유입 탐지) =="
for f in .claude/rules/safety-critical.md .claude/rules/infra.md \
         .cursor/rules/safety-critical.mdc .cursor/rules/infra.mdc; do
  # 주의: adapter의 한 줄 directive("CRITICAL: Load and follow ...")는 허용 —
  # 전문 블록 marker인 MUST:/NEVER: 헤딩만 재유입으로 판정한다.
  if grep -Eq '^(MUST|NEVER):' "$f"; then
    fail "$f 에 canonical 전문 heading(MUST:/NEVER:) 재유입"
  elif [[ "$(grep -cE '^- ' "$f" || true)" -gt 3 ]]; then
    fail "$f 에 다중 bullet body 재유입 (thin projection 경계 초과)"
  else
    ok "$f thin projection 유지"
  fi
done

echo "== [d] create-harness.sh copy matrix (loop 라인 anchored) =="
grep -qF 'adapt "$f" "${TARGET_ROOT}/skills/safety/$(basename "$f")"' scripts/create-harness.sh \
  && ok "skills/safety copy loop (adapt destination)" || fail "skills/safety adapt copy loop 없음"
grep -qF 'for f in docs-workflow.md infra.md safety-critical.md; do' scripts/create-harness.sh \
  && ok "Claude rules copy loop (safety-critical.md 포함)" || fail "Claude copy loop에 safety-critical.md 없음"
grep -E '^for f in .*infra\.mdc.*safety-critical\.mdc.*; do$' scripts/create-harness.sh | grep -q 'behavior-principles.mdc' \
  && ok "Cursor rules copy loop (infra.mdc 포함)" || fail "Cursor copy loop에 infra.mdc 없음"

if [[ "${1:-}" == "--scaffold" ]]; then
  echo "== [e] temp generic scaffold 실생성 검증 =="
  TMPDIR_E="$(mktemp -d "${TMPDIR:-/tmp}/rule-parity.XXXXXX")"
  trap 'rm -rf "${TMPDIR_E}"' EXIT
  bash scripts/create-harness.sh rule-parity-probe "${TMPDIR_E}/target" >/dev/null
  for f in skills/safety/safety-critical.md skills/safety/infra.md skills/safety/README.md \
           .claude/rules/safety-critical.md .claude/rules/infra.md \
           .cursor/rules/safety-critical.mdc .cursor/rules/infra.mdc; do
    [[ -f "${TMPDIR_E}/target/${f}" ]] && ok "scaffold: ${f}" || fail "scaffold에 ${f} 없음"
  done
  GEN_AGENTS="${TMPDIR_E}/target/AGENTS.md"
  for canon in "${A1_CANON}" "${A2_CANON}"; do
    grep -qF "$canon" "${GEN_AGENTS}" \
      && ok "generated AGENTS.md -> ${canon}" || fail "generated AGENTS.md에 ${canon} routing 없음"
  done
  grep -qF 'At session start, load and follow `skills/safety/safety-critical.md`' "${GEN_AGENTS}" \
    && ok "generated AGENTS.md A1 session-start 지시" || fail "generated AGENTS.md A1 지시 없음"
  MANIFEST="${TMPDIR_E}/target/.harness/manifest.json"
  if [[ -f "${MANIFEST}" ]] && command -v python3 >/dev/null; then
    if python3 - "${MANIFEST}" <<'PYEOF'
import json, sys
m = json.load(open(sys.argv[1]))
tracked = {f["path"] for f in m["framework_files"]}
new_paths = {
    "skills/safety/README.md",
    "skills/safety/safety-critical.md",
    "skills/safety/infra.md",
    ".claude/rules/safety-critical.md",
    ".cursor/rules/infra.mdc",
}
missing = sorted(new_paths - tracked)
if missing:
    print("missing manifest entries:", missing)
    sys.exit(1)
PYEOF
    then
      ok "manifest tracked: 신규 5개 path 전건 (exact)"
    else
      fail "manifest tracked 신규 path 누락"
    fi
  else
    fail "scaffold manifest 없음 또는 python3 부재"
  fi
fi

if [[ "${FAIL}" -eq 0 ]]; then
  echo "OVERALL: PASS (rule surface parity 정합)"
else
  echo "OVERALL: FAIL"
  exit 1
fi
