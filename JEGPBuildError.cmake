include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPAddTarget.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPParseArguments.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPUtilities.cmake")

function(jegp_add_build_error name)
  _jegp_parse_arguments("" "" "AS{=TEST|BUILD_CHECK};TYPE{=OBJECT_LIBRARY|EXECUTABLE};SOURCE=${name}.cpp"
                        "COMPILE_OPTIONS;LINK_LIBRARIES" ${ARGN})

  file(REAL_PATH "${_SOURCE}" input_source)
  _jegp_do_not_compile(${input_source})

  set(module_dir "${CMAKE_CURRENT_BINARY_DIR}/JEGPBuildError/${name}")
  set(scanned_dependencies_source "${module_dir}/scanned_dependencies.cpp")
  set(scanned_errors_file "${module_dir}/scanned_errors.json")
  set(build_error_source "${module_dir}/build_error.cpp")
  set(build_error_output "${module_dir}/build_error_latest_success.txt")

  set(build_error_target "${PROJECT_NAME}_build_${name}")
  set(check_command
      "${CMAKE_COMMAND}" -D AS=${_AS} -D "BUILD_DIR=${CMAKE_BINARY_DIR}" -D "BUILD_ERROR_SOURCE=${build_error_source}"
      -D "TARGET=${build_error_target}" -D "SCANNED_ERRORS_FILE=${scanned_errors_file}" -D
      "VERSION=${CMAKE_MINIMUM_REQUIRED_VERSION}" -P
      "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/JEGPBuildError_Check.cmake")

  add_custom_command(
    OUTPUT "${scanned_dependencies_source}" "${build_error_source}" # Generates the sources.
    COMMAND "${CMAKE_COMMAND}" -D AS=${_AS} -D "INPUT_SOURCE=${input_source}" -D
            "SCANNED_DEPENDENCIES_SOURCE=${scanned_dependencies_source}" -D "BUILD_ERROR_SOURCE=${build_error_source}"
            -D "SCANNED_ERRORS_FILE=${scanned_errors_file}" -D "VERSION=${CMAKE_MINIMUM_REQUIRED_VERSION}" -P
            "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/JEGPBuildError_Generate.cmake"
    DEPENDS "${input_source}")

  _jegp_add_target(
    "${build_error_target}" EXCLUDE_FROM_ALL
    TYPE ${_TYPE}
    SOURCES "${build_error_source}"
    COMPILE_OPTIONS ${_COMPILE_OPTIONS}
    LINK_LIBRARIES ${_LINK_LIBRARIES}
    PROPERTIES EXPORT_COMPILE_COMMANDS Y #[[Not needed when AS TEST.]])

  if(_AS STREQUAL TEST)
    add_test(NAME "${PROJECT_NAME}_test_${name}" COMMAND ${check_command})
  elseif(_AS STREQUAL BUILD_CHECK)
    set(dependencies_target "${PROJECT_NAME}_dependencies_of_${name}")
    set(check_target "${PROJECT_NAME}_check_${name}")

    _jegp_add_target(
      "${dependencies_target}"
      TYPE EXECUTABLE
      SOURCES "${input_source}" "${scanned_dependencies_source}"
      COMPILE_OPTIONS ${_COMPILE_OPTIONS}
      LINK_LIBRARIES ${_LINK_LIBRARIES})

    add_custom_command(
      OUTPUT "${build_error_output}"
      COMMAND ${check_command}
      COMMAND "${CMAKE_COMMAND}" -E touch "${build_error_output}"
      DEPENDS "${dependencies_target}")

    add_custom_target("${check_target}" ALL DEPENDS "${build_error_output}")
  endif()
endfunction()
