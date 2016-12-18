# CW_DOXYGEN m4 macro -- this file is part of cwautomacros.
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

dnl CW_DOXYGEN
dnl
dnl The following is created, if it doesn't already exist, by autogen.sh:
dnl - A directory 'doc' in srcdir
dnl - $(srcdir)/doc/Makefile.am
dnl - $(srcdir)/doc/doxygen.config.in
dnl - $(srcdir)/doc/main.css
dnl - $(srcdir)/doc/html.header
dnl - $(srcdir)/doc/html.footer
dnl - $(srcdir)/doc/mainpage.dox
dnl 
AC_DEFUN([CW_DOXYGEN], [
# Check if we have graphviz's 'dot'.
AC_PATH_PROG(DOXYGEN_DOT, [dot],)
AC_SUBST(DOXYGEN_DOT)
HAVE_DOT=NO
if test -n "$DOXYGEN_DOT"; then
HAVE_DOT=YES
fi
AC_SUBST(HAVE_DOT)
DOXYGEN_STRIP_FROM_PATH=$(cd $srcdir; pwd)
AC_SUBST(DOXYGEN_STRIP_FROM_PATH)
])
