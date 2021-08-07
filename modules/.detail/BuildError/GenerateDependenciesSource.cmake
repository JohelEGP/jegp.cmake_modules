cmake_policy(VERSION ${VERSION})

set(dependency_regex " *(# *include|import).*") # Hard-coded assumptions.

file(STRINGS "${INPUT_SOURCE}" #[[TO]] dependencies REGEX ${dependency_regex})
list(JOIN dependencies #[[GLUE]] "\n" #[[TO]] dependencies)

file(WRITE "${OUTPUT_SOURCE}" "${dependencies}\nint main(){}")
