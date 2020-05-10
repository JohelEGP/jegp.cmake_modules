function(jegp_add_test name)
    cmake_parse_arguments(JEGP_ADD_TEST "COMPILE_ONLY" "SOURCE"
                          "COMPILE_OPTIONS;LINK_LIBRARIES" ${ARGN})

    list(APPEND JEGP_ADD_TEST_SOURCE ${name}.cpp)
    list(GET JEGP_ADD_TEST_SOURCE 0 source)

    add_executable(jegp_test_${name} ${source})
    target_compile_options(jegp_test_${name}
                           PRIVATE ${JEGP_ADD_TEST_COMPILE_OPTIONS})
    target_link_libraries(
        jegp_test_${name} PRIVATE ${JEGP_ADD_TEST_LINK_LIBRARIES}
                                  ${PROJECT_NAME})
    if(NOT JEGP_ADD_TEST_COMPILE_ONLY)
        add_test(jegp_test_${name} jegp_test_${name})
    endif()
endfunction()
