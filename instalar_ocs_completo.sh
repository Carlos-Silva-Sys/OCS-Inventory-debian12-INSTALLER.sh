#!/bin/bash
# -----------------------------------------------------------
# SCRIPT DE INSTALACION COMPLETA NO INTERACTIVA DE OCS INVENTORY NG
# Configura dependencias (LAMP) y establece contraseñas estáticas.
# -----------------------------------------------------------

# Verificar si el script se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Por favor, ejecuta este script como root o con 'sudo'."
    exit 1
fi

echo "============== INICIO DE INSTALACION OCS INVENTORY NG (NO INTERACTIVO) =============="

# --- VARIABLES DE CONFIGURACION ---
# ⚠️ CAMBIAR ANTES DE EJECUTAR ⚠️
OCS_VERSION="2.12.1"
OCS_URL="https://github.com/OCSInventory-NG/OCSInventory-ocsweb/releases/download/${OCS_VERSION}/OCSNG_UNIX_SERVER-${OCS_VERSION}.tar.gz"
INSTALL_DIR="/var/www/html"
TMP_DIR="/tmp/ocs_install"

# CREDENCIALES - CAMBIAR ANTES DE EJECUTAR
ROOT_PASSWORD="TU_CONTRASEÑA_ROOT_MARIADB_AQUI"
OCS_DB_USER="ocsuser"
OCS_DB_PASS="TU_CONTRASEÑA_OCS_AQUI"
OCS_DB_NAME="ocsweb"
# ----------------------------------

# 1. INSTALACION DE DEPENDENCIAS (LAMP)
echo "--- PASO 1: INSTALANDO DEPENDENCIAS ---"
apt update
apt install -y apache2 mariadb-server \
    php php-mysql php-gd php-xml php-curl php-json php-mbstring libapache2-mod-php \
    perl libapache2-mod-perl2 make build-essential expect

# 2. CONFIGURACION INICIAL DE MARIADB (No Interactivo)
echo "--- PASO 2: CONFIGURACION NO INTERACTIVA DE MARIADB ---"

# Establecer la contraseña de root y asegurar la instalacion
mysql -e "UPDATE mysql.user SET Password=PASSWORD('$ROOT_PASSWORD') WHERE User='root';"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -e "DROP DATABASE test;"
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
mysql -e "FLUSH PRIVILEGES;"
echo "Contrasena de MariaDB root establecida"

# Crear la base de datos y el usuario para OCS
mysql -u root -p"$ROOT_PASSWORD" -e "CREATE DATABASE $OCS_DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p"$ROOT_PASSWORD" -e "CREATE USER '$OCS_DB_USER'@'localhost' IDENTIFIED BY '$OCS_DB_PASS';"
mysql -u root -p"$ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON $OCS_DB_NAME.* TO '$OCS_DB_USER'@'localhost' WITH GRANT OPTION;"
mysql -u root -p"$ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"
echo "Base de datos '$OCS_DB_NAME' y usuario '$OCS_DB_USER' creados."

# 3. CONFIGURACION Y SERVICIOS
echo "--- PASO 3: CONFIGURACION DE APACHE Y SERVICIOS ---"
a2enmod rewrite alias cgi
systemctl restart apache2
systemctl restart mariadb
systemctl enable apache2
systemctl enable mariadb

# 4. DESCARGA E INSTALACION DE OCS
echo "--- PASO 4: DESCARGANDO Y DESEMPAQUETANDO OCS ---"
mkdir -p $TMP_DIR
cd $TMP_DIR

wget $OCS_URL -O ocs_server.tar.gz

if [ $? -ne 0 ]; then
    echo "ERROR: Fallo al descargar OCS. URL: $OCS_URL"
    exit 1
fi

tar -xzf ocs_server.tar.gz
cd OCSNG_UNIX_SERVER-$OCS_VERSION

# 5. EJECUTAR SETUP.SH DE FORMA AUTOMATICA
echo "--- PASO 5: EJECUTANDO SETUP.SH ---"
expect -c '
    spawn ./setup.sh
    expect "Do you wish to continue (y/N)?" { send "y\r" }
    expect "Please enter the name of the user allowed to connect to MySQL server" { send "\r" }
    expect "Please enter the password of the user allowed to connect to MySQL server" { send "\r" }
    expect "Please enter the name of the database" { send "\r" }
    expect "Please enter the MySQL server address" { send "\r" }
    expect "Please enter the directory where the Communication server will be installed" { send "\r" }
    expect "Please enter the directory where the Administration server will be installed" { send "\r" }
    expect "Please enter the directory where the web interface will be installed" { send "\r" }
    expect "Where is the Apache configuration file located" { send "\r" }
    expect "Do you want me to configure Apache" { send "y\r" }
    expect "Do you want to use a virtual host (y/N)?" { send "n\r" }
    expect "Do you want to continue (y/N)?" { send "y\r" }
    expect eof
'

# 6. PERMISOS Y REINICIO
echo "--- PASO 6: CONFIGURANDO PERMISOS Y REINICIANDO ---"
chown -R www-data:www-data /var/www/html/ocsreports
systemctl restart apache2

echo "=========================================================="
echo "!!! INSTALACION DEL SERVIDOR COMPLETADA !!!"
echo "=========================================================="
echo ""
echo "1. Abre tu navegador: http://IP_DE_TU_VM/ocsreports"
echo ""
echo "2. Credenciales por defecto: admin / admin"
echo ""
echo "3. Primera vez, configura la conexion a la BD:"
echo "   - MySQL login: $OCS_DB_USER"
echo "   - MySQL password: $OCS_DB_PASS"
echo "   - Name of Database: $OCS_DB_NAME"
echo "=========================================================="
