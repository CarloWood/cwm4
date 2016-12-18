# CW_BOOST m4 macro -- this file is part of cwautomacros.
# Copyright (C) 2006, 2014 Carlo Wood <carlo@alinoe.com>
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

# CW_BOOST(STATIC, THREADS, LIBLIST)
# ----------------------------------
#
# Setup CXXFLAGS and LIBS for use with boost.
# Also USE_LIBBOOST is defined.
#
# STATIC must be 'yes' when we want to link to the static libraries.
# THREADS must be 'yes' if we need the thread-safe libraries.
# LIBLIST is a space seperated list of boost library names we want.
AC_DEFUN([CW_BOOST],
[dnl
# Require cw_used_libcwd and cw_config_debug to be set already.
AC_REQUIRE([CW_OPG_FLAGS])
# Add a few configure scripts that allow the user to specify values that we might not be able to find ourselves.
AC_ARG_ENABLE(boost-root, [dnl
  --enable-boost-root=/path/to/boost_root
                          specify the root path where boost is installed @<:@auto@:>@])
AC_ARG_ENABLE(boost-toolset, [dnl
  --enable-boost-toolset=bcb|como|cw8|osx|edg|gcc|il|iw|kcc|bck|cw|mgw|mp|vc|sw|tru|xlc|vc|...
                          specify the toolset that boost was compiled with. See also
                          http://www.boost.org/more/getting_started.html @<:@auto@:>@])

# Determine BOOST_ROOT
CW_BOOST_ROOT(["$enable_boost_root"])
if test -z "$BOOST_ROOT"; then
  AC_MSG_ERROR([Cannot find installed boost libraries (www.boost.org).
Please set the environment variable BOOST_ROOT to the correct value
or use the configure option --enable-boost-root=/path/to/boost_root.])
fi

# Determine BOOST_VERSION
CW_BOOST_VERSION
if test -z "$BOOST_VERSION"; then
  AC_MSG_ERROR([Cannot figure out the version of the boost libraries in $BOOST_ROOT/lib.
Please set the environment variable BOOST_VERSION to the correct value.])
fi

#Determine BOOST_TOOLSET
CW_BOOST_TOOLSET(["$enable_boost_toolset"])
if test -z "$BOOST_TOOLSET"; then
  AC_MSG_ERROR([Cannot find an appropriate toolset for the boost libraries in $BOOST_ROOT/lib.
Please set the environment variable BOOST_TOOLSET to the correct value
or use the configure option --enable-boost-toolset=<toolset>.])
fi

AC_DEFINE_UNQUOTED([USE_LIBBOOST], 1, [Define when boost is used with this project.])

# Set a few handy variables.
cw_boost_lib_prefix=lib
cw_boost_lib_postfix=so
if test "$1" = "yes"; then
  cw_boost_lib_postfix=a
fi
if expr match "$build_os" ".*-mingw32$" >/dev/null ||
   expr match "$build_os" ".*-cygwin" >/dev/null
then
  cw_boost_lib_postfix=dll
  if test "$1" = "yes"; then
    cw_boost_lib_postfix=lib
  else
    cw_boost_lib_prefix=
  fi
fi
cw_boost_threading=
if test "$2" = "yes"; then
  cw_boost_threading="-mt"
fi

# Fix CXXFLAGS
if test "$BOOST_TOOLSET" = "none"; then
  if test "$BOOST_ROOT" != "/usr"; then
    CXXFLAGS="$CXXFLAGS -I\"$BOOST_ROOT/include\""
  fi
else
  CXXFLAGS="$CXXFLAGS -I\"$BOOST_ROOT/include/boost-$BOOST_VERSION\""
fi

if test -n "$3"; then

  # Fix LIBS
  if test -n "$BOOST_ROOT" -a "$BOOST_ROOT" != "/usr"; then
    LIBS="$LIBS -L\"$BOOST_ROOT/lib$cw_boost_build\""
  fi

  # Run over each requested library
  for l in $3; do
    # Strip off possible prefixes.
    cw_boost_lib_name=`echo "$l" | sed -e 's/^libboost_//' -e 's/boost_//'`
    # Fix LIBS
    if test "$BOOST_TOOLSET" = "none"; then
      LIBS="$LIBS -lboost_$cw_boost_lib_name"
    else
      # Get a list of possible runtime flags.
      cw_boost_runtime_flags="`ls "$BOOST_ROOT"/lib"$cw_boost_build/$cw_boost_lib_prefix""boost_$cw_boost_lib_name-$BOOST_TOOLSET$cw_boost_threading"*"-$BOOST_VERSION.$cw_boost_lib_postfix" | \
	grep "$cw_boost_lib_prefix""boost_$cw_boost_lib_name-$BOOST_TOOLSET$cw_boost_threading-[[dgnpsy]]*-$BOOST_VERSION\.$cw_boost_lib_postfix\$" | \
	sed -e 's/.*boost_'$cw_boost_lib_name-$BOOST_TOOLSET$cw_boost_threading'-\([[dgnpsy]]*\)-'$BOOST_VERSION'\.'$cw_boost_lib_postfix'$/\1/' | \
	sort -u`"
      # Determine the runtime flags we want to use.
      cw_boost_runtime=
      if test x"$cw_used_libcwd" = x"yes" -o x"$cw_config_debug" = x"yes"; then
	if echo "$cw_boost_runtime_flags" | grep '^d$' >/dev/null; then
	  cw_boost_runtime=-d
	fi
      fi
      LIBS="$LIBS -lboost_$cw_boost_lib_name-$BOOST_TOOLSET$cw_boost_threading$cw_boost_runtime-$BOOST_VERSION"
    fi
  done

fi
])

