#!/bin/bash
# lamp-install.sh - Automaatne LAMP (Apache2, PHP 8.x, Oracle MySQL 8.0) paigaldusskript
# Nõuab root-õigusi.

set -e
export DEBIAN_FRONTEND=noninteractive

# Konfigureeritavad muutujad index.html jaoks
STUDENT_NAME="Mari Maasikas"
STUDENT_GROUP="ITS25"
MYSQL_ROOT_PASS="qwerty"

echo "=========================================="
echo "      ALUSTATAKSE LAMP PAIGALDAMIST       "
echo "=========================================="

# ==========================================
# 1. VAJALIKUD ABIPAKETID
# ==========================================
echo -e "\n[1/5] Kontrollitakse ja paigaldatakse abipakettid..."

NEEDED_PKGS=("wget" "ca-certificates" "gnupg" "debconf-utils")
TO_INSTALL=()

for pkg in "${NEEDED_PKGS[@]}"; do
    if ! dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "ok installed"; then
        TO_INSTALL+=("$pkg")
    fi
done

if [ ${#TO_INSTALL[@]} -ne 0 ]; then
    echo "Paigaldatakse abipaketid: ${TO_INSTALL[*]}"
    apt update
    apt install -y "${TO_INSTALL[@]}"
else
    echo "Kõik vajalikud abipaketid on juba paigaldatud."
fi

# ==========================================
# 2. MYSQL SERVER 8.0 (Oracle MySQL)
# ==========================================
echo -e "\n[2/5] Kontrollitakse MySQL Server 8.0..."

if dpkg-query -W -f='${Status}' mysql-server 2>/dev/null | grep -q "ok installed"; then
    echo "MySQL Server 8.0 on juba paigaldatud."
else
    echo "MySQL Server 8.0 puudub. Alustatakse automaatset paigaldamist..."
    
    # 1. debconf valikute seadistamine enne APT paketi paigaldamist
    echo "mysql-apt-config mysql-apt-config/select-server select mysql-8.0" | debconf-set-selections
    echo "mysql-apt-config mysql-apt-config/select-tools select Disabled"    | debconf-set-selections
    echo "mysql-apt-config mysql-apt-config/select-product select Ok"        | debconf-set-selections

    # 2. MySQL root-parooli eelseadistamine
    echo "mysql-community-server mysql-community-server/root-pass password ${MYSQL_ROOT_PASS}"     | debconf-set-selections
    echo "mysql-community-server mysql-community-server/re-root-pass password ${MYSQL_ROOT_PASS}" | debconf-set-selections

    # 3. Autentimisplugina eelseadistamine
    echo "mysql-community-server mysql-server/default-auth-override select Use Strong Password Encryption (RECOMMENDED)" | debconf-set-selections

    # 4. Oracle MySQL APT repositooriumi konfiguratsioonipaketi allalaadimine ja paigaldus
    wget -O /tmp/mysql-apt-config_0.8.40-1_all.deb https://dev.mysql.com/get/mysql-apt-config_0.8.40-1_all.deb
    dpkg -i /tmp/mysql-apt-config_0.8.40-1_all.deb
    rm -f /tmp/mysql-apt-config_0.8.40-1_all.deb

    # 5. Uuendame paketiloendit ja paigaldame MySQL serveri
    apt update
    apt install -y mysql-server
    
    echo "MySQL Server 8.0 paigaldus on lõpetatud."
fi

# Tagame, et MySQL teenus töötab ja on lubatud autostardiga
systemctl enable --now mysql

# Kontrollime või loome /root/.my.cnf faili automaatseks sisselogimiseks
if [ ! -f /root/.my.cnf ]; then
    echo "Loome /root/.my.cnf faili..."
    cat > /root/.my.cnf <<EOF
[client]
host=localhost
user=root
password=${MYSQL_ROOT_PASS}
EOF
    chmod 600 /root/.my.cnf
    echo "/root/.my.cnf luud edukalt."
else
    echo "/root/.my.cnf on juba olemas."
fi

# ==========================================
# 3. APACHE2
# ==========================================
echo -e "\n[3/5] Kontrollitakse Apache2..."

if dpkg-query -W -f='${Status}' apache2 2>/dev/null | grep -q "ok installed"; then
    echo "Apache2 on juba paigaldatud."
else
    echo "Apache2 puudub. Alustatakse paigaldamist..."
    apt install -y apache2
    echo "Apache2 paigaldus on lõpetatud."
fi

# Tagame, et Apache2 teenus töötab ja käivitub automaatselt
systemctl enable --now apache2

# Vaikimisi index.html veebilehe ülekirjutamine
INSTALL_DATE=$(date "+%Y-%m-%d %H:%M:%S")
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="et">
<head>
    <meta charset="UTF-8">
    <title>LAMP Paigaldus</title>
</head>
<body>
    <h1>LAMP server töötab!</h1>
    <p><strong>Õpilane:</strong> ${STUDENT_NAME}</p>
    <p><strong>Grupp:</strong> ${STUDENT_GROUP}</p>
    <p><strong>Paigaldatud:</strong> ${INSTALL_DATE}</p>
</body>
</html>
EOF

# ==========================================
# 4. PHP 8.x
# ==========================================
echo -e "\n[4/5] Kontrollitakse PHP 8.x..."

if command -v php &>/dev/null && php -v | grep -q "PHP 8"; then
    PHP_VER=$(php -v | head -n 1 | awk '{print $2}')
    echo "PHP 8.x on juba paigaldatud (versioon ${PHP_VER})."
else
    echo "PHP 8.x puudub. Alustatakse paigaldamist..."
    apt install -y php8.2 php8.2-cli php8.2-common php8.2-mysql libapache2-mod-php8.2
    
    # Apache2 taaskäivitamine PHP mooduli laadimiseks
    systemctl restart apache2
    echo "PHP 8.x ja vajalikud moodulid on paigaldatud."
fi

# testfaili info.php loomine
cat > /var/www/html/info.php <<'EOF'
<?php phpinfo(); ?>
EOF

# ==========================================
# 5. KOKKUVÕTLIK LÕPURAPORT
# ==========================================
APACHE_VER=$(apache2 -v 2>/dev/null | head -n 1 | awk '{print $3}' || echo "Puudub")
APACHE_ACT=$(systemctl is-active apache2 2>/dev/null || echo "inactive")
APACHE_ENA=$(systemctl is-enabled apache2 2>/dev/null || echo "disabled")

PHP_FINAL_VER=$(php -v 2>/dev/null | head -n 1 | awk '{print $2}' || echo "Puudub")

MYSQL_VER=$(mysql --version 2>/dev/null | awk '{print $5}' | tr -d ',' || echo "Puudub")
MYSQL_ACT=$(systemctl is-active mysql 2>/dev/null || echo "inactive")
MYSQL_ENA=$(systemctl is-enabled mysql 2>/dev/null || echo "disabled")

MY_CNF_STATUS="puudub"
if [ -f /root/.my.cnf ]; then
    MY_CNF_STATUS="olemas"
fi

echo -e "\n========== LAMP REPORT =========="
echo ""
echo "Apache2:"
echo "Version: ${APACHE_VER}"
echo "Status: ${APACHE_ACT}"
echo "Autostart: ${APACHE_ENA}"
echo ""
echo "PHP:"
echo "Version: ${PHP_FINAL_VER}"
echo ""
echo "MySQL:"
echo "Version: ${MYSQL_VER}"
echo "Status: ${MYSQL_ACT}"
echo "Autostart: ${MYSQL_ENA}"
echo ""
echo "Apache default page:"
echo "/var/www/html/index.html"
echo ""
echo "PHP test page:"
echo "/var/www/html/info.php"
echo ""
echo "MySQL root configuration:"
echo "/root/.my.cnf - ${MY_CNF_STATUS}"
echo ""
echo "================================="
