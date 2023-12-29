#!/bin/bash
usuario=$(whoami)
if [[ "$usuario" = "root"  ]];then
	echo;read -p  "Se debe ejecutar el script sin sudo. Pulse intro para continuar";exit
fi
echo "$usuario" > nomuser.txt
sudo sh dfs.sh
