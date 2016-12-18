# CW_BUG_G_CONFIG_H m4 macro -- this file is part of cwautomacros.
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

dnl CW_BUG_G_CONFIG_H
dnl Check if /usr/include/_G_config.h forgets to define a few macros
AC_DEFUN([CW_BUG_G_CONFIG_H],
[AC_LANG_SAVE
AC_LANG_C
AC_CHECK_FUNCS(labs)
AC_LANG_RESTORE
AC_CACHE_CHECK([whether _G_config.h forgets to define macros], cw_cv_sys_G_config_h_macros,
[AC_EGREP_CPP(_G_CLOG_CONFLICT,
[#ifndef HAVE__G_CONFIG_H
#include <_G_config.h>
#endif
#ifndef _G_CLOG_CONFLICT
_G_CLOG_CONFLICT
#endif
], cw_cv_sys_G_config_h_macros=_G_CLOG_CONFLICT, cw_cv_sys_G_config_h_macros=no)
AC_EGREP_CPP(_G_HAS_LABS,
[#ifdef HAVE__G_CONFIG_H
#include <_G_config.h>
#endif
#ifndef _G_HAS_LABS
_G_HAS_LABS
#endif
], [if test "$cw_cv_sys_G_config_h_macros" = "no"; then
  cw_cv_sys_G_config_h_macros=_G_HAS_LABS
else
  cw_cv_sys_G_config_h_macros="$cw_cv_sys_G_config_h_macros _G_HAS_LABS"
fi])])
if test "$cw_cv_sys_G_config_h_macros" != no; then
  CW_CONFIG_G_CONFIG_H_MACROS=define
else
  CW_CONFIG_G_CONFIG_H_MACROS=undef
fi
AC_SUBST(CW_CONFIG_G_CONFIG_H_MACROS)
if test "$ac_cv_func_labs" = yes; then
  CW_HAVE_LABS=1
else
  CW_HAVE_LABS=0
fi
AC_SUBST(CW_HAVE_LABS)
])
