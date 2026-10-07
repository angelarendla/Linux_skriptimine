#!/bin/bash

read_player() {
    read -p "Sisesta nimi: " name
    name="${name:-Unknown}"
    return 0
}

read_player_numbers() {
    local num
    echo "Sisesta 5 numbrit (1-50):"
    while [ $(wc -l < player_numbers.txt) -lt 5 ]; do
        read -p "> " num
        if [[ "$num" =~ ^[1-9]$|^[1-4][0-9]$|^50$ ]] && ! grep -qx "$num" player_numbers.txt; then
            echo "$num" >> player_numbers.txt
        else
            echo "Viga! Sisesta unikaalne arv 1–50."
        fi
    done
    return 0
}

show_player_numbers() {
    echo -e "\nSinu numbrid:"
    cat player_numbers.txt
    return 0
}
