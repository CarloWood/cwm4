# CW_SYS_RECURSIVE_BUILTIN_RETURN_ADDRESS m4 macro -- this file is part of cwautomacros.
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

dnl CW_SYS_RECURSIVE_BUILTIN_RETURN_ADDRESS
dnl
dnl Determines if __builtin_return_address(1) is supported by compiler.
AC_DEFUN([CW_SYS_RECURSIVE_BUILTIN_RETURN_ADDRESS],
[AC_CACHE_CHECK([whether __builtin_return_address(1) works], cw_cv_sys_recursive_builtin_return_address,
[AC_LANG_SAVE
AC_LANG_C
SYS_RECURSIVE_BUILTIN_RETURN_ADDRESS_CFLAGS_save="$CFLAGS"
CFLAGS=""
AC_TRY_RUN([
static void* p;
int f() { return (__builtin_return_address(1) == p) ? 0 : 1; }
int main() { p = __builtin_return_address(0); return f(); }],
cw_cv_sys_recursive_builtin_return_address=yes,
cw_cv_sys_recursive_builtin_return_address=no,
cw_cv_sys_recursive_builtin_return_address=unknown)
CFLAGS="$SYS_RECURSIVE_BUILTIN_RETURN_ADDRESS_CFLAGS_save"
AC_LANG_RESTORE])
if test "$cw_cv_sys_recursive_builtin_return_address" = "no"; then
CW_CONFIG_RECURSIVE_BUILTIN_RETURN_ADDRESS=undef
cw_recursive_builtin_return_address=0
else
CW_CONFIG_RECURSIVE_BUILTIN_RETURN_ADDRESS=define
cw_recursive_builtin_return_address=1
fi
AC_SUBST(CW_CONFIG_RECURSIVE_BUILTIN_RETURN_ADDRESS)
AC_DEFINE_UNQUOTED([CW_RECURSIVE_BUILTIN_RETURN_ADDRESS], $cw_recursive_builtin_return_address,
    [Define when __builtin_return_address accepts arguments larger than 0.])
])
