#!/bin/bash

DATA_FILE="names.csv"

initialize_file() {
    if [[ ! -f "$DATA_FILE" ]]; then
        echo "first_name,last_name" > "$DATA_FILE"
    fi
}

display_menu() {
    echo ""
    echo "Name Manager"
    echo "1. Add Name"
    echo "2. View All Names"
    echo "3. Search for a Name"
    echo "4. Delete a Name"
    echo "5. Exit"
}

add_name() {
    read -p "First name: " first
    read -p "Last name: " last

    # Check for empty input
    if [[ -z "$first" || -z "$last" ]]; then
        echo "Error: First and last names cannot be empty."
        return
    fi

    # Check for duplicates
    if tail -n +2 "$DATA_FILE" | grep -i -q "^$first,$last$"; then
        echo "Error: Name '$first $last' already exists."
        return
    fi

    echo "$first,$last" >> "$DATA_FILE"
    echo "Name added."
}

view_names() {
    if [[ $(wc -l < "$DATA_FILE") -le 1 ]]; then
        echo "No names found."
        return
    fi

    echo "All names:"
    tail -n +2 "$DATA_FILE" | while IFS=, read -r first last; do
        echo "- $first $last"
    done
}

search_name() {
    read -p "Search query: " query
    matches=$(tail -n +2 "$DATA_FILE" | grep -i "$query")

    if [[ -n "$matches" ]]; then
        echo "Matches found:"
        echo "$matches" | while IFS=, read -r first last; do
            echo "- $first $last"
        done
    else
        echo "No matches found."
    fi
}

delete_name() {
    read -p "Name to delete: " query
    before=$(($(wc -l < "$DATA_FILE") - 1))
    
    {
        head -n 1 "$DATA_FILE"
        tail -n +2 "$DATA_FILE" | grep -iv "$query"
    } > temp.csv && mv temp.csv "$DATA_FILE"

    after=$(($(wc -l < "$DATA_FILE") - 1))
    echo "$((before - after)) name(s) deleted."
}

main() {
    initialize_file
    while true; do
        display_menu
        read -p "Enter choice: " choice
        case $choice in
            1) add_name ;;
            2) view_names ;;
            3) search_name ;;
            4) delete_name ;;
            5) echo "Goodbye!"; break ;;
            *) echo "Invalid choice. Try again." ;;
        esac
    done
}

main