message(DEPRECATION "This module is deprecated. Use cmake-cxxmodules(7).")

include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPAddTarget.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPCppUtilities.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPDefineTarget.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPParseArguments.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPSetScript.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPUtilities.cmake")

# Implies "is a module".
define_property(TARGET PROPERTY JEGP_COMPILED_MODULE_FILE BRIEF_DOCS "File of the CMI; PCM (Clang) or GCM (GCC)."
                FULL_DOCS "The source location of the module unit's Compiled Module Interface.")

# Implies "is a named module".
define_property(TARGET PROPERTY _JEGP_MODULE_NAME BRIEF_DOCS "Module name." FULL_DOCS "_module-name_.")
define_property(TARGET PROPERTY _JEGP_DIRECTLY_IMPORTED_MODULES)

define_property(GLOBAL PROPERTY _JEGP_BUILDSYSTEM_NAMED_MODULE_TARGETS BRIEF_DOCS "Targets of added named modules."
                FULL_DOCS "Buildsystem targets of named modules added via `jegp_cpp_module`.")

# Sets `${out_module}` to the _module-name_ in the _module-declaration_s of `"${source}"`.
function(_jegp_get_module_name source out_module)
  set(module_declaration ".*export +module +(.+) *;.*")
  file(STRINGS "${source}" module_name REGEX "${module_declaration}")
  list(TRANSFORM module_name REPLACE "${module_declaration}" "\\1")
  set(${out_module} "${module_name}" PARENT_SCOPE)
endfunction()

# Sets `${out_modules}` to the list of _module-name_s in the _module-import-declaration_s of `"${source}"`.
function(_jegp_get_directly_imported_modules source out_modules)
  set(import_line ".*import +([^\"<>]+) *;.*")
  file(STRINGS "${source}" imported_modules REGEX "${import_line}")
  list(TRANSFORM imported_modules REPLACE "${import_line}" "\\1")
  set(${out_modules} "${imported_modules}" PARENT_SCOPE)
endfunction()

function(jegp_add_module name)
  _jegp_parse_arguments("" "" "" "SOURCES=${name}.cpp;COMPILE_OPTIONS;LINK_LIBRARIES" ${ARGN})

  _jegp_add_target(
    ${name}
    TYPE OBJECT_LIBRARY
    SOURCES ${_SOURCES}
    COMPILE_OPTIONS ${_COMPILE_OPTIONS}
    LINK_LIBRARIES ${_LINK_LIBRARIES})

  jegp_cpp_module("${name}" ${_UNPARSED_ARGUMENTS})
endfunction()

function(jegp_cpp_module name)
  _jegp_parse_arguments("" "IMPORTABLE_HEADER" "MODULE_INTERFACE_UNIT" "" ${ARGN})
  _jegp_assert([[NOT _IMPORTABLE_HEADER OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU"]]
               "Keyword IMPORTABLE_HEADER requires GNU as CMAKE_CXX_COMPILER_ID.")
  _jegp_assert([[NOT (_IMPORTABLE_HEADER AND DEFINED _MODULE_INTERFACE_UNIT)]] "Keywords are mutually exclusive.")

  if(_MODULE_INTERFACE_UNIT)
    set(_SOURCES "${_MODULE_INTERFACE_UNIT}")
  else()
    _jegp_get_target_cpp_sources("${name}" _SOURCES)
  endif()

  include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/JEGPDefineVariables.cmake")

  set(_jegp_modules_script_dir "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/CppModules")
  include("${_jegp_modules_script_dir}/Common.cmake")

  file(MAKE_DIRECTORY "${_jegp_modules_binary_dir}")

  set(cmi_stem "${name}")
  if(NOT _IMPORTABLE_HEADER)
    _jegp_get_module_name("${_SOURCES}" module_name)
    set(cmi_stem "${module_name}")
  endif()
  set(compiled_module_file "${_jegp_modules_binary_dir}/${cmi_stem}${JEGP_CMI_EXTENSION}")

  set_source_files_properties("${_SOURCES}" PROPERTIES OBJECT_OUTPUTS "${compiled_module_file}")
  if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    list(APPEND _jegp_modules_compile_options INTERFACE -fprebuilt-module-path=${_jegp_modules_binary_dir})
  endif()

  unset(suffix)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND _IMPORTABLE_HEADER)
    set(suffix -header)
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    list(APPEND _jegp_modules_compile_options PRIVATE "-fmodule-output=${compiled_module_file}")
    set(suffix -module)
  endif()
  list(APPEND _jegp_modules_compile_options PRIVATE -x c++${suffix})

  _jegp_define_target(
    ${name} COMPILE_OPTIONS PUBLIC ${_jegp_modules_compile_options}
    PROPERTIES JEGP_COMPILED_MODULE_FILE "${compiled_module_file}")
  set_target_properties(
    ${name} PROPERTIES EXPORT_PROPERTIES "JEGP_COMPILED_MODULE_FILE;_JEGP_MODULE_NAME;_JEGP_DIRECTLY_IMPORTED_MODULES")
  if(NOT _IMPORTABLE_HEADER)
    _jegp_get_directly_imported_modules(${_SOURCES} directly_imported_modules)
    set_target_properties(${name} PROPERTIES _JEGP_DIRECTLY_IMPORTED_MODULES "${directly_imported_modules}")
    set_target_properties(${name} PROPERTIES _JEGP_MODULE_NAME "${module_name}")
    set_property(GLOBAL APPEND PROPERTY _JEGP_BUILDSYSTEM_NAMED_MODULE_TARGETS ${name})
  endif()

  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    if(_IMPORTABLE_HEADER)
      add_custom_target(_jegp_touch_object_of_${name} ALL COMMAND "${CMAKE_COMMAND}" -E touch $<TARGET_OBJECTS:${name}>)
      add_dependencies(_jegp_touch_object_of_${name} ${name})
      get_source_file_property(module_name "${_SOURCES}" LOCATION)
    endif()
    _jegp_modules_gnu_map("${module_name}" "${compiled_module_file}")
  endif()
endfunction()

function(_jegp_module_dependency_scan)
  # Sets ${key_prefix}_${module_name}_target to the target of ${module_name}.
  # Sets ${key_prefix}_${module_name}_cmi to the CMI of ${module_name}.
  function(set_mappings_from_module_name key_prefix imported_named_module_targets_var)
    get_property(buildsystem_named_module_targets GLOBAL PROPERTY _JEGP_BUILDSYSTEM_NAMED_MODULE_TARGETS)
    foreach(target IN LISTS buildsystem_named_module_targets ${imported_named_module_targets_var})
      get_target_property(module_name ${target} _JEGP_MODULE_NAME)
      get_target_property(cmi ${target} JEGP_COMPILED_MODULE_FILE)
      set(${key_prefix}_${module_name}_target ${target} PARENT_SCOPE)
      set(${key_prefix}_${module_name}_cmi "${cmi}" PARENT_SCOPE)
    endforeach()
  endfunction()

  function(set_module_object_dependencies imported_named_module_targets_var)
    function(get_imported_modules target out_modules)
      macro(set_imported_modules out_list target)
        get_target_property(${out_list} ${target} _JEGP_DIRECTLY_IMPORTED_MODULES)
      endmacro()

      set_imported_modules(unlisted_modules ${target})

      set(imported_modules)
      while(unlisted_modules)
        list(POP_FRONT unlisted_modules module)
        list(APPEND imported_modules "${module}")

        if(TARGET ${_jegp_${module}_target})
          set_imported_modules(more_unlisted_modules ${_jegp_${module}_target})
          list(APPEND unlisted_modules "${more_unlisted_modules}")
          list(REMOVE_DUPLICATES unlisted_modules)
        endif()
      endwhile()

      set(${out_modules} "${imported_modules}" PARENT_SCOPE)
    endfunction()

    get_property(buildsystem_named_module_targets GLOBAL PROPERTY _JEGP_BUILDSYSTEM_NAMED_MODULE_TARGETS)
    foreach(target IN LISTS buildsystem_named_module_targets ${imported_named_module_targets_var})
      if(TARGET ${target})
        get_imported_modules(${target} imported_modules)
        foreach(imported_module IN LISTS imported_modules)
          set(imported_module_target ${_jegp_${imported_module}_target})
          if(TARGET ${imported_module_target})
            target_sources(
              ${target}
              INTERFACE "$<$<TARGET_EXISTS:${imported_module_target}>:$<TARGET_OBJECTS:${imported_module_target}>>")
          endif()
        endforeach()
      endif()
    endforeach()
  endfunction()

  function(set_directory_module_dependencies directory)
    function(get_source_locations out_source_locations)
      function(get_targets out_targets)
        get_directory_property(targets DIRECTORY "${directory}" BUILDSYSTEM_TARGETS)
        foreach(target IN LISTS targets)
          get_target_property(source_dir ${target} SOURCE_DIR)
          if(source_dir STREQUAL directory)
            list(APPEND result "${target}")
          endif()
        endforeach()
        set(${out_targets} ${result} PARENT_SCOPE)
      endfunction()

      get_targets(targets)
      foreach(target IN LISTS targets)
        get_target_property(sources ${target} SOURCES)
        if(NOT sources)
          continue()
        endif()
        foreach(source IN LISTS sources)
          cmake_path(ABSOLUTE_PATH source BASE_DIRECTORY "${directory}" OUTPUT_VARIABLE location)
          get_source_file_property(language "${location}" DIRECTORY "${directory}" LANGUAGE)
          if(language STREQUAL "CXX" AND EXISTS "${location}")
            list(APPEND result "${location}")
          endif()
        endforeach()
      endforeach()
      set(${out_source_locations} ${result} PARENT_SCOPE)
    endfunction()

    function(set_source_module_dependencies #[[<source_locations>...]])
      foreach(source_location IN LISTS ARGV)
        _jegp_get_directly_imported_modules("${source_location}" directly_imported_modules)
        foreach(directly_imported_module IN LISTS directly_imported_modules)
          if(TARGET ${_jegp_${directly_imported_module}_target})
            set_property(SOURCE "${source_location}" DIRECTORY "${directory}" APPEND
                         PROPERTY OBJECT_DEPENDS "${_jegp_${directly_imported_module}_cmi}")
          endif()
        endforeach()
        get_source_file_property(object_depends "${source_location}" DIRECTORY "${directory}" OBJECT_DEPENDS)
        if(object_depends)
          list(REMOVE_DUPLICATES object_depends)
          set_source_files_properties("${source_location}" DIRECTORY "${directory}" PROPERTIES OBJECT_DEPENDS
                                                                                               "${object_depends}")
        endif()
      endforeach()
    endfunction()

    get_source_locations(source_locations)
    set_source_module_dependencies(${source_locations})
  endfunction()

  function(set_directories out_list)
    macro(set_subdirectories out_list directory)
      get_directory_property(${out_list} DIRECTORY "${directory}" SUBDIRECTORIES)
    endmacro()

    set(directories "${CMAKE_SOURCE_DIR}")
    set_subdirectories(unlisted_directories "${CMAKE_SOURCE_DIR}")

    while(unlisted_directories)
      list(POP_FRONT unlisted_directories directory)
      if(NOT directory)
        continue()
      endif()

      list(APPEND directories "${directory}")

      set_subdirectories(more_unlisted_directories "${directory}")
      list(APPEND unlisted_directories "${more_unlisted_directories}")
    endwhile()

    set(${out_list} "${directories}" PARENT_SCOPE)
  endfunction()

  function(set_imported_named_module_targets directories_var out_list)
    function(set_imported_targets out_list)
      foreach(directory IN LISTS ${directories_var})
        get_directory_property(directory_imported_targets DIRECTORY "${directory}" IMPORTED_TARGETS)
        list(APPEND all_imported_targets ${directory_imported_targets})
      endforeach()
      set(${out_list} "${all_imported_targets}" PARENT_SCOPE)
    endfunction()

    set_imported_targets(imported_targets)
    foreach(target IN LISTS imported_targets)
      if(NOT TARGET ${target})
        continue()
      endif()
      get_target_property(module_name ${target} _JEGP_MODULE_NAME)
      if(module_name)
        list(APPEND imported_named_module_targets ${target})
      endif()
    endforeach()
    set(${out_list} "${imported_named_module_targets}" PARENT_SCOPE)
  endfunction()

  set_directories(directories)
  set_imported_named_module_targets(directories imported_named_module_targets)
  set_mappings_from_module_name("_jegp" imported_named_module_targets)
  set_module_object_dependencies(imported_named_module_targets)
  foreach(directory IN LISTS directories)
    set_directory_module_dependencies("${directory}")
  endforeach()
endfunction()
cmake_language(DEFER DIRECTORY "${CMAKE_SOURCE_DIR}" CALL _jegp_module_dependency_scan)
