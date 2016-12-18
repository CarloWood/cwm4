# CW_TYPE_GETGROUPS m4 macro -- this file is part of cwautomacros.
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

dnl CW_TYPE_GETGROUPS
dnl
dnl Like AC_TYPE_GETGROUPS but with bug fix for C++ and adding a
dnl typedef getgroups_t instead of defining the macro GETGROUPS_T.
AC_DEFUN([CW_TYPE_GETGROUPS],
[AC_REQUIRE([AC_TYPE_UID_T])dnl
AC_CACHE_CHECK(type of array argument to getgroups, ac_cv_type_getgroups,
[AC_TRY_RUN(
changequote(<<, >>)dnl
<<
/* Thanks to Mike Rendell for this test.  */
#include <sys/types.h>
#ifdef __cplusplus
extern "C" int getgroups(size_t, gid_t*);
#endif
#define NGID 256
#undef MAX
#define MAX(x, y) ((x) > (y) ? (x) : (y))
int main()
{
  gid_t gidset[NGID];
  int i, n;
  union { gid_t gval; long lval; }  val;

  val.lval = -1;
  for (i = 0; i < NGID; i++)
    gidset[i] = val.gval;
  n = getgroups (sizeof (gidset) / MAX (sizeof (int), sizeof (gid_t)) - 1, gidset);
  /* Exit non-zero if getgroups seems to require an array of ints.  This
     happens when gid_t is short but getgroups modifies an array of ints.  */
  return (n > 0 && gidset[n] != val.gval) ? 1 : 0;
}
>>,
changequote([, ])dnl
  [CW_TYPE_EXTRACT_FROM(getgroups, [#include <unistd.h>], 2, 2)
  eval "cw_result2=\"$cw_result\""
  ac_cv_type_getgroups=`echo "$cw_result2" | sed -e 's/ *\*$//'`],
  ac_cv_type_getgroups=int,
  ac_cv_type_getgroups=cross)
if test "$ac_cv_type_getgroups" = cross; then
  dnl When we can't run the test program (we are cross compiling), presume
  dnl that <unistd.h> has either an accurate prototype for getgroups or none.
  dnl Old systems without prototypes probably use int.
  AC_EGREP_HEADER([getgroups.*int.*gid_t], unistd.h,
                  ac_cv_type_getgroups=gid_t, ac_cv_type_getgroups=int)
fi])
CW_DEFINE_TYPE(getgroups_t, [$ac_cv_type_getgroups])
])
