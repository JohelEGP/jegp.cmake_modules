if(NOT DEFINED CMAKE_CURRENT_FUNCTION AND NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
  message(FATAL_ERROR "include() this module inside a function or script.")
endif()

include("${CMAKE_CURRENT_LIST_DIR}/JEGPUtilities.cmake")

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  set("JEGP_CMI_EXTENSION" ".gcm")
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  set("JEGP_CMI_EXTENSION" ".pcm")
endif()
