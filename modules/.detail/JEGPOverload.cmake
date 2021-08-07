include("${CMAKE_CURRENT_LIST_DIR}/JEGPUtilities.cmake")

macro(_jegp_overload keyword_function_map)
  set(_jegp_keyword_function_map ${keyword_function_map})

  while(_jegp_keyword_function_map)
    list(POP_FRONT _jegp_keyword_function_map _jegp_keyword _jegp_function)

    if(ARGV0 STREQUAL _jegp_keyword)
      cmake_language(EVAL CODE ${_jegp_function} [[(${ARGV})]])

      foreach(result IN LISTS _jegp_overload_results)
        _jegp_backward(${result})
      endforeach()

      set(_jegp_overload_invoked "Y")
      break()
    endif()
  endwhile()

  if(NOT _jegp_overload_invoked)
    cmake_language(EVAL CODE message [[(FATAL_ERROR "No ${CMAKE_CURRENT_FUNCTION}(${ARGV0}) overload.")]])
  endif()
  unset(_jegp_overload_invoked)
endmacro()

macro(_jegp_set_overload_results)
  set(_jegp_overload_results ${ARGV} PARENT_SCOPE)
endmacro()
