#! /bin/bash

# Function to display usage information.
usage() {
  echo "Usage: $0 [override_file_path]"
  echo "  override_file_path: Optional path to override file (relative to pwd)"
  exit 1
}

# Check if too many arguments are provided.
if [ $# -gt 1 ]; then
  echo "Error: Only one command line parameter is allowed"
  usage
fi

# Determine the override file path.
if [ $# -eq 1 ]; then
  # Case 1: Command line parameter provided.
  if [[ "$1" == /* ]]; then
    # Absolute path - normalize without resolving symlinks.
    OVERRIDE_FILE=$(realpath -sm "$1")
  else
    # Relative path - combine with pwd and normalize without resolving symlinks.
    combined_path="$(pwd)/$1"
    OVERRIDE_FILE=$(realpath -sm "$combined_path")
  fi
elif [ -n "$LIBCWD_RCFILE_OVERRIDE_NAME" ]; then
  # Case 2: Environment variable is set - normalize without resolving symlinks.
  OVERRIDE_FILE="$LIBCWD_RCFILE_OVERRIDE_NAME"
else
  # Case 3: Default behavior - use ../libcwdrc_$DIR.
  CURRENT_DIR=$(basename "$(pwd)")
  combined_path="$(pwd)/../libcwdrc_${CURRENT_DIR}"
  OVERRIDE_FILE=$(realpath -sm "$combined_path")
fi

# Check if we're using bash 4.0+ (required for associative arrays).
if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
  echo "Error: This script requires bash 4.0 or higher" >&2
  exit 1
fi

# Initialize arrays (outside the function).
declare -A key_set
declare -A key_header
declare -A key_comment
declare -A on_channels
declare -A off_channels

add_key() {
  local key="$1"
  key_set["$key"]=1
}

have_channel() {
  local key="$1"
  local channel="$2"
  [[ " ${on_channels[$key]} " == *" $channel "* || " ${off_channels[$key]} " == *" $channel "* ]]
}

add_on_channel() {
  local key="$1"
  local channel="$2"
  if ! have_channel "$key" "$channel"; then
    if [[ -z "${on_channels[$key]}" ]]; then
      on_channels["$key"]="$channel"
    else
      on_channels["$key"]="${on_channels[$key]} $channel"
    fi
  fi
}

add_off_channel() {
  local key="$1"
  local channel="$2"
  if ! have_channel "$key" "$channel"; then
    if [[ -z "${off_channels[$key]}" ]]; then
      off_channels["$key"]="$channel"
    else
      off_channels["$key"]="${off_channels[$key]} $channel"
    fi
  fi
}

parse_override_file() {
  local file="$1"
  local collecting_header=true
  local header_lines=()
  local current_key=""
  local current_comment=""

  # Reset arrays if parsing multiple files.
  key_set=([libcwd]=1)
  key_header=()
  key_comment=()
  on_channels=()
  off_channels=()

  while IFS= read -r line || [ -n "$line" ]; do
    # Remove carriage returns and trim trailing whitespace.
    line="${line//$'\r'/}"
    line="${line%%[[:space:]]}"

    # Check if this is a channels line.
    if [[ "$line" =~ ^(channels_on|#channels_off)[[:space:]]*=[[:space:]]*(.*)$ ]]; then
      local channel_type="${BASH_REMATCH[1]}"
      local channel_list="${BASH_REMATCH[2]}"

      echo "header_lines = ${header_lines[*]}"
      # Check for key definition line: # KEY KEY-COMMENT.
      if [[ ${#header_lines[@]} -gt 0 &&  "${header_lines[-1]}" =~ ^#[[:space:]]+([A-Za-z0-9_-]+)([[:space:]]+(.*))?$ ]]; then
        # Extract key and comment.
        current_key="${BASH_REMATCH[1]}"
        current_comment="${BASH_REMATCH[3]:-}"

        # Store all collected header lines.
        key_header["$current_key"]=$(printf '%s\n' "${header_lines[@]}")
        header_lines=()

        # Store the key comment.
        key_comment["$current_key"]="$current_comment"

        # Add this key to our list and initialize channels.
        add_key "$current_key"
        on_channels["$current_key"]=""
        off_channels["$current_key"]=""
      fi
      if [ -z "$current_key" ]; then
        echo "Warning: Found channels line without preceding key definition: $line" >&2
        continue
      fi

      # Remove any trailing comments.
      channel_list="${channel_list%%#*}"
      channel_list="${channel_list%%[[:space:]]}"

      echo "FOUND: \"$line\"; channel_type: \"$channel_type\"; channel_list: \"$channel_list\""

      # Split comma-separated list and add to appropriate array.
      IFS=',' read -ra channels <<< "$channel_list"
      for channel in "${channels[@]}"; do
        echo "CHANNEL = \"$channel\""
        # Trim whitespace from each channel.
        channel="${channel##[[:space:]]}"
        channel="${channel%%[[:space:]]}"

        if [[ "$channel" =~ ^[A-Za-z0-9_]+$ ]]; then
          if [ "$channel_type" = "channels_on" ]; then
            add_on_channel "$current_key" "$channel"
          else # #channels_off
            add_off_channel "$current_key" "$channel"
          fi
        fi
      done
      continue
    fi

    # Handle header lines (comments and empty lines).
    header_lines+=("$line")

  done < "$file"

  # Make sure the libcwd channels are listed.
  add_on_channel libcwd notice
  add_on_channel libcwd debug
  add_on_channel libcwd warning
  add_off_channel libcwd malloc
  add_off_channel libcwd demangler
  add_off_channel libcwd bfd
  add_off_channel libcwd system

  if [[ -v key_header["libcwd"] ]]; then
    echo "key_header["libcwd"] exists with contents: \"${key_header[libcwd]}\"."
  else
    key_header["libcwd"]=$'# This is an override file; just define the debug channels that we need.\n\n# libcwd default debug channels.'
  fi
}

# Function to display the parsed data (for debugging).
display_parsed_data() {
  echo "Parsed override file data:"
  echo "=========================="

  for key in "${!key_set[@]}"; do
    echo "Header:"
    echo "${key_header[$key]:-(none)}"
    echo "Key: [$key] [${key_comment[$key]:-(none)}]"
    echo "  ON:  ${on_channels[$key]:-(none)}"
    echo "  OFF: ${off_channels[$key]:-(none)}"
    echo
  done
}

# Example usage.
parse_override_file "$OVERRIDE_FILE"
display_parsed_data

# Collect new channels from source files.
shopt -s globstar nullglob
for f in **/*.cxx **/*.cpp **/*.cc **/*.C; do
  # Add top-level directory as key.
  rel="${f#./}"
  key="${rel%%/*}"
  add_key "$key"
  while IFS= read -r match; do
    pattern='^[[:space:]]*channel_ct[[:space:]]+[[:alnum:]_]+\(\"([[:alnum:]_]+)\"\);[[:space:]]*(//.*)?$'
    if [[ "$match" =~ $pattern ]]; then
      channel="${BASH_REMATCH[1]}"
      channel="${channel,,}"            # To lower case.
      add_off_channel "$key" "$channel"
    fi
  done < <(grep -E '^[[:space:]]*channel_ct[[:space:]]+' "$f" || true)
done

# Compute key order: explicit → *-task → rest.
explicit_order=(libcwd cwds utils memory threadsafe threadpool events evio statefultask)

# Build a set of keys that actually have channels.
declare -A key_has_channel
for key in "${!key_set[@]}"; do
  if [[ -n ${on_channels["$key"]} || -n ${off_channels["$key"]} ]]; then
    key_has_channel["$key"]=1
  fi
done

echo "All keys that have at least one channel: "${!key_has_channel[@]}

# Build ordered list respecting the requered ordering.
ordered=()
declare -A placed
append_key() {
  local key="$1"
  [[ -n "${key_has_channel[$key]-}" && -z "${placed[$key]-}" ]] || return
  ordered+=("$key")
  placed["$key"]=1
}
for k in "${explicit_order[@]}"; do append_key "$k"; done

# *-task keys sorted.
mapfile -t task_keys < <(
  for key in "${!key_has_channel[@]}"; do
    [[ "$key" == *-task && -z "${placed[$key]-}" ]] && printf '%s\n' "$key"
  done | sort -u
)
for key in "${task_keys[@]}"; do append_key "$key"; done

# Remaining keys sorted alphabetically.
mapfile -t rest_keys < <(
  for key in "${!key_has_channel[@]}"; do
    [[ -z "${placed[$key]-}" ]] && printf '%s\n' "$key"
  done | sort -u
)
for key in "${rest_keys[@]}"; do append_key "$key"; done

# Write the override file.
{
  for key in "${ordered[@]}"; do
    # Emit preserved header text, if any.
    if [[ -v key_header["$key"] ]]; then
      if [[ "$key" != "libcwd" && ${key_header[$key]:0:1} != $'\n' ]]; then
        echo
      fi
      echo "${key_header[$key]}"
    else
      printf '\n# %s\n' "$key"
    fi
    [[ -n ${on_channels["$key"]} ]] && { echo -n "channels_on = "; echo "${on_channels[$key]}" | sed 's/ /,/g'; }
    [[ -n ${off_channels["$key"]} ]] && { echo -n "#channels_off = "; echo "${off_channels[$key]}" | sed 's/ /,/g'; }
  done
} > "$OVERRIDE_FILE"

# Example of how to access the data.
echo "Accessing specific data:"
for key in "${!key_set[@]}"; do
  echo "Processing key: $key"

  # Convert space-separated strings to arrays if needed.
  IFS=' ' read -ra on_array <<< "${on_channels[$key]}"
  IFS=' ' read -ra off_array <<< "${off_channels[$key]}"

  echo "  ON channels (as array): ${on_array[*]}"
  echo "  OFF channels (as array): ${off_array[*]}"
  echo
done

if [[ -n "$TOPPROJECT" && "$OVERRIDE_FILE" == "$TOPPROJECT"* ]]; then
  OVERRIDE_FILE="\$TOPPROJECT${OVERRIDE_FILE#$TOPPROJECT}"
fi

# Display the determined path.
echo "Override file path: $OVERRIDE_FILE"

# You can add additional logic here to use the override file.
# For example:
# if [ -f "$OVERRIDE_FILE" ]; then
#   echo "Override file exists: $OVERRIDE_FILE"
#   # Process the file here.
# else
#   echo "Override file does not exist: $OVERRIDE_FILE"
# fi
