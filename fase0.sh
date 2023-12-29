#!/bin/bash/
clear
echo $USERNAME > usuario.txt
#sudo sh fase1.sh
echo "instalacion de AD"
echo "[1] fase 1"
echo "[2] fase 2"
echo "[3] fase 3"
echo "[4] fase 4"
echo "[5] fase 5"
while true
do
	echo; read -p "Elige una opcion [1-5]" op
	case "$op" in
		"")error "error: no ha introducido nada";;
		1)sudo sh fase1.sh;;
		2)sudo sh fase2.sh;;
		3)sudo sh fase3.sh;;
		4)sudo sh fase4.sh;;
		5)sudo sh salir.sh;;
		if [[ "$?" -eq 100 ]]
		then
			exit
		fi;;
		*)error "opcion incorrecta";;
	esac
done
