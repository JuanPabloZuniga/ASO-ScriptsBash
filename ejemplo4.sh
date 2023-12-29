echo "Introduzca su nombre y apellidos: \c"
read nombre
set $nombre
echo "$1 - $2 - $3"
echo "\$# Indica el numero de parametos posicionales: $#"
echo "\$# Muestra todos los parametros posocionales: $*"
echo $* | sed "s/ / - /g"
