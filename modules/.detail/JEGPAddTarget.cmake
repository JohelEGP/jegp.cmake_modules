include("${CMAKE_CURRENT_LIST_DIR}/JEGPParseArguments.cmake")

function(_jegp_add_target name)
  _jegp_parse_arguments("" "EXCLUDE_FROM_ALL" "TYPE{EXECUTABLE|INTERFACE_LIBRARY|OBJECT_LIBRARY}"
                        "SOURCES;COMPILE_OPTIONS;LINK_LIBRARIES;PROPERTIES" ${ARGN})

  if(_TYPE STREQUAL "EXECUTABLE")
    add_executable(${name} ${_SOURCES})
  else()
    string(REPLACE "_LIBRARY" #[[WITH]] "" #[[OUT]] library_type #[[IN]] "${_TYPE}")
    add_library(${name} ${library_type} ${_SOURCES})
  endif()

  if(_COMPILE_OPTIONS)
    target_compile_options(${name} ${_COMPILE_OPTIONS})
  endif()
  if(_LINK_LIBRARIES)
    target_link_libraries(${name} ${_LINK_LIBRARIES})
  endif()
  set_target_properties(${name} PROPERTIES EXCLUDE_FROM_ALL ${_EXCLUDE_FROM_ALL} ${_PROPERTIES})
endfunction()
