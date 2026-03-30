#!/usr/bin/env bash
set -eo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
WHITELIST="$ROOT/.hooks/em-dash-whitelist.txt"
DEFAULT_FIXER="/Users/vdog/.cursor/tools/parsing/fix-em-dashes.sh"
FIXER="${EM_DASH_FIXER:-$DEFAULT_FIXER}"

mkdir -p "$(dirname "$WHITELIST")"
if [[ ! -f "$WHITELIST" ]]; then
  cat > "$WHITELIST" <<'EOF'
# Approved em-dash occurrences.
# Format: <repo-relative-path><TAB><sha256-of-line-content>
EOF
fi

hash_text() {
  printf '%s' "$1" | shasum -a 256 | awk '{print $1}'
}

key_for_match() {
  local file="$1"
  local text="$2"
  printf '%s\t%s' "$file" "$(hash_text "$text")"
}

is_whitelisted() {
  local key="$1"
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    [[ "$line" == "$key" ]] && return 0
  done < "$WHITELIST"
  return 1
}

add_to_whitelist() {
  local key="$1"
  if ! is_whitelisted "$key"; then
    printf '%s\n' "$key" >> "$WHITELIST"
  fi
}

run_autofix() {
  local file="$1"
  local tmp="${file}.emdashfix.$$"

  [[ -x "$FIXER" ]] || return 1
  "$FIXER" "$file" > "$tmp"
  if ! cmp -s "$file" "$tmp"; then
    mv "$tmp" "$file"
    # Keep index in sync if file was staged.
    git add -- "$file" 2>/dev/null || true
  else
    rm -f "$tmp"
  fi
  return 0
}

cd "$ROOT"

matches=()
while IFS= read -r line || [[ -n "$line" ]]; do
  matches+=("$line")
done < <(
  rg -n --no-heading --color=never --hidden \
    -g '!.git/**' \
    -g '!node_modules/**' \
    -g '!.hooks/scripts/**' \
    -g '!.cursor/tools/**' \
    -g '!**/fix-em-dashes*.sh' \
    -g '!.hooks/em-dash-whitelist.txt' \
    "—" . || true
)

if [[ ${#matches[@]} -eq 0 ]]; then
  exit 0
fi

declare -a unapproved=()
declare -a unapproved_keys=()
declare -a unapproved_files=()

for entry in "${matches[@]}"; do
  file="${entry%%:*}"
  rest="${entry#*:}"
  line_no="${rest%%:*}"
  line_text="${rest#*:}"

  # Normalize "./path" from rg output into "path"
  file="${file#./}"
  key="$(key_for_match "$file" "$line_text")"

  if ! is_whitelisted "$key"; then
    unapproved+=("${file}:${line_no}:${line_text}")
    unapproved_keys+=("$key")
    unapproved_files+=("$file")
  fi
done

if [[ ${#unapproved[@]} -eq 0 ]]; then
  exit 0
fi

echo ""
echo "[pre-commit] BLOCKED - found unapproved em dash occurrences (U+2014)"
echo "Rule: use hyphen '-' instead of em dash, per bionic-dev invariant."
echo ""
printf '%s\n' "${unapproved[@]}"
echo ""

if [[ "${EM_DASH_AUTOFIX:-}" == "1" && -x "$FIXER" ]]; then
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    run_autofix "$f" || true
  done < <(printf '%s\n' "${unapproved_files[@]}" | awk '!seen[$0]++')
  exec "$0"
fi

if [[ -t 0 && -x "$FIXER" ]]; then
  read -r -p "Run autofix on affected files now? [y/N]: " autofix_answer
  case "$autofix_answer" in
    y|Y|yes|YES)
      # De-duplicate files with awk (portable and simple).
      while IFS= read -r f; do
        [[ -z "$f" ]] && continue
        run_autofix "$f" || true
      done < <(printf '%s\n' "${unapproved_files[@]}" | awk '!seen[$0]++')

      # Re-run check after fix attempt.
      exec "$0"
      ;;
  esac
fi

if [[ "${EM_DASH_APPROVE:-}" == "1" ]]; then
  for key in "${unapproved_keys[@]}"; do
    add_to_whitelist "$key"
  done
  echo "[pre-commit] approved and whitelisted via EM_DASH_APPROVE=1"
  exit 0
fi

if [[ -t 0 ]]; then
  read -r -p "Approve and whitelist these occurrences? [y/N]: " answer
  case "$answer" in
    y|Y|yes|YES)
      for key in "${unapproved_keys[@]}"; do
        add_to_whitelist "$key"
      done
      echo "[pre-commit] approved and whitelisted"
      exit 0
      ;;
  esac
fi

echo "Fix these lines, or re-run with EM_DASH_APPROVE=1 to whitelist in bulk."
exit 1
