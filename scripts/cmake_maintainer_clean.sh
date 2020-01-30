#! /bin/bash

MAKE="$1"

if [ ! -x "$MAKE" ]; then
  echo "Unexpected error: \"$MAKE\" is not executable."
  exit 1
fi

echo "Running 'make clean' ..."
"$MAKE" --no-print-directory clean

# This doesn't work for paths containing new-lines...
dirs=(.)
readarray -t subdirs < <(find . -type d -printf "%P\n")
dirs+=("${subdirs[@]}")

for dir in "${subdirs[@]}"; do
  if [ -e "$dir"/Makefile ]; then
    base=$(dirname "$dir")
    name=$(basename "$dir")
    if $MAKE -C "$base" -n "maintainer-clean-$name" >/dev/null 2>/dev/null; then
      $MAKE -C "$base" "maintainer-clean-$name"
    fi
  fi
done
if $MAKE -n maintainer-clean-extra >/dev/null 2>/dev/null; then
  $MAKE maintainer-clean-extra
fi

for dir in "${dirs[@]}"; do
  if [ -e "$dir"/Makefile ]; then
    echo "Maintainer cleaning $dir"
    rm -rf "$dir"/CMakeFiles "$dir"/CMakeCache.txt "$dir"/cmake_install.cmake "$dir"/Makefile
    if [ "$dir" != "." ]; then
      # Should be entirely empty now.
      rmdir "$dir"
    fi
  fi
done

# Should be empty now.
rmdir _3rdParty
rmdir _deps
