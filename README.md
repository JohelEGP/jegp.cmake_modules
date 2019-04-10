# JEGP CMake Modules

CMake modules that abstract common functionality in the JEGP libraries.

## Modules

### `jegp_add_test`

This module defines the following function.

```
jegp_add_test(<name>
              [COMPILE_ONLY]
              [SOURCE <source>]
              [COMPILE_OPTIONS <option>...]
              [LINK_LIBRARIES <library>...])
```

This function adds the executable target `jegp_test_${name}`.
- `COMPILE_ONLY` specifies that it doesn't need to be run by `ctest`.
- `SOURCE` specifies its source file in `${CMAKE_CURRENT_SOURCE_DIR}`.
    Defaults to `${name}.cpp`.
- `COMPILE_OPTIONS` specifies its `PRIVATE` compile options.
- `LINK_LIBRARIES` specifies its `PRIVATE` linked libraries
    besides `jegp::${PROJECT_NAME}`.
