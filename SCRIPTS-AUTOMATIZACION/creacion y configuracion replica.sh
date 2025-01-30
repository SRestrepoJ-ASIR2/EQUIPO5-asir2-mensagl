#!/bin/bash

# Variables
DB_USER="admin"
DB_PASSWORD="password"
DB_NAME="mensajeria"
REPL_USER="replica_user"
REPL_PASSWORD="replica_password"
PRIMARY_DB_IP="10.0.3.10"  # IP de la base de datos principal
SECONDARY_DB_IP="10.0.3.20"  # IP de la base de datos secundaria

# Instalar MySQL Server
sudo apt-get update
sudo apt-get install -y mysql-server

# Configurar MySQL para escuchar en todas las interfaces
sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

# Reiniciar MySQL para aplicar los cambios
sudo systemctl restart mysql

# Configurar la base de datos principal
if [ "$(hostname)" == "sgbd-principal_zona1" ]; then
    # Crear la base de datos y el usuario
    mysql -u root -e "CREATE DATABASE ${DB_NAME};"
    mysql -u root -e "CREATE USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';"
    mysql -u root -e "FLUSH PRIVILEGES;"

    # Crear usuario de replicación
    mysql -u root -e "CREATE USER '${REPL_USER}'@'${SECONDARY_DB_IP}' IDENTIFIED BY '${REPL_PASSWORD}';"
    mysql -u root -e "GRANT REPLICATION SLAVE ON *.* TO '${REPL_USER}'@'${SECONDARY_DB_IP}';"
    mysql -u root -e "FLUSH PRIVILEGES;"

    # Bloquear las tablas para obtener la posición del binlog
    mysql -u root -e "FLUSH TABLES WITH READ LOCK;"
    BINLOG_INFO=$(mysql -u root -e "SHOW MASTER STATUS;" | awk 'NR==2{print $1, $2}')
    BINLOG_FILE=$(echo $BINLOG_INFO | awk '{print $1}')
    BINLOG_POS=$(echo $BINLOG_INFO | awk '{print $2}')
    mysql -u root -e "UNLOCK TABLES;"

    echo "Configuración de la base de datos principal completada."
    echo "Binlog File: ${BINLOG_FILE}"
    echo "Binlog Position: ${BINLOG_POS}"
fi

# Configurar la base de datos secundaria (réplica)
if [ "$(hostname)" == "sgbd-secundario_zona1" ]; then
    # Detener la replicación si ya está configurada
    mysql -u root -e "STOP SLAVE;"

    # Configurar la replicación
    mysql -u root -e "CHANGE MASTER TO MASTER_HOST='${PRIMARY_DB_IP}', MASTER_USER='${REPL_USER}', MASTER_PASSWORD='${REPL_PASSWORD}', MASTER_LOG_FILE='${BINLOG_FILE}', MASTER_LOG_POS=${BINLOG_POS};"
    mysql -u root -e "START SLAVE;"

    # Verificar el estado de la replicación
    SLAVE_STATUS=$(mysql -u root -e "SHOW SLAVE STATUS\G")
    echo "$SLAVE_STATUS"

    echo "Configuración de la base de datos secundaria (réplica) completada."
fi