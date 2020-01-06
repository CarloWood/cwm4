#! /bin/bash

srcdir="$(echo $0 | sed -e 's%/cwm4/scripts/convert_config_h\.sh%%')"

for f in $config_files; do
  if [ $(basename $f) = "config.h" ]; then
    echo "configure: creating $f.in"
    mkdir -p "$(dirname $f)"
    awk  '/^#cmakedefine01/ { next; }
          /^#cmakedefine/ { $0 = gensub(/^#cmakedefine\s+([^ ]+).*/, "#@CW_CONFIG_\\1@ \\1", "g"); print; next; }
          { print; }' $srcdir/$f.in > $f.in
  fi
done
