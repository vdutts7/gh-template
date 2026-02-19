#!/usr/bin/env bash
# One-time setup after clone. Zero deps.
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

git config --local include.path ../.gitconfig
chmod +x .hooks/* .hooks/scripts/*.sh 2>/dev/null

echo "hooks activated:"
for h in .hooks/pre-*  .hooks/post-*; do
    [[ -f "$h" ]] && echo "  $(basename "$h")"
done
