
#!/bin/bash

# Apache2 paigaldamise ja staatuse kontrollimise skript

TEENUS="apache2"

# Kontrollime dpkg-query abil, kas teenus on paigaldatud
APACHE=$(dpkg-query -W -f='${Status}' $TEENUS 2>/dev/null | grep -c "ok installed")

if [ $APACHE -eq 0 ]; then
    echo "Teenust $TEENUS ei leitud. Alustan paigaldamist..."
    
    # Uuendame paketinimekirja ja paigaldame apache2
    apt update -y
    apt install $TEENUS -y
    
    echo "Teenus $TEENUS on edukalt paigaldatud!"
    systemctl status $TEENUS --no-pager
else
    echo "Teenus $TEENUS on juba süsteemi paigaldatud."
    systemctl status $TEENUS --no-pager
fi
