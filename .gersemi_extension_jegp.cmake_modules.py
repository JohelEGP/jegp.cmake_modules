command_definitions = {
    "jegp_add_standardese_sources": {
        "front_positional_arguments": ["name"],
        "options": ["EXCLUDE_FROM_ALL"],
        "one_value_keywords": ["CHECKED"],
        "multi_value_keywords": ["LIBRARIES", "APPENDICES", "EXTENSIONS", "PDF", "HTML"],
        "keyword_preprocessors": {
            "LIBRARIES": "unique",
            "APPENDICES": "unique",
            "EXTENSIONS": "unique",
        },
        "sections": {
            "PDF": {
                "options": ["EXCLUDE_FROM_MAIN"],
                "one_value_keywords": ["PATH"],
            },
            "HTML": {
                "options": ["EXCLUDE_FROM_MAIN"],
                "one_value_keywords": ["PATH", "SECTION_FILE_STYLE"],
                "multi_value_keywords": ["LATEX_REGEX_REPLACE", "HTML_REGEX_REPLACE"],
                "keyword_formatters": {
                    "LATEX_REGEX_REPLACE": "pairs",
                    "HTML_REGEX_REPLACE": "pairs",
                },
            },
        },
    },
    "jegp_add_test": {
        "front_positional_arguments": ["name"],
        "one_value_keywords": ["TYPE"],
        "multi_value_keywords": ["SOURCES", "COMPILE_OPTIONS", "LINK_LIBRARIES"],
    },
    "jegp_add_build_error": {
        "front_positional_arguments": ["name"],
        "one_value_keywords": ["AS", "TYPE", "SOURCE"],
        "multi_value_keywords": ["COMPILE_OPTIONS", "LINK_LIBRARIES"],
    },
    "jegp_cpp2_target": {
        "front_positional_arguments": ["target"],
    },
    "jegp_cpp2_target_sources": {
    },
}
