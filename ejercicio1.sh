#!bin/bash
function error (){
	echo;read -p "Error: $1. Pulse intro para continuar"
}
while true; 
do
	numero=`grep -Ei "^.*:x:1[0-9]{3}:" /etc/passwd | sed "1d" | wc -l`
	if [[ "$numero" -eq 0 ]]
	then
		echo;echo "Solo hay un usuario y ha sido creado durante la instalacion cuyo nombre es: $USER"
	else
		echo;echo "hay $numero usuarios creados en el sistema por nosotros"
		grep -Ei "^.*:x:1[0-9]{3}:" /etc/passwd | cut -f "1" -d ":" | sed "1d"
	fi
	while true
	do
		read -p "Desea salir del programa [S,N]: " sino
		if [[ "$sino" = "" ]]
		then 
			error "no ha introducido nada"
			continue
		elif  [[ "$sino" =~ ^[Ss]$ ]]
		then
			exit
		elif  [[ "$sino" =~ ^[Nn]$ ]]
		then
			continue 2
		else
			error "se esperaba s o n"
		fi
	done
done
