#!/bin/bash

hello() {
    echo "Tere tulemast!"
}

hello
hello
hello

echo "--- Tsüklis kutsutud: ---"

hello_tsukkel() {
    echo "Tere!"
}

for i in {1..5}
do
    hello_tsukkel
done
