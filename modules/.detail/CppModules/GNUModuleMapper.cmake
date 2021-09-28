set(jegp_gnu_module_mapper_file "${CMAKE_BINARY_DIR}/module_mapper.txt")
set(jegp_gnu_module_mapper_option "-fmodule-mapper=${jegp_gnu_module_mapper_file}")

function(jegp_gnu_module_mapper_add_mapping module_name gcm_filename #[[module_mapper_file]])
  if(ARGC EQUAL 3)
    set(module_mapper_file "${ARGV2}")
  else()
    set(module_mapper_file "${jegp_gnu_module_mapper_file}")
  endif()

  file(APPEND "${module_mapper_file}" "${module_name} ${gcm_filename}\n")
endfunction()
