create_clock -name CLK -period 10 [get_ports clk]
set_input_delay 2 -clock CLK [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 2 -clock CLK [all_outputs]
set_drive 0.2 [remove_from_collection [all_inputs] [get_ports clk]]
set_load 0.1 [all_outputs]
set_false_path -from [get_ports reset]
set_false_path -to [get_ports reset]
set_input_transition 0.1 [remove_from_collection [all_inputs] [get_ports clk]]
report_clocks
report_port -verbose
report_timing -max_paths 5
