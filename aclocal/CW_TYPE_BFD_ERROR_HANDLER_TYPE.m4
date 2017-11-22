# CW_TYPE_BFD_ERROR_HANDLER_TYPE m4 macro -- this file is part of cwm4.
# Copyright (C) 2017 Carlo Wood <carlo@alinoe.com>
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
# all other use of the material that constitutes the cwm4 project.

dnl CW_TYPE_BFD_ERROR_HANDLER_TYPE
dnl
dnl Determines if bfd_error_handler_type is defined in bfd.h as a variadic function.
AC_DEFUN([CW_TYPE_BFD_ERROR_HANDLER_TYPE],
[AC_CACHE_CHECK([if bfd_error_handler_type is printf style], cw_cv_type_bfd_error_handler_type,
[AC_LANG_PUSH([C])
AC_EGREP_HEADER([^typedef void \(\*bfd_error_handler_type\).*\.\.\.\)], [bfd.h], cw_cv_type_bfd_error_handler_type=yes, cw_cv_type_bfd_error_handler_type=no)
AC_LANG_POP([C])])
if test "$cw_cv_type_bfd_error_handler_type" = "no"; then
cw_type_bfd_error_handler_type=0
else
cw_type_bfd_error_handler_type=1
fi
AC_DEFINE_UNQUOTED([HAVE_PRINTF_STYLE_BFD_ERROR_HANDLER_TYPE], $cw_type_bfd_error_handler_type,
    [Define when bfd_error_handler_type uses a printf style rather than vprintf style argument passing.])
])
