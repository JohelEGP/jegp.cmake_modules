macro(_jegp_backward variable)
  if(DEFINED ${variable})
    set(${variable} ${${variable}} PARENT_SCOPE)
  else()
    unset(${variable} PARENT_SCOPE)
  endif()
endmacro()

function(_jegp_do_not_compile source)
  set_source_files_properties(${source} PROPERTIES HEADER_FILE_ONLY Y)
endfunction()
