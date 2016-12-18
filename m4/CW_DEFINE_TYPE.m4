# CW_DEFINE_TYPE_INITIALIZATION m4 macro -- this file is part of cwautomacros.
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

dnl CW_DEFINE_TYPE_INITIALIZATION
dnl
AC_DEFUN([CW_DEFINE_TYPE_INITIALIZATION],
CW_SYS_TYPEDEFS=
dnl We don't want automake to put this in Makefile.in
[AC_SUBST](CW_SYS_TYPEDEFS))

dnl CW_DEFINE_TYPE(NEWTYPE, OLDTYPE)
dnl
dnl Add `typedef OLDTYPE NEWTYPE;' to the output variable CW_SYS_TYPEDEFS
dnl
AC_DEFUN([CW_DEFINE_TYPE],
[AC_REQUIRE([CW_DEFINE_TYPE_INITIALIZATION])
CW_SYS_TYPEDEFS="typedef $2 $1; $CW_SYS_TYPEDEFS"
])

