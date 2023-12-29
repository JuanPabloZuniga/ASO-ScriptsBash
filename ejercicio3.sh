#!/bin/bash
while true
do
	echo;read -p "Introduzca las dimensiones de la tabla: " a
	if [[ "$a" = "" ]]
		then
			echo; read -p "Usted no ha indicado nada. Pulse intro para continuar"
			continue
		elif [[ ! "$a" =~ ^[0-9]+$ ]]
		then
			echo;read -p "Usted ha introducido letras, vuélvalo a intentar. Pulse intro para continuar"
			continue
	fi
while true
do	
	echo;read -p "Introduzca el simbolo que desea: " simbolo
	if [[ "$simbolo" = "" ]]
		then
			echo; read -p "Usted no ha indicado nada. Pulse intro para continuar"
			continue
		elif [[ ! "$simbolo" =~ [0-9a-Z] ]]
		then
			echo;read -p "Usted no ha introducido un simbolo, vuélvalo a intentar. Pulse intro para continuar"
			continue
	fi
	break
	
	
	for i in `seq $a`
	do
		for j in `seq $a`
		do
			echo -n "$simbolo"
		done
	done
		echo
	done
	sh salir.sh
	if [[ "$?" -eq 100 ]]
		then
		exit
	fi 
	done
done
