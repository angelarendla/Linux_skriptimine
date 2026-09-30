#!/bin/bash

kontrolli_faili() {
    if [ -f "$1" ]; then
        return 0
    else
        return 1
    fi
}

kontrolli_faili "/etc/passwd"
echo "Olekukood: $?"
