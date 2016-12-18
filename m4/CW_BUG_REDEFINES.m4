# CW_BUG_REDEFINES_INITIALIZATION m4 macro -- this file is part of cwautomacros.
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

dnl CW_BUG_REDEFINES_INITIALIZATION
dnl
AC_DEFUN([CW_BUG_REDEFINES_INITIALIZATION],
CW_SYS_REDEFINES_FIX=
dnl We don't want automake to put this in Makefile.in
[AC_SUBST](CW_SYS_REDEFINES_FIX))

dnl CW_BUG_REDEFINES([HEADERFILE])
dnl
dnl Check whether the HEADERFILE causes macros to be redefined
dnl
AC_DEFUN([CW_BUG_REDEFINES],
[AC_REQUIRE([CW_BUG_REDEFINES_INITIALIZATION])
changequote(, )dnl
cw_bug_var=`echo $1 | sed -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' -e 's/ //g' -e 's/[^a-z0-9]/_/g'`
changequote([, ])dnl
AC_MSG_CHECKING([if $1 redefines macros])
AC_CACHE_VAL(cw_cv_bug_redefines_$cw_bug_var,
[cat > conftest.$ac_ext <<EOF
#include <sys/types.h>
#include <sys/time.h>
#include <$1>
#ifdef __cplusplus
#include <cstdlib>
#endif
int main() { exit(0); }
EOF
save_CXXFLAGS="$CXXFLAGS"
CXXFLAGS="`echo $CXXFLAGS | sed -e 's/-Werror//g'`"
if { (eval echo configure: \"$ac_compile\") 1>&5; (eval $ac_compile) 2>&1 | tee conftest.out >&5; }; then
changequote(, )dnl
  cw_result="`grep 'warning.*redefined' conftest.out | sed -e 's/[^A-Z_]*redefined.*//' -e 's/.*warning.* [^A-Z_]*//'`"
  eval "cw_cv_bug_redefines_$cw_bug_var=\"\$cw_result\""
  cw_result="`grep 'previous.*defin' conftest.out | sed -e 's/:.*//' -e 's%.*include/%%g' | sort | uniq`"
changequote([, ])dnl
  eval "unset cw_cv_bug_redefines_${cw_bug_var}_prev"
  AC_CACHE_VAL(cw_cv_bug_redefines_${cw_bug_var}_prev, [eval "cw_cv_bug_redefines_${cw_bug_var}_prev=\"$cw_result\""])
else
  echo "configure: failed program was:" >&5
  cat conftest.$ac_ext >&5
  eval "cw_cv_bug_redefines_$cw_bug_var="
  eval "cw_cv_bug_redefines_${cw_bug_var}_prev="
fi
CXXFLAGS="$save_CXXFLAGS"
rm -f conftest*])
eval "cw_redefined_macros=\"\$cw_cv_bug_redefines_$cw_bug_var\""
eval "cw_redefined_from=\"\$cw_cv_bug_redefines_${cw_bug_var}_prev\""
if test x"$cw_redefined_macros" = x; then
  AC_MSG_RESULT(no)
else
  AC_MSG_RESULT($cw_redefined_macros from $cw_redefined_from)
fi
for i in $cw_redefined_from; do
CW_SYS_REDEFINES_FIX="$CW_SYS_REDEFINES_FIX\\
#include <$i>"
done
for i in $cw_redefined_macros; do
CW_SYS_REDEFINES_FIX="$CW_SYS_REDEFINES_FIX\\
#undef $i"
done])
