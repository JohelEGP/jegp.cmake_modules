function(jegp_add_test name)
  cmake_parse_arguments(JEGP_ARG "COMPILE_ONLY" "" "SOURCES;COMPILE_OPTIONS;LINK_LIBRARIES" ${ARGN})
  include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/JEGPDefineVariables.cmake")

  if(NOT JEGP_ARG_SOURCESS)
    set(JEGP_ARG_SOURCES ${name}.cpp)
  endif()

  set(test_name "${JEGP_${PROJECT_NAME}_NAME_PREFIX}test_${name}")

  if(JEGP_ARG_COMPILE_ONLY)
    add_library(${test_name} OBJECT ${JEGP_ARG_SOURCES})
  else()
    add_executable(${test_name} ${JEGP_ARG_SOURCES})
    add_test(${test_name} ${test_name})
  endif()

  target_compile_options(${test_name} PRIVATE ${JEGP_ARG_COMPILE_OPTIONS})
  target_link_libraries(${test_name} PRIVATE ${JEGP_ARG_LINK_LIBRARIES})
endfunction()
