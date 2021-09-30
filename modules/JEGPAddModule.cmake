include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPAddTarget.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPParseArguments.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPSetScript.cmake")

set(_jegp_modules_script_dir "${CMAKE_CURRENT_LIST_DIR}/.detail/CppModules")
include("${_jegp_modules_script_dir}/Common.cmake")

file(MAKE_DIRECTORY "${_jegp_modules_binary_dir}")

function(jegp_add_module name)
  _jegp_parse_arguments("" "" "" "SOURCES=${name}.cpp;COMPILE_OPTIONS;LINK_LIBRARIES" ${ARGN})
  include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/JEGPDefineVariables.cmake")

  set(compiled_module_file "${_jegp_modules_binary_dir}/${name}${JEGP_CMI_EXTENSION}")
  set_source_files_properties("${compiled_module_file}" PROPERTIES GENERATED TRUE)

  _jegp_add_target(
    ${name}
    TYPE OBJECT_LIBRARY
    SOURCES ${_SOURCES} "${compiled_module_file}"
    COMPILE_OPTIONS ${_COMPILE_OPTIONS} PUBLIC ${_jegp_modules_compile_options} INTERFACE
                    $<$<CXX_COMPILER_ID:Clang>:-fprebuilt-module-path=${_jegp_modules_binary_dir}>
    LINK_LIBRARIES ${_LINK_LIBRARIES} INTERFACE
                   $<$<NOT:$<IN_LIST:${name},$<TARGET_PROPERTY:LINK_LIBRARIES>>>:$<TARGET_OBJECTS:${name}>>
    PROPERTIES EXPORT_COMPILE_COMMANDS TRUE)

  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    _jegp_modules_gnu_map("${name}" "${compiled_module_file}")
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    get_source_file_property(source "${_SOURCES}" LOCATION)

    _jegp_set_script_directory("${_jegp_modules_script_dir}")
    _jegp_set_script_command(CompileCMI "SOURCE=${source}" "BUILD_DIR=${CMAKE_BINARY_DIR}"
                             "COMPILED_MODULE_FILE=${compiled_module_file}")

    add_custom_command(OUTPUT "${compiled_module_file}" COMMAND ${CompileCMI})
  endif()
endfunction()
