#!/bin/bash

echo "Starting Test Bench Script"
echo "Cleaning project"

#clean existing
ghdl --clean

echo "Compiling modules"
#compile

ghdl -a --std=08 -fsynopsys -v clock.vhd
ghdl -a --std=08 -fsynopsys -v debouncer.vhd
ghdl -a --std=08 -fsynopsys -v debouncer_tb.vhd
#echo "Running Test Bench"
#run
ghdl -e --std=08 -fsynopsys -v debouncer_tb

ghdl -r --std=08 -fsynopsys -v debouncer_tb --stop-time=50ms --vcd=debouncer_tb.vcd
