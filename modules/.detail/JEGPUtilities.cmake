macro(_jegp_assert condition error_message)
  cmake_language(
    EVAL
    CODE
    "
    if(NOT (${condition}))
      message(FATAL_ERROR [[Condition does not hold: ${condition}\nError message: ${error_message}]])
    endif()")
endmacro()

macro(_jegp_backward variable)
  if(DEFINED ${variable})
    set(${variable} ${${variable}} PARENT_SCOPE)
  else()
    unset(${variable} PARENT_SCOPE)
  endif()
endmacro()

macro(_jegp_default_variable variable)
  if(NOT DEFINED "${variable}")
    set("${variable}" ${ARGN})
  endif()
endmacro()

function(_jegp_do_not_compile source)
  set_source_files_properties(${source} PROPERTIES HEADER_FILE_ONLY Y)
endfunction()

function(_jegp_set_ternary variable condition true_value false_value)
  cmake_language(
    EVAL
    CODE
    "
    if(${condition})
      set(${variable} ${true_value} PARENT_SCOPE)
    else()
      set(${variable} ${false_value} PARENT_SCOPE)
    endif()")
endfunction()
