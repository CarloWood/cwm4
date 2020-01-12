#! /bin/bash

# Arguments.
name="$1"
path="$2"
sha1="$3"
toplevel="$4"

echo "path = \"$path\""

if test $(git rev-parse HEAD) != "$sha1"; then
  echo "Need git -C \"$toplevel\" commit -m 'Update gitlink $path.' -o -- \"$path\""
  exit 1
fi
