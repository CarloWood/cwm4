#! /bin/bash

# Colors.
esc=""
reset="$esc""[0m"
prefix="$esc""[36m***""$reset"
red="$esc[31m"
green="$esc[32m"
orange="$esc[33m"

# Arguments.
name="$1"
path="$2"
sha1="$3"
toplevel="$4"

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
  if [ "$submodule_branch" != "$current_branch" ]; then
    git checkout "$submodule_branch" |\
        awk '
          /^(Your branch is up-to-date with|Already on)/ { printf("'"  $green%s$reset"'\n", $0); next }
          /^Your branch is ahead of/ { printf("'"  $orange%s$reset"'\n", $0); next }
          /use "git push" to publish your local commits/ { next }
          { printf("'"  $red%s$reset"'\n", $0) }' || exit 1
    read left_count right_count < <(git rev-list --count --left-right @...@{u})
    if [ $right_count -ne 0 ]; then
      test $left_count -eq 0 || exit 1 # We can't fast forward.
      echo "  Fast forwarning $right_count commits..."
      git merge --ff-only || exit 1
    fi
    if [ "$(git rev-parse HEAD)" != "$sha1" ]; then
      # Update the parent project to point to the head of this branch.
      git -C "$toplevel" commit -m "Updating gitlink $path to point to current $submodule_branch branch." -o -- "$path"
    fi
  else
    echo "  $green""Already on branch $current_branch.$reset"
  fi
elif test $(git rev-parse HEAD) != "$sha1"; then
  # No submodule.$name.branch for this submodule. Just checkout the detached HEAD.
  echo "$name: Running 'git checkout $sha1'"
  git checkout $sha1
else
  echo "  $green""Already on detached HEAD $sha1.$reset"
fi
