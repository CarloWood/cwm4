# CW_HAVE_BUILTIN_BSWAP m4 macro -- this file is part of cwm4.
# Copyright (C) 2018 Carlo Wood <carlo@alinoe.com>
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

# CW_HAVE_BUILTIN_BSWAP
# ----------------------
#
# This macro tests if the compiler supports the __builtin_bswap32 feature.
# It is assumed that if this is the case than also __builtin_bswap64
# will be available, hence that the macro name is just CW_HAVE_BUILTIN_BSWAP.

AC_DEFUN([CW_HAVE_BUILTIN_BSWAP], [
  AC_CACHE_CHECK([if __builtin_bswap32 is available], cw_cv_have_builtin_bswap32, [
                  AC_LINK_IFELSE([AC_LANG_PROGRAM(, return __builtin_bswap32(0x12345678))],
                                 [cw_cv_have_builtin_bswap32=yes],
                                 [cw_cv_have_builtin_bswap32=no])])
  if test "$cw_cv_have_builtin_bswap32" = "no"; then
    AC_DEFINE(HAVE_BUILTIN_BSWAP, 0,
              [Define to 1 if compiler supports __builtin_bswap32])
  else
    AC_DEFINE(HAVE_BUILTIN_BSWAP, 1,
              [Define to 1 if compiler supports __builtin_bswap32])
  fi
])
