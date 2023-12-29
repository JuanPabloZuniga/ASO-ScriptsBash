#!/bin/bash/
function error(){
	echo; read -p "$1. Pulse intro para continuar"
}
paso=`cat pasos.txt 2> /dev/null`
if [[ ! -f pasos.txt || ! "$paso" -eq 2 ]]
then 
	error "No se ha ejecutado la fase 2"
	exit
fi 
clear

echo; echo "SEXTO PASO: Actualización del DNS"
systemctl stop systemd-resolved.service > /dev/null
systemctl disable systemd-resolved.service > /dev/null
unlink /etc/resolv.conf
nombreip=`ls /etc/netplan/`
ip1=`cat /etc/netplan/$nombreip | grep -E "addresses" | tail -1 | grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}" | head -1`
ip2=`cat /etc/netplan/$nombreip | grep -E "via" | head -1 | grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}"`
dominio=`cat /etc/netplan/$nombreip | grep -Eio "[a-Z][0-9a-Z]*\.[a-Z]+"`

echo "nameserver $ip1" > /etc/resolv.conf
echo "nameserver $ip2" >> /etc/resolv.conf
echo "search $dominio" >> /etc/resolv.conf
echo; read -p "Configuración realizada correctamente. Se va a proceder a reiniciar el equipo. Una vez reiniciado, continue con la instalación del servidor en la opción fase4. Pulse una tecla para reiniciar"
echo 3 > pasos.txt
reboot
