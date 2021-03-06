# CW_NBLOCK m4 macro -- this file is part of cwm4.
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

dnl CW_SYS_NONBLOCK
dnl
dnl Defines CW_CONFIG_NONBLOCK to be `POSIX', `BSD', `SYSV' or `WIN32'
dnl depending on whether socket non-blocking stuff is posix, bsd, sysv
dnl or win32 style respectively.
AC_DEFUN([CW_SYS_NONBLOCK],
[AC_REQUIRE([CW_SOCKET])
case "$host_alias" in		# (
  *-mingw32)			# (
    cw_windows=yes
    ;;				# (
  *-cygwin)
    cw_windows=yes
    ;;				# (
  *)
    cw_windows=no
    ;;
esac
if test "$cw_windows" = no -o "$cw_socket_header" = "sys/socket.h"; then
save_LIBS="$LIBS"
LIBS="$cw_socket_library"
AC_CACHE_CHECK(non-blocking socket flavour, cw_cv_system_nonblock,
[AC_REQUIRE([m4_warn([obsolete],
[your code may safely assume C89 semantics that RETSIGTYPE is void.
Remove this warning and the `AC_CACHE_CHECK' when you adjust the code.])dnl
AC_CACHE_CHECK([return type of signal handlers],[ac_cv_type_signal],[AC_COMPILE_IFELSE(
[AC_LANG_PROGRAM([#include <sys/types.h>
#include <signal.h>
],
		 [return *(signal (0, 0)) (0) == 1;])],
		   [ac_cv_type_signal=int],
		   [ac_cv_type_signal=void])])
AC_DEFINE_UNQUOTED([RETSIGTYPE],[$ac_cv_type_signal],[Define as the return type of signal handlers
		    (`int' or `void').])
])
CW_TYPE_EXTRACT_FROM(recvfrom, [#include <sys/types.h>
#include <$cw_socket_header>], 6, 6)
cw_recvfrom_param_six_t="$cw_result"
AC_LANG_SAVE
AC_LANG([C])
AC_RUN_IFELSE([AC_LANG_SOURCE([[#include <sys/types.h>
#include <$cw_socket_header>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/file.h>
#include <signal.h>
#include <unistd.h>
$ac_cv_type_signal alarmed() { exit(1); }
int main(int argc, char* argv[])
{
  char b[12];
  struct sockaddr x;
  size_t l = sizeof(x);
  int f = socket(AF_INET, SOCK_DGRAM, 0);
  if (argc == 1)
    return 0;
  if (f >= 0 && !(fcntl(f, F_SETFL, (*argv[1] == 'P') ? O_NONBLOCK : O_NDELAY)))
  {
    signal(SIGALRM, alarmed);
    alarm(2);
    recvfrom(f, b, 12, 0, &x, ($cw_recvfrom_param_six_t)&l);
    alarm(0);
    return 0;
  }
  return 1;
}]])],
[./conftest POSIX
if test "$?" = "0"; then
  cw_cv_system_nonblock=POSIX
else
  ./conftest BSD
  if test "$?" = "0"; then
    cw_cv_system_nonblock=BSD
  else
    cw_cv_system_nonblock=SYSV
  fi
fi],
[AC_MSG_ERROR(Failed to compile a test program!?)],
[cw_cv_system_nonblock=crosscompiled_set_to_POSIX_BSD_or_SYSV
AC_CACHE_SAVE
AC_MSG_WARN(Cannot set cw_cv_system_nonblock for unknown platform (you are cross-compiling).)
AC_MSG_ERROR(Please edit config.cache and rerun ./configure to correct this!)])
AC_LANG_RESTORE])
if test "$cw_cv_system_nonblock" = crosscompiled_set_to_POSIX_BSD_or_SYSV; then
  AC_MSG_ERROR(Please edit config.cache and correct the value of cw_cv_system_nonblock, then rerun ./configure)
fi
else
  cw_cv_system_nonblock=WIN32
fi
CW_CONFIG_NONBLOCK=$cw_cv_system_nonblock
AC_SUBST(CW_CONFIG_NONBLOCK)
LIBS="$save_LIBS"])
