include("${CMAKE_CURRENT_LIST_DIR}/../JEGPDefineVariables.cmake")

_jegp_default_variable("JEGP_CXX_MODULES_BINARY_PARENT_DIR" "${CMAKE_BINARY_DIR}")
set(_jegp_modules_binary_dir "${JEGP_CXX_MODULES_BINARY_PARENT_DIR}/JEGPModules")
set(_jegp_system_modules_cache_default "${_jegp_modules_binary_dir}/system")
if(DEFINED JEGP_SYSTEM_MODULES_CACHE)
  message(WARNING "JEGP_SYSTEM_MODULES_CACHE is deprecated. Set JEGP_CXX_MODULES_SYSTEM_CACHE.")
endif()
_jegp_define_variable("JEGP_CXX_MODULES_SYSTEM_CACHE" "${_jegp_system_modules_cache_default}")
_jegp_define_variable("JEGP_SYSTEM_MODULES_CACHE" "${JEGP_CXX_MODULES_SYSTEM_CACHE}")
cmake_path(IS_PREFIX JEGP_SYSTEM_MODULES_CACHE "${_jegp_system_modules_cache_default}"
           _jegp_system_modules_implicit_cache)
set(_jegp_header_units_binary_dir "${JEGP_SYSTEM_MODULES_CACHE}/header_units")
set(_jegp_gnu_module_mapper_file "${_jegp_modules_binary_dir}/module_mapper.txt")
set(_jegp_clang_modules_cache_flag
    $<$<NOT:$<BOOL:${_jegp_system_modules_implicit_cache}>>:-fmodules-cache-path=${JEGP_SYSTEM_MODULES_CACHE}>)
set(_jegp_modules_compile_options
    $<$<CXX_COMPILER_ID:GNU>:-fmodules-ts;-fmodule-mapper=${_jegp_gnu_module_mapper_file}>
    $<$<CXX_COMPILER_ID:Clang>:-fmodules;-fbuiltin-module-map;${_jegp_clang_modules_cache_flag}>)

function(_jegp_modules_gnu_map module_name gcm_filename #[[module_mapper_file]])
  if(ARGC EQUAL 3)
    set(module_mapper_file "${ARGV2}")
  else()
    set(module_mapper_file "${_jegp_gnu_module_mapper_file}")
  endif()

  file(APPEND "${module_mapper_file}" "${module_name} ${gcm_filename}\n")
endfunction()
