# CW_SETUP_RPM_DIRS m4 macro -- this file is part of cwautomacros.
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

dnl CW_SETUP_RPM_DIRS
dnl Set up rpm directory when on linux and in maintainer-mode
AC_DEFUN([CW_SETUP_RPM_DIRS],
[if test "$USE_MAINTAINER_MODE" = yes; then
  LSMFILE="$PACKAGE.lsm"
  AC_SUBST(LSMFILE)
  SPECFILE="$PACKAGE.spec"
  AC_SUBST(SPECFILE)
  if expr "$host" : ".*linux.*" >/dev/null; then
    top_builddir="`pwd`"
    test -d rpm || mkdir rpm
    cd rpm
    test -d BUILD || mkdir BUILD
    test -d SOURCES || mkdir SOURCES
    test -d SRPMS || mkdir SRPMS
    test -d RPMS || mkdir RPMS
    cd RPMS
    TARGET=i386
    AC_SUBST(TARGET)
    test -d $TARGET || mkdir $TARGET
    cd ..
    echo "%_require_vendor 1" > macros
    echo "%_require_distribution 1" >> macros
    echo "%_distribution http://sourceforge.net/project/showfiles.php?group_id=58164" >> macros
    echo "%vendor Carlo Wood" >> macros
    echo "%_topdir "$top_builddir"/rpm" >> macros
    echo "%_pgp_path "$PGPPATH >> macros
    echo "%_signature pgp5" >> macros
    echo "%_pgp_name carlo@alinoe.com" >> macros
    echo "macrofiles: /usr/lib/rpm/macros:"$top_builddir"/rpm/macros" > rpmrc
    echo "buildarchtranslate: i686: i386" >> rpmrc
    cd ..
  fi
fi
])
