#!/bin/bash

kasutaja_info() {
    local nimi="$1"
    local vanus="$2"

    echo "Nimi: $nimi"
    echo "Vanus: $vanus"
}

kasutaja_info "Mari" 18
