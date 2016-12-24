#! /bin/sh

# Only run this script if we are the real maintainer of this project (the owner of the git repository that contains the autogen.sh file).
if test "$(echo $GIT_COMMITTER_EMAIL | md5sum | cut -d \  -f 1)" = "$1"; then
  esc=""
  reset="$esc""[0m"
  prefix="$esc""[36m***""$reset"
  ok="$esc[32m"
  red="$esc[31m"
  orange="$esc[33m"
  echo "Hi $GIT_COMMITTER_NAME, how are you today?"
  # Is cwm4 on master already?
  cd cwm4 || exit 1
  if test x"$(git rev-parse --abbrev-ref HEAD)" != x"master"; then
    echo "$prefix $red""cwm4 is not up-to-date$reset, will rerun this script after updating."
    git checkout master && git pull --ff-only || exit 1
    # Run the (possibly updated) script again...
    cd ..
    echo "$prefix $red""Please 'git add cwm4' and commit.$reset"
    echo "Rerunning $0 $1..."
    exec "$0" "$1"
    exit $?
  fi
  cd ..
  echo "$prefix Updating the projects autogen.sh..."
  # Get the trailing 'AccountName/projectname.git' of the upstream fetch url of branch master:
  PROJECT_URL="$(git config remote.$(git config branch.master.remote).url | sed -e 's%.*[^A-Za-z]\([^/ ]*/[^/ ]*$\)%\1%')"
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
    echo "\n$prefix $red""Automatically committing uncommitted changes in cwm4!$reset"
    git commit -a -m 'Automatic commit of changes by autogen.sh.'
  fi
  CWM4COMMIT=$(git rev-parse HEAD)
  cd ..
  CWM4HASH=$(git ls-tree HEAD | grep '[[:space:]]cwm4$' | awk '{ print $3 }')
  if test "$CWM4HASH" != "$CWM4COMMIT"; then
    if git diff-index --quiet --cached HEAD; then
      echo "\n$prefix $red""Updating cwm4 to its current master!$reset"
      git add cwm4 && git commit -m 'Automatic commit of update of submodule cwm4'
    else
      echo "\n$prefix $red""Please checkout master in cwm4 and add it to the current project!$reset"
    fi
  fi
  echo "\n$prefix Fetching all submodules (recursively)..."
  git submodule foreach --recursive 'git fetch $(git config branch.master.remote)' | awk '
      /^Entering / { printf("'$orange'%s'$reset'\n", $0); next }
      { print }' || exit 1
  echo "\n$prefix Checking out master for each submodule..."
  git submodule foreach 'git checkout master' 2>&1 | awk '
      /use "git push" to publish your local commits/ { next }
      /^Entering / { printf("'$orange'%s'$reset'\n", $0); next }
      /^(Already on|Your branch is up-to-date with)/ { printf("'$ok'%s'$reset'\n", $0); next }
      /^(M|Your branch is ahead of)/ { printf("'$red'%s'$reset'\n", $0); next }
      { print }' || exit 1
  echo "\n$prefix Fast-forwarding submodules..."
  git submodule foreach 'git merge --ff-only' 2>&1 | awk '
      /^Entering / { printf("'$orange'%s'$reset'\n", $0); next }
      /^Already up-to-date/ { printf("'$ok'%s'$reset'\n", $0); next }
      { print }' || exit 1
  echo "\n$prefix Updating submodules (recursively) inside submodules..."
  git submodule foreach 'git submodule update --recursive' | awk '
      /^Entering / { printf("'$orange'%s'$reset'\n", $0); next }
      { print }' || exit 1
  echo
fi
exit 2
