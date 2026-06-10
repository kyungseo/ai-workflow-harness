#!/usr/bin/env bash
# check-shipped-dr-closure.sh — Shipped DR reference closure (policy: DR-033)
#
# scaffold가 ship하는 표면 문서가 scaffold seed 밖 DR을 인용하면 target에서
# dangling reference가 된다. 이 검사는 scaffold 생성 없이 source만으로 그 위반을
# 사전에 잡는다(작성/작업 중 proactive 검출).
#
# 규칙:
#   - seed SSoT = scripts/create-harness.sh 기본 adapt 블록 (제3 사본 금지)
#   - shipped doc = adapt()로 content-preserving 복사되는 표면
#     (regenerate되는 STATUS/PLAN/backlog/decisions/README는 제외)
#   - `Linked DRs:` frontmatter 라인은 제외 (source lineage 메타데이터 — DR-033 mode-b)
#   - shipped DR seed 파일이 자기 자신을 인용하는 것은 위반 아님
#
# 사용: bash scripts/tests/check-shipped-dr-closure.sh
# exit 0 = closed (위반 없음), exit 1 = 위반 발견

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT}"

HARNESS_SH="scripts/create-harness.sh"
if [[ ! -f "${HARNESS_SH}" ]]; then
  echo "SKIP: ${HARNESS_SH} 없음 (scaffold 적용 repository — N/A)"
  exit 0
fi

TMPD="$(mktemp -d)"
trap 'rm -rf "${TMPD}"' EXIT
SEEDFILE="${TMPD}/seed"
DOCFILE="${TMPD}/docs"

# ── seed 목록: create-harness.sh 기본 adapt 블록에서 파생 ───────────────────────
# 기본 블록은 비들여쓰기 `^adapt`, optional 블록(--with-optional)은 2-space 들여쓰기.
grep -E '^adapt .*docs/decisions/DR-[0-9]{3}' "${HARNESS_SH}" \
  | grep -oE 'DR-[0-9]{3}' | sort -u > "${SEEDFILE}"
if [[ ! -s "${SEEDFILE}" ]]; then
  echo "FAIL: seed DR 목록을 ${HARNESS_SH}에서 파생하지 못함"
  exit 1
fi

is_seed() {
  grep -qx "$1" "${SEEDFILE}"
}

# ── shipped doc set: adapt()로 content-preserving 복사되는 표면 ──────────────────
shipped_docs() {
  local f dr
  for f in \
    CLAUDE.md AGENTS.md \
    docs/BEHAVIOR-PRINCIPLES.md docs/AGENT-WORKFLOW.md \
    docs/HARNESS-PROTOCOL.md docs/HARNESS-NAMING-RULES.md \
    docs/HARNESS-RECOVERY-VALIDATION.md docs/HARNESS-PARALLEL-WORK-CONTROLS.md \
    docs/HARNESS-QUICK-REFERENCE.md; do
    [[ -f "${f}" ]] && echo "${f}"
  done
  # shipped DR seed 파일 본문 (regenerate되는 decisions/README는 제외)
  while IFS= read -r dr; do
    ls docs/decisions/"${dr}"-*.md 2>/dev/null
  done < "${SEEDFILE}"
  # adapter / rule / prompt 표면
  find .claude/rules .claude/commands .agents/skills .cursor/rules \
       -type f \( -name '*.md' -o -name '*.mdc' \) 2>/dev/null
  find skills/workflow -type f -name '*.md' 2>/dev/null
  find prompts -type f -name '*session-start.md' 2>/dev/null
}

shipped_docs > "${DOCFILE}"

FAIL=0
echo "== Shipped DR reference closure =="
echo "  seed: $(tr '\n' ' ' < "${SEEDFILE}")"
echo ""

while IFS= read -r file; do
  [[ -z "${file}" ]] && continue
  # 파일 자신의 DR 번호 (seed 파일 self-reference 허용)
  self="$(basename "${file}" | grep -oE 'DR-[0-9]{3}' || true)"
  # `Linked DRs:` 라인 제외 후 DR 토큰 추출
  for dr in $(grep -vE '^Linked DRs:' "${file}" | grep -oE 'DR-[0-9]{3}' | sort -u); do
    [[ -n "${self}" && "${dr}" == "${self}" ]] && continue
    if ! is_seed "${dr}"; then
      echo "  VIOLATION: ${file} -> ${dr} (seed 밖 — self-describe 또는 Linked DRs로 이동)"
      FAIL=1
    fi
  done
done < "${DOCFILE}"

echo ""
if [[ "${FAIL}" -eq 0 ]]; then
  echo "  OK: shipped 표면의 DR 참조가 모두 seed에 닫힘"
else
  echo "RESULT: FAIL — 위 위반을 mode-a(self-describe) 또는 mode-b(Linked DRs)로 처리하세요."
fi
exit "${FAIL}"
