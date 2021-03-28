# CW_HAVE_BUILTIN_EXPECT m4 macro -- this file is part of cwm4.
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

# CW_HAVE_BUILTIN_EXPECT
# ----------------------
#
# This macro tests if the compiler supports the __builtin_expect feature.

AC_DEFUN([CW_HAVE_BUILTIN_EXPECT], [
  AC_CACHE_CHECK([if __builtin_expect is available], cw_cv_have_builtin_expect, [
                  AC_LINK_IFELSE([AC_LANG_PROGRAM(, return __builtin_expect(main != 0, 1))],
                                 [cw_cv_have_builtin_expect=yes],
                                 [cw_cv_have_builtin_expect=no])])
  if test "$cw_cv_have_builtin_expect" = "no"; then
    AC_DEFINE(HAVE_BUILTIN_EXPECT, 0,
              [Define to 1 if compiler supports __builtin_expect])
  else
    AC_DEFINE(HAVE_BUILTIN_EXPECT, 1,
              [Define to 1 if compiler supports __builtin_expect])
  fi
])
