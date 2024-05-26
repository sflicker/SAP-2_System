library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debouncer_tb is
end debouncer_tb;

architecture rtl of debouncer_tb is
    signal w_clk_1mhz : STD_LOGIC;
    signal r_unfiltered : STD_LOGIC := '0';
    signal w_filtered : STD_LOGIC;
begin
    clock_inst : entity work.clock
    generic map(g_CLK_PERIOD => 1000 ns)  -- 1mhz
    port map(
        o_clk => w_clk_1mhz
    );

    debouncer_inst : entity work.debouncer
    generic map(g_LIMIT => 10000)    -- 10 ms based on 1mhz clock
    port map(
        i_clk => w_clk_1mhz,
        i_unfiltered => r_unfiltered,
        o_filtered => w_filtered
    );

    uut: process
    begin
        r_unfiltered <= '0';
        wait for 15 ms;

        Report "r_unfilter: " & to_string(r_unfiltered) & ", w_filtered: " & to_string(w_filtered);

        r_unfiltered <= '1';
        wait for 5 ms;          -- don't hold long enough

        Report "r_unfilter: " & to_string(r_unfiltered) & ", w_filtered: " & to_string(w_filtered);

        r_unfiltered <= '0';
        wait for 5 ms;

        Report "r_unfilter: " & to_string(r_unfiltered) & ", w_filtered: " & to_string(w_filtered);

        r_unfiltered <= '1';    -- hold long enough
        wait for 15 ms;

        Report "r_unfilter: " & to_string(r_unfiltered) & ", w_filtered: " & to_string(w_filtered);


        wait;
    end process;
end rtl;

        