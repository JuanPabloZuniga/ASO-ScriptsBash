#!/bin/bash
function error(){
	echo; read -p "ERROR: $1.Pulse intro para continuar"
}
function mensaje(){
	echo; read -p "$1. Pulse intro para continuar"
}
function instalar(){
while true
do
	echo; read -p "Se va a proceder a instalar el servicio NFS en el equipo $1, ¿desea continuar?: [sn]: " op2
	if [[ "$op2" = "" ]]
	then
		error "No ha introducido nada"
		continue
	elif [[ "$op2" =~ ^[sS]$ ]]
	then
		apt install $2 
		return 0
	elif [[ "$op2" =~ ^[nN]$ ]]
	then
		exit
	else
		error "valor incorrecto"
		continue
	fi
done
}
function comprobarRecurso(){
while true
do
	echo; read -p "Indique la ruta absoluta del directorio a compartir: " op3
	if [[ "$op3" = "" ]]
	then
		error "No ha introducido nada"
		continue
	else
		mkdir -p "$op3"
		sudo chmod -R 777 "$op3"
		return 0
	fi
done
}
function exportarRecurso(){
	echo "$op3 *(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
	exporfs -a
	systemctl restart nfs-kernel-server
	echo; read -p mensaje "Recurso compartido correctamente."
	return 0
}
function pMontaje(){
while true
do
	echo; read -p "Indique la Ip del servidor: " op4
	if [[ "$op4" = "" ]]
	then
		error "no ha introducido anda"
		continue
	else
		break 
	fi
done
while true
do
	echo; read -p "Indique la ruta absoluta de la carpeta compartida del servidor: " op5
	if [[ "$op5" = "" ]]
	then
		error "No ha introducido nada"
		continue
	else
		break
	fi
done
while true
do
	echo; read -p "Indique la ruta absoluta de la carpeta compartida en este equipo: " op6
	if [[ "$op6" = "" ]]
	then
		error "No ha introducido nada"
		continue
	else
		mkdir -p /mnt/"$op6"
		mount -t nfs "$op4":"$op5" /mnt"$op6"
		echo "$op4:$op5 /mnt/$op6 nfs auto,noatime,nolock,bg,nfsvers=3,intr,tcp,actimeo=1800 0 0" >> /etc/fstab
		mount -a
	fi
done
}
while true
do
	clear
	echo "========================"
	echo "1. Servidor"
	echo "2. Cliente"
	echo "3. Salir"
	echo "========================"
	echo; read -p "Desde que equipo se encuentra [1-3]: " op1
	case "$op1" in
		"")error;continue;;
		1)instalar servidor "nfs-kernel-server nfs-common rpcbind"
		  comprobarRecurso
		  exportarRecurso;;
		2)instalar cliente "nfs-common rpcbind"
		pMontaje;;
		3)salir;;
	esac
done
