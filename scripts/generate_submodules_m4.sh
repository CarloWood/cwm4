#! /bin/bash
# Written by Carlo Wood 2017

# Parse command line parameters.
opt_foreach=0
while [[ $# -gt 0 ]]
do
  case $1 in
    --foreach)
      opt_foreach=1
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

if test "$opt_foreach" -eq 0; then
  mkdir -p m4
  echo "# This file is automatically generated by autogen.sh. Any changes will be overwritten!" > m4/submodules.m4
  #echo "m4_define([CW_SUBMODULE_SUBDIRS], [])" >> m4/submodules.m4
  git submodule foreach --quiet --recursive "$FULL_PATH --foreach"' $path' >> m4/submodules.m4
  test $? -eq 0 || exit 1
  if test $(wc --lines < m4/submodules.m4) -gt 1; then
    cat << EOF >> m4/submodules.m4

AC_SUBST([CW_SUBDIRS], CW_SUBMODULE_SUBDIRS)
#AM_SUBST_NOTMAKE([CW_SUBDIRS])
AC_CONFIG_FILES(CW_SUBMODULE_CONFIG_FILES)
EOF
  else
    cat << EOF >> m4/submodules.m4

AC_SUBST([CW_SUBDIRS], [])
#AM_SUBST_NOTMAKE([CW_SUBDIRS])
EOF
  fi
elif test "$1" != "cwm4"; then
  # Script is called from git submodule foreach ...'
  submodule_path="$1"
  submodule_dirname="$(dirname "$submodule_path")"
  submodule_basename="$(basename "$submodule_path")"
  test "$submodule_dirname" != "." || submodule_dirname=""

  if test "$submodule_basename" = "cwds" -a -n "$submodule_dirname"; then
    echo 'ERROR: git submodule cwds must sit in the root of the project, not in `'"$submodule_dirname'." >&2
    exit 1
  fi

  echo
  echo "m4_define([cwm4_submodule_path], [$submodule_path])"
  echo "m4_define([cwm4_submodule_dirname], [$submodule_dirname])"
  echo "m4_define([cwm4_submodule_basename], [$submodule_basename])"
  echo "m4_include([${submodule_path}/configure.m4])"
fi
