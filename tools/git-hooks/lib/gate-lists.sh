#!/usr/bin/env sh
# Shared gate lists for ai-workflow-harness git hooks.

AWH_GATE_OVERRIDE_TRAILER="AWH-Gate-Override"
AWH_GATE_OVERRIDE_TOKEN="finalization-split"
AWH_GATE_REASON_TRAILER="AWH-Gate-Reason"

# Project-owned (Class B) gate config. Lets a target repo ADD its own protected /
# finalization paths without editing this framework-owned file, which is recorded
# in .harness/manifest.json and overwritten on a harness upgrade. The config is read
# as plain data — never sourced or eval'd — so a committed config cannot execute
# code at commit time. Override the path with AWH_GATE_CONFIG for tests.
AWH_GATE_CONFIG="${AWH_GATE_CONFIG:-.harness/gate-config}"

# awh_project_glob_match <path> <section>
# Returns 0 if <path> matches any glob listed under [<section>] of the project gate
# config. Patterns are shell case-globs (one per line; * also matches '/'). Only
# whole-line comments (#...) and blank lines are ignored — there is NO inline-comment
# stripping, so a trailing '# ...' becomes part of the pattern and will not match.
# Other sections are ignored. add-only: this never removes a framework default —
# callers check defaults first, then fall through here.
awh_project_glob_match() {
    _awh_path="$1"
    _awh_want="$2"
    _awh_root="${ROOT:-}"
    if [ -z "$_awh_root" ]; then
        _awh_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
    fi
    [ -n "$_awh_root" ] || return 1
    _awh_cfg="${_awh_root}/${AWH_GATE_CONFIG}"
    [ -r "$_awh_cfg" ] || return 1
    _awh_sec=""
    while IFS= read -r _awh_line || [ -n "$_awh_line" ]; do
        # trim leading/trailing whitespace (also strips a trailing CR on CRLF files)
        _awh_line="${_awh_line#"${_awh_line%%[![:space:]]*}"}"
        _awh_line="${_awh_line%"${_awh_line##*[![:space:]]}"}"
        case "$_awh_line" in
            ''|\#*) continue ;;
            '['*']')
                # quote the bracket chars: unquoted '[' is a glob bracket-expression
                # opener and dash leaves it unstripped (`[protected` != `protected`).
                _awh_sec="${_awh_line#"["}"
                _awh_sec="${_awh_sec%"]"}"
                continue
                ;;
        esac
        [ "$_awh_sec" = "$_awh_want" ] || continue
        case "$_awh_path" in
            $_awh_line) return 0 ;;
        esac
    done < "$_awh_cfg"
    return 1
}

awh_is_finalization_file() {
    case "$1" in
        docs/STATUS.md|docs/backlog/*|docs/works/*|docs/decisions/README.md)
            return 0
            ;;
    esac
    awh_project_glob_match "$1" finalization
}

awh_is_branch_isolation_protected_path() {
    case "$1" in
        AGENTS.md|CLAUDE.md|docs/STATUS.md|\
        docs/backlog/*|docs/works/*|docs/decisions/*|\
        docs/AGENT-WORKFLOW.md|docs/HARNESS-PROTOCOL.md|\
        docs/HARNESS-QUICK-REFERENCE.md|docs/GIT-WORKFLOW.md|\
        .claude/commands/*|.claude/rules/*|.cursor/rules/*|\
        .agents/skills/*|prompts/*|scripts/create-harness.sh|\
        tools/git-hooks/*|.harness/gate-config)
            return 0
            ;;
    esac
    awh_project_glob_match "$1" protected
}
