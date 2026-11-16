# ZC706 starter overlay; rebuild all hardware artefacts together with Vivado 2024.1.
if {[version -short] ne "2024.1"} {error "This image port requires Vivado 2024.1"}
set script_dir [file dirname [file normalize [info script]]]
cd $script_dir
create_project -force zc706 ./project -part xc7z045ffg900-2
set_property board_part xilinx.com:zc706:part0:1.4 [current_project]
create_bd_design base
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 ps7
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable"} [get_bd_cells ps7]
set_property -dict [list CONFIG.PCW_USE_M_AXI_GP0 {1} CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {50.000000}] [get_bd_cells ps7]
foreach {name iface width output} {leds_gpio led_4bits 4 1 switches_gpio dip_switches_4bits 4 0 buttons_gpio gpio_sws_3bits 3 0} {
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 $name
    set_property -dict [list CONFIG.C_GPIO_WIDTH $width CONFIG.C_ALL_OUTPUTS $output CONFIG.C_ALL_INPUTS [expr {!$output}]] [get_bd_cells $name]
    apply_bd_automation -rule xilinx.com:bd_rule:board -config [list Board_Interface $iface] [get_bd_intf_pins $name/GPIO]
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/ps7/M_AXI_GP0" Clk "Auto"} [get_bd_intf_pins $name/S_AXI]
}
assign_bd_address
# Keep core names distinct from external board-interface names for PYNQ metadata.
foreach {name offset} {leds_gpio 0x41200000 switches_gpio 0x41210000 buttons_gpio 0x41220000} {
    assign_bd_address -force -offset $offset -range 0x10000 -target_address_space [get_bd_addr_spaces ps7/Data] [get_bd_addr_segs $name/S_AXI/Reg]
}
validate_bd_design
save_bd_design
set bd [get_files */base.bd]
set wrapper [make_wrapper -files $bd -top]
add_files -norecurse $wrapper
set_property top base_wrapper [current_fileset]
update_compile_order -fileset sources_1
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} {error "Implementation failed"}
open_run impl_1
report_timing_summary -file timing-summary.rpt -warn_on_violation
report_drc -file drc.rpt
set path [get_timing_paths -max_paths 1 -nworst 1]
if {[llength $path] == 0} {error "No timed paths: cannot accept implementation"}
if {[get_property SLACK $path] < 0} {error "Timing failed"}
set errors [get_drc_violations -quiet -filter {SEVERITY == Error}]
if {[llength $errors] != 0} {error "DRC errors: $errors"}
write_hw_platform -fixed -include_bit -force -file base.xsa
file copy -force ./project/zc706.runs/impl_1/base_wrapper.bit base.bit
file copy -force ./project/zc706.gen/sources_1/bd/base/hw_handoff/base.hwh base.hwh
puts "ZC706_HARDWARE_BUILD_PASS"
