include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPAddTarget.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPParseArguments.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/.detail/JEGPSetScript.cmake")

define_property(TARGET PROPERTY JEGP_COMPILED_MODULE_FILE BRIEF_DOCS "File of the CMI; PCM (Clang) or GCM (GCC)."
                FULL_DOCS "The source location of the module unit's Compiled Module Interface.")

function(jegp_add_module name)
  _jegp_parse_arguments("" "IMPORTABLE_HEADER" "" "SOURCES=${name}.cpp;COMPILE_OPTIONS;LINK_LIBRARIES" ${ARGN})
  include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/JEGPDefineVariables.cmake")

  set(_jegp_modules_script_dir "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.detail/CppModules")
  include("${_jegp_modules_script_dir}/Common.cmake")

  file(MAKE_DIRECTORY "${_jegp_modules_binary_dir}")

  set(compiled_module_file "${_jegp_modules_binary_dir}/${name}${JEGP_CMI_EXTENSION}")

  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    set_source_files_properties("${_SOURCES}" PROPERTIES OBJECT_OUTPUTS "${compiled_module_file}")
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    list(APPEND _jegp_modules_compile_options INTERFACE -fprebuilt-module-path=${_jegp_modules_binary_dir})
  endif()

  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    unset(suffix)
    if(_IMPORTABLE_HEADER)
      set(suffix -header)
    endif()
    list(APPEND _jegp_modules_compile_options PRIVATE -x c++${suffix})
  endif()

  _jegp_add_target(
    ${name}
    TYPE OBJECT_LIBRARY
    SOURCES ${_SOURCES}
    COMPILE_OPTIONS ${_COMPILE_OPTIONS} PUBLIC ${_jegp_modules_compile_options}
    LINK_LIBRARIES
      ${_LINK_LIBRARIES}
      INTERFACE
        $<$<TARGET_EXISTS:${name}>:$<$<NOT:$<IN_LIST:${name},$<TARGET_PROPERTY:LINK_LIBRARIES>>>:$<TARGET_OBJECTS:${name}>>>
    PROPERTIES EXPORT_COMPILE_COMMANDS TRUE)
  set_target_properties(${name} PROPERTIES JEGP_COMPILED_MODULE_FILE "${compiled_module_file}"
                                           EXPORT_PROPERTIES "JEGP_COMPILED_MODULE_FILE")

  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    if(_IMPORTABLE_HEADER)
      set(touched_object_files "${_jegp_modules_binary_dir}/${name}.o")
      add_custom_command(OUTPUT "${touched_object_files}" COMMAND "${CMAKE_COMMAND}" -E touch $<TARGET_OBJECTS:${name}>
                                                                  "${touched_object_files}")
      add_library(_jegp_touch_object_file_for_${name} OBJECT "${touched_object_files}")
      add_dependencies(_jegp_touch_object_file_for_${name} ${name})
      target_link_libraries(${name} INTERFACE _jegp_touch_object_file_for_${name})

      get_source_file_property(name "${_SOURCES}" LOCATION)
    endif()
    _jegp_modules_gnu_map("${name}" "${compiled_module_file}")
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    get_source_file_property(source "${_SOURCES}" LOCATION)

    _jegp_set_script_directory("${_jegp_modules_script_dir}")
    _jegp_set_script_command(CompileCMI "SOURCE=${source}" "BUILD_DIR=${CMAKE_BINARY_DIR}"
                             "COMPILED_MODULE_FILE=${compiled_module_file}")

    add_custom_command(OUTPUT "${compiled_module_file}" COMMAND ${CompileCMI} DEPENDS $<TARGET_OBJECTS:${name}>)
    target_sources(${name} PRIVATE "${compiled_module_file}")
  endif()
endfunction()

function(_jegp_module_dependency_scan)
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
          if(language STREQUAL "CXX" AND (EXISTS "${location}"))
            list(APPEND result "${location}")
          endif()
        endforeach()
      endforeach()
      set(${out_source_locations} ${result} PARENT_SCOPE)
    endfunction()

    function(set_source_module_dependencies #[[<source_locations>...]])
      # Sets `${out_modules}` to the list of _module-name_s in the _module-import-declaration_s of `"${source}"`.
      function(get_directly_imported_modules source_location out_modules)
        set(import_line ".*import *([^\"<>]+) *;.*")
        file(STRINGS "${source_location}" imported_modules REGEX "${import_line}")
        list(TRANSFORM imported_modules REPLACE "${import_line}" "\\1")
        set(${out_modules} "${imported_modules}" PARENT_SCOPE)
      endfunction()

      foreach(source_location IN LISTS ARGV)
        get_directly_imported_modules("${source_location}" directly_imported_modules)
        foreach(directly_imported_module IN LISTS directly_imported_modules)
          if(TARGET ${directly_imported_module})
            get_target_property(cmi ${directly_imported_module} JEGP_COMPILED_MODULE_FILE)
            set_property(SOURCE "${source_location}" DIRECTORY "${directory}" APPEND PROPERTY OBJECT_DEPENDS "${cmi}")
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

  get_directory_property(subdirectories SUBDIRECTORIES)
  foreach(directory IN ITEMS "${CMAKE_SOURCE_DIR}" LISTS subdirectories)
    set_directory_module_dependencies("${directory}")
  endforeach()
endfunction()
cmake_language(DEFER DIRECTORY "${CMAKE_SOURCE_DIR}" CALL _jegp_module_dependency_scan)
