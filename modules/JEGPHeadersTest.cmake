message(DEPRECATION "Use the `CMAKE_VERIFY_INTERFACE_HEADER_SETS` variable.")

include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPSetScript.cmake")

# Process:
# - Generate the list of public headers of the targets.
# - Build a generated buildsystem that imports the current one and compiles the public headers of the targets.
# Building the target requires the buildsystem to `export(EXPORT)` its targets.
function(jegp_add_headers_test)
  cmake_parse_arguments("" "" "" "PRIVATE_REGEXES" ${ARGN})
  set(targets ${_UNPARSED_ARGUMENTS})

  include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/JEGPDefineVariables.cmake")
  set(headers_test "${JEGP_${PROJECT_NAME}_NAME_PREFIX}headers_test")

  function(set_scan_rules target)
    set(include_directories "$<TARGET_PROPERTY:${target},INTERFACE_INCLUDE_DIRECTORIES>")

    set(module_dir "${CMAKE_BINARY_DIR}/JEGPHeadersTest/${target}")
    set(header_file_extensions_file "${module_dir}/header_file_extensions.txt")
    set(requirements_file "${module_dir}/requirements.txt")
    set(success_output "${module_dir}/success.txt")

    file(WRITE "${header_file_extensions_file}" "${JEGP_CXX_HEADER_FILE_EXTENSIONS}")

    _jegp_set_script_directory("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/HeadersTest/")
    _jegp_set_script_command(
      GenerateRequirementsFile "HEADER_FILE_EXTENSIONS_FILE=${header_file_extensions_file}" "TARGET=${target}"
      "INCLUDE_DIRECTORIES=${include_directories}" "PRIVATE_REGEXES=${_PRIVATE_REGEXES}"
      "OUTPUT_FILE=${requirements_file}")
    _jegp_set_script_command(
      Enforce "BUILD_DIR=${module_dir}/build" "TARGET=${headers_test}" "REQUIREMENTS_FILE=${requirements_file}"
      "PROJECT_BINARY_DIR=${CMAKE_BINARY_DIR}" "PROJECT=${PROJECT_NAME}")

    if(TARGET ${headers_test})
      set(append APPEND)
    endif()

    add_custom_command(OUTPUT ${requirements_file} COMMAND ${GenerateRequirementsFile} ${append})
    add_custom_command(OUTPUT ${success_output} COMMAND ${Enforce} COMMAND ${CMAKE_COMMAND} -E touch ${success_output}
                       DEPENDS ${requirements_file} ${append})

    if(NOT append)
      add_custom_target(${headers_test} ALL DEPENDS ${success_output})
    endif()
  endfunction()

  foreach(tgt IN LISTS targets)
    set_scan_rules(${tgt})
  endforeach()
endfunction()
