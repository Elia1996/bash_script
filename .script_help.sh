#!/bin/bash
help_str="
auto_param_sim
	 simulazione parametrica automatizzata, questo programma prende uno script
	 qualsiasi e il nome 
	 $1 nome script
	 $2 modalità
	 	le modalità sono le seguenti:
			-exe modalità di esecuzione immediata, dev'essere fornito anche il
				nome del programma da utilizzare per ogni file 
				 $1 nome programma
			-gen generazione dei file parametrici, in questo caso vengono solo 
				 generati tutti i file parametrici da quello originario
	 [ARGOMENTI VARIABILI]
	 	  questi argomenti possono essere messi in un ordine qualsiasi 
	 	  -s -> step
					\$1 parameter_name
	 				\$2 start
	 				\$3 step
	 				\$4 end
	 	  -c -> custom 
				effettua una simulazione parametrica usando i valori dati
					\$1 parameter_name
					\$2 primo
	 				...
	  				\$n ultimo
		  -p -> parametro 
		  		dev'essere la prima opzione
		  		sostituisce senza parametrizzare
					\$1 parameter_name
					\$2 value
	
		Non si possono fare simultaneamente le simulazioni custom e step 
		per il momento. ma solo una di esse alla volta


pow_process	
		[Description]
		Questo script elabora file provenienti da Synopsys 
		che descrivono le transizioni dei segnali all'interno
		di un circuito digitale, dato quindi il clock lo 
		script elabora la switching activity dei vari nodi
		indicati da linea di comando.
		La frequenza di clock e il numero di transizioni
		totale è preso dal file senza che venga specificato
		ciò vuol dire che se 
	[SYNOPSYS]
		
	
"
