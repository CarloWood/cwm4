# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
Findfarmhash
-------

Finds the farmhash library.

Imported Targets
^^^^^^^^^^^^^^^^

This module provides the following imported targets, if found:

``farmhash::farmhash``
  The farmhash library

Result Variables
^^^^^^^^^^^^^^^^

This will define the following variables:

``farmhash_FOUND``
  True if the system has the farmhash library.
``farmhash_VERSION``
  The version of the farmhash library which was found.
``farmhash_INCLUDE_DIRS``
  Include directories needed to use farmhash.
``farmhash_LIBRARIES``
  Libraries needed to link to farmhash.

Cache Variables
^^^^^^^^^^^^^^^

The following cache variables may also be set:

``farmhash_INCLUDE_DIR``
  The directory containing ``farmhash.h``.
``farmhash_LIBRARY``
  The path to the farmhash library.

#]=======================================================================]

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
