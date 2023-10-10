include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPParseArguments.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPSetScript.cmake")

function(jegp_add_standardese_sources name)
  include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/JEGPUtilities.cmake")

  _jegp_parse_arguments("" "EXCLUDE_PDF_FROM_MAIN;EXCLUDE_HTML_FROM_MAIN;EXCLUDE_FROM_ALL" "CHECKED;PDF_PATH;HTML_PATH"
                        "LIBRARIES;APPENDICES;EXTENSIONS" ${ARGN})
  _jegp_assert(_LIBRARIES "No `LIBRARIES <source>`s specified.")

  function(cache_configurations configs_file)
    unset(configs_content)
    unset(section_separator)
    function(append_configs)
      cmake_parse_arguments("" "COMMENTED_OUT" "HEADER" "IN_ITEMS" ${ARGN})

      unset(prefix)
      if(_COMMENTED_OUT)
        set(prefix "#")
      endif()

      unset(new_configs)
      foreach(var IN ITEMS ${_IN_ITEMS})
        string(APPEND new_configs "${prefix}set(${var} [[${${var}}]])\n")
      endforeach()

      if(new_configs)
        unset(header)
        if(_HEADER)
          set(header "# ${_HEADER}\n")
        endif()

        set(configs_content "${configs_content}${section_separator}${header}${new_configs}" PARENT_SCOPE)
        set(section_separator "\n" PARENT_SCOPE)
      endif()
    endfunction()

    unset(set_vars)
    unset(missing_vars)
    foreach(var IN ITEMS pdf_title;page_license;first_library_chapter;last_library_chapter)
      if(DEFINED ${var})
        list(APPEND set_vars ${var})
      else()
        list(APPEND missing_vars ${var})
      endif()
    endforeach()

    append_configs(IN_ITEMS ${set_vars})
    if(missing_vars)
      message(WARNING "Missing: ${missing_vars}")
      append_configs(HEADER "Missing" IN_ITEMS ${missing_vars} COMMENTED_OUT)
    endif()

    set(defaulted _jegp_standardese_sources_)
    if(NOT DEFINED pdf_creator)
      include(FindGit)
      execute_process(COMMAND "${GIT_EXECUTABLE}" config user.name OUTPUT_VARIABLE pdf_creator
                      OUTPUT_STRIP_TRAILING_WHITESPACE)
      set(${defaulted}pdf_creator TRUE)
    endif()
    if(NOT DEFINED cover_title)
      set(cover_title "${pdf_title}")
    endif()
    if(NOT DEFINED cover_footer)
      set(cover_footer
          [[\textbf{Note: this is an early draft. It's known to be incomplet and
  incorrekt, and it has lots of
  b\kern-1.2pta\kern1ptd\hspace{1.5em}for\kern-3ptmat\kern0.6ptti\raise0.15ex\hbox{n}g.}]])
      set(${defaulted}cover_footer TRUE)
    endif()

    set(var_default_pairs
        "pdf_creator;${pdf_creator}"
        "cover_title;${cover_title}"
        "cover_footer;${cover_footer}"
        "pdf_subject;${PROJECT_NAME}"
        [[document_number_header;Ref]]
        [[document_number;\\unspec]]
        [[previous_document_number;\\unspec]]
        [[release_date;\\today]]
        "reply_to_header;Reply at"
        [[reply_to;\\url{${PROJECT_HOMEPAGE_URL}}]]
        "check_comment_alignment;false")
    unset(set_optional_vars)
    unset(defaulted_vars)
    while(var_default_pairs)
      list(POP_FRONT var_default_pairs var default)

      if(DEFINED ${var} AND NOT DEFINED ${defaulted}${var})
        list(APPEND set_optional_vars ${var})
      else()
        list(APPEND defaulted_vars ${var})
      endif()

      _jegp_default_variable(${var} "${default}")
    endwhile()

    append_configs(HEADER "Set optionals" IN_ITEMS ${set_optional_vars})
    append_configs(HEADER "Defaulted" IN_ITEMS ${defaulted_vars})

    list(TRANSFORM _LIBRARIES REPLACE "(.+)" [[\\include{\1}]] OUTPUT_VARIABLE main_matter_includes)
    list(TRANSFORM _APPENDICES REPLACE "(.+)" [[\\include{\1}]] OUTPUT_VARIABLE appendix_includes)
    list(TRANSFORM _LIBRARIES REPLACE "(.+)" "\\1.tex" OUTPUT_VARIABLE library_sources)
    list(JOIN main_matter_includes "\n" _jegp_main_matter_includes)
    list(JOIN appendix_includes "\n" _jegp_appendix_includes)
    list(JOIN library_sources " " _jegp_library_sources)

    append_configs(HEADER "Internal" IN_ITEMS _jegp_main_matter_includes;_jegp_appendix_includes;_jegp_library_sources)

    file(WRITE "${configs_file}" "${configs_content}")
  endfunction()

  function(set_check_command check_command out_var)
    if(${_CHECKED})
      set(${out_var} "${check_command}" PARENT_SCOPE)
    else()
      set(noop_command "${CMAKE_COMMAND}" -E true)
      set(${out_var} ${noop_command} PARENT_SCOPE)
    endif()
  endfunction()

  include(ExternalProject)

  _jegp_default_variable(JEGP_STANDARDESE_SOURCES_GIT_REPOSITORY "https://github.com/JohelEGP/draft.git")
  _jegp_default_variable(JEGP_STANDARDESE_SOURCES_GIT_TAG "standardese_sources_base")
  ExternalProject_Add(
    ${name}
    GIT_REPOSITORY "${JEGP_STANDARDESE_SOURCES_GIT_REPOSITORY}"
    GIT_TAG "${JEGP_STANDARDESE_SOURCES_GIT_TAG}"
    GIT_SHALLOW TRUE
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    EXCLUDE_FROM_ALL ${_EXCLUDE_FROM_ALL})

  set(checkout_dir "${CMAKE_CURRENT_BINARY_DIR}/draft_checkout")
  ExternalProject_Add_Step(
    ${name} checkout_draft DEPENDEES update #
    COMMAND "${CMAKE_COMMAND}" -E copy_directory "<SOURCE_DIR>/source" "${checkout_dir}/source"
    COMMAND "${CMAKE_COMMAND}" -E copy_directory "<SOURCE_DIR>/tools" "${checkout_dir}/tools")

  list(TRANSFORM _LIBRARIES REPLACE "(.+)" "${CMAKE_CURRENT_SOURCE_DIR}/\\1.tex" OUTPUT_VARIABLE library_sources)
  list(TRANSFORM _APPENDICES REPLACE "(.+)" "${CMAKE_CURRENT_SOURCE_DIR}/\\1.tex" OUTPUT_VARIABLE appendix_sources)
  list(TRANSFORM _EXTENSIONS REPLACE "(.+)" "${CMAKE_CURRENT_SOURCE_DIR}/\\1.tex" OUTPUT_VARIABLE extension_sources)
  ExternalProject_Add_Step(
    ${name} copy_sources
    DEPENDEES checkout_draft
    DEPENDS ${library_sources} ${appendix_sources} ${extension_sources}
    COMMAND "${CMAKE_COMMAND}" -E copy_if_different ${library_sources} ${appendix_sources} ${extension_sources}
            "${checkout_dir}/source/"
    WORKING_DIRECTORY "${checkout_dir}/source/")

  set(configs_file "${CMAKE_CURRENT_BINARY_DIR}/_jegp_${name}_configurations.cmake")
  cache_configurations("${configs_file}")

  _jegp_set_script_directory("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/Standardese")
  _jegp_set_script_command(ConfigureSources "CONFIGS_FILE=${configs_file}")

  ExternalProject_Add_Step(${name} configure_sources DEPENDEES checkout_draft COMMAND ${ConfigureSources}
                           WORKING_DIRECTORY "${checkout_dir}/source/")

  set_check_command("../tools/check-source.sh" check_source_command)
  ExternalProject_Add_Step(${name} check_sources DEPENDEES copy_sources configure_sources
                           COMMAND ${check_source_command} WORKING_DIRECTORY "${checkout_dir}/source/")

  if(_PDF_PATH)
    set_check_command("../tools/check-output.sh" check_output_command)
    cmake_path(ABSOLUTE_PATH _PDF_PATH BASE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}" OUTPUT_VARIABLE pdf_path)
    ExternalProject_Add_Step(
      ${name} pdf
      COMMAND make quiet
      COMMAND ${check_output_command}
      COMMAND "${CMAKE_COMMAND}" -E copy "std.pdf" "${pdf_path}"
      DEPENDEES check_sources
      BYPRODUCTS "${_PDF_PATH}"
      EXCLUDE_FROM_MAIN ${_EXCLUDE_PDF_FROM_MAIN}
      WORKING_DIRECTORY "${checkout_dir}/source/")
    ExternalProject_Add_StepTargets(${name} pdf)
  endif()
endfunction()
