include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPAddTarget.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPParseArguments.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPUtilities.cmake")

function(jegp_add_build_error name)
  _jegp_parse_arguments("" "" "AS{=TEST|BUILD_CHECK};TYPE{=OBJECT_LIBRARY|EXECUTABLE};SOURCE=${name}.cpp"
                        "COMPILE_OPTIONS;LINK_LIBRARIES" ${ARGN})

  include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/JEGPDefineVariables.cmake")
  set(name_prefix "${JEGP_${PROJECT_NAME}_NAME_PREFIX}")
  set(dependencies_target "${name_prefix}${name}_dependencies")
  set(build_target "${name_prefix}build_${name}")
  set(check_target "${name_prefix}check_${name}")
  set(test_name "${name_prefix}test_${name}")

  file(REAL_PATH "${_SOURCE}" input_source)
  _jegp_do_not_compile(${input_source})

  set(module_dir "${CMAKE_CURRENT_BINARY_DIR}/JEGPBuildError/${name}")
  set(dependencies_source "${module_dir}/dependencies.cpp")
  set(build_source "${module_dir}/build.cpp")
  set(errors_file "${module_dir}/errors.txt")
  set(success_output "${module_dir}/success.txt")

  function(set_script_command script)
    list(JOIN ARGN #[[WITH]] ";-D;" #[[TO]] defined_variables)
    # cmake-format: off
    set(${script}
        "${CMAKE_COMMAND}"
        -D ${defined_variables}
        -D "VERSION=${CMAKE_MINIMUM_REQUIRED_VERSION}"
        -P "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/BuildError/${script}.cmake"
        PARENT_SCOPE) # cmake-format: on
  endfunction()
  set_script_command(GenerateDependenciesSource "INPUT_SOURCE=${input_source}" "OUTPUT_SOURCE=${dependencies_source}")
  set_script_command(GenerateBuildSource "INPUT_SOURCE=${input_source}" "OUTPUT_SOURCE=${build_source}")
  set_script_command(GenerateErrorsFile "INPUT_SOURCE=${input_source}" "OUTPUT_FILE=${errors_file}")
  set_script_command(Check AS=${_AS} "BUILD_DIR=${CMAKE_BINARY_DIR}" "BUILD_SOURCE=${build_source}"
                     "TARGET=${build_target}" "ERRORS_FILE=${errors_file}")

  add_custom_command(OUTPUT "${dependencies_source}" COMMAND ${GenerateDependenciesSource} DEPENDS "${input_source}")
  add_custom_command(OUTPUT "${build_source}" COMMAND ${GenerateBuildSource} DEPENDS "${input_source}")
  add_custom_command(OUTPUT "${errors_file}" COMMAND ${GenerateErrorsFile} DEPENDS "${input_source}")
  add_custom_command(OUTPUT "${success_output}" COMMAND ${Check} COMMAND "${CMAKE_COMMAND}" -E touch "${success_output}"
                     DEPENDS "${dependencies_target}" "${build_source}" "${errors_file}")

  _jegp_add_target(
    "${build_target}" EXCLUDE_FROM_ALL
    TYPE ${_TYPE}
    SOURCES "${build_source}"
    COMPILE_OPTIONS PRIVATE ${_COMPILE_OPTIONS}
    LINK_LIBRARIES PRIVATE ${_LINK_LIBRARIES})

  if(_AS STREQUAL "TEST")
    target_sources("${build_target}" PRIVATE "${errors_file}")

    add_test(NAME "${test_name}" COMMAND ${Check})
  elseif(_AS STREQUAL "BUILD_CHECK")
    set_target_properties("${build_target}" PROPERTIES EXPORT_COMPILE_COMMANDS Y)

    _jegp_add_target(
      "${dependencies_target}"
      TYPE OBJECT_LIBRARY
      SOURCES "${input_source}" "${dependencies_source}"
      COMPILE_OPTIONS PRIVATE ${_COMPILE_OPTIONS}
      LINK_LIBRARIES PRIVATE ${_LINK_LIBRARIES})

    add_custom_target("${check_target}" ALL DEPENDS "${success_output}")
  endif()
endfunction()
