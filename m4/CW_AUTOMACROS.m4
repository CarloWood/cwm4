# CW_AUTOMACROS m4 macro -- this file is part of cwautomacros.
# Copyright (C) 2006 - 2008 Carlo Wood <carlo@alinoe.com>
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

dnl CW_AUTOMACROS
dnl Take care of general things needed.
AC_DEFUN([CW_AUTOMACROS], [dnl
dnl Check cwautomacros version.
minver=$1
test -n "$minver" || minver=0
if test 20160921 -lt $minver; then
  AC_MSG_ERROR([cwautomacros version $minver or later is required.])
fi
dnl Detect unexpanded macros.
m4_pattern_forbid(CW_)
dnl Define ACLOCAL_CWFLAGS, so that rerunning aclocal from 'make' will work.
ACLOCAL_CWFLAGS="-I ${CWAUTOMACROSPREFIX-/usr}/share/cwautomacros/m4"
if test -d $ac_confdir/libtoolm4; then
ACLOCAL_CWFLAGS="$ACLOCAL_CWFLAGS -I `cd $ac_confdir; pwd`/libtoolm4"
fi
AC_SUBST(ACLOCAL_CWFLAGS)
])
