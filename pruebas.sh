#!/bin/bash/
clear
dia=`date | cut -f 1-3 -d " "`
hora=`date | cut -f 5 -d " "`
echo "hoy es $dia y son las $hora"

echo; read -p "Introduzca su nombre: " nombre
echo su nombre es $nombre

echo; read -p "Introduzca su nombre y apellidos: " nombre1
echo su nombre es $nombre1

echo "su directorio actual es `pwd`"

echo "el valor de \$1 es $1"
echo "el valor de \$2 es $2"
echo "el valor de \$3 es $3"
set `date`
