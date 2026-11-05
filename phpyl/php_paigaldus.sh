#!/bin/bash
# php_paigaldus.sh - PHP ja vajalike lisapakettide paigaldamise skript

# Kontrollime, kas PHP on juba paigaldatud
PHP=$(dpkg-query -W -f='${Status}' php 2>/dev/null | grep -c "ok installed")

if [ $PHP -eq 0 ]; then
    echo "PHP ei ole paigaldatud. Alustatakse paigaldamist..."
    
    # Uuendame pakettide nimekirja
    apt update
    
    # Paigaldame PHP ja vajalikud abipakettid (libapache2-mod-php, php-mysql)
    apt install -y php libapache2-mod-php php-mysql
    
    # Kui vajad spetsiifiliselt versiooni 7.0 (vanemad Debian/Ubuntu versioonid), 
    # saab kasutada järgmist rida:
    # apt install -y php7.0 libapache2-mod-php7.0 php7.0-mysql

    # Kontrollime uuesti paigalduse tulemust
    PHP_CHECK=$(dpkg-query -W -f='${Status}' php 2>/dev/null | grep -c "ok installed")
    if [ $PHP_CHECK -eq 1 ]; then
        echo "PHP ja vajalikud lisapaketid on edukalt paigaldatud!"
    else
        echo "PHP paigaldamisel tekkis tõrge."
    fi
else
    echo "PHP on juba masinasse paigaldatud."
fi
