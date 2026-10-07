#!/bin/bash

# Abifailide laadimine
DIR="$(dirname "$0")"
source "$DIR/files.sh"
source "$DIR/input.sh"
source "$DIR/lottery_functions.sh"
source "$DIR/result.sh"

# Programmi töövoog
echo "=== LOTO MÄNG ==="
clear_files
read_player
read_player_numbers
show_player_numbers
generate_lottery_numbers
show_lottery_numbers
check_matches
show_result "$name" "$matches"
save_result "$name" "$matches"
