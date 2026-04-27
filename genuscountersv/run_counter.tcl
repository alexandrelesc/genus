set LOCAL_DIR [exec pwd]
set RTL_PATH  $LOCAL_DIR/source
set LIB_PATH  $LOCAL_DIR/library

set LIBRARY   fast.lib
set RTL_FILE  counter.sv
set DESIGN    counter

set DATE [clock format [clock seconds] -format "%b%d-%H-%M-%S"]

set OUT_DIR outputs_$DATE
set REP_DIR reports_$DATE

file mkdir $OUT_DIR
file mkdir $REP_DIR

read_lib $LIB_PATH/$LIBRARY
read_hdl -sv $RTL_PATH/$RTL_FILE

elaborate $DESIGN
current_design $DESIGN

check_design -unresolved

create_clock -name clk -period 10 [get_ports clk]
set_input_delay 1 -clock clk     [remove_from_collection [all_inputs] [get_ports {clk rst}]]
set_output_delay 1 -clock clk [all_outputs]

syn_gen
syn_map
syn_opt

report area   > $REP_DIR/${DESIGN}_area.rpt
report power  > $REP_DIR/${DESIGN}_power.rpt
report gates  > $REP_DIR/${DESIGN}_gates.rpt
report timing > $REP_DIR/${DESIGN}_timing.rpt

write_hdl > $OUT_DIR/${DESIGN}_netlist.v
write_sdc > $OUT_DIR/${DESIGN}.sdc

exit
