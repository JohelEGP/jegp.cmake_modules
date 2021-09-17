cmake_path(GET INPUT PARENT_PATH input_dir)
cmake_path(GET OUTPUT PARENT_PATH output_dir)
execute_process(COMMAND "${CMAKE_COMMAND}" -E make_directory "${input_dir}"
                COMMAND "${CMAKE_COMMAND}" -E make_directory "${output_dir}" COMMAND_ERROR_IS_FATAL ANY)
execute_process(COMMAND "${CMAKE_COMMAND}" -E create_symlink "${INPUT}" "${OUTPUT}" COMMAND_ERROR_IS_FATAL ANY)
