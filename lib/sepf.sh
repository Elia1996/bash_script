#!/bin/bash

Print_verbose () {
	   # stampa $1 solo se $2 = 1
	   if [[ $2 = 1 ]]; then
		   echo -e "$1"
		fi
}
Usage () {
	   echo "sepf -f file_name -d dest_file -p Y,YMB -n 10,1996 [OPTION]"
	   echo "man_sepf for man"
}

check_file () {
   # $1 nome del file di cui controllare l'esistenza
   # $2 stringa di errore
   if ! test -f $1; then
   		echo "File $1 non esistente nella directory "$(pwd)"."
		echo $2
 		exit 1
   fi
}

# Sub Elaborate Parametric File
TEMP=`getopt -o :vf:d:ep:n:o --long verbose,file:,dest:,elaborate,par_name:,par_val:,overwrite -- "$@"`
eval set -- "$TEMP"
echo $@

## variabili #############
elab=0
verbose=0
script_nm=0
script_nm_out=0
par_names=0
par_values=0
overwrite=0
ck_file=0
#########################
while true; do
	case $1 in
		-v|--verbose)
			# -v
			verbose=1; shift
			;;
		-f|--file)
			# -f file_name
			check_file $2 "	-f file not found $2"
			script_nm=$2
			Print_verbose "	Script file: $2" $verbose; shift 2
			;;
		-d|--dest)
			# -d file_name
			script_nm_out=$2;
			Print_verbose " Script out file: $2" $verbose; shift 2
			;;
		-e|--elaborate)
			# -e 
			elab=1; shift
			;;
		-p|--par_name)
			# -p par_name1,par_name2,par_name3
			set -f; IFS=","
			par_names=($2)
			Print_verbose "	Parmeter name: ${par_names[*]}" $verbose; shift 2
			;;
		-n|--par_val)
			# -n 10,20,12
			if [[ $par_names = 0 ]];then
				echo "	Errore parametri sbagliati"; Usage; exit 1
			fi
			set -f; IFS=","
			par_values=($2)
			if [[ ${#par_values[*]} -ne ${#par_names[*]} ]]; then
				echo "	Il numero di parametri non è uguale al numero di valori"
				Usage
				exit 1;
			fi
			Print_verbose "	Parameter values: ${par_values[*]}" $verbose
			shift 2
			;;
		-o|--overwrite)
			# -o
			if [[ $script_nm_out != 0 ]]; then 
				echo "	Errore, l'overwrite richiede solo il parametro -f"
				Usage
				exit 1
			fi
			overwrite=1
			Print_verbose "	Overwrite set" $verbose
			shift 1
			;;
		--)
			break;;
		*)
			echo "Errore, parametri sbagliati";
			Usage; 
			exit 1;;
		?)
			echo "Errore, pochi parametri";
			Usage;
			exit 1;;
	esac
done

if [[ $overwrite = 0 ]]; then 
	cp $script_nm $script_nm_out; 
else
	script_nm_out=$script_nm;
fi

if [[ $script_nm = 0 ]] || [[ $par_names = 0 ]] || [[ $par_values = 0 ]]; then
	echo "Errore, pochi parametri:"
	echo "	$script_nm, $par_names, $par_values"
	Usage
	exit ;
fi
Print_verbose "###  End of argument  ####" $verbose


Print_verbose "	number of param: ${#par_names[*]}" $verbose

# ciclo finchè ci sono parametri
for (( i=0; i<${#par_names[*]}; i++)) ; do
	Print_verbose "	param: ${par_names[$i]} ${par_values[$i]} $script_nm_out" $verbose
	# sostituisco il parametro
	cat $script_nm_out | sed "s/\<${par_names[$i]}\>/${par_values[$i]}/g" > supp.txt
	# ricopio il file in quello finale
	cat supp.txt > $script_nm_out 
	# elimino gli ultimi due parametri
done

if [[ $elab = 1 ]]; then
	Print_verbose "##### file con la sostituzione #############" $verbose
	Print_verbose "$(cat $script_nm_out)" $verbose
	Print_verbose "############################################" $verbose
	Print_verbose "	Elaboration $script_nm_out" $verbose
	#eseguo lo script awk che esegue le espressioni dentro le $()
	/usr/bin/gawk -f ~/script/lib/expand-inline.sh $script_nm_out > supp.txt
	cat supp.txt > $script_nm_out
	# cancello il file di supporto
	rm supp.txt
fi

