function(jegp_add_header_test)
    include(TestHeaders)

    get_property(include_directory
        TARGET ${PROJECT_NAME}
        PROPERTY INTERFACE_INCLUDE_DIRECTORIES)
    list(LENGTH include_directory include_directory_length)
    if(NOT include_directory_length EQUAL 1)
        message(FATAL_ERROR "Expected only one include directory")
    endif()

    file(GLOB_RECURSE headers
        RELATIVE ${include_directory}
        ${include_directory}/*.hpp)

    string(REPLACE jegp jegp_test
        jegp_test_libname_headers
        ${PROJECT_NAME}_headers)
    add_header_test(${jegp_test_libname_headers} HEADERS ${headers})
    target_link_libraries(${jegp_test_libname_headers}
        PRIVATE jegp::${PROJECT_NAME})
endfunction()
