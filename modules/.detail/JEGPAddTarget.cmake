include("${CMAKE_CURRENT_LIST_DIR}/JEGPParseArguments.cmake")

function(_jegp_add_target name)
  _jegp_parse_arguments("" "EXCLUDE_FROM_ALL" "TYPE{EXECUTABLE|OBJECT_LIBRARY}"
                        "SOURCES;COMPILE_OPTIONS;LINK_LIBRARIES;PROPERTIES" ${ARGN})

  if(_TYPE STREQUAL "EXECUTABLE")
    add_executable(${name} ${_SOURCES})
  elseif(_TYPE STREQUAL "OBJECT_LIBRARY")
    add_library(${name} OBJECT ${_SOURCES})
  endif()

  target_compile_options(${name} PRIVATE ${_COMPILE_OPTIONS})
  target_link_libraries(${name} PRIVATE ${_LINK_LIBRARIES})
  set_target_properties(${name} PROPERTIES EXCLUDE_FROM_ALL ${_EXCLUDE_FROM_ALL} ${_PROPERTIES})
endfunction()