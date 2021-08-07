include(${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPAddTarget.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPParseArguments.cmake)

function(jegp_add_test name)
  _jegp_parse_arguments("" "COMPILE_ONLY" "" "SOURCES=${name}.cpp" ${ARGN})

  set(test_name ${PROJECT_NAME}_test_${name})
  set(type EXECUTABLE)
  if(_COMPILE_ONLY)
    set(type OBJECT_LIBRARY)
  endif()
  _jegp_add_target(${test_name} TYPE ${type} SOURCES ${_SOURCES} ${_UNPARSED_ARGUMENTS})

  if(NOT _COMPILE_ONLY)
    add_test(${test_name} ${test_name})
  endif()
endfunction()
