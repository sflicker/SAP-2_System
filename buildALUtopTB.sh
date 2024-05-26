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
ghdl -a --std=08 -fsynopsys -v debouncer.vhd
ghdl -a --std=08 -fsynopsys -v ALU.vhd
ghdl -a --std=08 -fsynopsys -v ALU_top.vhd
ghdl -a --std=08 -fsynopsys -v ALU_top_tb.vhd
#echo "Running Test Bench"
#run
ghdl -e --std=08 -fsynopsys -v ALU_top_tb

ghdl -r --std=08 -fsynopsys -v ALU_top_tb --stop-time=1750ms --vcd=ALU_top_tb.vcd
