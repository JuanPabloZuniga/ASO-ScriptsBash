#!bin/bash
function error (){ #error generico
	echo;read -p "Error: $1. Pulse intro para continuar"
}
while true; 
do
	read -p "Desea salir del programa [S,N]: " sino
		
	case "$sino" in 
		"")error "No ha introducido datos" ;;
		[sS]) exit 100;;
		n|N) exit;;
		*) error "Se esperaba s o n";;
	esac
done
