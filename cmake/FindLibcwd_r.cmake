find_package( PkgConfig )
pkg_check_modules( Libcwd_r QUIET libcwd_r )

if ( Libcwd_r_FOUND AND NOT TARGET Libcwd_r::Libcwd_r )
  add_library( Libcwd_r::Libcwd_r INTERFACE IMPORTED )
  set_target_properties( Libcwd_r::Libcwd_r PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${Libcwd_r_INCLUDE_DIR}"
  )
endif()
