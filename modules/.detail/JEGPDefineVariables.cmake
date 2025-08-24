if(NOT DEFINED CMAKE_CURRENT_FUNCTION AND NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
  message(FATAL_ERROR "include() this module inside a function or script.")
endif()

include("${CMAKE_CURRENT_LIST_DIR}/JEGPUtilities.cmake")
