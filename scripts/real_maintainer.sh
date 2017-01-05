#! /bin/bash

# Only run this script if we are the real maintainer of this project (the owner of the git repository that contains the autogen.sh file).
if test "$(echo $GIT_COMMITTER_EMAIL | md5sum | cut -d \  -f 1)" = "$1"; then
  # Colors.
  esc=""
  reset="$esc""[0m"
  prefix="$esc""[36m***""$reset"
  red="$esc[31m"
  green="$esc[32m"
  orange="$esc[33m"

  # Greetings.
  echo "Hi $GIT_COMMITTER_NAME, how are you today?"

  # Sanity check.
  CWM4_BRANCH=$(git config -f .gitmodules submodule.cwm4.branch)
  if test -z "$CWM4_BRANCH"; then
    echo "$prefix $red""Setting submodule.cwm4.branch to master!"
    git config -f .gitmodules submodule.cwm4.branch master
    CWM4_BRANCH="master"
  fi

  # Is cwm4 on CWM4_BRANCH already?
  pushd cwm4 >/dev/null || exit 1
  if test x"$(git rev-parse --abbrev-ref HEAD)" != x"$CWM4_BRANCH"; then
    echo "$prefix $red""cwm4 is not up-to-date$reset; checking out branch $CWM4_BRANCH."
    git checkout $CWM4_BRANCH && git pull --ff-only || exit 1
  fi
  popd >/dev/null

  echo "$prefix Updating the projects autogen.sh..."
  # Get the trailing 'AccountName/projectname.git' of the upstream fetch url of branch master:
  MASTER_REMOTE=$(git config branch.master.remote)
  if test -z "$MASTER_REMOTE"; then
    REPO_NAME=$(basename $(pwd))
    echo "Fatal error: branch master does not have a remote set."
    echo "Make sure you created the repository $REPO_NAME on github and issued the commands"
    echo "under '...or push an existing repository from the command line'"
    echo "That is: create the remote REMOTE (ie, origin) and then issue the command:"
    echo "git push -u REMOTE master"
    exit 1
  fi
  PROJECT_URL="$(git config remote.$MASTER_REMOTE.url | sed -e 's%.*[^A-Za-z]\([^/ ]*/[^/ ]*$\)%\1%')"
  NEW_MD5=$(sed -e "s%@PROJECT_URL@%$PROJECT_URL%" cwm4/templates/autogen.sh | cat - cwm4/scripts/real_maintainer.sh | md5sum)
  OLD_MD5=$(cat autogen.sh cwm4/scripts/real_maintainer.sh | md5sum)
  if test "$OLD_MD5" = "$NEW_MD5"; then
    echo "  $prefix $green""Already up-to-date.""$reset"
  else
    sed -e "s%@PROJECT_URL@%$PROJECT_URL%" cwm4/templates/autogen.sh > autogen.sh
    echo "  $prefix $red""autogen.sh and/or real_maintainer.sh changed!""$reset"" Running the new script..."
    exec ./autogen.sh
    exit $?
  fi
  cd cwm4 || exit 1
  if ! git diff-index --quiet HEAD --; then
    echo -e "\n$prefix $red""Automatically committing uncommitted changes in cwm4!$reset"
    git commit -a -m 'Automatic commit of changes by autogen.sh.'
  fi
  CWM4COMMIT=$(git rev-parse HEAD)
  cd ..
  CWM4HASH=$(git ls-tree HEAD | grep '[[:space:]]cwm4$' | awk '{ print $3 }')
  if test "$CWM4HASH" != "$CWM4COMMIT"; then
    if git diff-index --quiet --cached HEAD; then
      echo -e "\n$prefix $red""Updating submodule reference to current HEAD of branch $CWM4_BRANCH of cwm4!$reset"
      git add cwm4 && git commit -m "Automatic commit: update of submodule reference cwm4 to current HEAD of branch $CWM4_BRANCH"
    elif test x"$(git rev-parse --abbrev-ref HEAD)" != x"$CWM4_BRANCH"; then
      echo -e "\n$prefix $red""Please checkout $CWM4_BRANCH in cwm4 and add it to the current project!$reset"
    fi
  fi

  # Is OUTPUT_DIRECTORY set?
  if m4 -P cwm4/sugar.m4 configure.ac | egrep '^[[:space:]]*CW_DOXYGEN' >/dev/null; then
    if test -z "$OUTPUT_DIRECTORY"; then
      echo "Error: the environment variable OUTPUT_DIRECTORY is not set."
      exit 1
    fi
  fi

  echo -e "\n$prefix Updating all submodules (recursively)..."

  # Check if 'branch' is set for all submodules with a configure.m4.
  git submodule foreach -q '
      if test -f "configure.m4" -a -z "$(git config -f $toplevel/.gitmodules submodule.$name.branch)"; then
        echo "'"$prefix $red"'""Setting submodule.$name.branch to master!'"$reset"'";
        git config -f $toplevel/.gitmodules "submodule.$name.branch" master; fi'
fi

# Continue to run update_submodules.sh.
exit 2
