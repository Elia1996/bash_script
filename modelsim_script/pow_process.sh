#!/bin/bash

source ~/script/lib/common.sh

Usage () { 
	echo -e "Usage: \n-f file -s signal1,signal2"
} 

if test $# -lt 4; then
	Usage
	exit 1
fi
# salvo in modo diverso gli argomenti per processarli
TEMP=`getopt -o :hf:s:c:e: --long help,file:,signal:,clk:,processed_end: -- "$@"`
# risetto gli argomenti da linea di comando
eval set -- "$TEMP"
# flag per sapere se ho sia il file che il nome dei segnali
let vf=0; let vs=0;

echo "Input argument"
# default
clk_name="clk"
processed_end="-proc"
while true; do
	case $1 in
		-h|--help)
			Usage 1>&2
			exit 0
			;;
		-f|--file-name)
			name=$2
			script_name=$(echo $2 | cut -d "." -f 1); shift 2;
			echo "	File di potenza: $name -> $script_name"
			let vf=1
			;;
		-s|--signal)
			set -f; IFS=","
			sig=($2)
			echo "	Signal: ${sig[@]}"; shift 2;
			let vs=1
			;;
		-c|--clk)
			clk_name=$2	
			echo "	Clk_name: $clk_name"; shift 2;
			;;
		-e|--processed-end)
			processed_end=$2
			echo "	Processed file ending: $script_end"; shift 2;
			;;
		--)
			shift; break
			;;
		*)
			echo "Error!" 1>$2
			Usage;;
	esac
done
shift $((OPTIND-1))
if [[ vf -eq 0 ]] || [[ vs -eq 0 ]]; then
		echo "Error!" 1>&2
		Usage
		exit 1
fi

script_name=$(echo "$script_name$processed_end.txt");

let ESWTOT=0
std_vector_or_signal () {
   #  nome del file
   #  nome da cercare
   # stampa il numero di occorrenze trovate nel file con il nome da cercare
   echo $(cat  | grep  | wc -l)
}

print_prob () {
   #  nome della variabile
   # salvo il nome dell variabile in var
   var=$1
   # salto i primi due argomenti per prendere solo le probabilità
   shift
   for i in $@; do
	    if [ ${i:0:1} = "." ]; then i=$(echo "0$i"); fi
   		printf "%10s" "$i" >> $script_name
   done
   echo "" >> $script_name
}

f_Ttot () {
   #  nome file
   let Ttot=$(cat $1 | awk '{if(NR==3)print $1}')
   echo $Ttot
}
f_commutazioni_clk () {
   #  nome file
   #let Tc=$(cat  | awk '{if(NR==7)print }')
   let Tc=$(cat $1 | grep $clk_name | awk '{print $2}')
   echo $Tc
}
f_Tc () {
   #  nome file
   #  nome segnale UNIVOCO
   let Commutazioni_clk=$(cat $1 | grep $2 | awk '{print $2}')
   echo $Commutazioni_clk
}
f_T1 () {
   #  nome file
   #  nome segnale UNIVOCO
   let T1=$(cat $1 | grep $2 | awk '{print $4}')
   echo $T1
}
f_T0 () {
   #  nome file
   #  nome segnale UNIVOCO
   let T0=$(cat $1  | grep $2 | awk '{print $5}')
   echo $T0
}
f_prob_of_0or1 () {
   #  T1
   #  T totale della sim
   echo "scale=4;$1/$2" | bc -l
}
f_Esw () {
   #  Tc ossia commutazioni del segnale di cui voglio la Esw
   #  commutazioni del clock
   echo "scale=4;2*$1/$2"| bc -l
}

signal_prob () {
   #  nome file
   # commutazioni del segnale totali
   let Tc=$(f_Tc  $1 $2)
   # Tempo del segnale a 1
   let T1=$(f_T1  $1 $2)
   # Tempo del segnale a 0
   let T0=$(f_T0  $1 $2)
   # Probabilità che il segnale sia a 1
   P1=$(f_prob_of_0or1 $T1 $Ttot)
   # Probabilità che il segnale sia a 0
   P0=$(f_prob_of_0or1 $T0 $Ttot)
   Esw=$(f_Esw $Tc $Commutazioni_clk)
   ESWTOT=$(echo "scale=4;$ESWTOT+$Esw" | bc -l)
   print_prob  $2 $P1 $P0 $Esw
   echo "   |Tc:$Tc |T1:$T1 |T0:$T0 |P1:$P1 |P0:$P0 |ESW:$Esw"
}

std_vector_prob () {
   #  nome file
   #  nome del segnale
   # trovo tutti i segnali
   signal_temp=$(cat $1 | grep $2 |awk '{print $1}' | tr "\n" " ")
   set -f; IFS=" "
   signal=($signal_temp)
   let count=0
   echo "Segnali:"
   for i in ${signal[@]}; do
	    echo -n "	Segnale $count: $i "
    	printf "%40s" $i >> $script_name	
   		# per ogni segnale stampo le sue caratteristiche
		signal_prob $1  $i 
		let count++
   done
}

echo -e "Power Report Processing for Switching Activity\n" > $script_name
printf "%40s%10s%10s%10s\n" "nome    |" "P1    |" "P0    |" "ESW    |" >> $script_name
let Commutazioni_clk=$(f_commutazioni_clk $name)
echo "	Commutazioni_clk: $Commutazioni_clk"
#  nome COMPLETO UNIVOCO del segnale
let Ttot=$(f_Ttot $1)
echo "	Ttot: $Ttot"

for signal_name in ${sig[@]}; do
	let ESWTOT=0
	std_vector_prob $name $signal_name
	echo "Switching activity"
	echo "	Esw totale:$ESWTOT"
	printf "%70.4s  %s\n" "$ESWTOT" "Esw($signal_name) tot">> $script_name
done
echo "By ER" >> $script_name
