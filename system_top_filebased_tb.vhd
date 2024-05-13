library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

entity system_top_filebased_tb is
    Generic (
        file_name : String := "asm_test_files/test_program_1.txt"
    );
end system_top_filebased_tb;

architecture test of system_top_filebased_tb is
    signal w_clk : std_logic;
    signal r_reset : std_logic := '0';
    signal r_prog_run_switch : std_logic := '0';
    signal r_read_write_switch : STD_LOGIC := '0';
    signal r_clear_start : std_logic := '0';
    signal r_step_toggle : std_logic := '0';
    signal r_manual_auto_switch : std_logic := '0';
    signal r_rx_serial : std_logic := '0';
    signal w_tx_serial : std_logic;
    signal w_seven_segment_anodes : STD_LOGIC_VECTOR(3 downto 0);
    signal w_seven_segment_cathodes : STD_LOGIC_VECTOR(6 downto 0);
begin


    clock : entity work.clock
    port map(
        o_clk => w_clk
    );
    
    system_top : entity work.system_top
    port map (
        i_clk => w_clk,
        i_reset => r_reset,
        s2_prog_run_switch => r_prog_run_switch,
        S4_read_write_switch => r_read_write_switch,
        S5_clear_start => r_clear_start,
        S6_step_toggle => r_step_toggle,
        S7_manual_auto_switch => r_manual_auto_switch,
        i_rx_serial => r_rx_serial,
        o_tx_serial => w_tx_serial,
        o_seven_segment_anodes => w_seven_segment_anodes,
        o_seven_segment_cathodes => w_seven_segment_cathodes
    );

end test;