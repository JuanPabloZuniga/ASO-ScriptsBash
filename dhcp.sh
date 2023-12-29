#!/bin/bash
function error(){
	echo; read -p "ERROR: $1. Pulse intro para continuar"
}
function mensaje(){
	echo; read -p "$1. Pulse intro para continuar"
}
function range(){
if [[ "$1" -eq 100 ]]
then
	while true
	do
	echo; read -p "Indique el $2 número del rango:  " rango
	if [[ "$rango" = "" ]]
	then
		error "no ha introducido nada"
		continue
	elif [[ "$rango" -ge 2 && "$rango" -le 254 ]]
	then
		return 0
	else
		error "valor incorrecto"
		continue
	fi
	done
else
	set $ip2
	echo "subnet $1.$2.$3.0 netmask 255.255.255.0 {" >> /etc/dhcp/dhcpd.conf
	echo "  range $1.$2.$3.$rango1 $1.$2.$3.$rango2;" >> /etc/dhcp/dhcpd.conf
	echo "}" >> /etc/dhcp/dhcpd.conf
fi
}
function menu(){
while true
do	clear
	echo "=================================="
	echo "1) Ver estado"
	echo "2) Añadir parámetros"
	echo "3) Configurar rango"
	echo "4) Salir"
	echo "=================================="
	echo; read -p "Escoja una opción [1-4]: " op2
	case "$op2" in
	"")error "No ha introducido nada";continue;;
	1)sudo systemctl status isc-dhcp-server;;
	2)parametros;;
	3)range;;
	4)sh salir.sh
		if [[ "$?" -eq 100 ]]
		then
			exit
		else
			continue 2
		fi;;
	*)error "valor no válido";continue;;
	esac
done
}
function parametros(){
while true
do	clear
	echo "=========================================="
	echo "1) Añadir mínimo tiempo de concesión"
	echo "2) Añadir máximo tiempo de concesión"
	echo "3) Añadir tiempo de concesión por defecto"
	echo "4) Añadir puerta de enlace predeterminada"
	echo "5) Añadir las direcciones de los servidores DNS en las concesiones"
	echo "6) Excluir Ips"
	echo "7) Reservar Ip"
	echo "=========================================="
	echo; read -p "Escoja una opción [1-7]: " op4
	case "$op4" in
		"")error "no ha introducido nada";continue;;
		1)preguntaT mínimo min;;
		2)preguntaT máximo max;;
		3)preguntaT "por defecto";;
		4)pEnlace "la puerta de enlace" "	option routers";;
		5)pEnlace "la direccion del servidor DNS" "	option domain-name-servers";;
		6)excluir;;
		7)reservar;;
		*)error "valor no válido";continue;;
	esac
done
}
function pEnlace(){
while true
do
	echo; read -p "Introduzca $1 que desea añadir: " pe
	if [[ "$pe" = "" ]]
	then
		error "no ha introducido nada"
		continue
	elif [[ "$pe" =~ ([0-9]{1,3}\.){3}[0-9]{1,3} ]]
	then
		numS=`grep -En "." /etc/dhcp/dhcpd.conf | grep -E "^[0-9]+:subnet" | cut -f1 -d ":"`
		numS=$((numS + 1))
		sed -i "$numS i\$2 $pe;" /etc/dhcp/dhcpd.conf
		mensaje "Parámetro añadido con éxito"
		break
	else
		error "valor no válido"
		continue
	fi
done
}
function preguntaT(){
grep -Eiq "^$2-lease-time" /etc/dhcp/dhcpd.conf
if [[ "$?" -eq 0 ]]
then
	error "Ya hay un parámetro configurado"
else
	while true
	do
		echo; read -p "Introduzca, en segundos, el tiempo $1 que desea: " op5
		if [[ "$op5" = "" ]]
		then
			error "no ha introducido nada"
			continue
		elif [[ "$op5" =~ [a-Z] ]]
		then
			error "Valor no válido"
			continue
		else
			echo "$2-lease-time $op5;" >> /etc/dhcp/dhcpd.conf
			sudo systemctl restart isc-dhcp-server
			mensaje "Parámetro añadido con éxito"
			break
		fi
	done
fi
}
ip=`ip a | grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}/24" | cut -f1 -d "/"`
ip2=`echo "$ip" | sed "s/\./ /g"`
clear
sudo systemctl status isc-dhcp-server > /dev/null
if [[ "$?" -eq 0 ]]
then
	while true
	do
		echo; read -p "EL servicio ya está instalado. ¿Desea continuar? [SN]: " op2
		if [[ "$op2" = "" ]]
		then
			error "No ha introducido nada"
			continue
		elif [[ "$op2" =~ ^[sS] ]]
		then
			 menu
		elif [[ "$op2" =~ ^[nN]$ ]]
		then
			exit
		else
			error "Valor incorrecto"
			continue
		fi
	done
else
	redT=`cat /etc/netplan/01-network-manager-all.yaml | wc -l`
	if [[ "$redT" -lt 5 ]]
		then
			error "No se dispone de un IP estática."
		else
		while true
		do
		clear
		echo; read -p "Se va a proceder a la instalación del servicios DNS ¿Desea continuar[SN]?: " op1
			case "$op1" in
				"")error "no ha introducido nada";continue;;
				s|S)echo;echo "Por favor, espere"
				    sudo apt update -y > /dev/null 2> /dev/null
				    #sudo apt upgrade -y > /dev/null 2> /dev/null
				    sudo apt install isc-dhcp-server -y > /dev/null 2> /dev/null
				    sudo cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.copia
				    range 100 primer
				    rango1="$rango"
				    range 100 segundo
				    rango2="$rango"
				    range 200
				    sudo systemctl start isc-dhcp-server
				    echo; mensaje "Instalación existosa"
				    menu
				    ;;
				n|N)exit;;
				*)error "valor incorrecto";continue;;
			esac
		done
	fi
fi
