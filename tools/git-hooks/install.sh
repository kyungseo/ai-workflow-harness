#!/usr/bin/env sh
# Installs git hooks for ai-workflow-harness.
# Run once after cloning: sh tools/git-hooks/install.sh

ROOT=$(git rev-parse --show-toplevel)
HOOKS_DIR="$ROOT/.git/hooks"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

ln -sf "$SCRIPT_DIR/pre-commit" "$HOOKS_DIR/pre-commit"
ln -sf "$SCRIPT_DIR/commit-msg" "$HOOKS_DIR/commit-msg"
chmod +x "$HOOKS_DIR/pre-commit" "$HOOKS_DIR/commit-msg"

echo "Git hooks installed:"
echo "  pre-commit : diff and scaffold syntax checks"
echo "  commit-msg : Conventional Commits format"
