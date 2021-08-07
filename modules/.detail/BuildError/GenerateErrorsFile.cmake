cmake_policy(VERSION ${VERSION})

set(error_regex " *// *(error(-regex)?): *([^\n]*) *")
file(READ "${INPUT_SOURCE}" input_content)

string(REGEX MATCHALL "${error_regex}" #[[TO]] error_message_specifiers #[[IN]] "${input_content}")
foreach(specifier IN LISTS error_message_specifiers)
  string(REGEX MATCH "${error_regex}" #[[TO]] "" #[[IN]] "${specifier}")
  list(APPEND build_errors "${CMAKE_MATCH_1}" "${CMAKE_MATCH_3}")
endforeach()

file(WRITE "${OUTPUT_FILE}" "${build_errors}")
