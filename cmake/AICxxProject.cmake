# Default message log level. Use cmake --log-level=debug to get DEBUG output.
set( CMAKE_MESSAGE_LOG_LEVEL "STATUS" )

# Check if AICxxProject was included correctly.
if ( NOT top_srcdir )
  message( FATAL_ERROR
    "Add the following to the top of the CMakeLists.txt file, just below the `project(...)` command, in the root of the project:\n"
    "  include(cwm4/cmake/AICxxProject)    # <=== ADD THIS\n" )
endif ()

# Print the current subdirectory, relative to the project root.
file( RELATIVE_PATH current_subdirectory "${top_srcdir}" "${CMAKE_CURRENT_SOURCE_DIR}" )
if ( "${current_subdirectory}" STREQUAL "" )
  message( STATUS "----------------------------------------------------\n** Configuring project ${CMAKE_PROJECT_NAME}:" )
else ()
  message( STATUS "----------------------------------------------------\n** Configuring subdirectory ${current_subdirectory}:" )
endif ()

# Add support for CMAKE_BUILD_TYPE, EnableDebug, EnableGlobalDebug, EnableLibcwd
include( CW_OPTIONS )

#==============================================================================
# Find required libraries
#

set( THREADS_PREFER_PTHREAD_FLAG true ) # See https://stackoverflow.com/a/39547577/1487069
find_package( Threads REQUIRED )

# Initialize AICXX_OBJECTS_LIST
include( AICxxObjectsList )
