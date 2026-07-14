#!/usr/bin/env bash
# check-env-permission-contract.sh — Claude env Read deny fixture matrix.
#
# Usage: check-env-permission-contract.sh <.claude/settings.json>
# Exit: 0 = contract PASS, 1 = contract FAIL, 2 = usage/environment error
set -euo pipefail

SETTINGS="${1:-}"
if [[ -z "${SETTINGS}" || $# -ne 1 ]]; then
  echo "usage: check-env-permission-contract.sh <.claude/settings.json>" >&2
  exit 2
fi
if [[ ! -f "${SETTINGS}" ]]; then
  echo "FAIL: settings file 없음: ${SETTINGS}" >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: permission contract 검사에 python3 필요" >&2
  exit 2
fi

python3 - "${SETTINGS}" <<'PY'
import fnmatch
import json
import sys

settings_path = sys.argv[1]
try:
    with open(settings_path, encoding="utf-8") as handle:
        settings = json.load(handle)
except (OSError, ValueError) as error:
    sys.stderr.write(f"FAIL: settings JSON parse 실패: {error}\n")
    sys.exit(1)

deny = settings.get("permissions", {}).get("deny", [])
if not isinstance(deny, list) or not all(isinstance(item, str) for item in deny):
    sys.stderr.write("FAIL: permissions.deny가 string array가 아님\n")
    sys.exit(1)

required = {
    "Read(./.env)",
    "Read(./.env.local)",
    "Read(./.env.*.local)",
}
missing = sorted(required.difference(deny))
if missing:
    sys.stderr.write(f"FAIL: required env deny 누락: {', '.join(missing)}\n")
    sys.exit(1)
if "Read(./.env.*)" in deny:
    sys.stderr.write("FAIL: broad env wildcard가 .env.example까지 차단함\n")
    sys.exit(1)

read_patterns = [
    entry[len("Read("):-1]
    for entry in deny
    if entry.startswith("Read(") and entry.endswith(")")
]
fixtures = {
    ".env": True,
    ".env.local": True,
    ".env.test.local": True,
    ".env.example": False,
}
for fixture, expected_denied in fixtures.items():
    actual_denied = any(
        fnmatch.fnmatchcase(f"./{fixture}", pattern)
        for pattern in read_patterns
    )
    if actual_denied != expected_denied:
        expected = "deny" if expected_denied else "readable"
        actual = "deny" if actual_denied else "readable"
        sys.stderr.write(
            f"FAIL: fixture {fixture} expected={expected} actual={actual}\n"
        )
        sys.exit(1)

print("PASS: .env/.env.local/.env.*.local deny, .env.example readable")
PY
