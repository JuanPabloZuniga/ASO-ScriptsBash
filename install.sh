#!/bin/bash/
function error(){
	echo; read -p "$1. Pulse una tecla para continuar"
}
clear
ruta=`pwd` 

echo "$ruta" > ruta.txt

usu=`whoami`
if [[ "$usu" = "root" ]]
then
	error "No se puede ejecutar $0 con sudo"
	exit
fi
whoami > usuario.txt
echo "-----------------------------------------------"
echo " 		INSTALACIÓN ACTIVE DIRECTORY "
echo "-----------------------------------------------"
echo "  [1] fase 1"
echo "	[2] fase 2"
echo "	[3] fase 3"
echo "	[4] fase 4"
echo "	[5] Salir"
echo "-----------------------------------------------"
while true
do	
	echo; read -p "Escoja una opción [1-5]: " op
	case "$op" in
		"")error "Error: no ha introducido nada";;
		1)echo 0 > pasos.txt; sudo sh fase1.sh;;
		2)sudo sh fase2.sh;;
		3)sudo sh fase3.sh;;
		4)sudo sh fase4.sh;exit;;
		5)sh salir.sh
		if [[ "$?" -eq 100 ]]
		then 
			exit
		fi;;
		*)error "Error: opción incorrecta";;
	esac
done
