# CW_PCHFLAGS m4 macro -- this file is part of cwautomacros.
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

dnl CW_PCHFLAGS
dnl Add --enable-pch (-include pch.h) option. Update USE_PCH (automake conditional) and PCHFLAGS accordingly.
AC_DEFUN([CW_PCHFLAGS], [dnl

# Add args to configure.
AC_ARG_ENABLE(pch,           [  --enable-pch            enable precompiled header support @<:@auto detect for g++@:>@])

# Handle enable_pch.
PCHFLAGS=
if test x"$enable_pch" != x"no"; then           # No --disable-pch
  # Check if compiler supports PCH.
  CW_SYS_PCH
  if test "$cw_cv_prog_CXX_pch" = "no" -a x"$enable_pch" = x"yes"; then
    AC_MSG_ERROR([
  --enable-pch: You need to use a PCH capable compiler to enable this.
    ])
  fi
  if test "$cw_cv_prog_CXX_pch" = "yes"; then
    PCHFLAGS="-include pch.h"
  fi
else
  AM_CONDITIONAL(USE_PCH, [false])
fi
AC_SUBST([PCHFLAGS])
])
