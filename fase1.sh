#!/bin/bash
function escogerServ(){
	echo; echo "------ TIPO SERVIDOR ------"
	echo "[1] Servidor principal"
	echo "[2] Servidor réplica"
	echo "[3] Salir"
	while true
	do
		echo; read -p "Escoja una opción [1-3]: " opserv
		case "$opserv" in
			"")error "Error: no ha introducido nada";;
			1)echo "$opserv" > tipoServer.txt; return 0;;
			2)echo "$opserv" > tipoServer.txt; return 0;;
			3)exit;;
			*)error "Error: opción incorrecta";;
		esac
	done
}

function error(){
	echo; read -p "$1. Pulse una tecla para continuar"
}

function pedirIP(){
while true
do
	echo; read -p "Introduzca una $num3 [c para cancelar]: " ipc
	
	if [[ "$ipc" = "" ]]
	then
		error "No ha introducido nada"
		continue
	elif [[ "$ipc" =~ [Cc] ]]
	then
		exit
	elif [[ ! "$ipc" =~ ([0-9]{1,3}\.){3}[0-9]{1,3} ]]
	then
		error "Dirección IP con formato incorrecto"
		continue
	fi
	
	num=`echo $ipc | sed "s/\./ /g"`
	set $num

	if [[ "$num2" -eq 1 && ( ( "$4" -le 0 || "$4" -ge 255 ) || ( "$1" -le 0 || "$1" -ge 255 ) || "$2" -ge 255  || "$3" -ge 255 ) ]]
	then
		error "Dirección IP no válida"
	elif [[ "$num2" -eq 2 && ( ! ( "$ipc" =~ (255\.){3}0 || "$ipc" =~ (255\.){2}0\.0 || "$ipc" =~ 255\.0\.0\.0  ) ) ]]
	then
		error "Máscara no válida"
	else
		return 0
	fi
done
}

function transformarMascara(){
	case "$ipc" in
		255\.255\.255\.0)mask="/24";;
		255\.255\.0\.0)mask="/16";;
		255\.0\.0\.0)mask="/8";;
	esac
}

function comprobarDominio(){
while true
do
	echo; read -p "Indique el nombre del dominio: " dominio
	if [[ "$dominio" = "" ]]
	then
		error "Es necesario indicar el nombre del dominio"
		continue
	elif [[ ! "$dominio" =~ [a-Z][0-9a-Z]*\.[a-Z]+ ]]
	then
		error "Nombre de dominio incorrecto"
		continue
	fi
	return 0
done
}

function NombreDominio(){
	dominio=`cat /etc/netplan/$nombreip | grep -Eio "[a-Z][0-9a-Z]*\.[a-Z]+"`
}

function NombreEquipo(){
	echo; echo "SEGUNDO PASO: Configuración del nombre del equipo"
	nombre=`hostname`
	echo; echo "El nombre actual del equipo es $nombre"
	while true
	do
		echo; read -p "Desea cambiarlo? [SN]: " sino2
		if [[ "$sino2" = "" ]]
		then
			error "Opción incorrecta"
		elif [[ "$sino2" =~ ^[Ss]$ ]]
		then
			while true
			do
				echo; read -p "Introduzca un nuevo nombre para el equipo: " newname
				if [[ "$newname" = "" ]]
				then
					error "No ha introducido nada"
					continue
				else
					echo "$newname" > /etc/hostname
					sed -i 's/^127.0.1.1.*/127.0.1.1 '$newname'.'$dominio' '$newname'/' /etc/hosts
					return 0
				fi
			done
		elif [[ "$sino2" =~ ^[Nn]$ ]]
		then
			sed -i 's/^127.0.1.1.*/127.0.1.1 '$nombre'.'$dominio' '$nombre'/' /etc/hosts
			return 0
		else
			error "Opción incorrecta"
		fi
	done
}

function ActivarByobu(){
	usu=`cat usuario.txt`
	echo; echo "TERCER PASO: Configurando byobu"
	while true
	do
		echo; read -p "Desea activar byobu [SN]: " sino
		if [[ "$sino" = "" ]]
		then
			error "Opción incorrecta"
		elif [[ "$sino" =~ ^[Ss]$ ]]
		then
			sudo -u "$usu" byobu-enable
			timedatectl set-timezone Europe/Madrid
			break
		elif [[ "$sino" =~ ^[Nn]$ ]]
		then
			break
		else
			error "Opción incorrecta"
		fi
	done

	echo; read -p "Configuración realizada correctamente. Se va a proceder a reiniciar el equipo. Una vez reiniciado, continue con la instalación del servidor en la opción fase2. Pulse una tecla para reiniciar"
	echo 1 > pasos.txt
	ruta=`cat ruta.txt`  
	echo @reboot sh $ruta/fase2.sh > /var/spool/cron/crontabs/$usu
	reboot
}


function configuracion(){
	echo; echo "PIMER PASO: Configuración de la tarjeta de red. Es necesario asignar una IP estática al Server"
	
	while true
	do
		echo; read -p "Desea cambiar la configuración IP [SN]: " sino4
		case "$sino4" in
			"")error "No ha introducido nada";;
			[Ss])break;;
			[Nn])NombreDominio; return 0;;
			*)error "Opción incorrecta";;
		esac
	done
	while true
	do
		num2=1
		num3="dirección IP" 
		pedirIP 
		nuevaip=$ipc
		num2=2
		num3="máscara" 
		pedirIP 
		transformarMascara
		num2=1
		num3="puerta de enlace"
		pedirIP 
		puertaE=$ipc
		if [[ "$opserv" -eq 2 ]]
		then
			num3="DNS principal"
			pedirIP
			dns=$ipc
		else
			dns=$nuevaip
		fi
		comprobarDominio
		
		tarjeta=`ip a | grep -E "^[0-9]" | tail -1 | cut -f 2 -d " " | cut -f 1 -d ":"`
		echo "network:" > /etc/netplan/$nombreip
		echo "  ethernets:" >> /etc/netplan/$nombreip
		echo "    $tarjeta:" >> /etc/netplan/$nombreip
		echo "      addresses: [$nuevaip$mask]" >> /etc/netplan/$nombreip
		echo "      routes:" >> /etc/netplan/$nombreip
		echo "          - to: default" >> /etc/netplan/$nombreip
		echo "            via: $puertaE" >> /etc/netplan/$nombreip
		echo "      nameservers:" >> /etc/netplan/$nombreip
		echo "          search: [$dominio]" >> /etc/netplan/$nombreip
		echo "          addresses: [$dns,8.8.8.8]" >> /etc/netplan/$nombreip
		echo "  version: 2" >> /etc/netplan/$nombreip
		netplan apply > /dev/null 2> /dev/null
		ping -c 1 8.8.8.8 > /dev/null 2> /dev/null
		if [[ "$?" -eq 2 ]]
		then
			while true
			do
				echo; read -p "Error: ha habido un problema en la configuración de red. Desea volver a configurarla? [SN]: " snserv
				case "$snserv" in
					"")error "Error: no ha introducido nada";;
					s|S)continue 2;;
					n|N)	echo "network:" > /etc/netplan/$nombreip
						echo "  ethernets:" >> /etc/netplan/$nombreip
						echo "    $tarjeta:" >> /etc/netplan/$nombreip
						echo "      dhcp4: true" >> /etc/netplan/$nombreip
						echo "  version: 2" >> /etc/netplan/$nombreip
						netplan apply
						error "Usted ha escogido una dirección IP automática, incompatible con la instalación de AD. El programa se cerrará"
						exit;;
					*)error "Error: opción incorrecta";;
				esac
			done
		fi
		echo; read -p "Red configurada correctamente. Pulse intro para continuar"
		return 0
	done
}

paso=`cat pasos.txt 2> /dev/null` 
if [[ ! -f pasos.txt || ! "$paso" -eq 0 ]]
then 
	error "El servidor se instala desde el archivo install.sh"
	exit
fi 

clear
echo; echo "SE VA A PROCEDER A LA INSTALACIÓN DE UN SERVIDOR ACTIVE DIRECTORY EN ESTE EQUIPO."
escogerServ
nombreip=`ls /etc/netplan/`
configuracion 
NombreEquipo
ActivarByobu

