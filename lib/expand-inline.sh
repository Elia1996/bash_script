#!/usr/bin/gawk -f
{
	# i find all $(.*) statement and save it in arr
	match($0,/\$\([^\)]*\)/,arr);
	while (length(arr)!=0){ 
		cmd=substr(arr[0],3,length(arr[0])-3); 
		newcmd="echo $(("cmd"))"
		newcmd | getline var
		sub(/\$\([^\)]*\)/,var,$0) 
		match($0,/\$\([^\)]*\)/,arr)
	}
	{print }
}
