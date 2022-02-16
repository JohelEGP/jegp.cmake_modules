include("${CONFIGS_FILE}")

foreach(source IN LISTS CONFIGURABLE_SOURCES)
  file(READ "${source}" contents)

  set(repls "${replacements}")
  while(repls)
    list(POP_FRONT repls old new)
    string(REGEX REPLACE "${old}" "${new}" contents "${contents}")
  endwhile()

  file(WRITE "${source}" "${contents}")
endforeach()
