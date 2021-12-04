# Try to find farmhash headers and libraries.
#
# Usage of this module as follows:
#
#     find_package(farmhash [REQUIRED])
#
# Variables used by this module, they can change the default
# behaviour and need to be set before calling find_package:
#
#   FARMHASH_ROOT_DIR           Set this variable to the root installation of
#                               farmhash if the module has problems finding
#                               the proper installation path.
#   FARMHASH_LIBRARIES_PATHS    Set this variable to the directory where the
#                               library can be found if the module has problems
#                               finding it.
#
# This module creates the target
#
#   farmhash::farmhash
#
# Variable defined by this module:
#
#  FARMHASH_FOUND             System has farmhash libs/headers
#
# Advanced variables defined by this module:
#
#  FARMHASH_ROOT_DIR          The root where include/farmhash.h was found.
#  FARMHASH_LIBRARIES         The farmhash library/libraries
#  FARMHASH_INCLUDE_DIR       The location of farmhash headers

include_guard(GLOBAL)

find_path(FARMHASH_ROOT_DIR
  NAMES include/farmhash.h
)

find_library(FARMHASH_LIBRARIES
  NAMES farmhash
  PATHS ${FARMHASH_ROOT_DIR}/lib ${FARMHASH_LIBRARIES_PATHS}
)

find_path(FARMHASH_INCLUDE_DIR
  NAMES farmhash.h
  PATHS ${FARMHASH_ROOT_DIR}/include
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(farmhash DEFAULT_MSG
  FARMHASH_LIBRARIES
  FARMHASH_INCLUDE_DIR
)

mark_as_advanced(
  FARMHASH_ROOT_DIR
  FARMHASH_LIBRARIES
  FARMHASH_INCLUDE_DIR
)

if (farmhash_FOUND)
  message(STATUS "Found farmhash: ${FARMHASH_ROOT_DIR}")
  add_library(libfarmhash SHARED IMPORTED GLOBAL)
  set_target_properties(libfarmhash PROPERTIES
    IMPORTED_LOCATION ${FARMHASH_LIBRARIES}               # The DLL, .so or .dylib
    INTERFACE_INCLUDE_DIRECTORIES ${FARMHASH_INCLUDE_DIR}
  )

  add_library(farmhash::farmhash ALIAS libfarmhash)
endif ()
