# CW_SYS_PCH m4 macro -- this file is part of cwautomacros.
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

# CW_SYS_PCH
# ----------
#
# This macro checks if the compiler supports PCH
# and if so, set `cw_cv_prog_CXX_pch' to "yes"
# and sets the automake conditional `USE_PCH'.
#
AC_DEFUN([CW_SYS_PCH],
[AC_CACHE_CHECK([for compiler with PCH support],
  [cw_cv_prog_CXX_pch],
  [ac_save_CXXFLAGS="$CXXFLAGS"
  CXXFLAGS="$CXXFLAGS -Werror -Winvalid-pch -Wno-deprecated"
  AC_LANG_SAVE
  AC_LANG_CPLUSPLUS
  echo '#include <math.h>' > conftest.h
  rm -f conftest.h.gch
  if $CXX $CXXFLAGS $CPPFLAGS -x c++-header conftest.h \
      -c -o conftest.h.gch 1>&5 2>&1 &&
    echo '#error "pch failed"' > conftest.h &&
    echo '#include "conftest.h"' > conftest.cc &&
    $CXX -c $CXXFLAGS $CPPFLAGS conftest.cc 1>&5 2>&1 ;
  then
    cw_cv_prog_CXX_pch=yes
  else
    cw_cv_prog_CXX_pch=no
  fi
  rm -f conftest*
  CXXFLAGS=$ac_save_CXXFLAGS
  AC_LANG_RESTORE
])
AM_CONDITIONAL(USE_PCH, test "$cw_cv_prog_CXX_pch" = "yes")
CW_MAKEFILEIN_PREFIX])

