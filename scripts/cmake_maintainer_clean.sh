#! /bin/bash

MAKE="$1"

if [ ! -x "$MAKE" ]; then
  echo "Unexpected error: \"$MAKE\" is not executable."
  exit 1
fi

echo "Running 'make clean' ..."
"$MAKE" --no-print-directory clean

# This doesn't work for paths containing new-lines...
# The sorting makes sure that subdirectories are processed before their parent directory.
readarray -t subdirs < <(find . -mindepth 2 -type f -name 'Makefile' -printf "%P\n" | sed -re 's%/?Makefile$%%' | sort -r)

# Since cmake tends to regenerate Makefile's whenever they are missing, we have to run
# all Makefile rules prior to deleting the Makefiles themselves.
empty_dirs=()
for dir in "${subdirs[@]}"; do
  base=$(dirname "$dir")
  name=$(basename "$dir")
  if $MAKE -C "$base" -n "maintainer-clean-$name" >/dev/null 2>/dev/null; then
    echo "Running: $MAKE -C \"$base\" maintainer-clean-$name"
    $MAKE -C "$base" "maintainer-clean-$name"
  elif [ "$dir" != "." -a $MAKE -C "$dir" -n "maintainer-clean" ] >/dev/null 2>/dev/null; then
    echo "Running: $MAKE -C \"$base\" maintainer-clean"
    $MAKE -C "$base" maintainer-clean
  fi
  # Attempt to find empty directories.
  if [ ! -e "$base/Makefile" ]; then
    empty_dirs+=("$base")
  fi
done
# The project root uses the extention -extra.
if $MAKE -n maintainer-clean-extra >/dev/null 2>/dev/null; then
  echo "Running: $MAKE maintainer-clean-extra"
  $MAKE maintainer-clean-extra
fi

# Finally remove all cmake stuff and the Makefiles.
subdirs+=("${empty_dirs[@]}")
IFS=$'\n' sorted=($(sort -r <<<"${subdirs[*]}"))
unset IFS
for dir in "${sorted[@]}"; do
  echo "Maintainer cleaning $dir"
  rm -rf "$dir"/CMakeFiles "$dir"/CMakeCache.txt "$dir"/cmake_install.cmake "$dir"/Makefile
  if [ "$dir" != "." ]; then
    # Should be entirely empty now.
    rmdir "$dir" || find "$dir"
  fi
done

# Should be empty now.
test ! -e _3rdParty || rmdir _3rdParty || find _3rdParty
