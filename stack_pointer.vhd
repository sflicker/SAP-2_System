library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- 16 bit program counter 
entity stack_pointer is
    generic (
        g_WIDTH : integer := 16
    );
    Port ( 
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        i_inc : in STD_LOGIC;
        i_dec : in STD_LOGIC;
        o_data : out STD_LOGIC_VECTOR(g_WIDTH-1 downto 0)

    );
end stack_pointer;

architecture rtl of stack_pointer is
begin
    process(i_clk, i_rst)
        variable internal_value : STD_LOGIC_VECTOR(15 downto 0) := (others => '1');
    begin
        if i_rst = '1' then
            internal_value := (others => '1');
        elsif rising_edge(i_clk) then
            if i_inc = '1' then
                internal_value := STD_LOGIC_VECTOR(unsigned(internal_value) + 1);
            elsif i_dec = '1' then
                internal_value := STD_LOGIC_VECTOR(unsigned(internal_value) - 1);
            end if;
        end if;
        o_data <= internal_value;
    end process;
end rtl;

         