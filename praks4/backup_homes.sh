#!/bin/bash

BCP_DIR="/home_bcp"
DATE=$(date +%d.%m.%Y)

# Kontrollime root õigusi
if [ "$(id -u)" -ne 0 ]; then
    echo "Viga: Skripti peab käivitama root õigustes!" >&2
    exit 1
fi

# Loome sihtkataloogi, kui seda pole
mkdir -p "$BCP_DIR"

# Varundame iga kasutaja kodukataloogi /home kaustast
for user_dir in /home/*; do
    if [ -d "$user_dir" ]; then
        username=$(basename "$user_dir")
        archive_name="${username}.${DATE}.tar.gz"
        
        echo "Varundan kasutajat: $username..."
        tar -czf "${BCP_DIR}/${archive_name}" -C /home "$username"
        
        if [ $? -eq 0 ]; then
            echo "OK: ${BCP_DIR}/${archive_name}"
        else
            echo "VIGA: Kasutaja $username varundamine ebaõnnestus!" >&2
        fi
    fi
done
