#!/bin/bash

##
## Bad previous shutdown...
##
rm -rf /run/apache2/*
rm -rf /var/run/apache2/*

if [ "X$COMPOSERS" != "X" ]; then
  set -f                      # avoid globbing (expansion of *).
  echo "processing composer in : $COMPOSERS..."
  array=(${COMPOSERS//:/ })
  for i in "${!array[@]}"
  do
    crt=${array[i]}
    if [ -d $crt ]; then
      cd $crt
      composer install
    fi
  done
fi;
if [ "X$BOWERS" != "X" ]; then
  set -f                      # avoid globbing (expansion of *).
  echo "processing bower in : $BOWERS..."
  array=(${BOWERS//:/ })
  for i in "${!array[@]}"
  do
    crt=${array[i]}
    if [ -d $crt ]; then
      cd $crt
      bower install --allow-root
    fi
  done
fi;
echo "...all ok..."

##
## Démarrage d'Apache2
##
/usr/sbin/apache2ctl -D FOREGROUND