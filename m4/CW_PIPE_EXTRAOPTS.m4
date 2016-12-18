# CW_PIPE_EXTRAOPTS m4 macro -- this file is part of cwautomacros.
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

dnl CW_PIPE_EXTRAOPTS
dnl If the compiler understands -pipe, add it to EXTRAOPTS if not already.
AC_DEFUN([CW_PIPE_EXTRAOPTS],
[AC_MSG_CHECKING([if the compiler understands -pipe])
AC_CACHE_VAL(cw_cv_pipe_flag,
[save_CXXFLAGS="$CXXFLAGS"
AC_LANG_SAVE
AC_LANG_CPLUSPLUS
CXXFLAGS="-pipe"
AC_TRY_COMPILE(,,cw_cv_pipe_flag=yes,cw_cv_pipe_flag=no)
AC_LANG_RESTORE
CXXFLAGS="$save_CXXFLAGS"])
if test "$cw_cv_pipe_flag" = yes ; then
  AC_MSG_RESULT(yes)
  x=`echo "$EXTRAOPTS" | grep 'pipe' 2>/dev/null`
  if test "$x" = "" ; then
    EXTRAOPTS="$EXTRAOPTS -pipe"
  fi
else
  AC_MSG_RESULT(no)
fi
])
