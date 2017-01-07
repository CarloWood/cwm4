#! /bin/sh

MISSING_SUBMODULES="maybe"
while test -n "$MISSING_SUBMODULES"; do

  # (Re)generate submodules.m4.
  cwm4/scripts/generate_submodules_m4.sh

  # Check dependencies.
  MISSING_SUBMODULES=
  SUBDIRS="$(autom4te -l M4sugar cwm4/submodules.m4)"
  for dir in $SUBDIRS; do
    if ! test -f "$dir/configure.m4"; then
      MISSING_SUBMODULES="$MISSING_SUBMODULES $dir"
    fi
  done
  for dir in $MISSING_SUBMODULES; do
    echo "  Adding submodule dependency $dir"
    #git submodule URL $dir
  done
done
