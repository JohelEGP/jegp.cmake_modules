function(jegp_add_compiler_error_test name)
  jegp_add_test(${name} COMPILE_ONLY ${ARGN})
  set(test_name ${PROJECT_NAME}_test_${name})

  get_target_property(original_source_path ${test_name} SOURCES)
  set(split_source_path ${CMAKE_CURRENT_BINARY_DIR}/JEGPAddCompilerErrorTest/${original_source_path})
  set_target_properties(${test_name} PROPERTIES EXCLUDE_FROM_ALL Y EXPORT_COMPILE_COMMANDS Y SOURCES
                                                                                             ${split_source_path})

  add_custom_command(
    OUTPUT ${split_source_path}
    COMMAND ${CMAKE_COMMAND} -D INPUT=${CMAKE_CURRENT_SOURCE_DIR}/${original_source_path} -D OUTPUT=${split_source_path}
            -D FILE=${split_source_path} -D TARGET=${test_name} -P
            ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/JEGPTestCompilerError.cmake
    MAIN_DEPENDENCY ${original_source_path}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

  add_custom_target(${test_name}_run ALL SOURCES ${original_source_path} DEPENDS ${split_source_path})
endfunction()
