message(DEPRECATION "Use the `CMAKE_VERIFY_INTERFACE_HEADER_SETS` variable.")

function(jegp_add_header_test)
  include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/JEGPDefineVariables.cmake")
  include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/TestHeaders.cmake")

  set(include_directory ${${PROJECT_NAME}_SOURCE_DIR}/include)

  file(GLOB_RECURSE headers RELATIVE ${include_directory} ${include_directory}/*.hpp)

  set(target "${JEGP_${PROJECT_NAME}_NAME_PREFIX}test_headers")
  add_header_test("${target}" HEADERS ${headers})
  target_link_libraries("${target}" PRIVATE ${PROJECT_NAME})
endfunction()
