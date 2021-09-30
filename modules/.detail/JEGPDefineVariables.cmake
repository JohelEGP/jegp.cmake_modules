if(NOT DEFINED CMAKE_CURRENT_FUNCTION AND NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
  message(FATAL_ERROR "include() this module inside a function or script.")
endif()

macro(_jegp_define_variable variable default)
  if(NOT DEFINED "${variable}")
    set("${variable}" "${default}")
  endif()
endmacro()

_jegp_define_variable("JEGP_CXX_HEADER_FILE_EXTENSIONS" "H;h++;hh;hpp;hxx;h;HPP")
_jegp_define_variable("JEGP_${PROJECT_NAME}_NAME_PREFIX" "${PROJECT_NAME}_")

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  set("JEGP_CMI_EXTENSION" ".gcm")
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  set("JEGP_CMI_EXTENSION" ".pcm")
endif()
