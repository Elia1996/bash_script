#!/bin/bash
alias la="ls -al"
alias anni="cd ~/Scrivania/materie/Anni"
alias anno="cd ~/Scrivania/IV_Anno"
alias ise="cd ~/Scrivania/IV_Anno/Integrazione_di_sistemi_embedded/Laboratori"
alias scriptbash="cd /media/tesla/Storage/Linux/Scrivania/materie/Bash/script_bash"
alias c-='echo $PWD >> ~/.aliases_pwd_swap; cd ../'
alias c--='cd ../../'
alias c3-='cd ../../../'
alias c4-='cd ../../../../'
alias c5-='cd ../../../../../'
alias new_alias="vim ~/.bash_aliases"
alias nanoic="nano -i -c"
alias scri="cd ~/Scrivania"
alias usrbin="cd /usr/bin"
alias polito="firefox --new-tab https://idp.polito.it/idp/x509mixed-login"
alias c+='if [[ `wc -l ~/.aliases_pwd_swap | cut -d " " -f 1` -ne 0 ]];\
then cd `tail -n 1 ~/.aliases_pwd_swap`;\
head -n -1 ~/.aliases_pwd_swap > ~/.alias_swap;\
cat ~/.alias_swap > ~/.aliases_pwd_swap;\
else echo "empty stack of directory"; fi'

alias hk='cd ~/Scrivania/materie/HHK'
alias hsdft='cd ~/Scrivania/healt_Shirt/Battito_Cardiaco/C/DFT'
alias grepc='grep --color'
alias Prog='cd ~/Scrivania/Progetti_work'
alias pyprog='cd ~/Scrivania/Progetti_work/Anni/I_Magistrale/ISE/python'

alias setlinux='echo $PWD >> ~/.aliases_pwd_swap; \
cd /home/tesla/Scrivania/Progetti_work/setlinux;\
./setlinux.sh ;\
cd `tail -n 1 ~/.aliases_pwd_swap`;\
head -n -1 ~/.aliases_pwd_swap > ~/.alias_swap;\
cat ~/.alias_swap > ~/.aliases_pwd_swap;'

