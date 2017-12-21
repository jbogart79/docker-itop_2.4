#Imagen base:
FROM  debian

#Variables
ARG ITOP_USER=itop
ARG ITOP_PASSW=password
ARG ITOP_NAME_DB=itop

#Actualizacion e instalacion de dependencias:
RUN apt-get update && \
apt-get install -y apache2 mysql-server php7.0 php7.0-mysql php7.0-ldap php7.0-mcrypt php7.0-cli php7.0-soap php7.0-json graphviz wget unzip php7.0-dom php7.0-gd php7.0-zip

#Configuracion de PHP, MariaDB y Apache:
RUN perl -pi -e "s[post_max_size = 8M][post_max_size = 32M]g" /etc/php/7.0/cli/php.ini && \
perl -pi -e "s[; max_input_vars = 1000][max_input_vars = 5000]g" /etc/php/7.0/cli/php.ini && \
perl -pi -e "s[max_file_uploads = 20][max_file_uploads = 1]g" /etc/php/7.0/cli/php.ini && \
perl -pi -e "s[upload_max_filesize = 2M][upload_max_filesize = 10M]g" /etc/php/7.0/cli/php.ini && \
perl -pi -e "s[post_max_size = 8M][post_max_size = 15M]g" /etc/php/7.0/cli/php.ini && \
perl -pi -e "s[memory_limit = -1][memory_limit = 32]g" /etc/php/7.0/cli/php.ini && \
echo "[mysqld]" >> /etc/mysql/mariadb.cnf && \
echo "max_allowed_packet=40M" >> /etc/mysql/mariadb.cnf && \
echo "[mysqldump]" /etc/mysql/mariadb.cnf && \
echo "max_allowed_packet=40M" /etc/mysql/mariadb.cnf && \
echo "ServerName localhost" >> /etc/apache2/apache2.conf

#Descarga e instalcion de  la aplicaion:
RUN wget https://netcologne.dl.sourceforge.net/project/itop/itop/2.4.0/iTop-2.4.0-3585.zip && \
unzip iTop-2.4.0-3585.zip && \
rm -Rf /var/www/html/* && \
mkdir -p /var/www/html && \
cp -R ./web/* /var/www/html/ && \
chown -R www-data:www-data /var/www && \
rm -Rf ./web && rm -Rf ./iTop-2.4.0-3585.zip

#Creacion de usuario y DB
RUN service mysql start && \
mysql -u root -e "CREATE DATABASE IF NOT EXISTS $ITOP_NAME_DB" && \
mysql -u root -e "CREATE USER IF NOT EXISTS $ITOP_USER IDENTIFIED BY '$ITOP_PASSW'" && \
mysql -u root -e "GRANT ALL PRIVILEGES ON $ITOP_NAME_DB.* TO '$ITOP_USER'@'%' WITH GRANT OPTION"

#Copia de modulos personalizados
ADD sample-module.tar.bz2 /var/www/html/extensions/sample-module
ADD toolkit.tar.bz2 /var/www/html/toolkit

#Rutas para la instalacion de modulos personalizados
RUN chown -R www-data:www-data /var/www/html

#Se expone el puerto 80
EXPOSE 80

#Arranque servicios y comando de entrada
ENTRYPOINT service  apache2 start && service mysql start && /bin/bash
