#!/bin/bash
mes_hoy=`date \+%b`
# Obtener el número de día (sin 0 inicial)
dia_hoy=`date \+%d | sed 's/^0//'`
# Listado de todos los ficheros, ocultos incluidos, en formato largo
listado=`ls -al ~ | sed 1d`

# Configurar el for para que recorra la cadena $listado de salto en salto (en vez de espacio en espacio)
IFS=$'\n'
for linea in $listado
do
    mes=`echo $linea | awk '{print $6}'`
    dia=`echo $linea | awk '{print $7}'`
    #echo $mes $mes_hoy $dia $dia_hoy

    nombre=`echo $linea | awk '{print $9}'`
    # Comprobar que el fichero ha sido modificado el día de hoy
    if [[ "$mes" == "$mes_hoy" && "$dia" == "$dia_hoy" ]]; then
        propietario=`echo $linea | awk '{print $3}'`
        horaMinutoModificado=`echo $linea | awk '{print $8}'`
        nombre=`echo $linea | awk '{print $9}'`
        salida="$dia/$mes:$horaMinutoModificado:$propietario:$HOME/$nombre:"
        #echo "--> $permisos $propietario $longitud $horaMinuto $nombre"

        permisos=`echo $linea | awk '{print $1}' | cut -c2-10`
        tipoFichero=`echo $linea | cut -c1`
        # Comprobar si la linea actual corresponde a un directorio
        if [[ $tipoFichero == "d" ]]; then
            # Comprobar si se tiene permiso de acceso al directorio (x)
            if [[ -r $nombre  ]]; then
                salida=$salida"Success: Directorio creado correctamente"
            else
                salida=$salida"Warning: no tiene permisos de acceso"
            fi
        # Comprobar si la linea actual corresponde a un fichero
        elif [[ $tipoFichero == "-" ]]; then
            # Comprobar si se tiene permisos de acceso al fichero (sea o no ejecutable)
            if [[ ! -s $nombre ]]; then
            	salida=$salida"Warning: Fichero vacio"
            elif [[ -r $nombre  ]]; then
            	salida=$salida"Warning: no tiene permisos de acceso"
            else
                    # Obtener la fecha de creación (última linea del comando stat)
                    acceso=`stat $nombre | grep -Ei "^Acceso: [0-9]" | cut -f2,3 -d" " | sed "s/\.[0-9]*//"`
                    modificacion=`stat vacio | grep -Ei "^Modi" | cut -f2,3 -d" " | sed "s/\.[0-9]*//"`
                    creacion=`stat vacio | grep -Ei "Crea" | tr -s " " | cut -f3,4 -d" " | sed "s/\.[0-9]*//"
            
		
                    if [[ "$creacion" == "$modificacion" ]]; then
                        salida=$salida"Success: Fichero creado correctamente"
                     
                    else
                        salida=$salida"Success: fichero accedido o modificado correctamente"
                    fi
            fi
        fi

        echo $salida >> fichero.log
    #else
    #    echo "-------> $nombre no es de hoy <--------"
    fi


done


