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

# cartella degli script
CDIR=~/script/modelsim_script
# 	CONTROLLI   ###########
if test $# -lt 4;then
	if test $(is_help $1) -eq 1 ;then echo "$help_str"; fi
	echo "Errore pochi argomenti"
	exit
fi

# elimino l'estensione del parametro
script_name=$(echo $1 | cut -d "." -f 1)
estens=$(echo $1 | cut -d "." -f 2)

# controllo che esista lo script
if ! test -f $1; then
	echo "Errore, lo script $1 non esiste"
	exit
fi
shift

case $1 in 
	-gen)
		func_for_exec=save
		;;
	-exe)
		case $2 in
			vsim)
				func_for_exec=vsim_exe
				programma=0;;
			*)
				func_for_exec=execute
				programma=$2;;
		esac
		shift
		;;
	 *)
	 	error_print $help_str
	 	exit
		;;
esac
shift


flag_delete_script=0
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
		-s)
			# controllo del numero di parametri
			if test $narg -ne 4; then
				echo "Errore nell'opzione -s, -h per l'help"    
				exit
			fi
			
			par_name=$2
			start=$3
			step=$4
			end=$5
			echo "      ------> di seguito i bellissimi file generati"
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
			shift; shift; shift; shift; shift
			echo "      ------> elaborazione a step eseguita"
			exit
			;;
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
			fi
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


