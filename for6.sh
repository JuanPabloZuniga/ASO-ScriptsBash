ficheros="/home/alumno/for2134r.sh
/home/alumno/for2.sh
/home/alumno/for3.sh
/home/alumno/for4.sh
/home/alumno/for345.sh
/home/alumno/forrg.sh"

for fichero in $ficheros
do
	if [ ! -e "$fichero" ] #Comprobamos si existe el fichero
	then
		echo "$fichero no existe"; echo
		break #rompe la cadena, sale de ña cadena y se va feura del done
		continue #continua, rompe la cadena del bucle for y va a la siguiente(no baja)
	fi
	cat $fichero
	echo
done
echo estoy saliendo
