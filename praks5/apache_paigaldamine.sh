# apache paigaldusskript
#
# kontrollime, mitu korda apache2 korral ok installed
# sõnad on leitud ja vastus salvestame
# muutuja sisse:
APACHE2=$(dpkg-query -W -f='${Status}' apache2 2>/dev/null | grep -c 'ok installed')
# kui APACHE2 muutuja väärtus võrdub 0-ga
if [ $APACHE2 -eq 0 ]; then
    # siis ok installed ei ole leitud
    # ja väljastame vastav teade ning
    # paigaldame teenus
    echo "Paigaldame apache2"
    apt install apache2
    echo "Apache on paigaldatud"
# kui APACHE2 muutuja väärtus võrdub 1-ga
elif [ $APACHE2 -eq 1 ]; then
    # siis ok installed on leitud 1 kord
    # ja teenus on juba paigaldatud
    echo "apache2 on juba paigaldatud"
    # stardime selle ja näitame staatust
    service apache2 start
    service apache2 status
# lõpetame tingimuslause
fi
# skripti lõpp
