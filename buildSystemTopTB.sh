#!/bin/bash

echo "Starting Test Bench Script"
echo "Cleaning project"

#clean existing
ghdl --clean

echo "Compiling modules"
#compile

ghdl -a --std=08 -fsynopsys -v clock.vhd
ghdl -a --std=08 -fsynopsys -v clock_divider.vhd
ghdl -a --std=08 -fsynopsys -v program_counter.vhd
ghdl -a --std=08 -fsynopsys -v passthrough_clock_converter.vhd
ghdl -a --std=08 -fsynopsys -v clock_controller.vhd
ghdl -a --std=08 -fsynopsys -v segment_decoder.vhd
ghdl -a --std=08 -fsynopsys -v digit_multiplexer.vhd
ghdl -a --std=08 -fsynopsys -v display_controller.vhd
ghdl -a --std=08 -fsynopsys -v memory_input_multiplexer.vhd
ghdl -a --std=08 -fsynopsys -v stack_pointer.vhd
ghdl -a --std=08 -fsynopsys -v data_register.vhd
ghdl -a --std=08 -fsynopsys -v instruction_register.vhd
ghdl -a --std=08 -fsynopsys -v ALU.vhd
ghdl -a --std=08 -fsynopsys -v IO_controller.vhd
ghdl -a --std=08 -fsynopsys -v memory_loader.vhd
ghdl -a --std=08 -fsynopsys -v reset_command.vhd
ghdl -a --std=08 -fsynopsys -v uart_rx.vhd
ghdl -a --std=08 -fsynopsys -v uart_tx.vhd
ghdl -a --std=08 -fsynopsys -v ram_bank.vhd
ghdl -a --std=08 -fsynopsys -v internal_bus.vhd
#ghdl -a --std=08 -fsynopsys -v command_processor.vhd
#ghdl -a --std=08 -fsynopsys -v status_register.vhd
ghdl -a --std=08 -fsynopsys -v proc_controller.vhd
ghdl -a --std=08 -fsynopsys -v proc_top.vhd
ghdl -a --std=08 -fsynopsys -v system_top.vhd
ghdl -a --std=08 -fsynopsys -v system_top_filebased_tb.vhd
ghdl -e --std=08 -fsynopsys -v system_top_filebased_tb

#echo "Running Test Bench"
#run

 test_dir="./asm_test_files"

for file in "$test_dir"/test*.asm; do
     echo file="$file"
    
     base_name=$(basename $file .asm)
     echo base_name=$base_name

     vcd_file=${base_name}.vcd
     echo vcd_file=$vcd_file
    
     vcd_dir=./vcd_files
     echo vcd_dir=$vcd_dir

     vcd_path=${vcd_dir}/${vcd_file}
     echo vcd_path=vc$vcd_path
    
     ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name=$file --stop-time=5ms --vcd=$vcd_path
done



#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb --stop-time=5ms --vcd=system_top_filebased_tb.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/test_cma_a_AA_expect_55.asm" --stop-time=5ms --vcd=test_cma_a_AA_expect_55.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/test_call_expect_20.asm" --stop-time=5ms --vcd=test_call_expect_20.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/test_inr_c_53_expect_54.asm" --stop-time=5ms --vcd=test_inr_c_53_expect_54.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/test_mov_expect_FF.asm" --stop-time=5ms --vcd=test_mov_expect_FF.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/test_out_expect_48.asm" --stop-time=5ms --vcd=test_out_expect_48.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/test_jz_expect_12.asm" --stop-time=5ms --vcd=test_jz_expect_12.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/test_jnz_expect_12.asm" --stop-time=5ms --vcd=test_jnz_expect_12.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/loop_test.asm" --stop-time=5ms --vcd=system_top_loop_test.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/loop_test_with_output.asm" --stop-time=5ms --vcd=system_top_loop_test_with_output.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/out_test.asm" --stop-time=5ms --vcd=system_top_out_test.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/out_test2.asm" --stop-time=5ms --vcd=system_top_out_test2.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/call_test.asm" --stop-time=10ms --vcd=system_top_call_test.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/a_ana_c_test.asm" --stop-time=5ms --vcd=system_top_a_ana_c_test.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/add_b_test.asm" --stop-time=5ms --vcd=system_top_add_b_test.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/add_c_test.asm" --stop-time=5ms --vcd=system_top_add_c_test.vcd

#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/test_acc_10_dec_result_0F.asm" --stop-time=5ms --vcd=test_acc_10_dec_result_0F.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/test_acc_53_inc_result_54.asm" --stop-time=5ms --vcd=test_acc_53_inc_result_54.vcd
#ghdl -r --std=08 -fsynopsys -v system_top_filebased_tb -gfile_name="asm_test_files/test_sub_a_90_b_28_expect_68.asm" --stop-time=5ms --vcd=test_sub_a_90_b_28_expect_68.vcd
