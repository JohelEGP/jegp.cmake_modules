macro(prepare)
  foreach(n RANGE ${CMAKE_ARGC})
    if(DEFINED compile_module)
      list(APPEND compile_module "${CMAKE_ARGV${n}}")
    elseif("${CMAKE_ARGV${n}}" STREQUAL "--")
      set(compile_module "")
    endif()
  endforeach()

  set(compile_object "${compile_module}")

  list(TRANSFORM compile_module REPLACE ".*\\.o" "${COMPILED_MODULE_FILE}")

  list(REMOVE_ITEM compile_object --precompile;-x;c++-module "${SOURCE}")
  list(APPEND compile_object "${COMPILED_MODULE_FILE}" -Wno-unused-command-line-argument)
endmacro()

macro(build)
  execute_process(COMMAND ${compile_module} COMMAND_ERROR_IS_FATAL ANY)
  execute_process(COMMAND ${compile_object} COMMAND_ERROR_IS_FATAL ANY)
endmacro()

prepare()
build()
