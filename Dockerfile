# Version 1.0.0

FROM ubuntu:16.04
MAINTAINER Jérôme KLAM, "jeromeklam@free.fr"

## Installation des utilitaires de base
RUN apt-get update
RUN apt-get -y install wget tzdata curl zip dos2unix

## TimeZone
RUN echo "Europe/Paris" > /etc/timezone
RUN rm /etc/localtime
RUN dpkg-reconfigure -f noninteractive tzdata

## Installation d'Apache 2
RUN apt-get update && apt-get install -y apache2 apache2-doc apache2-utils libexpat1 ssl-cert

## Installation de PHP 7
RUN apt-get update
RUN apt-get install -y php
RUN apt-get install -y php-mbstring php-mcrypt php-mysql php-xml libapache2-mod-php7.0 php-pear php-soap
RUN apt-get update
RUN apt-get install -y php-dev php-tidy php-zip php-memcached php-xdebug php7.0-curl php7.0-ldap php-gd

# git
RUN apt-get install -y git

## Installation des utilitaires
RUN apt-get install -y vim nano

## Update
RUN apt-get update

## Installation de composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/bin/composer
# module dev avec liens
RUN composer global require "jeromeklam/composer-localdev"
RUN composer global update

## Création du repertoire pour stocker les fichiers de configuration
RUN mkdir -p /config/php7/apache2 /config/php7/cli /config/apache2

## Variables d'environnement
ENV DOCUMENTROOT www
ENV SERVERNAME apache2php7.local.fr
ENV ERRORLOG error.log
ENV ACCESSLOG access.log
ENV APP_SERVERNAME localhost

## Suppression du vhost par défaut
RUN rm /etc/apache2/sites-enabled/000-default.conf

## Ajout des fichiers virtualhost
ADD ./docker/apache2/virtualhost.conf /config/apache2
ADD ./docker/apache2/virtualhost_ssl.conf /config/apache2
RUN cp /config/apache2/virtualhost.conf /etc/apache2/sites-available
RUN cp /config/apache2/virtualhost_ssl.conf /etc/apache2/sites-available
RUN ln -sf /etc/apache2/sites-available/virtualhost.conf /etc/apache2/sites-enabled/000-default.conf
RUN ln -sf /etc/apache2/sites-available/virtualhost_ssl.conf /etc/apache2/sites-enabled/000-default_ssl.conf
RUN mv /etc/apache2/apache2.conf /etc/apache2/apache2.conf.orig 
RUN sed -e 's/# Global configuration/# Global configuration\nServerName localhost/g' < /etc/apache2/apache2.conf.orig > /etc/apache2/apache2.conf

## Activation des modules SSL et REWRITE
RUN a2enmod ssl
RUN a2enmod env
RUN a2enmod rewrite
RUN a2enmod headers

## On expose le port 80 et 443
EXPOSE 80
EXPOSE 443

VOLUME /var/www
VOLUME /var/log/apache2

## Bower & grunt
RUN apt-get install -y nodejs npm
RUN ln -sf /usr/bin/nodejs /usr/bin/node
RUN npm install -g bower grunt
RUN npm install -g dredd
RUN npm install -g aglio

## On déplace les fichiers de configuration s'il n'existe pas et on démarre apache
ADD ./docker/startup.sh /
RUN chmod +x /startup.sh
CMD ["/bin/bash", "/startup.sh"]