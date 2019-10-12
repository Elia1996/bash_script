#!/bin/bash
help_str="
 simulazione parametrica automatizzata, questo programma prende uno script
 qualsiasi e il nome 
 $1 nome script
 $2 modalità
 	le modalità sono le seguenti:
		-exe modalità di esecuzione immediata, dev'essere fornito anche il
			nome del programma da utilizzare per ogni file 
			 $1 nome programma
		-gen generazione dei file parametrici, in questo caso vengono solo 
			 generati tutti i file parametrici da quello originario
 [ARGOMENTI VARIABILI]
 	  questi argomenti possono essere messi in un ordine qualsiasi 
 	  -s -> step
				\$1 parameter_name
 				\$2 start
 				\$3 step
 				\$4 end
 	  -c -> custom 
			effettua una simulazione parametrica usando i valori dati
				\$1 parameter_name
				\$2 primo
 				...
  				\$n ultimo
	  -p -> parametro 
	  		dev'essere la prima opzione
	  		sostituisce senza parametrizzare
				\$1 parameter_name
				\$2 value

	Non si possono fare simultaneamente le simulazioni custom e step 
	per il momento. ma solo una di esse alla volta
"

source ~/script/lib/common.sh

# FUNZIONI  #############
Print () {
	# stampa $1 solo se verbose = 1
	if [[ $verbose = 1 ]];then
		echo $1
	fi
}

Usage () {
	echo -e "Usage:\n	auto_param_sim -e/-g -p param_name [opzioni]\n	See man_auto_param_sim for man"	   
}

execute () { 
	$programma $1
	#rm "$script_name_supp.do"
	save $1
}
vsim_exe () {
   sh ~/script/modelsim_script/auto_vsim.sh $1
   save $1
}


save () {
	echo ""
	echo "       ------ file $1 ----------"
	cat -n $1
}

# 	CONTROLLI   ##############################################
if test $# -lt 4;then
	echo "Errore pochi argomenti" 1>&2
	Usage
	exit 1
fi

# SCRIPT ##################################################à

# salvo gli argomenti per processarli
TEMP=`getopt -o :hf:g:e:s:c:p --long help,file:,gen:,exe:,step:,custom:,param: -- "@$"`
# risetto gli argomenti da linea di comando
eval set -- "$TEMP"

#### parametri #####
flag_delete_script=0
verbose=0
# cartella degli script
CDIR=~/script/modelsim_script
####################

# ciclo sugli argomenti da linea di comando ordinati
while true; do
	case $1 in 
		-g|--gen)
			func_for_exec=save; shift 2
			Print "	-g"
			;;
		-e|--exe)
			Print "	-exe"
			case $2 in
				vsim)
					Print "		execution with vsim program"
					func_for_exec=vsim_exe
					programma=0;;
				*)
					Print "		execution with custom program"
					func_for_exec=execute
					programma=$2;;
			esac
			shift 2
			;;
		-v|--verbose)
			verbose=1; shift 2;
			Print "OPTION"
			Print "	-verbose"
			;;
		-s|--step)
			Print "	-step"
			# I set comma as field separator in order to divide parameter
			set -f; IFS=","
			arg=($2)
			narg=${#arg[@]}
			# controllo del numero di parametri
			if test $narg -ne 3; then
				echo "Errore nell'opzione -s, -h per l'help"    
				exit
			fi
			
			par_name=${arg[0]}
			start=${arg[1]}
			step=${arg[2]}
			end=${arg[3]}
			Print "		param_name= $par_name"
			Print "		start= $start"
			Print "		step= $step"
			Print "		end= $end"
			Print "      ------> di seguito i bellissimi file generati"
			for i in $(seq $start $step $end);do
				sub_elab_param_file $script_name.$estens\
				"$script_name-$par_name-$i.$estens" -e\
				$par_name $i
				# funzinone per l'eventuale simulazione immediata
				$func_for_exec "$script_name-$par_name-$i.$estens"
			done
			if test $flag_delete_script -eq 1; then
				rm $script_name.$estens
			fi
			shift 5
			Print "      ------> elaborazione a step eseguita"
			exit
			;;
		-c|--custom)
			Print "	--custom"
			# opzione del tipo -c par_name=2,3,4,5
			# I set comma as field separator in order to divide parameter
			set -f; IFS="="
			arg=($2)
			narg=${#arg[@]}
			if test $narg -lt 2; then
				echo "Errore nell'opzione -c, -h per l'help"
				exit
			fi
			# parametro da modificare
			par_name=${arg[0]}
			set -f; IFS=","
			par_values=(${arg[1]})

			Print "      ------> di seguito i bellissimi file generati"
			# ciclo sui parametri
			for value in ${par_values[*]};do
				sub_elab_param_file $script_name.$estens\
				"$script_name-$par_name-$value.$estens" -e\
				$par_name $value
				# funzinone per l'eventuale simulazione immediata
				$func_for_exec "$script_name-$par_name-$value.$estens"
				shift
			done
			echo "      ------> elaborazione custom eseguita"
			if test $flag_delete_script -eq 1; then
				rm $script_name.$estens
			fi
			exit
			;;
		--)
			break;;
		 *)
		 	error_print "Argomenti sbagliati"
			Usage
		 	exit 1
			;;
	esac
done


echo "----- creazione figa di file parametrici per simulazioni ieaaaa -----"
while test $# -ge 1; do
	# vedo se è l'ultima opzione
	flag_last_option=$(is_last_option $@)
	
	# trovo il numero di argomenti per l'opzione corrente
	narg=$(arg_of_option $@)
	
	# sezione in cui mi sono divertito a far stampare i comandi
	echo -n "------> comando: "
	param=($@)
	for ((j=0; j<$(($narg+1)); j++)); do
		echo -n ${param[$j]}" "
	done
	echo ""
	
	# ciclo sul parametro in questione
	case $1 in
		-c)
			if test $narg -lt 2; then
				echo "Errore nell'opzione -c, -h per l'help"
				exit
			fi
			shift
			par_name=$1
			shift
			echo "      ------> di seguito i bellissimi file generati"
			for ((i=0; i<$(($narg-1)); i++));do
				sub_elab_param_file $script_name.$estens\
				"$script_name-$par_name-$1.$estens" -e\
				$par_name $1
				# funzinone per l'eventuale simulazione immediata
				$func_for_exec "$script_name-$par_name-$1.$estens"
				shift
			done
			echo "      ------> elaborazione custom eseguita"
			if test $flag_delete_script -eq 1; then
				rm $script_name.$estens
			fi
			exit
			;;
		-p)
			if test $narg -ne 2; then
				echo "Errore nell'opzione -p, -h per l'help"
				exit
		i	fi
			# tolgo l'opzione
			shift
			# salvo il nome del parametro
			par_name=$1
			shift
			
			# creo il file nuovo, se è l'ultimo parametro elaboro anche
			if [[ $flag_last_option = 0 ]];then
				sub_elab_param_file $script_name.$estens \
				$script_name-$par_name-$1.$estens -ne $par_name $1
			else
				sub_elab_param_file $script_name.$estens \
				$script_name-$par_name-$1.$estens -e $par_name $1
		    fi		
			# se non è il primo parametro elimino il file parametrico
			# precedente che è stato utilizzato per l'ultimo
			# perchè tanto non serve più
			if test $flag_delete_script -eq 1; then
				rm $script_name.$estens
			fi
			# rinomino lo script in modo che si appendino i
			# valori di ciascun parametro
			script_name="$script_name-$par_name-$1"
			shift
			echo "      ------> elaborazione a singolo parametro eseguita"
			flag_delete_script=1
			;;
		*)
			echo "$help_str"
			exit
			;;
	esac
done

# funzinone per l'eventuale simulazione immediata
$func_for_exec "$script_name.$estens"


