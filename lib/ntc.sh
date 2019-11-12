#!/bin/bash

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
	echo "$numberp,$numbern"
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
	echo pf=$n_parte_frazionaria
	# valore parte intera
	if [[ $1 -eq 1 ]];then
		value_pi=$(echo "-($(echo "obase=10; ibase=2; ${num::$n_parte_intera}$(perl -e "print("0" x $n_parte_frazionaria)")" | bc))" | bc)
	else
		# tolgo il bit di segno
		let n_parte_intera_unsigned=n_parte_intera-1
		let n_before_sign=n-1
		value_pi_pos=$(echo "obase=10; ibase=2; ${num:1:$n_parte_intera_unsigned}$(perl -e "print("0" x $n_parte_frazionaria)")" | bc)	
		echo "parte intera positiva:"$value_pi_pos
		sign=$(echo "obase=10; ibase=2; ${num:0:1}$(perl -e "print("0" x $n_before_sign)")" | bc)
		echo "segno:"$sign
		value_pi=$(echo $value_pi_pos-$sign | bc )
	fi
	
	#valore parte frazionaria
	if [[ $n_parte_frazionaria == 0 ]];then 
		# se la parte intera corrisponde al numero di bit
		value_pf=0;
	else
		value_pf=$(echo "obase=10; ibase=2; ${num:$n_parte_intera}" | bc)
	fi
	
	echo pf=$value_pf
	n_parte_frazionaria_dec=$(nfractbit "2^-$n_parte_frazionaria")
	echo $n_parte_frazionaria_dec
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



Print_verbose () {
       # stampa $1 solo se $2 = 1
       if [[ $2 = 1 ]]; then
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




################################################################
#### SCRIPT ####################################################
TEMP=`getopt -o vf:n:b:t:c --long verbose,file:,number:,bit_number:,type:,ca2 -- "$@"`
eval set -- "$TEMP"

n_flag=0
f_flag=0
b_flag=0
t_flag=0
ca2=0
echo $@
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
            from_file=$2
            Print_verbose " Script file: $2" $verbose; shift 2
            ;;
        -n|--number)
			# -n number to convert
			n_flag=1
			number=$2; shift 2
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
		-c|--ca2)
			# ca2 complement
			ca2=1
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

case $conv_type in
	eb)
		# esadecimale -> binario
		
