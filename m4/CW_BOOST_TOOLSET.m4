# CW_BOOST_TOOLSET m4 macro -- this file is part of cwautomacros.
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

# CW_BOOST_TOOLSET([BOOST_TOOLSET])
# ---------------------------------
#
# If the environment variable BOOST_TOOLSET is not already
# set, then set it to the toolset of the libraries that we
# found in BOOST_ROOT.
AC_DEFUN([CW_BOOST_TOOLSET],
[dnl
AC_REQUIRE([CW_BOOST_VERSION])
# Use environment variable or configure option over cached value.
test -z "$BOOST_TOOLSET" -a -z "$1" || unset cw_cv_lib_boost_toolset
AC_CACHE_CHECK([for boost toolset], [cw_cv_lib_boost_toolset],
[dnl
cw_cv_lib_boost_toolset="not found"
# Use the configure option (past as parameter) or the environment
# variable BOOST_TOOLSET when already set.
if test -n "$1"; then
  cw_cv_lib_boost_toolset="$1"
elif test -n "$BOOST_TOOLSET"; then
  cw_cv_lib_boost_toolset="$BOOST_TOOLSET"
fi
# If BOOST_VERSION contains a dot, then there is no toolset given.
if expr match "$BOOST_VERSION" '[[0-9]]*\.[[0-9]]*$' >/dev/null; then
  cw_cv_lib_boost_toolset="none"
elif test "$cw_cv_lib_boost_toolset" = "not found" -a -n "$BOOST_ROOT" -a -n "$BOOST_VERSION"; then
  dnl The double [[...]] below are needed to escape m4, it will result in [...] in the configure script.
  cw_cv_lib_boost_toolset="`ls "$BOOST_ROOT"/lib$cw_boost_build/libboost* 2>/dev/null | \
      egrep '.*-'$BOOST_VERSION'\.(so$|so\.|a$|dll$|lib$)' | \
      sed -r -e 's%.*/libboost_[[^/-]]*-([[^./-]]*).*-'$BOOST_VERSION'\.(so|so\..*|a|dll|lib)$%\1%' | \
      egrep -v '(^mt$|libboost_)' | sort -u`"
  test -n "$cw_cv_lib_boost_toolset" || cw_cv_lib_boost_toolset="none"
fi
])
if test "$cw_cv_lib_boost_toolset" = "not found"; then
  unset BOOST_TOOLSET
else
  BOOST_TOOLSET="$cw_cv_lib_boost_toolset"
  dnl The double [[...]] below are needed to escape m4, it will result in [...] in the configure script.
  if expr `echo "$cw_cv_lib_boost_toolset" | wc -l` \> 1 >/dev/null || \
     expr match "$cw_cv_lib_boost_toolset" '[[^ ]] [[^ ]]' >/dev/null; then
    unset cw_cv_lib_boost_toolset
    AC_MSG_ERROR([Cannot determine toolset, you have more than one installed in $BOOST_ROOT/lib$cw_boost_build!
Please specify the toolset to use with --enable-boost-toolset=toolset])
  fi
fi
])

