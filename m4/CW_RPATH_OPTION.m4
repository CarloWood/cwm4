# CW_RPATH_OPTION m4 macro -- this file is part of cwautomacros.
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

dnl CW_RPATH_OPTION
dnl Figure out the commandline option to gcc needed to pass
dnl a runtime path to the linker.
AC_DEFUN([CW_RPATH_OPTION],
[AC_CACHE_CHECK([how to pass a runtime path to the linker], cw_cv_rpath_option,
[save_CXXFLAGS="$CXXFLAGS"
AC_LANG_SAVE
AC_LANG_CPLUSPLUS
CXXFLAGS="$save_CXXFLAGS -Wl,--rpath,/tmp"
AC_TRY_LINK(,,[cw_cv_rpath_option="-Wl,--rpath,"],[cw_cv_rpath_option="-Wl,-R"])
AC_LANG_RESTORE
CXXFLAGS="$save_CXXFLAGS"])
RPATH_OPTION="$cw_cv_rpath_option"
AC_SUBST(RPATH_OPTION)
])

