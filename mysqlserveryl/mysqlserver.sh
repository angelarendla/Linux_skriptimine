#!/bin/bash
# mysql-server.sh - Automaatne Oracle MySQL 8.0 paigaldamise skript (Debian 12)

# Kui mõni käsk ebaõnnestub, peatatakse skript kohe
set -e

# Seadistame mittesurvestava (automaatse) paigaldusrežiimi
export DEBIAN_FRONTEND=noninteractive

echo "===> Uuendame paketiandmebaasi ja paigaldame vajalikud tööriistad..."
apt update
apt install -y gnupg ca-certificates debconf-utils wget

echo "===> Seadistame automaatsed vastused mysql-apt-config ja mysql-server küsimustele..."
# 1. Valime repositooriumist MySQL 8.0, lülitame muud tööriistad välja ja kinnitame (Ok)
echo "mysql-apt-config mysql-apt-config/select-server select mysql-8.0" | debconf-set-selections
echo "mysql-apt-config mysql-apt-config/select-tools select Disabled"    | debconf-set-selections
echo "mysql-apt-config mysql-apt-config/select-product select Ok"        | debconf-set-selections

# 2. Määrame root-kasutaja parooliks "qwerty"
echo "mysql-community-server mysql-community-server/root-pass password qwerty"     | debconf-set-selections
echo "mysql-community-server mysql-community-server/re-root-pass password qwerty" | debconf-set-selections

# 3. Valime tugeva krüpteeringuga autentimise plugina (RECOMMENDED)
echo "mysql-community-server mysql-server/default-auth-override select Use Strong Password Encryption (RECOMMENDED)" | debconf-set-selections

echo "===> Laeme alla ja paigaldame ametliku MySQL APT konfiguratsioonipaketi..."
# Kasutame aktuaalset paketi versiooni 0.8.40-1
wget -O /tmp/mysql-apt-config_0.8.40-1_all.deb https://dev.mysql.com/get/mysql-apt-config_0.8.40-1_all.deb
dpkg -i /tmp/mysql-apt-config_0.8.40-1_all.deb

echo "===> Uuendame repositooriumite nimekirja ja paigaldame MySQL Serveri..."
apt update
apt install -y mysql-server

echo "===> Käivitame MySQL teenuse ja seadistame selle automaatselt käivituma..."
systemctl enable --now mysql

echo "===> Koostame root-kasutajale .my.cnf konfiguratsioonifaili..."
# Luuakse .my.cnf fail root-kasutaja kodukataloogi, et tagada mugav sisselogimine
cat >"$HOME/.my.cnf" <<'EOF'
[client]
host=localhost
user=root
password=qwerty
EOF

# Piirame õigusi nii, et ainult omanik saab faili lugeda
chmod 600 "$HOME/.my.cnf"

echo "--------------------------------------------------------"
echo "Valmis! Oracle MySQL 8.0 on edukalt paigaldatud."
echo "Root-parool: qwerty (Seadistatud .my.cnf kaudu automaatseks sisselogimiseks)"
echo "--------------------------------------------------------"
mysql --version || true
