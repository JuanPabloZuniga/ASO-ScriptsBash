#!/bin/bash

min=100

if [[ "$#" -eq 0 ]]
then
	echo;read -p "se esparaban parámetos posicionales"
	exit
fi

for a
do
	if [[ ! "$a" =~ ^[0-9]+$ ]]
	then
		echo; echo "$a no es un valor valido, se esperaba un numero entre 1 y 99."
		continue
		
	elif [[ "$a" -eq 0 || "$a" -ge 100 ]]
	then
		echo; echo "No se admite el numero $a en el calculo del menor numero, se esperaba un valor entre 1 y 99."
		continue
	elif [[ "$a" -lt "$min" ]]
	then
		min=$a
	fi
done
if [[ "$min" -eq 100 ]]
then
	echo; read -p "ninguno de los valores introducidos es valido. No se puede mostrar un minimo"
	else
	echo; read -p "El valor menor es $min"
fi
echo;



