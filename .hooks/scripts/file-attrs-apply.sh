#!/usr/bin/env bash
# file-attrs-apply — post-checkout/post-merge: inventory -> worktree
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
HERE="$(cd "$(dirname "$0")" && pwd)"
LIB="$HERE/apply-file-attrs.sh"
[[ -x "$LIB" ]] || exit 0
exec bash "$LIB" --repo "$ROOT" --apply "$@"
