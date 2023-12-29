#!/bin/bash/
function error(){
	echo; read -p "$1. Pulse intro para continuar"
}
paso=`cat pasos.txt 2> /dev/null`
if [[ ! -f pasos.txt || ! "$paso" -eq 1 ]]
then 
	error "No se ha ejecutado la fase 1"
	exit
fi 
echo; echo "CUARTO PASO: Actualizar el sistema"
apt update
#apt upgrade
clear
echo; echo "QUINTO PASO: Instalación del servidor SAMBA 4"

apt install build-essential libacl1-dev libattr1-dev libblkid-dev libgnutls28-dev libreadline-dev python-dev-is-python3 libpam0g-dev python3-dnspython gdb pkg-config libpopt-dev libldap2-dev dnsutils libbsd-dev attr krb5-user docbook-xsl libcups2-dev acl winbind

apt install samba
mv /etc/samba/smb.conf /etc/samba/smb.conf.old
opserver=`cat tipoServer.txt`
nombreip=`ls /etc/netplan`
dominio=`cat /etc/netplan/$nombreip | grep -Eio "[a-Z][0-9a-Z]*\.[a-Z]+"`
if [[ "$opserver" -eq 1 ]]
then
	samba-tool domain provision --use-rfc2307 --interactive
elif [[ "$opserver" -eq 2 ]]
then
	samba-tool domain join "$dominio" DC -UAdministrator
fi
echo; read -p "Configuración realizada correctamente. Se va a proceder a reiniciar el equipo. Una vez reiniciado, continue con la instalación del servidor en la opción fase3. Pulse una tecla para reiniciar"
echo 2 > pasos.txt
reboot
