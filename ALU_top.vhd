library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_top is
    generic (
        g_DEBOUNCER_LIMIT : integer := 1000000 -- default assumes 10 ms sampling wait with 100 mhz
    );
    port(
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        i_a : in STD_LOGIC_VECTOR(7 downto 0);
        i_b : in STD_LOGIC_VECTOR(7 downto 0);
        i_op_inc : in STD_LOGIC;
        i_op_dec : in STD_LOGIC;

        o_op : out STD_LOGIC_VECTOR(3 downto 0);
        o_result : out STD_LOGIC_VECTOR(7 downto 0);
        o_minus : out STD_LOGIC;
        o_equal : out STD_LOGIC;
        o_carry : out STD_LOGIC;
        o_seven_segment_anodes : out STD_LOGIC_VECTOR(3 downto 0);      -- maps to seven segment display
        o_seven_segment_cathodes : out STD_LOGIC_VECTOR(6 downto 0)     -- maps to seven segment display
    );
end alu_top;

architecture rtl of alu_top is
    signal w_system_clock_1kHZ : STD_LOGIC;
    signal w_display_data : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal r_op : STD_lOGIC_VECTOR(3 downto 0) := (others => '0');
    signal w_alu_output : STD_LOGIC_VECTOR(7 downto 0);
    signal w_op_inc_filtered : STD_LOGIC;
    signal w_op_dec_filtered : STD_LOGIC;
    constant c_OP_LIMIT : STD_LOGIC_VECTOR(3 downto 0) := "1010";
    signal r_inc_current : STD_LOGIC := '0';
    signal r_dec_current : STD_LOGIC := '0';
begin

    o_result <= std_logic_vector(w_alu_output);
    o_op <= r_op;

    processor_clock_divider_1MHZ : entity work.clock_divider
    generic map(g_DIV_FACTOR => 100000)
    port map(
        i_clk => i_clk,
        i_rst => i_rst,
        o_clk => w_system_clock_1kHZ
    );  

    display_controller : entity work.display_controller
    port map(
        i_clk => w_system_clock_1kHZ,
        i_rst => i_rst,
        i_data => w_display_data,
        o_anodes => o_seven_segment_anodes,
        o_cathodes => o_seven_segment_cathodes
    );

    debouncer_inc : entity work.debouncer
    generic map(g_LIMIT => g_DEBOUNCER_LIMIT)    -- 10 ms based on 100 mhz clock
    port map(
        i_clk => i_clk,
        i_unfiltered => i_op_inc,
        o_filtered => w_op_inc_filtered
    );

    debouncer_dec : entity work.debouncer
    generic map(g_LIMIT => g_DEBOUNCER_LIMIT)    -- 10 ms based on 100 mhz clock
    port map(
        i_clk => i_clk,
        i_unfiltered => i_op_dec,
        o_filtered => w_op_dec_filtered
    );

    op_controller : process(i_clk, i_rst)

    begin
        if i_rst = '1' then
            r_op <= "0000";
            r_inc_current <= '0';
            r_dec_current <= '0';
        elsif rising_edge(i_clk) then
            if w_op_inc_filtered = '1' and r_inc_current = '0' then
                Report "Incrementating OP";
                if r_op = c_OP_LIMIT then
                    r_op <= "0000";
                else
                    r_op <= std_logic_vector(unsigned(r_op) + 1);
                end if;
            end if;

            if w_op_dec_filtered = '1' and r_dec_current = '0' then
                Report "Decrementing OP";
                if r_op = "0000" then
                    r_op <= c_OP_LIMIT;
                else
                    r_op <= std_logic_vector(unsigned(r_op) - 1);
                end if;
            end if;

            r_inc_current <= w_op_inc_filtered;
            r_dec_current <= w_op_dec_filtered;
        end if;
    end process;


    alu_inst : entity work.alu
    port map(
        i_op => r_op,
        i_rst => i_rst,
        i_input_1 => i_a,
        i_input_2 => i_b,
        o_out => w_alu_output,
        o_minus_flag => o_minus,
        o_equal_flag => o_equal,
        o_carry_flag => o_carry
    );

    w_display_data(7 downto 0) <= std_logic_vector(w_alu_output);

end rtl;

