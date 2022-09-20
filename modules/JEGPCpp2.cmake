include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPCheckCpp2.cmake")

function(jegp_cpp2_target name)
  get_target_property(cpp2_sources "${name}" SOURCES)
  list(FILTER cpp2_sources INCLUDE REGEX "\\.cpp2$")

  foreach(cpp2_src IN LISTS cpp2_sources)
    get_source_file_property(cpp2_src "${cpp2_src}" LOCATION)
    string(REGEX REPLACE "2$" "" cpp1_src "${cpp2_src}")

    add_custom_command(OUTPUT "${cpp1_src}" COMMAND "${JEGP_CXX2_COMPILER}" "${JEGP_CXX2_FLAGS}" "${cpp2_src}"
                       DEPENDS "${cpp2_src}" WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
    target_sources("${name}" PRIVATE "${cpp1_src}")
    set_source_files_properties("${cpp1_src}" PROPERTIES INCLUDE_DIRECTORIES "${JEGP_CPPFRONT_INCLUDE_DIRECTORIES}")
  endforeach()
endfunction()
