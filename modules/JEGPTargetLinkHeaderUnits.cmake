include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPAddTarget.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPSetScript.cmake")

set(_jegp_header_units_script_dir "${CMAKE_CURRENT_LIST_DIR}/.detail/CppModules")
include("${_jegp_header_units_script_dir}/Common.cmake")

file(MAKE_DIRECTORY "${_jegp_header_units_binary_dir}")

function(jegp_target_link_header_units target #[[<header>...]])
  target_compile_options(${target} PUBLIC ${_jegp_modules_compile_options})

  if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    return()
  endif()

  function(add_header_unit name header)
    set(compiled_header_unit "${_jegp_header_units_binary_dir}/${header}.gcm")

    _jegp_set_script_directory("${_jegp_header_units_script_dir}")
    _jegp_set_script_command(GNUAddMapping "GCM_CACHE=${CMAKE_CURRENT_BINARY_DIR}/gcm.cache" "HEADER=${header}"
                             "MODULE_MAPPER_FILE=${_jegp_gnu_module_mapper_file}" "GCM_SYMLINK=${compiled_header_unit}")

    add_custom_command(
      OUTPUT "${compiled_header_unit}" COMMAND "${CMAKE_CXX_COMPILER}" ${COMPILE_OPTIONS} -std=c++${CMAKE_CXX_STANDARD}
                                               ${COMPILE_DEFINITIONS} -fmodules-ts -x c++-system-header -c "${header}"
      COMMAND ${GNUAddMapping})

    add_custom_target(${name} DEPENDS "${compiled_header_unit}")
  endfunction()

  foreach(header IN LISTS ARGN)
    set(header_unit _jegp_header_unit_for_${header})

    if(NOT TARGET ${header_unit})
      add_header_unit(${header_unit} "${header}")
    endif()

    add_dependencies(${target} ${header_unit})
  endforeach()
endfunction()
