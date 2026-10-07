#!/bin/bash

generate_lottery_numbers() {
    local r
    while [ $(wc -l < lottery_numbers.txt) -lt 5 ]; do
        r=$((RANDOM % 50 + 1))
        grep -qx "$r" lottery_numbers.txt || echo "$r" >> lottery_numbers.txt
    done
    return 0
}

show_lottery_numbers() {
    echo -e "\nVõidunumbrid:"
    cat lottery_numbers.txt
    return 0
}

check_matches() {
    local count=0
    local p
    echo -e "\nKontrollin mänge:"
    for p in $(cat player_numbers.txt); do
        if grep -qx "$p" lottery_numbers.txt; then
            echo "$p: TABAMUS!"
            count=$((count + 1))
        else
            echo "$p: Ei"
        fi
    done
    matches=$count
    return 0
}
