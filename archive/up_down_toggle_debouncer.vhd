library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity up_down_toggle_debouncer is
    generic (
        g_DEBOUNCE_LIMIT : integer := 1
    );
    port(
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        i_up : in STD_LOGIC;
        i_down : in STD_LOGIC;
        o_output : out STD_LOGIC_VECTOR(3 downto 0) := (others => '0')
    );
    end up_down_toggle_debouncer;

    architecture rtl of up_down_toggle_debouncer is
        signal r_last_up, r_last_down : STD_LOGIC := '0';
        signal r_stable_up, r_stable_down : STD_LOGIC := '0';
        signal r_output_limit : std_logic_vector(3 downto 0) := "1000";

    begin
        process(i_clk)
            variable r_debounce_counter : natural := 0;
        begin
            if rising_edge(i_clk) then
                if i_rst = '1' then
                    r_stable_up <= '0';
                    r_last_up <= '0'
                if i_up = '1' and r_last_up = '0' then -- rising edge 
                    if r_debounce_counter = 0 then
                        r_stable_up <= '1';
                    end if;
                    r_debounce_counter := r_debounce_counter + 1;
                    if r_debounce_counter >= g_DEBOUNCE_LIMIT then
                        r_debounce_counter := g_DEBOUNCE_LIMIT;
                    end if;
                else
                    r_debounce_counter := 0;
                    r_stable_up <= '0';
                end if;
                r_last_up <= i_up;

                if i_down = '1' and r_last_down = '0' then -- rising edge 
                    if r_debounce_counter = 0 then
                        r_stable_down <= '1';
                    end if;
                    r_debounce_counter := r_debounce_counter + 1;
                    if r_debounce_counter >= g_DEBOUNCE_LIMIT then
                        r_debounce_counter := g_DEBOUNCE_LIMIT;
                    end if;
                else
                    r_debounce_counter := 0;
                    r_stable_down <= '0';
                end if;
                r_last_down <= i_down;
            end if;
        end process;

        process(i_clk)
        begin
            if rising_edge(i_clk) then
                if i_rst = '1' then
                    o_output <= (others => '0');
                elsif r_stable_up = '1' then
                    if o_output < r_output_limit then
                        o_output <= std_logic_vector(unsigned(o_output) + 1);
                    else 
                        o_output <= (others => '0');
                    end if;
                    r_stable_up <= '0';
                elsif r_stable_down = '1' then
                    if o_output = "0000" then
                        o_output <= r_output_limit;
                    else 
                        o_output <= std_logic_vector(unsigned(o_output) - 1);
                    end if;
                    r_stable_down <= '0';
                end if;
            end if;
        end process;
    end rtl;





            