#! /bin/sh

if test -f .git; then
  echo "Error: don't run $0 inside a submodule. Run it from the parent project's directory."
  exit 1
fi

if test "$(realpath $0)" != "$(realpath $(pwd)/autogen.sh)"; then
  echo "Error: run autogen.sh from the directory it resides in."
  exit 1
fi

if test -d .git; then
  # If this was a clone without --recursive, fix that fact.
  if test ! -e cwm4/scripts/bootstrap.sh; then
    git submodule update --init --recursive
  fi
  # Update autogen.sh and cwm4 itself if we are the real maintainer.
  if test -f cwm4/scripts/real_maintainer.sh; then
    cwm4/scripts/real_maintainer.sh 15014aea5069544f695943cfe3a5348c
    RET=$?
    # A return value of 2 means we need to continue with calling bootstrap.sh.
    # Otherwise, abort/stop returning that value.
    if test $RET -ne 2; then
      echo "Exiting with code $RET"
      exit $RET
    fi
  elif ! cwm4/scripts/update_submodules.sh --recursive; then
    echo "autogen.sh: Failed to update one or more submodules. Does it have uncommitted changes?"
    exit 1
  fi
else
  # Clueless user check.
  if test -f configure; then
    echo "You only need to run './autogen.sh' when you checked out this project from the git repository."
    echo "Just run ./configure [--help]."
    if test -e cwm4/scripts/bootstrap.sh; then
      echo "If you insist on running it and know what you are doing, then first remove the 'configure' script."
    fi
    exit 0
  elif test ! -e cwm4/scripts/bootstrap.sh; then
    echo "Houston, we have a problem: the cwm4 git submodule is missing from your source tree!?"
    echo "I'd suggest to clone the source code of this project from github:"
    echo "git clone --recursive https://github.com/@PROJECT_URL@"
    exit 1
  fi
fi

# Run the autotool commands.
exec cwm4/scripts/bootstrap.sh
