#!/usr/bin/env bash
# scaffold-sandbox.sh — manual onboarding 테스트용 scaffold sandbox 생성/리셋 도구.
#
# 이것은 deterministic check가 아니다 (run-harness-checks.sh에 편입하지 않는다).
# 사람이 scaffold 옵션 조합별로 sandbox를 만들어 /session-start 온보딩을 직접 돌려보고,
# 빠르게 초기 상태로 되돌리며 반복 테스트하기 위한 maintainer 전용 도구다.
# `check-onboarding-flows.sh`(자동 assertion)의 human-in-loop 대응물.
# source repo 전용 — scaffold 적용 repo에는 배포되지 않는다.
#
# 사용법:
#   scripts/tests/scaffold-sandbox.sh new   <name> [--profile generic|spring-boot] \
#                                             [--workflow generic|source-gitflow] [--with-optional] [--git]
#   scripts/tests/scaffold-sandbox.sh reset <name>   # --git으로 만든 sandbox만 (pristine 태그 복원)
#   scripts/tests/scaffold-sandbox.sh rm    <name>
#   scripts/tests/scaffold-sandbox.sh list
#
# 산출물 위치: ${SANDBOX_ROOT:-<repo>/temp/scaffold-sandbox}/<name>   (temp/ = .gitignore 대상)
#
# 예시:
#   # §1~§5 두께 반복 테스트 (빠른 reset)
#   scripts/tests/scaffold-sandbox.sh new rfx --git
#   #  → cd temp/scaffold-sandbox/rfx && claude → /session-start
#   scripts/tests/scaffold-sandbox.sh reset rfx     # 1초 복원, 다시 테스트
#
#   # §0 git-init 흐름 테스트 (no-git)
#   scripts/tests/scaffold-sandbox.sh new rfx
#   scripts/tests/scaffold-sandbox.sh new sb --profile spring-boot --workflow source-gitflow
#
#   scripts/tests/scaffold-sandbox.sh list     # 목록
#   scripts/tests/scaffold-sandbox.sh rm rfx   # 정리
#
#   옵션 조합별로 sandbox를 이름 붙여 만들 수 있어, generic/spring-boot/source-gitflow/with-optional을 각각 띄워두고 비교 테스트할 수 있습니다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_REPO="$(cd "$SCRIPT_DIR/../.." && pwd)"
SANDBOX_ROOT="${SANDBOX_ROOT:-$HARNESS_REPO/temp/scaffold-sandbox}"
CREATE="$HARNESS_REPO/scripts/create-harness.sh"
PRISTINE_TAG="pristine-scaffold"

die() { echo "오류: $*" >&2; exit 1; }

valid_name() {
  [[ "$1" =~ ^[A-Za-z0-9._-]+$ ]] || die "name은 [A-Za-z0-9._-]만 허용한다 ($1)"
}

target_of() { printf '%s/%s' "$SANDBOX_ROOT" "$1"; }

cmd_new() {
  local name="${1:-}"
  [[ -n "$name" ]] || die "name이 필요하다"
  valid_name "$name"
  shift
  local do_git=false
  local -a opts=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --git) do_git=true ;;
      --profile|--workflow) opts+=("$1" "${2:?$1 값이 필요하다}"); shift ;;
      --profile=*|--workflow=*|--with-optional) opts+=("$1") ;;
      *) die "알 수 없는 옵션: $1" ;;
    esac
    shift
  done

  local target; target="$(target_of "$name")"
  mkdir -p "$SANDBOX_ROOT"
  if [[ -e "$target" ]]; then
    echo "기존 sandbox 삭제: $target"
    rm -rf "$target"
  fi
  echo "생성: create-harness.sh ${opts[*]:-} $name -> $target"
  bash "$CREATE" ${opts[@]+"${opts[@]}"} "$name" "$target" >/dev/null
  if $do_git; then
    git -C "$target" init -b main -q
    git -C "$target" add -A
    git -C "$target" commit -q -m "scaffold pristine"
    git -C "$target" tag -f "$PRISTINE_TAG" >/dev/null
    echo "→ git init + '$PRISTINE_TAG' 태그 고정. 'reset $name'으로 즉시 복원 가능."
  else
    echo "→ no-git 상태. §0 git-init 흐름까지 테스트 가능."
  fi
  echo "테스트: cd $target && claude   ->   /session-start"
}

cmd_reset() {
  local name="${1:-}"; [[ -n "$name" ]] || die "name이 필요하다"; valid_name "$name"
  local target; target="$(target_of "$name")"
  [[ -d "$target" ]] || die "sandbox가 없다: $target"
  [[ -d "$target/.git" ]] || die "$name은 git sandbox가 아니다. 'new $name --git'으로 다시 만든다."
  git -C "$target" rev-parse "$PRISTINE_TAG" >/dev/null 2>&1 \
    || die "'$PRISTINE_TAG' 태그가 없다. 'new $name --git'이 필요하다."
  git -C "$target" reset --hard "$PRISTINE_TAG" -q
  git -C "$target" clean -fdq
  echo "복원: $name -> $PRISTINE_TAG (온보딩 변경 전부 폐기)"
}

cmd_rm() {
  local name="${1:-}"; [[ -n "$name" ]] || die "name이 필요하다"; valid_name "$name"
  local target; target="$(target_of "$name")"
  [[ -e "$target" ]] || { echo "없음(이미 삭제됨): $target"; return 0; }
  rm -rf "$target"
  echo "삭제: $target"
}

cmd_list() {
  [[ -d "$SANDBOX_ROOT" ]] || { echo "(sandbox 루트 없음: $SANDBOX_ROOT)"; return 0; }
  local found=false d n g
  for d in "$SANDBOX_ROOT"/*/; do
    [[ -d "$d" ]] || continue
    found=true
    n="$(basename "$d")"
    g="no-git"; [[ -d "$d/.git" ]] && g="git"
    printf '  %-24s [%s]\n' "$n" "$g"
  done
  $found || echo "(빈 sandbox: $SANDBOX_ROOT)"
}

case "${1:-}" in
  new)   shift; cmd_new "$@" ;;
  reset) shift; cmd_reset "$@" ;;
  rm)    shift; cmd_rm "$@" ;;
  list)  shift; cmd_list "$@" ;;
  *)
    cat >&2 <<'EOF'
사용법: scripts/tests/scaffold-sandbox.sh {new|reset|rm|list}
  new  <name> [--profile generic|spring-boot] [--workflow generic|source-gitflow] [--with-optional] [--git]
       옵션대로 scaffold 생성. --git이면 init+pristine 태그(reset 가능), 아니면 no-git(§0 흐름 테스트).
  reset <name>   pristine 태그로 hard reset (git sandbox만)
  rm    <name>   sandbox 삭제
  list           sandbox 목록
EOF
    exit 1
    ;;
esac
