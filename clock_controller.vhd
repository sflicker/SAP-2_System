library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity clock_controller is

    Port(
        i_clk : IN STD_LOGIC;
        i_prog_run_switch : IN STD_LOGIC;  -- prog / run switch (prog=0, run=1)
        i_step_toggle : IN STD_LOGIC;        -- single step  when high
        i_manual_auto_switch : IN STD_LOGIC;        -- manual/auto mode. 0 manual, 1 auto
        i_hltbar : in STD_LOGIC;      -- 
        i_clrbar : in STD_LOGIC;
        o_clk : OUT STD_LOGIC;
        o_clkbar : OUT STD_LOGIC
    );
end clock_controller;

architecture rtl of clock_controller is
    signal r_manual_or_auto_w_h : STD_LOGIC;
    signal r_auto_w_h : STD_LOGIC;
    signal r_manual_w_h : STD_LOGIC;
begin

    -- single_pulse_generator : entity work.single_pulse_generator
    --     port map(
    --         clk => clk_out_1HZ,
    --         start => pulse,
    --         pulse_out => clock_pulse
    --     );
    
    o_clk <= r_manual_or_auto_w_h and i_hltbar and i_prog_run_switch;
    o_clkbar <= not o_clk;
    r_manual_or_auto_w_h <= r_auto_w_h or r_manual_w_h;
    r_manual_w_h <= not i_manual_auto_switch and i_step_toggle;
    r_auto_w_h <= i_clk and i_manual_auto_switch and i_clrbar;
    
    
end rtl behavioral;
