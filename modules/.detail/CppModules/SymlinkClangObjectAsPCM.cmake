cmake_path(GET INPUT PARENT_PATH input_dir)
cmake_path(GET OUTPUT PARENT_PATH output_dir)
file(MAKE_DIRECTORY "${input_dir}" "${output_dir}")
file(CREATE_LINK "${INPUT}" "${OUTPUT}" SYMBOLIC)
