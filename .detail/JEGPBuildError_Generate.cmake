cmake_policy(VERSION ${VERSION})

set(error_regex " *// *(error(-regex)?): *([^\n]*) *")
file(READ "${INPUT_SOURCE}" input_content)

string(REGEX REPLACE "${error_regex}" "" error_content "${input_content}")
string(REGEX MATCHALL "${error_regex}" error_message_specifiers "${input_content}")

foreach(specifier IN LISTS error_message_specifiers)
  string(REGEX MATCH "${error_regex}" "" "${specifier}")
  list(APPEND scanned_errors "${CMAKE_MATCH_1}" "${CMAKE_MATCH_3}")
endforeach()

if(AS STREQUAL "BUILD_CHECK")
  file(STRINGS "${INPUT_SOURCE}" dependencies REGEX "( *(# *include|import).*)") # Hard-coded assumptions.
  list(JOIN dependencies "\n" dependencies)
endif()

file(WRITE "${BUILD_ERROR_SOURCE}" "${error_content}")
file(WRITE "${SCANNED_ERRORS_FILE}" "${scanned_errors}")
file(WRITE "${SCANNED_DEPENDENCIES_SOURCE}" "${dependencies}\nint main(){}")
