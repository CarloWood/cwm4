#! /bin/bash

# Colors.
esc=""
reset="$esc[0m"
prefix="$esc[36m*** $reset"
red="$esc[31m"
green="$esc[32m"
orange="$esc[33m"

# Options.
verbose=1
commit=0
quiet_opt=
commit_opt=
while [[ $# -gt 0 ]]
do
  case $1 in
    --quiet)
      verbose=0
      quiet_opt=" --quiet"
      ;;
    --commit)
      commit=1
      commit_opt=" --commit"
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

# Arguments.
name="$1"
path="$2"
sha1="$3"
toplevel="$4"
if [ -n "$5" ]; then
  prefix="$esc[36m$5$reset"
fi

# Depth first.
git submodule --quiet foreach "$0$quiet_opt$commit_opt"' $name "$path" $sha1 "$toplevel"'" '$path: '"

#echo "name = $name"
#echo "path = \"$path\""
#echo "sha1 = $sha1"
#echo "toplevel = \"$toplevel\""
# toplevel + path = pwd

function fatal_error()
{
  echo $prefix$red"$@"$reset
  exit 1
}

current_branch="$(git symbolic-ref HEAD 2>/dev/null)"
if [[ $? == 0 ]]; then
  current_branch=${current_branch#refs/heads/}
else
  current_branch="(detached HEAD)"
fi
submodule_branch=$(git config -f "$toplevel/.gitmodules" submodule.$name.branch)

if [ -n "$submodule_branch" ]; then
  show_already=$verbose
  if [ "$submodule_branch" != "$current_branch" ]; then
    git checkout "$submodule_branch" |\
        awk '
          /^(Your branch is up-to-date with|Already on)/ { printf("'"  $green$name: %s$reset"'\n", $0); next }
          /^Your branch is ahead of/ { printf("'"  $orange$name: %s$reset"'\n", $0); next }
          /use "git push" to publish your local commits/ { next }
          { printf("'"  $red$name: %s$reset"'\n", $0) }' || fatal_error "git checkout \"$submodule_branch\" failed?"
    show_already=0
  fi
  read left_count right_count < <(git rev-list --count --left-right @...@{u})
  if [ $right_count -ne 0 ]; then
    test $commit -eq 0 || fatal_error "Can fast forward while --commit is given?!"
    test $left_count -eq 0 || fatal_error "Can not fast forward $path."
    echo "$prefix$orange""Fast forwarding $submodule_branch of $path $right_count commits...$reset"
    git merge --ff-only || fatal_error "git merge --ff-only failed!"
  elif [ $show_already -eq 1 ]; then
    echo "$prefix$green""Submodule $name is already on branch $current_branch.$reset"
  fi
  if [ $commit -ne 0 -a "$(git rev-parse HEAD)" != "$sha1" ]; then
    # Update the parent project to point to the head of this branch.
    git -C "$toplevel" commit -m "Updating gitlink $path to point to current HEAD of $submodule_branch branch." -o -- "$path" |\
        awk '
          /Updating gitlink/ { printf("'"$prefix$orange%s$reset"'\n", $0) }' || fatal_error "git -C \"$toplevel\" commit -m \"Updating gitlink $path to point to current HEAD of $submodule_branch branch.\" -o -- \"$path\" failed?"
  fi
elif test $(git rev-parse HEAD) != "$sha1"; then
  # No submodule.$name.branch for this submodule. Just checkout the detached HEAD.
  echo "$prefix$name: Running 'git checkout $sha1'"
  git checkout $sha1
elif [ $verbose -eq 1 ]; then
  echo "$prefix$green""Submodule $name is already on detached HEAD $sha1.$reset"
fi
