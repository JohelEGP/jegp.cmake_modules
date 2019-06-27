function(jegp_add_header_test)
    include(TestHeaders)

    set(include_directory ${${PROJECT_NAME}_SOURCE_DIR}/include)

    file(GLOB_RECURSE headers
        RELATIVE ${include_directory}
        ${include_directory}/*.hpp)

    string(REPLACE jegp jegp_test
        jegp_test_libname_headers
        ${PROJECT_NAME}_headers)
    add_header_test(${jegp_test_libname_headers} HEADERS ${headers})
    target_link_libraries(${jegp_test_libname_headers} PRIVATE ${PROJECT_NAME})
endfunction()
