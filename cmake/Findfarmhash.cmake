#[[

Findfarmhash

Finds the farmhash library.

Imported Targets
----------------

This module provides the following imported targets, if found:

 `farmhash::farmhash`
      The farmhash library

Cache Variables
---------------

The following cache variables may be set as well, if found:

 `farmhash_INCLUDE_DIR`
      The directory containing `farmhash.h`.
 `farmhash_LIBRARY`
      The path to the farmhash library.

#=======================================================================]]

find_package( PkgConfig )
pkg_check_modules( PC_farmhash QUIET farmhash )

find_path( farmhash_INCLUDE_DIR
    NAMES farmhash.h
    PATHS ${PC_farmhash_INCLUDE_DIRS}
)
find_library( farmhash_LIBRARY
    NAMES farmhash
    PATHS ${PC_farmhash_LIBRARY_DIRS}
)

set( farmhash_VERSION ${PC_farmhash_VERSION} )

include( FindPackageHandleStandardArgs )
find_package_handle_standard_args( farmhash
    REQUIRED_VARS
        farmhash_INCLUDE_DIR
        farmhash_LIBRARY
    VERSION_VAR
        farmhash_VERSION
)

if ( farmhash_FOUND AND NOT TARGET farmhash::farmhash )
  add_library( farmhash::farmhash UNKNOWN IMPORTED )
  set_target_properties( farmhash::farmhash PROPERTIES
    IMPORTED_LOCATION "${farmhash_LIBRARY}"
    INTERFACE_COMPILE_OPTIONS "${PC_farmhash_CFLAGS_OTHER}"
    INTERFACE_INCLUDE_DIRECTORIES "${farmhash_INCLUDE_DIR}"
  )
endif ()

mark_as_advanced(
    farmhash_INCLUDE_DIR
    farmhash_LIBRARY
)
