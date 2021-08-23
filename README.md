# JEGP CMake Modules

CMake modules that abstract common functionality in the JEGP libraries.

## Variables

This repository reserves identifiers that begin with `JEGP_` and `_JEGP_` regardless of case.

### Variables that Change Behavior

- `JEGP_<PROJECT-NAME>_NAME_PREFIX`:
Prefix of names added by these modules.
When not defined, `${PROJECT_NAME}_` is prefixed.
_Base name_ refers to the unprefixed added name.

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

The target's base name is `test_headers`.
`${PROJECT_NAME}` is a `PRIVATE` linked library of the target.
The public headers of `${PROJECT_NAME}` are those ending in `.hpp`
in the directory `${${PROJECT_NAME}_SOURCE_DIR}/include`.

### `JEGPAddTest`

This module defines the following function.

```
jegp_add_test(<name>
              [TYPE {EXECUTABLE | OBJECT_LIBRARY} |
               COMPILE_ONLY]
              [SOURCES <source>...]
              [COMPILE_OPTIONS <option>...]
              [LINK_LIBRARIES <library>...])
```

This function adds a target with base name `test_${name}`.
- `TYPE` specifies the type of the added target and defaults to `EXECUTABLE`. \
  [ _Note:_ An `OBJECT_LIBRARY` target effectively serves as compile-time test. -- _end note_ ]
- `COMPILE_ONLY` is equivalent to `TYPE OBJECT_LIBRARY` (deprecated).
- `SOURCES` specifies its source files in `${CMAKE_CURRENT_SOURCE_DIR}`.
  Defaults to `${name}.cpp`.
- `COMPILE_OPTIONS` specifies its `PRIVATE` compile options.
- `LINK_LIBRARIES` specifies its `PRIVATE` linked libraries.

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


[SF.11]: http://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Rs-contained
"Header files should be self-contained"
