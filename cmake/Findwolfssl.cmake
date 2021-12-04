# Try to find wolfssl headers and libraries.
#
# Usage of this module as follows:
#
#     find_package(wolfssl [REQUIRED])
#
# Variables used by this module, they can change the default
# behaviour and need to be set before calling find_package:
#
#   WOLFSSL_ROOT_DIR           Set this variable to the root installation of
#                               wolfssl if the module has problems finding
#                               the proper installation path.
#   WOLFSSL_LIBRARIES_PATHS    Set this variable to the directory where the
#                               library can be found if the module has problems
#                               finding it.
#   WOLFSSL_PREFER_STATIC_LIB  Set this variable to ON to link with a static
#                               library instead of a shared one, if it exists.
#
# This module creates the target
#
#   wolfssl::wolfssl
#
# Variable defined by this module:
#
#  WOLFSSL_FOUND             System has wolfssl libs/headers
#
# Advanced variables defined by this module:
#
#  WOLFSSL_ROOT_DIR          The root where include/wolfssl/ssl.h was found.
#  WOLFSSL_LIBRARIES         The wolfssl library/libraries
#  WOLFSSL_INCLUDE_DIR       The location of wolfssl headers

include_guard(GLOBAL)

find_path(WOLFSSL_ROOT_DIR
  NAMES include/wolfssl/ssl.h
)

find_library(WOLFSSL_LIBRARIES
  NAMES wolfssl
  PATHS ${WOLFSSL_ROOT_DIR}/lib ${WOLFSSL_LIBRARIES_PATHS}
)

find_path(WOLFSSL_INCLUDE_DIR
  NAMES wolfssl/ssl.h
  PATHS ${WOLFSSL_ROOT_DIR}/include
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(wolfssl DEFAULT_MSG
  WOLFSSL_LIBRARIES
  WOLFSSL_INCLUDE_DIR
)

mark_as_advanced(
  WOLFSSL_ROOT_DIR
  WOLFSSL_LIBRARIES
  WOLFSSL_INCLUDE_DIR
)

if (wolfssl_FOUND)
  message(STATUS "Found wolfssl: ${WOLFSSL_ROOT_DIR}")
  add_library(libwolfssl SHARED IMPORTED GLOBAL)
  set_target_properties(libwolfssl PROPERTIES
    IMPORTED_LOCATION ${WOLFSSL_LIBRARIES}               # The DLL, .so or .dylib
    INTERFACE_INCLUDE_DIRECTORIES ${WOLFSSL_INCLUDE_DIR}
  )

  add_library(wolfssl::wolfssl ALIAS libwolfssl)
endif ()
