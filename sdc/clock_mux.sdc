###############################################################################
# Created by write_sdc
# Tue Dec  6 02:34:59 2022
###############################################################################
current_design clock_mux
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name core_clock -period 25.0000 [get_ports {core_clock}]
set_clock_transition 0.1500 [get_clocks {core_clock}]
set_clock_uncertainty 0.5000 core_clock
set_propagated_clock [get_clocks {core_clock}]
create_clock -name io_clock -period 25.0000 [get_ports {io_clock}]
set_clock_transition 0.1500 [get_clocks {io_clock}]
set_clock_uncertainty 0.5000 io_clock
set_propagated_clock [get_clocks {io_clock}]
create_clock -name clock_out_a -period 25.0000 [get_ports {clock_out_a}]
set_clock_transition 0.1500 [get_clocks {clock_out_a}]
set_clock_uncertainty 0.5000 clock_out_a
set_propagated_clock [get_clocks {clock_out_a}]
create_clock -name clock_out_b -period 25.0000 [get_ports {clock_out_b}]
set_clock_transition 0.1500 [get_clocks {clock_out_b}]
set_clock_uncertainty 0.5000 clock_out_b
set_propagated_clock [get_clocks {clock_out_b}]
create_clock -name clock_out_c -period 25.0000 [get_ports {clock_out_c}]
set_clock_transition 0.1500 [get_clocks {clock_out_c}]
set_clock_uncertainty 0.5000 clock_out_c
set_propagated_clock [get_clocks {clock_out_c}]
set_input_delay 5.0000 -clock [get_clocks {core_clock}] -rise -max -add_delay [get_ports {la_oenb}]
set_input_delay 5.0000 -clock [get_clocks {core_clock}] -fall -max -add_delay [get_ports {la_oenb}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0729 [get_ports {clock_out_a}]
set_load -pin_load 0.0729 [get_ports {clock_out_b}]
set_load -pin_load 0.0729 [get_ports {clock_out_c}]
set_driving_cell -lib_cell gf180mcu_fd_sc_mcu7t5v0__inv_4 -pin {ZN} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {clock_out_a}]
set_driving_cell -lib_cell gf180mcu_fd_sc_mcu7t5v0__inv_4 -pin {ZN} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {clock_out_b}]
set_driving_cell -lib_cell gf180mcu_fd_sc_mcu7t5v0__inv_4 -pin {ZN} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {clock_out_c}]
set_timing_derate -early 0.9500
set_timing_derate -late 1.0500
###############################################################################
# Design Rules
###############################################################################
set_max_fanout 4.0000 [current_design]
