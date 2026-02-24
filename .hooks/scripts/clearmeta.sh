#!/bin/zsh
# pwd: ~/scripts OR .github/scripts (repo template)
# chmod: chmod +x clearmeta.sh
# purpose: NUCLEAR metadata stripper - nukes ALL privacy-leaking metadata (xattrs, EXIF, embedded media)
# usage: clearmeta <file>           - clear metadata from single file
#        clearmeta -r <directory>   - recursively clear metadata from all files in directory
#        clearmeta -d <directory>   - dry-run (show what would be cleaned)
# notes: com.apple.provenance may persist but it's LOCAL-ONLY and doesn't leak externally

setopt pipefail 2>/dev/null || true
set -eo pipefail

# ─────────────────────────────────────────────────────────────────
# Feature flags
# ─────────────────────────────────────────────────────────────────
FLAG_RECURSIVE=false
FLAG_DRY_RUN=false
FLAG_VERBOSE=false
FLAG_QUIET=false
TARGET=""

# ─────────────────────────────────────────────────────────────────
# Parse flags
# ─────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    -r|--recursive) FLAG_RECURSIVE=true; shift ;;
    -d|--dry-run) FLAG_DRY_RUN=true; shift ;;
    -v|--verbose) FLAG_VERBOSE=true; shift ;;
    -q|--quiet) FLAG_QUIET=true; shift ;;
    -h|--help) 
      /bin/cat << 'EOF'
Usage: clearmeta [options] <file|directory>

NUCLEAR metadata stripper - nukes ALL metadata including SIP-protected provenance.

Strips:
  - macOS xattrs (WhereFroms, quarantine, download date, provenance)
  - EXIF/XMP/IPTC (GPS, author, camera, timestamps via exiftool)
  - Embedded media metadata (ID3 tags, cover art via ffmpeg)
  - SIP-protected provenance (via byte-copy trick)

Options:
  -r, --recursive   Process all files in directory recursively
  -d, --dry-run     Show what would be cleaned (no changes)
  -v, --verbose     Show detailed output
  -q, --quiet       Minimal output (errors only)
  -h, --help        Show this help

Examples:
  clearmeta ~/Downloads/file.pdf        # single file
  clearmeta -r ~/Downloads              # recursive directory
  clearmeta -d -r ~/Downloads           # dry-run recursive
  clearmeta -v file.png                 # verbose single file

EOF
      exit 0
      ;;
    -*) echo "🔴 Unknown option: $1"; exit 1 ;;
    *) TARGET="$1"; shift ;;
  esac
done

# ─────────────────────────────────────────────────────────────────
# Logging helpers
# ─────────────────────────────────────────────────────────────────
log_info() { $FLAG_QUIET || echo "🟢 $1"; return 0; }
log_warn() { $FLAG_QUIET || echo "🟡 $1"; return 0; }
log_error() { echo "🔴 $1"; return 0; }
log_verbose() { $FLAG_VERBOSE && ! $FLAG_QUIET && echo "  [verbose] $1"; return 0; }
log_detail() { $FLAG_QUIET || echo "  $1"; return 0; }

# ─────────────────────────────────────────────────────────────────
# Cleanup handler
# ─────────────────────────────────────────────────────────────────
cleanup() {
  local exit_code=$?
  setopt nullglob
  for f in /tmp/clearmeta_$$_*; do
    [[ -e "$f" ]] && rm -f "$f" 2>/dev/null
  done
  exit $exit_code
}
trap cleanup EXIT INT TERM

# ─────────────────────────────────────────────────────────────────
# Check available tools
# ─────────────────────────────────────────────────────────────────
HAS_EXIFTOOL=false
HAS_FFMPEG=false
command -v exiftool &>/dev/null && HAS_EXIFTOOL=true
command -v ffmpeg &>/dev/null && HAS_FFMPEG=true

# ─────────────────────────────────────────────────────────────────
# Media file extensions that have embedded metadata (ID3, etc)
# ─────────────────────────────────────────────────────────────────
MEDIA_EXTENSIONS="mp3|mp4|m4a|m4v|mov|mkv|avi|flac|wav|ogg|opus|webm|aac|wma|wmv|aiff|ape"

# ─────────────────────────────────────────────────────────────────
# Strip embedded media metadata via ffmpeg
# ─────────────────────────────────────────────────────────────────
strip_media_metadata() {
  local file="$1"
  local quiet="$2"
  local ext="${file##*.}"
  ext="${ext:l}"  # zsh lowercase
  
  # Check if ffmpeg is available
  if ! $HAS_FFMPEG; then
    [[ "$quiet" != "quiet" ]] && log_detail "⚠️  ffmpeg not installed, skipping embedded metadata"
    return 1
  fi
  
  # Check if this is a media file
  if [[ ! "$ext" =~ ^($MEDIA_EXTENSIONS)$ ]]; then
    return 0  # Not a media file, nothing to do
  fi
  
  local tmp_file="/tmp/clearmeta_$$_ffmpeg"
  
  # Strip all metadata and cover art, copy streams without re-encoding
  # -map 0:a = audio only (drops cover art video stream)
  # -map_metadata -1 = strip all metadata
  # -c:a copy = copy audio without re-encoding
  if ffmpeg -i "$file" -map 0:a -map_metadata -1 -c:a copy "$tmp_file" -y -loglevel error 2>/dev/null; then
    if [[ -s "$tmp_file" ]]; then
      # Preserve permissions
      chmod "$(stat -f "%Lp" "$file" 2>/dev/null || echo "644")" "$tmp_file" 2>/dev/null
      if mv "$tmp_file" "$file" 2>/dev/null; then
        [[ "$quiet" != "quiet" ]] && log_detail "✅ Stripped embedded media metadata (ffmpeg)"
        return 0
      fi
    fi
  fi
  
  rm -f "$tmp_file" 2>/dev/null
  [[ "$quiet" != "quiet" ]] && log_detail "ℹ️  Media metadata already clean or no audio stream"
  return 0
}

# ─────────────────────────────────────────────────────────────────
# Strip EXIF/XMP/IPTC metadata via exiftool
# ─────────────────────────────────────────────────────────────────
strip_exif_metadata() {
  local file="$1"
  local quiet="$2"
  
  if ! $HAS_EXIFTOOL; then
    [[ "$quiet" != "quiet" ]] && log_detail "⚠️  exiftool not installed, skipping EXIF/XMP/IPTC"
    return 1
  fi
  
  if exiftool -all= -overwrite_original -q -q "$file" 2>/dev/null; then
    [[ "$quiet" != "quiet" ]] && log_detail "✅ Stripped EXIF/XMP/IPTC metadata (exiftool)"
    return 0
  fi
  
  return 0  # Not an error if file type not supported
}

# ─────────────────────────────────────────────────────────────────
# Clear xattrs (WhereFroms, quarantine, etc)
# ─────────────────────────────────────────────────────────────────
clear_xattrs() {
  local file="$1"
  local quiet="$2"
  
  # Delete specific problematic xattrs first
  xattr -d com.apple.metadata:kMDItemWhereFroms "$file" 2>/dev/null || true
  xattr -d com.apple.metadata:kMDItemDownloadedDate "$file" 2>/dev/null || true
  xattr -d com.apple.quarantine "$file" 2>/dev/null || true
  xattr -d com.apple.macl "$file" 2>/dev/null || true
  xattr -d com.apple.lastuseddate#PS "$file" 2>/dev/null || true
  xattr -d com.apple.FinderInfo "$file" 2>/dev/null || true
  xattr -d com.apple.provenance "$file" 2>/dev/null || true  # works when SIP off; no-op when SIP on
  
  # Clear any remaining (except SIP-protected ones)
  xattr -c "$file" 2>/dev/null || true
  
  [[ "$quiet" != "quiet" ]] && log_detail "✅ Cleared xattrs (WhereFroms, quarantine, etc)"
  return 0
}

# ─────────────────────────────────────────────────────────────────
# NUCLEAR: Clear ALL metadata from a single file
# Uses rsync method to nuke even SIP-protected provenance
# (rsync doesn't preserve xattrs by default)
# ─────────────────────────────────────────────────────────────────
nuke_file() {
  local file="$1"
  local quiet="$2"
  local ext="${file##*.}"
  ext="${ext:l}"  # zsh lowercase
  
  # Skip if not a regular file
  [[ ! -f "$file" ]] && return 0
  
  # Skip .git internals
  [[ "$file" == *"/.git/"* ]] && return 0
  
  log_verbose "Processing: $file"
  
  # LAYER 1: Strip EXIF/XMP/IPTC first (before rsync destroys file structure for some formats)
  strip_exif_metadata "$file" "$quiet" || true
  
  # LAYER 2: For media files, strip embedded metadata (ID3, cover art)
  if [[ "$ext" =~ ^($MEDIA_EXTENSIONS)$ ]]; then
    strip_media_metadata "$file" "$quiet"
    clear_xattrs "$file" "$quiet"
    return 0
  fi
  
  # LAYER 3: Use rsync to nuke ALL xattrs including SIP-protected provenance
  # macOS rsync doesn't copy xattrs by default (no -E flag)
  local tmp_file="/tmp/clearmeta_$$_rsync"
  local perms
  perms=$(stat -f "%Lp" "$file" 2>/dev/null || echo "644")
  
  if rsync -a "$file" "$tmp_file" 2>/dev/null; then
    # Verify copy succeeded
    if [[ -s "$tmp_file" ]]; then
      chmod "$perms" "$tmp_file" 2>/dev/null || true
      if mv "$tmp_file" "$file" 2>/dev/null; then
        [[ "$quiet" != "quiet" ]] && log_detail "✅ NUKED all metadata (rsync --no-xattrs)"
        return 0
      fi
    fi
  fi
  
  rm -f "$tmp_file" 2>/dev/null
  
  # FALLBACK: Try byte-copy method
  tmp_file="/tmp/clearmeta_$$_bytecopy"
  if /bin/cat "$file" > "$tmp_file" 2>/dev/null; then
    chmod "$perms" "$tmp_file" 2>/dev/null || true
    if mv "$tmp_file" "$file" 2>/dev/null; then
      [[ "$quiet" != "quiet" ]] && log_detail "✅ NUKED all metadata (byte-copy)"
      return 0
    fi
  fi
  
  rm -f "$tmp_file" 2>/dev/null
  
  # LAST RESORT: Just clear what we can with xattr
  clear_xattrs "$file" "$quiet"
  [[ "$quiet" != "quiet" ]] && log_detail "⚠️  rsync/byte-copy failed, fell back to xattr"
  return 1
}

# ─────────────────────────────────────────────────────────────────
# Check file for metadata (dry-run mode)
# ─────────────────────────────────────────────────────────────────
check_file_metadata() {
  local file="$1"
  local has_meta=false
  local details=""
  
  # Skip if not a regular file
  [[ ! -f "$file" ]] && return 0
  
  # Skip .git internals
  [[ "$file" == *"/.git/"* ]] && return 0
  
  # Check xattrs (exclude com.apple.provenance which we can't remove on macOS 15+)
  local xattr_list
  xattr_list=$(xattr "$file" 2>/dev/null | grep -v "com.apple.provenance" || true)
  if [[ -n "$xattr_list" ]]; then
    has_meta=true
    local xattr_count
    xattr_count=$(echo "$xattr_list" | wc -l | /usr/bin/tr -d ' ')
    details="$details xattrs:$xattr_count"
  fi
  
  # Check EXIF metadata (only count privacy-relevant tags, not structural)
  if $HAS_EXIFTOOL; then
    local exif_privacy
    # Only count tags that could leak privacy info (exclude structural metadata)
    exif_privacy=$(exiftool -q -q -s \
      -Author -Creator -Artist -Copyright -Rights -Owner \
      -GPSLatitude -GPSLongitude -GPSPosition -GPSCoordinates \
      -Make -Model -Software -HostComputer \
      -Comment -UserComment -Description -Title -Subject \
      -CreateDate -DateTimeOriginal -ModifyDate \
      -SerialNumber -LensSerialNumber \
      "$file" 2>/dev/null | wc -l | /usr/bin/tr -d ' ')
    if [[ "$exif_privacy" -gt 0 ]]; then
      has_meta=true
      details="$details exif:$exif_privacy"
    fi
  fi
  
  if $has_meta; then
    echo "  would clean: $file ($details)"
    return 1  # Signal has metadata
  fi
  return 0
}

# ─────────────────────────────────────────────────────────────────
# Prompt for target if not provided
# ─────────────────────────────────────────────────────────────────
if [[ -z "$TARGET" ]]; then
  echo -n "Enter file/directory path [default: $PWD]: "
  read -r TARGET
  [[ -z "$TARGET" ]] && TARGET="$PWD"
fi

# Expand path (handle ~, variables, etc)
TARGET="${TARGET/#\~/$HOME}"
if [[ -e "$TARGET" ]]; then
  TARGET=$(cd "$(dirname "$TARGET")" 2>/dev/null && pwd)/$(basename "$TARGET")
else
  log_error "Not found: $TARGET"
  exit 1
fi

# ─────────────────────────────────────────────────────────────────
# Show tool status
# ─────────────────────────────────────────────────────────────────
if ! $FLAG_QUIET; then
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "NUCLEAR METADATA STRIPPER"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "▸ Tools available:"
  $HAS_EXIFTOOL && echo "  exiftool: ✅ (EXIF/XMP/IPTC)" || echo "  exiftool: ❌ (install: brew install exiftool)"
  $HAS_FFMPEG && echo "  ffmpeg:   ✅ (embedded media)" || echo "  ffmpeg:   ❌ (install: brew install ffmpeg)"
  echo "  xattr:    ✅ (macOS built-in)"
  echo "  rsync:    ✅ (strips xattrs including provenance)"
  echo ""
fi

# ─────────────────────────────────────────────────────────────────
# DRY-RUN MODE
# ─────────────────────────────────────────────────────────────────
if $FLAG_DRY_RUN; then
  log_info "DRY-RUN mode - scanning: $TARGET"
  echo "───────────────────────────────────────────────────────────────"
  
  total=0
  has_meta=0
  
  if [[ -d "$TARGET" ]]; then
    # Use temp file to avoid subshell variable loss (SHELL-003)
    local tmpfile="/tmp/clearmeta_$$_files"
    find "$TARGET" -type f -not -path "*/.git/*" > "$tmpfile" 2>/dev/null
    
    while IFS= read -r file; do
      [[ -z "$file" ]] && continue
      total=$((total + 1))
      check_file_metadata "$file" || has_meta=$((has_meta + 1))
    done < "$tmpfile"
    
    rm -f "$tmpfile" 2>/dev/null
  else
    total=1
    check_file_metadata "$TARGET" || has_meta=1
  fi
  
  echo ""
  log_info "Scanned $total files, $has_meta have metadata to strip"
  echo "═══════════════════════════════════════════════════════════════"
  exit 0
fi

# ─────────────────────────────────────────────────────────────────
# RECURSIVE MODE
# ─────────────────────────────────────────────────────────────────
if $FLAG_RECURSIVE; then
  if [[ ! -d "$TARGET" ]]; then
    log_error "-r flag requires a directory, but got: $TARGET"
    exit 1
  fi
  
  $FLAG_QUIET || echo "▸ Target: $TARGET"
  $FLAG_QUIET || echo "───────────────────────────────────────────────────────────────"
  
  # Count files first
  total_files=$(find "$TARGET" -type f -not -path "*/.git/*" 2>/dev/null | wc -l | /usr/bin/tr -d ' ')
  $FLAG_QUIET || echo "▸ Found $total_files files to process"
  $FLAG_QUIET || echo ""
  
  success_count=0
  fail_count=0
  
  # Use temp file to avoid subshell variable loss (SHELL-003)
  local tmpfile="/tmp/clearmeta_$$_files"
  find "$TARGET" -type f -not -path "*/.git/*" > "$tmpfile" 2>/dev/null
  
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    
    # Show relative path for cleaner output
    rel_path="${file#$TARGET/}"
    [[ "$rel_path" == "$file" ]] && rel_path="$file"
    
    if $FLAG_QUIET; then
      nuke_file "$file" "quiet" && success_count=$((success_count + 1)) || fail_count=$((fail_count + 1))
    else
      printf "  %-55s " "$rel_path"
      if nuke_file "$file" "quiet"; then
        echo "✅"
        success_count=$((success_count + 1))
      else
        echo "⚠️"
        fail_count=$((fail_count + 1))
      fi
    fi
  done < "$tmpfile"
  
  rm -f "$tmpfile" 2>/dev/null
  
  # Also clear xattrs on directories themselves
  $FLAG_QUIET || echo ""
  $FLAG_QUIET || echo "▸ Clearing directory xattrs..."
  xattr -cr "$TARGET" 2>/dev/null || true
  $FLAG_QUIET || echo "  ✅ Cleared xattrs on directories"
  
  # Summary
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "▸ SUMMARY"
  echo "───────────────────────────────────────────────────────────────"
  echo "  Files processed: $total_files"
  echo "  Success: $success_count"
  echo "  Warnings: $fail_count"
  echo "═══════════════════════════════════════════════════════════════"
  exit 0
fi

# ─────────────────────────────────────────────────────────────────
# SINGLE FILE/DIRECTORY MODE
# ─────────────────────────────────────────────────────────────────
$FLAG_QUIET || echo "▸ Target: $TARGET"
$FLAG_QUIET || echo "───────────────────────────────────────────────────────────────"

# Show BEFORE state
if ! $FLAG_QUIET; then
  echo ""
  echo "▸ BEFORE"
  echo "───────────────────────────────────────────────────────────────"
  xattrs_before=$(xattr "$TARGET" 2>/dev/null || true)
  if [[ -n "$xattrs_before" ]]; then
    echo "$xattrs_before" | sed 's/^/  /'
  else
    echo "  (no xattrs)"
  fi
  
  if $HAS_EXIFTOOL && [[ -f "$TARGET" ]]; then
    exif_count=$(exiftool -q -q -s "$TARGET" 2>/dev/null | wc -l | /usr/bin/tr -d ' ')
    echo "  EXIF/XMP/IPTC tags: $exif_count"
  fi
fi

# Process
$FLAG_QUIET || echo ""
$FLAG_QUIET || echo "▸ NUKING..."
$FLAG_QUIET || echo "───────────────────────────────────────────────────────────────"

if [[ -d "$TARGET" ]]; then
  # For directories: clear all xattrs (when SIP off, this removes provenance too)
  xattr -cr "$TARGET" 2>/dev/null && log_detail "✅ Cleared xattrs (recursive)" || log_detail "⚠️  Some attributes could not be cleared"
  # Explicit provenance strip (succeeds when SIP off; no-op when SIP on)
  xattr -d com.apple.provenance "$TARGET" 2>/dev/null || true
  log_detail "ℹ️  When SIP is on, provenance on dirs may still persist"
  log_detail "💡 Tip: Use -r flag to byte-copy all files inside: clearmeta -r $TARGET"
else
  # For files: NUCLEAR treatment
  nuke_file "$TARGET"
fi

# Show AFTER state
if ! $FLAG_QUIET; then
  echo ""
  echo "▸ AFTER"
  echo "───────────────────────────────────────────────────────────────"
  xattrs_after=$(xattr "$TARGET" 2>/dev/null || true)
  if [[ -n "$xattrs_after" ]]; then
    echo "$xattrs_after" | sed 's/^/  /'
  else
    echo "  (no xattrs)"
  fi
  
  if $HAS_EXIFTOOL && [[ -f "$TARGET" ]]; then
    exif_count=$(exiftool -q -q -s "$TARGET" 2>/dev/null | wc -l | /usr/bin/tr -d ' ')
    echo "  EXIF/XMP/IPTC tags: $exif_count"
  fi
fi

# Check if only provenance remains (that's fine - it's local-only, doesn't leak)
remaining_xattrs=$(xattr "$TARGET" 2>/dev/null | grep -v "com.apple.provenance" || true)
if ! $FLAG_QUIET && [[ -n "$remaining_xattrs" ]]; then
  echo ""
  echo "▸ NOTE"
  echo "───────────────────────────────────────────────────────────────"
  echo "  ⚠️  Some xattrs could not be removed:"
  echo "$remaining_xattrs" | sed 's/^/    /'
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
