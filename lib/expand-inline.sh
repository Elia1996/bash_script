#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo $DIR
echo "${BASH_SOURCE[0]}"
echo "$( dirname "${BASH_SOURCE[0]}""
/usr/bin/gawk -f ~/script/lib/expand-inline.gawk $1
