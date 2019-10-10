#!/bin/bash

Usage () { 
	echo -e "Usage: \n-f file -s signal1,signal2"
} 

if test $# -lt 4; then
	Usage
	exit 1
fi

while getopts ":hf:s:" opt; do
	case ${opt} in
		h)
			Usage 1>&2
			exit 0
			;;
		f)
			script_name=$(echo $OPTARG | cut -d "." -f 1)
			script_name=$(echo "$script_name-proc.txt")
			;;
		s)
			set -f; IFS=","
			sig=($OPTARG)
			;;
		\?)
			echo "Error" 1>&2
			Usage 1>$2
			exit 1
			;;
	esac
done
shift $((OPTIND-1))


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
   		printf "%8.4f" "$i" >> $script_name
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
   let Tc=$(cat $1 | grep $clk_name | awk '{print }')
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
   printf "%.4f" $(echo $1/$2 | bc -l)
}
f_Esw () {
   #  Tc ossia commutazioni del segnale di cui voglio la Esw
   #  commutazioni del clock
   printf "%.4f" $(echo 2*$1/$2| bc -l)
}

signal_prob () {
   #  nome file
   #  nome COMPLETO UNIVOCO del segnale
   let Ttot=$(f_Ttot $1)
   let Tc=$(f_Tc  $1 $2)
   let Commutazioni_clk=$(f_commutazioni_clk $1)
   let T1=$(f_T1  $1 $2)
   let T0=$(f_T0  $1 $2)
   P1=$(f_prob_of_0or1 $T1 $Ttot)
   P0=$(f_prob_of_0or1 $T0 $Ttot)
   Esw=$(f_Esw $Tc $Commutazioni_clk)
   ESWTOT=$(printf "%.4f" $(echo $ESWTOT+$Esw | bc -l))
   print_prob  $2 $P1 $P0 $Esw
   echo "$1: |$2: |Ttot:$Ttot |Tc:$Tc |Comm:$Commutazioni_clk |T1:$T1 |T0:$T0 |P1:$P1 |P0:$P0 |Esw:$Esw"
}

std_vector_prob () {
   #  nome file
   #  nome del segnale
   # trovo tutti i segnali
   signal=$(cat $1 | grep $2 |awk '{print $1}')
   for i in $signal; do
    	printf "%40s" $i >> $script_name	
   		# per ogni segnale stampo le sue caratteristiche
		signal_prob  $i 
   done
}

echo " " > $script_name
printf "%40s%8s%8s%8s\n" "nome    |" "P1  |" "P0  |" "Esw  |" >> $script_name
name=
clk_name=
for signal_name in ${sig[@]}; do
	echo $signal_name
	let ESWTOT=0
	std_vector_prob $name $signal_name
	echo "Esw totale:$ESWTOT"
	printf "%64.4f  %s\n" "$ESWTOT" "Esw($signal_name) tot">> $script_name
done
