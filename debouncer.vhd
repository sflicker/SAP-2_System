library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debouncer is
    generic (
        g_LIMIT : integer := 1000000    -- default assume 10 ms wait for with 100 mhz clock
    );
    port (
        i_clk : IN STD_LOGIC;
        i_unfiltered : in STD_LOGIC;
        o_filtered : out STD_LOGIC
    );
end debouncer;

architecture rtl of debouncer is
    signal r_count : integer := 0;
    signal r_current : STD_LOGIC := '0';
begin
    process (i_clk)
    begin
        if rising_edge(i_clk) then
            if i_unfiltered /= r_current and r_count < g_LIMIT then
                r_count <= r_count + 1;
            elsif r_count >= g_LIMIT then
                r_current <= i_unfiltered;
                r_count <= 0;
            else 
                r_count <= 0;
            end if;
        end if;
        o_filtered <= r_current;
    end process;
end rtl;