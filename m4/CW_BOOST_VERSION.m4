# CW_BOOST_VERSION m4 macro -- this file is part of cwautomacros.
# Copyright (C) 2006, 2011, 2014 Carlo Wood <carlo@alinoe.com>
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

# CW_BOOST_VERSION
# ----------------
#
# If the environment variable BOOST_VERSION is not already
# set, then set it to the highest version of any found boost
# library in BOOST_ROOT.
AC_DEFUN([CW_BOOST_VERSION],
[dnl
AC_REQUIRE([CW_BOOST_ROOT])
# Use environment variable over cached value.
test -z "$BOOST_VERSION" || unset cw_cv_lib_boost_version
AC_CACHE_CHECK([for boost version], [cw_cv_lib_boost_version],
[dnl
cw_cv_lib_boost_version=none
# Use the environment variable BOOST_VERSION when already set to a sane value.
cw_cv_lib_boost_version="`echo "$BOOST_VERSION" | grep '^[[1-9]][[0-9]]*[[._]][[0-9]][[0-9]]*$'`"
if test -z "$cw_cv_lib_boost_version" -a -n "$BOOST_ROOT"; then
  cw_cv_lib_boost_version="`ls -l "$BOOST_ROOT"/lib$cw_boost_build/libboost*.so 2>/dev/null | \
    egrep '\.so\.[[0-9]]+\.[[0-9]]+(\.[[0-9]]+)?$' |
    sed -e 's/.*\.so\.\([[0-9]]*\.[[0-9]]*\)\.[[0-9]]*$/\1/' \
        -e 's/.*\.so\.\([[0-9]]*\.[[0-9]]*\)$/\1/' | \
    sort -nu | tail -n 1 | sed -e 's/.* //'`"
  if test -z "$cw_cv_lib_boost_version"; then
    dnl The double [[...]] below are needed to escape m4, it will result in [...] in the configure script.
    cw_cv_lib_boost_version="`ls "$BOOST_ROOT"/lib$cw_boost_build/libboost* 2>/dev/null | \
	egrep '.*(-[[0-9_]]*\.(so$|so\.|a$|dll$|lib$)|\.so\.[[0-9]]+\.[[0-9]]+(\.[[0-9]]+)?$)' | \
	sed -e 's/.*-\([[0-9_]]*\)\.so$/\1/' \
	    -e 's/.*-\([[0-9_]]*\)\.so\..*/\1/' \
	    -e 's/.*-\([[0-9_]]*\)\.a$/\1/' \
	    -e 's/.*-\([[0-9_]]*\)\.dll$/\1/' \
	    -e 's/.*-\([[0-9_]]*\)\.lib$/\1/' \
	    -e 's/.*\.so\.\([[0-9]]*\.[[0-9]]*\)\.[[0-9]]*$/\1/' \
	    -e 's/.*\.so\.\([[0-9]]*\.[[0-9]]*\)$/\1/' \
	    -e 's/\([[0-9]]\)*\([[._]]\)\([[0-9]]*\)/\1_\3 \1\2\3/' \
	    -e 's/_/_000/' -e 's/_[[0-9]]*\(....\) /_\1 /' \
	    -e 's/_/./' | \
	sort -nu | tail -n 1 | sed -e 's/.* //'`"
  fi
fi
])
if test "$cw_cv_lib_boost_version" = "none"; then
  unset BOOST_VERSION
else
  BOOST_VERSION="$cw_cv_lib_boost_version"
fi
])
