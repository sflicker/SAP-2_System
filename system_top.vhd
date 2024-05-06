library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity system_top is
    port(
        i_clk : STD_LOGIC;
        i_reset : STD_LOGIC;
--        S1_addr_in : in STD_LOGIC_VECTOR(15 downto 0);       -- address setting - S1 in ref
        S2_prog_run_switch : in STD_LOGIC;       -- prog / run switch (prog=0, run=1)
--        S3_data_in : in STD_LOGIC_VECTOR(7 downto 0);       -- data setting      S3 in ref
        S4_read_write_switch : in STD_LOGIC;       -- read/write toggle   -- 1 to write values to ram. 0 to read. needs to be 0 for run mode
        S5_clear_start : in STD_LOGIC;       -- start/clear (reset)  -- 
        S6_step_toggle : in STD_LOGIC;       -- single step -- 1 for a single step
        S7_manual_auto_switch : in STD_LOGIC;       -- manual/auto mode - 0 for manual, 1 for auto. 

    );
end system_top;

architecture behavioral of system_top is
    signal w_clk_display_refresh_1kHZ : STD_LOGIC;
    signal w_processor_clock_1MHZ : STD_LOGIC;

begin
    display_clock_divider : entity work.clock_divider
        generic map(g_DIV_FACTOR => 100000)
        port map(
            i_clk => i_clk,
            i_reset => i_reset,
            o_clk => w_clk_display_refresh_1kHZ;
        );

    processor_clock_divider : entity work.clock_divider
        generic map(g_DIV_FACTOR => 100)
        port map(
            i_clk => i_clk,
            i_reset => i_reset,
            o_clk => w_processor_clock_1MHZ;
        );  

    processor_clock_controller : entity work.clock_controller
        port map (
            clk_in => w_processor_clock_1MHZ,
            prog_run_switch => S2_prog_run_switch,
            step_toggle => S6_step_toggle,
            manual_auto_switch => S7_manual_auto_switch,
            hltbar => hltbar_sig,
            clrbar => clrbar_sig,
            clk_out => clk_sys_sig,
            clkbar_out => clkbar_sys_sig
        );

    system_mem : entity work.ram_bank
        port map (
            i_clk =>
            i_addr =>
            i_data =>
            i_write_enable =>
            o_data =>
        );

end behavioral;