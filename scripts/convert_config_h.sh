#! /bin/bash

srcdir="$(echo $0 | sed -e 's%/cwm4/scripts/convert_config_h\.sh%%')"

for f in $config_files; do
  SRCFILE="$srcdir/$f.in"
  if [ "$SRCFILE" -ef "$f.in" ]; then
    echo "WARNING: BUILDING IN THE SOURCE TREE IS NOT SUPPORTED."
    SRCFILE="$srcdir/$f.in.bak"
    if [ ! -e "$SRCFILE" ]; then
      echo "Moving $srcdir/$f.in to $srcdir/$f.in.bak because we're about to overwrite it."
      mv $srcdir/$f.in $srcdir/$f.in.bak
    fi
  fi
  if [ $(basename $f) = "config.h" ]; then
    echo "configure: creating $f.in"
    mkdir -p "$(dirname $f)"
    awk  '/^#cmakedefine01/ { next; }
          /^#cmakedefine/ { $0 = gensub(/^#cmakedefine\s+([^ ]+).*/, "#@CW_CONFIG_\\1@ \\1", "g"); print; next; }
          { print; }' "$SRCFILE" > $f.in
  fi
done
