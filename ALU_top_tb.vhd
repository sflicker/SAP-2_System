library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_top_tb is
end alu_top_tb;

architecture rtl of alu_top_tb is
signal w_clk_100mhz : STD_LOGIC;
signal r_rst : STD_LOGIC := '0';
signal r_a : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
signal r_b : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
signal r_op_inc : STD_LOGIC := '0';
signal r_op_dec : STD_LOGIC := '0';
signal w_op : STD_LOGIC_VECTOR(3 downto 0);
signal w_minus : STD_LOGIC;
signal w_equal : STD_LOGIC;
signal w_carry : STD_LOGIC;
signal w_result : STD_LOGIC_VECTOR(7 downto 0);
signal w_seven_segment_anodes : STD_LOGIC_VECTOR(3 downto 0);
signal w_seven_segment_cathodes : STD_LOGIC_VECTOR(6 downto 0);
begin

    clock : entity work.clock
    generic map(g_CLK_PERIOD => 1000 ns)
    port map(
        o_clk => w_clk_100mhz
    );
    
    alu : entity work.alu_top
    generic map(g_DEBOUNCER_LIMIT => 10000)
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
        Report "Starting Test - a=0, b=0";

        r_rst <= '1';
        wait for 10 ns;

        r_rst <= '0';
        wait for 10 ns;

        r_a <= "00000000";
        r_b <= "00000000";

        wait for 10 ms;
        Report "op=" & to_string(w_op) 
         & ", r_a=" & to_string(r_a)
         & ", r_b=" & to_string(r_b)
         & ", Result=" & to_string(w_result)
         & ", w_minus=" & to_string(w_minus) 
         & ", w_equal=" & to_string(w_equal) 
         & ", w_carry=" & to_string(w_carry);

        for j in 0 to 12 loop

            r_op_inc <= '1';
            wait for 15 ms;

            r_op_inc <= '0';
            wait for 15 ms;

            Report "op=" & to_string(w_op) 
            & ", r_a=" & to_string(r_a)
            & ", r_b=" & to_string(r_b)
            & ", Result=" & to_string(w_result)
            & ", w_minus=" & to_string(w_minus) 
            & ", w_equal=" & to_string(w_equal) 
            & ", w_carry=" & to_string(w_carry);

        end loop;

    Report "Repeating test with a=10000000, b=01110000";

    r_rst <= '1';
    wait for 10 ns;

    r_rst <= '0';
    wait for 10 ns;

    r_a <= "10000000";
    r_b <= "01110000";

    wait for 10 ms;
    Report "op=" & to_string(w_op) 
     & ", r_a=" & to_string(r_a)
     & ", r_b=" & to_string(r_b)
     & ", Result=" & to_string(w_result)
     & ", w_minus=" & to_string(w_minus) 
     & ", w_equal=" & to_string(w_equal) 
     & ", w_carry=" & to_string(w_carry);

    for j in 0 to 12 loop

        r_op_inc <= '1';
        wait for 15 ms;

        r_op_inc <= '0';
        wait for 15 ms;

        Report "op=" & to_string(w_op) 
        & ", r_a=" & to_string(r_a)
        & ", r_b=" & to_string(r_b)
        & ", Result=" & to_string(w_result)
        & ", w_minus=" & to_string(w_minus) 
        & ", w_equal=" & to_string(w_equal) 
        & ", w_carry=" & to_string(w_carry);

    end loop;

        Report "Repeating test with a=11011000, b=00101010";

        r_rst <= '1';
        wait for 10 ns;
    
        r_rst <= '0';
        wait for 10 ns;
    
        r_a <= "11011000";
        r_b <= "00101010";
    
        wait for 10 ms;
        Report "op=" & to_string(w_op) 
         & ", r_a=" & to_string(r_a)
         & ", r_b=" & to_string(r_b)
         & ", Result=" & to_string(w_result)
         & ", w_minus=" & to_string(w_minus) 
         & ", w_equal=" & to_string(w_equal) 
         & ", w_carry=" & to_string(w_carry);
    
        for j in 0 to 12 loop
    
            r_op_inc <= '1';
            wait for 15 ms;
    
            r_op_inc <= '0';
            wait for 15 ms;
    
            Report "op=" & to_string(w_op) 
            & ", r_a=" & to_string(r_a)
            & ", r_b=" & to_string(r_b)
            & ", Result=" & to_string(w_result)
            & ", w_minus=" & to_string(w_minus) 
            & ", w_equal=" & to_string(w_equal) 
            & ", w_carry=" & to_string(w_carry);
    
        end loop;
    


    wait;
end process;



end rtl;