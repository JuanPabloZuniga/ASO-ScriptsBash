for a in 1 2 3 4 5 6 7 8 9 10
do
	echo -n "$a"
done

echo; echo

for a in `seq 20`
do
	echo -n "$a"
done

echo; echo

for a in {1..10}
do
	echo -n "$a"
done

echo;echo

for a in {1..10..2}
do
        echo -n "$a"
done

echo; echo

for ((a=1; a<=10; a++))
do
	echo -n "$a"
done

echo;echo

for ((a=10; a<=5; a--))
do
        echo -n "$a"
done

echo;echo
