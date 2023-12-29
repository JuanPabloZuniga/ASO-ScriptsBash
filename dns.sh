#!/bin/bash
function mensaje(){
	echo;read -p "ERROR: $1. Pulse intro para continuar"
}
function zonas(){
while true
do	
	clear
	echo
	echo "============================================"
	echo "1. Crear zona maestra de resolución directa"
	echo "2. Añadir registros zona maestra de resolución directa"
	echo "3. Crear zona maestra de resolución inversa"
	echo "4. Añadir registros zona maestra de resolución directa"
	echo "5. Borrar zona"
	echo "6. Ver estado"
	echo "7. Salir"
	echo "============================================"
	echo
	echo; read -p "Indique una opción [1-7]: " op2
	case "$op2" in
		"")mensaje "no ha introducido nada";continue;;
		1)directa 100 local 3 A;;
		2)Rdirecta;;
		3)directa 200 127 2 PTR .in-addr.arpa.;;
		4)Rdirecta;;
		5)Bzonas;;
		6)sudo systemctl status bind9;Binversa;;
		7)sh salir.sh
		if [[ "$?" -eq 100 ]]
		then
			exit
		else
			continue 2
		fi;;
		*)mensaje "valor no válido";continue;;
	esac
done
}

function directa(){
while true
do
	echo;read -p "Indique un nombre para la zona: " nombre
	if [[ "$nombre" = "" ]]
	then
	 	mensaje "no ha introducido nada"
	 	continue
	else
		nombre=`echo "$nombre" | sed "s/  *//g"`
	 	grep -Eiq "$nombre" /etc/bind/named.conf.local
		if [[ "$?" -eq 0 ]]
		then
			mensaje "La zona ya existe"
			continue
		else
			nomEquipo=`hostname`
			if [[ "$1" -eq 100 ]]
				then
					zona=`echo "zone" "\"$nombre\""`
					file=`echo "file" "\"/etc/bind/db.$nombre\""`
				else
					zona=`echo "zone" "\"$Ip3-in-addr.arpa\""`
					file=`echo "file" "\"/etc/bind/db.$Ip3\""`
			fi
			echo "$zona {" >> /etc/bind/named.conf.local
			echo "	type master;" >> /etc/bind/named.conf.local
			echo "	$file;" >> /etc/bind/named.conf.local
			echo "};" >> /etc/bind/named.conf.local
			cp -r /etc/bind/db."$2" /etc/bind/db."$nombre"
			grep -En  "." /etc/bind/db."$nombre" > numerodeZona.txt
			nLinea=`grep -E "SOA" numerodeZona.txt | cut -f1 -d ":"`
			sed -i "$nLinea d" /etc/bind/db."$nombre"
			sed -i "$nLinea i\@	IN	SOA	$nomEquipo.$nombre. admin.$nombre. (" /etc/bind/db."$nombre"
			nTotal=`cat /etc/bind/db."$nombre" | wc -l`
			nTotal2=$((nTotal - $3))
			sed -i "$nTotal2,$nTotal d" /etc/bind/db."$nombre"
			echo "@	IN	NS	$nomEquipo.$nombre." >> /etc/bind/db."$nombre"
			echo "$nombre$5	IN	$4	$Ip" >> /etc/bind/db."$nombre"
			systemctl restart bind9
			cat /etc/bind/db."$nombre"
			echo; read -p "Zona creada con éxito. Pulse intro para continnuar"
			break
		fi
	fi
done
}
function Bzonas(){
 while true
 do
 	clear
 	grep -Ei "^zone" /etc/bind/named.conf.local | cut -f2 -d " " | sed "s/\"//g" | grep -En "." > zonas.txt
 	zTotal=`cat zonas.txt | wc -l`
 	if [[ "$zTotal" -eq 0 ]]
 	then
 		mensaje "no hay zonas creadas para borrar"
 		return 0
 	else
	 	cat zonas.txt
	 	while true
	 	do
		 	echo; read -p "Indique el número de la zona que desea borrar [1-$zTotal]: " op3
		 	if [[ "$op3" = "" ]]
		 	then
		 		mensaje "No ha introducido nada"
		 		continue
		 	elif [[ "$op3" -ge 1 && "$op3" -le "$zTotal" ]]
		 	then
		 		nomZona=`grep -E "^$op3:" zonas.txt | cut -f2 -d ":"`
		 		nomZona2=`grep -A 1 "$nomZona" zonas.txt | tail -1 | cut -f2 -d ":"`
		 		num1=`grep -En "." /etc/bind/named.conf.local | grep -Ei "$nomZona" | head -1 | cut -f1 -d ":"`
		 		num2=`grep -En "." /etc/bind/named.conf.local | grep -Ei "$nomZona2" | head -1 | cut -f1 -d ":"`
		 		num2=$((num2 - 1))
		 		sed -i "$num1,$num2 d" /etc/bind/named.conf.local
		 		cat /etc/bind/named.conf.local
		 		sudo rm -r /etc/bind/db."$nomZona" > /dev/null 2> /dev/null
		 		echo; read -p "Zona borrada correctamente. Pulse intro para continuar"
		 		return 0
		 	else
		 		mensaje "Valor no válido"
		 		continue
		 	fi
	 	done
	 fi
 done
}
 function Rdirecta(){
 	while true
 	do
 	zTotal2=`cat zonas.txt | wc -l`
 	if [[ "$zTotal2" -eq 0 ]]
 	then
 		mensaje "no hay zonas creadas para trabajar"
 		break
 	else
	 	cat zonas.txt
 		echo; read -p "Indique el número de la zona con la que desea trabajar [1-$zTotal2]: " op6
	 	if [[ "$op6" = "" ]]
	 	then
	 		mensaje "No ha introducido nada"
	 		continue
	 	elif [[ "$op6" -le "$zTotal2" && "$op6" -ge 1 ]]
	 	then
	 		read -p "$op6"
	 		nombreZona=`grep -E "^$op6:" zonas.txt | cut -f2 -d ":"`
	 		read -p "$nombreZona"
	 		break
	 	else
	 		mensaje "Valor no válido"
	 		continue
	 	fi
	 fi
 	done
 	while true
 	do
	 	echo; read -p "Introduzca el nombre de equipo que desea añadir al registro [c] para cancelar: " nomE
	 	if [[ "$nomE" = "" ]]
	 	then
	 		mensaje "no ha introducido nada"
	 	elif [[ "$nomE" =~ ^[Cc]$ ]]
	 	then
	 		exit
	 	else
	 		break
	 	fi
 	done
 	while true
 	do
	 	echo; read -p "Introduzca la ip del $nomE [c] para cancelar: " IpE
	 	if [[ "$nomE" = "" ]]
	 	then
	 		mensaje "no ha introducido nada"
	 		continue
	 	elif [[ "$nomE" =~ ^[Cc]$ ]]
	 	then
	 		exit
	 	#elif [[ "$ipE" =~ ([0-9]{1,3}\.){3}[0-9]{1,3} ]]
	 	#then
	 	#	break
	 	else
	 	#	mensaje "formato de Ip incorrecta"
	 	#	continue
	 	break
	 	fi
 	done
 	echo "$nomE\.	IN	A	$IpE" >> /etc/bind/db.$nombreZona
 	cat  /etc/bind/db.$nombreZona
 	echo; read -p "Zona añadida con éxito. Pulse intro para continuar"
 }
Ip=`ip a | grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}/24" | cut -f1 -d "/"`
red=`hostname -I | cut -f1-3 -d "." | sed "s/\./ /g"`
set $red
Ip3="$3.$2.$1"
Ip4="$4.$3.$2.$1"
clear
sudo systemctl status bind9 > /dev/null
if [[ "$?" -eq 0 ]]
then
	while true
	do
		echo; read -p "EL servicio ya está instalado. ¿Desea continuar? [SN]: " op4
		if [[ "$op4" = "" ]]
		then
			mensaje "No ha introducido nada"
			continue
		elif [[ "$op4" =~ ^[sS] ]]
		then
			zonas
		elif [[ "$op4" =~ ^[nN]$ ]]
		then
			exit
		else
			mensaje "Valor incorrecto"
			continue
		fi
	done
else
	redT=`cat /etc/netplan/01-network-manager-all.yaml | wc -l`
	if [[ "$redT" -lt 5 ]]
		then
			mensaje "No se dispone de un IP estática."
		else
		while true
		do
		clear
		echo; read -p "Se va a proceder a la instalación del servicios DNS ¿Desea continuar[SN]?: " op1
			case "$op1" in
				"")mensaje "no ha introducido nada";continue;;
				s|S)echo;echo "Por favor, espere"
				    sudo apt update -y > /dev/null 2> /dev/null
				    #sudo apt upgrade -y > /dev/null 2> /dev/null
				    sudo apt install bind9 -y > /dev/null 2> /dev/null
				    echo; read -p "Instalación existosa. Pulse intro para continuar"
				    zonas;;
				n|N)exit;;
				*)mensaje "valor incorrecto";continue;;
			esac
		done
	fi
fi
