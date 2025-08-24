# `JEGPBuildError`

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

[`jegp_add_test`]: ./JEGPAddTest.md
[match]: https://cmake.org/cmake/help/latest/command/string.html#regex-match
[`CMAKE_EXPORT_COMPILE_COMMANDS`]: https://cmake.org/cmake/help/latest/variable/CMAKE_EXPORT_COMPILE_COMMANDS.html
