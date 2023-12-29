#!bin/bash
clear
while true
do
	echo; read -p "Qué usuario desea crear: " usuario
	grep -Ei "^$usuario:" /etc/passwd > /dev/null
	if [[ $? -eq 0 ]]
	then
		echo "Error, el usuaro $usuario ya existe en el sistema"
	else
	sudo useradd $usuario
	fi
		while true
		do
		echo; read -p "Desea crear otro usuario [SN]: " sino
		if [[ "$sino" = "" ]]
		then
			echo "No ha introducido nada"
			continue
		elif [[ "$sino" =~ ^[sS]$ ]]
		then
			continue 2
		elif [[ "$sino" =~ ^[Nn]$ ]]
		then
			exit
		fi
		done
done

grep -Ei "$usuario" /etc/passwd
