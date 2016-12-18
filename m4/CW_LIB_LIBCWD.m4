# CW_LIB_LIBCWD m4 macro -- this file is part of cwautomacros.
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

# CW_LIB_LIBCWD(OPTIONNAME, WANTED, THREADED,
#               [ACTION_IF_FOUND], [ACTION-IF-NOT-FOUND])
# -------------------------------------------
#
# OPTIONNAME is the name used in AC_ARG_ENABLE that requests
# libcwd support.
#
# WANTED can be [yes], [no] or [auto]/[] and should be the result
# of use --enable-OPTIONNAME, --disable-OPTIONNAME or neither.
# For example:
# AC_ARG_ENABLE(debugging, [  --enable-debugging      enable debugging code.])
# Where OPTIONNAME is [debugging] and WANTED is [$enable_debugging].
#
# THREADED can be [yes], [no] or [both] when the application is
# threaded, non-threaded or when both are needed respectively.
# If THREADED is set to [both] then CWD_FLAGS and CWD_LIBS
# are set as appropriate for the non-threaded case and
# CWD_R_FLAGS and CWD_R_LIBS are set as appropriate for
# the threaded case.
#
# This macro tests for the usability of libcwd and sets the macro
# `cw_used_libcwd' to "yes" when it is detected, "no" otherwise.
#
# The default ACTION_IF_FOUND is, if WANTED is unequal "no",
# to set CWD_FLAGS and CWD_LIBS.
#
# The default ACTION-IF-NOT-FOUND is to print an error message;
# ACTION-IF-NOT-FOUND is only executed when WANTED is "yes" and no
# libcwd was found.

AC_DEFUN([CW_LIB_LIBCWD],
[cw_wanted=$2
if test x"$cw_wanted" = x"no"; then
  cw_used_libcwd=no
else
  cw_libname=cwd
  test "$3" = "yes" && cw_libname=cwd_r
  AC_CACHE_CHECK([if libcwd is available], cw_cv_lib_libcwd,
[  # Check if we have libcwd
  AC_LANG_SAVE
  AC_LANG_CPLUSPLUS
  cw_save_LIBS="$LIBS"
  LIBS="$LIBS `pkg-config --libs lib$cw_libname`"
  AC_LINK_IFELSE([AC_LANG_CALL([], [__libcwd_version])], [cw_cv_lib_libcwd=yes], [cw_cv_lib_libcwd=no])
  LIBS="$cw_save_LIBS"
  AC_LANG_RESTORE])
  if test "$3" = "both"; then
    AC_CACHE_CHECK([if libcwd_r is available], cw_cv_lib_libcwd_r,
[    # Check if we have libcwd_r
    AC_LANG_SAVE
    AC_LANG_CPLUSPLUS
    cw_save_LIBS="$LIBS"
    LIBS="$LIBS `pkg-config --libs libcwd_r`"
    AC_LINK_IFELSE([AC_LANG_CALL([], [__libcwd_version])], [cw_cv_lib_libcwd_r=yes], [cw_cv_lib_libcwd_r=no])
    LIBS="$cw_save_LIBS"
    AC_LANG_RESTORE])
  fi
  cw_use_libcwd="$cw_wanted"
  test -n "$cw_use_libcwd" || cw_use_libcwd=auto
  test "$cw_use_libcwd" = "auto" && cw_use_libcwd=$cw_cv_lib_libcwd
  if test "$cw_use_libcwd" = "yes"; then
    if test "$cw_cv_lib_libcwd" = "no" -o "$3" = "both" -a x"$cw_cv_lib_libcwd_r" = x"no"; then
      m4_default([$5], [dnl
      AC_MSG_ERROR([
  --enable-$1: You need to have libcwd installed to enable this.
  Or perhaps you need to add its location to PKG_CONFIG_PATH and LD_LIBRARY_PATH, for example:
  PKG_CONFIG_PATH=/opt/install/lib/pkgconfig LD_LIBRARY_PATH=/opt/install/lib ./configure])])
    else
      cw_used_libcwd=yes
      if test "$3" = "both"; then
	m4_default([$4], [dnl
	CWD_FLAGS="`pkg-config --cflags libcwd`"
	CWD_LIBS="`pkg-config --libs libcwd`"
	CWD_R_FLAGS="`pkg-config --cflags libcwd_r`"
	CWD_R_LIBS="`pkg-config --libs libcwd_r`"])
	AC_SUBST(CWD_R_FLAGS)
	AC_SUBST(CWD_R_LIBS)
      else
	m4_default([$4], [dnl
	CWD_FLAGS="`pkg-config --cflags lib$cw_libname`"
	CWD_LIBS="`pkg-config --libs lib$cw_libname`"])
      fi
      AC_SUBST(CWD_FLAGS)
      AC_SUBST(CWD_LIBS)
    fi
  else
    cw_used_libcwd=no
  fi
fi
])

