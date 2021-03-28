# CW_LIB_LIBCWD m4 macro -- this file is part of cwm4.
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
# The automake conditional CW_NON_THREADED is set to reflect
# if THREADED was no or both; and likewise CW_THREADED is set
# to reflect if THREADED was yes or both.
#
# If WANTED is not [no] then this macro tests for the usability of
# libcwd[_r] as follows:
#
# If THREADED is set to [no] or [both] then CWD_FLAGS and CWD_LIBS
# are set as appropriate for the non-threaded case.
# If THREADED is set to [yes] or [both] then CWD_R_FLAGS and CWD_R_LIBS
# are set as appropriate for the threaded case.
# This is the default ACTION_IF_FOUND, if WANTED is unequal "no".
#
# If the required librarie(s) could be found then the macros
# LIBCWD_FLAGS, LIBCWD_LIBS, LIBCWD_R_FLAGS and LIBCWD_R_LIBS
# are set to their counter parts without the LIB prefix and
# the macro `cw_used_libcwd' is set to "yes".
#
# If the required librarie(s) (as per THREADED, not WANTED) could
# not be found then LIBCWD_R_FLAGS is set to "-pthread", the other
# three LIB* macros will be empty and `cw_used_libcwd' is set to "no".
# The AM_CONDITIONAL `LIBCWD_USED' is also set accordingly.
#
# The default ACTION-IF-NOT-FOUND is to print an error message;
# ACTION-IF-NOT-FOUND is only executed when WANTED is "yes" and
# a required libcwd(_r) was not found.
#
# WANTED | THREADED | libcwd exists | libcwd_r exists | CWD_* | CWD_R_* | LIBCWD_* | LIBCWD_R_* | cw_used_libcwd
#     no |        * |             * |               * | empty |   empty |    empty |      empty |       no
#    yes |       no |            no |               * |    -  |      -  |       -  |         -  |        -  (print error)
#    yes |       no |           yes |               * |   set |   empty |      set |      empty |      yes
#    yes |      yes |             * |              no |    -  |      -  |       -  |         -  |        -  (print error)
#    yes |      yes |             * |             yes | empty |     set |    empty |        set |      yes
#    yes |     both |            no |              no |    -  |      -  |       -  |         -  |        -  (print error)
#    yes |     both |            no |             yes |    -  |      -  |       -  |         -  |        -  (print error)
#    yes |     both |           yes |              no |    -  |      -  |       -  |         -  |        -  (print error)
#    yes |     both |           yes |             yes |   set |     set |      set |        set |      yes
#   auto |       no |            no |               * | empty |   empty |    empty |      empty |       no
#   auto |       no |           yes |               * |   set |   empty |      set |      empty |      yes
#   auto |      yes |             * |              no | empty |   empty |    empty |      empty |       no
#   auto |      yes |             * |             yes | empty |     set |    empty |        set |      yes
#   auto |     both |            no |              no | empty |   empty |    empty |      empty |       no
#   auto |     both |            no |             yes | empty |     set |    empty |      empty |       no
#   auto |     both |           yes |              no |   set |   empty |    empty |      empty |       no
#   auto |     both |           yes |             yes |   set |     set |      set |        set |      yes
#
# The '*' under THREADED mean 'any', yes, no or both.
# A '*' under 'libcwd* exists' means "not tested".
# 'error' under cw_used_libcwd means that it is set to no, and a fatal error message is printed.
# 'empty' under LIBCWD_R_* means that LIBCWD_R_LIBS is empty and LIBCWD_R_FLAGS is set to '-pthread'.

AC_DEFUN([CW_LIB_LIBCWD],
[
# Lets start with a default of everything empty, libcwd not being used.
CWD_FLAGS=
CWD_LIBS=
CWD_R_FLAGS=
CWD_R_LIBS=
AC_SUBST(CWD_FLAGS)
AC_SUBST(CWD_LIBS)
AC_SUBST(CWD_R_FLAGS)
AC_SUBST(CWD_R_LIBS)
LIBCWD_FLAGS=
LIBCWD_LIBS=
LIBCWD_R_FLAGS=
LIBCWD_R_LIBS=
AC_SUBST(LIBCWD_FLAGS)
AC_SUBST(LIBCWD_LIBS)
AC_SUBST(LIBCWD_R_FLAGS)
AC_SUBST(LIBCWD_R_LIBS)
cw_used_libcwd=no
# The input variables.
cw_optionname="$1"
cw_wanted="$2"
cw_threaded="$3"
m4_pattern_allow([CW_NON_THREADED])
AM_CONDITIONAL([CW_NON_THREADED], [test "$cw_threaded" = "no" -o "$cw_threaded" = "both"])
m4_pattern_allow([CW_THREADED])
AM_CONDITIONAL([CW_THREADED], [test "$cw_threaded" = "yes" -o "$cw_threaded" = "both"])
# Default for error reporting.
cw_libname="libcwd_r"
test "$cw_threaded" != "no" || cw_libname="libcwd"
# If we don't want to use libcwd, then this macro is done.
if test x"$cw_wanted" != x"no"; then
  # Test if libcwd exists when cw_threaded is no or both.
  if test x"$cw_threaded" = x"no" -o x"$cw_threaded" = x"both"; then
    AC_CACHE_CHECK([if libcwd is available], cw_cv_lib_libcwd,
[    # Check if we have libcwd.
    AC_LANG_SAVE
    AC_LANG([C++])
    cw_save_LIBS="$LIBS"
    LIBS="$LIBS $(pkg-config --libs libcwd)"
    AC_LINK_IFELSE([AC_LANG_CALL([], [__libcwd_version])], [cw_cv_lib_libcwd=yes], [cw_cv_lib_libcwd=no])
    LIBS="$cw_save_LIBS"
    AC_LANG_RESTORE])
    if test "$cw_cv_lib_libcwd" = "yes"; then
      CWD_FLAGS="$(pkg-config --cflags libcwd)"
      CWD_LIBS="$(pkg-config --libs libcwd)"
      test -n "$CWD_LIBS" || cw_libname="libcwd"
    fi
  fi
  # Test if libcwd_r exists when cw_threaded is yes or both.
  if test x"$cw_threaded" = x"yes" -o x"$cw_threaded" = x"both"; then
    AC_CACHE_CHECK([if libcwd_r is available], cw_cv_lib_libcwd_r,
[    # Check if we have libcwd_r.
    AC_LANG_SAVE
    AC_LANG([C++])
    cw_save_LIBS="$LIBS"
    LIBS="$LIBS $(pkg-config --libs libcwd_r)"
    AC_LINK_IFELSE([AC_LANG_CALL([], [__libcwd_version])], [cw_cv_lib_libcwd_r=yes], [cw_cv_lib_libcwd_r=no])
    LIBS="$cw_save_LIBS"
    AC_LANG_RESTORE])
    if test "$cw_cv_lib_libcwd_r" = "yes"; then
      CWD_R_FLAGS="$(pkg-config --cflags libcwd_r)"
      CWD_R_LIBS="$(pkg-config --libs libcwd_r)"
    fi
  fi
  # Set cw_have_needed to no if a needed library is missing.
  cw_have_needed="yes"
  if test x"$cw_threaded" = x"no" -o x"$cw_threaded" = x"both"; then
    cw_have_needed=$cw_cv_lib_libcwd
  fi
  if test x"$cw_threaded" = x"yes" -o x"$cw_threaded" = x"both"; then
    test $cw_have_needed = "no" || cw_have_needed=$cw_cv_lib_libcwd_r
  fi
  # Print an error if we don't have what we want.
  if test "$cw_wanted" = "yes" -a "$cw_have_needed" = "no"; then
    m4_default([$5], [dnl
      AC_MSG_ERROR([
  --enable-$cw_optionname: You need to have $cw_libname installed to enable this.
  Or perhaps you need to add its location to PKG_CONFIG_PATH and LD_LIBRARY_PATH, for example:
  PKG_CONFIG_PATH=/opt/install/lib/pkgconfig LD_LIBRARY_PATH=/opt/install/lib ./configure])
    ])
  elif test "$cw_have_needed" = "yes"; then
    cw_used_libcwd=yes
    if test x"$cw_threaded" = x"no" -o x"$cw_threaded" = x"both"; then
      m4_default([$4], [dnl
      LIBCWD_FLAGS="$CWD_FLAGS"
      LIBCWD_LIBS="$CWD_LIBS"])
    fi
    if test x"$cw_threaded" = x"yes" -o x"$cw_threaded" = x"both"; then
      m4_default([$4], [dnl
      LIBCWD_R_FLAGS="${CWD_R_FLAGS:--pthread}"
      LIBCWD_R_LIBS="$CWD_R_LIBS"])
    fi
  fi
fi # $cw_wanted != "no"
AM_CONDITIONAL(LIBCWD_USED, [test "$cw_used_libcwd" = "yes"])
])
