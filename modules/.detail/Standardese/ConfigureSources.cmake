set(configurable_sources "config.tex" "std.tex" "../tools/check-source.sh")

include("${CONFIGS_FILE}")

foreach(source IN LISTS configurable_sources)
  configure_file("${source}" "${source}" @ONLY)
endforeach()
