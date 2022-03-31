include("${CMAKE_CURRENT_LIST_DIR}/../JEGPDefineVariables.cmake")

_jegp_default_variable("JEGP_CXX_MODULES_BINARY_PARENT_DIR" "${CMAKE_BINARY_DIR}")
set(_jegp_modules_binary_dir "${JEGP_CXX_MODULES_BINARY_PARENT_DIR}/JEGPModules")
set(_jegp_system_modules_cache_default "${_jegp_modules_binary_dir}/system")
_jegp_default_variable("JEGP_CXX_MODULES_SYSTEM_CACHE" "${_jegp_system_modules_cache_default}")
cmake_path(IS_PREFIX JEGP_CXX_MODULES_SYSTEM_CACHE "${_jegp_system_modules_cache_default}"
           _jegp_system_modules_implicit_cache)
set(_jegp_header_units_binary_dir "${JEGP_CXX_MODULES_SYSTEM_CACHE}/header_units")
set(_jegp_gnu_module_mapper_file "${_jegp_modules_binary_dir}/module_mapper.txt")

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  set(_jegp_modules_compile_options -fmodules-ts "-fmodule-mapper=${_jegp_gnu_module_mapper_file}")
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  set(_jegp_modules_compile_options -fmodules -fbuiltin-module-map)
  if(NOT _jegp_system_modules_implicit_cache)
    list(APPEND _jegp_modules_compile_options "-fmodules-cache-path=${JEGP_CXX_MODULES_SYSTEM_CACHE}")
  endif()
endif()

function(_jegp_modules_gnu_map module_name gcm_filename #[[module_mapper_file]])
  if(ARGC EQUAL 3)
    set(module_mapper_file "${ARGV2}")
  else()
    set(module_mapper_file "${_jegp_gnu_module_mapper_file}")
  endif()

  file(APPEND "${module_mapper_file}" "${module_name} ${gcm_filename}\n")
endfunction()
