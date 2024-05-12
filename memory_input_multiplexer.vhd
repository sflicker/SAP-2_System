library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory_input_multiplexer is
    Port (
        i_prog_run_select : IN STD_LOGIC;

        i_prog_data : IN STD_LOGIC_VECTOR(7 downto 0);
        i_run_data : IN STD_LOGIC_VECTOR(7 downto 0);

        i_prog_addr : IN STD_LOGIC_VECTOR(15 downto 0);
        i_run_addr : IN STD_LOGIC_VECTOR(15 downto 0);
--        prog_clk_in : IN STD_LOGIC;
---        run_clk_in : IN STD_LOGIC;
        i_prog_write_enable : IN STD_LOGIC;
        i_run_write_enable : IN STD_LOGIC;
        
        o_data : OUT STD_LOGIC_VECTOR(7 downto 0);
        o_addr : OUT STD_LOGIC_VECTOR(15 downto 0);
 --       select_clk_in : OUT STD_LOGIC;
        o_write_enable : OUT STD_LOGIC
    );
end memory_input_multiplexer;

architecture rtl of memory_input_multiplexer is
begin
    o_data <= i_prog_data when i_prog_run_select = '0' else i_run_data;
    o_addr <= i_prog_addr when i_prog_run_select = '0' else i_run_addr;
--    select_clk_in <= prog_clk_in when prog_run_select = '0' else run_clk_in;
    o_write_enable <= i_prog_write_enable when i_prog_run_select = '0' else i_run_write_enable;
end rtl;