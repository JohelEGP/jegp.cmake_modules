include("${CMAKE_CURRENT_LIST_DIR}/JEGPOverload.cmake")

function(_jegp_substring_after)
  cmake_parse_arguments("" "" "SUBSTRING_AFTER;SUBSTRING;FOUND" "" ${ARGN})
  set(string ${${_SUBSTRING_AFTER}})

  _jegp_set_overload_results(${_SUBSTRING_AFTER} ${_FOUND})

  string(FIND "${string}" "${_SUBSTRING}" substring_begin)
  if(substring_begin EQUAL -1)
    set(${_FOUND} "N" PARENT_SCOPE)
    return()
  endif()

  string(LENGTH "${_SUBSTRING}" substring_length)
  math(EXPR substring_after_begin "${substring_begin} + ${substring_length}")
  string(SUBSTRING "${string}" ${substring_after_begin} -1 substring_after)

  set(${_SUBSTRING_AFTER} "${substring_after}" PARENT_SCOPE)
  set(${_FOUND} "Y" PARENT_SCOPE)
endfunction()

function(_jegp_json_string)
  cmake_parse_arguments("" "" "JSON;FIND_ITH;VALUE" "KEYS" ${ARGN})
  set(json_string ${_FIND_ITH})

  _jegp_set_overload_results(${_JSON})

  string(JSON size LENGTH ${json_string})
  math(EXPR size "${size} - 1")

  foreach(i RANGE ${size})
    cmake_language(EVAL CODE "set(value_keys ${_KEYS})")
    string(JSON value GET "${json_string}" ${value_keys})

    if(value STREQUAL _VALUE)
      list(FIND _KEYS [[${i}]] i_pos)
      list(SUBLIST value_keys 0 ${i_pos} ith_parent_keys)

      string(JSON ith GET "${json_string}" ${ith_parent_keys} ${i})
      set(${_JSON} ${ith} PARENT_SCOPE)

      return()
    endif()
  endforeach()

  set(${_JSON} "NOTFOUND" PARENT_SCOPE)
endfunction()

function(_jegp_string)
  _jegp_overload("SUBSTRING_AFTER;_jegp_substring_after;JSON;_jegp_json_string")
endfunction()
