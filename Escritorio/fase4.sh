#!/bin/bash/
function error(){
	echo; read -p "$1. Pulse intro para continuar"
}
paso=`cat pasos.txt 2> /dev/null`
if [[ ! -f pasos.txt || ! "$paso" -eq 3 ]]
then 
	error "No se ha ejecutado la fase 3"
	exit
fi 

function Comprobar(){
	equipo=`hostname --fqdn`
	dominio=`dnsdomainname`
	host -t A $equipo 
	if [[ $? -eq 0 ]]
	then
		host -t SRV _ldap._tcp.$dominio
		if [[ $? -eq 0 ]]
		then
			host -t SRV _kerberos._udp.$dominio
			if [[ $? -eq 0 ]]
			then
				error "Servidor funcionando correctamente"
			else
				error "ERROR: hubo un problema en el servidor Kerberos"
			fi
		else
			error "ERROR: hubo un problema en el servidor ldap"
		fi
	else
		error "ERROR: hubo un problema en el servidor"
	fi
}

systemctl mask nmbd smbd winbind > /dev/null
systemctl disable nmbd smbd winbind > /dev/null
systemctl stop nmbd smbd winbind > /dev/null
systemctl unmask samba-ad-dc.service > /dev/null
systemctl start samba-ad-dc.service > /dev/null
systemctl enable samba-ad-dc.service > /dev/null
opserver=`cat tipoServer.txt`
if [[ "$opserver" -eq 1 ]]
then
	echo; echo "Generando ticket para el usuario Administrator"
	kinit Administrator
	samba-tool group addmembers Administrators $usu
fi

while true
do
	echo; read -p "Desea comprobar que el servidor funciona correctamente [SN]: " sino
	case "$sino" in
		"")error "No ha introducido nada";;
		[Ss])Comprobar; break;;
		[Nn])break;;
		*)error "Opción incorrecta";;
	esac
done
usu=`cat usuario.txt`
echo;echo "Añadiendo usuario de instalación a SAMBA 4"
smbpasswd -a $usu
rm usuario.txt tipoServer.txt pasos.txt ruta.txt
error "!SERVIDOR FUNCIONANDO DISFRUTA, MÁQUINA!"
