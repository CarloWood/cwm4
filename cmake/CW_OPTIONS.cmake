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
# OptionEnableDebug                     - set when CMAKE_BUILD_TYPE is not Release and -DEnableDebug:BOOL=ON (defaults to CW_BUILD_TYPE_IS_DEBUG)
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
#
# Usage example,
#
#       # Option 'EnableDebug' compiles in debug mode.
#       option( EnableDebug
#               "Build for debugging" ${CW_BUILD_TYPE_IS_DEBUG}
#               "CW_BUILD_TYPE_IS_NOT_RELEASE" OFF )
#
# where argument four is a semi-colon separated list of variables
# that must be true for this option to be added (otherwise OFF,
# argument five).

include_guard(GLOBAL)

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
macro(option)
  message( DEBUG "  in: ${ARGV0} = ${${ARGV0}}" )
  set( extra_info "" )
  set( forced_value FALSE )

  set( option_dependent_list_is_true true )
  foreach ( OptionDependency ${ARGV3} )
    if ( NOT ${OptionDependency} )
      set( option_dependent_list_is_true FALSE )
      set( extra_info " (forced because ${OptionDependency} is OFF)" )
      set( forced_value true )
      message( DEBUG "  dependency: ${OptionDependency} is OFF; using argument 5 (${ARGV4})" )
      break()
    endif ()
  endforeach()
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
    message( DEBUG "Option ${ARGV0} (${ARGV1}) =\n\t${Option${ARGV0}}${extra_info}" )
  else ()
    message( STATUS "Option ${ARGV0} (${ARGV1}) =\n\t${Option${ARGV0}}${extra_info}" )
  endif ()
endmacro ()

# Normalize the build type capitalization and handle NONE case.
if ( NOT CMAKE_BUILD_TYPE )
  set( CMAKE_BUILD_TYPE Release )
endif ()
message( DEBUG "CMAKE_CONFIGURATION_TYPES = ${CMAKE_CONFIGURATION_TYPES}" )
string( TOUPPER "${CMAKE_BUILD_TYPE}" BUILD_TYPE_UPPER )
if ( "${BUILD_TYPE_UPPER}" STREQUAL "RELEASE" )
  set( CMAKE_BUILD_TYPE "Release" CACHE STRING "Build Type" FORCE )
elseif ( "${BUILD_TYPE_UPPER}" STREQUAL "DEBUG" )
  set( CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build Type" FORCE )
elseif ( "${BUILD_TYPE_UPPER}" STREQUAL "RELWITHDEBINFO" )
  set( CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING "Build Type" FORCE )
else ()
  message( FATAL_ERROR "Unknown CMAKE_BUILD_TYPE \"${CMAKE_BUILD_TYPE}\"." )
endif ()
message( DEBUG "CMAKE_BUILD_TYPE = ${CMAKE_BUILD_TYPE}" )
if (CMAKE_BUILD_TYPE STREQUAL "Release")
  set( CW_BUILD_TYPE_IS_RELEASE ON CACHE INTERNAL "" )
  set( CW_BUILD_TYPE_IS_NOT_RELEASE OFF CACHE INTERNAL "" )
else ()
  set( CW_BUILD_TYPE_IS_RELEASE OFF CACHE INTERNAL "" )
  set( CW_BUILD_TYPE_IS_NOT_RELEASE ON CACHE INTERNAL "" )
endif ()
if (CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
  set( CW_BUILD_TYPE_IS_RELWITHDEBINFO ON CACHE INTERNAL "" )
else ()
  set( CW_BUILD_TYPE_IS_RELWITHDEBINFO OFF CACHE INTERNAL "" )
endif ()
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  set( CW_BUILD_TYPE_IS_DEBUG ON CACHE INTERNAL "" )
else ()
  set( CW_BUILD_TYPE_IS_DEBUG OFF CACHE INTERNAL "" )
endif ()
message( STATUS "Option CMAKE_BUILD_TYPE =\n\t${CMAKE_BUILD_TYPE}" )

# Option 'EnableDebug' compiles in debug mode.
option( EnableDebug
        "Build for debugging" ${CW_BUILD_TYPE_IS_DEBUG}
        "CW_BUILD_TYPE_IS_NOT_RELEASE" OFF )

message( DEBUG "OptionEnableDebug is ${OptionEnableDebug}" )

if (CW_BUILD_TYPE_IS_NOT_RELEASE AND OptionEnableDebug)
  find_package( PkgConfig )
  pkg_check_modules( Libcwd_r libcwd_r IMPORTED_TARGET GLOBAL )
endif()

# Option 'EnableLibcwd' links with libcwd in debug mode.
option( EnableLibcwd
        "link with libcwd" ${Libcwd_r_FOUND}
        "CW_BUILD_TYPE_IS_NOT_RELEASE;OptionEnableDebug" OFF )

if (OptionEnableLibcwd AND NOT Libcwd_r_FOUND)
  message( FATAL_ERROR "EnableLibcwd specified but libcwd_r not found!" )
endif()
