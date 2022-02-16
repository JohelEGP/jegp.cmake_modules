file(READ "${SOURCE}" value)
file(WRITE "${CONFIGS_FILE}" "set(${VARIABLE} [[${value}]])")
