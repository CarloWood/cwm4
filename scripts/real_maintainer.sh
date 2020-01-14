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
    echo -e "\n$prefix $red""Committing all changes in cwm4!$reset"
    git --no-pager diff
    git commit -a -m 'Automatic commit of changes by autogen.sh.'
  fi
  CWM4COMMIT=$(git rev-parse HEAD)
  cd ..
  CWM4HASH=$(git ls-tree HEAD | grep '[[:space:]]cwm4$' | awk '{ print $3 }')
  if test "$CWM4HASH" != "$CWM4COMMIT"; then
    if git diff-index --quiet --cached HEAD; then
      echo -e "\n$prefix $red""Updating gitlink cwm4 to current $CWM4_BRANCH branch!$reset"
      git commit -m "Updating gitlink cwm4 to point to current HEAD of $CWM4_BRANCH branch." -o -- cwm4
    elif test x"$(git rev-parse --abbrev-ref HEAD)" != x"$CWM4_BRANCH"; then
      echo -e "\n$prefix $red""Please checkout $CWM4_BRANCH in cwm4 and add it to the current project!$reset"
    fi
  fi

  if test -e configure.ac; then
    # Is OUTPUT_DIRECTORY set?
    if m4 -P cwm4/sugar.m4 configure.ac | egrep '^[[:space:]]*CW_DOXYGEN' >/dev/null; then
      if test -z "$OUTPUT_DIRECTORY"; then
        echo "Error: the environment variable OUTPUT_DIRECTORY is not set."
        exit 1
      fi
    fi
  fi

  # Do we have a .gitignore?
  if ! test -f .gitignore; then
    echo -e "\n$prefix Adding .gitignore..."
    cp cwm4/templates/dot_gitignore .gitignore
    git add .gitignore
  fi

  echo -e "\n$prefix Updating all submodules (recursively)..."

  # Check if 'branch' is set for all submodules with a configure.m4,
  # and fix the url of remotes when needed.
  git submodule foreach --recursive -q '
      if test -f "configure.m4" -o "$name" = "cwm4"; then
        if ! git config -f $toplevel/.gitmodules submodule.$name.branch >/dev/null; then
          echo "  $name: '"$red"'Setting submodule.$name.branch to master!'"$reset"'"
          git config -f $toplevel/.gitmodules "submodule.$name.branch" master
        fi
        BRANCH=$(git config -f $toplevel/.gitmodules submodule.$name.branch)
        REMOTE=$(git config branch.$BRANCH.remote)
        if test -n "$GITHUB_REMOTE_NAME" -a x"$REMOTE" != x"$GITHUB_REMOTE_NAME"; then
          echo "  $name: '"$red"'Renaming remote from $REMOTE to $GITHUB_REMOTE_NAME!'"$reset"'"
          git remote rename $REMOTE $GITHUB_REMOTE_NAME
          REMOTE=$GITHUB_REMOTE_NAME
        fi
        if test -n "$GITHUB_URL_PREFIX"; then
          URL=$(git config remote.$REMOTE.url)
          PART=$(echo "$URL" | grep -o '"'"'[^/:]*$'"'"')
          NEWURL="$GITHUB_URL_PREFIX$PART"
          if test "$URL" != "$NEWURL"; then
            echo "  $name: '"$red"'Changing url of remote to $NEWURL!'"$reset"'"
            git remote set-url $REMOTE "$NEWURL"
          fi
        fi
      fi'

  # Update all submodules. update_submodule.sh doesn't access the remote, so we need to fetch first.
  echo "*** Fetching new commits..."
  git fetch --jobs=8 --recurse-submodules-default=yes
  echo "*** Doing fast-forward on branched submodules..."
  if ! git submodule --quiet foreach "$(realpath cwm4/scripts/update_submodule.sh)"' $name "$path" $sha1 "$toplevel"'; then
    echo "autogen.sh: Failed to update one or more submodules. Does it have uncommitted changes?"
    exit 1
  fi
  echo "*** Updating submodule gitlinks..."
  if ! git submodule --quiet foreach "$(realpath cwm4/scripts/update_submodule.sh)"' --quiet --commit $name "$path" $sha1 "$toplevel"'; then
    echo "autogen.sh: Failed to update one or more submodules. Does it have uncommitted changes?"
    exit 1
  fi
  echo "*** Updating SHA1's in CMakeLists.txt..."
  # Update the SHA1 of hunter in the root CMakeLists.txt.
  GATE_SHA1=$(git ls-remote --quiet --refs --heads https://github.com/CarloWood/gate.git master | cut -f 1)
  HUNTER_SHA1=$(git ls-remote --quiet --refs --heads https://github.com/CarloWood/hunter.git master | cut -f 1)
  CURRENT_GATE_SHA1=$(awk '/GIT_TAG[[:space:]"]+[0-9a-f]{40}.*Gate/ { match($0, /.*GIT_TAG[[:space:]"]+([0-9a-f]{40})/, arr); print arr[1] }' CMakeLists.txt)
  CURRENT_HUNTER_SHA1=$(awk '/SHA1[[:space:]"]+[0-9a-f]{40}.*Hunter/ { match($0, /.*SHA1[[:space:]"]+([0-9a-f]{40})/, arr); print arr[1] }' CMakeLists.txt)
  if [ "$CURRENT_GATE_SHA1" != "$GATE_SHA1" -o "$CURRENT_HUNTER_SHA1" != "$HUNTER_SHA1" ]; then
    sed -r -i -e 's/(.*GIT_TAG.*)([0-9a-f]{40})(.*Gate.*)/\1'$GATE_SHA1'\3/;s/(.*SHA1.*)([0-9a-f]{40})(.*Hunter.*)/\1'$HUNTER_SHA1'\3/' CMakeLists.txt
    git commit -m 'Update of sha1 of hunter/gate repositories.' -- CMakeLists.txt
  fi
fi

# Continue to run update_submodule.sh in each submodule.
exit 2
