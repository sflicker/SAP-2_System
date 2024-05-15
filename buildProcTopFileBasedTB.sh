#!/bin/bash

echo "Starting Test Bench Script"
echo "Cleaning project"

#clean existing
ghdl --clean

echo "Compiling modules"
#compile

ghdl -a --std=08 -fsynopsys -v clock.vhd
#ghdl -a --std=08 -fsynopsys -v single_pulse_generator.vhd
ghdl -a --std=08 -fsynopsys -v clock_converter.vhd
ghdl -a --std=08 -fsynopsys -v StatusRegister.vhd
ghdl -a --std=08 -fsynopsys -v memory_data_register.vhd
ghdl -a --std=08 -fsynopsys -v ProgramCounter.vhd
ghdl -a --std=08 -fsynopsys -v passthrough_clock_converter.vhd
ghdl -a --std=08 -fsynopsys -v clock_controller.vhd
ghdl -a --std=08 -fsynopsys -v segment_decoder.vhd
ghdl -a --std=08 -fsynopsys -v digit_multiplexer.vhd
ghdl -a --std=08 -fsynopsys -v display_controller.vhd
ghdl -a --std=08 -fsynopsys -v memory_input_multiplexer.vhd
ghdl -a --std=08 -fsynopsys -v IO_controller.vhd
ghdl -a --std=08 -fsynopsys -v StackPointer.vhd
#ghdl -a --std=08 -fsynopsys -v input_port_multiplexer.vhd
#ghdl -a --std=08 -fsynopsys -v ring_counter_6bit.vhd

ghdl -a --std=08 -fsynopsys -v register.vhd
#ghdl -a --std=08 -fsynopsys -v accumulator.vhd
#ghdl -a --std=08 -fsynopsys -v address_rom.vhd
ghdl -a --std=08 -fsynopsys -v ALU.vhd
#ghdl -a --std=08 -fsynopsys -v b.vhd
#ghdl -a --std=08 -fsynopsys -v controller_rom.vhd
#ghdl -a --std=08 -fsynopsys -v IR.vhd
ghdl -a --std=08 -fsynopsys -v IR_operand_latch.vhd
#ghdl -a --std=08 -fsynopsys -v mar.vhd
#ghdl -a --std=08 -fsynopsys -v pc.vhd
#ghdl -a --std=08 -fsynopsys -v output.vhd
#ghdl -a --std=08 -fsynopsys -v presettable_counter.vhd
ghdl -a --std=08 -fsynopsys -v ram_bank.vhd
ghdl -a --std=08 -fsynopsys -v w_bus.vhd
ghdl -a --std=08 -fsynopsys -v proc_controller.vhd
ghdl -a --std=08 -fsynopsys -v proc_top.vhd
ghdl -a --std=08 -fsynopsys -v proc_top_filebased_tb.vhd
#

ghdl -e --std=08 -fsynopsys -v proc_top_filebased_tb

echo "Running Test Bench"
#run
ghdl -r --std=08 -fsynopsys -v proc_top_filebased_tb -gfile_name="asm_test_files/test_program_1.asm" --stop-time=100000ns --vcd=proc_top_test_program_1.vcd
ghdl -r --std=08 -fsynopsys -v proc_top_filebased_tb -gfile_name="asm_test_files/load_accumulator_test.asm" --stop-time=20000ns --vcd=proc_top_load_accumulator_test.vcd
ghdl -r --std=08 -fsynopsys -v proc_top_filebased_tb -gfile_name="asm_test_files/store_accumulator_test.asm" --stop-time=20000ns --vcd=proc_top_store_accumulator_test.vcd
ghdl -r --std=08 -fsynopsys -v proc_top_filebased_tb -gfile_name="asm_test_files/mvi_test.asm" --stop-time=20000ns --vcd=proc_top_mvi_test.vcd
ghdl -r --std=08 -fsynopsys -v proc_top_filebased_tb -gfile_name="asm_test_files/jump_test.asm" --stop-time=20000ns --vcd=proc_top_jump_test.vcd
ghdl -r --std=08 -fsynopsys -v proc_top_filebased_tb -gfile_name="asm_test_files/loop_test.asm" --stop-time=100000ns --vcd=proc_top_loop_test.vcd
ghdl -r --std=08 -fsynopsys -v proc_top_filebased_tb -gfile_name="asm_test_files/loop_test_with_output.asm" --stop-time=proc_top_150000ns --vcd=loop_test_with_output.vcd
ghdl -r --std=08 -fsynopsys -v proc_top_filebased_tb -gfile_name="asm_test_files/out_test.asm" --stop-time=10000ns --vcd=proc_top_out_test.vcd
ghdl -r --std=08 -fsynopsys -v proc_top_filebased_tb -gfile_name="asm_test_files/out_test2.asm" --stop-time=10000ns --vcd=proc_top_out_test2.vcd
ghdl -r --std=08 -fsynopsys -v proc_top_filebased_tb -gfile_name="asm_test_files/call_test.asm" --stop-time=250000ns --vcd=proc_top_call_test.vcd
ghdl -r --std=08 -fsynopsys -v proc_top_filebased_tb -gfile_name="asm_test_files/a_ana_c_test.asm" --stop-time=250000ns --vcd=proc_top_a_ana_c_test.vcd




