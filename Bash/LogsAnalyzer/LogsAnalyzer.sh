#!/bin/bash

# Ścieżka do pliku logów (możesz zmienić na /var/log/syslog lub inny plik)
LOG_FILE="/var/log/syslog"
OUTPUT_FILE="analyzed_logs.txt"

# Definicja wzorców logów
declare -A LOG_PATTERNS=(
    ["ERROR"]="error"
    ["WARNING"]="warning"
    ["INFO"]="info"
    ["CRITICAL"]="critical"
    ["NETWORK"]="timeout|connection refused|dns failure"
)

# Funkcja analizująca linie logów
analyze_log_line() {
    local line="$1"
    local categories=()
    for category in "${!LOG_PATTERNS[@]}"; do
        if [[ $line =~ ${LOG_PATTERNS[$category]} ]]; then
            categories+=("$category")
        fi
    done
    echo "${categories[@]}"
}

# Monitorowanie logów w czasie rzeczywistym
echo "Monitoring log file: $LOG_FILE"
if [[ ! -f $LOG_FILE ]]; then
    echo "Error: Log file $LOG_FILE does not exist."
    exit 1
fi

# Tworzenie pliku wyjściowego
> "$OUTPUT_FILE"

# Śledzenie zmian w pliku logów
tail -F "$LOG_FILE" | while read -r line; do
    categories=$(analyze_log_line "$line")
    if [[ -n $categories ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') $line -> $categories" >> "$OUTPUT_FILE"
    fi
done

