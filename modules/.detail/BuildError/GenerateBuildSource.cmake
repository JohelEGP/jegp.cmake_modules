cmake_policy(VERSION ${VERSION})

set(error_regex " *// *(error(-regex)?): *([^\n]*) *")
file(READ "${INPUT_SOURCE}" input_content)

string(REGEX REPLACE "${error_regex}" #[[WITH]] "" #[[TO]] build_errors_content #[[IN]] "${input_content}")
file(WRITE "${OUTPUT_SOURCE}" "${build_errors_content}")
