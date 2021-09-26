include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPAddTarget.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPSetScript.cmake")

function(jegp_target_link_header_units target #[[<header>...]])
  set(script_dir "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/CppModules")
  include("${script_dir}/GNUModuleMapper.cmake")

  if(NOT TARGET _jegp_header_units)
    _jegp_add_target(
      _jegp_header_units TYPE INTERFACE_LIBRARY
      COMPILE_OPTIONS INTERFACE $<$<CXX_COMPILER_ID:GNU>:-fmodules-ts ${jegp_gnu_module_mapper_option}>
                      $<$<CXX_COMPILER_ID:Clang>:-fmodules -fbuiltin-module-map>)
  endif()

  target_link_libraries(${target} PUBLIC _jegp_header_units)

  if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    return()
  endif()

  set(header_units_dir "${CMAKE_BINARY_DIR}/JEGPHeaderUnits")
  file(MAKE_DIRECTORY "${header_units_dir}")

  function(add_header_unit name header)
    set(header_gcm "${header_units_dir}/${header}.gcm")

    _jegp_set_script_directory("${script_dir}")
    _jegp_set_script_command(GNUAddMapping "GCM_CACHE=${CMAKE_CURRENT_BINARY_DIR}/gcm.cache" "HEADER=${header}"
                             "MODULE_MAPPER_FILE=${jegp_gnu_module_mapper_file}" "OUTPUT=${header_gcm}")

    add_custom_command(
      OUTPUT "${header_gcm}" COMMAND "${CMAKE_CXX_COMPILER}" ${COMPILE_OPTIONS} -std=c++${CMAKE_CXX_STANDARD}
                                     ${COMPILE_DEFINITIONS} -fmodules-ts -x c++-system-header -c "${header}"
      COMMAND ${GNUAddMapping})

    add_custom_target(${name} DEPENDS "${header_gcm}")
  endfunction()

  foreach(header IN LISTS ARGN)
    set(header_unit _jegp_header_unit_for_${header})

    if(NOT TARGET ${header_unit})
      add_header_unit(${header_unit} "${header}")
    endif()

    add_dependencies(${target} ${header_unit})
  endforeach()
endfunction()
