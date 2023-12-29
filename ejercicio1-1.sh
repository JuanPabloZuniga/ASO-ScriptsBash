#!bin/bash
function error (){
	echo;read -p "Error: $1. Pulse intro para continuar"
}
function pulse (){
	echo;read -p "$1. Pulse intro para continuar"
}
function nusuarios(){
while true; 
do
	numero=`grep -Ei "^.*:x:1[0-9]{3}:" /etc/passwd | sed "1d" | wc -l`
	if [[ "$numero" -eq 0 ]]
	then
		echo;echo "Solo hay un usuario y ha sido creado durante la instalacion cuyo nombre es: $USER"
	else
		echo;echo "Hay $numero usuarios creados en el sistema por nosotros:"
		echo; grep -Ei "^.*:x:1[0-9]{3}:" /etc/passwd | cut -f "1" -d ":" | sed "1d"
	fi
	while true
	do
		echo; read -p "Desea volver [S,N]: " sino
		if [[ "$sino" = "" ]]
		then 
			error "no ha introducido nada"
			continue
		elif  [[ "$sino" =~ ^[Ss]$ ]]
		then
			return 0
		elif  [[ "$sino" =~ ^[Nn]$ ]]
		then
			continue 2
		else
			error "se esperaba s o n"
		fi
	done
done
}
function crearBorrar(){
while true
do
	echo; read -p "Indique el nombre de usuario que desea $1 [c] para cancelar: " op2
	if [[ "$op2" = "" ]]
	then
		error "no ha introducido nada"
		continue
	elif [[ "$op2" =~ ^[cC]$ ]]
	then
		return 0
	fi
	if [[ "$num" -eq 10 ]]
	then
		grep -Eiq "$op2" /etc/passwd
		if [[ "$?" -eq 1 ]]
		then
			useradd "$op2" -p "" -m
			passwd -e "$op2" &> /dev/null
			echo; read -p "Usuario creado. Pulse intro para continuar"
			break
		else
			error "El usuario indicado $2"
			continue
		fi
	else [[ "$num" -eq 20 ]]
		grep -Eiq "$op2" /etc/passwd
		if [[ "$?" -eq 0 ]]
		then
			userdel "$op2"
			rm -r /home/"$op2" &> /dev/null
			echo; read -p "Usuario borrado. Pulse intro para continuar"
			break
		else
			error "El usuario indicado $2."
			continue
		fi
	fi
done
}
function nCompleto(){
while true
do
	echo; read -p "Indique el nombre completo del usuario [Apellido1 APellido2,Nombre][c para cancelar]: " op4
	if [[ "$op4" = "" ]]
	then
		error "No ha introducido nada"
		continue
	elif [[ "$op4" =~ ^[cC]$ ]]
	then
		return 0
	elif [[ "$op4" =~ ^[A-Z][a-z]+\ [A-Z][a-z]*,[A-Z][a-z]*$ ]]
	then
		op4=`echo "$op4" | sed "s/,/ /"`
		set $op4
		nombreCompleto="$3$1$2"
		grep -Ei "$nombreCompleto" /etc/passwd
		if [[ "$?" -eq 0 ]]
			then
			while true
			do
				echo; read -p "$op3 ya existe, ¿desea borrar el usuario $op3?[SN] [c] para cancelar: " op5
				if [[ "$op5" =~ ^[sS]$ ]]
					then
						userdel "$op3"
						rm -r /home/$op3 &> /dev/null
						"usuario borrado con exito" pulse
						break
					elif [[ "$op5" =~ ^[nN]$ ]]
					then
						return 0
					elif [[ "$op5" =~ ^[cC]$ ]]
					then
						return 0
					else
						error "se esperaba S o n"
						continue
				fi
			done
		elif [[ "$?" -eq 1 ]]
			then
			while true
			do
				echo; read -p "El usuario $op3 no existe. ¿Desea crearlo?[SN] [c] para cancelar: " op6
				if [[ "$op6" = "" ]]
				then
					error "No ha introducido nada"
					continue
				elif [[ "$op6" =~ ^[sS] ]]
				then
					useradd -m -p "" "$nombreCompleto"
					passwd -e "$nombreCompleto" &> /dev/null
					echo; read -p "Usuario creado con exito. Pulse intro para continuar"
					return 0
				fi
			done
		fi
	else
		error "Formato de nombre incorrecto"
		continue
	fi
done
}
function dsdArchivo(){
	while true
	do
		echo;read -p "¿Desea añadir usuarios [a] o borrar usuarios [b]? [c para cancelar]: " op7
		if [[ "$op7" = "" ]]
		then
			error "no ha introducido nada"
			continue
		elif [[ "$op7" =~ ^[cC]$ ]]
		then
			return 0
		elif [[ "$op7" =~ ^[aA]$ ]]
		then
			num=30
			ArchivoAB
			return 0
		elif [[ "$op7" =~ ^[bB] ]]
		then
			num=40
			ArchivoAB
			return 0
		else
			error "se esperaba a o b"
			continue
		fi
	done
}
function ArchivoAB(){
if [[ "$num" -eq 30 ]]
then
	while true
	do
		echo; read -p "Indique los nombres de usuario que desea añadir [c] para cancelar: " nombres
		if [[ "$nombres" = "" ]]
		then
			error "no ha introducido nada"
			continue
		elif [[ "$nombres" = ^[cC]$ ]]
		then
			return 0
		else
			for nombres in $nombres
			do
				while true
				do
					echo; read -p "Indique el nombre completo del usuario $nombres: [Apellido1 APellido2,Nombre] [c] para cancelar: " completo
					if [[ "$completo" = "" ]]
					then
						error "no ha introducido nada"
						continue
					elif [[ "$completo" =~ ^[cC]$ ]]
					then
						return 0
					elif [[ "$completo" =~ ^[A-Z][a-z]+\ [A-Z][a-z]*,[A-Z][a-z]*$ ]]
						then
							useradd -c "$completo" "$nombres" -m -p "" &> /dev/null
							if [[ "$?" -eq 9 ]]
							then
								echo -e "USUARIOS CREADOS\n -$nombres\n" > nocreados.txt
							else [[ "$?" -eq 0 ]]
								echo -e "USUARIOS NO CREADOS\n -$nombres\n" > creados.txt
							fi
							passwd -e "$nombres" &> /dev/null
							break
					else
							read -p "mal"
							continue
					fi
				done
			done
		fi
		echo; cat nocreados.txt creados.txt
		echo; read -p "Operación completada con exito. Pulse intro para continuar"
		rm -r nocreados.txt creados.txt
		return 0
	done
elif [[ "$num" -eq 40 ]]
then
	while true
	do
		echo; read -p "Indique los nombres de usuario que desea borrar [c] para cancelar: " nombres
		if [[ "$nombres" = "" ]]
		then
			error "no ha introducido nada"
			continue
		elif [[ "$nombres" =~ ^[cC]$ ]]
		then
			return 0
		else
			for nombres in $nombres
			do
				while true
				do
					echo; read -p "Indique el nombre completo del usuario $nombres: [Apellido1 Apellido2,Nombre] [c] para cancelar: " completo
					if [[ "$completo" = "" ]]
					then
						error "no ha introducido nada"
						continue
					elif [[ "$completo" =~ ^[cC]$ ]]
					then
						return 0
					elif [[ "$completo" =~ ^[A-Z][a-z]+\ [A-Z][a-z]*,[A-Z][a-z]*$ ]]
						then
							userdel "$nombres" &> /dev/null
							rm -r /home/"$nombres" &> /dev/null
							if [[ "$?" -eq 0 ]]
							then
								echo -e "USUARIOS ELIMINADOS\n -$nombres\n" > nocreados.txt
							else [[ "$?" -eq 6 ]]
								echo -e "USUARIOS NO ELIMINADOS\n  -$nombres\n" > creados.txt
							fi
							break
					else
						read -p "mal"
						continue
					fi
				done
			done
		fi
		echo; cat nocreados.txt creados.txt
		echo; read -p "Operación completada. Pulse intro para continuar"
		rm -r nocreados.txt creados.txt
		return 0
	done
fi
}

while true
do
	clear
	echo
	echo "********* EJERCICIO 1 REPASO *********"
	echo
	echo "1) Número de usuarios del sistema"
	echo "2) Añadir usuarios al sistema"
	echo "3) Borrar usuarios del sistema"
	echo "4) Gestionar usuario desde nombre completo"
	echo "5) Gestionar usuarios desde archivo"
	echo "6) Salir"
	echo;read -p "Escoja una opción: [1-6] [c] para cancelar: " op
	case "$op" in
		"")error "no ha introducido nada";continue;;
		1)nusuarios;;
		2)num=10;crearBorrar "crear" "ya existe" "creado";;
		3)num=20;crearBorrar "borrar" "no existe" "borrado";;
		4)nCompleto;;
		5)dsdArchivo;;
		6)sh salir.sh
			if [[ "$?" -eq 100 ]]
			then
				exit
			else
				continue 2
			fi;;
		c|C)exit;;
		*)error "se esperaba un número entre 1 y 6";continue;;
	esac
	
done
