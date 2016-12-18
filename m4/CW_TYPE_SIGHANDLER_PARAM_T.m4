# CW_TYPE_SIGHANDLER_PARAM_T m4 macro -- this file is part of cwautomacros.
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

dnl CW_TYPE_SIGHANDLER_PARAM_T
dnl
dnl If `sighandler_param_t' is not defined in signal.h,
dnl define it to be the type of the the first argument of `SIG_IGN'.
dnl
AC_DEFUN([CW_TYPE_SIGHANDLER_PARAM_T],
[AC_CACHE_CHECK(type sighandler_param_t, cw_cv_type_sighandler_param_t,
[AC_EGREP_HEADER(sighandler_param_t, signal.h, cw_cv_type_sighandler_param_t=exists,
[CW_TYPE_EXTRACT_FROM(SIG_IGN, [#include <signal.h>], 1, 1)
eval "cw_cv_type_sighandler_param_t=\"$cw_result\""])])
if test "$cw_cv_type_sighandler_param_t" != exists; then
  CW_DEFINE_TYPE(sighandler_param_t, [$cw_cv_type_sighandler_param_t])
fi
])
