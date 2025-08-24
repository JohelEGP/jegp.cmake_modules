# `JEGPAddTest`

This module defines the following function.

```
jegp_add_test(<name>
              [TYPE {EXECUTABLE | OBJECT_LIBRARY}]
              [SOURCES <source>...]
              [COMPILE_OPTIONS <option>...]
              [LINK_LIBRARIES <library>...])
```

This function adds the target `${name}`.
- `TYPE` specifies the type of the added target and defaults to `EXECUTABLE`. \
  [ _Note:_ An `OBJECT_LIBRARY` target effectively serves as compile-time test. -- _end note_ ]
- `SOURCES` specifies its source files in `${CMAKE_CURRENT_SOURCE_DIR}`.
  Defaults to `${name}.cpp`.
- `COMPILE_OPTIONS` specifies its `PRIVATE` compile options.
- `LINK_LIBRARIES` specifies its `PRIVATE` linked libraries.
