#!bin/bash
while true
do
num=`cat /etc/passwd | grep -Ei "^.*:x:1[0-9]{3}:" | cut -f 1 -d ":" | wc -l`
usu=`cat /etc/passwd | grep -Ei "^.*:x:1[0-9]{3}:" | cut -f 1 -d ":"`
if [[ $num -eq 1 ]]
then
	echo "Solo hay un usuario y ha sido creado durante la instalacón"
else 
	echo "Hay $num usuarios creados en el sistema, por nosotros:"
	echo "$usu"
	
fi
while true
do
echo; read -p "¿Desea salir del programa?: " sino
if [[ "$sino" = "" ]]
then
	echo "No ha introducido nada"
	continue
elif [[ "$sino" =~ ^[sS]$ ]]
	then 
		exit
elif [[ "$sino" =~ ^[nN]$ ]]
	then 
	continue 2
else 
	echo "Error: se esperaba S o N"
	continue
fi
done
done
