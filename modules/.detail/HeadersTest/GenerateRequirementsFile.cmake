file(READ "${HEADER_FILE_EXTENSIONS_FILE}" header_file_extensions)

foreach(include_dir IN LISTS INCLUDE_DIRECTORIES)
  list(TRANSFORM header_file_extensions PREPEND "${include_dir}/*." OUTPUT_VARIABLE headers_glob)

  file(GLOB_RECURSE headers LIST_DIRECTORIES false RELATIVE "${include_dir}" ${headers_glob})
  foreach(regex IN LISTS PRIVATE_REGEXES)
    list(FILTER headers EXCLUDE REGEX ${regex})
  endforeach()

  list(APPEND requirements ${include_dir} ${TARGET} ${headers})
endforeach()

file(APPEND ${OUTPUT_FILE} "${requirements}")
