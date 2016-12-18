# CW_SYS_MALLOC_OVERHEAD m4 macro -- this file is part of cwautomacros.
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

dnl CW_SYS_MALLOC_OVERHEAD
dnl
dnl Defines CW_MALLOC_OVERHEAD to be the number of bytes extra
dnl allocated for a call to malloc.
dnl
AC_DEFUN([CW_SYS_MALLOC_OVERHEAD],
[AC_CACHE_CHECK(malloc overhead in bytes, cw_cv_system_mallocoverhead,
[AC_TRY_RUN([#include <cstddef>
#include <cstdlib>

bool bulk_alloc(size_t malloc_overhead_attempt, size_t size)
{
  int const number = 100;
  long int distance = 9999;
  char* ptr[number];
  ptr[0] = (char*)malloc(size - malloc_overhead_attempt);
  for (int i = 1; i < number; ++i)
  {
    ptr[i] = (char*)malloc(size - malloc_overhead_attempt);
    if (ptr[i] > ptr[i - 1] && (ptr[i] - ptr[i - 1]) < distance)
      distance = ptr[i] - ptr[i - 1];
  }
  for (int i = 0; i < number; ++i)
    free(ptr[i]);
  return (distance == (long int)size);
}

int main(int argc, char* [])
{
  if (argc == 1)
    exit(0);	// This wasn't the real test yet
  for (size_t s = 0; s <= 64; s += 2)
    if (bulk_alloc(s, 2048))
      exit(s);
  exit(8);	// Guess a default
}],
./conftest run
cw_cv_system_mallocoverhead=$?,
[AC_MSG_ERROR(Failed to compile a test program!?)],
[case $host_alias in						#(
  *-mingw32)
    cw_cv_system_mallocoverhead=8
    ;;								#(
  *-cygwin)
    cw_cv_system_mallocoverhead=8
    ;;								#(
  *)
    cw_cv_system_mallocoverhead=4 dnl Guess a default for cross compiling
    ;;
esac])])
eval "CW_MALLOC_OVERHEAD=$cw_cv_system_mallocoverhead"
AC_SUBST(CW_MALLOC_OVERHEAD)
m4_pattern_allow(CW_MALLOC_OVERHEAD)
AC_DEFINE_UNQUOTED([CW_MALLOC_OVERHEAD], $cw_cv_system_mallocoverhead, [The overhead in bytes of malloc(3).])
])
