#! /bin/bash

# To use this script, create .git/hooks/pre-push with the line
#
# exec git submodule --quiet foreach --recursive "$(realpath cwm4/scripts/submodule_pre-push.sh)"' "$sm_path" $sha1 "$toplevel"'
#
# and make it executable.
#
# To create the alias, run
#
# $ git config --local alias.upsh '!'"$(realpath cwm4/scripts/upsm-push.sh)"

# Arguments.
path="$1"
sha1="$2"
toplevel="$3"

if test $(git rev-parse HEAD) != "$sha1"; then
  echo "Need: git -C \"$toplevel\" commit -m 'Update gitlink $path.' -o -- \"$path\""
  echo
  echo "One or more submodule gitlink(s) are not up to date."
  echo "Please use,"
  echo
  echo "    git upsh"
  echo
  echo "to automatically update and commit gitlinks before pushing."
  echo

  exit 1
fi

exit 0
