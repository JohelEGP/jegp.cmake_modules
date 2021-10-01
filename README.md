# JEGP CMake Modules

CMake modules that abstract common functionality in the JEGP libraries.

## Variables

This repository reserves identifiers that begin with `JEGP_` and `_JEGP_` regardless of case.

### Variables that Change Behavior

- `JEGP_CXX_HEADER_FILE_EXTENSIONS`:
List of extensions for C++ header files.

- `JEGP_<PROJECT-NAME>_NAME_PREFIX`:
Prefix of names added by these modules.
When not defined, `${PROJECT_NAME}_` is prefixed.
_Base name_ refers to the unprefixed added name.

- `JEGP_SYSTEM_MODULES_CACHE`:
Cache path of the system's modules.

## Modules

### Project Modules

#### `JEGPAddModule`

This module defines the following function.

```
jegp_add_module(<name>
                [SOURCES <source>...]
                [COMPILE_OPTIONS <option>...]
                [LINK_LIBRARIES <library>...])
```

This function adds the object library `${name}`
representing a C++ module.
The meaning of the keywords are the same as for [`jegp_add_test`][],
except that `PRIVATE` is not implied.

#### `JEGPTargetLinkHeaderUnits`

This module defines the following function.

```
jegp_target_link_header_units(<target> <header>...)
```

This function specifies header units to use
when linking `${target}` and/or its dependents.

#### `JEGPProjectModules`

This module includes all project modules.

### Test Modules

#### `JEGPHeadersTest`

This module defines the following function.

```
jegp_add_headers_test(<target>...
                      [PRIVATE_REGEXES <regex>...])
```

This function enforces [SF.11]
on the public headers of the targets.
The headers are determined from
the `INTERFACE_INCLUDE_DIRECTORIES` property of the targets and
the `JEGP_CXX_HEADER_FILE_EXTENSIONS` variable,
excluding headers that [match][] any `PRIVATE_REGEXES`.

A target _`T`_ with base name `headers_test` is added.
When _`T`_ builds, the public headers are self-contained.
Invocations that share _`T`_ append headers to the build of _`T`_.

[ _Example:_
```CMake
add_library(mylib src/a.cpp)
target_include_directories(mylib PUBLIC src/)
jegp_add_headers_test(mylib PRIVATE_REGEXES "detail/;external/")
```
-- _end example_ ]

#### `JEGPAddHeaderTest`

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

#### `JEGPAddTest`

This module defines the following function.

```
jegp_add_test(<name>
              [TYPE {EXECUTABLE | OBJECT_LIBRARY}]
              [SOURCES <source>...]
              [COMPILE_OPTIONS <option>...]
              [LINK_LIBRARIES <library>...])
```

This function adds a target with base name `test_${name}`.
- `TYPE` specifies the type of the added target and defaults to `EXECUTABLE`. \
  [ _Note:_ An `OBJECT_LIBRARY` target effectively serves as compile-time test. -- _end note_ ]
- `SOURCES` specifies its source files in `${CMAKE_CURRENT_SOURCE_DIR}`.
  Defaults to `${name}.cpp`.
- `COMPILE_OPTIONS` specifies its `PRIVATE` compile options.
- `LINK_LIBRARIES` specifies its `PRIVATE` linked libraries.

#### `JEGPBuildError`

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
The check is done as a test by default; it can also be done at build-time, according to `AS`.
The meaning of the other keywords can be inferred from [`jegp_add_test`][],
except that `TYPE` defaults to `OBJECT_LIBRARY`.

The error message specifiers are in the source in their expected order of appearance in the build output.
They [match][] the regex ` *// *error(-regex)?: *([^\n]*) *`.
The build output contains or matches `\2` depending on whether `\1` matched.
A copy of the source without the error message specifiers is built for the check.

_Note:_ `AS BUILD_CHECK` has the limitations of [`CMAKE_EXPORT_COMPILE_COMMANDS`][].

#### `JEGPTestUtilities`

This module includes all test modules.


[`jegp_add_test`]: #jegpaddtest

[SF.11]: http://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Rs-contained
"Header files should be self-contained"

[match]: https://cmake.org/cmake/help/latest/command/string.html#regex-match

[`CMAKE_EXPORT_COMPILE_COMMANDS`]: https://cmake.org/cmake/help/latest/variable/CMAKE_EXPORT_COMPILE_COMMANDS.html
