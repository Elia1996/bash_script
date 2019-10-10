vcom fd.vhd
vcom ha.vhd
vcom counter.vhd
vcom tb_counter.vhd

vsim -t 1ps -novopt work.testcount(test)
add wave *
add wave \{sim:/testcount/ucounter1/ctmp}
add wave \{sim:/testcount/ucounter1/stmp}
add wave \{sim:/testcount/ucounter1/stmpsync}
power add /testcount/UCOUNTER1/*
run $(NCICLI*TCLK)ns
#power report -file pow$(NCICLI*TCLK)ns_rep_NCICLI_TCLKns.txt

