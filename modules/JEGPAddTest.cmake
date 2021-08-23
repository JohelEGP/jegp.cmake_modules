include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPAddTarget.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPParseArguments.cmake")

function(jegp_add_test name)
  _jegp_parse_arguments("" "COMPILE_ONLY" "" "SOURCES=${name}.cpp;COMPILE_OPTIONS;LINK_LIBRARIES" ${ARGN})
  include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/JEGPDefineVariables.cmake")

  set(test_name "${JEGP_${PROJECT_NAME}_NAME_PREFIX}test_${name}")

  set(type EXECUTABLE)
  if(_COMPILE_ONLY)
    set(type OBJECT_LIBRARY)
  endif()
  _jegp_add_target(
    ${test_name}
    TYPE ${type}
    SOURCES ${_SOURCES}
    COMPILE_OPTIONS ${_COMPILE_OPTIONS}
    LINK_LIBRARIES ${_LINK_LIBRARIES})

  if(NOT _COMPILE_ONLY)
    add_test(${test_name} ${test_name})
  endif()
endfunction()
