function mensaje() {
	echo; read -p "$1. Pulse intro para continuar."
}

clear
function ElegirTarjeta() {
	ip a | grep -Ei "^[0-9]:" | sed "1d" | cut -f 2 -d ":" | sed "s/ //g" | grep -Ein "." > tarjetas.txt
	total=`cat tarjetas.txt | wc -l`
	echo; cat tarjetas.txt
	while true
	do
		echo; read -p "Escoja con qué tarjeta desea trabajar [1-$total] o [c] para cancelar: " op
		if [[ "$op" = "" ]]
		then
			mensaje "Error: no ha introducido nada"
			continue
		elif [[ "$op" =~ ^[cC]$ ]]
		then
			exit
		elif [[ ! "$op" =~ ^[0-9]+$ ]]
		then
			mensaje "Error: debe introducir números"
			continue
		elif [[ $op -lt 1 || $op -gt $total ]]
		then
			mensaje "Error: debe introducir un número entre el 1 y $total"
			continue
		else
			tarjeta=`grep -Ei "$op:" tarjetas.txt | cut -f 2 -d ":"` 
			return 0
		fi 
	done
}

function EstadoActual() {
	archivo=`ls /etc/netplan | head -1`
	grep -Ei "$tarjeta" /etc/netplan/$archivo > /dev/null 2> /dev/null
	if [[ "$?" -eq 1 ]]
	then
		while true
		do
			echo; read -p "La tarjeta $tarjeta está configurada de manera automática, pulse [e] para configurarla de manera estática o [c] para cancelar: " op2
			case "$op2" in
				"")mensaje "Error: no ha introducido nada";;
				e|E)msj="dirección ip"
				    num=1
				    ipEstatica
				    dirip=$ip
				    num=2
				    msj="máscara"
				    ipEstatica
				    mask=$ip
				    transformarMask
				    grep -Ei "routes" /etc/netplan/$archivo > /dev/null 2> /dev/null
				    if [[ $? -eq 1 ]]
				    then
			            	msj="puerta de enlace"
					num=1
					ipEstatica
					gate=$ip
				    fi
				    archivoYaml
				    return 10;;
				c|C)exit;;
				*)mensaje "Error: debe introducir e o c";;
			esac
		done
	else
		grep -Ein "ens" /etc/netplan/$archivo > prueba.txt
		lineas=`cat prueba.txt | wc -l`
		if [[ $lineas -eq 1 ]]
		then
			final=`cat /etc/netplan/$archivo | wc -l`
			inicio=`cat prueba.txt | cut -f 1 -d ":"`
			sed "$inicio,$final d" /etc/netplan/$archivo > eliminar.txt
			grep -Ein "." /etc/netplan/$archivo > numerado.txt
			echo; echo "Configuración actual de la tarjeta [$tarjeta]"; echo
			for ((a=$inicio;a<=$final;a++))
			do
				grep -Ei "^$a" numerado.txt
			done
			return 0
		else
			tarjeta1=`cat prueba.txt | cut -f 2 -d ":" | sed "s/ //g" | sed "2d"`
			tarjeta2=`cat prueba.txt | cut -f 2 -d ":" | sed "s/ //g" |sed "1d"`
			if [[ ! "$tarjeta1" = "$tarjeta" ]]
			then
				final=`cat /etc/netplan/$archivo | wc -l`
				inicio=`cat prueba.txt | cut -f 1 -d ":" | sed "1d"`
				sed "$inicio,$final d" /etc/netplan/$archivo > eliminar.txt
				grep -Ein "." /etc/netplan/$archivo > numerado.txt
				echo; echo "Configuración actual de la tarjeta [$tarjeta]"; echo
				for ((a=$inicio;a<=$final;a++))
				do
					grep -Ei "^$a" numerado.txt
				done
				return 0
			else
				inicio=`cat prueba.txt | cut -f 1 -d ":" | sed "2d"`
				final=`cat prueba.txt | cut -f 1 -d ":" | sed "1d"`
				let final--
				sed "$inicio,$final d" /etc/netplan/$archivo > eliminar.txt
				grep -Ein "." /etc/netplan/$archivo > numerado.txt
				echo; echo "Configuración actual de la tarjeta [$tarjeta]"; echo
				for ((a=$inicio;a<=$final;a++))
				do
					grep -Ei "^$a" numerado.txt
				done
				return 0
			fi
		fi
	fi
}

function CambiarConfiguracion() {
	while true
	do
		echo; read -p "Pulse [a] para configurarla de manera automática, [e] de manera estática o [c] para cancelar [$tarjeta]: " op3
		case "$op3" in
			"")mensaje "Error: no ha introducido nada";;
			a|A)return 0;;
			e|E)msj="dirección ip"
			num=1
			ipEstatica
			dirip=$ip
			num=2
			msj="máscara"
			ipEstatica
			mask=$ip
			transformarMask
			grep -Ei "routes" /etc/netplan/$archivo > /dev/null 2> /dev/null
			if [[ $? -eq 1 ]]
			then
				msj="puerta de enlace"
				num=1
				ipEstatica
				gate=$ip
			fi
			return 0;;
			c|C)exit;;
			*)mensaje "Error: debe introducir alguno de los valores indicados";;
		esac
	done
}

function ipEstatica() {
	if [[ ! $op2 -eq e ]]
	then
		cat eliminar.txt > /etc/netplan/$archivo
	fi
	while true
	do
		echo; read -p "Indique una $msj correcta [$tarjeta] o [c] para cancelar: " ip
		if [[ "$ip" = "" ]]
		then 
			mensaje "Error: no has introducido nada"
		elif [[ "$ip" =~ ^[cC]$ ]]
		then
			exit
		elif [[ ! "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]
		then
			mensaje "Error: formato de dirección ip incorrecto"
		fi
		numip=`echo $ip | sed "s/\./ /g"`
		set $numip
		if [[ $num -eq 1 && ( ( $1 -le 0 || $1 -ge 255 ) || ( $2 -gt 255 || $2 -lt 0 ) || ( $3 -gt 255 || $3 -lt 0 ) || ( $4 -le 0 || $4 -ge 255 ) ) ]]
		then
			mensaje "Error: dirección ip no válida"
		elif [[ $num -eq 2 && ( ! ( "$ip" =~ ^(255\.){3}0$ || "$ip" =~ ^(255\.){2}0\.0$ || "$ip" =~ ^255\.0\.0\.0$ ) ) ]]
		then
			mensaje "Error: máscara no válida"
		else
			return 0
		fi
	done
}

function transformarMask() {
	case "$mask" in
	255\.255\.255\.0)mask="/24";;
	255\.255\.0\.0)mask="/16";;
	255\.0\.0\.0)mask="/8";;
	esac
}

function archivoYaml() {
if [[ "$op3" =~ ^[eE]$ || "$op2" =~ ^[eE]$ ]]
then
	final=`cat /etc/netplan/$archivo | wc -l`
	if [[ $final -eq 3 ]]
	then
		echo " ethernets:" >> /etc/netplan/$archivo
	fi
	echo "   $tarjeta:" >> /etc/netplan/$archivo
	echo "     addresses: [$dirip$mask]" >> /etc/netplan/$archivo
	grep -Ei "routes" /etc/netplan/$archivo > /dev/null 2> /dev/null
	if [[ "$?" -eq 1 ]]
	then
		echo "     routes:" >> /etc/netplan/$archivo
		echo "         - to: default" >> /etc/netplan/$archivo
		echo "           via: $gate" >> /etc/netplan/$archivo
	fi
	echo "     nameservers:" >> /etc/netplan/$archivo
	echo "         addresses: [8.8.8.8, 8.8.4.4]" >> /etc/netplan/$archivo
else
	cat eliminar.txt > /etc/netplan/$archivo
	lines=`cat /etc/netplan/$archivo | wc -l`
	if [[ "$lines" -eq 4 ]]
	then
		sed "4d" /etc/netplan/$archivo > eliminar.txt
		cat eliminar.txt > /etc/netplan/$archivo
		lines=`cat /etc/netplan/$archivo | wc -l`
	fi
	grep -Ei "routes" /etc/netplan/$archivo > /dev/null 2> /dev/null
	if [[ ( "$?" -eq 1 ) && ( "$lines" -gt 3 ) ]]
	then
		echo "     routes:" >> /etc/netplan/$archivo
		echo "         - to: default" >> /etc/netplan/$archivo
		echo "           via: 192.168.91.2" >> /etc/netplan/$archivo
	fi
fi
netplan apply
echo; more /etc/netplan/$archivo
rm prueba.txt eliminar.txt numerado.txt tarjetas.txt > /dev/null 2> /dev/null
return 0
}

while true
do
	echo; read -p "SE VA A PROCEDER A CONFIGURAR LA RED. ¿Desea continuar? [SN]: " sn
	case "$sn" in
		"")mensaje "Error: no ha introducido nada";;
		s|S)ElegirTarjeta
		EstadoActual
		if [[ $? -eq 10 ]]
		then
			continue
		fi
		CambiarConfiguracion
		archivoYaml;;
		n|N)exit;;
		*)mensaje "Error: debe introducir s o n";;
	esac
done
