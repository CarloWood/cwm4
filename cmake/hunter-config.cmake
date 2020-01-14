# Available version strings for Boost can be found here: https://github.com/cpp-pm/hunter/blob/master/cmake/projects/Boost/hunter.cmake
# We use 1.70.0-p0 because we don't want to demand a cmake version even larger than 3.14 at this time.
# Boost 1.70 requires CMake 3.14 or newer.
# Boost 1.71 requires CMake 3.15.3 or newer.
# Boost 1.72 requires CMake 3.16.2 or newer.
# See https://stackoverflow.com/questions/42123509/cmake-finds-boost-but-the-imported-targets-not-available-for-boost-version/42124857#42124857
hunter_config( Boost VERSION 1.70.0-p0 )
