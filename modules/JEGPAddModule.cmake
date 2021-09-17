include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPAddTarget.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPParseArguments.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPSetScript.cmake")

function(jegp_add_module name)
  _jegp_parse_arguments("" "" "" "SOURCES=${name}.cpp;COMPILE_OPTIONS;LINK_LIBRARIES" ${ARGN})
  include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/JEGPDefineVariables.cmake")

  if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set(object_name "_jegp_module_object_${JEGP_${PROJECT_NAME}_NAME_PREFIX}${name}")
    set(pcm "${CMAKE_CURRENT_BINARY_DIR}/PCM/${name}.pcm")

    _jegp_set_script_directory("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/")
    _jegp_set_script_command(SymlinkClangObjectAsPCM "INPUT=$<TARGET_OBJECTS:${object_name}>" "OUTPUT=${pcm}")
    add_custom_command(OUTPUT "${pcm}" COMMAND ${SymlinkClangObjectAsPCM})
  endif()

  _jegp_add_target(
    ${name}
    TYPE OBJECT_LIBRARY
    SOURCES "$<$<CXX_COMPILER_ID:GNU>:${_SOURCES}>" ${pcm}
    COMPILE_OPTIONS ${_COMPILE_OPTIONS}
    LINK_LIBRARIES ${_LINK_LIBRARIES})

  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    set(module_mapper_file "${CMAKE_BINARY_DIR}/module_mapper_file.txt")

    target_compile_options(${name} PUBLIC -fmodules-ts INTERFACE "-fmodule-mapper=${module_mapper_file}")

    file(APPEND "${module_mapper_file}" "${name} ${CMAKE_CURRENT_BINARY_DIR}/gcm.cache/${name}.gcm\n")
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    add_library(${object_name} OBJECT "${_SOURCES}")
    add_dependencies(${name} ${object_name})

    macro(common_target_calls target)
      target_compile_options(${target} PUBLIC -Xclang PRIVATE -emit-module-interface INTERFACE "-fmodule-file=${pcm}")
    endmacro()

    common_target_calls(${name})
    common_target_calls(${object_name})
  endif()
endfunction()
