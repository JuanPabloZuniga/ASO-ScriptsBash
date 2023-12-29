#!/bin/bash
function error(){
echo; read -p "ERROR: $1 Pulse Enter para continuar..."
}
function salir(){
while true
do
	 echo; read -p "Realmente desea salir? [S-N]: " op
    	 case "$op" in
	    "")error "Vacío, Elija s o n";;
	    [sS])exit;;
	    [nN])return;;
	    *)error "Elija s o n";;
    esac
done
}
function reiniciar(){
while true
do
	echo; read -p "Desea reiniciar? [S-N]: " op
	case "$op" in
	    "")error "Vacío, Elija s o n";;
	    [sS])reboot;;
	    [nN])return;;
	    *)error "Elija s o n";;
	esac
done
}

function convertidor(){
case "$mes" in
	1)mess="Enero";;
	2)mess="Febrero";;
	3)mess="Marzo";;
	4)mess="Abril";;
	5)mess="Mayo";;
	6)mess="Junio";;
	7)mess="Julio";;
	8)mess="Agosto";;
	9)mess="Septiembre";;
	10)mess="Octubre";;
	11)mess="Noviembre";;
	12)mess="Diciembre";;
	*)mess="todos los meses";;
esac

case "$dias_semana" in
	0)dia_semana="domingo";;
	1)dia_semana="lunes";;
	2)dia_semana="martes";;
	3)dia_semana="miércoles";;
	4)dia_semana="jueves";;
	5)dia_semana="viernes";;
	6)dia_semana="sábado";;
	*)dia_semana="todos los días";;
esac

}

function crear(){
campos=("minutos" "horas" "mes" "dia_mes" "dias_semana")
valores=()

for campo in "${campos[@]}"
do
	while true
	do
		clear
		echo; echo "Creando tarea programada..."
		read -p "Elija un valor para $campo [c cancelar]: " valor
		#cancelar           
		if [[ "$valor" =~ ^[cC]$ ]]
		then
			return
		fi
		#numeros con formato y *
		if [[ ! ( "$valor" =~ ^[0-9]{1,2}$ || "$valor" =~ ^[0-9]{1,2},[0-9]{1,2}$ || "$valor" =~ ^\*$ )  ]]
		then
		  error "Introduzca números o * para todo"; continue
		fi
		#minutos
		if [[ "$campo" = "minutos" &&  ( "$valor" -gt 59 || "$valor" -lt 0 ) ]]
		then
		  error "Introduzca un valor entre 0 y 59 o * para $campo"; continue
		fi
		#horas
		if [[ "$campo" = "horas" &&  ( "$valor" -gt 23 || "$valor" -lt 0 )  ]]
		then
		  error "Introduzca un valor entre 0 y 23 o * para $campo"; continue
		fi
		#mes
		if [[ "$campo" = "mes" && ( "$valor" -gt 12 || "$valor" -lt 1 ) ]]
		then
		  error "Introduzca un valor entre 1 y 12 o * para $campo"; continue
		fi
		#dia del mes
		if [[ ${valores[2]} = "*"  && "$campo" = "dia_mes" &&  "$valor" -gt 28 || "$valor" -lt 1  ]]
		then
			error "Introduzca * o 1 a 28" ; continue
		elif [[ ( ${valores[2]} -eq 1 || ${valores[2]} -eq 3 || ${valores[2]} -eq 5 || ${valores[2]} -eq 7 || ${valores[2]} -eq 8 || ${valores[2]} -eq 10 || ${valores[2]} -eq 12  )  && "$campo" = "dia_mes" && ( "$valor" -gt 31 || "$valor" -lt 1 ) ]] 2> /dev/null
		then
		    error "Introduzca un valor entre 1 y 31 o * para $campo"; continue	
		elif [[ ( ${valores[2]} -eq 4 || ${valores[2]} -eq 6 || ${valores[2]} -eq 9 || ${valores[2]} -eq 11 )  && "$campo" = "dia_mes" && ( "$valor" -gt 30 || "$valor" -lt 1 ) ]] 2> /dev/null
		then
		  error "Introduzca un valor entre 1 y 30 o * para $campo"; continue
		elif [[ ${valores[2]} -eq 2 && "$campo" = "dia_mes" && "$bisiesto" = "si" &&  ( "$valor" -gt 29 || "$valor" -lt 1 )  ]] 2> /dev/null
		then
			  error "Introduzca 1 y 29 o * para $campo" ; continue
		elif [[  ${valores[2]} -eq 2 && "$campo" = "dia_mes" && "$bisiesto" = "no" && ( "$valor" -gt 28 || "$valor" -lt 1 ) ]] 2> /dev/null
		then
		  error "Introduzca un valor entre 1 y 28 o * para $campo"; continue
		elif [[ ${valores[2]} = "*" && "$campo" = "dia_mes" &&  ( "$valor" -gt 28 || "$valor" -lt 1 ) ]]  2> /dev/null
		then 
		  	error "Introduzca 1 a 28 dias" ; continue
		fi
		
		#dia de la semana
		if [[ "$campo" = "dia_semana" && ( "$valor" -gt 6 || "$valor" -lt 0 || ! "$valor" =~ ^\*$ ) ]]
		then
		  error "Introduzca un valor entre 0 y 6 para $campo (0 domingo)"; continue
		fi
		break
	done
	valores+=("$valor")
done

minutos=${valores[0]}
horas=${valores[1]}
mes=${valores[2]}
dia_mes=${valores[3]}
dias_semana=${valores[4]}
convertidor

while true
do
	echo; echo "Elija el comando a realizar se programará de $horas:$minutos $dia_semana $dia_mes de $mess" 
	read -p "Tambien puede incluir un script existente: " comando
	if [[ "$comando" = "" ]]
	then
		error "Vacío escriba un comando o un script existente" ; continue

	elif [[ "$comando" =~ \.sh$  ]]
	then
		echo "Comprabando si existe el archivo. Por favor espere..."
		salida="$(find ~ -type f -iname "$comando" 2> /dev/null)"
		if [[ "${#salida}" -gt 0 ]]
		then
			comando=$salida
			break
		else
			error "Sript no encontrado" ; continue
		fi
	elif command -v $comando &> /dev/null
	then
		break			
	else
		error "No existe el comando seleccionado" ; continue	
	fi
done

crontab -l >> tarea$usu.txt
echo "$minutos $horas $dia_mes $mes $dias_semana $comando" >> tarea$usu.txt
crontab tarea$usu.txt
crontab -l
rm tarea$usu.txt
echo; echo "Tarea programada correctamente para $usu"
reiniciar
}

function bisiesto(){
for i in `seq 2020 4 2034`
do
	if [[ "$i" = "$anyo" ]]
	then
		bisiesto="si"
		return
	fi
done
bisiesto="no" 
}

function borrar(){
total_tareas=`crontab -l | wc -l`
let total_tareas++
while true
do
	clear
	echo; echo "Tareas de $usu"
	crontab -l | grep -n "." && echo "$total_tareas:Salir"
	echo; read -p "Elija una tarea para eliminar [c cancelar a todas]" op
	if [[ "$op" = "" ]]
	then
		error "Vacío. Elija un número entre 1-$total_tareas"
	
		return 	
	elif [[ "$op" -eq $total_tareas ]]
	then
		return	
	
	elif [[ "$op" -gt 0 && "$op" -lt "$total_tareas" ]]
	then
		crontab -l | grep -n "." | sed "$op d" >> tborrar.txt
		crontab tborrar.txt
		rm tborrar.txt
		break	
	else
		error "Elija un número entre 1-$total_tareas"
	fi
done
echo; echo "Tarea borrada correctamente" 
reiniciar
}
usu=`whoami`
anyo=`date | awk '{print $4}'`
bisiesto
while true
do
    clear
    echo; echo "CRONTAB MANAGER de $usu"
    echo "1. Crear tarea"
    echo "2. Borrar tarea"
    echo "3. Listar tareas"
    echo "3. Salir"
    echo; read -p "Elija una opción: " op
    case "$op" in
	    "")error "Vacío, Elija un número del 1-4";;
	    1)crear;;
	    2)borrar;;
	    3)echo; crontab -l | grep -n "." ; echo; read -p "Pulse enter para continuar...";;
	    4)salir;;
	    *)error "Elija un número del 1-4";;
    esac
done    
