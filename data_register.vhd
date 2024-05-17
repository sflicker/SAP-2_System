library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity data_register is 
    generic (
        g_WIDTH : integer := 8
    );
    Port (
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        i_write_enable : in STD_LOGIC;
        i_data : in STD_LOGIC_VECTOR(g_WIDTH-1 downto 0);
        o_data : out STD_LOGIC_VECTOR(g_WIDTH-1 downto 0)
    );
end data_register;

architecture rtl of data_register is

begin
    process(i_clk, i_rst)
    variable internal_data : STD_LOGIC_VECTOR(g_WIDTH-1 downto 0) 
        := (others => '0');
    begin
        if i_rst = '1' then
            internal_data := (others => '0');
        elsif rising_edge(i_clk) then
            if i_write_enable = '1' then
                internal_data := i_data;
            end if;
        end if;
        o_data <= internal_data;
    end process;
end rtl;
