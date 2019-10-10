#!/bin/bash

# 1     #####################################################
# CONFIGURATION OF HIDDEN FILE NEEDED FOR ENVIRONMENT
# alias and others

# See this site: https://www.howtogeek.com/howto/35807/how-to-harmonize-your-dual-boot-setup-for-windows-and-ubuntu/
# to more info.

# This file should be in directory of script:
#   .bashrc
#   .bash_aliases
#   .alias_swap
#   .vimrc
#   .dircolors

# 1.1    ####################################################
# VARIABLE

hid_dir="conf_file"

# 1.2    ####################################################
# SCRIPT
cp ./$hid_dir/.bashrc ~
cp ./$hid_dir/.bash_aliases ~
cp ./$hid_dir/.alias_swap ~
cp ./$hid_dir/.vimrc ~
cp ./$hid_dir/.dircolors ~

echo "export BASHLIB='/home/tesla/Scrivania/Progetti_work/bash_script/lib/common.sh'" >> ~/.bashrc
