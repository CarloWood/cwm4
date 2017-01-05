# CW_DOXYGEN m4 macro -- this file is part of cwm4.
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
# all other use of the material that constitutes the cwm4 project.

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
# Doxygen output directory.
AC_MSG_NOTICE([REAL_MAINTAINER_FALSE is $REAL_MAINTAINER_FALSE; OUTPUT_DIRECTORY is $OUTPUT_DIRECTORY])
if test -z "$REAL_MAINTAINER_FALSE"; then
  OUTPUT_DIRECTORY="."
fi
if test -z "$OUTPUT_DIRECTORY"; then
  AC_MSG_ERROR([The environment variable OUTPUT_DIRECTORY is empty?!], 1)
fi
AC_SUBST(OUTPUT_DIRECTORY)
AC_CONFIG_FILES(
        [doc/Makefile]
        [doc/doxygen.config]
	[doc/html.header]
	[doc/html.footer])
])
