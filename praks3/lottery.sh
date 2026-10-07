#!/bin/bash

show_header() { echo "=== LOTO MÄNG ==="; }
clear_files() { > player_numbers.txt; > lottery_numbers.txt; }
read_player() { read -p "Nimi: " name; name="${name:-Unknown}"; }

read_player_numbers() {
    echo "Sisesta 5 numbrit (1-50):"
    while [ $(wc -l < player_numbers.txt) -lt 5 ]; do
        read -p "> " n
        [[ "$n" =~ ^[1-9]$|^[1-4][0-9]$|^50$ ]] && ! grep -qx "$n" player_numbers.txt && echo "$n" >> player_numbers.txt || echo "Viga!"
    done
}

show_player_numbers() { echo "Sinu numbrid:"; cat player_numbers.txt; }

generate_lottery_numbers() {
    while [ $(wc -l < lottery_numbers.txt) -lt 5 ]; do
        r=$((RANDOM % 50 + 1))
        grep -qx "$r" lottery_numbers.txt || echo "$r" >> lottery_numbers.txt
    done
}

show_lottery_numbers() { echo -e "\nVõidunumbrid:"; cat lottery_numbers.txt; }

check_matches() {
    matches=0
    for p in $(cat player_numbers.txt); do
        grep -qx "$p" lottery_numbers.txt && { echo "$p: TABAMUS!"; matches=$((matches+1)); } || echo "$p: Ei"
    done
}

show_result() { echo -e "\nTabamusi: $matches/5"; }
save_result() { echo "$(date) | $name | Tabamusi: $matches" >> results.txt; }

# --- PÕHIOSA ---
show_header
clear_files
read_player
read_player_numbers
show_player_numbers
generate_lottery_numbers
show_lottery_numbers
check_matches
show_result
save_result
