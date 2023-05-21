#! /bin/bash

GENERATOR="$1"
GITACHE_PACKAGES="$2"

if [ "$GENERATOR" = "ninja" ]; then
  MAKE="$(which ninja)"
else # GENERATOR
  MAKE="$GENERATOR"
fi

if [ ! -x "$MAKE" ]; then
  echo "Unexpected error: \"$MAKE\" is not executable."
  exit 1
fi

if [ "$GENERATOR" = "ninja" ]; then
  echo "Running 'ninja -t clean' ..."
  "$MAKE" clean
else
  echo "Running 'make clean' ..."
  "$MAKE" --no-print-directory clean
fi

empty_dirs=()

if [ "$GENERATOR" = "ninja" ]; then

  # The sorting makes sure that subdirectories are processed before their parent directory.
  readarray -t subdirs < <(find . -mindepth 2 -type d -name 'CMakeFiles' -printf "%P\n" | sed -re 's%/?CMakeFiles$%%' | sort -r)

  MCT=$(ninja help | grep '^maintainer-clean-' | grep -v 'maintainer-clean-extra:' | sed -e 's%:.*%%')
  for target in $MCT; do
    $MAKE $target
  done

else # GENERATOR

  # This doesn't work for paths containing new-lines...
  # The sorting makes sure that subdirectories are processed before their parent directory.
  readarray -t subdirs < <(find . -mindepth 2 -type f -name 'Makefile' -printf "%P\n" | sed -re 's%/?Makefile$%%' | sort -r)

  # Since cmake tends to regenerate Makefile's whenever they are missing, we have to run
  # all Makefile rules prior to deleting the Makefiles themselves.
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

fi # GENERATOR

# The project root uses the extention -extra.
if $MAKE -n maintainer-clean-extra >/dev/null 2>/dev/null; then
  echo "Running: $MAKE maintainer-clean-extra"
  $MAKE maintainer-clean-extra
fi

# Remove all cmake stuff and the Makefiles.
subdirs+=("${empty_dirs[@]}")
IFS=$'\n' sorted=($(sort -r <<<"${subdirs[*]}"))
unset IFS
sorted+=(".")
for dir in "${sorted[@]}"; do
  echo "Maintainer cleaning $dir"
  rm -rf "$dir"/CMakeFiles "$dir"/CMakeCache.txt "$dir"/cmake_install.cmake "$dir"/Makefile
done

if [ "$GENERATOR" = "ninja" ]; then
  rm -rf _deps
  rm -f utils/config.h
  rm -f build.ninja
fi

# Finally remove all empty directories.
find . -type d -empty -delete
