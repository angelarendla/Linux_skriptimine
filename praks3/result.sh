#!/bin/bash

show_result() {
    local player_name="$1"
    local match_count="$2"
    echo -e "\nMängija: $player_name | Tabamusi: $match_count/5"
    return 0
}

save_result() {
    local player_name="$1"
    local match_count="$2"
    {
        echo "=== $(date) ==="
        echo "Player: $player_name | Matches: $match_count/5"
        echo "Player numbers:"; cat player_numbers.txt
        echo "Lottery numbers:"; cat lottery_numbers.txt
        echo "----------------------------------------"
    } >> results.txt
    return 0
}
