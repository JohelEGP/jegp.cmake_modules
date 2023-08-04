include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPCheckCpp2.cmake")

function(_jegp_cpp2_generate cpp2_src)
  string(REGEX REPLACE "2$" "" cpp1_src "${cpp2_src}")

  cmake_path(GET cpp1_src PARENT_PATH cpp1_src_parent_path)
  cmake_path(GET cpp1_src FILENAME cpp1_src_filename)
  cmake_path(RELATIVE_PATH cpp1_src_parent_path BASE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
  string(PREPEND cpp1_src_parent_path "${CMAKE_CURRENT_BINARY_DIR}/${JEGP_CPPFRONT_BUILD_DIR}/")
  file(MAKE_DIRECTORY "${cpp1_src_parent_path}")
  set(cpp1_src "${cpp1_src_parent_path}/${cpp1_src_filename}")
  cmake_path(NORMAL_PATH cpp1_src)

  add_custom_command(
    OUTPUT "${cpp1_src}" COMMAND "${JEGP_CXX2_COMPILER}" "${JEGP_CXX2_FLAGS}" "${cpp2_src}" -o "${cpp1_src}"
    DEPENDS "${cpp2_src}" WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
  set_source_files_properties("${cpp1_src}" PROPERTIES INCLUDE_DIRECTORIES "${JEGP_CPPFRONT_INCLUDE_DIRECTORIES}")

  return(PROPAGATE cpp1_src)
endfunction()

function(jegp_cpp2_target name)
  get_target_property(cpp2_sources "${name}" SOURCES)
  list(FILTER cpp2_sources INCLUDE REGEX "\\.(cpp|h)2$")

  foreach(cpp2_src IN LISTS cpp2_sources)
    _jegp_cpp2_generate("${cpp2_src}")
    target_sources("${name}" PRIVATE "${cpp1_src}")
  endforeach()
endfunction()

function(jegp_cpp2_target_sources)
  set(args)
  foreach(i RANGE 0 ${ARGC})
    if(NOT (${ARGV${i}} MATCHES "\\.(cpp|h)2$"))
      list(APPEND args "\${ARGV${i}}")
      continue()
    endif()

    _jegp_cpp2_generate("${ARGV${i}}")
    set(ARGV${i} "${cpp1_src}")
    list(APPEND args "\${ARGV${i}}")
  endforeach()
  cmake_language(EVAL CODE "target_sources(${args})")
endfunction()
