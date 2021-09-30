include("${CMAKE_CURRENT_LIST_DIR}/JEGPString.cmake")

function(jegp_read_exported_compile_command for_source out_compile_cmd out_compile_dir in_build_dir)
  file(READ "${in_build_dir}/compile_commands.json" compile_commands_json)
  _jegp_string(JSON compile_command FIND_ITH "${compile_commands_json}" VALUE "${for_source}" KEYS [[${i}]] file)

  string(JSON #[[TO]] compile_dir GET #[[FROM]] "${compile_command}" #[[THE VALUE OF]] directory)
  string(JSON #[[TO]] compile_cmd GET #[[FROM]] "${compile_command}" #[[THE VALUE OF]] command)

  separate_arguments(compile_cmd NATIVE_COMMAND "${compile_cmd}")

  set(${out_compile_dir} ${compile_dir} PARENT_SCOPE)
  set(${out_compile_cmd} ${compile_cmd} PARENT_SCOPE)
endfunction()
