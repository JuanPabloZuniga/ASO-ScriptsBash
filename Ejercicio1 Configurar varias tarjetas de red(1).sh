#!/bin/bash
function mensaje() {
	echo; read -p "$1. Pulse una tecla para continuar"
}


function estadoActualTarjeta () {
	lInicial=`grep -Ein "$tarjetatrabajo" /etc/netplan/$archivo | cut -f 1 -d ":" | sed "s/ //g"`
	
	if [[ ! $lInicial = "" ]]
	then
		let lFinal=$lInicial+3
		echo; echo "Configuración actual de la tarjeta [$tarjetatrabajo]:"
		grep -Ein "." /etc/netplan/$archivo > netplan_num.txt
		echo
		for (( i=$lInicial; i<=$lFinal; i++ ))
		do
			grep -E "^$i" netplan_num.txt | sed "s/^[0-9][0-9]*://"
		done
		let lSiguiente=$lFinal+1
		grep -E "^$lSiguiente:         routes:" netplan_num.txt &> /dev/null
		if [[ "$?" -eq 0 ]]
		then
			encontrado="yes"
			gate=`grep -Ei "via:" /etc/netplan/$archivo | cut -f 2 -d ":"` 
			let lFinalR=$lSiguiente+2
			for (( i=$lSiguiente; i<=$lFinalR; i++ ))
		do
			grep -E "^$i" netplan_num.txt | sed "s/^[0-9][0-9]*://" >> route.txt
		done
		fi
	fi
}

function cambiarConfiguracion() {
	while true
	do
		echo; read -p "Pulse [a] para configurar la red de manera automática, [e] para configurar la red de manera estática o [c] para cancelar: " sn4
		case "$sn4" in
			"")mensaje "Error: no se ha introducido nada";;
			a|A) if [[ ! $lInicial = "" ]]
			     then
				eliminarLineas
			     else 
				echo;read -p "No se han realizado cambios. Pulse intro para continuar"
				return 100
			     fi
			     return 0;;
			e|E)if [[ ! $lInicial = "" ]]
			     then
			     	eliminarLineas
			     fi
			     ipStatic
			     if [[ $? -eq 100 ]]; then
				return 100
			     else
			     	return 0
			     fi;;
			c|C)return 100;;
			*)mensaje "Error: debe introducir a, e o c";;
		esac
	done
}

function eliminarLineas() {
	if [[ "$encontrado" = "yes" ]]
	then
		sed -i "$lInicial,$lFinalR d" /etc/netplan/$archivo 
		tLineas=`cat /etc/netplan/$archivo | wc -l`
		if [[ $tLineas -eq 5 ]]
		then
			sed -i "5d" /etc/netplan/$archivo 
		else
			cat route.txt >> /etc/netplan/$archivo
			rm route.txt
		fi 
		encontrado="no"
	else
		sed -i "$lInicial,$lFinal d" /etc/netplan/$archivo 
	fi
	
	echo; echo "Tarjeta configurada correctamente."; echo
	cat /etc/netplan/$archivo
}


function ipStatic(){
	num2="dirección IP correcta"
	num3=1
	configuracionEstatica
	if [[ $? -eq 100 ]]; then
		return 100
	fi
	dirip=$ipc
	num2="máscara correcta"
	num3=2
	configuracionEstatica
	if [[ $? -eq 100 ]]; then
		return 100
	fi
	mask=$ipc
	grep -Ei "routes:" /etc/netplan/$archivo &> /dev/null
	if [[ "$?" -eq 1 ]]
	then
		num2="puerta de enlace"
		num3=1
		configuracionEstatica
		if [[ $? -eq 100 ]]; then
			return 100
		fi
		gate=$ipc
	fi
	grep -Ei "ethernets:" /etc/netplan/$archivo &> /dev/null
	if [[ "$?" -eq 1 ]]
	then
		echo "  ethernets:" >> /etc/netplan/$archivo
	fi
	echo "       $tarjetatrabajo:" >> /etc/netplan/$archivo
	echo "         addresses: [$dirip/24]" >> /etc/netplan/$archivo
	echo "         nameservers:" >> /etc/netplan/$archivo
	echo "             addresses: [8.8.8.8, 8.8.4.4]" >> /etc/netplan/$archivo
	grep -Ei "routes:" /etc/netplan/$archivo &> /dev/null
	if [[ "$?" -eq 1 ]]
	then
		echo "         routes:" >> /etc/netplan/$archivo
		echo "             - to: default" >> /etc/netplan/$archivo
		echo "               via: $gate" >> /etc/netplan/$archivo
	fi
	netplan apply
	echo; echo "Tarjeta configurada correctamente."; echo
	cat /etc/netplan/$archivo
}

mostrarTarjetas () {
	ip a | grep -Ei "^[0-9]+:" | sed "1d" | cut -f 2 -d ":" | sed "s/ //g" | grep -Ein "." > tarjetasdisponibles_num.txt
	ip a | grep -Ei "^[0-9]+:" | sed "1d" | cut -f 2 -d ":" | sed "s/ //g" > tarjetasdisponibles.txt
	tTarjetas=`cat tarjetasdisponibles_num.txt | wc -l`
	let tTarjetas++
	echo "$tTarjetas:Salir" >> tarjetasdisponibles_num.txt 
	echo; echo "Tarjetas de red disponibles en tu sistema"
	echo; more tarjetasdisponibles_num.txt
	while true
	do
		echo; read -p "Escoja con qué tarjeta deseas trabajar [1-$tTarjetas]: " num
		if [[ ! $num =~ ^[0-9]+$ ]]
		then
			mensaje "Error: debes introducir números"
			continue
		elif [[ "$num" -gt "$tTarjetas" || "$num" -lt 1 ]]
		then
			mensaje "Error: debes introducir un número entre el 1 y $tTarjetas"
			continue
		else
			tarjetatrabajo=`grep -Ei "^$num" tarjetasdisponibles_num.txt | cut -f 2 -d ":"`
			if [[ $tarjetatrabajo = "Salir" ]];then
				rm netplan_num.txt tarjetasdisponibles.txt tarjetasdisponibles_num.txt route.txt &> /dev/null
				exit
			fi
			return 0
		fi
	done
}

configuracionEstatica () {
	while true
	do
		echo; read -p "Introduzca una $num2 para la tarjeta "$tarjetatrabajo" [c para cancelar]: " ipc
		
		if [[ "$ipc" = "" ]]
		then
			mensaje "No ha introducido nada"
			continue
		elif [[ "$ipc" =~ ^[Cc]$ ]]
		then
			return 100
		elif [[ ! "$ipc" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]
		then
			mensaje "Dirección IP con formato incorrecto"
			continue
		fi
		
		num4=`echo "$ipc" | sed "s/\./ /g"`
		set $num4
		if [[ "$num3" -eq 1 && ( ( "$4" -le 0 || "$4" -ge 255 ) || ( "$1" -le 0 || "$1" -ge 255 ) || "$2" -gt 255  || "$3" -gt 255 ) ]]
		then
			mensaje "Dirección IP no válida"
		elif [[ "$num3" -eq 2 && ( ! ( "$ipc" =~ ^(255\.){3}0$ || "$ipc" =~ ^(255\.){2}0\.0$ || "$ipc" =~ ^255\.0\.0\.0$  ) ) ]]
		then
			mensaje "Máscara no válida"
		else
			return 0
		fi
	done
}

function otro() {
	while true
	do
		echo; read -p "Desea modificar otra tarjeta de red [SN]: " sn
		case "$sn" in
			"")mensaje "Error: no se ha introducido nada";;
			s|S)clear;return 0;;
			n|N)rm netplan_num.txt tarjetasdisponibles.txt tarjetasdisponibles_num.txt;exit;;
			*)mensaje "Error: debe introducir s o n";;
		esac
	done
}

usuario=`whoami`
if [[ ! $usuario = "root" ]];then
	echo;read -p "Este script debe ser ejecutado con privilegios de administración, por favor utilice sudo al ejecutarlo. Pulse intro para continuar"
	exit
fi

archivo=`ls /etc/netplan | head -1`
while true
do
	clear
	echo; read -p "SE VA A PROCEDER A CONFIGURAR EL ARCHIVO $archivo. ¿Desea continuar? [SN]: " sn
	case "$sn" in
		"") mensaje "Error: no se ha introducido nada";;
		s|S) while true
		     do
			mostrarTarjetas
			estadoActualTarjeta
			cambiarConfiguracion
			if [[ $? -eq 100 ]];then
				clear
				continue
			fi
			otro
		     done;;
		n|N) exit;;
		*) mensaje "Error: debe introducir s o n";;
	esac
done
