cmake_policy(VERSION ${VERSION})
include("${CMAKE_CURRENT_LIST_DIR}/../JEGPString.cmake")

macro(prepare)
  macro(set_from_compile_command)
    file(READ "${BUILD_DIR}/compile_commands.json" compile_commands_json)
    _jegp_string(JSON compile_command FIND_ITH "${compile_commands_json}" VALUE "${BUILD_SOURCE}" KEYS [[${i}]] file)

    string(JSON #[[TO]] build_command GET #[[FROM]] "${compile_command}" #[[THE VALUE OF]] command)
    string(JSON #[[TO]] build_directory GET #[[FROM]] "${compile_command}" #[[THE VALUE OF]] directory)

    separate_arguments(build_command NATIVE_COMMAND "${build_command}")
  endmacro()

  set(build_command ${CMAKE_COMMAND} --build . --target ${TARGET})
  set(build_directory ${BUILD_DIR})
  if(AS STREQUAL "BUILD_CHECK")
    set_from_compile_command()
  endif()
endmacro()

macro(build)
  execute_process(
    COMMAND ${build_command}
    WORKING_DIRECTORY ${build_directory}
    RESULT_VARIABLE built
    OUTPUT_VARIABLE build_output
    ERROR_VARIABLE build_error)
endmacro()

macro(check)
  if(built EQUAL 0)
    message(FATAL_ERROR "Build output: \"${build_output}\".\nError: Expected build error. Got successful build.")
  endif()

  set(compile_output "${build_output}")
  if(AS STREQUAL "BUILD_CHECK")
    set(compile_output "${build_error}")
  endif()

  function(search_fatal_error search_type)
    message(FATAL_ERROR "Remaining build output: \"${compile_output}\".\n"
                        "Error: Failed with \"${built}\". Remaining build output does not ${search_type} \"${error}\".")
  endfunction()

  file(READ ${ERRORS_FILE} error_specifiers)
  while(error_specifiers)
    list(POP_FRONT error_specifiers type error)

    if(type STREQUAL "error")
      _jegp_string(SUBSTRING_AFTER compile_output SUBSTRING "${error}" FOUND contains_error)

      if(NOT contains_error)
        search_fatal_error("contain")
      endif()
    elseif(type STREQUAL "error-regex")
      if(NOT "${compile_output}" MATCHES "${error}")
        search_fatal_error("match")
      endif()
    else()
      message(FATAL_ERROR "Unknown error specifier type \"${type}\".")
    endif()
  endwhile()
endmacro()

prepare()
build()
check()
