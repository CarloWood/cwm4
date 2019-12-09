# Default message log level. Use cmake --log-level=debug to get DEBUG output.
set( CMAKE_MESSAGE_LOG_LEVEL "STATUS" )

# Add support for CMAKE_BUILD_TYPE, EnableDebug, EnableGlobalDebug, EnableLibcwd
include(CW_OPTIONS)

#==============================================================================
# Find required libraries
#

set( THREADS_PREFER_PTHREAD_FLAG true ) # See https://stackoverflow.com/a/39547577/1487069
find_package( Threads REQUIRED )

# Initialize AICXX_OBJECTS_LIST
include(AICxxObjectsList)
