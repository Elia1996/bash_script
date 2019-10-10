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
run 200ns
#power report -file pow200ns_rep_100_2ns.txt

