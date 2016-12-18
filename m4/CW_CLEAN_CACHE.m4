# CW_CLEAN_CACHE m4 macro -- this file is part of cwautomacros.
# Copyright (C) 2006 Carlo Wood <carlo@alinoe.com>
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

dnl CW_CLEAN_CACHE
AC_DEFUN([CW_CLEAN_CACHE],
[AC_MSG_CHECKING([if we can use cached results for the tests])
CW_PROG_CXX_FINGER_PRINTS
if test "$cw_cv_sys_CXX_finger_print" != "$cw_prog_cxx_finger_print" -o \
        "$cw_cv_sys_CXXCPP_finger_print" != "$cw_prog_cxxcpp_finger_print" -o \
	"$cw_cv_sys_CC_finger_print" != "$cw_prog_cc_finger_print" -o \
        "$cw_cv_sys_CPPFLAGS" != "$CPPFLAGS" -o \
        "$cw_cv_sys_CXXFLAGS" != "$CXXFLAGS" -o \
        "$cw_cv_sys_LDFLAGS" != "$LDFLAGS" -o \
        "$cw_cv_sys_LIBS" != "$LIBS"; then
changequote(<<, >>)dnl
for i in `set | grep -v '^ac_cv_prog_[Ccg][CXx]' | grep '^[a-z]*_cv_' | sed -e 's/=.*$//'`; do
  unset $i
done
changequote([, ])dnl
AC_MSG_RESULT([no])
else
AC_MSG_RESULT([yes])
fi
dnl Store important environment variables in the cache file
cw_cv_sys_CXX_finger_print="$cw_prog_cxx_finger_print"
cw_cv_sys_CXXCPP_finger_print="$cw_prog_cxxcpp_finger_print"
cw_cv_sys_CC_finger_print="$cw_prog_cc_finger_print"
cw_cv_sys_CPPFLAGS="$CPPFLAGS"
cw_cv_sys_CXXFLAGS="$CXXFLAGS"
cw_cv_sys_LDFLAGS="$LDFLAGS"
cw_cv_sys_LIBS="$LIBS"
])
