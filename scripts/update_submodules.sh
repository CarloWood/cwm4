#! /bin/bash
# Written by Carlo Wood 2016, 2017

# This script should be run from the root of the parent project.
if ! test -e .git; then
  echo "$0: $(pwd) is not a git repository."
  exit 1
fi

# Parse command line parameters.
opt_init=
opt_recursive=
do_foreach=0
initial_call=1
while [[ $# -gt 0 ]]
do
  case $1 in
    --init)
      opt_init=$1
      ;;
    --recursive)
      opt_recursive=$1
      do_foreach=1
      ;;
    --reentery)
      initial_call=0
      ;;
    --)
      break;
      ;;
    -*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      break
      ;;
  esac
  shift
done

# Determine the full path to this script.
if [[ ${0:0:1} = / ]]; then
  FULL_PATH="$0"
else
  FULL_PATH="$(realpath $0)"
fi

# Colors.
esc=""
reset="$esc""[0m"
prefix="$esc""[36m***""$reset"
red="$esc[31m"
green="$esc[32m"
orange="$esc[33m"

if test "$initial_call" -eq 1; then
  do_foreach=1
else
  # Script is called from git submodule foreach ...'
  name="$1"
  path="$2"
  sha1="$3"
  toplevel="$4"
  # Make sure we are in the right directory.
  cd "$toplevel/$path" || exit 1
  # Does the parent project want us to checkout a branch for this module?
  SUBMODULE_BRANCH=$(git config -f "$toplevel/.gitmodules" submodule.$name.branch)
  if test -n "$SUBMODULE_BRANCH"; then
    git checkout $SUBMODULE_BRANCH 2>&1 |\
      awk '
        /^(Your branch is up-to-date with|Already on)/ { printf("'"$green%s$reset"'\n", $0); next }
        /^Your branch is ahead of/ { printf("'"$orange%s$reset"'\n", $0); next }
        /use "git push" to publish your local commits/ { next }
        { printf("'"$red%s$reset"'\n", $0) }' || exit 1
      
    git pull --ff-only || exit 1
    if test $(git rev-parse HEAD) != "$sha1"; then
      # Update the parent project to point to the head of this branch.
      pushd "$toplevel" >/dev/null
      SN1=$(git stash list | grep '^stash' | wc --lines)
      git stash save --quiet Automatic stash of parent project by update_submodules.sh
      SN2=$(git stash list | grep '^stash' | wc --lines)
      git add $path
      git commit -m "Updating submodule reference to current HEAD of branch $SUBMODULE_BRANCH of $name"
      if test $SN1 -ne $SN2; then
        git stash pop --quiet
      fi
      popd >/dev/null
    fi
  elif test $(git rev-parse HEAD) != "$sha1"; then
    # No submodule.$name.branch for this submodule. Just checkout the detached HEAD.
    git checkout $sha1
  fi
  echo
fi

if test $do_foreach -eq 1; then
  if test -n "$opt_init"; then
    git submodule init
  fi
  # Make sure the submodules even exist.
  git submodule update
  # Call this script recursively for all submodules.
  git submodule foreach "$FULL_PATH --reentery $opt_init $opt_recursive"' $name $path $sha1 $toplevel' |\
    awk '
      /^Already/ { printf("'"$green%s$reset"'\n", $0); next }
      { print }'
fi
