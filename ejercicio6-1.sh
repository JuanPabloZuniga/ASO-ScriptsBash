#!/bin/bash

function ComprobarIP(){
	while true
	do
		echo; read -p "introduzca la IP que desea comprobar: " ipc
		if [[ ! "ipc" =~ ([0-9]{1,3}\.){3}[0-9]{1,3} ]]
		then
			error "direccion IP no valida"
			continue
		fi
		
		num=`echo $ipc | sed "s/\./ /g"`
		set $num
		
		if [[ "$4" -eq 0 && ( "$1" -ge 1  && "$1" -le 254 ) &&  ( "$2" -ge 1  && "$2" -le 255 ) && ( "$3" -ge 1  && "$3" -le 255 ) ]]
		then
			error "direccion IP no válida"
			continue
		elif [[ "$4" -eq 255 && ( "$1" -le 0  && "$1" -ge 255 ) &&  ( "$2" -ge 255  && "$2" -le 255 ) && ( "$3" -ge 1  && "$3" -le 255 ) ]]
		then
			error "has introducido una direccion de difusión"
			continue
		elif [[ ("$4" -eq 0 || "$4" -ge 255) || ("$1" -le 0 || "$1" -ge 255) || "$2" -ge 255 || "$3" -ge 255 ]]
		then
			error "direccion IP no valida"
			continue
		fi
		echo; echo "Comprobando IP, espere..."
		ping -c 1 $ipc > /dev/null 2> /dev/null
		if [[ "$?" -eq 0 ]]
		then
			echo; read -p "equipo "$ipc" conetado"
			continue 2
		elif [[ "$?" -eq 1 ]]
		then
			echo; read -p "equipo "$ipc" no conectado"
			continue 2;
		fi
	done;
}
function pcaula(){
while true
do
	echo; read -p "Introduzca el último octeto dela direccion de red deo equipo: " oct
	ipau=`ip a | sed "s/ */ /g" | grep -Eio "([0-9]{1,3}\.){3}" | cut -d "/" -f 1 | tail -1 | head -1`
	ipaula="$ipau$oct"
	if [[ "$oct" = "" ]]
	then
		echo; read -p "no ha introducido nada"
		continue
	elif [[ "$oct" =~ ^[Cc]$ ]]
	then
		return 0
	elif [[ "$oct" =~ ^[0-9]{1,3}$ ]]
	then
		echo; read -p "el valor no es correcto."
		continue
	elif [[  "$oct" -ge 1 && "$oct" -le 254 ]]
	then
		ping -c 1 "$ipaula" > /dev/null 2>&1
		case $? in
			0) echo; read -p "equipo conectado."; return 0;;
			1) echo; read -p "equipo no conectado"; return 0;;
		esac
	
	else
		echo; read -p "valor incorrecto"
		continue 2
	fi
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
			1)ComprobarIP;;
			2)ComprobarPC;;
			4)return 0;;
			*)error "vallor no introducido"; continue;;
		esac
	done
done
}
function compaula(){
	echo; read -p "introduzca la primera dirección del rango que desea comprobar: " pri
	echo; read -p "introduzca la última dirección del rango que desea comprobar: " seg
	for (( ult="$pri"; ult<="$seg"; ult++ ))
	do
		ping -c 1 $ipau$ult > /dev/null && echo "$ipau$ult" >> EQUIPOS_CONECTADOS.txt  || echo "$ipau$ult" >> EQUIPOS_NO_CONECTADOS.txt
	done
	echo; echo "===Equipos Conectados==="
	cat EQUIPOS_CONECTADOS.txt
	echo; echo EQUIPOS_NO_CONECTADOS.txt
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
