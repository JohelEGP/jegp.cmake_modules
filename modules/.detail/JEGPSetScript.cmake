include("${CMAKE_CURRENT_LIST_DIR}/JEGPUtilities.cmake")

# Set the parent directory of scripts to `_jegp_set_script_command` as-if by a variable in the invoker's scope.
function(_jegp_set_script_directory dir)
  set(_jegp_script_dir "${dir}" PARENT_SCOPE)
endfunction()

# Set `${script}` as a command to run `${script}.cmake` with the given variables and the latest policies.
function(_jegp_set_script_command script #[[<variable=value>...]])
  cmake_parse_arguments("" "" "" "--" ${ARGN})
  list(JOIN _-- ";-D;" unparsed_options)
  list(JOIN _UNPARSED_ARGUMENTS ";-D;" defined_variables)

  _jegp_assert(defined_variables "The following implementation requires at least one defined variable to prepend `-D`.")

  # cmake-format: off
  set("${script}"
      "${CMAKE_COMMAND}" -D "_JEGP_SCRIPT=${_jegp_script_dir}/${script}.cmake"
                         -D ${defined_variables}
                         -P "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/JEGPIncludeScript.cmake"
                         ${unparsed_options}
      PARENT_SCOPE) # cmake-format: on
endfunction()
