include("${CMAKE_CURRENT_LIST_DIR}/GNUModuleMapper.cmake")

file(GLOB_RECURSE header_gcm LIST_DIRECTORIES FALSE "${GCM_CACHE}/*/${HEADER}.gcm")

string(REPLACE "${GCM_CACHE}" #[[WITH]] "" #[[OUT]] header_path #[[IN]] "${header_gcm}")
cmake_path(REMOVE_EXTENSION header_path LAST_ONLY)

jegp_gnu_module_mapper_add_mapping("${header_path}" "${header_gcm}" "${MODULE_MAPPER_FILE}")

file(CREATE_LINK "${header_gcm}" "${OUTPUT}" SYMBOLIC)
