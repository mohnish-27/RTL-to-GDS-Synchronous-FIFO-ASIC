# RTL Script to run Basic Synthesis Flow
set_db init_lib_search_path /home/install/FOUNDRY/digital/90nm/dig/lib   
#set_db hdl_search_path /home/systempep/Documents/MohnishFIFO


set_db library slow.lib
read_hdl Fifosync.v
elaborate 
read_sdc /home/systempep/Documents/MohnishFIFO/constraints.sdc
set_db syn_generic_effort medium
syn_generic
set_db syn_map_effort medium
syn_map
set_db syn_opt_effort medium
syn_opt


write_hdl > Fifosync_netlist.v
write_sdc > Fifosync_block.sdc
report_area > Fifosync_area.rep
report_gates > Fifosync_gate.rep
report_power > Fifosync_power.rep
report_timing > Fifosync_timing.rep
gui_show


