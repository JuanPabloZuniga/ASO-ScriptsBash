#!/bin/bash

function ComprobarIP(){
	while true
	do
		echo; read -p "introduzca la IP que desea comprobar: " ipc
		if [[ ! "ipc" =~ ([0-9]{1,3}\.){3}[0-9]{1,3} ]]
		then
			echo; error "direccion IP no valida"
			continue
		elif [[ "$ipc" =~ .*255.* || "$ipc" =~ ^0.* || "$ipc" =~ .*0$ ]]
		then
			echo; error "direccion IP no valida"
			continue
		fi
		echo; echo "Comprobando IP, espere..."
		cping=`ping -c 1 $ipc`
		if [[ "$?" -eq 0 ]]
		then
			echo; read -p "equipo "$ipc" conectado"
	done
}
function menuRed(){
while true
do
	clear
	echo; echo "[1] Comprobar una IP"
	echo; echo "[2] Comprobar un PC del aula"
	echo; echo "[3] Comprobar todo el aula"
	echo; echo "[4] Volver"
	
	while true
	do
		echo; read -p "Que operacion desea ralizar[1-4]: " op2
		case "$op2" in
			"")error "No ha introducido nada"; continue;
			1)ComprobarIP; continue 2;;
			2)ComprobarPC; continue 2;;
			4)return 0;;
			*)error "vallor no introducido"; continue;;
		esac
	done
done
}

echo; echo "[1] ver mi IP"
echo; echo "[2] Comprobar la red"
echo; echo "[3] Salir"

while true 
do
	echo;read -p "Que operacion desea realizar [1-3]: " op
		if [[ ! "$op" =~ ^[1-3]$ ]]
		then
			echo; read -p "opcion incorrecta, pulse intro"
		elif [[ "$op" -eq 1 ]]
		then
			echo
			ip=`ip a | grep -Eio "([0-9]{1,3}\.){3}[0-9]{1,3}\/[0-9]{2}" | cut -f 1 -d "/"`
			 echo;read -p "$ip - Pulse intro para continuar"
		elif [[ "$op" -eq 2 ]]
		then menuRed
		fi	
done

while true
do
	clear

while true
do
	echo; read -p "Que operacion desea realizar" op
	case "op" in
		"")error "No ha introduido nada";;
		1)MiIP;continue;;
		2)ComprobarRed;;
		3)sh salir.sh
			if;; [[ "$?" -eq 100 ]]
			then
				exit
			else
				continue 2
			fi;;
		*) error "valor no valido"; continue;;
	esac
done
