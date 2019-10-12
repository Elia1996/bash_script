#!/bin/bash

source ../lib/common.sh

echo $(sepf -v -f script.do -d new_scr.do -p Y,YMD,YMB -n 20,50,1996 -e )

