#!/usr/bin/env bash
# Pre-commit: replace U+2014 em dashes with hyphen in staged text files; re-stage; never block.

set -eo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT" || exit 1

git rev-parse --verify HEAD >/dev/null 2>&1 || exit 0

should_skip_path() {
  case "$1" in
    node_modules/* | .git/* | */fix-em-dashes*.sh | .hooks/em-dash-whitelist.txt) return 0 ;;
  esac
  return 1
}

count_em_dashes_stdin() {
  LC_ALL=C python3 -c "import sys; print(sys.stdin.buffer.read().decode('utf-8', errors='replace').count('\u2014'))"
}

replace_em_dashes() {
  local file="$1"
  python3 -c '
import pathlib, sys
p = pathlib.Path(sys.argv[1])
try:
    text = p.read_text(encoding="utf-8")
except (OSError, UnicodeDecodeError):
    sys.exit(1)
fixed = text.replace("\u2014", "-")
if fixed == text:
    sys.exit(1)
p.write_text(fixed, encoding="utf-8")
' "$file"
}

is_binary_in_cached_diff() {
  local path="$1"
  local line
  line=$(git diff --cached --numstat -- "$path" 2>/dev/null | head -n 1)
  [[ "$line" == $'-\t-\t'* ]]
}

fixed_any=false

while IFS= read -r -d '' path; do
  [[ -z "$path" ]] && continue
  should_skip_path "$path" && continue
  [[ "$(git cat-file -t ":$path" 2>/dev/null)" == blob ]] || continue
  is_binary_in_cached_diff "$path" && continue
  [[ -f "$path" ]] || continue

  em_count=$(git show ":$path" 2>/dev/null | count_em_dashes_stdin)
  [[ "${em_count:-0}" -eq 0 ]] && continue

  if replace_em_dashes "$path"; then
    git add -- "$path" 2>/dev/null || true
    fixed_any=true
    echo "[pre-commit] check-em-dashes: $path ($em_count em dash(es) -> hyphen)"
  fi
done < <(git diff --cached -z --name-only --diff-filter=ACM 2>/dev/null || true)

if $fixed_any; then
  echo "[pre-commit] em dashes replaced with hyphens"
fi

exit 0
