include("${CONFIGS_FILE}")

string(REPLACE ":" ";" CONFIGURABLE_SOURCES "${CONFIGURABLE_SOURCES}")
foreach(source IN LISTS CONFIGURABLE_SOURCES)
  configure_file("${source}" "${source}" @ONLY)
endforeach()
