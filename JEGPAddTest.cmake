function(jegp_add_test name)
  cmake_parse_arguments("" "COMPILE_ONLY" "" "SOURCES;COMPILE_OPTIONS;LINK_LIBRARIES" ${ARGN})
  include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/JEGPDefineVariables.cmake")

  if(NOT _SOURCESS)
    set(_SOURCES ${name}.cpp)
  endif()

  set(test_name "${JEGP_${PROJECT_NAME}_NAME_PREFIX}test_${name}")

  if(_COMPILE_ONLY)
    add_library(${test_name} OBJECT ${_SOURCES})
  else()
    add_executable(${test_name} ${_SOURCES})
    add_test(${test_name} ${test_name})
  endif()

  target_compile_options(${test_name} PRIVATE ${_COMPILE_OPTIONS})
  target_link_libraries(${test_name} PRIVATE ${_LINK_LIBRARIES})
endfunction()
