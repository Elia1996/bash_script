#!/bin/bash

# this installation require sudo
#script_name=${0:2}
#for manpage in `ls`; do
#	if [ $manpage != $script_name ];then
#		mkdir /usr/local/man/man1
#		mkdir /usr/local/man/man1/$manpage.1
#		install -g 0 -o 0 -m 0644 $manpage.1 /usr/local/man/man1/
#		gzip /usr/local/man/man1/$manpage.1
#		echo "Manpage $manpage installed"
#	fi
#done

# this installation not require sudo
# firstly i find line in which i wrote the global help that 
# show all installed script
# 1) elimino l'help perchè dev'essere aggiornato
all_my_script="ams"
ams_cmd="alias $all_my_script=\"echo -e 'Following program are installed with manpage\nthat could be read adding man_ prefix to commands: "
# creo un backup degli alias
cp ~/.bash_aliases ~/.bash_aliases_old

cat ~/.bash_aliases | grep -v "alias $all_my_script=" > supp.txt
cat supp.txt > ~/.bash_aliases 
rm supp.txt

script_name=${0:2}
current_dir=$(dirname $0)

for manpage in $(ls $current_dir/ -l | grep ^- | awk '{print $9}' | grep -v "\w\.\w"); do
	if [ $manpage != $script_name ];then
		c=$(cat ~/.bash_aliases | grep "man_$manpage")
		# prendo tutti i file della directory tranne il file di script corrente
		if [[ $? = 1 ]];then
			# installo il programa creando l'alias
			prog=$(cat $current_dir/$manpage | head -n 1 | sed 's/^.\\\"//g')
			echo "alias $manpage=\"$prog\"" >> ~/.bash_aliases

			# installo il suo man come alias
			echo "alias man_$manpage=\"man $current_dir/$manpage\"" >> ~/.bash_aliases
			echo "Manpage $manpage installed as alias, call as man_$manpage"
		else
			echo "Manpage yet installed"
		fi
		ams_cmd=$(echo "$ams_cmd \n		$manpage")
	fi
done
echo "$ams_cmd \n ' \"" >> ~/.bash_aliases
echo "Restart terminal to update new man page"


