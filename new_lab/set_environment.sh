#!/bin/bash

set_environment () {
	echo "#!/bin/bash" > file.txt
	cat /home/mg.lowpower/.initbash.user | sed 's/alias //g' | sed '/^#.*$/d' | sed '/^$/d' | sed '/^PS1.*$/d' >> file.txt
	source file.txt
	rm file.txt
}
setmentor () {
   set_environment
   $setmentor
}
setsynopsys () {
   set_environment
   $setsynopsys
}
