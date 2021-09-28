include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPAddTarget.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPParseArguments.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPSetScript.cmake")

function(jegp_add_module name)
  _jegp_parse_arguments("" "" "" "SOURCES=${name}.cpp;COMPILE_OPTIONS;LINK_LIBRARIES" ${ARGN})
  include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/JEGPDefineVariables.cmake")

  set(script_dir "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/CppModules")

  if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set(object_name "_jegp_module_object_${JEGP_${PROJECT_NAME}_NAME_PREFIX}${name}")
    set(pcm "${CMAKE_CURRENT_BINARY_DIR}/PCM/${name}.pcm")

    _jegp_set_script_directory("${script_dir}")
    _jegp_set_script_command(SymlinkClangObjectAsPCM "INPUT=$<TARGET_OBJECTS:${object_name}>" "OUTPUT=${pcm}")
    add_custom_command(OUTPUT "${pcm}" COMMAND ${SymlinkClangObjectAsPCM})
  endif()

  _jegp_add_target(
    ${name}
    TYPE OBJECT_LIBRARY
    SOURCES "$<$<CXX_COMPILER_ID:GNU>:${_SOURCES}>" ${pcm}
    COMPILE_OPTIONS ${_COMPILE_OPTIONS}
    LINK_LIBRARIES
      ${_LINK_LIBRARIES} INTERFACE
      $<$<CXX_COMPILER_ID:GNU>:$<$<NOT:$<IN_LIST:${name},$<TARGET_PROPERTY:LINK_LIBRARIES>>>:$<TARGET_OBJECTS:${name}>>>
  )

  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    include("${script_dir}/GNUModuleMapper.cmake")

    target_compile_options(${name} PUBLIC -fmodules-ts INTERFACE "${jegp_gnu_module_mapper_option}")

    set(gcm_filename "${CMAKE_CURRENT_BINARY_DIR}/gcm.cache/${name}.gcm")

    jegp_gnu_module_mapper_add_mapping("${name}" "${gcm_filename}")

    set_source_files_properties(${_SOURCES} PROPERTIES OBJECT_OUTPUTS "${gcm_filename}")
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    add_library(${object_name} OBJECT "${_SOURCES}")
    add_dependencies(${name} ${object_name})

    macro(common_target_calls target)
      target_compile_options(${target} PUBLIC -fmodules -fbuiltin-module-map PRIVATE -Xclang -emit-module-interface
                             INTERFACE "-fmodule-file=${pcm}")
    endmacro()

    common_target_calls(${name})
    common_target_calls(${object_name})
  endif()
endfunction()
