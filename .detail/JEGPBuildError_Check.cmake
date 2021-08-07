cmake_policy(VERSION ${VERSION})
include("${CMAKE_CURRENT_LIST_DIR}/JEGPUtilities.cmake")

set(BUILD_COMMAND "${CMAKE_COMMAND}" --build . --target "${TARGET}")
if(AS STREQUAL "BUILD_CHECK")
  include("${CMAKE_CURRENT_LIST_DIR}/JEGPStringJson.cmake")

  file(READ "${BUILD_DIR}/compile_commands.json" compile_commands)
  _jegp_string(JSON build_command FIND "${compile_commands}" "${BUILD_ERROR_SOURCE}" [[${i}]] file)
  string(JSON BUILD_COMMAND GET "${build_command}" command)
  string(JSON BUILD_DIR GET "${build_command}" directory)
  separate_arguments(BUILD_COMMAND)
endif()

execute_process(
  COMMAND ${BUILD_COMMAND}
  WORKING_DIRECTORY "${BUILD_DIR}"
  RESULT_VARIABLE built
  OUTPUT_VARIABLE build_output
  ERROR_VARIABLE build_output)

if(built EQUAL 0)
  message(FATAL_ERROR "${build_output} Expected build error. Got successful build.")
endif()

function(search_fatal_error search_type)
  message(FATAL_ERROR "Remaining build output: \"${build_output}\".\n"
                      "Error: Failed with \"${built}\". Remaining build output does not ${search_type} \"${error}\".")
endfunction()

file(READ "${SCANNED_ERRORS_FILE}" error_specifiers)
while(error_specifiers)
  list(POP_FRONT error_specifiers type error)

  if(type STREQUAL "error")
    string(FIND "${build_output}" "${error}" error_begin)
    if(error_begin EQUAL -1)
      search_fatal_error("contain")
    endif()

    string(LENGTH "${error}" error_length)
    math(EXPR remaining_build_output_begin "${error_begin} + ${error_length}")

    string(SUBSTRING "${build_output}" ${remaining_build_output_begin} -1 build_output)
  elseif(type STREQUAL "error-regex")
    if(NOT "${build_output}" MATCHES "${error}")
      search_fatal_error("match")
    endif()
  else()
    message(FATAL_ERROR "Unknown error specifier type \"${type}\".")
  endif()
endwhile()
