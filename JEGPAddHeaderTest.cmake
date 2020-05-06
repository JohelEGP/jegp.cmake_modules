function(jegp_add_header_test)
    include(TestHeaders)

    set(include_directory ${${PROJECT_NAME}_SOURCE_DIR}/include)

    file(GLOB_RECURSE headers
        RELATIVE ${include_directory}
        ${include_directory}/*.hpp)

    add_header_test(${PROJECT_NAME}_test_headers HEADERS ${headers})
    target_link_libraries(${PROJECT_NAME}_test_headers PRIVATE ${PROJECT_NAME})
endfunction()
