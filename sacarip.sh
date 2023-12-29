#!bin/bash
echo
ip a | grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}/(8|16|24)" | grep -En "." > ips.txt
echo "Tus IP's son:"
echo
cat ips.txt
sudo rm ips.txt
echo;read -p "Pulse intro para continuar"
exit
