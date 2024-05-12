library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity instruction_register is
    Port (
        i_clk : in STD_LOGIC;
        i_clr : in STD_LOGIC;
        i_data : in STD_LOGIC_VECTOR(7 downto 0);           -- input data
        i_sel_we : in STD_LOGIC_VECTOR(1 downto 0);                         -- write enable selector
        o_opcode : out STD_LOGIC_VECTOR(7 downto 0);        -- outputs
        o_operand_low : out STD_LOGIC_VECTOR(7 downto 0);
        o_operand_high : out STD_LOGIC_VECTOR(7 downto 0)
    );
end instruction_register;

architecture rtl of instruction_register is
    
begin
    process(i_clk, i_clr)
    begin
        -- this should probably be cleared at the beginning
        -- of every fetch cycle
        if i_clr = '1' then
            o_opcode <= "00000000";
            o_operand_low <= "00000000";
            o_operand_high <= "00000000";
        elsif rising_edge(i_clk) then
            if i_sel_we = "00" then 
                -- all write enables off
            elsif i_sel_we = "01" then
                o_opcode <= i_data;
            elsif i_sel_we = "10" then
                o_operand_low <= i_data;
            elsif i_sel_we = "11" then
                o_operand_high <= i_data;
            end if;
        end if;
    end process;
    
end architecture rtl;