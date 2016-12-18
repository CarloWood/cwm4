# CW_TYPE_EXTRACT_FROM m4 macro -- this file is part of cwautomacros.
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

dnl CW_TYPE_EXTRACT_FROM(FUNCTION, INIT, ARGUMENTS, ARGUMENT)
dnl
dnl Extract the type of ARGUMENT argument of function FUNCTION with ARGUMENTS arguments.
dnl INIT are possibly needed #includes.  The result is put in `cw_result'.
dnl
AC_DEFUN([CW_TYPE_EXTRACT_FROM],
[cat > conftest.$ac_ext <<EOF
[$2]
#ifdef __cplusplus
#include <cstdlib>
#define ARGF
#else
#define ARGF f
#endif
template<typename ARG>
  void detect_type(ARG)
  {
    return reinterpret_cast<ARG*>(0);
  }
EOF
echo $ac_n "template<typename ARG0[,] $ac_c" >> conftest.$ac_ext
i=1
while test "$i" != "$3"; do
echo $ac_n "typename ARG$i[,] $ac_c" >> conftest.$ac_ext
i=`echo $i | sed -e 'y/012345678/123456789/'`
done
echo "typename ARG$3>" >> conftest.$ac_ext
echo $ac_n "void foo(ARG0(*ARGF)($ac_c" >> conftest.$ac_ext
i=1
while test "$i" != "$3"; do
echo $ac_n "ARG$i[,] $ac_c" >> conftest.$ac_ext
i=`echo $i | sed -e 'y/012345678/123456789/'`
done
echo "ARG$3)) { ARG$4 arg;" >> conftest.$ac_ext
cat >> conftest.$ac_ext <<EOF
  detect_type(arg);
}
int main(void)
{
  foo($1);
  exit(0);
}
EOF
save_CXXFLAGS="$CXXFLAGS"
CXXFLAGS="`echo $CXXFLAGS | sed -e 's/-Werror//g'`"
if { (eval echo configure: \"$ac_compile\") 1>&5; (eval $ac_compile) 2>&1 | tee conftest.out >&5; }; then
changequote(, )dnl
  cw_result="`grep 'detect_type<.*>' conftest.out | sed -e 's/.*detect_type<//g' -e 's/>[^>]*//' | head -n 1`"
  if test -z "$cw_result"; then
    cw_result="`cat conftest.out`"
    dnl We need this comment to work around a bug in autoconf or m4: '['
    cw_result="`echo $cw_result | sed -e 's/.*detect_type.*with ARG = //g' -e 's/].*//'`"
  fi
changequote([, ])dnl
  if test -z "$cw_result"; then
    AC_MSG_ERROR([Configure problem: Failed to determine type])
  fi
else
  echo "configure: failed program was:" >&5
  cat conftest.$ac_ext >&5
  AC_MSG_ERROR([Configuration problem: Failed to compile a test program])
fi
CXXFLAGS="$save_CXXFLAGS"
rm -f conftest*
])
