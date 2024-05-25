#!/bin/bash

echo "Starting Test Bench Script"
echo "Cleaning project"

#clean existing
ghdl --clean

echo "Compiling modules"
#compile

ghdl -a --std=08 -fsynopsys -v clock.vhd
ghdl -a --std=08 -fsynopsys -v clock_divider.vhd
ghdl -a --std=08 -fsynopsys -v segment_decoder.vhd
ghdl -a --std=08 -fsynopsys -v digit_multiplexer.vhd
ghdl -a --std=08 -fsynopsys -v display_controller.vhd
ghdl -a --std=08 -fsynopsys -v up_down_toggle_debouncer.vhd
ghdl -a --std=08 -fsynopsys -v ALU.vhd
ghdl -a --std=08 -fsynopsys -v ALU_top.vhd
#echo "Running Test Bench"
#run


#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb --stop-time=5ms --vcd=system_top_filebased_tb.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/test_program_1.asm" --stop-time=5ms --vcd=system_top_test_program_1.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/load_accumulator_test.asm" --stop-time=5ms --vcd=system_top_load_accumulator_test.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/store_accumulator_test.asm" --stop-time=5ms --vcd=system_top_store_accumulator_test.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/mvi_test.asm" --stop-time=5ms --vcd=system_top_mvi_test.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/jump_test.asm" --stop-time=5ms --vcd=system_top_jump_test.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/loop_test.asm" --stop-time=5ms --vcd=system_top_loop_test.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/loop_test_with_output.asm" --stop-time=5ms --vcd=system_top_loop_test_with_output.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/out_test.asm" --stop-time=5ms --vcd=system_top_out_test.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/out_test2.asm" --stop-time=5ms --vcd=system_top_out_test2.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/call_test.asm" --stop-time5ms --vcd=system_top_call_test.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/a_ana_c_test.asm" --stop-time=5ms --vcd=system_top_a_ana_c_test.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/add_b_test.asm" --stop-time=5ms --vcd=system_top_add_b_test.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/add_c_test.asm" --stop-time=5ms --vcd=system_top_add_c_test.vcd

