#!/bin/bash

script_name=$(echo  | cut -d "." -f 1)
script_name=$(echo "$script_name-proc.txt")

let ESWTOT=0
std_vector_or_signal () {
   #  nome del file
   #  nome da cercare
   # stampa il numero di occorrenze trovate nel file con il nome da cercare
   echo $(cat  | grep  | wc -l)
}

print_prob () {
   #  nome del file dei valori
   #  nome della variabile
   # salvo il nome dell variabile in var
   var=
   # salto i primi due argomenti per prendere solo le probabilità
   shift
   shift
   for i in $@; do
   		printf "%8.4f" "$i" >> $script_name
   done
   echo "" >> $script_name
}

f_Ttot () {
   #  nome file
   let Ttot=$(cat  | awk '{if(NR==3)print $1}')
   echo $Ttot
}
f_commutazioni_clk () {
   #  nome file
   #let Tc=$(cat  | awk '{if(NR==7)print }')
   let Tc=$(cat  | grep $clk_name | awk '{print }')
   echo $Tc
}
f_Tc () {
   #  nome file
   #  nome segnale UNIVOCO
   let Commutazioni_clk=$(cat  | grep  | awk '{print $2}')
   echo $Commutazioni_clk
}
f_T1 () {
   #  nome file
   #  nome segnale UNIVOCO
   let T1=$(cat  | grep  | awk '{print $4}')
   echo $T1
}
f_T0 () {
   #  nome file
   #  nome segnale UNIVOCO
   let T0=$(cat  | grep  | awk '{print $5}')
   echo $T0
}
f_prob_of_0or1 () {
   #  T1
   #  T totale della sim
   printf "%.4f" $(echo / | bc -l)
}
f_Esw () {
   #  Tc ossia commutazioni del segnale di cui voglio la Esw
   #  commutazioni del clock
   printf "%.4f" $(echo 2*/| bc -l)
}

signal_prob () {
   #  nome file
   #  nome COMPLETO UNIVOCO del segnale
   let Ttot=$(f_Ttot )
   let Tc=$(f_Tc  )
   let Commutazioni_clk=$(f_commutazioni_clk )
   let T1=$(f_T1  )
   let T0=$(f_T0  )
   P1=$(f_prob_of_0or1 $T1 $Ttot)
   P0=$(f_prob_of_0or1 $T0 $Ttot)
   Esw=$(f_Esw $Tc $Commutazioni_clk)
   ESWTOT=$(printf "%.4f" $(echo $ESWTOT+$Esw | bc -l))
   print_prob   $P1 $P0 $Esw
   echo "1: |2: |Ttot:$Ttot |Tc:$Tc |Comm:$Commutazioni_clk |T1:$T1 |T0:$T0 |P1:$P1 |P0:$P0 |Esw:$Esw"
}

std_vector_prob () {
   #  nome file
   #  nome del segnale
   # trovo tutti i segnali
   signal=$(cat  | grep  |awk '{print $1}')
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
shift
shift
for signal_name in $@; do
	let ESWTOT=0
	std_vector_prob $name $signal_name
	echo "Esw totale:$ESWTOT"
	printf "%64.4f  %s\n" "$ESWTOT" "Esw($signal_name) tot">> $script_name
done
