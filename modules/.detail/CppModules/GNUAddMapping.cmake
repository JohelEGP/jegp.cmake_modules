include("${CMAKE_CURRENT_LIST_DIR}/Common.cmake")

file(GLOB_RECURSE header_gcm LIST_DIRECTORIES FALSE "${GCM_CACHE}/*/${HEADER}.gcm")

string(REPLACE "${GCM_CACHE}" #[[WITH]] "" #[[OUT]] header_path #[[IN]] "${header_gcm}")
cmake_path(REMOVE_EXTENSION header_path LAST_ONLY)

_jegp_modules_gnu_map("${header_path}" "${GCM_SYMLINK}" "${MODULE_MAPPER_FILE}")

file(CREATE_LINK "${header_gcm}" "${GCM_SYMLINK}" SYMBOLIC)
