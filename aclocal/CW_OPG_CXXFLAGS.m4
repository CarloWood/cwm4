# CW_OPG_CXXFLAGS m4 macro -- this file is part of cwm4.
# Copyright (C) 2006, 2017, 2020 Carlo Wood <carlo@alinoe.com>
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

dnl CW_OPG_CXXFLAGS(COMPILE_FLAGS, THREADED, MAX_ERRORS)
dnl
dnl Add --enable-debug    (DEBUG, DOXYGEN_DEBUG),
dnl     --enable-libcwd   (CWDEBUG, DOXYGEN_CWDEBUG),
dnl     --enable-optimize
dnl and --enable-profile
dnl options.
dnl
dnl This macro sets CXXFLAGS to include -g (or -ggdb on FreeBSD) when
dnl debugging is required, -O2 when optimization is required, -pg when
dnl profiling is requested and appropriate warning flags (no warning
dnl flags are set when not in maintainer-mode).
dnl
dnl However, if CXXFLAGS already contains a -g* option then that is used
dnl instead of the default -g (-ggdb). If it contains a -O* option then
dnl that is used instead of -O2. Finally, if options are passed to
dnl the macro as COMPILE_FLAGS then those are used instead of the default
dnl ones. CXXFLAGS overrule COMPILE_FLAGS, which overrules the defaults
dnl defined in this macro.
dnl
dnl COMPILE_FLAGS may only specify -g*, -O*, -W* and/or -std=* flags.
dnl Any other flags will be ignored. In non-maintainer mode also all -W*
dnl flags are ignored.
dnl
dnl THREADED can be either [yes], [no] or [auto]/[], see the description
dnl in CW_LIB_LIBCWD.m4.
dnl
dnl MAX_ERRORS can be empty (no limit) or a positive integer, representing
dnl the maximum number of errors printed by the compiler.
dnl
dnl Updates USE_LIBCWD, LIBCWD(_R)_FLAGS, LIBCWD(_R)_LIBS, CXXFLAGS and
dnl LDFLAGS accordingly.
dnl
dnl Furthermore, the following macros are set:
dnl
dnl CW_DEBUG_FLAG       : Any -g* flags.
dnl CW_OPTIMIZE_FLAG    : Any -O* flags.
dnl CW_WARNING_FLAGS	: Any -W* flags.
dnl CW_STD_FLAG         : An -std=* flag.
dnl CW_STRIPPED_CXXFLAGS: Any other flags that were already in CXXFLAGS.
dnl
AC_DEFUN([CW_OPG_CXXFLAGS], [dnl
dnl Containers for the respective options.
m4_pattern_allow(CW_DEBUG_FLAG)
m4_pattern_allow(CW_OPTIMIZE_FLAG)
m4_pattern_allow(CW_WARNING_FLAGS)
m4_pattern_allow(CW_STD_FLAG)
m4_pattern_allow(CW_STRIPPED_CXXFLAGS)
m4_pattern_allow(CW_DEFAULT_DEBUG_FLAGS)
m4_pattern_allow(CW_MAX_ERRORS_FLAG)
m4_pattern_allow([CW_MAX_ERRORS])

# Add args to configure
AC_ARG_ENABLE(debug,         [  --enable-debug          build for debugging @<:@no@:>@], [cw_config_debug=$enableval], [cw_config_debug=])
AC_ARG_ENABLE(libcwd,        [  --enable-libcwd         link with libcwd @<:@auto@:>@], [cw_config_libcwd=$enableval], [cw_config_libcwd=])
AC_ARG_ENABLE(optimize,      [  --enable-optimize       do code optimization @<:@auto@:>@], [cw_config_optimize=$enableval], [cw_config_optimize=])
AC_ARG_ENABLE(profile,       [  --enable-profile        add profiling code @<:@no@:>@], [cw_config_profile=$enableval], [cw_config_profile=])

# Separate -g, -O, -W and -std= of COMPILE_FLAGS.
CW_DEBUG_FLAG2=
CW_OPTIMIZE_FLAG2=
CW_WARNING_FLAGS2=
CW_STRIPPED_CXXFLAGS2=
for arg in $1; do
case "$arg" in # (
-g*)
        CW_DEBUG_FLAG2="$arg"
        ;; # (
-O*)
        CW_OPTIMIZE_FLAG2="$arg"
        ;; # (
-W*)	CW_WARNING_FLAGS2="$CW_WARNING_FLAGS2 $arg"
	;; # (
-std=*)
        CW_STD_FLAG2="$arg"
        ;;
*)
        echo "Warning: ignoring flags $arg in COMPILER_FLAGS"
        ;;
esac
done

# Separate -g, -O, -W, -std= and other flags of CXXFLAGS.
CW_DEBUG_FLAG=
CW_OPTIMIZE_FLAG=
CW_WARNING_FLAGS=
CW_STD_FLAG=
CW_STRIPPED_CXXFLAGS=
for arg in $CXXFLAGS; do
case "$arg" in # (
-g*)
        CW_DEBUG_FLAG="$arg"
        ;; # (
-O*)
        CW_OPTIMIZE_FLAG="$arg"
        ;; # (
-W*)	CW_WARNING_FLAGS="$CW_WARNING_FLAGS $arg"
	;; # (
-std=*)
        CW_STD_FLAG="$arg"
        ;;
*)
        CW_STRIPPED_CXXFLAGS="$CW_STRIPPED_CXXFLAGS $arg"
        ;;
esac
done

# Flags in CXXCLAGS overrule.
test -n "$CW_DEBUG_FLAG" || CW_DEBUG_FLAG="$CW_DEBUG_FLAG2"
test -n "$CW_OPTIMIZE_FLAG" || CW_OPTIMIZE_FLAG="$CW_OPTIMIZE_FLAG2"
test -n "$CW_WARNING_FLAGS" || CW_WARNING_FLAGS="$CW_WARNING_FLAGS2"
test -n "$CW_STD_FLAG" || CW_STD_FLAG="$CW_STD_FLAG2"

# Set various defaults, depending on other options.

if test x"$cw_config_optimize" = x"no"; then
    CW_OPTIMIZE_FLAG=""        # Explicit --disable-optimize, strip optimization even from CXXFLAGS environment variable.
fi

if test x"$enable_maintainer_mode" = x"yes"; then
  if test -z "$cw_config_optimize"; then
    cw_config_optimize=no          # --enable-maintainer-mode, set default to --disable-optimize.
  fi
  if test -z "$cw_config_debug"; then
    cw_config_debug=yes            # --enable-maintainer-mode, set default to --enable-debug.
  fi
fi

if test x"$cw_config_debug" = x"yes"; then
  if test -z "$cw_config_optimize"; then
    cw_config_optimize=no          # --enable-debug and no --enable-optimize, set default to --disable-optimize.
  fi
else
  if test -z "$cw_config_libcwd"; then
    cw_config_libcwd=no            # No --enable-debug and no --enable-libcwd, set default to --disable-libcwd.
  fi
fi

dnl Find out which debugging options we need
AC_CANONICAL_HOST
case "$host" in
  *freebsd*) CW_DEFAULT_DEBUG_FLAGS=-ggdb ;; dnl FreeBSD needs -ggdb to include sourcefile:linenumber info in its object files.
  *) CW_DEFAULT_DEBUG_FLAGS=-g ;;
esac

# Handle cw_config_libcwd.
# Check if we have libcwd, $cw_config_libcwd can be "yes", "no" or "".
if test -z "$cw_used_libcwd"; then
CW_LIB_LIBCWD([libcwd], [$cw_config_libcwd], [$2])
# Abuse LIBCWD_R_FLAGS to pass -pthread to the compiler.
LIBCWD_R_FLAGS="-pthread${LIBCWD_R_FLAGS:+ }$LIBCWD_R_FLAGS"
fi
USE_LIBCWD="$cw_used_libcwd"
AC_SUBST([USE_LIBCWD])
if test "$cw_used_libcwd" = "yes"; then
  test -n "$CW_DEBUG_FLAG" || CW_DEBUG_FLAG="$CW_DEFAULT_DEBUG_FLAGS"
  if test -z "$cw_config_optimize"; then
    cw_config_optimize=no          # libcwd is being used, set default to --disable-optimize.
  fi
  DOXYGEN_CWDEBUG=CWDEBUG
else
  DOXYGEN_CWDEBUG=
fi
AC_SUBST([DOXYGEN_CWDEBUG])

# Handle cw_config_debug.
if test x"$cw_config_debug" = x"yes"; then
  CW_STRIPPED_CXXFLAGS="$CW_STRIPPED_CXXFLAGS -DDEBUG"
  DOXYGEN_DEBUG=DEBUG
  test -n "$CW_DEBUG_FLAG" || CW_DEBUG_FLAG="$CW_DEFAULT_DEBUG_FLAGS"
else
  DOXYGEN_DEBUG=
fi
AC_SUBST([DOXYGEN_DEBUG])

# Handle cw_config_optimize; when not explicitly set to "no", use user provided
# optimization flags, or -O2 when nothing was provided.
if test x"$cw_config_optimize" != x"no"; then
  test -n "$CW_OPTIMIZE_FLAG" || CW_OPTIMIZE_FLAG="-O2"
elif test "$ac_test_CXXFLAGS" != set; then
  # If CXXFLAGS was set by configure, reset CW_OPTIMIZE_FLAG.
  CW_OPTIMIZE_FLAG=
fi

# Handle cw_config_profile.
if test x"$cw_config_profile" = x"yes"; then
  CW_STRIPPED_CXXFLAGS="$CW_STRIPPED_CXXFLAGS -pg"
  LDFLAGS="$LDFLAGS -pg"
fi

# Choose warning options to use.
# If not in maintainer mode, use the warning options that were in CXXFLAGS.
# Otherwise, use those plus any passed to the macro, or if neither are
# given a default string - and then filter out incompatible warnings.
if test x"$enable_maintainer_mode" = x"yes"; then
  test -n "$CW_WARNING_FLAGS" || CW_WARNING_FLAGS="-W -Wall -Woverloaded-virtual -Wundef -Wpointer-arith -Wwrite-strings -Werror -Winline"
  AC_EGREP_CPP(Winline-broken, [
#if __GNUC__ < 3
  Winline-broken
#endif
  ],
     dnl -Winline is broken.
     [CW_WARNING_FLAGS="$(echo "$CW_WARNING_FLAGS" | sed -e 's/ -Winline//g')"],
     dnl -Winline is not broken. Remove -Werror when optimizing though.
     [if test -n "$CW_OPTIMIZE_FLAG"; then
        CW_WARNING_FLAGS="$(echo "$CW_WARNING_FLAGS" | sed -e 's/ -Werror//g')"
      fi]
  )
fi

# Determine the flag that limits the number of errors to one.
CW_MAX_ERRORS_FLAG=
if m4_changequote([`],['])[[m4_changequote(`[',`]') "$3" m4_changequote([`],['])=~ ^[0-9]+$ ]]m4_changequote(`[',`]'); then
  if test $3 -gt 0; then
    AC_LANG_SAVE
    AC_LANG([C++])
    AX_CHECK_COMPILE_FLAG([-ferror-limit=$3], [CW_MAX_ERRORS_FLAG="-ferror-limit=$3"], [
    AX_CHECK_COMPILE_FLAG([-fmax-errors=$3], [CW_MAX_ERRORS_FLAG="-fmax-errors=$3"], [], [-Werror])], [-Werror])
    AC_LANG_RESTORE
  fi
fi

# Reassemble CXXFLAGS with max-error, debug and optimization flags.
[CXXFLAGS=`echo "$CW_STD_FLAG" "$CW_MAX_ERRORS_FLAG $CW_DEBUG_FLAG $CW_WARNING_FLAGS $CW_OPTIMIZE_FLAG $CW_STRIPPED_CXXFLAGS" | sed -e 's/^ *//' -e 's/  */ /g' -e 's/ *$//'`]

dnl Put CXXFLAGS into the Makefile.
AC_SUBST(CXXFLAGS)
dnl Allow fine tuning if necessary, by substituting the parts too.
AC_SUBST(CW_DEBUG_FLAG)
AC_SUBST(CW_WARNING_FLAGS)
AC_SUBST(CW_OPTIMIZE_FLAG)
AC_SUBST(CW_STRIPPED_CXXFLAGS)
])
