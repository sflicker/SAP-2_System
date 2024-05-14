library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- 16 bit address RAM
-- synchronous
entity ram_bank is
    Port ( 
           i_clk : in STD_LOGIC;
           i_addr : in STD_LOGIC_VECTOR(15 downto 0);     -- 8 bit addr
           i_data : in STD_LOGIC_VECTOR(7 downto 0);   -- 8 bit data
           i_we   : in STD_LOGIC;                 -- load data at addr - active hit
           o_data : out STD_LOGIC_VECTOR(7 downto 0)  -- data out from addr
           ); 
end ram_bank;

architecture rtl of ram_bank is
    attribute ram_style : string;
    type t_RAM_TYPE is array(0 to 2**16-1) of STD_LOGIC_VECTOR(7 downto 0);
    signal r_RAM : t_RAM_TYPE := (
        others => (others => '0'));

    attribute ram_style of r_RAM : signal is "block";
begin

    process(i_clk)
        variable v_data : STD_LOGIC_VECTOR(7 downto 0);
    begin
        if rising_edge(i_clk) then
            Report "Ram_Bank - i_we: " & to_string(i_we) &
                ", i_addr: " & to_string(i_addr) & ", i_data: " & to_string(i_data);
            if i_we = '1' then
                Report "Writing Data to Memory";
                r_RAM(to_integer(unsigned(i_addr))) <= i_data;
            else 
                v_data := r_RAM(to_integer(unsigned(i_addr)));
                o_data <= v_data;
                Report "Reading Data from Memory - data: " & to_string(v_data);
            end if;
        end if;
    end process;
end rtl;
