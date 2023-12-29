#!bin/bash
function error (){ #error hgenerico
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
		sh salir.sh
		if [[ "$?" -eq 100 ]] 
		then 
			echo; exit
	fi
done
