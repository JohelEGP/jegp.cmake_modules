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
              [SOURCES <source>...]
              [COMPILE_OPTIONS <option>...]
              [LINK_LIBRARIES <library>...])
```

This function adds the executable target `${PROJECT_NAME}_test_${name}`.
- `COMPILE_ONLY` specifies that it doesn't need to be linked nor run by `ctest`.
- `SOURCES` specifies its source files in `${CMAKE_CURRENT_SOURCE_DIR}`.
  Defaults to `${name}.cpp`.
- `COMPILE_OPTIONS` specifies its `PRIVATE` compile options.
- `LINK_LIBRARIES` specifies its `PRIVATE` linked libraries.
  A valid target `${PROJECT_NAME}` is also implicitly linked (deprecated).

### `JEGPBuildError`

This module defines the following function.

```
jegp_add_build_error(<name>
                     [AS {TEST | BUILD_CHECK}]
                     [TYPE {OBJECT_LIBRARY | EXECUTABLE}]
                     [SOURCE <source>]
                     [COMPILE_OPTIONS <option>...]
                     [LINK_LIBRARIES <library>...])
```

This function permits checking that building the source fails with specified error messages.
The check is added as a test by default; it can also happen at build-time, according to `AS`.
The type of the target that builds the source is specified by `TYPE` and defaults to `OBJECT_LIBRARY`.
The meaning of the other keywords can be inferred from `jegp_add_test`.

The error message specifiers are in the source in their expected order of appearance in the build output.
They match the [regex][] ` *// *error(-regex)?: *([^\n]*) *`.
The build output contains or matches `\2` depending on whether `\1` matched.

A copy of the source without the error message specifiers is built for the check.

### `JEGPTestUtilities`

This module includes all other modules.

## Requirements

This repository reserves identifiers that begin with `JEGP_` and `_JEGP_` regardless of case.


[regex]: https://cmake.org/cmake/help/latest/command/string.html#regex-specification
