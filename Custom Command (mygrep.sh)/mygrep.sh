#!/bin/bash

line_numbers=0
invert_match=0

# Process options
while [[ $# -gt 0 && "$1" == -* ]]; do
    option="$1"
    shift
    if [[ "$option" == "--help" ]]; then
        echo "Usage: $0 [OPTIONS] PATTERN FILE"
        echo "Options:"
        echo "  -n         Show line numbers"
        echo "  -v         Invert match"
        echo "  --help     Display this help message"
        exit 0
    fi
    for (( i=1; i<${#option}; i++ )); do
        char="${option:$i:1}"
        case "$char" in
            n) line_numbers=1 ;;
            v) invert_match=1 ;;
            *) echo "Error: invalid option -$char" >&2; exit 1 ;;
        esac
    done
done

# Check remaining arguments
if [[ $# -ne 2 ]]; then
    echo "Error: incorrect number of arguments. Usage: $0 [options] pattern file" >&2
    exit 1
fi

pattern="$1"
filename="$2"

# Check if file exists
if [[ ! -f "$filename" ]]; then
    echo "Error: file '$filename' not found." >&2
    exit 1
fi

# Read the file line by line
line_number=0
while IFS= read -r line; do
    ((line_number++))
    # Case-insensitive substring check
    if [[ "${line,,}" == *"${pattern,,}"* ]]; then
        match=1
    else
        match=0
    fi

    # Invert match if -v is set
    if (( invert_match )); then
        match=$(( !match ))
    fi

    # Print line if matched
    if (( match )); then
        if (( line_numbers )); then
            printf "%d:%s\n" "$line_number" "$line"
        else
            printf "%s\n" "$line"
        fi
    fi
done < "$filename"