#!/usr/bin/env bash
set -euo pipefail

# Determine override file path.
if (( $# > 1 )); then
  echo "Usage: $0 [override_file]" >&2
  exit 1
fi

if (( $# == 1 )); then
  rcfile="$(realpath "$1")"
elif [[ -n "${LIBCWD_RCFILE_OVERRIDE_NAME-}" ]]; then
  rcfile="$LIBCWD_RCFILE_OVERRIDE_NAME"
else
  dir="$(basename "$PWD")"
  rcfile="$(realpath "../libcwdrc_$dir")"
fi

declare -A channel_state  # key: "key:channel", value: "on"|"off".
declare -A key_seen       # key: "<key>", value: "1".

# Parse an existing override file if present.
if [[ -f "$rcfile" ]]; then
  prev=""
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^[[:space:]]*channels_on[[:space:]]*=[[:space:]]*(.*)$ ]] ||
       [[ "$line" =~ ^[[:space:]]*#channels_off[[:space:]]*=[[:space:]]*(.*)$ ]]; then
      # Determine key from the immediately preceding "# <key>..." line.
      key=""
      if [[ "$prev" =~ ^#\ (.*)$ ]]; then
        first="${BASH_REMATCH[1]}"
        first="${first%%[[:space:].,:;]*}"
        if [[ "$first" == "libcwd" || -d "$first" ]]; then
          key="$first"
        fi
      fi
      # Skip if no valid key was found.
      if [[ -z "$key" ]]; then
        prev="$line"
        continue
      fi

      # Extract and record channels.
      list="${BASH_REMATCH[1]}"
      IFS=',' read -ra chans <<< "$list"
      for c in "${chans[@]}"; do
        # Remove all whitespace and lowercase.
        c="${c//[[:space:]]/}"
        c="${c,,}"
        [[ -z "$c" ]] && continue
        if [[ "$line" =~ ^[[:space:]]*channels_on ]]; then
          channel_state["$key:$c"]="on"
        else
          channel_state["$key:$c"]="off"
        fi
      done
      key_seen["$key"]=1
    fi
    prev="$line"
  done < "$rcfile"
fi

# Normalize a directory path to the top-level directory name.
normalize_key() {
  local path="$1"
  path="${path#./}"
  case "$path" in
    */*) echo "${path%%/*}" ;;
    *)   echo "$path" ;;
  esac
}

# Collect channels from source files.
shopt -s globstar nullglob
for f in **/*.cxx **/*.cpp **/*.cc **/*.C; do
  # Resolve top-level key for this file. Skip files in the repository root.
  d="$(dirname "$f")"
  key="$(normalize_key "$d")"
  [[ "$key" == "$d" && "$d" != */* ]] && continue

  while IFS= read -r match; do
    # match looks like: "  channel_ct foo("FOO"); ...".
    text="${match#*channel_ct }"
    chan="${text%%(*}"
    chan="${chan%%[[:space:]]*}"
    chan="${chan,,}"
    [[ -z "$chan" ]] && continue
    key_seen["$key"]=1
    [[ -n "${channel_state["$key:$chan"]-}" ]] || channel_state["$key:$chan"]="off"
  done < <(grep -E '^[[:space:]]*channel_ct[[:space:]]+' "$f" || true)
done

# Ensure libcwd defaults are present.
key_seen["libcwd"]=1
for ch in warning notice debug; do
  channel_state["libcwd:$ch"]="on"
done
for ch in bfd demangler malloc system; do
  : "${channel_state["libcwd:$ch"]:="off"}"
done

# Build ordered key list: explicit → *-task (alphabetic) → rest (alphabetic).
explicit_order=(libcwd cwds utils memory threadsafe threadpool events evio statefultask)

# Collect all keys seen.
mapfile -t all_keys < <(printf '%s\n' "${!key_seen[@]}")

# Add explicit keys if present.
ordered=()
declare -A placed
for k in "${explicit_order[@]}"; do
  if [[ -n "${key_seen[$k]-}" ]]; then
    ordered+=("$k")
    placed["$k"]=1
  fi
done

# Add *-task keys (excluding already placed), sorted.
mapfile -t task_keys < <(
  for k in "${all_keys[@]}"; do
    if [[ "$k" == *-task && -z "${placed[$k]-}" ]]; then
      echo "$k"
    fi
  done | sort -u
)
for k in "${task_keys[@]}"; do
  ordered+=("$k")
  placed["$k"]=1
done

# Add remaining keys, sorted.
mapfile -t rest_keys < <(
  for k in "${all_keys[@]}"; do
    if [[ -z "${placed[$k]-}" ]]; then
      echo "$k"
    fi
  done | sort -u
)
ordered+=("${rest_keys[@]}")

# Regenerate override file.
{
  echo "# This is an override file; just define the debug channels that we need."
  echo

  for key in "${ordered[@]}"; do
    # Collect on/off lists for this key.
    on_list=()
    off_list=()
    for entry in "${!channel_state[@]}"; do
      k="${entry%%:*}"
      c="${entry#*:}"
      if [[ "$k" == "$key" ]]; then
        if [[ "${channel_state[$entry]}" == "on" ]]; then
          on_list+=("$c")
        else
          off_list+=("$c")
        fi
      fi
    done

    # Skip keys without any channels.
    (( ${#on_list[@]} + ${#off_list[@]} == 0 )) && continue

    echo "# $key"
    (( ${#on_list[@]} )) && { echo -n "channels_on = "; echo "${on_list[*]}" | sed 's/ /,/g'; }
    (( ${#off_list[@]} )) && { echo -n "#channels_off = "; echo "${off_list[*]}" | sed 's/ /,/g'; }
    echo
  done
} > "$rcfile"

# Print export line with optional $TOPPROJECT canonicalization.
if [[ -n "${TOPPROJECT-}" && -n "$TOPPROJECT" && "$rcfile" == "$TOPPROJECT"* ]]; then
  rcfile="\$TOPPROJECT${rcfile#$TOPPROJECT}"
fi
echo "export LIBCWD_RCFILE_OVERRIDE_NAME=\"$rcfile\""

