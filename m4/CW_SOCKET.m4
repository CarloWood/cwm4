# CW_SOCKET m4 macro -- this file is part of cwautomacros.
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

dnl CW_SOCKET
dnl
dnl Defines cw_socket_header to be `sys/socket.h', `winsock2.h' or `winsock.h'.
dnl and sets cw_socket_library to either `-lsocket', `-lws2_32' or `-lwsock32'.
AC_DEFUN([CW_SOCKET], [

save_LIBS="$LIBS"
LIBS=
cw_socket_header=

AC_CHECK_LIB(c, socket, cw_socket_library=""; cw_socket_header="sys/socket.h",
[AC_CHECK_LIB(socket, socket, cw_socket_library="-lsocket"; cw_socket_header="sys/socket.h",
[AC_CHECK_LIB(ws2_32, socket, cw_socket_library="-lws2_32"; cw_socket_header="winsock2.h",
[AC_CHECK_LIB(wsock32, socket, cw_socket_library="-lwsock32"; cw_socket_header="winsock.h")])])])

if test -z "$cw_socket_header"; then
  AC_MSG_ERROR([Cannot find a socket library])
fi

if test "$cw_socket_header" = "sys/socket.h"; then
  AC_CHECK_HEADERS(sys/socket.h)
  if test "$ac_cv_header_sys_socket_h" != "yes"; then
    AC_MSG_ERROR([Cannot find socket headerfile])
  fi
elif test "cw_socket_header" = "winsock2.h"; then
  AC_CHECK_HEADERS(winsock2.h)
  if test "$ac_cv_header_winsock2_h" != "yes"; then
    AC_MSG_ERROR([Cannot find socket headerfile])
  fi
elif test "cw_socket_header" = "winsock.h"; then
  AC_CHECK_HEADERS(winsock.h)
  if test "$ac_cv_header_winsock_h" != "yes"; then
    AC_MSG_ERROR([Cannot find socket headerfile])
  fi
fi

LIBS="$save_LIBS"

])
