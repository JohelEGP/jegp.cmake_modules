include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPAddTarget.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPParseArguments.cmake")

function(jegp_add_test name)
  _jegp_parse_arguments("" "" "TYPE{=EXECUTABLE|OBJECT_LIBRARY}" "SOURCES=${name}.cpp;COMPILE_OPTIONS;LINK_LIBRARIES"
                        ${ARGN})
  include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/JEGPDefineVariables.cmake")

  _jegp_add_target(
    ${name}
    TYPE ${_TYPE}
    SOURCES ${_SOURCES}
    COMPILE_OPTIONS PRIVATE ${_COMPILE_OPTIONS}
    LINK_LIBRARIES PRIVATE ${_LINK_LIBRARIES})

  if(_TYPE STREQUAL "EXECUTABLE")
    add_test(${name} ${name})
  endif()
endfunction()
