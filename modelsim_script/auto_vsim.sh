#!/bin/bash
# $1 nome dello script.do da eseguire

Usage () {
	   echo "Usage: \n  auto_vsim -f filename\n man_auto_vsim for manpage\n"
}
source ~/script/lib/common.sh

CDIR=~/script/modelsim_script

TEMP="getopt -o :hf: --long :help,file: -- "$@""
eval set -- "$TEMP"

#variabili
ck_file=0

while true; do
	case $1 in
		-h|--help)
			Usage; shift
			exit 0;
			;;
		-f|--file)
			check_file $2 "Error, file not found"
			script=$2; shift 2
			;;
		--)
			break
			;;
		*)
			Usage
			exit 1
			;;
	esac
done

if [[ ck_file = 0 ]]; then
	echo "Errore, definire lo script.do da eseguire"	
	Uxsage
	exit 1
fi

cat "$CDIR/auto_vsim.py" | sed "s/compile.do/$1/" > auto_vsim_custom.py
chmod 777 auto_vsim_custom.py
./auto_vsim_custom.py
rm auto_vsim_custom.py
