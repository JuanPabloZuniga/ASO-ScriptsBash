#!/bin/bash
function error(){
	echo; read -p "ERROR: $1.Pulsa intro para continuar"
}
function pregunta(){
while true
do
	echo; read -p "Por favor, indique el número de PC que desea añadir a al red $ip1 [C para cancelar]: " op2
	if [[ "$op2" =~ ^[Cc]$ ]]
	then
		return 0
	elif [[ "$op2" = "" ]]
	then
		error "no se admiten valores vacíos"
	elif [[ "$op2" =~ ^[a-Z]$* ]]
	then
		error "no se admiten letras"
		continue
	elif [[ "$op2" -le 0 || "$op2" -ge 255 ]]
	then
		error "dirección IP incorrecta"
		continue
	fi
	break
done
echo; read -p "Desea indicar un rango de equipos [sN]: " op3
while true
do
	if [[ "$op3" =~ ^[Ss]$ ]]
	then
		echo; read -p "Indique el último número de PC que desea añadir de la red $ip1 [C para cancelar]: " op4
		if [[ "$op4" =~ ^[Cc]$ ]]
		then
			return 0
		elif [[ "$op4" =~ ^[a-Z]$* ]]
		then
			error "no se admiten letras"
			continue
		elif [[ "$op4" -lt "$op2" ]]
		then
			error "valores de rango incorrecto"
			continue
		else
			ultimo="/$op4"
			permisos
		fi
	elif [[ "$op3" =~ ^[Nn]$ ]]
	then
		permisos
	else
		error "valor no valido"
		continue 
	fi
done
}
function permisos(){
while true
do
	echo; read -p "Escoja una opción 1.ro - 2.rw [c para cancelar]: " op5
	if [[ "$op5" -eq 1 ]]
	then
		p1="ro,"
		break
	elif [[ "$op5" -eq 2 ]]
	then
		p1="rw,"
		break
	elif [[ "$op5" =~ ^[Cc]$ ]]
	then
		break
	else
		error "se esperaba el número 1 o 2"
		continue
	fi
done
while true
do
	echo; read -p "Escoja una opción 1.wdelay - 2.no_wdelay [c para cancelar]: " op6
	if [[ "$op6" -eq 1 ]]
	then
		p2="wdelay,"
		break
	elif [[ "$op6" -eq 2 ]]
	then
		p2="no_wdelay,"
		break
	elif [[ "$op6" =~ ^[Cc]$ ]]
	then
		break
	else
		error "se esperaba el número 1 o 2"
		continue
	fi
done
while true
do
	echo; read -p "Escoja una opción 1.root_squash - 2.no_root_squash [c para cancelar]: " op7
	if [[ "$op7" -eq 1 ]]
	then
		p3="root_squash,"
		break
	elif [[ "$op7" -eq 2 ]]
	then
		p3="no_root_squash,"
		break
	elif [[ "$op7" =~ ^[Cc]$ ]]
	then
		break
	else
		error "se esperaba el número 1 o 2"
		continue
	fi
done
while true
do
	echo; read -p "Escoja una opción 1.sync - 2.async [c para cancelar]: " op8
	if [[ "$op8" -eq 1 ]]
	then
		p4="sync,"
		break
	elif [[ "$op8" -eq 2 ]]
	then
		p4="async,"
		break
	elif [[ "$op8" =~ ^[Cc]$ ]]
	then
		break
	else
		error "se esperaba el número 1 o 2"
		continue
	fi
done
while true
do
	echo; read -p "Escoja una opción 1.subtree_check - 2.no_subtree_check [c para cancelar]: " op9
	if [[ "$op9" -eq 1 ]]
	then
		p5="subtree_check"
		break
	elif [[ "$op9" -eq 2 ]]
	then
		p5="no_subtree_check"
		break
	elif [[ "$op9" =~ ^[Cc]$ ]]
	then
		break
	else
		error "se esperaba el número 1 o 2"
		continue
	fi
done
while true
do
	echo; read -p "Desea añadir más equipos [SN]: " op10
	if [[ "$op10" = "" ]]
	then
		error "no se admiten valores vacíos"
		continue
	elif [[ "$op10" =~ ^[Ss]$ ]]
	then
		pregunta
	elif [[ "$op10" =~ ^[Nn]$ ]]
	then
		crear
	else
		error "se esperaba s o n"
		continue
	fi
done
}
function crear(){
	echo "$recurso $ip.$op2$ultimo($p1,$p2,$p3,$p4,$p5)" >> /etc/exports
	echo "Comprobando archvios exports"
	echo "Reiniciando servicio NFS"
	systemctl restart nfs-kernel-server &> /dev/null
	echo;cat /etc/exports
	read -p "Pulse intro para continuar"
	exit
	
}
ip=`hostname -I | cut -f1-3 -d "."`
ip1="$ip.0"
while true
do	clear
	grep -Ei "^/" /etc/exports | cut -f1 -d " " | sort | uniq | grep -En "." > recursos.txt
	nTotal=`cat recursos.txt | wc -l`
	nTotal1=$((nTotal+1))
	echo "$nTotal1: Salir" >> recursos.txt
	echo "==================================================="
	echo "		   RECURSOS COMPARTIDOS"
	echo "==================================================="
	echo;cat recursos.txt
	echo "==================================================="
	echo; read -p "Por favor, escoja un recurso compartido [1-$nTotal1]: " op1
	if [[ "$op1" = "" ]]
	then
		error "no se adminten valores vacíos"
		continue
	elif [[ "$op1" -eq "$nTotal1" ]]
	then
		exit
	elif [[ "$op1" -ge 1 && "$op1" -le "$nTotal1" ]]
	then
		recurso=`grep -Ei "^$op1:" recursos.txt | cut -f2 -d ":"`
		pregunta
	else
		error "se esperaba un número entre 1 y $nTotal1"
		continue
	fi

done
