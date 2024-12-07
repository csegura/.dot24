#!/bin/bash

# Directory containing the scripts
scripts_dir="./scripts"

# Function to extract documentation from a script
get_script_doc() {
    local script="$1"
    # Extract the first line starting with #DOC:
    grep '^#DOC:' "$script" | sed 's/^#DOC: //'
}

# Function to list all scripts with their descriptions
list_scripts() {
    echo "Available installation recipes:"
    for script in "$scripts_dir"/*.sh; do
        [[ -f "$script" ]] || continue  # Skip if no scripts are found
        doc=$(get_script_doc "$script")
        echo "  $(basename "$script") - ${doc:-No documentation available}"
    done
    echo
}

# Function to display the help message
display_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  --help        Show this help message and list all installation recipes."
    echo
    list_scripts
}

# Function to display a menu of scripts
display_menu() {
    echo "Select an installation recipe to run:"
    local i=1
    for script in "$scripts_dir"/*.sh; do
        [[ -f "$script" ]] || continue  # Skip if no scripts are found
        doc=$(get_script_doc "$script")
        echo "$i. $(basename "$script") - ${doc:-No documentation available}"
        scripts[i]="$script"
        i=$((i + 1))
    done
    echo "0. Exit"
}

# Parse command-line arguments
if [[ "$1" == "--help" ]]; then
    display_help
    exit 0
fi

# Main script logic
while true; do
    # Display the menu
    display_menu

    # Read user input
    read -p "Enter your choice: " choice

    # Handle menu options
    if [[ "$choice" -eq 0 ]]; then
        echo "Exiting."
        exit 0
    elif [[ -n "${scripts[$choice]}" ]]; then
        selected_script="${scripts[$choice]}"
        echo "Running: $(basename "$selected_script")"
        bash "$selected_script" || echo "Error: $(basename "$selected_script") failed."
    else
        echo "Invalid choice, please try again."
    fi
done
