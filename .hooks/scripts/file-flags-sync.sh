#!/usr/bin/env bash
HERE="$(cd "$(dirname "$0")" && pwd)"
exec bash "$HERE/file-attrs-sync.sh" "$@"
