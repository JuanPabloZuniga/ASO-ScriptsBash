#!/bin/bash 
function error(){
	echo; read -p "$1 incorrecto, pulse intro"
}

function pedirDigito {
	while true
	do
		echo; read -p "Introduzca $1 digito [x para cancelar]: " dig
		if [[ "$dig" = "" ]]
		then
			error "valor"
			continue
		elif [[ "$dig" =~ [xX] && "$cont" -eq 0 ]]
		then
			exit
		elif [[ "$dig" =~ [xX] ]]
		then
			mostrarResultado
			exit
		elif [[ ! "$dig" =~ ^[0-9]+$ ]]
		then
			error "valor"
			continue
		else
			return 0
		fi	
	done
}
function continuar(){
	while true
	do
		read -p "Desea realizar mas operaciones [S,N]: " more
		case "$more" in
			s|S) return 0;;
			n|N) mostrarResultado;;
			*) echo; read -p "Escoja S o N, pulse intro para continuar";;
		esac
	done
}

function mostrarResultado(){
	echo;echo "$operacion = $a"; echo
		
}
cont=0

clear; echo
echo "1) +"
echo "2) -"
echo "3) *"
echo "4) /"
echo "5) Salir"
while true
do	
	echo;read -p "Que operacion desea realizar [1-5]: " num
	case "$num" in 
		1)op="+";;
		2)op="-";;
		3)op="*";;
		4)op="/";;
		5) sh salir.sh
		if [[ "$?" -eq 100 ]]
		then
			exit
		fi;;
		*) echo; read -p "opcion incorrecta, pulse intro"
		continue;;
	esac
	if [[ "$cont" -eq 0 ]]
	then
		pedirDigito "el primer"
		num1=$dig
		pedirDigito "el segundo"
		let a=$num$op$dig
		operacion="$num1 $op $dig"
		let cont++
	else
		pedirDigito "otro"
		let a$op=$dig
		operacion="$operacion $op $dig"
	fi
	continuar	
done

