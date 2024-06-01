library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port ( 
           i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_op : in STD_LOGIC_VECTOR(3 downto 0);
           i_input_1 : in STD_LOGIC_VECTOR(7 downto 0);
           i_input_2 : in STD_LOGIC_VECTOR(7 downto 0);
           i_update_status_flags : in STD_LOGIC;
           o_out : out STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
           o_minus_flag : out STD_LOGIC := '0';
           o_equal_flag : out STD_LOGIC := '0';
           o_carry_flag : out STD_LOGIC := '0';
           o_status_flags : out STD_LOGIC_VECTOR(7 downto 0) := (others => '0')
    );
end ALU;

architecture rtl of ALU is
    signal result_buffer : unsigned(8 downto 0) := (others=>'0');
    signal extended_result : unsigned(8 downto 0) := (others=>'0');
    constant ONE : unsigned(8 downto 0) := "000000001";
    constant ZERO : unsigned(7 downto 0) := (others => '0');
begin

    process (i_input_1, i_input_2, i_op)
        variable extended_a, extended_b : unsigned(8 downto 0) := (others => '0');
    begin

        extended_a := '0' & unsigned(i_input_1);
        extended_b := '0' & unsigned(i_input_2);
    
        case i_op is
            when "0001" =>   -- ADD
                extended_result <= extended_a + extended_b;
            when "0010" =>   -- SUB
                 extended_result <= extended_a - extended_b;
            when "0011" =>   -- INC
                 extended_result <= extended_b + ONE;
            when "0100" =>  -- DEC
                 extended_result <= extended_b - ONE;
            when "0101" =>     -- AND
                extended_result <= extended_a AND extended_b;
            when "0110" =>  -- OR
                extended_result <= extended_a OR extended_b;
            when "0111" =>  -- XOR
                extended_result <= extended_a XOR extended_b;
            when "1000" =>  -- Complement
                extended_result <= not extended_b;
            when "1001" =>  -- rotate left
                extended_result <= '0' & extended_b(6 downto 0) & extended_b(7);
            when "1010" =>  -- rotate right
                extended_result <= '0' & extended_b(0) & extended_b(7 downto 1);
            when others =>   -- 0000 is NOP and others output to 0 so we don't create latch in combinatorial part
                extended_result <= "000000000";
        end case;

    end process;

    process (i_clk, i_rst) 
        variable op_integer : integer;
    begin
        op_integer := to_integer(unsigned(i_op));
        if i_rst = '1' then
            result_buffer <= "000000000";
        elsif rising_edge(i_clk) and (op_integer >= 1 and op_integer <= 10) then
            -- update on the rising edge and the op is in the valid range. 
            result_buffer <= extended_result;
        end if;
    end process;

    o_out <= std_logic_vector(result_buffer(7 downto 0));
    o_carry_flag <= result_buffer(8);
    o_minus_flag <= result_buffer(7);
    o_equal_flag <= '1' when result_buffer(7 downto 0) = "00000000" else '0';
    o_status_flags <= o_minus_flag & o_equal_flag & "000" & o_carry_flag & "00";

end rtl;
