# This should be included (only) from the top level CMakeLists.txt file.
include_guard( GLOBAL )

# This is a list of all aicxx submodules that exist.
# Submodules on the right depend on the submodules on the left.
set( AICxxSubmodules cwds utils threadsafe threadpool evio statefultask )

foreach( subdir ${AICxxSubmodules} )
  get_filename_component( _fullpath "${subdir}" REALPATH )
  if ( EXISTS "${_fullpath}" AND EXISTS "${_fullpath}/CMakeLists.txt" )
#[[
    if ( EXISTS "${_fullpath}/CMpackages.cmake" )
      include( "${_fullpath}/CMpackages.cmake" )
    endif ()
#]]
    add_subdirectory( ${subdir} )
  endif ()
endforeach ()
