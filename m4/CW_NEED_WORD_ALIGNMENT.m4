# CW_NEED_WORD_ALIGNMENT m4 macro -- this file is part of cwautomacros.
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

dnl CW_NEED_WORD_ALIGNMENT
dnl
dnl Defines LIBCWD_NEED_WORD_ALIGNMENT when the host needs
dnl respectively size_t alignment or not.
AC_DEFUN([CW_NEED_WORD_ALIGNMENT],
[AC_CACHE_CHECK(if machine needs word alignment, cw_cv_system_needwordalignment,
[AC_TRY_RUN([#include <cstddef>
#include <cstdlib>

int main(void)
{
  size_t* p = reinterpret_cast<size_t*>((char*)malloc(5) + 1);
  *p = 0x12345678;
#ifdef __alpha__	// Works, but still should use alignment.
  exit(-1);
#else
  exit ((((unsigned long)p & 1UL) && *p == 0x12345678) ? 0 : -1);
#endif
}],
cw_cv_system_needwordalignment=no,
cw_cv_system_needwordalignment=yes,
cw_cv_system_needwordalignment="why not")])
if test "$cw_cv_system_needwordalignment" != no; then
  AC_DEFINE_UNQUOTED([LIBCWD_NEED_WORD_ALIGNMENT])
fi
])
