## https://stackoverflow.com/a/56738858/3743145

# Get all properties that cmake supports.
execute_process(COMMAND cmake --help-property-list OUTPUT_VARIABLE _cmake_property_list)
# Convert command output into a CMake list.
STRING(REGEX REPLACE ";" "\\\\;" _cmake_property_list "${_cmake_property_list}")
STRING(REGEX REPLACE "\n" ";" _cmake_property_list "${_cmake_property_list}")

list(REMOVE_DUPLICATES _cmake_property_list)

function(print_target_properties tgt)
  if(NOT TARGET ${tgt})
    message("There is no target named '${tgt}'")
    return()
  endif()

  foreach (prop ${_cmake_property_list})
    string(REPLACE "<CONFIG>" "${CMAKE_BUILD_TYPE}" prop ${prop})
    get_target_property(propval ${tgt} ${prop})
    if (propval)
      get_target_property(propval ${tgt} ${prop})
      message ("${tgt} ${prop} = ${propval}")
    endif()
  endforeach(prop)
endfunction(print_target_properties)
