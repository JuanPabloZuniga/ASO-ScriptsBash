#!/bin/bash
echo; echo "Buscando archivos y directorios. Por favor, espere..."
find ~ -xdev -maxdepth 1 -mtime 0 -type f,d -ls | sed "s/  */ /g" | sed "s/^ //" | cut -f3,5-11 -d " " > logsArchivo.txt
cat logsArchivo.txt | grep -Ein "." > contado.txt
total=`cat logsArchivo.txt | wc -l`
for i in `seq $total`
do
	grep -Ei "^$i:" contado.txt | sed "s/:/ /" | cut -f2-11 -d " " > fidi.txt
	mensaje=`cat fidi.txt | cut -f5-11 -d " " | sed "s/ //" | sed "s/ /:/g"`
	#mensaje=`cat logsArchivo.txt | cut -f5-11 -d " " | sed "s/ //" | sed "s/ /:/g"`
	grep -Eiq "^d.*" fidi.txt 
	if [[ "$?" -eq 0 ]]
	then
		echo "$mensaje:Succes: directorio creado correctamente" >> archivoConLOGS.log
	else
		
		ruta=`cut -f8 -d " " fidi.txt`
		grep -Eiq "." "$ruta"
		if [[ "$?" -eq 0 ]]
		then
			owner=`ls -l $ruta | cut -f3 -d " "`
			usu=`whoami`
			if [[ "$owner" =~ "$usu" ]]
			then
				echo "$mensaje:Success: fichero accedido o modificado correctamente" >> archivoConLOGS.log
			else
				echo "$mensaje:Warning: no tiene permisos de acceso" >> archivoConLOGS.log
			fi
		else
			echo "$mensaje:Warning: fichero vacío" >> archivoConLOGS.log
		fi
	fi
done
cat mensajeLOG archivoConLOGS.log
echo; read -p "Pulse intro para continuar"
rm -r archivoConLOGS.log

