#! /bin/bash

# Colors.
esc=""
reset="$esc[0m"
prefix="$esc[36m*** $reset"
red="$esc[31m"
green="$esc[32m"
orange="$esc[33m"

# Arguments.
name="$1"
path="$2"
sha1="$3"
toplevel="$4"
if [ -n "$5" ]; then
  prefix="$esc[36m$5$reset"
fi

# Depth first.
git submodule foreach "$0"' $name "$path" $sha1 "$toplevel"'" '$path: '"

#echo "name = $name"
#echo "path = \"$path\""
#echo "sha1 = $sha1"
#echo "toplevel = \"$toplevel\""
# toplevel + path = pwd

current_branch="$(git symbolic-ref HEAD 2>/dev/null)"
if [[ $? == 0 ]]; then
  current_branch=${current_branch#refs/heads/}
else
  current_branch="(detached HEAD)"
fi
submodule_branch=$(git config -f "$toplevel/.gitmodules" submodule.$name.branch)

if [ -n "$submodule_branch" ]; then
  show_already=1
  if [ "$submodule_branch" != "$current_branch" ]; then
    git checkout "$submodule_branch" |\
        awk '
          /^(Your branch is up-to-date with|Already on)/ { printf("'"  $green$name: %s$reset"'\n", $0); next }
          /^Your branch is ahead of/ { printf("'"  $orange$name: %s$reset"'\n", $0); next }
          /use "git push" to publish your local commits/ { next }
          { printf("'"  $red$name: %s$reset"'\n", $0) }' || exit 1
    show_already=0
  fi
  read left_count right_count < <(git rev-list --count --left-right @...@{u})
  if [ $right_count -ne 0 ]; then
    test $left_count -eq 0 || exit 1 # We can't fast forward.
    echo "$prefix$orange""Fast forwarding $submodule_branch of $path $right_count commits...$reset"
    git merge --ff-only || exit 1
  elif [ $show_already -eq 1 ]; then
    echo "$prefix$green""Submodule $name is already on branch $current_branch.$reset"
  fi
  if [ "$(git rev-parse HEAD)" != "$sha1" ]; then
    # Update the parent project to point to the head of this branch.
    git -C "$toplevel" commit -m "Updating gitlink $path to point to current $submodule_branch branch." -o -- "$path" |\
        awk '
          /Updating gitlink/ { printf("'"$prefix$orange%s$reset"'\n", $0) }' || exit 1
  fi
elif test $(git rev-parse HEAD) != "$sha1"; then
  # No submodule.$name.branch for this submodule. Just checkout the detached HEAD.
  echo "$prefix$name: Running 'git checkout $sha1'"
  git checkout $sha1
else
  echo "$prefix$green""Submodule $name is already on detached HEAD $sha1.$reset"
fi
