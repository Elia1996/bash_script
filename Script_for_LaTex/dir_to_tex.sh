#!/bin/bash

# $1 nome directory to make in latex
# $2 nome example file dove 
#	CODE -> tipo di codice
#	FILENAME -> path del file
#	NAME -> nome del programma

ex_file=$2
dir_to_latex=$1

function set_file() {
	   # $1 filename
	   filename=$dir/$1
	   name=$(basename $1 | sed -e 's/_/\_/g')
	   code_ext=$(echo $1 | rev | cut -d "." -f 1 | rev)
	   case $code_ext in
		   py)
			   code="python";;
		   sh)
			   code="bash";;
	       vhd)
			   code="vhdl";;
		   *)
			   code="bash";;
	   esac
	   echo $filename
	   echo $name
	   echo $code_ext
	   cat $ex_file | sed s/CODE/$code/g | sed s/FILENAME/$filename/g | sed s/NAME/$name/g
}


cd $dir_to_latex
dir=$(basename $dir_to_latex)

for name in `ls`; do
	if test -f $name; then
		echo "f :"$name	
		set_file $dir_to_latex/$name
	else
		echo "d :"$name
	fi
done

