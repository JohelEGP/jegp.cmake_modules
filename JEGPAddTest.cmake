function(jegp_add_test name)
  cmake_parse_arguments(JEGP_ARG "COMPILE_ONLY" "SOURCE" "SOURCES;COMPILE_OPTIONS;LINK_LIBRARIES" ${ARGN})

  if(NOT JEGP_ARG_SOURCE)
    set(JEGP_ARG_SOURCE ${name}.cpp)
  else()
    message(DEPRECATION "SOURCE keyword is deprecated in favor of SOURCES.")
  endif()
  if(NOT JEGP_ARG_SOURCES)
    set(JEGP_ARG_SOURCES ${JEGP_ARG_SOURCE})
  endif()

  set(test_name ${PROJECT_NAME}_test_${name})

  if(JEGP_ARG_COMPILE_ONLY)
    add_library(${test_name} OBJECT ${JEGP_ARG_SOURCES})
  else()
    add_executable(${test_name} ${JEGP_ARG_SOURCES})
    add_test(${test_name} ${test_name})
  endif()

  if(TARGET ${PROJECT_NAME})
    set(implicit_linked_library ${PROJECT_NAME})
    message(DEPRECATION "Implicitly linking of ${implicit_linked_library} to ${test_name}.")
  endif()

  target_compile_options(${test_name} PRIVATE ${JEGP_ARG_COMPILE_OPTIONS})
  target_link_libraries(${test_name} PRIVATE ${JEGP_ARG_LINK_LIBRARIES} ${implicit_linked_library})
endfunction()
