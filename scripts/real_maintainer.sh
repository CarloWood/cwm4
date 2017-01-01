#! /bin/bash

# Only run this script if we are the real maintainer of this project (the owner of the git repository that contains the autogen.sh file).
if test "$(echo $GIT_COMMITTER_EMAIL | md5sum | cut -d \  -f 1)" = "$1"; then
  # Colors.
  esc=""
  reset="$esc""[0m"
  prefix="$esc""[36m***""$reset"
  ok="$esc[32m"
  red="$esc[31m"
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
    echo "$prefix $red""cwm4 is not up-to-date$reset, will rerun this script after updating."
    git checkout $CWM4_BRANCH && git pull --ff-only || exit 1
    # Run the (possibly updated) script again...
    popd >/dev/null
    echo "Restarting $0 script..."
    exec "$0" "$1"
    exit $?
  fi
  popd >/dev/null

  echo "$prefix Updating the projects autogen.sh..."
  # Get the trailing 'AccountName/projectname.git' of the upstream fetch url of branch master:
  MASTER_REMOTE=$(git config branch.master.remote)
  if test -z "$MASTER_REMOTE"; then
    REPO_NAME=$(basename $(pwd))
    echo "Fatal error: branch master does not have a remote set."
    echo "Make sure you created the repository $REPO_NAME on github and issued the commands"
    echo "under '…or push an existing repository from the command line'"
    echo "That is: create the remote REMOTE (ie, origin) and then issue the command:"
    echo "git push -u REMOTE master"
    exit 1
  fi
  PROJECT_URL="$(git config remote.$MASTER_REMOTE.url | sed -e 's%.*[^A-Za-z]\([^/ ]*/[^/ ]*$\)%\1%')"
  echo "  $prefix PROJECT_URL = \"$PROJECT_URL\""
  NEW_MD5=$(sed -e "s%@PROJECT_URL@%$PROJECT_URL%" cwm4/templates/autogen.sh | md5sum)
  OLD_MD5=$(cat autogen.sh | md5sum)
  if test "$OLD_MD5" = "$NEW_MD5"; then
    echo "  $prefix $ok""Already up-to-date.""$reset"
  else
    sed -e "s%@PROJECT_URL@%$PROJECT_URL%" cwm4/templates/autogen.sh > autogen.sh
    echo "  $prefix $red""autogen.sh changed!""$reset"" Running the new script..."
    exec ./autogen.sh
    exit 0
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
      echo -e "\n$prefix $red""Updating cwm4 to its current branch $CWM4_BRANCH!$reset"
      git add cwm4 && git commit -m 'Automatic commit of update of submodule cwm4'
    elif test x"$(git rev-parse --abbrev-ref HEAD)" != x"$CWM4_BRANCH"; then
      echo -e "\n$prefix $red""Please checkout $CWM4_BRANCH in cwm4 and add it to the current project!$reset"
    fi
  fi
  echo -e "\n$prefix Updating all submodules (recursively)..."
fi

# Update all submodules.
if ! cwm4/scripts/update_submodules.sh --recursive; then
  echo "autogen.sh: Failed to update one or more submodules. Does it have uncommitted changes?"
  exit 1
fi

# Generate submodules.m4.
git submodule foreach -q --recursive 'test "$name" = "cwm4" || echo "CW_SUBMODULE([$path])"' > submodules.m4
cat >> submodules.m4 << EOF
AC_SUBST([CW_SUBDIRS], "CW_SUBMODULE_SUBDIRS")
AM_SUBST_NOTMAKE([CW_SUBDIRS])
AC_CONFIG_FILES(CW_SUBMODULE_CONFIG_FILES)
EOF

# Continue to run bootstrap.sh.
exit 2
