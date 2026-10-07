#!/bin/bash

> player_numbers.txt
> lottery_numbers.txt

read -p "Sisesta nimi: " name
if [ -z "$name" ]; then name="Unknown"; fi

echo "Sisesta 5 numbrit (1-50):"
count=0
while [ $count -lt 5 ]; do
    read -p "Number $((count + 1)): " num
    if ! [[ "$num" =~ ^[0-9]+$ ]] || [ $num -lt 1 ] || [ $num -gt 50 ]; then
        echo "Viga! Sisesta arv 1-50."
    elif grep -q "^${num}$" player_numbers.txt; then
        echo "Seda juba valisid!"
    else
        echo "$num" >> player_numbers.txt
        count=$((count + 1))
    fi
done

while [ $(wc -l < lottery_numbers.txt) -lt 5 ]; do
    r=$(( (RANDOM % 50) + 1 ))
    grep -q "^${r}$" lottery_numbers.txt || echo "$r" >> lottery_numbers.txt
done

matches=0
while read -r p; do
    echo "Kontrollin $p..."
    if grep -q "^${p}$" lottery_numbers.txt; then
        echo "TABAMUS!"
        matches=$((matches + 1))
    else
        echo "Ei tabanud."
    fi
done < player_numbers.txt

if [ $matches -eq 5 ]; then res="JACKPOT!"; elif [ $matches -eq 4 ]; then res="Väga hea tulemus!"; elif [ $matches -eq 3 ]; then res="Hea tulemus."; elif [ $matches -eq 2 ]; then res="Kaks tabamust."; elif [ $matches -eq 1 ]; then res="Üks tabamus."; else res="Seekord tabamusi ei olnud."; fi

echo "Mängija: $name | Tabamusi: $matches/5 | $res"

{ echo "========================================"; echo "Date: $(date)"; echo "Player: $name"; echo "Player numbers:"; cat player_numbers.txt; echo "Lottery numbers:"; cat lottery_numbers.txt; echo "Matches: $matches"; echo "Result: $res"; } >> results.txt
