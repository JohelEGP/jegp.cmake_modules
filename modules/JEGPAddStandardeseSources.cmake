include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPParseArguments.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPSetScript.cmake")

function(jegp_add_standardese_sources name)
  include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/JEGPUtilities.cmake")

  _jegp_parse_arguments("" "EXCLUDE_FROM_ALL" "CHECKED" "LIBRARIES;APPENDICES;EXTENSIONS;PDF;HTML" ${ARGN})
  _jegp_parse_arguments("_PDF" "EXCLUDE_FROM_MAIN" "PATH" "" ${_PDF})
  _jegp_parse_arguments("_HTML" "EXCLUDE_FROM_MAIN" "PATH;SECTION_FILE_STYLE" "LATEX_REGEX_REPLACE;HTML_REGEX_REPLACE"
                        ${_HTML})
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

    append_configs(HEADER "Internal" IN_ITEMS _jegp_main_matter_includes _jegp_appendix_includes _jegp_library_sources)

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

  set(checkout_dir "${CMAKE_CURRENT_BINARY_DIR}/_jegp_${name}_draft_checkout")
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
    COMMAND "${CMAKE_COMMAND}" -E copy_if_different ${library_sources} ${appendix_sources} "${checkout_dir}/source/"
    WORKING_DIRECTORY "${checkout_dir}/source/")

  _jegp_set_script_directory("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/Standardese")

  set(valid_extensions bibliography macros_extensions)
  set(bibliography_configurable_source "${checkout_dir}/source/back.tex")
  set(macros_extensions_configurable_source "${checkout_dir}/source/macros.tex")
  foreach(ext IN LISTS _EXTENSIONS)
    _jegp_assert("ext IN_LIST valid_extensions" "Invalid `EXTENSIONS` value `${ext}`.")
  endforeach()
  foreach(ext IN LISTS valid_extensions)
    set(${ext}_configs_file "${CMAKE_CURRENT_BINARY_DIR}/_jegp_${name}_${ext}_configuration.cmake")

    set(var "_jegp_${ext}")
    if(ext IN_LIST _EXTENSIONS)
      _jegp_set_script_command(WriteConfigFile "CONFIGS_FILE=${${ext}_configs_file}" "VARIABLE=${var}"
                               "SOURCE=${CMAKE_CURRENT_SOURCE_DIR}/${ext}.tex")
      ExternalProject_Add_Step(${name} write_${ext}_config DEPENDEES update COMMAND ${WriteConfigFile})

      list(APPEND _jegp_${name}_written_configs write_${ext}_config)
    else()
      file(WRITE "${${ext}_configs_file}" "set(${var})")
    endif()

    _jegp_set_script_command(ConfigureSources "CONFIGS_FILE=${${ext}_configs_file}"
                             "CONFIGURABLE_SOURCES=${${ext}_configurable_source}")
    ExternalProject_Add_Step(${name} configure_${ext} DEPENDEES copy_sources ${_jegp_${name}_written_configs}
                             COMMAND ${ConfigureSources})

    list(APPEND _jegp_${name}_configured_extensions configure_${ext})
  endforeach()

  set(configs_file "${CMAKE_CURRENT_BINARY_DIR}/_jegp_${name}_configurations.cmake")
  cache_configurations("${configs_file}")

  _jegp_set_script_command(ConfigureSources "CONFIGS_FILE=${configs_file}"
                           "CONFIGURABLE_SOURCES=config.tex:preface.tex:std.tex:../tools/check-source.sh")

  ExternalProject_Add_Step(${name} configure_sources DEPENDEES copy_sources COMMAND ${ConfigureSources}
                           WORKING_DIRECTORY "${checkout_dir}/source/")

  set_check_command("../tools/check-source.sh" check_source_command)
  ExternalProject_Add_Step(${name} check_sources DEPENDEES configure_sources ${_jegp_${name}_configured_extensions}
                           COMMAND ${check_source_command} WORKING_DIRECTORY "${checkout_dir}/source/")

  if(_PDF_PATH)
    set_check_command("../tools/check-output.sh" check_output_command)
    cmake_path(ABSOLUTE_PATH _PDF_PATH BASE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}" OUTPUT_VARIABLE pdf_path)
    ExternalProject_Add_Step(
      ${name} pdf
      DEPENDEES check_sources
      COMMAND make quiet
      COMMAND ${check_output_command}
      COMMAND "${CMAKE_COMMAND}" -E copy "std.pdf" "${pdf_path}"
      BYPRODUCTS "${_pdf_path}"
      EXCLUDE_FROM_MAIN ${_PDF_EXCLUDE_FROM_MAIN}
      WORKING_DIRECTORY "${checkout_dir}/source/")
    ExternalProject_Add_StepTargets(${name} pdf)
  endif()

  if(_HTML_PATH)
    ExternalProject_Add_Step(
      ${name} copy_sources_back DEPENDEES check_sources
      COMMAND "${CMAKE_COMMAND}" -E copy_directory "${checkout_dir}/source/" "${CMAKE_CURRENT_SOURCE_DIR}/source/")

    set(latex_replacements_configs_file "${CMAKE_CURRENT_BINARY_DIR}/_jegp_${name}_latex_replacements.cmake")
    file(WRITE "${latex_replacements_configs_file}"
         "set(replacements [===[${_HTML_LATEX_REGEX_REPLACE}]===])\n"
         [[string(REPLACE ":" ";" CONFIGURABLE_SOURCES "${CONFIGURABLE_SOURCES}")]])

    list(TRANSFORM _LIBRARIES REPLACE "(.+)" "\\1.tex" OUTPUT_VARIABLE replacement_library_sources)
    list(TRANSFORM _APPENDICES REPLACE "(.+)" "\\1.tex" OUTPUT_VARIABLE replacement_appendix_sources)
    set(replacement_sources ${replacement_library_sources} ${replacement_appendix_sources})
    string(REPLACE ";" ":" replacement_sources "${replacement_sources}")

    _jegp_set_script_command(ApplyReplacements "CONFIGS_FILE=${latex_replacements_configs_file}"
                             "CONFIGURABLE_SOURCES=${replacement_sources}:back.tex")

    ExternalProject_Add_Step(${name} apply_latex_replacements DEPENDEES copy_sources_back COMMAND ${ApplyReplacements}
                             WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/source/")

    cmake_path(ABSOLUTE_PATH _HTML_PATH BASE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}" OUTPUT_VARIABLE html_path)

    set(html_replacements_configs_file "${CMAKE_CURRENT_BINARY_DIR}/_jegp_${name}_html_replacements.cmake")
    file(WRITE "${html_replacements_configs_file}"
         "set(replacements"
         "    [===[Working Draft<br>Programming Languages &mdash. C\\+\\+;${cover_title}]===]"
         "    [===[${_HTML_HTML_REGEX_REPLACE}]===])\n"
         "# Remove empty indexes.\n"
         "foreach(index IN ITEMS generalindex grammarindex headerindex moduleindex libraryindex conceptindex impldefindex)\n"
         "    if (NOT (EXISTS \"${html_path}/\${index}.html\"\n"
         "             OR EXISTS \"${html_path}/\${index}\"\n"
         "             OR EXISTS \"${html_path}/\${index}/\"))\n"
         "        list(APPEND replacements \"<h2 ><a href='\${index}/?(.html)?'>Index of [a-z -]+</a></h2><\" \"<\")\n"
         "    endif()\n"
         "endforeach()\n"
         "file(GLOB_RECURSE CONFIGURABLE_SOURCES LIST_DIRECTORIES false \"${html_path}/*\")\n"
         "list(FILTER CONFIGURABLE_SOURCES EXCLUDE REGEX [[.*(\\.css|\\.png)]])\n")
    if(DEFINED cover_footer_html)
      if(cover_footer_html STREQUAL "")
        set(_jegp_${name}_cover_footer_prefix "<br><br>")
      endif()
      file(APPEND "${html_replacements_configs_file}"
           "list(APPEND replacements\n"
           "     [[${_jegp_${name}_cover_footer_prefix}<b>Note: this is an early draft. It's known to be incomplet and incorrekt, and it has lots of b<span style='position:relative.left:-1.2pt'>a</span><span style='position:relative.left:1pt'>d</span> for<span style='position:relative.left:-3pt'>matti<span style='position:relative.bottom:0.15ex'>n</span>g.</span></b>]]\n"
           "     [[${cover_footer_html}]])\n")
    endif()
    if(NOT (bibliography IN_LIST _EXTENSIONS))
      file(APPEND "${html_replacements_configs_file}"
           "# Remove empty bibliography.\n"
           "list(APPEND replacements \"<div id='bibliography'><h2 ><a href='bibliography/?(.html)?'>Bibliography</a></h2><div class='tocChapter'></div></div><\" \"<\")\n"
           "list(APPEND replacements \"<div id='bibliography' class='section'><h1 >Bibliography</h1></div><\" \"<\")\n")
      list(APPEND _jegp_${name}_html_sources_to_remove "bibliography.html" "bibliography")
    endif()

    _jegp_set_script_command(ApplyReplacements "CONFIGS_FILE=${html_replacements_configs_file}")

    set(_jegp_${name}_remove_html_sources_command
        "${CMAKE_COMMAND}" -E chdir "14882" #
        "${CMAKE_COMMAND}" -E rm -rf ${_jegp_${name}_html_sources_to_remove} "${html_path}")
    ExternalProject_Add_Step(
      ${name} html
      DEPENDEES apply_latex_replacements
      COMMAND stack build
      COMMAND "${CMAKE_COMMAND}" -E rm -rf "14882"
      COMMAND stack exec cxxdraft-htmlgen "${CMAKE_CURRENT_SOURCE_DIR}" "${_HTML_SECTION_FILE_STYLE}"
      COMMAND ${_jegp_${name}_remove_html_sources_command}
      COMMAND "${CMAKE_COMMAND}" -E copy_directory "14882" "${html_path}"
      COMMAND ${ApplyReplacements}
      EXCLUDE_FROM_MAIN ${_HTML_EXCLUDE_FROM_MAIN}
      WORKING_DIRECTORY "${JEGP_CXXDRAFT_HTMLGEN_GIT_REPOSITORY}")
    ExternalProject_Add_StepTargets(${name} html)
  endif()
endfunction()
