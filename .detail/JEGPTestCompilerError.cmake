set(error_regex " *// *error: *([^\n]+) *")
file(READ ${INPUT} original_source_content)

string(REGEX MATCHALL ${error_regex} split_error_regexes "${original_source_content}")
string(REGEX REPLACE ${error_regex} "" split_source_content "${original_source_content}")
list(TRANSFORM split_error_regexes REPLACE ${error_regex} \\1)

file(WRITE ${OUTPUT} "${split_source_content}")
list(JOIN split_error_regexes .* error_regex)

function(include_jegp_string_json_find)
  include(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/JEGPStringJsonFind.cmake)
endfunction()
include_jegp_string_json_find()

file(READ compile_commands.json compile_commands)
_jegp_string(JSON compile_command FIND ${compile_commands} ${OUTPUT} [[${i}]] file)
string(JSON command GET ${compile_command} command)
string(JSON directory GET ${compile_command} directory)
separate_arguments(command)

execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${directory}
  RESULT_VARIABLE compiled
  OUTPUT_VARIABLE compiler_output
  ERROR_VARIABLE compiler_output)

if(compiled EQUAL 0)
  message(FATAL_ERROR "Target ${TARGET} for compiler error test compiled successfully!")
endif()

string(REGEX MATCH "${error_regex}" matched "${compiler_output}")

if(NOT matched)
  message(FATAL_ERROR ${compiler_output}
                      "Failed with ${compiled}. Compiler output for ${TARGET} did not match \"${error_regex}\"")
endif()
