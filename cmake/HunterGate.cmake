# FetchContent_MakeAvailable is available since CMake version 3.14.
cmake_minimum_required( VERSION 3.14 )

include( FetchContent )

# Uncomment to use local git submodule for Hunter.
#set( HUNTER_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/cwm4/hunter" )

# Setting up external packages.
#set( HUNTER_Boost_COMPONENTS filesystem iostreams program_options system )
#set( HUNTER_PACKAGES Boost farmhash )
set( HUNTER_PACKAGES farmhash )

# Use local git submodule in the source tree.
FetchContent_Declare( SetupHunter SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cwm4/hunter/gate" )
# Initialize Hunter and build external pacakges.
FetchContent_MakeAvailable( SetupHunter )

# Refresh CMAKE_MODULE_PATH (this call isn't using the URL or SHA1, what is really being
# used can be found in the generated ${CMAKE_CURRENT_BINARY_DIR}/HunterGate.cmake.
HunterGate(
    URL "https://github.com/cpp-pm/hunter/archive/v0.23.240.tar.gz"
    SHA1 "ca19f3769e6c80cfdd19d8b12ba5102c27b074e0"
)
