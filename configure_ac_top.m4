dnl Detect unexpanded macros.
m4_pattern_forbid(CW_)

dnl Package name and version
AC_INIT(CW_PACKAGE_NAME, CW_VERSION_MAJOR.CW_VERSION_MINOR.CW_VERSION_REVISION, CW_BUGREPORT)

dnl Put resulting configuration defines in this header file.
AC_CONFIG_HEADERS([config.h])

dnl Because we use cwautomacros.
CW_AUTOMACROS

dnl Automake options.
AM_INIT_AUTOMAKE([foreign])

dnl Include maintainer mode targets
AM_MAINTAINER_MODE

dnl Check for compiler and preprocessor
AC_PROG_CC_C99
AC_PROG_CXX
AC_PROG_CXXCPP

dnl Add --enable-debug (DEBUG, DOXYGEN_DEBUG), --enable-libcwd (CWDEBUG, DOXYGEN_CWDEBUG),
dnl --enable-optimise and --enable-profile options. Update USE_LIBCWD, CWD_LIBS and CXXFLAGS accordingly.
CW_OPG_FLAGS([-W -Wall -Woverloaded-virtual -Wundef -Wpointer-arith -Wwrite-strings -Winline])

dnl Checks for other programs.
AC_PROG_INSTALL
AC_PROG_LIBTOOL

dnl Suppress warning from ar by supplying U flag.
AC_SUBST(AR_FLAGS, [cruU])

dnl Define ACLOCAL_CWFLAGS, so that rerunning aclocal from 'make' will work.
ACLOCAL_CWFLAGS="-I cwm4/m4"
if test -d $ac_confdir/libtoolm4; then
ACLOCAL_CWFLAGS="$ACLOCAL_CWFLAGS -I `cd $ac_confdir; pwd`/libtoolm4"
fi
AC_SUBST(ACLOCAL_CWFLAGS)

dnl This source code is C++11 and thread-safe.
CXXFLAGS="$CXXFLAGS -pthread -std=c++11"
LIBCWD_FLAGS="$CWD_R_FLAGS"
LIBCWD_LIBS="$CWD_R_LIBS"
AC_SUBST(LIBCWD_FLAGS)
AC_SUBST(LIBCWD_LIBS)