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

# State: ("key:channel") -> on|off.
declare -A channel_state
# Keys that exist (used for ordering and emission).
declare -A key_seen
# Preserve original header text after "# " for each key, if present.
declare -A header_text

############################
# Parse existing rc override.
############################
current_key=""
while IFS= read -r line || [[ -n "$line" ]]; do
  # Detect header lines and set current_key. Preserve full header text to repeat later.
  if [[ "$line" =~ ^#[[:space:]]+(.*)$ ]]; then
    text="${BASH_REMATCH[1]}"
    # Determine key as the first 'word' in the header (up to whitespace or punctuation).
    key_candidate="$text"
    key_candidate="${key_candidate%%[[:space:].,:;]*}"
    if [[ -n "$key_candidate" ]]; then
      if [[ "$key_candidate" == "libcwd" || -d "$key_candidate" ]]; then
        current_key="$key_candidate"
        header_text["$current_key"]="$text"
        key_seen["$current_key"]=1
      else
        # Unknown key candidate; do not set current_key.
        current_key=""
      fi
    else
      current_key=""
    fi
    continue
  fi

  # Parse channels_on and #channels_off lines for the current key.
  if [[ "$line" =~ ^[[:space:]]*channels_on[[:space:]]*=[[:space:]]*(.*)$ ]]; then
    [[ -z "$current_key" ]] && continue
    list="${BASH_REMATCH[1]}"
    IFS=',' read -ra chans <<< "$list"
    for c in "${chans[@]}"; do
      c="${c//[[:space:]]/}"
      c="${c,,}"
      [[ -z "$c" ]] && continue
      channel_state["$current_key:$c"]="on"
    done
    key_seen["$current_key"]=1
    continue
  fi

  if [[ "$line" =~ ^[[:space:]]*#channels_off[[:space:]]*=[[:space:]]*(.*)$ ]]; then
    [[ -z "$current_key" ]] && continue
    list="${BASH_REMATCH[1]}"
    IFS=',' read -ra chans <<< "$list"
    for c in "${chans[@]}"; do
      c="${c//[[:space:]]/}"
      c="${c,,}"
      [[ -z "$c" ]] && continue
      channel_state["$current_key:$c"]="off"
    done
    key_seen["$current_key"]=1
    continue
  fi
done < <( [[ -f "$rcfile" ]] && cat -- "$rcfile" || printf '' )

######################################
# Scan source tree for channel_ct lines.
######################################
shopt -s globstar nullglob

# Supported C++ source extensions.
src_globs=( **/*.cxx **/*.cpp **/*.cc **/*.C )

for f in "${src_globs[@]}"; do
  # Only consider files in subdirectories of $PWD.
  [[ "$f" != */* ]] && continue

  rel="${f#./}"
  top="${rel%%/*}"                  # Top-level directory is the key.
  key_seen["$top"]=1

  # Grep lines that start with optional whitespace then 'channel_ct '.
  while IFS= read -r match; do
    # Extract the identifier with a bash regex to avoid brittle slicing.
    if [[ "$match" =~ ^[[:space:]]*channel_ct[[:space:]]+([A-Za-z_][A-Za-z_0-9]*)[[:space:]]*\( ]]; then
      chan="${BASH_REMATCH[1],,}"
      [[ -n "${channel_state["$top:$chan"]-}" ]] || channel_state["$top:$chan"]="off"
    fi
  done < <(grep -E '^[[:space:]]*channel_ct[[:space:]]+' "$f" || true)
done

###########################################
# Ensure special libcwd defaults are present.
###########################################
key_seen["libcwd"]=1
for ch in warning notice debug; do
  channel_state["libcwd:$ch"]="on"
done
for ch in bfd demangler malloc system; do
  : "${channel_state["libcwd:$ch"]:="off"}"
done
# If there was no preserved header, provide a sensible one.
: "${header_text["libcwd"]:="libcwd default debug channels."}"

#############################################
# Compute key order: explicit → *-task → rest.
#############################################
explicit_order=(libcwd cwds utils memory threadsafe threadpool events evio statefultask)

# Collect all keys that actually have channels.
declare -A key_has_channel
for kch in "${!channel_state[@]}"; do
  k="${kch%%:*}"
  key_has_channel["$k"]=1
done

# Helper to append unique keys in order.
ordered=()
declare -A placed
append_key() { if [[ -n "${key_has_channel[$1]-}" && -z "${placed[$1]-}" ]]; then ordered+=("$1"); placed["$1"]=1; fi; }

for k in "${explicit_order[@]}"; do
  append_key "$k"
done

# *-task keys (excluding those already placed).
mapfile -t task_keys < <(
  for k in "${!key_has_channel[@]}"; do [[ "$k" == *-task && -z "${placed[$k]-}" ]] && printf '%s\n' "$k"; done | sort -u
)
for k in "${task_keys[@]}"; do append_key "$k"; done

# Remaining keys.
mapfile -t rest_keys < <(
  for k in "${!key_has_channel[@]}"; do [[ -z "${placed[$k]-}" ]] && printf '%s\n' "$k"; done | sort -u
)
for k in "${rest_keys[@]}"; do append_key "$k"; done

########################
# Write the override file.
########################
{
  echo "# This is an override file; just define the debug channels that we need."
  echo

  for key in "${ordered[@]}"; do
    # Collect channels for this key.
    on_list=()
    off_list=()
    for entry in "${!channel_state[@]}"; do
      k="${entry%%:*}"
      c="${entry#*:}"
      [[ "$k" != "$key" ]] && continue
      if [[ "${channel_state[$entry]}" == "on" ]]; then
        on_list+=("$c")
      else
        off_list+=("$c")
      fi
    done

    # Skip keys without any channels.
    (( ${#on_list[@]} + ${#off_list[@]} == 0 )) && continue

    # Emit preserved header if available, else just the key.
    if [[ -n "${header_text[$key]-}" ]]; then
      echo "# ${header_text[$key]}"
    else
      echo "# $key"
    fi

    (( ${#on_list[@]} ))  && { echo -n "channels_on = ";  echo "${on_list[*]}"  | sed 's/ /,/g'; }
    (( ${#off_list[@]} )) && { echo -n "#channels_off = "; echo "${off_list[*]}" | sed 's/ /,/g'; }
    echo
  done
} > "$rcfile"

#######################################
# Print export line (canonicalize prefix).
#######################################
if [[ -n "${TOPPROJECT-}" && -n "$TOPPROJECT" && "$rcfile" == "$TOPPROJECT"* ]]; then
  rcfile="\$TOPPROJECT${rcfile#$TOPPROJECT}"
fi
echo "export LIBCWD_RCFILE_OVERRIDE_NAME=\"$rcfile\""

