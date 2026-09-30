#!/bin/bash

kontrolli_faili() {
    if [ ! -f "$1" ]; then
        echo "Faili ei leitud!"
        return 1
    fi

    echo "Fail on olemas."
}

kontrolli_faili "/etc/passwd"
