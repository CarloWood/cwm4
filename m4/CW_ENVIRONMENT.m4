# CW_ENVIRONMENT m4 macro -- this file is part of cwautomacros.
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

dnl CW_ENVIRONMENT
dnl Load environment from cache (if it exists, otherwise use the current environment)
dnl when invoked as config.status --recheck.  Always let CXX and CXXCPP override cached
dnl values.
AC_DEFUN([CW_ENVIRONMENT],
[if test -f "$cache_file" -a x"$no_create" = xyes -a x"$no_recursion" = xyes; then
  eval "CPPFLAGS=\"$cw_cv_sys_CPPFLAGS\""
  eval "CXXFLAGS=\"$cw_cv_sys_CXXFLAGS\""
  eval "LDFLAGS=\"$cw_cv_sys_LDFLAGS\""
  eval "LIBS=\"$cw_cv_sys_LIBS\""
fi
if test x"$CXX" != "x" -o x"$CXXCPP" != "x"; then
  unset ac_cv_prog_CXX
  unset ac_cv_prog_CXXCPP
  unset ac_cv_prog_cxx_cross
  unset ac_cv_prog_cxx_works
  unset ac_cv_prog_gxx
  unset ac_cv_prog_gxx_version
fi
if test x"$CC" != "x" -o x"$CPP" != "x"; then
  unset ac_cv_prog_CC
  unset ac_cv_prog_CPP
  unset ac_cv_prog_cc_cross
  unset ac_cv_prog_g
  unset ac_cv_prog_cc_works
  unset ac_cv_prog_gcc
fi
])
