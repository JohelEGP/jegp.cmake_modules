# `JEGPCpp2`

This module defines the following functions.

```
jegp_cpp2_target(<target>)
```

This function enables the target to compile its Cpp2 source files.

The target's `SOURCES` property is inspected for Cpp2 source files.
Corresponding Cpp1 source files are generated and added as sources to the target.

```
jegp_cpp2_target_sources()
```

[`target_sources`][] for Cpp2 source files.

For each argument that is a Cpp2 source file,
sets up the generation of its Cpp1 source file under [`CMAKE_CURRENT_BINARY_DIR`][], and
replaces it with the generated Cpp1 source file
before finally forwarding to `target_sources`.

[`target_sources`]: https://cmake.org/cmake/help/latest/command/target_sources.html
[`CMAKE_CURRENT_BINARY_DIR`]: https://cmake.org/cmake/help/latest/variable/CMAKE_CURRENT_BINARY_DIR.html
