# JEGP CMake Modules

CMake modules that abstract common functionality in the JEGP libraries.

## Modules

### `JEGPAddHeaderTest`

This module defines the following function.

```
jegp_add_header_test()
```

This function enforces [SF.11]
for the public headers of the JEGP library `${PROJECT_NAME}`.
It adds an executable target that builds when the headers are self-contained.
Otherwise, a build error should give a clue about the problematic headers.

[SF.11]: http://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Rs-contained
"Header files should be self-contained"

The target name is `${PROJECT_NAME}_test_headers`.
`${PROJECT_NAME}` is a `PRIVATE` linked library of the target.
The public headers of `${PROJECT_NAME}` are those ending in `.hpp`
in the directory `${${PROJECT_NAME}_SOURCE_DIR}/include`.

### `JEGPAddTest`

This module defines the following function.

```
jegp_add_test(<name>
              [COMPILE_ONLY]
              [SOURCE <source> |
               SOURCES <source>...]
              [COMPILE_OPTIONS <option>...]
              [LINK_LIBRARIES <library>...])
```

This function adds the executable target `${PROJECT_NAME}_test_${name}`.
- `COMPILE_ONLY` specifies that it doesn't need to be linked nor run by `ctest`.
- `SOURCE` specifies its source file in `${CMAKE_CURRENT_SOURCE_DIR}`.
  Defaults to `${name}.cpp`.
- `COMPILE_OPTIONS` specifies its `PRIVATE` compile options.
- `LINK_LIBRARIES` specifies its `PRIVATE` linked libraries.
  A valid target `${PROJECT_NAME}` is also implicitly linked (deprecated).

### `JEGPCompilerError`

This module defines the following function.

```
jegp_add_compiler_error_test(<name>
                             [SOURCE <source>]
                             [COMPILE_OPTIONS <option>...]
                             [LINK_LIBRARIES <library>...])
```

This function adds a target to `all` that checks that
compiling the source fails with specified error messages.

The error messages appear in the source
in their expected order of appearance in the compiler error.
They match the regex ` *// *error: *([^\n]+) *`.
The submatch is what is checked.

### `JEGPTestUtilities`

This module includes all other modules.
