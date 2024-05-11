library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity clock_controller_tb is
end clock_controller_tb;

architecture test of clock_controller_tb is
    signal w_clk : STD_LOGIC;
    signal r_step : STD_LOGIC := '0';
    signal r_auto : STD_LOGIC := '0';
    signal r_hltbar : STD_LOGIC := '1';
    signal r_clrbar : STD_LOGIC := '1';
    signal o_clk : STD_LOGIC := '1';
    signal o_clkbar : STD_LOGIC := '1'; 
begin

    CLOCK : entity work.clock
        port map (
            clk => w_clk
        );

    LUT : entity work.clock_controller
        port map(
            clk_in => w_clk,
            step => r_step,
            auto => r_auto,
            hltbar => r_hltbar,
            clrbar => r_clrbar,
            clk_out => o_clk,
            clkbar_out => o_clkbar
        );

    TC : process
    begin
        wait for 100 ns;
        r_auto <= '1';

        wait for 200 ns;
        r_auto <= '0';

        wait for 200 ns;
        r_step <= '1';
        wait for 250 ns;
        r_step <= '0';
        wait for 50 ns;

        r_auto <= '1';
        wait for 200 ns;
        r_hltbar <= '0';

        wait for 100 ns;
        r_hltbar <= '1';

        wait for 100 ns;
        r_clrbar <= '0';

        wait for 100 ns;
        r_clrbar <= '1';

        wait;
    end process;
end test;
