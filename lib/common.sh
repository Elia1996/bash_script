#!/bin/bash

SDIR=~/script/modelsim_script

ask_make_yesno () {
   # $1 answer 
   # $2 command to make
   # $3 se 1 chiede due volte, se 0 solo una
   # ritorna 0 se ha risposto si e ha eseguito e 1 altrimenti
   if test $# -ne 3; then
		echo "Error !!!!! ask_make_yesno want tre argument!!"
   fi
   ask_yesno "$1"
   if [[ $? -eq 1 ]]; then
		if [[ $3 -eq 1 ]]; then
			ask_yesno "Sei SICURISSIMO??? (y/n)"
			if [[ $? -eq 1 ]]; then
				$2
				return 0
			fi
		else
			$2
			return 0
		fi
   fi
   return 1
}


ask_question () {
    # $1 stringa da stampare nella domanda
    # $2 stringa da stampare se ha sbagliato
    # $3 ... $n argomenti validi
    local op=0
    local flag=1
    local str1=$1
    local str2=$2
    shift
    shift
    echo -n -e $str1": "
    while test $flag -eq 1; do
        read op
        let flag=1
        for arg in $*; do  
            if test $op = $arg; then
                flag=0;
                break   
            fi
        done
        if test $flag -eq 1 ; then
            echo -n $str2": "
        fi
    done
    ANS=$op
}
ask_yesno () {   
    # $1 stringa da stampare nella domanda
    # $3 ... $n argomenti validi
    local op=0
    local flag=1
    local str1=$1
    shift
    echo -n -e $str1": "
    while test $flag -eq 1; do
        read op
        let flag=0
		local answer=$(yesorno $op)
		case $answer in
			0) # ne si ne no
            	echo -n "Only yes or no is avaiable as answer: " 
				let flag=1;;
			1) # no
				let ANS=0;;
			2) # si
				let ANS=1;;
			*) # error
				echo "errorrrrr";;
        esac
    done
    return $ANS
}

yesorno () {
   # $1 viene controllato essere un si o un no e viene ritornato
   #	0 -> ne si ne no
   # 	1 -> no
   #    2 -> si
   local answer=$(check_fio $1 yes no n y si no s)
   if test $answer -eq 0; then
   		echo 0 # ne si ne no
		return 
   fi
   local is_yes=$(check_fio $1 yes y si s)
   if test $is_yes -eq 1; then
   		echo 2  # si
		return
   fi
	echo 1 # no
}

check_fio () {
   # check first in others (fio)
   # $1 argomento da controllare in quelli dopo
   # 	in or, se $1 è uguale a anche solo uno ritorna 1
   local first=$1
   shift
   for i in $*; do
		if [[ $i = $first ]]; then
			echo 1
			return 
		fi
   done
   echo 0
}

is_last_option () {
   local help_str="
	is_last_option
		dice se siamo all'ultima opzione
	"
   # se il primo argomento è un'opzione la elimino
   if [[ $1 =~ ^-[^-]*$ ]]; then shift; fi
   # ciclo sulle altre stringhe finchè non trovo un'altra opzione o
   # finiscono le opzioni
   let count=0
   for arg in $@; do
   		if [[ $arg =~ ^-[^-]*$ ]]; then
			echo 0
			return 
		fi
		shift
   done
   echo 1
}
arg_of_option () {
   local help_str="
	arg_of_option fornisce il numero di argomenti legati ad un'opzione
				  di un programma, si suppone che ogni argomento inizi
				  con - e sia composto da una stringa, viene quindi 
				  ritornato il numero di argomenti
   "
   # gli argomenti devono essere almeno 2 del tipo
   # -prima_opz sec terz ... -sec_opz
   if test $# -lt 2 ; then
   		echo 0
		return
   fi
   # se il primo argomento è un'opzione la elimino
   if [[ $1 =~ ^-[^-]*$ ]]; then shift; fi
   # ciclo sulle altre stringhe finchè non trovo un'altra opzione o
   # finiscono le opzioni
   let count=0
   for arg in $@; do
   		if ! [[ $arg =~ ^-[^-]*$ ]]; then
			let count++
		else
			echo $count 
			return
		fi
		shift
   done
   echo $count 
   return 
}

is_help () {
   # $1 se è uguale a: -h, h, H, -H, help, -help 
   #    stampa $1
   case $1 in
   		-h|h|H|-H|help|-help)
			echo 1;;
		*)
			echo 0;;
   esac
}

error_print () {
   # stampa l'errore ed esce 
   # $1 stringa da stampare
   echo $@ | sed -e "s,\t,    ,g"
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


sepf () {
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
				Print_verbose " Parmeter name: ${par_names[*]}" $verbose; shift 2
				;;
			-n|--par_val)
				# -n 10,20,12
				if [[ $par_names = 0 ]];then
					echo "	Errore parametri sbagliati"; Usage; exit 1
				fi
				set -f; IFS=","
				par_values=($2)
				if [[ ${#par_values[*]} -ne ${#par_names[*]} ]]; then
					echo "	Il numedo"
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
				Print_verbose " Overwrite set" $verbose
				shift 1
				;;
			--)
				break;;
			*)
				echo "Errore, parametri sbagliati";
				Usage; 
				exit 1;;
		esac
	done
	Print_verbose "###  End of argument  ####" $verbose

	if [[ $overwrite = 0 ]]; then 
		cp $script_nm $script_nm_out; 
	else
		script_nm_out=script_nm;
	fi

	Print_verbose "		number of param: ${#par_names[*]}" $verbose

	 echo ${par_names[$i]}
	# ciclo finchè ci sono parametri
	for (( i=0; i<${#par_names[*]}; i++)) ; do
		Print_verbose "		param: ${par_names[$i]} ${par_values[$i]}" $verbose
		# sostituisco il parametro
		cat $script_nm_out | sed "s/\<${par_names[$i]}\>/${par_values[$i]}/g" > supp.txt
		# ricopio il file in quello finale
		cat supp.txt > $script_nm_out 
		# elimino gli ultimi due parametri
	done
	
	if [[ $elab = 1 ]]; then
		cat $script_nm_out
		Print_verbose "		Elaboration $script_nm_out" $verbose
		#eseguo lo script awk che esegue le espressioni dentro le $()
		/usr/bin/gawk -f ~/script/lib/expand-inline.sh $script_nm_out > supp.txt
		cat supp.txt > $script_nm_out
		# cancello il file di supporto
		rm supp.txt
	fi
}

Print_verbose () {
	   # stampa $1 solo se $2 = 1
	   if [[ $2 = 1 ]]; then
		   echo -e "$1\n"
		fi
}
