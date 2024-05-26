library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_top_tb is
end alu_top_tb;

architecture rtl of alu_top_tb is
signal w_clk_100mhz : STD_LOGIC;
signal r_rst : STD_LOGIC := '0';
signal r_a : STD_LOGIC_VECTOR(7 downto 0);
signal r_b : STD_LOGIC_VECTOR(7 downto 0);
signal r_op_inc : STD_LOGIC := '0';
signal r_op_dec : STD_LOGIC := '0';
signal w_op : STD_LOGIC;
signal w_minus : STD_LOGIC;
signal w_equal : STD_LOGIC;
signal w_carry : STD_LOGIC;
signal w_result : STD_LOGIC_VECTOR(7 downto 0);
signal w_seven_segment_anodes : STD_LOGIC_VECTOR(3 downto 0);
signal w_seven_segment_cathodes : STD_LOGIC_VECTOR(6 downto 0);
begin

    clock : entity work.clock
    generic map(g_CLK_PERIOD => 10 ns)
    port map(
        o_clk => w_clk_100mhz
    );
    
    alu : entity work.alu_top
    port map(
        i_clk => w_clk_100mhz,
        i_rst => r_rst,
        i_a => r_a,
        i_b => r_b,
        i_op_inc => r_op_inc,
        i_op_dec => r_op_dec,
        o_op => w_op,
        o_result => w_result,
        o_minus => w_minus,
        o_equal => w_equal,
        o_carry => w_carry,
        o_seven_segment_anodes => w_seven_segment_anodes,
        o_seven_segment_cathodes => w_seven_segment_cathodes

    );

    uut: process
    begin
        Report "Starting Test";

        r_rst <= '1';
        wait for 50 ms;

        r_rst <= '0';
        wait for 50 ms;

        r_op_inc <= '1';
        wait for 50 ms;

        r_op_inc <= '0';

        r_a <= "10001000";
        r_b <= "10011001";
        wait for 10 ms;

        Report "Result=" & to_string(w_result) & ", op=" & to_string(w_op);

        wait;
    end process;



end rtl;