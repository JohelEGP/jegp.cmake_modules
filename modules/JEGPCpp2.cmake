include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPCheckCpp2.cmake")

function(jegp_cpp2_target name)
  get_target_property(cpp2_sources "${name}" SOURCES)
  list(FILTER cpp2_sources INCLUDE REGEX "\\.(cpp|h)2$")

  foreach(cpp2_src IN LISTS cpp2_sources)
    string(REGEX REPLACE "2$" "" cpp1_src "${cpp2_src}")

    cmake_path(GET cpp1_src PARENT_PATH cpp1_src_parent_path)
    cmake_path(GET cpp1_src FILENAME cpp1_src_filename)
    cmake_path(RELATIVE_PATH cpp1_src_parent_path BASE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
    string(PREPEND cpp1_src_parent_path "${CMAKE_CURRENT_BINARY_DIR}/JEGPCpp2/generated_sources/")
    file(MAKE_DIRECTORY "${cpp1_src_parent_path}")
    set(cpp1_src "${cpp1_src_parent_path}/${cpp1_src_filename}")

    add_custom_command(
      OUTPUT "${cpp1_src}" COMMAND "${JEGP_CXX2_COMPILER}" "${JEGP_CXX2_FLAGS}" "${cpp2_src}" -o "${cpp1_src}"
      DEPENDS "${cpp2_src}" WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
    target_sources("${name}" PRIVATE "${cpp1_src}")
    set_source_files_properties("${cpp1_src}" PROPERTIES INCLUDE_DIRECTORIES "${JEGP_CPPFRONT_INCLUDE_DIRECTORIES}")
  endforeach()
endfunction()
