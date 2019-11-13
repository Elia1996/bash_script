#!/bin/bash

Print_verbose () {
       # stampa $1 solo se $2 = 1
       if [[ $verbose = 1 ]]; then
           echo -e "$1"
        fi
}
Usage () {
    echo "Usage:"
       echo "   ntc -b n_bits -t [d|b|e|fp] [ -f file_name | -n number ] [OPTION]"
       echo "   man_ntc for man"
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


##################################################################
# is integer?
# return 1 if $1 is an integer
isint () {	
	# echo $1 | awk '{print ($0==int($0))?1:0}'
	echo "$(echo $1 | sed 's/^.*\.//g')==0" | bc -l
}

##################################################################
# floating point number of bit
# return number of bit needed for represent a floating point number
fpnbit () {
	#$1 precision
	#$1 numeber floating point
	number2=$(echo $(echo $2 | awk '{print ($0<0)?$0:-($0)}') | bclout)
	n=0
	number=$(echo "scale=2000;$number2*2^$n" | bclout )
	number3=$(echo $number | awk '{print int($0)}')
	if [[ $number3 -gt 0 ]]; then
		number=$(echo "scale=2000;$number3/2^$n" | bclout )
	else
		number=0
	fi
	numberp=$(echo $number+$1 | bclout)
	numbern=$(echo $number-$1 | bclout)
	Print_verbose "$numberp,$numbern"
	let n=n+1
	# finchè non è un floating point
	while (( $( echo "$number2 < $numbern || $numberp<$number" | bc) ));do
		number=$(echo "scale=2000;$number2*2^$n" | bclout )
		number3=$(echo $number | awk '{print int($0)}')
		if [[ $number3 -gt 0 ]]; then
			number=$(echo "scale=2000;$number3/2^$n" | bclout )
		else
			number=0
		fi
		numberp=$(echo $number+$1 | bclout)
		numbern=$(echo $number-$1 | bclout)
		let n=n+1
		#echo $number
		if [[ $n -gt 500 ]]; then
			break
		fi
	done
	echo $n
}

##################################################################
# bit check
# controlla che il numero passato sia composto solo da 0 e 1
bck (){
	for((i=0; i<${#1}; i++ ));do
		if [[ ${1:$i:1} -ne 0 ]] && [[ ${1:$i:1} -ne 1 ]];then
			echo "Error, binary number is not binary"
			exit -1
		fi
	done
}

##################################################################
# bc long output, if output is long, bc automatically set \ at 
# every n number of digits, this function remove it
bclout () {
	#
	echo $(bc $@ | sed 's/\\$//g') | sed 's/ //g'
}

##################################################################
# bc for floating point
# this funtion modifiy bc outoput in order
# to have every time  at least 0 as integer
# part, 
# example: .023 -> 0.023
bcfloat () {
	# $@ sono i dati da dare a bc
	out=$(bclout $@); 
	if (( $(echo "$out < 1" |bc -l) )) ; then 
		# il numero è minore di 1, devo aggiungere 0 all'inizio
		if (( $(echo "$out < 0 && $out > -1" | bc -l) )); then
			out=$(echo "-($out)" | bclout)
			echo -n "-0";
		else
			if (( $(echo "$out > 0 && $out < 1" | bc -l) )); then
				echo -n "0";
			fi
		fi
	fi;
	echo $out
}

###################################################################
# number of fractional bit of a number
# this number could also be n expression
nfractbit () {
	# $1 è il numero da valutare con bc
	if [[ $(echo "scale=2000; $1" | bc | tr "." " "| wc -w) -eq 1 ]];then
		# nel caso in cui sia un numero intero
		echo "0"
	else
		echo -n $(echo "scale=2000; $1" | bc | sed 's/\\$//g') | sed 's/ //g' | rev | tr "0" " " | sed 's/^ *//g' | tr " " "0" | sed 's/\.[0-9]*$//g' | wc -c
	fi
}


###################################################################
# binary CA2 to decimal fixed point
# converte un numero binario CA2 su $1 bit di parte intera
# nel corrispondente numero frazionario
bc2tofp () {
	# $1 numero di bit di parte intera
	# $2 numero in binario da trasformare
	n_parte_intera=$1
	num=$2
	n=$(echo ${#num})
	n_parte_frazionaria=$(echo "$n-$n_parte_intera" | bc)
	# controllo sul numero di bit di parte intera
	if [[ $n_parte_frazionaria -lt 0 ]];then echo "Error, nbit parte intera=$n_parte_intera, nbit numero=$n"; exit -1; fi
	Print_verbose "pf=$n_parte_frazionaria"
	# valore parte intera
	if [[ $1 -eq 1 ]];then
		value_pi=$(echo "-($(echo "obase=10; ibase=2; ${num::$n_parte_intera}$(perl -e "print("0" x $n_parte_frazionaria)")" | bc))" | bc)
	else
		# tolgo il bit di segno
		let n_parte_intera_unsigned=n_parte_intera-1
		let n_before_sign=n-1
		value_pi_pos=$(echo "obase=10; ibase=2; ${num:1:$n_parte_intera_unsigned}$(perl -e "print("0" x $n_parte_frazionaria)")" | bc)	
		Print_verbose "parte intera positiva:"$value_pi_pos
		sign=$(echo "obase=10; ibase=2; ${num:0:1}$(perl -e "print("0" x $n_before_sign)")" | bc)
		Print_verbose "segno:"$sign
		value_pi=$(echo $value_pi_pos-$sign | bc )
	fi
	
	#valore parte frazionaria
	if [[ $n_parte_frazionaria == 0 ]];then 
		# se la parte intera corrisponde al numero di bit
		value_pf=0;
	else
		value_pf=$(echo "obase=10; ibase=2; ${num:$n_parte_intera}" | bc)
	fi
	
	Print_verbose "pf=$value_pf"
	n_parte_frazionaria_dec=$(nfractbit "2^-$n_parte_frazionaria")
	Print_verbose "n_parte_frazionaria=$n_parte_frazionaria_dec"
	echo "scale=$n_parte_frazionaria_dec; ($value_pi+$value_pf)/2^$n_parte_frazionaria" | bcfloat
}

###################################################################
# binary to decimal fized point
# converte un numero binario  su $1 bit di parte intera
# nel corrispondente numero frazionario
btofp (){
	# $1 numero di bit di parte intera
	# $2 binary number to transform
	number=$(echo "0$2")
	let bit_parte_intera=$1+1
	bc2tofp $bit_parte_intera $number	
}


##################################################################
# converte un file, gli deve essere passata la funzione giusta
conv (){ 
	Print_verbose "in conv"
	# $1 = isfile = 1 se $4 è un file
	isfile=$1
	# $2 = func è la funzione per convertire i numeri
	# il suo prototipo è 
	# func ca2 numero
	# dove ca2 è 1 se il numero è ca2
	func=$2
	# $3 = ca2 = 1 se il numero è in ca2
	ca2=$3
	# $4 = parte intera del numero, se -1 il numero è decimale
	p_intera=$4
	# $5 numero di bit
	n_bit=$5
	# $5 è una lista di numeri da convertire (isfile=0) oppure
	# è il nome del file (isfile=1)
	file_num=$6
	Print_verbose "filenum="$file_num

	# se ho un file calcolo il numero di colonne 
	# se invece no stampo su un'unica colonna
	if [[ $isfile == 1 ]];then
		Print_verbose "file"
		# numero di righe del file
		n_line=$(echo "$(wc -l $file_num| cut -d " " -f 1)+1" | bc)
		Print_verbose "- Number of line= $n_line" 
		# numero di parole del file
		n_word=$(wc -w $file_num | cut -d " " -f 1)
		Print_verbose "- Number of word= $n_word"
		# calcolo il numero di colonne
		n_col=$(echo "$n_word/$n_line" | bc)
		Print_verbose "- Number of col= $n_col"
		
		# salvo il file con gli spazi invece che gli a capi 
		fp=$(cat $file_num); 

	else
		Print_verbose "number"
		n_col=1	
		file_num=$(echo $file_num | tr ";" " ")
		fp=$file_num
	fi

	# aggiungo il giusto numero di 0
	new_number=""
	count=1
	totcnt=1
	Print_verbose "data_file=$fp" 
	n_number=$(echo $fp | wc -w)
	for i in $fp;do
		# passo il numero alla funzione
		Print_verbose "$func"
		new_number=$($func $ca2 $p_intera $n_bit $i)
		Print_verbose "out of $func"
		echo -n "$new_number "
		if [[ $count -eq $n_col ]] & [[ $totcnt -lt $n_number ]]; then
			echo ""
			let count=1
		else
			let count=count+1
		fi
	done
}

##################################################################
# binary to decimal
# converte un numero binario in decimale, il numero binario può
# essere ca2 e fixed point
bindec () {
	ca2=$1
	p_intera=$2
	n_bit=$3
	num=$4
	
	# se non viene data la parte intera si presuppone sia
	# pari al numero di bit e che il numero sia decimale
	if [[ $p_intera -eq -1 ]]; then
		Print_verbose "p_intera=$p_intera"
		p_intera=$(echo ${#num})
	fi
	if [[ ${#num} -ne  $n_bit ]];then
		echo "Error, number of bit $n_bit is wrong, binary number is $num"
		exit -1
	fi
	Print_verbose "p_intera=$p_intera" 
	
	if [[ $ca2 -eq 1 ]];then
		# se è ca2
		bc2tofp $p_intera $num
	else
		# se non è ca2
		btofp $p_intera $num
	fi
}


##################################################################
# binary to exadecimal
# converte un numero binario in esadecimale
binhex () {
	ca2=$1 # IGNORATO 
	p_intera=$2 # IGNORATO
	n_bit=$3
	num=$4

	e_number=$(echo "obase=16; ibase=2; $num" | bc)
	n_e=${#e_number}
	n_bin=$(echo ${#num}/4 | bc | awk '{print ($0-int($0)<0.4999999999)?int($0):int($0)+1}')
	if [[ $n_e -lt $n_bin ]]; then
		n_zero=$(echo "$n_bin-$n_e" | bc )
		echo $(perl -e "print("0" x $n_zero)")$e_number
	else
		echo $e_number
	fi
}

################################################################
# decimale to binario
# converte un decimale flixed point o intero nel binario corrisponendente
decbin () {
	ca2=$1	
	p_intera=$2
	n_bit=$3
	num=$4
	
	Print_verbose "in db"
	
	# se non viene data la parte intera si presuppone sia
	# pari al numero di bit e che il numero sia decimale
	if [[ $p_intera -eq -1 ]]; then
		Print_verbose "p_intera=$p_intera"
		let p_intera=n_bit
	fi
	if [[ $ca2 -eq 1 ]]; then
		# il numero è CA2
		if (( $(echo "$num < 0" | bc -l) )); then
			# NUMERO NEGATIVO ###################
			# moltiplico il numero per 2^parte_frazionaria e lo rendo inter
			# trovo il numero rappresentabile sui bit dati
			num=$(echo "-($num)" | bc)
			num=$(echo "$num*2^($n_bit-$p_intera)" | bc | awk '{print ($0-int($0)>0.499)?int($0)+1:int($0) }' )			
			Print_verbose $num
			# poichè è negativo devo fargli fare il giro dei bit
			num=$(echo "2^$n_bit - $num" | bc )
			Print_verbose $num
			# poichè è negativo devo fargli fare il giro dei bit
			# lo trasformo in binario
			b_num=$(echo "obase=2; ibase=10; $num" | bc)
			# aggiusto il numero di bit
			if [[ ${#b_num} -ne $n_bit ]]; then
				echo "Error, number isn't representable on $n_bit bit!! number*2^(n_bit-p_intera)=$num, b_bit=$b_num"
				exit -1
			fi
		else
			# NUMERO POSITIVO #####################
			# moltiplico il numero per 2^parte_frazionaria e lo rendo intero
			# trovo il numero rappresentabile sui bit dati
			num=$(echo "$num*2^($n_bit-$p_intera)" | bc | awk '{print ($0-int($0)>0.499)?int($0)+1:int($0) }' )			
			# lo trasformo in binario
			b_num=$(echo "obase=2; ibase=10; $num" | bc)
			# aggiusto il numero di bit
			if [[ $(echo "${#b_num}" | bc) -lt $n_bit ]]; then
				# estendo il segno
				n_ext=$(echo "$n_bit- ${#b_num}-1" | bc )
				b_num=$(echo "$(perl -e "print("0" x $n_ext )")$b_num")
			else
				echo "Error, number isn't representable on $n_bit bit!! number*2^(n_bit-p_intera)=$num, b_bit=$b_num"
				exit -1
			fi
			b_num=$(echo "0"$b_num)
		fi
	else
		if (( $(echo "$num < 0" | bc -l) )); then
			echo "Error, a negative number caan't be represented in normal notation, USE CA2 bello ;)!!!"
		else
			# moltiplico il numero per 2^parte_frazionaria e lo rendo intero
			# trovo il numero rappresentabile sui bit dati
			num=$(echo "$num*2^($n_bit-$p_intera)" | bc | awk '{print ($0-int($0)>0.499)?int($0)+1:int($0) }' )			
			# lo trasformo in binario
			b_num=$(echo "obase=2; ibase=10; $num" | bc)
			# aggiusto il numero di bit
			if [[ $(echo "${#b_num}" | bc) -le $n_bit ]]; then
				# estendo il segno
				n_ext=$(echo "$n_bit- ${#b_num}" | bc )
				b_num=$(echo "$(perl -e "print("0" x $n_ext )")$b_num")
			else
				echo "Error, number isn't representable on $n_bit bit!! number*2^(n_bit-p_intera)=$num, b_bit=$b_num"
				exit -1
			fi
		fi
	fi
	echo $b_num
}

#############################################################à##
# decimale -> esadecimale
dechex () {
	ca2=$1	
	p_intera=$2
	n_bit=$3
	num=$4

	
	# se non viene data la parte intera si presuppone sia
	# pari al numero di bit e che il numero sia decimale
	if [[ $p_intera -eq -1 ]]; then
		let p_intera=n_bit
	fi
	# trasformo in binario
	b_num=$(decbin $ca2 $p_intera $n_bit $num)
	# trasformo in esadecimale
	e_num=$(echo "obase=16; ibase=2; $b_num"| bc -l)
	echo $e_num
}

################################################################
# hhex to bin
hexbin () {
	ca2=$1	
	p_intera=$2
	n_bit=$3
	num=$4

	
	# se non viene data la parte intera si presuppone sia
	# pari al numero di bit e che il numero sia decimale
	if [[ $p_intera -eq -1 ]]; then
		let p_intera=n_bit
	fi
	b_num=$(echo "obase=2; ibase=16; ${num^^}" | bc )
	echo $b_num
}

###############################################################
# exa to decimal
hexdec () {
	ca2=$1	
	p_intera=$2
	n_bit=$3
	num=$4

	
	# se non viene data la parte intera si presuppone sia
	# pari al numero di bit e che il numero sia decimale
	if [[ $p_intera -eq -1 ]]; then
		let p_intera=n_bit
	fi
	b_num=$(hexbin $ca2 $p_intera $n_bit $num)
	d_num=$(bindec $ca2 $p_intera $n_bit $b_num)
	echo $d_num
}



################################################################
#### SCRIPT ####################################################
TEMP=`getopt -o vf:n:b:t:p:c --long verbose,file:,number:,bit_number:,type:,p_intera:,ca2 -- "$@"`
eval set -- "$TEMP"

n_flag=0
f_flag=0
b_flag=0
t_flag=0
p_flag=0
ca2=0
p_intera=-1
verbose=0
n_bit=0
file_num=0
while true; do
    case $1 in
        -v|--verbose)
            # -v
            verbose=1; shift
            ;;
        -f|--file)
            # -f file_name
			f_flag=1
            check_file $2 " -f file not found $2"
			file_num=$2
            Print_verbose " Script file: $2" $verbose; shift 2
            ;;
        -n|--number)
			# -n number to convert
			n_flag=1
			file_num=$2; shift 2
			;;
		-b|--bit_number)
			# -b number of bits
			b_flag=1
			n_bit=$2; shift 2
			;;
		-t|--type)
			# type of conversion
			t_flag=1
			conv_type=$2; shift 2
			;;
		-p|--p_intera)
			# parte intera del numero
			p_flag=1
			p_intera=$2; shift 2
			;;
		-c|--ca2)
			# ca2 complement
			ca2=1; shift
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

# conversione nel caso in cui il numero di bit sia nella forma 2.10
# ossia parte intera e frazionaria
# se ho 2.10 n_word_nbit sarà 2 , se ho 12 sarà 1, se ho 2.3.1 avrò 3
n_word_nbit=$(echo $n_bit | tr "." " " | wc -w)
if [[ $n_word_nbit -eq 2 ]];then
	n1=$(echo $n_bit | tr "." " " | cut -d " " -f 1)
	n2=$(echo $n_bit | tr "." " " | cut -d " " -f 2)
	n_bit=$( echo "$n1+$n2" | bc )
	p_intera=$n1
else
	if [[ $n_word_nbit -gt 2 ]];then
		echo "Error, $n_bit have too much dots"
		exit -1
	fi
fi

Print_verbose " $f_flag $conv_type $ca2 $p_intera $n_bit $file_num"
conv $f_flag $conv_type $ca2 $p_intera $n_bit $file_num
#bindec
#binhex
#decbin
#binhex
#hexbin
#hexdec

if [[ $n_flag -eq 1 ]]; then
	echo ""
fi

#case $conv_type in
#	bd)
#		# esadecimale -> binario
#		conv $f_flag "bd" $ca2 $p_intera $file_num
#		;;
#	be)
#		# binario -> esadecimale
#		conv $f_flag "be" $ca2 $p_intera $file_num 
#		;;
#esac
