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
report_area
report_area > FSM_ADDER-area-simple.txt
report_fsm
report_fsm > FSM_ADDER-fsm-simple.txt
uplevel #0 { report_timing -path full -delay max -nworst 1 -max_paths 1 -significant_digits 2 -sort_by group }
report_timing > FSM_ADDER-timing-simple.txt
gui_show_man_page report_timing
report_timing -nworst 10
report_timing -nworst 3
report_timing -nworst 3
power_repoer
power_report
report_power
report_power -hier
report_power -hier
report_power -net
list_design
list_designs
current instance FSM
current instance fsm_adder
current_instance fsm_adder
current_instance fsm
report_costraints
report_constraints