# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
#source root-6.06.02/bin/thisroot.sh

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
#if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
#    debian_chroot=$(cat /etc/debian_chroot)
#fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    #PS1='${debian_chroot:+($debian_chroot)}\[\e[1;32m\]\u@\h\[\e[1;32m\]:\[\e[1;34m\]\w\[\e[1;34m\]\$\[\e[1;34m\] '
    PS1='${debian_chroot:+($debian_chroot)}\[\e[1;32m\]\u@\h\[\e[1;32m\]:\[\e[1;34m\]\$\[\e[1;34m\] '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac



# some more ls aliases
alias ll='ls -l'
alias la='ls -a'
alias l='ls -CF'

# colori per ls
# u -> underlined
# s -> sfumato
# b -> bold
# [color_simble]_ -> sfondo
# s[color_simble]_ -> sfondo sfumato
# l'ordine è:   s[color_name]_usb[color_name]
# ROSSO
red='0;31'
bred='1;31'
sred='0;91'
sbred='1;91' 
# VERDE
green='0;32'
bgreen='1;32'
sgreen='0;92'
sbgreen='1;92'
# GIALLO
yellow='0;33'
byellow='1;33'
syellow='0;93'
sbyellow='1;93'
# BLU
blue='0;34'
bblue='1;34'
sblue='0;94'
sbblue='1;94'
# VIOLA 
purple='0;35'
bpurple='1;35'
spurple='0;95'
sbpurple='1;95'
# CIANO
cyan='0;36'
bcyan='1;36'
scyan='0;96'
sbcyan='1;96'
# BIANCO
white='0;37'
bwhite='1;37'
swhite='0;97'
sbwhite='1;97'
# BIANCO SU ROSSO
red_white='0;41'
red_bwhite='1;41'
sred_white='0;101'
sred_bwhite='1;101'
# BIANCO SU VERDE
green_white='0;42'
green_bwhite='1;42'
sgreen_white='0;102'
sgreen_bwhite='1;102'
# BIANCO SU BLU
blue_white='0;44'
blue_bwhite='1;44'
sblue_white='0;104'
sblue_bwhite='1;10'
# BIANCO SU VIOLA
purple_white='0;45'
purple_bwhite='1;45'
spurple_white='0;105'
spurple_bwhite='1;105'
# BIANCO SU GIALLO
yellow_white='0;43'
yellow_bwhite='1;43'
syellow_white='0;103'
syellow_bwhite='1;103'
# BIANCO SU CIANO
cyan_white='0;46'
cyan_bwhite='1;46'
scyan_white='0;106'
scyan_white='1;106'
# 
# 
#sed -e "s/\s/=/g" ~/.dircolors | sed ':a;N;$!ba;s/\n/:/g' | sed "s/\./\*./g" > ~/ndircolors
#chmod 777 ~/ndircolors
# tolgo i commenti
cut -d "#" -f 1 ~/.dircolors > ~/supp2
# tolgo gli a capi
sed 's/\s/\n/g' ~/supp2 | grep "[^ $]" > ~/supp
rm supp2
stringa=""
bol=0;
while read arg
do
    if [[ ${arg:0:1} = '$' ]]
    then
        arg=${arg:1}
        var=$(cat .bashrc | grep $arg | sed "1q" | cut -d "=" -f 2 | sed "s/'//g") 
        stringa="$stringa$var:"
        bol=0;
    else
        if [[ $bol = 0 ]]
        then   
            stringa="$stringa$arg="
            bol=1
        else
            stringa="$stringa$arg:"
            bol=0
        fi
    fi
done < supp
echo $stringa > supp
sed "s/\./\*./g" supp > supp2 
stringa=$(cat supp2)
rm supp2
rm supp
LS_COLORS=$stringa
export LS_COLORS
export EDITOR=vim
alias ls='ls --color=auto'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


################   COLORI    ############
# Reset
Color_Off='\e[0m'       # Text Reset

# Regular Colors
Black='\e[0;30m'        # Nero
Red='\e[0;31m'          # Rosso
Green='\e[0;32m'        # Verde
Yellow='\e[0;33m'       # Giallo
Blue='\e[0;34m'         # Blu
Purple='\e[0;35m'       # Viola
Cyan='\e[0;36m'         # Ciano
White='\e[0;37m'        # Bianco

# Bold
BBlack='\e[1;30m'       # Nero
BRed='\e[1;31m'         # Rosso
BGreen='\e[1;32m'       # Verde
BYellow='\e[1;33m'      # BBlue
Giallo='\e[1;34m'        # Blu
BPurple='\e[1;35m'      # Viola
BCyan='\e[1;36m'        # Ciano
BWhite='\e[1;37m'       # Bianco

# Underline
UBlack='\e[4;30m'       # Nero
URed='\e[4;31m'         # Rosso
UGreen='\e[4;32m'       # Verde
UYellow='\e[4;33m'      # Giallo
UBlue='\e[4;34m'        # Blu
UPurple='\e[4;35m'      # Viola
UCyan='\e[4;36m'        # Ciano
UWhite='\e[4;37m'       # Bianco

# Background
On_Black='\e[40m'       # Nero
On_Red='\e[41m'         # Rosso
On_Green='\e[42m'       # Verde
On_Yellow='\e[43m'      # Giallo
On_Blue='\e[44m'        # Blu
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Ciano
On_White='\e[47m'       # Bianco

# High IBlack
Intensty='\e[0;90m'       # Nero
IRed='\e[0;91m'         # Rosso
IGreen='\e[0;92m'       # Verde
IYellow='\e[0;93m'      # Giallo
IBlue='\e[0;94m'        # Blu
IPurple='\e[0;95m'      # Viola
ICyan='\e[0;96m'        # Ciano
IWhite='\e[0;97m'       # Bianco

# Bold High Intensty
BIBlack='\e[1;90m'      # Nero
BIRed='\e[1;91m'        # Rosso
BIGreen='\e[1;92m'      # Verde
BIYellow='\e[1;93m'     # Giallo
BIBlue='\e[1;94m'       # Blu
BIPurple='\e[1;95m'     # Viola
BICyan='\e[1;96m'       # Ciano
BIWhite='\e[1;97m'      # Bianco

# High Intensty backgrounds
On_IBlack='\e[0;100m'   # Nero
On_IRed='\e[0;101m'     # Rosso
On_IGreen='\e[0;102m'   # Verde
On_IYellow='\e[0;103m'  # Giallo
On_IBlue='\e[0;104m'    # Blu
On_IPurple='\e[10;95m'  # Viola
On_ICyan='\e[0;106m'    # Ciano
On_IWhite='\e[0;107m'   # Bianco

export BASHLIB="/home/tesla/Scrivania/Progetti_work/bash_script/lib/common.sh"
~/script/set_linux/conf_file/.initbash.user
