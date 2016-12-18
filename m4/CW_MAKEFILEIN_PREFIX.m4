# CW_MAKEFILEIN_PREFIX m4 macro -- this file is part of cwautomacros.
# Copyright (C) 2007 Carlo Wood <carlo@alinoe.com>
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

# CW_MAKEFILEIN_PREFIX
# --------------------
#
# This macro set @Makefilein@ to an empty string.
# That allows verbatim rules to be included in Makefile.am
# without that automake tries to decode them.
#
AC_DEFUN([CW_MAKEFILEIN_PREFIX], [
Makefilein=
AC_SUBST(Makefilein)
])
