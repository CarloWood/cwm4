# CW_LIB_LIBCAIRO m4 macro -- this file is part of cwm4.
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
# all other use of the material that constitutes the cwm4 project.

# CW_LIB_LIBCAIRO([ACTION_IF_FOUND], [ACTION-IF-NOT-FOUND])
# -------------------------------------------
#
# This macro tests for the usability of libcairo.
#
# The default ACTION_IF_FOUND is to set CAIRO_FLAGS and CAIRO_LIBS.
# The default ACTION-IF-NOT-FOUND is to print an error message.

AC_DEFUN([CW_LIB_LIBCAIRO], [
AC_CACHE_CHECK([if libcairo is available], cw_cv_lib_libcairo, [
# Check if we have libcairo
AC_LANG_SAVE
AC_LANG([C])
cw_save_LIBS="$LIBS"
LIBS="$LIBS `pkg-config --libs cairo`"
AC_LINK_IFELSE([AC_LANG_CALL([], [cairo_create])], [cw_cv_lib_libcairo=yes], [cw_cv_lib_libcairo=no])
LIBS="$cw_save_LIBS"
AC_LANG_RESTORE])
if test "$cw_cv_lib_libcairo" = "no"; then
  m4_default([$2], [dnl
  AC_MSG_ERROR([
Cannot find (a working) libcairo.
Perhaps you need to add its location to PKG_CONFIG_PATH and LD_LIBRARY_PATH, for example:
PKG_CONFIG_PATH=/opt/install/lib/pkgconfig LD_LIBRARY_PATH=/opt/install/lib ./configure])])
else
  m4_default([$1], [dnl
  CAIRO_FLAGS="`pkg-config --cflags cairo`"
  CAIRO_LIBS="`pkg-config --libs cairo`"])
  AC_SUBST(CAIRO_FLAGS)
  AC_SUBST(CAIRO_LIBS)
fi])
