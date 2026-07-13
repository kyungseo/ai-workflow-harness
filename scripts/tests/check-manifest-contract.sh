#!/usr/bin/env bash
# check-manifest-contract.sh — `--check` manifest 계약 behavior matrix
# (CHORE-20260713-003 R0-F6: static fixture 수가 아니라 table-driven coverage)
#
# 검증 축:
#   parse    — canonical single-line / pretty-print+key-reorder / legacy 동일 판정
#   invalid  — malformed JSON, framework_files 누락/wrong-type/빈 목록,
#              unknown hash_mode → exit 2 (fail closed)
#   fail-closed — python3 부재(HARNESS_CHECK_FORCE_NO_PYTHON=1 test hook) → exit 2
#   provenance — source state 4분류: legacy info / expected upgrade delta /
#              same-version skew WARN / recorded-dirty WARN
#
# fixture는 repo-local temp/harness-tests/ 아래에만 생성·정리한다(검증 spine temp 정책).
# adopter-safe: create-harness.sh 또는 python3 부재 시 SKIP(N/A), 실패로 치지 않는다.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CREATE_SH="${REPO_ROOT}/scripts/create-harness.sh"

if [[ ! -f "${CREATE_SH}" ]]; then
  echo "SKIP (N/A): scripts/create-harness.sh 없음 — manifest contract matrix 비대상"
  exit 0
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "SKIP (N/A): python3 없음 — --check는 fail closed로 동작하나 matrix 자체를 돌릴 수 없음"
  exit 0
fi

sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | awk '{print $1}'
  else shasum -a 256 "$1" | awk '{print $1}'; fi
}

RC=0
BASE="${REPO_ROOT}/temp/harness-tests/manifest-contract-$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "${BASE}"
trap 'rm -rf "${BASE}"' EXIT

PROJ="fixture-proj"
SRC_FILE="CLAUDE.md"
HASH="$(sha256_of "${REPO_ROOT}/${SRC_FILE}")"
VERSION="$(tr -d ' \t\n\r' < "${REPO_ROOT}/VERSION" 2>/dev/null || printf '0.0.0-dev')"
CUR_COMMIT="$(git -C "${REPO_ROOT}" rev-parse HEAD 2>/dev/null || printf 'unknown')"
ZEROS="0000000000000000000000000000000000000000"
ENTRY="{\"path\": \"${SRC_FILE}\", \"src\": \"${SRC_FILE}\", \"sha256\": \"${HASH}\"}"

# fixture target 생성: manifest 내용 + rendered 파일 1개(in-sync 기대)
make_target() {
  local name="$1" manifest_body="$2"
  local dir="${BASE}/${name}"
  mkdir -p "${dir}/.harness"
  printf '%s\n' "${manifest_body}" > "${dir}/.harness/manifest.json"
  sed "s/ai-workflow-harness/${PROJ}/g" "${REPO_ROOT}/${SRC_FILE}" > "${dir}/${SRC_FILE}"
}

# run_case <name> <expected-exit> <must-pattern|-> <absent-pattern|-> [env KEY=V]
run_case() {
  local name="$1" want="$2" must="$3" absent="$4" envkv="${5:-}"
  local out code
  if [[ -n "${envkv}" ]]; then
    out="$(env "${envkv}" "${CREATE_SH}" --check "${BASE}/${name}" 2>&1)"; code=$?
  else
    out="$("${CREATE_SH}" --check "${BASE}/${name}" 2>&1)"; code=$?
  fi
  local ok=1
  [[ "${code}" -eq "${want}" ]] || { echo "  FAIL [${name}]: exit ${code} (기대 ${want})"; ok=0; }
  if [[ "${must}" != "-" ]] && ! printf '%s' "${out}" | grep -qF "${must}"; then
    echo "  FAIL [${name}]: 기대 출력 없음: ${must}"; ok=0
  fi
  if [[ "${absent}" != "-" ]] && printf '%s' "${out}" | grep -qF "${absent}"; then
    echo "  FAIL [${name}]: 금지 출력 발견: ${absent}"; ok=0
  fi
  if [[ "${ok}" -eq 1 ]]; then echo "  OK   [${name}]"; else RC=1; fi
}

canonical_body() {
  # $1 = harness_version, $2 = source_commit, $3 = source_dirty
  printf '{"manifest_version": 1, "harness_version": "%s", "source_identity": "ai-workflow-harness", "generated_at": "2026-07-13", "profile": "generic", "workflow_mode": "generic", "with_optional": false, "project_name": "%s", "source_ref": "fixture-tag", "source_commit": "%s", "source_dirty": %s, "hash_algorithm": "sha256", "hash_mode": "source_template_raw", "framework_files": [%s]}' \
    "$1" "${PROJ}" "$2" "$3" "${ENTRY}"
}

echo "== manifest contract behavior matrix =="

# ── parse 축 ──────────────────────────────────────────────────────────────────
make_target canonical "$(canonical_body "${VERSION}" "${CUR_COMMIT}" false)"
run_case canonical 0 "1 tracked, 1 in-sync" "version-skew"

make_target pretty "$(canonical_body "${VERSION}" "${CUR_COMMIT}" false | python3 -c 'import json,sys; d=json.load(sys.stdin); print(json.dumps(dict(sorted(d.items())), indent=2, ensure_ascii=False))')"
run_case pretty 0 "1 tracked, 1 in-sync" "version-skew"

make_target compact "$(canonical_body "${VERSION}" "${CUR_COMMIT}" false | python3 -c 'import json,sys; print(json.dumps(json.load(sys.stdin), separators=(",", ":")))')"
run_case compact 0 "1 tracked, 1 in-sync" "version-skew"

make_target legacy "{\"manifest_version\": 1, \"harness_version\": \"${VERSION}\", \"generated_at\": \"2026-06-01\", \"project_name\": \"${PROJ}\", \"workflow_mode\": \"generic\", \"hash_algorithm\": \"sha256\", \"hash_mode\": \"normalized_source_template\", \"framework_files\": [${ENTRY}]}"
run_case legacy 0 "unknown (legacy" "version-skew"

# ── invalid 축 (전부 exit 2, drift 판정 없음) ─────────────────────────────────
mkdir -p "${BASE}/malformed/.harness"; printf '{ not json' > "${BASE}/malformed/.harness/manifest.json"
run_case malformed 2 "invalid manifest" "tracked"

make_target missing-files "{\"harness_version\": \"${VERSION}\", \"project_name\": \"${PROJ}\", \"hash_mode\": \"source_template_raw\"}"
run_case missing-files 2 "invalid manifest" "tracked"

make_target wrong-type "{\"harness_version\": \"${VERSION}\", \"project_name\": \"${PROJ}\", \"hash_mode\": \"source_template_raw\", \"framework_files\": \"nope\"}"
run_case wrong-type 2 "invalid manifest" "tracked"

make_target empty-entries "{\"harness_version\": \"${VERSION}\", \"project_name\": \"${PROJ}\", \"hash_mode\": \"source_template_raw\", \"framework_files\": []}"
run_case empty-entries 2 "invalid manifest" "tracked"

make_target bad-hash-mode "$(canonical_body "${VERSION}" "${CUR_COMMIT}" false | sed 's/source_template_raw/sha256_raw/')"
run_case bad-hash-mode 2 "unknown hash_mode" "tracked"

# canonical hash_mode는 provenance 3필드 필수 (R1-F1)
make_target canonical-no-prov "$(canonical_body "${VERSION}" "${CUR_COMMIT}" false | python3 -c 'import json,sys; d=json.load(sys.stdin); [d.pop(k) for k in ("source_ref","source_commit","source_dirty")]; print(json.dumps(d))')"
run_case canonical-no-prov 2 "invalid manifest" "tracked"

make_target wrongtype-dirty "$(canonical_body "${VERSION}" "${CUR_COMMIT}" false | python3 -c 'import json,sys; d=json.load(sys.stdin); d["source_dirty"]="false"; print(json.dumps(d))')"
run_case wrongtype-dirty 2 "invalid manifest" "tracked"

# source_commit 형식: full 40-hex 또는 명시적 unknown만 (R1-F2)
make_target bad-commit "$(canonical_body "${VERSION}" "abc123" false)"
run_case bad-commit 2 "invalid manifest" "tracked"

# TSV/hash 형식 fail closed (R1-F4)
make_target bad-sha "$(canonical_body "${VERSION}" "${CUR_COMMIT}" false | python3 -c 'import json,sys; d=json.load(sys.stdin); d["framework_files"][0]["sha256"]="xyz"; print(json.dumps(d))')"
run_case bad-sha 2 "invalid manifest" "tracked"

make_target ctrl-char "$(canonical_body "${VERSION}" "${CUR_COMMIT}" false | python3 -c 'import json,sys; d=json.load(sys.stdin); d["project_name"]="fixture\tproj"; print(json.dumps(d))')"
run_case ctrl-char 2 "invalid manifest" "tracked"

# ── fail-closed 축 (python3 부재 시뮬레이션) ──────────────────────────────────
run_case canonical 2 "requires python3" "tracked" "HARNESS_CHECK_FORCE_NO_PYTHON=1"

# ── provenance 축 (source state 4분류; legacy info는 위 legacy case가 커버) ────
if [[ "${CUR_COMMIT}" != "unknown" ]]; then
  make_target skew "$(canonical_body "${VERSION}" "${ZEROS}" false)"
  run_case skew 0 "version-skew" "-"

  make_target upgrade-delta "$(canonical_body "0.0.1" "${ZEROS}" false)"
  run_case upgrade-delta 0 "expected upgrade source delta" "version-skew"

  make_target recorded-dirty "$(canonical_body "${VERSION}" "${CUR_COMMIT}" true)"
  run_case recorded-dirty 0 "recorded source was dirty" "version-skew"

  # git metadata 부재 sentinel은 skew 비교에서 제외 (R1-F2 거짓 WARN 방지)
  make_target git-unknown "$(canonical_body "${VERSION}" "unknown" false)"
  run_case git-unknown 0 "non-reproducible" "version-skew"
else
  echo "  SKIP (N/A): source가 git checkout이 아님 — provenance 비교 3 case 생략"
fi

# ── invariant delegation regression (R1b-F1) ─────────────────────────────────
# invariant [5]가 invalid manifest에서 --check 위임을 우회하거나(과거 '"path"'
# guard) set -e로 중간 종료하지 않고, 항상 명시적 FAIL로 수렴하는지 고정한다.
# 실제 scaffold를 하나 생성해 manifest를 corrupt한 뒤 invariants 전체를 돌린다.
INVARIANTS="${SCRIPT_DIR}/check-scaffold-invariants.sh"
if [[ -f "${INVARIANTS}" ]]; then
  DELEG="${BASE}/deleg-target"
  if "${CREATE_SH}" deleg-fixture "${DELEG}" >/dev/null 2>&1; then
    python3 - "${DELEG}/.harness/manifest.json" <<'PY'
import json, sys
p = sys.argv[1]
d = json.load(open(p, encoding="utf-8"))
d["framework_files"] = []
open(p, "w", encoding="utf-8").write(json.dumps(d, ensure_ascii=False))
PY
    inv_out="$(bash "${INVARIANTS}" "${DELEG}" 2>&1)"; inv_rc=$?
    deleg_ok=1
    [[ "${inv_rc}" -ne 0 ]] || { echo "  FAIL [inv-delegation]: invalid manifest인데 invariants exit 0"; deleg_ok=0; }
    printf '%s' "${inv_out}" | grep -qF -- "--check 실패" || { echo "  FAIL [inv-delegation]: --check 위임 FAIL 메시지 없음"; deleg_ok=0; }
    printf '%s' "${inv_out}" | grep -q "RESULT:" || { echo "  FAIL [inv-delegation]: 중간 종료 의심 (RESULT 줄 없음)"; deleg_ok=0; }
    if [[ "${deleg_ok}" -eq 1 ]]; then echo "  OK   [inv-delegation]"; else RC=1; fi
  else
    echo "  FAIL [inv-delegation]: fixture scaffold 생성 실패"; RC=1
  fi
else
  echo "  SKIP (N/A): check-scaffold-invariants.sh 없음 — delegation regression 생략"
fi

echo ""
if [[ "${RC}" -eq 0 ]]; then echo "manifest contract matrix: PASS"; else echo "manifest contract matrix: FAIL"; fi
exit "${RC}"
