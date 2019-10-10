#!/bin/bash

# $1 path del nuovo lab
# $2 nome del nuovo lab

# CONTROLLI
script_path=~/script/new_lab
dir_VHDL="VHDL"
dir=$1
dir2=$1
if test $# -ne 2; then
	echo "errore, gli argomenti devono essere 2: dir projet-name"
	exit
fi
if test -d $1; then
	if test ${dir2:${#dir2}-1:1} = '/'; then
		dir=${dir2:0:${#dir2}-1}
	fi
else
	echo "errore, la directory $1 non c'è, non si può creare il progetto $2"
	exit
fi
cd $dir2
#salvo in una stringa la nuova directory
lab=$(echo "$dir/$2")
# controllo che non esista già il progetto
if test -d $lab; then
	echo "errore, progetto già esistente"
fi


# PROGRAMMA ##################
# inizializzo le variabili
#source "$script_path/set_environment.sh"

mkdir $lab
cd $lab
mkdir $dir_VHDL
