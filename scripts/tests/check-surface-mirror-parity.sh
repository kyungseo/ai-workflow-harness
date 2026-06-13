#!/usr/bin/env bash
# check-surface-mirror-parity.sh — source-side workflow surface mirror/prompt 존재 parity.
#
# Scope (source repo 전용): canonical workflow command가 tool-specific mirror를 모두 갖는지와
#   session-start prompt 3종이 존재하는지 deterministic하게 점검한다. 변경 시점 절차 규칙
#   (Mirror Atomicity rule, repo-health Area A)이 잡지 못하는 "임의 시점 전체 set 완전성"을
#   회귀로 잠근다. 판단(과잉반복·adapter 비대·canonical 참조 정합)은 catalog/repo-health 유지.
#
# 점검 항목:
#   1) canonical command(skills/workflow/*.md, slice/README 제외) ↔ .claude/commands/{name}.md
#   2) canonical command ↔ .agents/skills/workflow-{name}/SKILL.md
#   3) 역방향 orphan: .claude/commands/{name}.md 중 canonical 없는 것
#   4) session-start prompt 3종(claude/codex/cursor) 존재
#
# Non-command canonical (mirror 없음이 정상 — slice/index):
#   여기 명시해 coverage 누락을 가시화한다. slice가 늘면 이 목록을 갱신한다.
#   (default-template-parity.sh의 explicit registry와 동일 철학)
#
# Usage:
#   bash scripts/tests/check-surface-mirror-parity.sh
#   bash scripts/tests/check-surface-mirror-parity.sh --root <repo-root>
#
# Exit:
#   0 = PASS/SKIP, 1 = FAIL, 2 = usage error
#
# Adopter-safe: skills/workflow/ 가 없으면 전체 SKIP(N/A) — adopter repo 구조 차이를 실패로 치지 않음.
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
usage: check-surface-mirror-parity.sh [--root <repo-root>]
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

CANONICAL_DIR="${REPO_ROOT}/skills/workflow"
CLAUDE_DIR="${REPO_ROOT}/.claude/commands"
AGENTS_DIR="${REPO_ROOT}/.agents/skills"
PROMPTS_DIR="${REPO_ROOT}/prompts"

# mirror가 없는 것이 정상인 canonical 파일(슬라이스/인덱스). slice 추가 시 갱신.
NON_COMMAND="README repo-health-full repo-health-cascade"

# session-start prompt 필수 3종.
PROMPT_SET="claude-session-start codex-session-start cursor-session-start"

is_non_command() {
  local name="$1" n
  for n in ${NON_COMMAND}; do
    [[ "${name}" == "${n}" ]] && return 0
  done
  return 1
}

# Adopter-safe: canonical surface가 없으면 점검 대상 아님.
if [[ ! -d "${CANONICAL_DIR}" ]]; then
  echo "SKIP (N/A): skills/workflow/ 없음 — source-only mirror parity 점검 대상 아님"
  exit 0
fi

RC=0
fail() { echo "  FAIL: $1"; RC=1; }

echo "== mirror parity: canonical command ↔ claude adapter ↔ agents skill =="
shopt -s nullglob
for f in "${CANONICAL_DIR}"/*.md; do
  name="$(basename "${f}" .md)"
  is_non_command "${name}" && continue
  [[ -f "${CLAUDE_DIR}/${name}.md" ]] || fail "claude adapter 누락: .claude/commands/${name}.md"
  [[ -f "${AGENTS_DIR}/workflow-${name}/SKILL.md" ]] || fail "agents skill 누락: .agents/skills/workflow-${name}/SKILL.md"
done

echo "== 역방향 orphan: claude adapter 중 canonical 없는 것 =="
for f in "${CLAUDE_DIR}"/*.md; do
  [[ -f "${f}" ]] || continue
  name="$(basename "${f}" .md)"
  is_non_command "${name}" && continue
  [[ -f "${CANONICAL_DIR}/${name}.md" ]] || fail "orphan claude adapter (canonical 없음): .claude/commands/${name}.md"
done

echo "== session-start prompt 3종 존재 =="
for p in ${PROMPT_SET}; do
  [[ -f "${PROMPTS_DIR}/${p}.md" ]] || fail "prompt 누락: prompts/${p}.md"
done
shopt -u nullglob

echo ""
if [[ "${RC}" -eq 0 ]]; then
  echo "OVERALL: PASS (mirror/prompt parity 정합)"
else
  echo "OVERALL: FAIL"
fi
exit "${RC}"
