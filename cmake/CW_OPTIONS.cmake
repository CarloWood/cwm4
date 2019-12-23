# option cmake macro -- this file is part of cwm4.
# Copyright (C) 2019  Carlo Wood <carlo@alinoe.com>
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
# by a tool like cmake when using these functions as input.  You need
# not follow the terms of the GNU General Public License when using or
# distributing such scripts, even though portions of the text of this
# file appears in them. The GNU General Public License (GPL) does govern
# all other use of the material that constitutes the cwm4 project.

# This module should only be included from AICxxProject.
#
# It sets the following global variables:
#
# OptionEnableDebug                     - set when CMAKE_BUILD_TYPE is not Release and -DEnableDebug:BOOL=ON
#                                         (defaults to CW_BUILD_TYPE_IS_DEBUG || CW_BUILD_TYPE_IS_RELWITHDEBUG)
# OptionEnableLibcwd                    - set when CMAKE_BUILD_TYPE is not Release and OptionEnableDebug is true,
#                                         and -DEnableLibcwd:BOOL=ON (defaults to Libcwd_r_FOUND)
#
# The following variables are intended to be used with the macro 'option'
# defined below.
#
# CW_BUILD_TYPE_IS_RELEASE              - true iff CMAKE_BUILD_TYPE = Release
# CW_BUILD_TYPE_IS_NOT_RELEASE          - true iff CMAKE_BUILD_TYPE != Release
# CW_BUILD_TYPE_IS_RELWITHDEBINFO       - true iff CMAKE_BUILD_TYPE = RelWithDebInfo
# CW_BUILD_TYPE_IS_DEBUG                - true iff CMAKE_BUILD_TYPE = Debug
# CW_BUILD_TYPE_IS_BETATEST             - true iff CMAKE_BUILD_TYPE = BetaTest
# CW_BUILD_TYPE_IS_RELWITHDEBUG         - true iff CMAKE_BUILD_TYPE = RelWithDebug
#
# Usage example,
#
#       # Option 'EnableDebug' compiles in debug mode.
#       cw_option( EnableDebug
#               "Build for debugging" ${CW_BUILD_TYPE_IS_DEBUG}
#               "CW_BUILD_TYPE_IS_NOT_RELEASE" OFF )
#
# where argument four is a semi-colon separated list of variables
# that must be true for this option to be added (otherwise OFF,
# argument five).

include_guard( GLOBAL )
include( color_vars )
set( Option "${BoldCyan}Option${ColourReset}" )
set( OptionColor "${Green}" )
set( OptionColorYay "${Green}" )
set( OptionColorAlert "${Red}" )
set( OptionColorBuildType "${OptionColorAlert}" )

# Clear INTERNAL cache values at start of project.
set( CW_BUILD_TYPE_IS_RELEASE ON CACHE INTERNAL "" )
set( CW_BUILD_TYPE_IS_NOT_RELEASE OFF CACHE INTERNAL "" )
set( CW_BUILD_TYPE_IS_RELWITHDEBINFO OFF CACHE INTERNAL "" )
set( CW_BUILD_TYPE_IS_DEBUG OFF CACHE INTERNAL "" )
unset( OptionEnableDebug )
unset( OptionEnableLibcwd )

# Params: <option-name> <help-string> <default> <dependent-list> <default2>
#
# Sets 'Option<option-name>' to ON or OFF.
# If <option-name> is set to ON or OFF (from the commandline), then
# this is cached and reused the next time. Otherwise <default> is used.
#
# <dependent-list> is a list with zero or more variable names (semicolon
# separated) that must all be true however, or the value of
# 'Option<option-name>' is set to <default2> (defaults to OFF).
#
# option-name   : The name of the option. For example "EnableDebug".
# help-string   : The help string of the option with trailing period. For example "To enable debugging."
# default       : The uncached value to use when nothing was (previously) specified on the commandline.
# dependent-list: A semi-colon separated list of variables that all have to be true.
# default2      : The value to use when one or more of the variables in dependent-list is not true.
#
macro( cw_option )
  message( DEBUG "  in: ${ARGV0} = ${${ARGV0}}" )
  set( extra_info "" )
  set( forced_value FALSE )

  set( option_dependent_list_is_true true )
  if ( NOT "${ARGV3}" STREQUAL "" )
    foreach ( OptionDependency ${ARGV3} )
      if ( NOT ${OptionDependency} )
        set( option_dependent_list_is_true FALSE )
        string( SUBSTRING ${OptionDependency} 0 12 lead )
        if ( lead STREQUAL "OptionEnable" )
          set( value "OFF" )
          string( SUBSTRING ${OptionDependency} 6 -1 name )
        else ()
          set( value "false" )
          set( name ${OptionDependency} )
        endif ()
        set( extra_info " (forced because ${name} is ${value})" )
        set( forced_value true )
        message( DEBUG "  dependency: ${name} is ${value}; using argument 5 (${ARGV4})" )
        break()
      endif ()
    endforeach ()
  endif ()
  if ( NOT option_dependent_list_is_true )
    # Use the <default2> parameter.
    if ( ${ARGV4} )
      set( Option${ARGV0} ON CACHE INTERNAL "" )
    else ()
      set( Option${ARGV0} OFF CACHE INTERNAL "" )
    endif ()
  elseif ( "${${ARGV0}}" STREQUAL "ON" OR "${${ARGV0}}" STREQUAL "OFF" )
    # Just (re-)set the help string.
    set( ${ARGV0} "${${ARGV0}}" CACHE BOOL "${ARGV1}" FORCE )
    set( Option${ARGV0} ${${ARGV0}} CACHE INTERNAL "" )
    set( extra_info " (cached)")
  else ()
    # Use the <default> that was passed.
    set( ${ARGV0} "DEFAULT" CACHE STRING "${ARGV1}; can be ON or OFF" )
    set( Option${ARGV0} ${ARGV2} CACHE INTERNAL "" )
    set( extra_info " (default)" )
  endif ()

  # Clobber the cached variable (as a normal variable) to make it harder to accidently use it.
  set( ${ARGV0} "Use the variable Option${ARGV0} instead of ${ARGV0}." )
  if ( forced_value )
    message( DEBUG "${Option} ${OptionColor}${ARGV0}${ColourReset} (${ARGV1}) =\n\t${Option${ARGV0}}${extra_info}" )
    #message( DEBUG "${Option} ${ARGV0} (${ARGV1}) = ${Option${ARGV0}}${extra_info}" )
  elseif ( (${Option${ARGV0}} AND ${ARGV2}) OR NOT (${Option${ARGV0}} OR ${ARGV2}) )
    message( STATUS "${Option} ${OptionColor}${ARGV0}${ColourReset} (${ARGV1}) =\n\t${OptionColorYay}${Option${ARGV0}}${ColourReset}${extra_info}" )
    #message( STATUS "${Option} ${ARGV0} (${ARGV1}) = ${OptionColorYay}${Option${ARGV0}}${ColourReset}${extra_info}" )
  else ()
    message( STATUS "${Option} ${OptionColor}${ARGV0}${ColourReset} (${ARGV1}) =\n\t${OptionColorAlert}${Option${ARGV0}}${ColourReset}${extra_info}" )
    #message( STATUS "${Option} ${ARGV0} (${ARGV1}) = ${OptionColorAlert}${Option${ARGV0}}${ColourReset}${extra_info}" )
  endif ()
endmacro ()

# Normalize the build type capitalization and handle NONE case.
if ( NOT CMAKE_BUILD_TYPE )
  set( CMAKE_BUILD_TYPE Release )
endif ()
string( TOUPPER "${CMAKE_BUILD_TYPE}" BUILD_TYPE_UPPER )
if ( "${BUILD_TYPE_UPPER}" STREQUAL "RELEASE" )
  set( CMAKE_BUILD_TYPE "Release" CACHE STRING "Build Type" FORCE )
  set( OptionColorBuildType "${OptionColorYay}" )
elseif ( "${BUILD_TYPE_UPPER}" STREQUAL "DEBUG" )
  set( CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build Type" FORCE )
elseif ( "${BUILD_TYPE_UPPER}" STREQUAL "RELWITHDEBINFO" )
  set( CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING "Build Type" FORCE )
elseif ( "${BUILD_TYPE_UPPER}" STREQUAL "BETATEST" )
  set( CMAKE_BUILD_TYPE "BetaTest" CACHE STRING "Build Type" FORCE )
elseif ( "${BUILD_TYPE_UPPER}" STREQUAL "RELWITHDEBUG" )
  set( CMAKE_BUILD_TYPE "RelWithDebug" CACHE STRING "Build Type" FORCE )
else ()
  message( FATAL_ERROR "Unknown CMAKE_BUILD_TYPE \"${CMAKE_BUILD_TYPE}\"." )
endif ()
set( default_enable_debug OFF )
if (NOT CMAKE_BUILD_TYPE STREQUAL "Release")
  set( CW_BUILD_TYPE_IS_RELEASE OFF CACHE INTERNAL "" )
  set( CW_BUILD_TYPE_IS_NOT_RELEASE ON CACHE INTERNAL "" )
endif ()
if (CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
  set( CW_BUILD_TYPE_IS_RELWITHDEBINFO ON CACHE INTERNAL "" )
endif ()
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  set( CW_BUILD_TYPE_IS_DEBUG ON CACHE INTERNAL "" )
  set( default_enable_debug ON )
endif ()
if (CMAKE_BUILD_TYPE STREQUAL "BetaTest")
  set( CW_BUILD_TYPE_IS_BETATEST ON CACHE INTERNAL "" )
endif ()
if (CMAKE_BUILD_TYPE STREQUAL "RelWithDebug")
  set( CW_BUILD_TYPE_IS_RELWITHDEBUG ON CACHE INTERNAL "" )
  set( default_enable_debug ON )
endif ()
message( STATUS "${Option} ${OptionColor}CMAKE_BUILD_TYPE${ColourReset} =\n\t${OptionColorBuildType}${CMAKE_BUILD_TYPE}${ColourReset}" )
#message( STATUS "${Option} ${OptionColor}CMAKE_BUILD_TYPE${ColourReset} = ${OptionColorBuildType}${CMAKE_BUILD_TYPE}${ColourReset}" )

# Option 'EnableDebug' compiles in debug mode: we want debug code, debug output (if available),
# asserts, debug info - but not necessary no optimization.
cw_option( EnableDebug
        "Build for debugging" ${default_enable_debug}
        "CW_BUILD_TYPE_IS_NOT_RELEASE" OFF )

message( DEBUG "OptionEnableDebug is ${OptionEnableDebug}" )

if (CW_BUILD_TYPE_IS_NOT_RELEASE AND OptionEnableDebug)
  find_package( PkgConfig )
  pkg_check_modules( Libcwd_r libcwd_r IMPORTED_TARGET GLOBAL )
  if (Libcwd_r_FOUND)
    set( default_enable_libcwd ON )
  else ()
    set( default_enable_libcwd OFF )
  endif ()
endif ()

# Option 'EnableLibcwd' links with libcwd in debug mode.
cw_option( EnableLibcwd
        "link with libcwd" "${default_enable_libcwd}"
        "CW_BUILD_TYPE_IS_NOT_RELEASE;OptionEnableDebug" OFF )

if (OptionEnableLibcwd AND NOT Libcwd_r_FOUND)
  message( FATAL_ERROR "EnableLibcwd specified but libcwd_r not found!" )
endif ()
