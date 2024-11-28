dnl Detect unexpanded macros.
m4_pattern_forbid([^AX_]) dnl These macros are defined in the package 'autoconf-archive' available from the ubuntu "universe" repository.
m4_pattern_forbid([^CW_])
m4_pattern_forbid([^LT_])

dnl Package name and version
m4_ifdef([CW_VERSION_REVISION], [
  m4_define([cwm4_version_full], [CW_VERSION_MAJOR.CW_VERSION_MINOR.CW_VERSION_REVISION])], [
  m4_define([cwm4_version_full], [CW_VERSION_MAJOR.CW_VERSION_MINOR])]
)
AC_INIT([CW_PACKAGE_NAME],[cwm4_version_full],[CW_BUGREPORT])
AC_CONFIG_AUX_DIR(.)

dnl Automake options.
AM_INIT_AUTOMAKE(m4_sinclude([m4/min_automake_version.m4])[foreign subdir-objects])

dnl Minimum autoconf version to use.
AC_PREREQ([2.71])

dnl Some macros that we use.
m4_define([cwm4_relpath], [m4_if(m4_bregexp($1, [.*[^/]$]), -1, [$1], [$1/])])
m4_define([cwm4_quote], [m4_if([$#], [0], [], [[$*]])])
m4_define([cwm4_dquote], [[$@]])

dnl Where libtoolize should put it's macro files.
AC_CONFIG_MACRO_DIR([m4/aclocal])

dnl Put resulting configuration defines in this header file.
AC_CONFIG_HEADERS([config.h])

dnl Include maintainer mode targets
AM_MAINTAINER_MODE

dnl Check for compiler and preprocessor
AC_PROG_CC
AC_PROG_CXX
AC_PROG_CXXCPP

dnl Substitute VERSIONINFO when CW_INTERFACE_VERSION is set.
m4_ifdef([CW_INTERFACE_VERSION], [# Libtool version info
VERSIONINFO="CW_INTERFACE_VERSION:CW_INTERFACE_VERSION_REVISION:CW_INTERFACE_AGE"
AC_SUBST(VERSIONINFO)])

dnl Add --enable-debug (DEBUG, DOXYGEN_DEBUG), --enable-libcwd (CWDEBUG, DOXYGEN_CWDEBUG), --enable-optimize and --enable-profile options.
dnl Update USE_LIBCWD, LIBCWD(_R)_FLAGS, LIBCWD(_R)_LIBS and CXXFLAGS accordingly.
dnl The first parameter should only contain warning flags: these flags are not used when not using maintainer-mode.
dnl Second parameter can be [no] (single-threaded), [yes] (multi-threaded) or [both] (single and multi-threaded applications).
dnl Third parameter can be empty (no limit), or an integer (larger than 0) to limit the maximum number of printed compiler errors.
CW_OPG_CXXFLAGS([CW_COMPILE_FLAGS], [CW_THREADS], [CW_MAX_ERRORS])

dnl Use libtool (lt_init.m4 will only exist when the project is actually using libtool).
m4_sinclude([m4/lt_init.m4])

dnl Checks for other programs.
AC_PROG_INSTALL

dnl Suppress warning from ar by supplying U flag.
dnl There seem to be two variants of AR[_]FLAGS in use, set both.
AC_SUBST(AR_FLAGS, [cruU])
AC_SUBST(ARFLAGS, [cruU])

dnl Check if we are the real maintainer.
cw_real_maintainer=0
if test -z "$MAINTAINER_MODE_TRUE" -a -n "$REPOBASE"; then
  if test "$(echo "$GIT_COMMITTER_EMAIL" | md5sum | cut -d \  -f 1)" = dnl
      "$(sed -n -e 's/.*MAINTAINER_HASH=//p' "$REPOBASE/autogen.sh")"; then
    cw_real_maintainer=1
  fi
fi
AM_CONDITIONAL(REAL_MAINTAINER, test $cw_real_maintainer = 1)
