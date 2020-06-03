function(jegp_add_test name)
    cmake_parse_arguments(JEGP_ADD_TEST "COMPILE_ONLY" "SOURCE"
                          "COMPILE_OPTIONS;LINK_LIBRARIES" ${ARGN})

    list(APPEND JEGP_ADD_TEST_SOURCE ${name}.cpp)
    list(GET JEGP_ADD_TEST_SOURCE 0 source)

    set(test_name ${PROJECT_NAME}_test_${name})

    add_executable(${test_name} ${source})
    target_compile_options(${test_name}
                           PRIVATE ${JEGP_ADD_TEST_COMPILE_OPTIONS})
    target_link_libraries(${test_name} PRIVATE ${JEGP_ADD_TEST_LINK_LIBRARIES}
                                               ${PROJECT_NAME})
    if(NOT JEGP_ADD_TEST_COMPILE_ONLY)
        add_test(${test_name} ${test_name})
    endif()
endfunction()
