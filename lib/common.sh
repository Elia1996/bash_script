#!/bin/bash

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


sub_elab_param_file () {
	local help_str="
		
		SUBstitute and ELABorate a PARAMetric FILE
		\$1 -> nome del file da modificare
		\$2 -> nome del file di destinazione
		\$3 -> -e  elabora anche
			   -ne non elabora
		Dal \$3 in poi sono coppie di:
			1) nome del parametro
			2) valore ad esso associato
		La funzione sostituisce i parametri e poi lancia uno script awk che
		va ad eseguire e sostituire tutti i costrutti del tipo \$([^)]*) in 
		modo che se necessario si possano fare operazioni con i valori all'
		interno delle parentesi, queste operazioni verranno eseguite e
		sostituite con il loro valore alla luce dei valori passati come
		argomento.

	"
	check_file $1 $help_str
	script_nm=$1
	script_nm_out=$2
	case $3 in
		-e)
			elab=1;;
		-ne)
			elab=0;;
		*)
			echo "Errore, manca il flag sull'elaborazione -e o -ne";;
	esac
	shift # elimino script_nm
	shift # elimino script_nm_out
	shift # elimino il flag di elaborazione
	if test $(($#%2)) -ne 0; then
		echo "Errore, gli argomenti parametrici non sono pari"
		echo "$help_str"
		exit
	fi
	cp $script_nm $script_nm_out
	# ciclo finchè ci sono parametri
	while test $# -gt 1; do
		#echo "----------------arg: "$@
		# sostituisco il parametro
		cat $script_nm_out | sed "s/$1/$2/g" > supp.txt
		# ricopio il file in quello finale
		cat supp.txt > $script_nm_out 
		# elimino gli ultimi due parametri
		shift
		shift
	done
	if [[ $elab = 1 ]]; then
		#eseguo lo script awk che esegue le espressioni dentro le $()
		/usr/bin/gawk -f ~/script/lib/expand-inline.sh $script_nm_out > supp.txt
		cat supp.txt > $script_nm_out
		# cancello il file di supporto
		rm supp.txt
	fi
}
