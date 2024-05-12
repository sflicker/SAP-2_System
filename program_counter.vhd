library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- 16 bit program counter 
entity program_counter is
    generic (
        WIDTH : integer := 16
    );
    Port ( 
        i_clk : in STD_LOGIC;
        i_reset : in STD_LOGIC;
        i_increment : in STD_LOGIC;
        i_write_enable_full : in STD_LOGIC;
        i_write_enable_low : in STD_LOGIC;
        i_write_enable_high :in STD_LOGIC;
        i_data : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        o_data : out STD_LOGIC_VECTOR(WIDTH-1 downto 0)
    );
   
end program_counter;

architecture rtl of program_counter is
begin

    process(i_clk, i_reset)
        variable internal_value : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    begin
        if i_reset = '1' then
            internal_value := (others => '0');
        elsif rising_edge(i_clk) then
            if i_increment = '1' then
                internal_value := STD_LOGIC_VECTOR(unsigned(internal_value) + 1);
            elsif i_write_enable_full = '1' then
                internal_value := i_data;
            elsif i_write_enable_low = '1' then
                internal_value(7 downto 0) := i_data(7 downto 0);
            elsif i_write_enable_high = '1' then
                internal_value(15 downto 8) := i_data(7 downto 0);
            end if;
        end if;
        o_data <= internal_value;
        
    end process;
end rtl;
