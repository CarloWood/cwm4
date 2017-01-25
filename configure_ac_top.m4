dnl Detect unexpanded macros.
m4_pattern_forbid(CW_)
m4_pattern_forbid(LT_)

dnl Package name and version
AC_INIT(CW_PACKAGE_NAME, CW_VERSION_MAJOR.CW_VERSION_MINOR.CW_VERSION_REVISION, CW_BUGREPORT)

dnl Automake options.
AM_INIT_AUTOMAKE(m4_sinclude(min_automake_version.m4)[foreign])

dnl Minimum autoconf version to use.
AC_PREREQ(m4_sinclude(min_autoconf_version.m4))

dnl Some macros that we use.
m4_define([cwm4_relpath], [m4_if(m4_bregexp($1, [.*[^/]$]), -1, [$1], [$1/])])
m4_define([cwm4_quote], [m4_if([$#], [0], [], [[$*]])])
m4_define([cwm4_dquote], [[$@]])

dnl Where to find the CW_* macros.
AC_CONFIG_MACRO_DIR([cwm4/m4])

dnl Put resulting configuration defines in this header file.
AC_CONFIG_HEADERS([config.h])

dnl Include maintainer mode targets
AM_MAINTAINER_MODE

dnl Use libtool (lt_init.m4 will only exist when the project is actually using libtool).
m4_sinclude([lt_init.m4])

dnl Check for compiler and preprocessor
AC_PROG_CC_C99
AC_PROG_CXX
AC_PROG_CXXCPP

dnl Add --enable-debug (DEBUG, DOXYGEN_DEBUG), --enable-libcwd (CWDEBUG, DOXYGEN_CWDEBUG),
dnl --enable-optimise and --enable-profile options. Update USE_LIBCWD, CWD_LIBS and CXXFLAGS accordingly.
CW_OPG_FLAGS(CW_COMPILER_WARNINGS)

dnl Checks for other programs.
AC_PROG_INSTALL

dnl Suppress warning from ar by supplying U flag.
AC_SUBST(AR_FLAGS, [cruU])

dnl Check if we are the real maintainer.
AM_CONDITIONAL(REAL_MAINTAINER, test -z "$MAINTAINER_MODE_TRUE" -a dnl
  -n "$REPOBASE" -a dnl
  "$(echo "$GIT_COMMITTER_EMAIL" | md5sum | cut -d \  -f 1)" = dnl
  "$(sed -n -e 's/.*MAINTAINER_HASH=//p' "$REPOBASE/autogen.sh")")

dnl This source code is C++11 and thread-safe.
CXXFLAGS="$CXXFLAGS -pthread -std=c++11"
LIBCWD_FLAGS="$CWD_R_FLAGS"
LIBCWD_LIBS="$CWD_R_LIBS"
AC_SUBST(LIBCWD_FLAGS)
AC_SUBST(LIBCWD_LIBS)
