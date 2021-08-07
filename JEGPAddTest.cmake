function(jegp_add_test name)
  cmake_parse_arguments(JEGP_ADD_TEST "COMPILE_ONLY" "SOURCE" "SOURCES;COMPILE_OPTIONS;LINK_LIBRARIES" ${ARGN})

  if(NOT JEGP_ADD_TEST_SOURCE)
    set(JEGP_ADD_TEST_SOURCE ${name}.cpp)
  endif()
  if(NOT JEGP_ADD_TEST_SOURCES)
    set(JEGP_ADD_TEST_SOURCES ${JEGP_ADD_TEST_SOURCE})
  endif()

  set(test_name ${PROJECT_NAME}_test_${name})

  if(JEGP_ADD_TEST_COMPILE_ONLY)
    add_library(${test_name} OBJECT ${JEGP_ADD_TEST_SOURCES})
  else()
    add_executable(${test_name} ${JEGP_ADD_TEST_SOURCES})
    add_test(${test_name} ${test_name})
  endif()

  if(TARGET ${PROJECT_NAME})
    set(implicit_linked_library ${PROJECT_NAME})
    message(DEPRECATION "Implicitly linking of ${implicit_linked_library} to ${test_name}.")
  endif()

  target_compile_options(${test_name} PRIVATE ${JEGP_ADD_TEST_COMPILE_OPTIONS})
  target_link_libraries(${test_name} PRIVATE ${JEGP_ADD_TEST_LINK_LIBRARIES} ${implicit_linked_library})
endfunction()
