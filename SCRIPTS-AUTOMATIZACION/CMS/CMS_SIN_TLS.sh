#!/bin/bash
# Instalación de LAMP y WordPress con WP-CLI
# Equipo 5

# Actualizar los paquetes
echo "Actualizando paquetes..."
sudo apt-get update

# Instalando Apache
echo "Instalando Apache..."
sudo apt-get install -y apache2

# Instalando MySQL
echo "Instalando MySQL..."
sudo apt-get install -y mysql-server

# Iniciar MySQL
echo "Iniciando MySQL..."
sudo systemctl start mysql

# Crear la base de datos y usuario en MySQL
echo "Creando la base de datos y el usuario MySQL..."
sudo mysql -e "CREATE DATABASE wordpressdb;"
sudo mysql -e "CREATE USER 'wordpressuser'@'localhost' IDENTIFIED BY 'password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON wordpressdb.* TO 'wordpressuser'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Instalando PHP y extensiones necesarias
echo "Instalando PHP y extensiones necesarias..."
sudo apt-get install -y php libapache2-mod-php php-mysql php-curl php-xml php-mbstring php-zip

# Reiniciar Apache para cargar PHP
echo "Reiniciando Apache..."
sudo systemctl restart apache2

# Descargar WordPress
echo "Descargando WordPress..."
wget https://wordpress.org/latest.tar.gz

# Extraer WordPress
echo "Extrayendo WordPress..."
tar -xvzf latest.tar.gz

# Mover WordPress a la raíz de Apache
echo "Moviendo WordPress a /var/www/html..."
sudo mv wordpress /var/www/html/

# Establecer los permisos correctos
echo "Estableciendo permisos..."
sudo chown -R www-data:www-data /var/www/html/wordpress

# Configurar WP-CLI
echo "Verificando WP-CLI..."
sudo apt-get install -y curl git unzip
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# Crear wp-config.php
echo "Creando archivo wp-config.php..."
sudo cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
sudo sed -i "s/database_name_here/wordpressdb/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/username_here/wordpressuser/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/password_here/password/" /var/www/html/wordpress/wp-config.php

# Configurar VirtualHost de Apache para WordPress
echo "Configurando VirtualHost para WordPress..."
sudo bash -c 'cat > /etc/apache2/sites-available/wordpress.conf <<EOF
<VirtualHost *:80>
    DocumentRoot /var/www/html/wordpress
    <Directory /var/www/html/wordpress>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF'

# Deshabilitar el sitio por defecto
echo "Deshabilitando el sitio por defecto de Apache..."
sudo a2dissite 000-default.conf

# Habilitar el nuevo sitio de WordPress
echo "Habilitando el sitio de WordPress..."
sudo a2ensite wordpress.conf

# Habilitar el módulo de reescritura de Apache
echo "Habilitando el módulo de reescritura..."
sudo a2enmod rewrite

# Reiniciar Apache
echo "Reiniciando Apache..."
sudo systemctl restart apache2

# Instalar y configurar WordPress automáticamente
echo "Instalando WordPress..."
sudo -u www-data wp core install --path="/var/www/html/wordpress" --url="http://localhost" --title="Mi WordPress" --admin_user="admin" --admin_password="adminpassword" --admin_email="admin@example.com"

# Corregir permisos de caché de WP-CLI
echo "Corregir permisos de caché de WP-CLI..."
sudo mkdir -p /var/www/.wp-cli
sudo chown -R www-data:www-data /var/www/.wp-cli

# Instalar y activar el plugin SupportCandy
echo "Instalando y activando el plugin SupportCandy..."
sudo -u www-data wp plugin install supportcandy --activate --path="/var/www/html/wordpress"

# Configuración para permitir el acceso externo
echo "Configurando acceso desde otras máquinas..."
sudo ufw allow 'Apache Full'
sudo systemctl restart apache2

# Mensaje de éxito
echo "✅ Instalación completada. Accede a tu WordPress en http://<tu-ip-local>"
