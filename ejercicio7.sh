#!/bin/bash
function buscar(){
while true
do
	read -p "Escriba el nombre del archivo o directorio: " nom
	echo; echo "Buscando, por favor, espere..."
	if [[ "$nom" = "" ]]
	then
		echo; read -p "No ha introducido nada"; continue
	fi
	find / -xdev -iname "*$nom*" 2> /dev/null > fichero.txt
	total=`cat fichero.txt | wc -l`
	if [[ "$total" -gt 0 ]]
	then
		if [[ "$cont" -eq 1 ]]
		then
			grep -n -E "." fichero.txt > numerado.txt
			echo; more numerado.txt
			while true
			do
				echo; read -p "Indique el número del archivo que desea trabajar: " num
				if [[ "$num" = "" ]]
				then
					echo; read -p "No ha introducido nada. Pulse intro..."
				elif [[ ! "$num" =~ ^[0-9]+$ ]]
				then
					echo; read -p "No ha introducido un numero. Pulse intro"
				elif [[ "$num" -gt "$total" || "$num" -lt 1 ]]
				then
					echo; read -p "error, introduzca un numero de la lista. Pulse intro"
				else
					encontrado=`grep -E "^$num:" numerado.txt | cut -f 2 -d ":"`; return 0
				fi
			done
		else
			echo; more fichero.txt
			rm fichero.txt
		fi
		echo; read -p "Pulse intro para continuar"; return 0
	else
		echo; read -p "Archivo no encontrado. Pulse intro"; return 0
	fi	
done
}

function tipo(){
file "$encontrado" | grep -Ei "directory" > /dev/null
if [[ $? -eq 0 ]]
then
	echo; read -p "$encontrado es un directorio. Pulse intro..."
else
	echo; read -p "$encontrado es un fichero. Pulse intro..."
fi
}

function permisos(){
per=`ls -l "$encontrado" | cut -f 1 -d " "`
echo; read -p " Los permisos de "$encontrado" son $per: ";

}

function propiedades(){
	clear
	echo; echo "[1] Tipo"
	echo; echo "[2] Permisos"
	echo; echo "[3] Propietario y Grupo de propeitarios"
	echo; echo "[4] Tamaño"
	read -p "Que operacion desea realizar: " pe
	case "$pe" in
	"") echo; read -p "no ha introducido nada. Pulse intro para continuar";;
	1)buscar;tipo;;
	2)buscar;permisos;;
	esac
}

while true
do
	clear
	echo; echo "[1] Buscar"
	echo; echo "[2] Propiedades"
	echo; echo "[3] Operaciones"
	echo; echo "[4] Salir"
	
	while true
	do
		echo; read -p "Que operacion desea ralizar[1-4]: " op2
		case "$op2" in
			"")error "No ha introducido nada"; continue;;
			1) cont=0; buscar;;
			2) cont=1;propiedades;;
			3) Operaciones;;
			4)sh salir.sh
			if [[ "$?" -eq 100 ]]
			then
				exit
			else
				continue 2
			fi;;
		esac
	done
done




