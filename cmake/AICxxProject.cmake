# Default message log level. Use cmake --log-level=debug to get DEBUG output.
set( CMAKE_MESSAGE_LOG_LEVEL "STATUS" )

# Set CW_PROJECT_ROOT_DIR.
# We're supposed to get here for the first time from the project root.
set( project_root "${CMAKE_CURRENT_SOURCE_DIR}" )
# But if that is not the case then we'll get here first from cwds.
get_filename_component( current_source_dir_name "${CMAKE_CURRENT_SOURCE_DIR}" NAME )
if ( current_source_dir_name STREQUAL "cwds" )
  # cwds is always in the project root.
  get_filename_component( project_root "${CMAKE_CURRENT_SOURCE_DIR}/.." ABSOLUTE )
endif()
if ( NOT CW_PROJECT_ROOT_DIR )
  set( CW_PROJECT_ROOT_DIR "${project_root}" CACHE STRING "The real path of the root of the project." )
  message( STATUS "Project root determined to be \"${CW_PROJECT_ROOT_DIR}\"." )
endif ()

# Print the current subdirectory, relative to the project root.
file( RELATIVE_PATH current_subdirectory "${CW_PROJECT_ROOT_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}" )
message( STATUS "----------------------------------------------------\n** Configuring subdirectory ${current_subdirectory}:" )

# Add support for CMAKE_BUILD_TYPE, EnableDebug, EnableGlobalDebug, EnableLibcwd
include(CW_OPTIONS)

#==============================================================================
# Find required libraries
#

set( THREADS_PREFER_PTHREAD_FLAG true ) # See https://stackoverflow.com/a/39547577/1487069
find_package( Threads REQUIRED )

# Initialize AICXX_OBJECTS_LIST
include(AICxxObjectsList)
