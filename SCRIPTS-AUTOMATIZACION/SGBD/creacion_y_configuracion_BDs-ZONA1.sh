#!/bin/bash

# Variables desde Terraform
ROLE="${role}"
PRIMARY_IP="${primary_ip}"
SECONDARY_IP="${secondary_ip}"

# Credenciales hardcodeadas (escapadas)
DB_USER="admin"
DB_PASSWORD="Admin123"
DB_NAME="prosody"
REPL_USER="replica_user"
REPL_PASSWORD="Admin123"

# Instalar MySQL Server
sudo apt-get update
sudo apt-get install -y mysql-server

# Configurar MySQL para escuchar en todas las interfaces
sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql

# Configurar el nodo PRIMARIO
if [ "$ROLE" == "primary" ]; then
    mysql -u root <<-EOF
        CREATE DATABASE IF NOT EXISTS $${DB_NAME};
        CREATE USER '$${DB_USER}'@'%' IDENTIFIED BY '$${DB_PASSWORD}';
        GRANT ALL PRIVILEGES ON $${DB_NAME}.* TO '$${DB_USER}'@'%';
        CREATE USER '$${REPL_USER}'@'$${SECONDARY_IP}' IDENTIFIED BY '$${REPL_PASSWORD}';
        GRANT REPLICATION SLAVE ON *.* TO '$${REPL_USER}'@'$${SECONDARY_IP}';
        FLUSH PRIVILEGES;
        FLUSH TABLES WITH READ LOCK;
        SHOW MASTER STATUS;
        UNLOCK TABLES;
EOF

    MASTER_STATUS=$(mysql -u root -e "SHOW MASTER STATUS;" -s)
    echo "$MASTER_STATUS" | awk '{print $1, $2}' > /tmp/master_status.txt
    sudo chmod 644 /tmp/master_status.txt
fi

# Configurar el nodo SECUNDARIO
if [ "$ROLE" == "secondary" ]; then
    sleep 60
    scp -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@$${PRIMARY_IP}:/tmp/master_status.txt /tmp/
    BINLOG_FILE=$(awk '{print $1}' /tmp/master_status.txt)
    BINLOG_POS=$(awk '{print $2}' /tmp/master_status.txt)

    mysql -u root <<-EOF
        STOP SLAVE;
        CHANGE MASTER TO
        MASTER_HOST='$${PRIMARY_IP}',
        MASTER_USER='$${REPL_USER}',
        MASTER_PASSWORD='$${REPL_PASSWORD}',
        MASTER_LOG_FILE='$${BINLOG_FILE}',
        MASTER_LOG_POS=$${BINLOG_POS};
        START SLAVE;
EOF

    echo "Estado de la replicación:"
    mysql -u root -e "SHOW SLAVE STATUS\G"
fi

# Configurar seguridad básica
sudo mysql_secure_installation <<EOF
y
$${DB_PASSWORD}
$${DB_PASSWORD}
y
y
y
y
EOF

sudo systemctl restart mysql