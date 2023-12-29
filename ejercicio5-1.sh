#!/bin/bash

min=100

if [[ "$#" -eq 0 ]]
then
	echo;read -p "se esparaban parámetos posicionales"
	exit
fi

for a in `seq $#`
do
	if [[ ! "$1" =~ ^[0-9]+$ ]]
	then
		echo; echo "$1 no es un valor valido, se esperaba un numero entre 1 y 99."
		
	elif [[ "$1" -eq 0 || "$1" -ge 100 ]]
	then
		echo; echo "No se admite el numero $1 en el calculo del menor numero, se esperaba un valor entre 1 y 99."
	elif [[ "$a" -lt "$min" ]]
	then
		min=$1
	fi
	shift
done
if [[ "$min" -eq 100 ]]
then
	echo; read -p "ninguno de los valores introducidos es valido. No se puede mostrar un minimo"
	else
	echo; read -p "El valor menor es $min"
fi
echo;
