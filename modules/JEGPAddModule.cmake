include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPAddTarget.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPParseArguments.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPSetScript.cmake")

function(jegp_add_module name)
  _jegp_parse_arguments("" "" "" "SOURCES=${name}.cpp;COMPILE_OPTIONS;LINK_LIBRARIES" ${ARGN})
  include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/JEGPDefineVariables.cmake")

  set(script_dir "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/CppModules")
  set(pcm_file "${CMAKE_CURRENT_BINARY_DIR}/PCM/${name}.pcm")
  set(pcm_name "_jegp_module_object_${JEGP_${PROJECT_NAME}_NAME_PREFIX}${name}")

  _jegp_add_target(
    ${name}
    TYPE OBJECT_LIBRARY
    SOURCES ${_SOURCES}
    COMPILE_OPTIONS
      ${_COMPILE_OPTIONS} PUBLIC $<$<CXX_COMPILER_ID:Clang>:-fmodules -fbuiltin-module-map> INTERFACE
      $<$<NOT:$<STREQUAL:${pcm_name},$<TARGET_PROPERTY:NAME>>>:$<$<CXX_COMPILER_ID:Clang>:-fmodule-file=${pcm_file}>>
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
    _jegp_add_target(
      ${pcm_name}
      TYPE OBJECT_LIBRARY
      SOURCES ${_SOURCES}
      COMPILE_OPTIONS ${_COMPILE_OPTIONS} PRIVATE -Xclang -emit-module-interface
      LINK_LIBRARIES ${_LINK_LIBRARIES} PUBLIC ${name})

    _jegp_set_script_directory("${script_dir}")
    _jegp_set_script_command(SymlinkClangObjectAsPCM "INPUT=$<TARGET_OBJECTS:${pcm_name}>" "OUTPUT=${pcm_file}")

    add_custom_command(OUTPUT "${pcm_file}" COMMAND ${SymlinkClangObjectAsPCM} DEPENDS $<TARGET_OBJECTS:${pcm_name}>)

    target_sources(${name} INTERFACE "${pcm_file}")
  endif()
endfunction()
