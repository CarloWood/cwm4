#! /bin/bash

# This script should be run from the root of the parent project.
if ! test -d .git; then
  echo "$0: $(pwd) is not a git repository."
  exit 1
fi

if test "$#" -ne 4; then
  # Script is called for the first time from the root of the base parent project.
  # Bootstrap the recursive calls.
  FULLPATH=$(realpath $0) || exit 1
  git submodule foreach "$FULLPATH"' $name $path $sha1 $toplevel'
else
  # Script is called from git submodule foreach "$FULLPATH"' $name $path $sha1 $toplevel'.
  # Check that it was indeed called with a full path.
  if [[ ${0:0:1} != / ]]; then
    echo "Not a full path: $0"
    exit 1
  fi
  name="$1"
  path="$2"
  sha1="$3"
  toplevel="$4"
  # Does the parent project want us to checkout a branch for this module?
  SUBMODULE_BRANCH=$(git config -f "$toplevel/.gitmodules" submodule.$name.branch)
  if test -n "$SUBMODULE_BRANCH"; then
    git checkout $SUBMODULE_BRANCH
    if test $(git rev-parse HEAD) != "$sha1"; then
      # Update the parent project to point to the head of this branch.
      CURDIR="$(pwd)"
      cd $toplevel || exit 1
      SN1=$(git stash list | grep '^stash' | wc --lines)
      git stash save --quiet Automatic stash of parent project by update_submodules.sh
      SN2=$(git stash list | grep '^stash' | wc --lines)
      git add $name
      git commit -m "Update of submodule $name to current $SUBMODULE_BRANCH"
      if test $SN1 -ne $SN2; then
        git stash pop --quiet
      fi
      cd "$CURDIR"
    fi
  elif test $(git rev-parse HEAD) != "$sha1"; then
    # No submodule.$name.branch for this submodule. Just checkout the detached HEAD.
    git checkout $sha1
  fi
fi
