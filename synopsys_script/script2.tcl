gui_start
analyze -library WORK -format vhdl {/home/lp19.10/Desktop/lab2/syn/fsm_gray.vhd /home/lp19.10/Desktop/lab2/syn/dpadder.vhd /home/lp19.10/Desktop/lab2/syn/FSM_ADDER.vhd}
elaborate FSM_ADDER -architecture BEHAVIORAL -library WORK
create clock -name ?CLK? -period 10 {clock}
create_clock -name "CLK" -period 10 {clock}
create_clock -name "CLK" -period 10 {CLK}
gui_show_man_page report_clock
report_clock
compile -exact_map
write -hierarchy -format ddc -output /home/lp19.10/Desktop/lab2/syn/FSM_ADDER-simple.ddc
read_file -format ddc {/home/lp19.10/Desktop/lab2/syn/FSM_ADDER-simple.ddc}
write -hierarchy -format vhdl -output /home/lp19.10/Desktop/lab2/syn/FSM_ADDER-simple.vhdl
