include("${CMAKE_CURRENT_LIST_DIR}/../JEGPReadExportedCompileCommand.cmake")

macro(prepare)
  jegp_read_exported_compile_command(#[[FOR]] "${SOURCE}" compile_cmd compile_dir #[[IN]] "${BUILD_DIR}")

  list(TRANSFORM compile_cmd REPLACE ".*\\.o$" "${COMPILED_MODULE_FILE}")
  list(APPEND compile_cmd -Xclang -emit-module-interface)
endmacro()

macro(build)
  execute_process(COMMAND ${compile_cmd} WORKING_DIRECTORY "${compile_dir}" COMMAND_ERROR_IS_FATAL ANY)
endmacro()

prepare()
build()
