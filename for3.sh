filename="*sh"

for file in $filename
do
	echo "Contenidos de $file"
	echo "-------"
	cat $file
	echo 
done

