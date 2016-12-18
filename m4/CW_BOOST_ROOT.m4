# CW_BOOST_ROOT m4 macro -- this file is part of cwautomacros.
# Copyright (C) 2006, 2014 Carlo Wood <carlo@alinoe.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.
#
# As a special exception, the author gives unlimited permission to copy,
# distribute and modify the configure scripts that are the output of
# by a tool like autoconf when using these macros as input.  You need
# not follow the terms of the GNU General Public License when using or
# distributing such scripts, even though portions of the text of this
# file appears in them. The GNU General Public License (GPL) does govern
# all other use of the material that constitutes the cwautomacros project.

# CW_BOOST_ROOT([BOOST_ROOT])
# ---------------------------
#
# This macro detects if boost is installed
# and sets HAVE_BOOST if appropriate.
#
# The optional BOOST_ROOT is where boost
# was installed.  When not given then
# the variable BOOST_ROOT is set to where
# boost was installed.
#
# BOOST_VERSION is set to the (latest) version
# that was installed there.
AC_DEFUN([CW_BOOST_ROOT],
[dnl
# Use environment variable or configure option over cached value.
test -z "$BOOST_ROOT" -a -z "$1" || unset cw_cv_lib_boost_root
AC_CACHE_CHECK([for boost install root], [cw_cv_lib_boost_root],
[dnl
cw_cv_lib_boost_root="not found"
# This is a dummy version, any version we find will be larger.
cw_version=0_0000
# Test if the BOOST_ROOT is not already given.
if test -n "$1"; then
  # Use the parameter that was passed.
  cw_cv_lib_boost_root="$1"
else
  # If not given as parameter, then test if the environment variable itself is already set.
  if test -n "$BOOST_ROOT"; then
    cw_cv_lib_boost_root="$BOOST_ROOT"
  else
    # No luck so far, lets catenate all possible paths together in the right order.
    if expr match "$build_os" ".*-mingw32$" >/dev/null ||
       expr match "$build_os" ".*-cygwin" >/dev/null
    then
      # Windows (cygwin and mingw32) demand that all dll's are in PATH or the current directory.
      cw_library_path="$PATH:."
    else
      cw_library_path="`echo $LD_LIBRARY_PATH | sed -e 's/^://;s/:://g;s/:$//'`"
      if test -f "/etc/ld.so.conf"; then
        cw_ld_so_conf_file_patterns="`egrep '^[[[:space:]]]*include[[[:space:]]]' /etc/ld.so.conf | sed -r -e 's/^[[[:space:]]]*include[[[:space:]]]+//;s/[[[:space:]]]*//g'`"
        cw_ld_so_conf_files="/etc/ld.so.conf `ls $cw_ld_so_conf_file_patterns`"
	cw_library_path="$cw_library_path`cat $cw_ld_so_conf_files 2>/dev/null | \
	    sed -r -e 's/^[[[:space:]]]*include[[[:space:]]]+.*//;s/#.*//' -e 's/[[:space:]]*//g' -e 's/=[^=]*$//' | \
	    grep -v '^$' | awk '{ printf("%s%s", "'$PATH_SEPARATOR'", $''1); }'`"
      fi
      cw_library_path="$cw_library_path$PATH_SEPARATOR/lib$PATH_SEPARATOR/usr/lib"
    fi
    # Now run over all paths and look for a directory with boost libraries in it.
    cw_boost_build="/$ac_build_alias"
    while test "$cw_version" = "0_0000" -a -n "$cw_boost_build"; do
    cw_save_IFS=$IFS; IFS=$PATH_SEPARATOR
    for d in $cw_library_path
    do
      IFS=$cw_save_IFS
      if test -d "$d"; then
	# Only consider directories that end in '/lib'.
	# We use `expr' here and not `case in', because the latter doesn't match spaces,
	# and this macro needs to work for directory names that contain spaces too.
	if expr match "$d" '.*/lib$' >/dev/null; then
	  cw_possible_root="`echo "$d" | sed -e 's%/lib$%%'`"	# Strip off the '/lib'.
	  # This magic gets a lists of all versions, and filters out the highest version of that.
	  # The number behind the underscore is prepended with zeroes to a total length of four digits however.
	  dnl The double [[...]] below are needed to escape m4, it will result in [...] in the configure script.
	  cw_possible_version_set="`ls "$cw_possible_root"/lib$cw_boost_build/libboost* 2>/dev/null | \
	      egrep '.*(-[[0-9_]]*\.(so$|so\.|a$|dll$|lib$)|\.so\.[[0-9]]+\.[[0-9]]+(\.[[0-9]]+)?$)' | \
	      sed -e 's/.*-\([[0-9_]]*\)\.so$/\1/' \
	          -e 's/.*-\([[0-9_]]*\)\.so\..*/\1/' \
	          -e 's/.*-\([[0-9_]]*\)\.a$/\1/' \
	          -e 's/.*-\([[0-9_]]*\)\.dll$/\1/' \
	          -e 's/.*-\([[0-9_]]*\)\.lib$/\1/' \
		  -e 's/.*\.so\.\([[0-9]]*\.[[0-9]]*\)\.[[0-9]]*$/\1/' \
		  -e 's/.*\.so\.\([[0-9]]*\.[[0-9]]*\)$/\1/' \
		  -e 's/\([[0-9]]\)*\([[._]]\)\([[0-9]]*\)/\1_\3 \1\2\3/' \
	          -e 's/_/_000/' -e 's/_[[0-9]]*\(....\) /_\1 /' | \
	      sort -nu | tail -n 1`"
	  cw_possible_version="`echo $cw_possible_version_set | sed -e 's/ .*//'`"
	  # If we found a newer version, then store the results.
          if test -n "$cw_possible_version" && expr "$cw_possible_version" \> "$cw_version" >/dev/null; then
	    cw_version="$cw_possible_version"
	    cw_cv_lib_boost_root="$cw_possible_root"
	    cw_version_str="`echo $cw_possible_version_set | sed -e 's/.* //'`"
	  fi
	elif expr match "$d" '.*boost.*' >/dev/null; then
	  # This catches the case where LD_LIBRARY_PATH would contain the BOOST_ROOT instead of the lib dir.
]dnl
	  AC_MSG_WARN([\"$d\" doesn't end in \"/lib\".])
[dnl
	fi
      fi
    done
    if test "$cw_version" = "0_0000"; then
      if expr match "$cw_boost_build" '.*-unknown-.*' >/dev/null; then
        cw_boost_build="`echo $cw_boost_build | sed -e 's/-unknown//'`"
      else
        cw_boost_build=
      fi
    fi
    done
  fi
fi
])
if test "$cw_cv_lib_boost_root" = "not found"; then
  unset BOOST_ROOT
else
  BOOST_ROOT="$cw_cv_lib_boost_root"
fi
])
