#!/bin/bash
function salir(){
while true
do
	echo; read -p "¿Desea salir del programa [SN]?: " op2
	case "$op2" in 
		s|S)exit;;
		n|N)return 0;;
		"")echo; read -p "ERROR: no ha introducido nada";continue;;
		*)echo; read -p "ERROR: se esperaba S o N. Pulse intro para continuar";;
	esac
done
}

function listarGruposUsuarios(){
	echo; net rpc $1
	echo; read -p "Pulse intro para continuar"
}
function listarUsuarios(){
	echo; pdbedit -Lw | cut -f1 -d ":" | grep -Ei "[^\$]$"
	echo; read -p "Pulse intro para continuar"
}
function nombre(){
	echo; echo "Obteniendo información. Por favor espere..."
	echo; grep -Ei $1 /etc/samba/smb.conf | cut -f2 -d "=" | sed "s/ //"
	echo; read -p "Pulse intro para continuar" 
}

function CrearBorrar(){
while true
do
	echo; read -p "Indique el nombre del usuario que desea crear o borrar [c para cancelar]: " nom
	if [[ "$nom" =~ [cC] ]]
	then 
		return 0
	elif [[ "$nom" = "" ]]
	then
		echo; read -p "ERROR: no ha introducido nada"
		continue
	fi
	
	pdbedit -Lw | cut -f1 -d ":" | grep -Ei "[^\$]$" | grep -Eiq "$nom"
	if [[ "$?" -eq 0 ]]
	then
		v1="ya"
		v2="borrarlo"
		v3="-x"
		
	elif [[ "$?" -eq 1 ]]
	then
		v1="NO"
		v2="crearlo"
		v3="-a"
	fi
	echo; read -p "El usuario $nom $v1 existe. Desea $v2 [s,n]: " sn
	if [[ "$sn" =~ [sS] ]]
	then
		smbpasswd $v3 "$nom"
		echo; read -p "Pulse intro para continuar"
		return 0
	elif [[ "$sn" =~ [nN] ]]
	then
		return 0
	fi
done
sudo rm usuarios.txt
}

function informacion(){
	echo; echo "Obteniendo información. Por favor espere..."
	echo; net ads info
	echo; read -p "Pulse intro para continuar"
}


function nombreCompletoDominio(){
	echo; echo "Obteniendo información. Por favor espere..."
	echo;grep -E "^127\.0(\.1){2}" /etc/hosts | cut -f2 -d " "
	echo; read -p "Pulse intro para continuar"
}

function listarGruposDeUsuario(){
	echo; echo "Introduce el password de root"
	echo;
	sudo net rpc "$1" > usuariosgrupos.txt 
	cat usuariosgrupos.txt | sed 1,2d | grep -En "." > usuariosgruposnum.txt
	
	total=`cat usuariosgruposnum.txt | wc -l`
	echo; echo "$2 DISPONIBLES"
	echo "---------------------------------"
	more usuariosgruposnum.txt
	while true
	do
		echo; read -p "Indique el numero del $3 deseado: " num3
		if [[ "$num3" = "" ]]
		then
			echo; echo "Error, no ha introducido nada"
			continue
		elif [[ ! "$num3" =~ ^[0-9]+$ ]]
		then
			echo; echo "Error, debe introducir un numero"
			continue
		elif [[ ! ( "$num3" -le  "$total" && "$num3" -gt 0 ) ]]
		then
			echo;echo "Error, debe introducir un numero entre 1 y $total"
			continue
		else
			break
		fi
	done
	
	usua=`cat usuariosgruposnum.txt | grep -E "^$num3:" | cut -f2 -d ":"`
	echo "$4 $usua"
	echo;sudo net rpc $4 "$usua"
	echo; read -p "Pulse intro para continuar"
	sudo rm usuariosgrupos.txt
	return
}

while true
do
	clear
	echo "=============================================="
	echo "		INFORMACIÓN DEL SERVIDOR"
	echo "=============================================="
	echo "  1. Visualizar nombre NETBIOS"
	echo "  2. Visualizar nombre del dominio"
	echo "  3. Visualizar nombre completo del dominio"
	echo "  4. Visualizar información del servidor"
	echo "  5. Listar usuarios de samba"
	echo "  6. Listar grupos de samba"
	echo "  7. Listar grupos de un usuario"
	echo "  8. Listar usuarios de un grupo indicado"
	echo "  9. Crear/Borrar un usuario de dominio"
	echo " 10. Salir"
	echo "=============================================="
	echo; read -p "Escoja una opción [1-10]: " op
	case $op in 
		"")echo; read -p "ERROR: no ha introducido nada. Pulse intro para continuar";continue;;
		1)nombre "workgroup";;
		2)nombre "realm";;
		3)nombreCompletoDominio;;
		4)informacion;;
		5)listarUsuarios;;
		#5)listarGruposUsuarios "user";;
		6)listarGruposUsuarios "group";;
		7)listarGruposDeUsuario "user" "USUARIOS" "usuario" "user info";;
		8)listarGruposDeUsuario "group" "GRUPOS" "grupo" "group members";;
		9)CrearBorrar;;
		10)salir;;
		*)echo; read -p "ERROR: se esperaba un número entre 1 y 10";continue;;
		
	esac
done

