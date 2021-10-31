include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPAddTarget.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPParseArguments.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPSetScript.cmake")

function(jegp_add_module name)
  _jegp_parse_arguments("" "IMPORTABLE_HEADER" "" "SOURCES=${name}.cpp;COMPILE_OPTIONS;LINK_LIBRARIES" ${ARGN})
  include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/JEGPDefineVariables.cmake")

  set(_jegp_modules_script_dir "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/CppModules")
  include("${_jegp_modules_script_dir}/Common.cmake")

  file(MAKE_DIRECTORY "${_jegp_modules_binary_dir}")

  set(compiled_module_file "${_jegp_modules_binary_dir}/${name}${JEGP_CMI_EXTENSION}")
  set_source_files_properties("${compiled_module_file}" PROPERTIES GENERATED TRUE)

  _jegp_add_target(
    ${name}
    TYPE OBJECT_LIBRARY
    SOURCES ${_SOURCES} "${compiled_module_file}"
    COMPILE_OPTIONS
      ${_COMPILE_OPTIONS}
      PUBLIC
      ${_jegp_modules_compile_options}
      INTERFACE
      $<$<CXX_COMPILER_ID:Clang>:-fprebuilt-module-path=${_jegp_modules_binary_dir}>
      PRIVATE
      $<$<AND:$<CXX_COMPILER_ID:GNU>,$<BOOL:${_IMPORTABLE_HEADER}>>:-x;c++-header>
    LINK_LIBRARIES
      ${_LINK_LIBRARIES}
      INTERFACE
      $<$<AND:$<NOT:$<IN_LIST:${name},$<TARGET_PROPERTY:LINK_LIBRARIES>>>,$<NOT:$<BOOL:${_IMPORTABLE_HEADER}>>>:$<TARGET_OBJECTS:${name}>>
    PROPERTIES EXPORT_COMPILE_COMMANDS TRUE)

  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    if(_IMPORTABLE_HEADER)
      set(touched_object_files "${_jegp_modules_binary_dir}/${name}.o")
      add_custom_command(OUTPUT "${touched_object_files}" COMMAND "${CMAKE_COMMAND}" -E touch $<TARGET_OBJECTS:${name}>
                                                                  "${touched_object_files}")
      add_library(_jegp_touch_object_file_for_${name} OBJECT "${touched_object_files}")
      add_dependencies(_jegp_touch_object_file_for_${name} ${name})
      target_link_libraries(${name} INTERFACE _jegp_touch_object_file_for_${name})

      get_source_file_property(name "${_SOURCES}" LOCATION)
    endif()
    _jegp_modules_gnu_map("${name}" "${compiled_module_file}")
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    get_source_file_property(source "${_SOURCES}" LOCATION)

    _jegp_set_script_directory("${_jegp_modules_script_dir}")
    _jegp_set_script_command(CompileCMI "SOURCE=${source}" "BUILD_DIR=${CMAKE_BINARY_DIR}"
                             "COMPILED_MODULE_FILE=${compiled_module_file}")

    add_custom_command(OUTPUT "${compiled_module_file}" COMMAND ${CompileCMI})
  endif()
endfunction()
