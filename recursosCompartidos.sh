#!/bin/bash/

function error() {
	echo; read -p "ERROR: $1. Pulse intro para continuar"
}

root=`whoami`
if [[ ! "$root" = root ]]
then
	error "el script debe ejecutarse con sudo"
	exit
fi

function listar() {
	echo; echo "Recursos compartidos actualmente"
	grep -Ei "^\[" /etc/samba/smb.conf | cut -f 2 -d "[" | cut -f 1 -d "]" | grep -n "." | sed "s/:/: /g" > compartidos.txt
	echo; cat compartidos.txt
	if [[ "$num" -eq 1 ]]
	then
		echo; read -p "Pulse intro para continuar"
		rm compartidos.txt
		return 0
	else
		total=`cat compartidos.txt | wc -l`
		while true
		do
			echo; read -p "Escoja una opción entre 1 y $total: " op2
			if [[ "$op2" = "" ]]
			then
				error "no ha introducido nada"
				continue
			elif [[ ! "$op2" =~ ^[0-9]+$ ]]
			then
				error "se esperaba un número entre 1 $total"
				continue
			elif [[ "$op2" -lt 1 || "$op2" -gt "$total" ]]
			then
				error "se esperaba un número entre 1 y $total"
				continue
			else
				recurso=`grep -E "$op2" compartidos.txt | cut -f 2 -d ":" | sed "s/ //g"`
				inicio=`grep -Ein "^\[$recurso\]$" /etc/samba/smb.conf | cut -f 1 -d ":"`
				final=`grep -En "^\[" /etc/samba/smb.conf | grep -A 1 $inicio | tail -1 | cut -f 1 -d ":"`
				if [[ $final -eq $inicio ]]
				then
					final=`cat /etc/samba/smb.conf | wc -l`
				else
					let final--					
				fi
				
				sed -i "$inicio,$final d" /etc/samba/smb.conf
				echo; read -p "Recurso borrado correctamente. Pulse intro para continuar"
				return 0
			fi
		done
	fi
}

function crear() {
	while true
	do
		echo; read -p "Indique el nombre del recurso compartido [c para cancelar]:  " nombre
		if [[ "$nombre" = "" ]]
		then
			error "no ha introcudio nada"
			continue
		elif [[ "$nombre" =~ ^[Cc]$ ]]
		then
			return 0
		else
			grep "^\[$nombre\]$" /etc/samba/smb.conf > /dev/null 2> /dev/null
			if [[ "$?" -eq 0 ]]
			then
				error "ya existe un recursos compartido con este nombre"
				continue
			fi
			
			while true
			do
				echo; read -p "Indique la ruta ABSOLUTA del recurso compartido [c para cancelar]: " ruta
				grep -E "^path = $ruta$" /etc/samba/smb.conf > /dev/null 2> /dev/null
				if [[ "$?" -eq 0 ]]
				then
					error "el recurso ya está compartido"
					continue
				elif [[ "$ruta" =~ ^[Cc]$ ]]
				then
					return 0
				else
					echo "[$nombre]" >> /etc/samba/smb.conf
					echo "        path = $ruta" >> /etc/samba/smb.conf
					echo "        browseable = yes" >> /etc/samba/smb.conf
					echo "        writeable = yes" >> /etc/samba/smb.conf
					systemctl restart smbd.service > /dev/null
					echo; testparm
					echo; read -p "Recurso compartido correctamente. Pulse intro para continuar"
					return 0
				fi
			done
		fi
	done
}

function salir(){
while true
do
	echo; read -p "Desea salir del programa [SN]: " salir
	case "$salir" in
		"")error "no ha introducido nada"; continue;;
		[Ss])return 100;;
		[Nn])return;;
		*)error "valor no válido"; continue;;
		
	esac
done
}

while true
do
	clear
	echo "******************************************"
	echo "     GESTIONAR RECUROSOS COMPARTIDOS"
	echo "******************************************"
	echo "  1. Listar recursos compartidos"
	echo "  2. Crear recurso compartido"
	echo "  3. Borrar recuro compartido"
	echo "  4. Salir"
	echo "******************************************"
	while true
	do
		echo; read -p "Escoje una opción [1-4]: " op
		case "$op" in
			"")error "no ha introducido nada"; continue;;
			1)num=1; listar; continue 2;;
			2)crear; continue 2;;
			3)num=2; listar; continue 2;;
			4)sh salir.sh
			if [[ "$?" -eq 100 ]]
			then
				exit
			else
				continue 2 
			fi;;
			*)error "se esperaba un número entre 1 y 4"; continue;;
		esac
	done
done
