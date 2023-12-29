#!/bin/bash
function error(){
	echo; read -p "ERROR: $1. Pulse intro para continuar"
}
function salir(){
while true
do
	echo; read -p "¿Desea salir del programa? [SN]: " op2
	if [[ "$op2" = "" ]]
	then
		error "no ha introducido nada"
		continue
	elif [[ "$op2" =~ ^[sS]$ ]]
	then
		exit
	elif [[ "$op2" =~ ^[nN]$ ]]
	then	
		break
	else
		error "se esperaba un valor válido"
		continue
	fi
done
}
function Tarea(){
	while true
	do
		echo "$minuto $hora $dia $mes $diaS $op3" >> TareaProgramadas.txt
		echo; read -p "¿Desea crear otra tarea? [SN] [c] para cancelar: " op4
		if [[ "$op4" = "" ]]
		then
			error "no ha introducido nada"
		elif [[ "$op4" =~ ^[cC]$ ]]
		then
			exit
		elif [[ "$op4" =~ ^[sS]$ ]]
		then
			return 0
		elif [[ "$op4" =~ ^[nN]$ ]]
		then
			sudo crontab TareaProgramadas.txt
			sudo crontab -l
			echo; read -p "Tarea creada con éxito. Pulse intro para continuar"
			exit
		else
			error "se esperaba un valor válido"
		fi
	done
	
}
function rutaComando(){
while true
do
	while true
	do
		echo; read -p "Introduzca $1 [c] para cancelar: " op3
		if [[ "$op3" = "" ]]
		then
			error "no ha introducido nada"
		elif [[ "$op3" =~ ^[cC]$ ]]
		then
			exit
		elif [[ "$2" -eq 10  ]]
		then
			if [[ ! -f "$op3" ]]
			then
				error "fichero no encontrado"
			else
				read -p "1"
				Tarea
				return 0
			fi
		elif [[ "$2" -eq 20 ]]
		then
			$op3 > /dev/null 2> /dev/null
			if [[ "$?" -eq 0 ]]
			then
				read -p "2"
				Tarea
				return 0
			else
				error "comando no válido"
			fi
		else
			
			error "formato no válido"
		fi
	done
	
done
}
function crear(){
#pedir la hora en formato hh:mm y los dias dd,dd-mm,mm o también se puede permitir 12-* o *-3
	while true
	do
		echo; read -p "Indique en qué $1 desea realizar la tarea, ['*' para cada $1] [c] para cancelar: " valor
		if [[ "$valor" =~ ^[cC]$ ]]
		then
			exit
		elif [[ "$valor" = "" ]]
		then
			error "No ha introducido nada"
		elif [[ "$valor" =~ ^\*$ ]]
		then
			return 0
		elif [[ "$valor" -lt $2 || "$valor" -gt $3 || ! "$valor" =~ ^[0-9]+$ ]]
		then
			error "Se esperaba un valor válido"
		else
			return 0
		fi
	done
}
function crearTarea(){
	while true
	do
		echo; read -p "¿Desea ejecutar la ruta de un script [r] o comando [c]? [s] para salir: " ScriptComando
		if [[ "$ScriptComando" = "" ]]
		then
			error "no ha introducido nada"
		elif [[ "$ScriptComando" = ^[sS]$ ]]
		then
			exit
		elif [[ "$ScriptComando" =~ ^[rR]$ ]]
		then
			
			rutaComando "la ruta absoluta del archivo" 10
			return 0
		elif [[ "$ScriptComando" =~ ^[cC]$ ]]
		then
			rutaComando "un comando válido" 20
			return 0
		else
			error "se esperaba un valor válido"
		fi
	done
	
}

function borrar(){
while true
do
	total=`cat TareaProgramadas.txt | wc -l`
	cat TareaProgramadas.txt | grep -En "." > listado.txt
	echo; cat listado.txt
	echo; read -p "Escoja la tarea que desea borrar: [1- $total] [c] para cancelar: " op5
	if [[ "$op5" = "" ]]
	then
		error "no ha introducido nada"
	elif [[ "$op5" =~ ^[cC]$ ]]
	then
		exit
	elif [[ "$op5" -lt 1 || "$op5" -gt $total ]]
	then
		error "se esperaba un número entre 1 y $total"
	elif [[ "$op5" =~ [a-Z] ]]
	then
		error "formato incorrecto"
	else
		sed -i "$op5 d" TareaProgramadas.txt
		sudo crontab TareaProgramadas.txt
		echo; echo "Archivo borrado con exito..."
		while true
		do
			echo; read -p "Desea borrar otra tarea [SN] [c] para cancelar: " op6
			if [[ "$op6" = "" ]]
			then
				error "no ha introducido nada"
				continue
			elif [[ "$op6" =~ ^[sS]$ ]]
			then
				continue 2
			elif [[ "$op6" =~ ^[nN]$ ]]
			then
				echo; sudo crontab -l
				exit
			fi
		done
	fi
done
}

while true
do	
	clear
	echo; read -p "¿Desea crear [c] o borrar [b] una tarea? [s] para salir: " op1
	case "$op1" in
		"") error "no ha introducido nada";continue;;
		s|S)salir;;
		c|C)crear hora 0 23 
		hora="$valor"
		crear minuto 0 59
		minuto="$valor"
		crear "dia del mes" 1 31
		dia="$valor"
		crear "mes" 1 12
		mes="$valor"
		crear "dia de la semana" 0 6
		diaS="$valor"
		crearTarea
		;;
		b|B)borrar;;
		*)error "se esperaba un valor válido";continue;;
	esac
done
