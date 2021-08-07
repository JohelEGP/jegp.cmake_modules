macro(_jegp_parse_arguments_structure)
  foreach(desc IN LISTS keyword_descriptions)
    if(desc MATCHES "(.+){(.+)}")
      set(keyword ${CMAKE_MATCH_1})
      set(domain ${CMAKE_MATCH_2})
      string(REPLACE "|" ";" domain "${domain}")
    elseif(desc MATCHES "(.+)=(.*)")
      set(keyword ${CMAKE_MATCH_1})
      set(default ${CMAKE_MATCH_2})
    else()
      set(keyword ${desc})
    endif()

    loop_end()

    unset(keyword)
    unset(default)
    unset(domain)
  endforeach()
endmacro()

function(_jegp_parse_arguments_values prefix keyword_descriptions)
  function(assert_domain)
    list(TRANSFORM domain REPLACE "=(.+)" "\\1")
    foreach(value IN LISTS ${parsed_keyword})
      list(FIND domain ${value} index)
      if(index EQUAL -1)
        message(FATAL_ERROR "${keyword} ${value} not in ${domain}.")
      endif()
    endforeach()
  endfunction()
  macro(set_domain_defaults)
    foreach(value IN LISTS domain)
      if(value MATCHES "=(.+)")
        list(APPEND default_values ${CMAKE_MATCH_1})
      endif()
    endforeach()
    if(default_values)
      set(${parsed_keyword} ${default_values} PARENT_SCOPE)
    endif()
    unset(default_values)
  endmacro()
  macro(loop_end)
    set(parsed_keyword ${prefix}_${keyword})
    if(${parsed_keyword} AND domain)
      assert_domain()
    elseif(domain)
      set_domain_defaults()
    elseif(default)
      set(${parsed_keyword} ${default} PARENT_SCOPE)
    endif()
  endmacro()
  _jegp_parse_arguments_structure()
endfunction()

function(_jegp_parse_arguments_keywords keyword_descriptions out_list)
  macro(loop_end)
    list(APPEND keyword_list ${keyword})
  endmacro()
  _jegp_parse_arguments_structure()
  set(${out_list} ${keyword_list} PARENT_SCOPE)
endfunction()

macro(_jegp_parse_arguments prefix options one_value_keyword_descriptions multi_value_keyword_descriptions)
  _jegp_parse_arguments_keywords("${one_value_keyword_descriptions}" ${prefix}_one_value_keywords)
  _jegp_parse_arguments_keywords("${multi_value_keyword_descriptions}" ${prefix}_multi_value_keywords)
  cmake_parse_arguments("${prefix}" "${options}" "${${prefix}_one_value_keywords}" "${${prefix}_multi_value_keywords}"
                        ${ARGN})
  _jegp_parse_arguments_values("${prefix}" "${one_value_keyword_descriptions}")
  _jegp_parse_arguments_values("${prefix}" "${multi_value_keyword_descriptions}")
  unset(${prefix}_one_value_keywords)
  unset(${prefix}_multi_value_keywords)
endmacro()
