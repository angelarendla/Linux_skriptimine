#!/bin/bash

kasutaja_info() {
    echo "Nimi: $1"
    echo "Vanus: $2"
}

liida() {
    echo "$(( $1 + $2 ))"
}

kasutaja_info "Mari" 18
echo -n "Liitmise tulemus: "
liida 10 5
kontrolli üks kaks kolm
