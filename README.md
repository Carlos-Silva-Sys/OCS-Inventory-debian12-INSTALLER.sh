```
OCS INVENTORY NG - DEBIAN 12
Autor: Carlos Silva
Sistema: Debian 12

================================================================================

DESCRIPCIÓN
================================================================================

Instalación automática de OCS Inventory NG (servidor) en Debian 12.
Incluye LAMP (Apache, MariaDB, PHP) y configuración no interactiva.

================================================================================

SCRIPT
================================================================================

instalar_ocs_completo.sh

================================================================================

CÓMO EJECUTAR
================================================================================

chmod +x instalar_ocs_completo.sh
sudo ./instalar_ocs_completo.sh

================================================================================

CAMBIAR ANTES DE EJECUTAR
================================================================================

Editar el script y cambiar:
- ROOT_PASSWORD = contraseña para root de MariaDB
- OCS_DB_PASS = contraseña para el usuario de OCS

================================================================================

DESPUÉS DE LA INSTALACIÓN
================================================================================

1. Acceder a: http://IP_DEL_SERVIDOR/ocsreports

2. Credenciales por defecto: admin / admin

3. Configurar conexión a la base de datos:
   - MySQL login: ocsuser
   - MySQL password: (la que pusiste en OCS_DB_PASS)
   - Name of Database: ocsweb

================================================================================

SOLUCIÓN DE PROBLEMAS
================================================================================

Si no carga, verificar servicios:
systemctl status apache2 mariadb

Reiniciar servicios:
systemctl restart apache2 mariadb

================================================================================

CONTACTO
================================================================================
GitHub: CarlosSilva32d-blip
Correo: carlossilva32d@gmail.com

LICENCIA: Uso libre para fines educativos y profesionales.
```
