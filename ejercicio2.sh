#bin/bash
function error(){
	echo; read -p "Error. Lo sentimos, $1. Pulse intro para continuar..."
}
while true
do
	clear
	read -p "Que usuarios desea crear: " usuario
	grep -Ei "^$usuario:" /etc/passwd > /dev/null
	if [[ "$?" -eq 0 ]]
	then
		error "$usuario ya existe en el sistema"
	else
		sudo adduser "$usuario"
	fi
	
	while true
	do
		echo; read -p "Desea crear otro usuario [S,N] " op
		case "$op" in 
			"")error "No ha indicado ningun valor" ;;
			[sS]) continue 2;;
			n|N) exit 2;;
			*) error "Se esperaba s o n";;
		esac
	done		
done
