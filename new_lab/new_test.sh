#!/bin/bash

# $1 path del nuovo test deve contenere la cartella VHDL
# $2 nome del nuovo test 

# FUNZIONI e lIBERIE #############################
source ~/script/lib/common.sh

# CONTROLLIi ######################################
dir_VHDL="VHDL"
script_path=~/script/new_lab
dir=$1
dir_test=$2

if test $# -ne 2 ; then
	echo "errore, gli argomenti devono essere 2: lab_dir test_name"
	exit
fi
if test -d $1; then
	if test ${dir:${#dir}-1:1} = '/'; then
		dir=${dir:0:${#dir}-2}
	fi
else
	echo "errore, la directory $1 non c'è, non si può creare il test  $2"
	exit
fi
# entro nella directory del lab e vedo se c'è VHDL
cd $dir
if ! test -d $dir_VHDL;then
	echo "errore, non esite la directory con i file vhdl creare prima $dir_VHDL con i file vhdl(.vhd) dentro"
	exit
fi
# controllo che non esista già il test
if test -d $dir_test;then
	echo "errore il test esiste già dare un nome diverso"
fi

# SCRIPT ###########################################

# creo la cartella per il test col  nome passato
mkdir $dir_test
cd $dir_test

# inizializzo le variabili per modelsim e synopsys

# creo lo cartelle si modelsim e synopsys
mkdir setup
mkdir syn
# creo dei link o copio in base a cosa risponde l'utente
echo "Scegliere se copiare(c), creare un link(l) o non \ncopiare ne linkare (n) dei seguenti sorgenti\n presenti in $dir_VHDL:"
for file_vhdl in $(cd ../$dir_VHDL ; ls ); do
	ask_question "$file_vhdl  (c|l|n)" "Solo c(copy), l(link), n(non copiare ne linkare) sono ammesse" "c" "l" "n"
	case $ANS in
		c)
			cd setup
			cp ../../$dir_VHDL/$file_vhdl .
			cd ../syn
			if ! test ${file_vhdl:0:3} = "tb_";then
				ln -s ../setup/$file_vhdl .
			fi
			cd ../;;
		l)
		    cd setup
			ln -s ../../$dir_VHDL/$file_vhdl .
			cd ../syn
			if ! test ${file_vhdl:0:3} = "tb_";then
				ln -s ../setup/$file_vhdl .
			fi
			cd ../ ;;
		n)
			echo "non copiato";;
		*)
			echo error ;;
	esac
done


# SETTO MODELSIM
#source "$script_path/set_environment.sh"
mate-terminal --command="bash -c 'cd $dir/$dir_test/setup; source ~/script/new_lab/set_environment.sh; setmentor; vlib work; $SHELL'"
cp /home/repository/lowpower/setup/.synopsys_dc.setup .
mkdir work
mate-terminal --command="bash -c 'cd $dir/$dir_test/syn; source ~/script/new_lab/set_environment.sh; setsynopsys; $SHELL'"








