#!/bin/bash
function error(){
	echo; read -p "$1. Pulse intro para continuar..."
}

function instalarServicio() {
	echo; echo "Instalando Servicio NFS. Por favor espere..."
	if [[ "$opc" -eq 1 ]]
	then
		apt install nfs-kernel-server nfs-common rpcbind -y &> /dev/null
	else
		apt install nfs-common rpcbind -y &> /dev/null
	fi
}

function tareaProgramada() {
	usuario=$(cat nomuser.txt)
	if [[ -d "/var/spool/cron/crontabs/$usuario" ]];then
		cat /var/spool/cron/crontabs/$usuario > tarea.txt
	fi
	echo "* * * * * cp -R /mnt$ruta $ruta" >> tarea.txt
	crontab -u $usuario tarea.txt
	#rm nomuser.txt tarea.txt
}

function puntoMontaje(){
	while true;do
		echo;read -p "Especifique la dirección IP del servidor principal: " dirip
		ping -c1 $dirip &> /dev/null
		if [[ $? -gt 0 ]];then
			echo; read -p "Dirección Ip inválida. Pulse intro para continuar."; continue
		else 
			while true;do
				echo;read -p "Introduzca la ruta ABSOLUTA del recurso compartido: " ruta
				case "$ruta" in
					"")error "Error: no ha introducido nada";continue;;
					*)mkdir -p /mnt"$ruta"
					mount -t nfs $dirip:$ruta /mnt"$ruta"
					if [[ "$?" -gt 0 ]];then
						error "Ha habido un problema con la dirección IP o la ruta especificada";continue
					else 
						break 				
					fi;;
					
				esac
			done
		fi
	
		grep -Ei "$ruta" /etc/fstab &> /dev/null 
		if [[ "$?" -gt 0 ]];then
			echo "$dirip:$ruta	/mnt"$ruta"	nfs	auto,noatime,nolock,bg,nfsvers=3,intr,tcp,actimeo=1800 0 0" >> /etc/fstab
			mount -a
			echo; read -p "Se ha creado el punto de montaje automáticamente para la ruta $ruta";return 0		
		else 
			while true;do
				echo; read -p "El punto de montaje ya se encuentra creado para la $ruta. Desea indicar otra ruta [S,N]: " sino
				case $sino in
					"")error "Error: no ha introducido nada";continue;;
					s|S)continue 2;;
					n|N)return 0;;
					*)error "Error: opción inválida";continue;;
				esac
			done
		fi
	done		
}

function comprobarRecurso() {
while true
do
	echo; read -p "Indique un nombre para el directorio a compartir: " dir
	if [[ "$dir" = "" ]]
	then
		echo; read -p "Error, no ha introducido nada. Pulse intro para continuar."; continue
	fi
	echo; echo "Buscando directorios con ese nombre. Por favor espere..."
	find / -xdev -iname "*$dir*" -type d | grep -n "." > nomdir.txt
	if [[ -s nomdir.txt ]]
	then
		numrow=$(cat nomdir.txt | wc -l)
		let numrow+=1
		echo "$numrow:Indicar directorio propio" >> nomdir.txt
		more nomdir.txt
		while true
		do
			echo; read -p "Elija una opción [1 - $numrow]: " opc
			if [[ ! ( "$opc" =~ ^[0-9]+$ && "$opc" -ge 1 && "$opc" -le "$numrow" ) ]]
			then
				echo; echo "Error, debe introducir un número entre 1 y $numrow"; continue
			fi
			break
		done
		if [[ "$numrow" -eq "$opc" ]]
		then
			crearDirectorio
			if [[ $? -eq 10 ]]
			then
				continue
			else
				return 0
			fi
		else
			ruta=$(grep -Ei "^$opc:" nomdir.txt | cut -f2 -d ":")
			chmod -R 777 "$ruta"
			return 0
		fi
	else
		echo; read -p "No se ha encontrado nada. Pulse intro para continuar."
		crearDirectorio
		if [[ $? -eq 10 ]]
		then
			continue
		else
			return 0
		fi
	fi
done		
}

function crearDirectorio () {
while true
do
	echo; read -p "Indique la ruta ABSOLUTA  del directorio que deseas compartir: " ruta
	if [[ ! "$ruta" =~ ^/ ]]
	then
		echo; read -p "No se ha indicado una ruta absoluta. Pulse intro para continuar"; continue
	fi
	break
done
ls $ruta &> /dev/null
if [[ $? -gt 0 ]]
then
	while true
	do
		echo; read -p "El directorio indicado no existe. ¿Desea crearlo? [S-N]: " crear
		case "$crear" in
			"") echo; read -p "Error, no ha introducido nada. Pulse intro para continuar.";;
			[sS]) mkdir -p "$ruta"; chmod -R 777 "$ruta"; return 0;;
			[nN]) return 10;;
			*) echo; read -p "Error, valor no válido.";;			
		esac
	done
fi		
}

function compartirRecurso() {
	if [[ ! -f "/etc/samba/smb.conf" ]]
	then
		apt install samba -y &> /dev/null
	fi
	grep -Ei "$ruta" /etc/samba/smb.conf &> /dev/null
	if [[ $? -eq 0 ]]
	then
		echo; read -p "El recurso $ruta estaba compartido con anterioridad. Pulse intro para continuar."; return 0
	fi
	dir=$(echo $ruta | awk -F / '{print $NF}')
	echo "[$dir]" >> /etc/samba/smb.conf
	echo "    path = $ruta" >> /etc/samba/smb.conf
	echo "    browseable = yes" >> /etc/samba/smb.conf
	echo "    writeable = yes" >> /etc/samba/smb.conf
	echo; testparm
	echo; read -p "Recurso compartido correctamente. Pulse intro para continuar."
	
}
function exportarRecurso() {
	grep -Ei "$dir" /etc/exports &> /dev/null
	if [[ $? -eq 0 ]]
	then
		echo; read -p "El recurso $dir estaba exportado con anterioridad. Pulse intro para continuar."
		otroRecurso
		if [[ "$?" -eq 50  ]];then
			return 50
		fi
	fi
	while true
	do
		clear
		echo; read -p "Indique la direción IP del equipo inicial al que desea exportar el recurso [* para todos]: " dirip
		if [[ "$dirip" =~ "*" ]]
		then
			break
		elif [[ "$dirip" = "" ]];then
			error "No ha introducido nada";continue
		elif [[  "$dirip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]];then	
			echo; echo "Comprobando IP. Por favor espere..."
			ping -c1 $dirip &> /dev/null
			if [[ $? -gt 0 ]]
			then
				echo; read -p "Dirección Ip inválida. Pulse intro para continuar."; continue
			else 
				while true;do
					echo;read -p "Desea exportar el recurso a más de equipos [SN]: " sino
					case "$sino" in
						"")error "Error: no ha introducido nada";continue;;
						s|S)preguntarRango;break 2;;
						n|N)break 2;;
						*)error "Error: valor no válido";continue;;
					esac
				done
			fi
		else 
			error "Error: dirección IP inválida";continue
		fi			
	done
	echo "$ruta $dirip(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
	exportfs -a &> /dev/null && systemctl restart nfs-kernel-server &> /dev/null
	echo; read -p "El recurso compartido ha sido exportado para todos los equipos indicados...";otroRecurso;return 50
}

function otroRecurso(){
	while true;do
		echo;read -p "Desea probar con otro recurso [SN]: " sino
		case "$sino" in
			"")error "Error: no ha introducido nada";continue;;
			s|S)return 50;;
			n|N)exit;;
			*)error "Error: valor no válido";continue;;
		esac
	done
}

function preguntarRango(){
	num_equipo=`echo $dirip | cut -f4 -d "."`
	let num_equipo++
	while true;do
		echo;read -p "Indique el número del último equipo al que desea exportar el recurso [$num_equipo-254]: " last
		if [[ "$last" = "" ]];then
			error "Error: no ha introducido nada";continue
		elif [[ ! "$last" =~ ^[0-9]+$ || "$last" -lt "$num_equipo" || "$last" -gt 254 ]];then
			error "Error: valor no válido, se esperaba un número entre $num_equipo y 254";continue
		else
			dirip=$dirip/$last;return 0
		fi
	done	
}

clear
usu=$(whoami)
if [[ ! $usu = "root" ]]
then
	echo; read -p "Debe ejecutar el script con sudo. Pulse intro para continuar."
	exit
fi
echo; echo "Actualizando el repositorio. Por favor espere... "
#apt update -y  &> /dev/null
if [[ "$?" -gt 0 ]]
then
	echo; read -p "Ha habido un problema con la actualización del sistema. Revise la configuración IP. Pulse intro para continuar."
	exit
fi

clear
echo "---------------------------"
echo;echo "INSTALACIÓN SERVIDOR NFS"
echo "---------------------------"
echo "[1] Servidor principal"
echo "[2] Servidor destino"
echo "[3] Salir"
while true
do
	echo; read -p "Escoja una opción [1-3]: " opc
	case "$opc" in
		"")echo; read -p "No ha introducido nada. Pulse intro para continuar."; continue;;
		1)instalarServicio
		  while true;do
			  comprobarRecurso
			  compartirRecurso
			  exportarRecurso
			  if [[ "$?" -eq 50  ]];then
				continue
			  fi
			  break
		  done;;
		2)instalarServicio
		  puntoMontaje
		  tareaProgramada
		  exit;;
		3) sh salir.sh;;
		*) echo; read -p "Opción incorrecta. Pulse intro para continuar"; continue;;
	esac
done
