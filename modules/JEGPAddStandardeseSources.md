# `JEGPAddStandardeseSources`

This module defines the following function.

```
jegp_add_standardese_sources(<name>
                             [EXCLUDE_FROM_ALL]
                             LIBRARIES <source>...
                             [APPENDICES <source>...]
                             [EXTENSIONS <source>...]
                             [CHECKED <condition>]
                             [PDF
                              [EXCLUDE_FROM_MAIN]
                              PATH <pdf_path>]
                             [HTML
                              [EXCLUDE_FROM_MAIN]
                              PATH <html_path>
                              [SECTION_FILE_STYLE <sectionfilestyle>]
                              [LATEX_REGEX_REPLACE [<match-regex> <replace-expr>]...]
                              [HTML_REGEX_REPLACE [<match-regex> <replace-expr>]...]])
```

This function adds the external project `<name>`.
`<name>` processes, as specified below, all given `<source>`,
which are [stem][]s existing in `${CMAKE_CURRENT_SOURCE_DIR}`.
If `<pdf_path>` or `<html_path>` is specified,
from the processed sources, `<name>` respectively
- outputs C++ Working Draft-like [PDF][CPP-WD-LIKE-PDF] or [HTML][CPP-WD-LIKE-HTML] documentations, and
- adds step target `<name>-pdf` or `<name>-html` that drives the output.

The [C++ Standard Draft Sources][] has scripts
to check the input sources and output of building the PDF.
The `<condition>` defaults to `FALSE` and determines, via `if`, whether the scripts are used.

`EXCLUDE_FROM_ALL` specifies the argument of the `EXCLUDE_FROM_ALL` keyword to `<name>`.
`EXCLUDE_FROM_MAIN` specifies the argument of the `EXCLUDE_FROM_MAIN` keyword to the respective step target.

When specifying the `HTML` keyword,
the variable `JEGP_CXXDRAFT_HTMLGEN_GIT_REPOSITORY`
should be set to a local checkout of
<https://github.com/JohelEGP/cxxdraft-htmlgen/tree/standardese_sources_base>
(or <https://github.com/Eelis/cxxdraft-htmlgen> if modules aren't indexed).
The `stack` commands will be used in that checkout.
The `<sectionfilestyle>` is forwarded to `cxxdraft-htmlgen`.

##### Process

`<name>` configures [C++ Standard Draft Sources][] via the patched fork specified by
[the `JEGP_STANDARDESE_SOURCES_GIT_REPOSITORY` and `JEGP_STANDARDESE_SOURCES_GIT_TAG` variables](../README.md#standardese_sources_vars).
<br/>_Recommended practice_: For faster processing, set the variable to a local shallow clone.
```bash
# 1a. Clone <https://github.com/JohelEGP/draft/>.
git clone "https://github.com/JohelEGP/draft/" --branch=standardese_sources_base
# 1b. Alternatively, shallow clone directly if this is a one-shot (e.g., in CI).
git clone "https://github.com/JohelEGP/draft/" --branch=standardese_sources_base standardese_sources_base --depth=1
# 1c. Alternatively, in an existing repository of `gh:cplusplus/draft`,
#    add the remote and checkout the branch.
git remote add JohelEGP "https://github.com/JohelEGP/draft/"
git checkout -b standardese_sources_base JohelEGP/standardese_sources_base
# 2. Do a shallow clone (after 1a and 1c).
git clone file://`pwd`/draft/ --branch=standardese_sources_base standardese_sources_base --depth=1
# 3. Configure with:
cmake ... -DJEGP_STANDARDESE_SOURCES_GIT_REPOSITORY=file://`pwd`/standardese_sources_base
```

All given `<source>` are copied to alongside a copy of the sources of the patched fork's clone.
The copies of `macros.tex` and `back.tex`
have the respective contents of `macros_extensions.tex` and `bibliography.tex` inserted
if they are specified via the `EXTENSIONS` keyword.
The copies of `config.tex`, `preface.tex`, `std.tex`, and `check-source.sh`
have these variables substituted
as if by [`configure_file`][]'s `@ONLY` mode.

| Variable              | Meaning                                                             |
| --------------------- | ------------------------------------------------------------------- |
| pdf_title             | Title of the PDF.                                                   |
| page_license          | License or copyright of the documentations.                         |
| first_library_chapter | Stable label of the first library chapter.                          |
| last_library_chapter  | Stable label of the last library chapter.                           |

| Variable                 | Default string value                    |
|:-------------------------|:----------------------------------------|
| pdf_subject              | `${PROJECT_NAME}`                       |
| pdf_creator              | The `user.name` of Git's configuration. |
| document_number_header   | `Ref`                                   |
| document_number          | `\unspec`                               |
| previous_document_number | `\unspec`                               |
| release_date             | `\today`                                |
| reply_to_header          | `Reply at`                              |
| reply_to                 | `\url{${PROJECT_HOMEPAGE_URL}}`         |
| cover_title              | `${pdf_title}`                          |
| cover_footer             | Same as the C++ WD.                     |
| check_comment_alignment  | `false`                                 |

The following variables apply to the HTML output.

| HTML variables    | Default string value |
|:------------------|:---------------------|
| cover_footer_html | Same as the C++ WD.  |

Additionally, `std.tex` is configured to input
all library and appendix `<source>` in the input order.
`check-source.sh` is similarly configured for all library `<source>`.

After copying and configuring, if specified,
the check script for the sources is run.

`<name>-pdf` builds the PDF.
If successfully built and checked (if required),
it is copied to `<pdf_path>` relative to `${CMAKE_CURRENT_BINARY_DIR}`.

`<name>-html` builds the HTML.
If successfully built,
it is copied to `<html_path>` relative to `${CMAKE_CURRENT_BINARY_DIR}`.

To build the HTML, the sources are copied back to `${CMAKE_CURRENT_SOURCE_DIR}/source`.
<br/>_Recommended practice_: Add `${CMAKE_CURRENT_SOURCE_DIR}/source` to `.gitignore`.

`LATEX_REGEX_REPLACE` and `HTML_REGEX_REPLACE` specify
[`string(REGEX REPLACE)`][] operations
respectively applied to the LaTeX sources and HTML sources.
<br/>_Recommended practice_:
- Use when `cxxdraft-htmlgen` doesn't know how to transform a LaTeX construct to HTML.
- Be aware of how [CMake lists][] work.
  Here are some tips for some use cases:
  * To match `;`, use `.` if that suffices.
  * To replace with `;`, use the [html entity][] `&#x003B` instead.
  * To replace with `[` and `]` across arguments, respectively use `&#x005B` and `&#x005D` instead.

[ _Example_:
```CMake
jegp_add_standardese_sources(
  name
  LIBRARIES "..."
  HTML PATH "..."
       # Transform the LaTeX command `\href` to HTML.
       LATEX_REGEX_REPLACE [[\\href{([^}]+)}{([^}]+)};HREF(\1)(\2)]]
       HTML_REGEX_REPLACE [[HREF\(([^)]+)\)\(([^)]+)\);<a href="\1">\2</a>]])
```
-- _end example_ ]

##### C++ modules support

The linked forks include C++ modules support:
- Commands parallel to the header commands.
  + Indexing commands and accompanying `\printindex` in `back.tex`.
    > ```LaTeX
    > % index for library modules
    > \newcommand{\libmodule}[1]{\indexmdl{#1}\tcode{#1}}
    > \newcommand{\indexmodule}[1]{\index[moduleindex]{\idxmdl{#1}|idxbfpage}}
    > \newcommand{\libmoduledef}[1]{\indexmodule{#1}\tcode{#1}}
    > \newcommand{\libmodulerefx}[2]{\libmodule{#1}\iref{#2}}
    > ```
  + `modularlibsumtab`, like `libsumtab`.

[stem]: https://cmake.org/cmake/help/latest/command/cmake_path.html#stem-def
[CPP-WD-LIKE-PDF]: https://wg21.link/std
[CPP-WD-LIKE-HTML]: https://wg21.link/draft
[C++ Standard Draft Sources]: https://github.com/cplusplus/draft
[`configure_file`]: https://cmake.org/cmake/help/latest/command/configure_file.html
[`string(REGEX REPLACE)`]: https://cmake.org/cmake/help/latest/command/string.html#regex-replace
[CMake lists]: https://cmake.org/cmake/help/latest/manual/cmake-language.7.html#lists
[html entity]: https://www.w3schools.com/html/html_entities.asp
