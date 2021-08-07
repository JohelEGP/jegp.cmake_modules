if(NOT DEFINED CMAKE_CURRENT_FUNCTION AND NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
  message(FATAL_ERROR "include() this module inside a function or script.")
endif()

macro(_jegp_define_variable variable default)
  if(NOT DEFINED "${variable}")
    set("${variable}" "${default}")
  endif()
endmacro()

_jegp_define_variable("JEGP_${PROJECT_NAME}_NAME_PREFIX" "${PROJECT_NAME}_")
