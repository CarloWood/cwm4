# CW_TYPE_SOCKLEN_T m4 macro -- this file is part of cwautomacros.
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

dnl CW_TYPE_SOCKLEN_T
dnl
dnl If `socklen_t' is not defined in $cw_socket_header,
dnl define it to be the type of the fifth argument
dnl of `setsockopt'.
dnl
AC_DEFUN([CW_TYPE_SOCKLEN_T],
[AC_REQUIRE([CW_SOCKET])
AC_CACHE_CHECK(type socklen_t, cw_cv_type_socklen_t,
[AC_EGREP_HEADER(socklen_t, $cw_socket_header, cw_cv_type_socklen_t=exists,
[CW_TYPE_EXTRACT_FROM(setsockopt, [#include <sys/types.h>
#include <$cw_socket_header>], 5, 5)
eval "cw_cv_type_socklen_t=\"$cw_result\""])])
if test "$cw_cv_type_socklen_t" != exists; then
  CW_DEFINE_TYPE(socklen_t, [$cw_cv_type_socklen_t])
fi
])
