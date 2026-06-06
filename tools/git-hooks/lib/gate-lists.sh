#!/usr/bin/env sh
# Shared gate lists for ai-workflow-harness git hooks.

AWH_GATE_OVERRIDE_TRAILER="AWH-Gate-Override"
AWH_GATE_OVERRIDE_TOKEN="finalization-split"
AWH_GATE_REASON_TRAILER="AWH-Gate-Reason"

awh_is_finalization_file() {
    case "$1" in
        docs/STATUS.md|docs/backlog/*|docs/works/*|docs/decisions/README.md)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

awh_is_branch_isolation_protected_path() {
    case "$1" in
        AGENTS.md|CLAUDE.md|docs/STATUS.md|\
        docs/backlog/*|docs/works/*|docs/decisions/*|\
        docs/AGENT-WORKFLOW.md|docs/HARNESS-PROTOCOL.md|\
        docs/HARNESS-QUICK-REFERENCE.md|docs/GIT-WORKFLOW.md|\
        .claude/commands/*|.claude/rules/*|.cursor/rules/*|\
        .agents/skills/*|prompts/*|scripts/create-harness.sh|\
        tools/git-hooks/*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
