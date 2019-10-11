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
script_name=${0:2}
current_dir=$(pwd)
for manpage in `ls`; do
	if [ $manpage != $script_name ];then
		c=$(cat ~/.bash_aliases | grep "man_$manpage")
		if [[ $? = 1 ]];then
			echo "alias man_$manpage=\"man $current_dir/$manpage\"" >> ~/.bash_aliases
			echo "Manpage $manpage installed as alias, call as man_$manpage"
		else
			echo "Manpage yet installed"
		fi
	fi
done
echo "Restart terminal to update new man page"


