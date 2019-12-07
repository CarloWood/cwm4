# Params: <option-name> <help-string> <default> <dependent-list> <default2>
#
# Sets 'Option<option-name>' to ON or OFF.
# If <option-name> is set to ON or OFF (from the commandline), then
# this is cached and reused the next time. Otherwise <default> is used.
#
# <dependent-list> is a list with zero or more variable names (semicolon
# separated) that must all be TRUE however, or the value of
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

  set( option_dependent_list_is_true TRUE )
  foreach ( OptionDependency ${ARGV3} )
    if ( NOT ${OptionDependency} )
      set( option_dependent_list_is_true FALSE )
      set( extra_info " (forced because ${OptionDependency} is not true)" )
      set( forced_value TRUE )
      message( DEBUG "  dependency: ${OptionDependency} is not TRUE; using argument 5 (${ARGV4})" )
      break()
    endif ()
  endforeach()
  if ( NOT option_dependent_list_is_true )
    # Use the <default2> parameter.
    if ( ${ARGV4} )
      set( Option${ARGV0} ON )
    else ()
      set( Option${ARGV0} OFF )
    endif ()
  elseif ( "${${ARGV0}}" STREQUAL "ON" OR "${${ARGV0}}" STREQUAL "OFF" )
    # Just (re-)set the help string.
    set( ${ARGV0} "${${ARGV0}}" CACHE BOOL "${ARGV1}" FORCE )
    set( Option${ARGV0} ${${ARGV0}} )
    set( extra_info " (cached)")
  else ()
    # Use the <default> that was passed.
    set( ${ARGV0} "DEFAULT" CACHE STRING "${ARGV1}; can be ON or OFF" )
    set( Option${ARGV0} ${ARGV2} )
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
string( TOUPPER "${CMAKE_BUILD_TYPE}" BUILD_TYPE_UPPER )
if ( "${BUILD_TYPE_UPPER}" STREQUAL "RELEASE" )
  set( CMAKE_BUILD_TYPE "Release" CACHE STRING "Build Type" FORCE )
elseif ( "${BUILD_TYPE_UPPER}" STREQUAL "DEBUG" )
  set( CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build Type" FORCE )
else ()
  message( FATAL_ERROR "Unknown CMAKE_BUILD_TYPE \"${CMAKE_BUILD_TYPE}\"." )
endif ()
message( DEBUG "CMAKE_BUILD_TYPE = ${CMAKE_BUILD_TYPE}" )
if (CMAKE_BUILD_TYPE STREQUAL "Release")
  set( CW_BUILD_TYPE_IS_RELEASE ON )
else ()
  set( CW_BUILD_TYPE_IS_RELEASE OFF )
endif ()
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  set( CW_BUILD_TYPE_IS_DEBUG ON )
else ()
  set( CW_BUILD_TYPE_IS_DEBUG OFF )
endif ()
message( STATUS "Option CMAKE_BUILD_TYPE =\n\t${CMAKE_BUILD_TYPE}" )
