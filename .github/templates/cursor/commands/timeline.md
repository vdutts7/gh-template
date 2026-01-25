---
id: timeline
version: 3.0
created: 2025-11-26
updated: 2026-01-23
category: data-operations
layer: 1
type: tool/basic

chains_with:
  - style-track: "track style milestones over time"
  - amzn_slack_people_ellehong: "ellen_cya field generation"
depends_on:
  - grep: "timestamp extraction"
  - jq: "json manipulation"
  - find: "locate timeline files"
used_by:
  - style-track: "log significant style improvements"

operation: APPEND-ONLY
---

# timeline

```yaml
mode: APPEND-ONLY
target: "{workspace}/*.timeline.json"
centralized: false

workspace_detection:
  priority:
    1: "active_file_path from {recent_context}"
    2: "last_edited_file directory"
    3: "cwd if contains .git or package.json or Cargo.toml"
    4: "explicit user override"
  
  oncall_detection:
    trigger: "pwd contains 'oncall' OR $ONCALL env var set"
    behavior: |
      if in $ONCALL repo or subdir:
        1. find nearest *.timeline.json (search up from cwd)
        2. MUST include ellen_cya and slack_update fields
        3. auto-detect schema from last 10 entries
    env_var: "$ONCALL"
    typical_path: "~/Desktop/oncall"
    subdir_pattern: "_0_/{sprint_folder}/"
  
  resolution:
    - extract: "workspace root from {recent_context}"
    - check: "is user in subdir? (e.g., ~/Desktop/oncall/_0_)"
    - check_oncall: "is path under $ONCALL? if yes, use oncall_detection"
    - resolve: "use deepest dir with project markers OR active working dir"
    - validate: "dir exists and is writable"

  project_markers:
    - ".git"
    - "package.json"
    - "Cargo.toml"
    - "pyproject.toml"
    - "go.mod"
    - "*.timeline.json"

timeline_file:
  pattern: "{project_name}.timeline.json"
  location: "{resolved_workspace}/"
  create_if_missing: true
  
  schema:
    entries: "array"
    entry:
      ts: "ISO8601"
      type: "string"
      content: "string"
      context: "object (optional)"
      ellen_cya: "string (REQUIRED if oncall repo)"
      slack_update: "string (REQUIRED if oncall repo)"

  schema_inference:
    description: "auto-detect schema from last 10 entries before appending"
    steps:
      1: "read last 10 entries from timeline"
      2: "extract all unique field names"
      3: "identify required vs optional fields"
      4: "new entry MUST include all fields present in majority (>50%) of last 10"
    purpose: "maintain schema consistency without hardcoding"

oncall_fields:
  description: "REQUIRED fields when in $ONCALL repo"
  ellen_cya:
    description: "terse external-facing status optimized for Ellen optics"
    format: "1-2 sentences, proactive, accountability-forward"
    when_no_change: "ref:ts_{previous_entry_timestamp}"
    source: "/amzn/slack/people/ellehong"
  slack_update:
    description: "ready-to-paste slack DM update for Ellen"
    format: |
      {terse status update}
      
      **refs**
      - {full URL 1}
      - {full URL 2}
    link_style: "per /amzn/style/comment-style - all refs at bottom"

append_operation:
  steps:
    1: "detect workspace from {recent_context}"
    2: "check if oncall repo (pwd contains 'oncall' or under $ONCALL)"
    3: "find *.timeline.json in resolved workspace"
    4: "if not found, create {dirname}.timeline.json"
    5: "read last 10 entries to infer schema"
    6: "validate new entry has all required fields (including ellen_cya if oncall)"
    7: "append new entry with timestamp"
    8: "write back (atomic)"
  
  entry_template:
    ts: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    type: "{entry_type}"
    content: "{entry_content}"
    context:
      workspace: "{resolved_workspace}"
      file: "{active_file}"
    ellen_cya: "{ellen_cya_text}"  # if oncall
    slack_update: "{slack_update_text}"  # if oncall
```

## workspace resolution

```bash
# from {recent_context}, extract:
# - cursor_workspace: top-level dir open in IDE
# - active_subdir: actual working directory (may differ)
# - active_file: currently edited file path

resolve_workspace() {
  local ctx_workspace="$1"   # from recent_context
  local ctx_subdir="$2"      # from recent_context  
  local ctx_file="$3"        # from recent_context
  
  # Priority: subdir > file's dir > workspace
  if [[ -n "$ctx_subdir" && -d "$ctx_subdir" ]]; then
    echo "$ctx_subdir"
  elif [[ -n "$ctx_file" ]]; then
    dirname "$ctx_file"
  else
    echo "$ctx_workspace"
  fi
}

is_oncall_repo() {
  local path="$1"
  # Check if path contains 'oncall' or is under $ONCALL
  if [[ "$path" == *"oncall"* ]] || [[ -n "$ONCALL" && "$path" == "$ONCALL"* ]]; then
    return 0
  fi
  return 1
}

find_nearest_timeline() {
  local dir="$1"
  while [[ "$dir" != "/" ]]; do
    local timeline=$(find "$dir" -maxdepth 1 -name "*.timeline.json" 2>/dev/null | head -1)
    if [[ -n "$timeline" ]]; then
      echo "$timeline"
      return 0
    fi
    dir=$(dirname "$dir")
  done
  return 1
}

infer_schema_from_entries() {
  local timeline_file="$1"
  # Get last 10 entries and extract field names
  jq -r '.entries[-10:] | map(keys) | add | unique | .[]' "$timeline_file" 2>/dev/null
}
```

## append entry

```bash
append_timeline_entry() {
  local workspace="$1"
  local entry_type="$2"
  local content="$3"
  local ellen_cya="$4"      # optional, required if oncall
  local slack_update="$5"   # optional, required if oncall
  
  # Check if oncall repo
  local is_oncall=false
  if is_oncall_repo "$workspace"; then
    is_oncall=true
  fi
  
  # Find or create timeline file
  local timeline_file
  if $is_oncall; then
    timeline_file=$(find_nearest_timeline "$workspace")
  fi
  
  if [[ -z "$timeline_file" ]]; then
    timeline_file=$(find "$workspace" -maxdepth 1 -name "*.timeline.json" | head -1)
  fi
  
  if [[ -z "$timeline_file" ]]; then
    local project_name=$(basename "$workspace")
    timeline_file="${workspace}/${project_name}.timeline.json"
    echo '{"entries":[]}' > "$timeline_file"
  fi
  
  # Infer schema from last 10 entries
  local schema_fields=$(infer_schema_from_entries "$timeline_file")
  
  # Validate oncall fields
  if $is_oncall && [[ -z "$ellen_cya" ]]; then
    echo "ERROR: ellen_cya field required in oncall repo" >&2
    return 1
  fi
  
  # Append entry (atomic)
  local ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  local tmp=$(mktemp)
  
  if $is_oncall; then
    jq --arg ts "$ts" \
       --arg type "$entry_type" \
       --arg content "$content" \
       --arg ws "$workspace" \
       --arg ellen "$ellen_cya" \
       --arg slack "$slack_update" \
       '.entries += [{"ts":$ts,"type":$type,"content":$content,"context":{"workspace":$ws},"ellen_cya":$ellen,"slack_update":$slack}]' \
       "$timeline_file" > "$tmp" && mv "$tmp" "$timeline_file"
  else
    jq --arg ts "$ts" \
       --arg type "$entry_type" \
       --arg content "$content" \
       --arg ws "$workspace" \
       '.entries += [{"ts":$ts,"type":$type,"content":$content,"context":{"workspace":$ws}}]' \
       "$timeline_file" > "$tmp" && mv "$tmp" "$timeline_file"
  fi
}
```

## usage

```yaml
invoke:
  implicit: "agent detects from {recent_context}"
  explicit: "/timeline add <type> <content>"

examples:
  - "/timeline add milestone 'completed auth refactor'"
  - "/timeline add note 'investigating memory leak'"
  - "/timeline add decision 'chose postgres over sqlite'"
  
  # oncall repo examples (ellen_cya auto-generated)
  - "/timeline add blocker 'blocked on MPA approval'"
  - "/timeline add investigation 'verified alarms in cloudwatch'"

entry_types:
  - milestone
  - note  
  - decision
  - blocker
  - resolution
  - investigation
  - standup
  - artifacts
```

## constraints

```yaml
strict:
  - "APPEND-ONLY: never modify/delete existing entries"
  - "NO centralized file: each project has own timeline"
  - "workspace detection MUST use {recent_context}"
  - "subdir takes precedence over parent workspace"
  - "oncall repo MUST include ellen_cya and slack_update fields"
  - "schema inference from last 10 entries before append"
```
