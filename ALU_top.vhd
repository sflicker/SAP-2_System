library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_top is
    port(
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        i_a : in STD_LOGIC_VECTOR(7 downto 0);
        i_b : in STD_LOGIC_VECTOR(7 downto 0);
        i_op_inc : in STD_LOGIC;
        i_op_dec : in STD_LOGIC;

        o_op : out STD_LOGIC_VECTOR(3 downto 0);
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
    signal w_op : STD_lOGIC_VECTOR(3 downto 0) := (others => '0');
    signal w_alu_output : unsigned(7 downto 0);
begin



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

    debouncer : entity work.up_down_toggle_debouncer
    generic map(
        g_DEBOUNCE_LIMIT => 25)
    port map(
        i_clk => w_system_clock_1kHZ,
        i_rst => i_rst,
        i_up => i_op_inc,
        i_down => i_op_dec,
        o_output => w_op
    );

    alu_inst : entity work.alu
    port map(
        i_op => w_op,
        i_input_1 => unsigned(i_a),
        i_input_2 => unsigned(i_b),
        o_out => w_alu_output,
        o_minus_flag => o_minus,
        o_equal_flag => o_equal,
        o_carry_flag => o_carry
    );

    w_display_data(7 downto 0) <= std_logic_vector(w_alu_output);

end rtl;

