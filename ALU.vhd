library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port ( 
   --        i_clk : in STD_LOGIC;
           i_op : in STD_LOGIC_VECTOR(3 downto 0);
           i_input_1 : in unsigned(7 downto 0);
           i_input_2 : in unsigned(7 downto 0);
--           i_update_status_flags : in STD_LOGIC;
           o_out : out unsigned(7 downto 0) := (others => '0');
           o_minus_flag : out STD_LOGIC := '0';
           o_equal_flag : out STD_LOGIC := '0';
           o_carry_flag : out STD_LOGIC := '0'
    );
end ALU;

architecture rtl of ALU is
    signal extended_a, extended_b : unsigned(8 downto 0) := (others => '0');
    constant ONE : unsigned(8 downto 0) := "000000001";
    constant ZERO : unsigned(7 downto 0) := (others => '0');
    -- procedure update_flags(
    --     variable result : in STD_LOGIC_VECTOR(7 downto 0);
    --     signal minus_flag_sig : out STD_LOGIC;
    --     signal equal_flag_sig : out STD_LOGIC) is
    -- begin        
    --     minus_flag_sig <= '1' when result(7) = '1' else '0';
    --     equal_flag_sig <= '1' when result = "00000000" else '0';
    -- end procedure;
begin

    extended_a <= '0' & i_input_1;
    extended_b <= '0' & i_input_2;

    process (extended_a, extended_b, i_op)
        variable extended_result : unsigned(8 downto 0) := (others=>'0');
  --      variable result : STD_LOGIC_VECTOR(8 downto 0) := (others => '0');
    begin
        --defaults
--        o_result := (others => '0');
--        o_minus_flag := '0';
--        o_equal_flag := '0';

        case i_op is
            when "0000" =>  -- no operation
            extended_result := extended_result;
            when "0001" =>   -- ADD
            extended_result := extended_a + extended_b;
                o_out <= extended_result(7 downto 0);
                o_carry_flag <= extended_result(8);
                o_minus_flag <= extended_result(7);
                o_equal_flag <= '1' when extended_result(7 downto 0) = ZERO else '0';
            when "0010" =>   -- SUB
            extended_result := extended_a - extended_b;
                o_out <= extended_result(7 downto 0);
                o_carry_flag <= not extended_result(8);
                o_minus_flag <= extended_result(7);                
                o_equal_flag <= '1' when extended_result(7 downto 0) = ZERO else '0';
            when "0011" =>   -- INC
            extended_result := extended_b + ONE;
                o_out <= extended_result(7 downto 0);
                o_carry_flag <= extended_result(8);
                o_minus_flag <= extended_result(7);
                o_equal_flag <= '1' when extended_result(7 downto 0) = ONE else '0';
            when "0100" =>  -- DEC
            extended_result := extended_b - ONE;
                o_out <= extended_result(7 downto 0);
                o_carry_flag <= not extended_result(8);
                o_minus_flag <= extended_result(7);
                o_equal_flag <= '1' when extended_result(7 downto 0) = ONE else '0';
            when "0101" =>   -- AND
                extended_result := extended_a AND extended_b;
            when "0110" =>  -- OR
                extended_result := extended_a OR extended_b;
            when "0111" =>  -- XOR
                extended_result := extended_a XOR extended_b;
            when "1000" =>  -- Complement
                extended_result := not extended_b;
            when "1001" =>  -- rotate left
                extended_result := extended_b(6 downto 0) & extended_b(7);
            when "1010" =>  -- rotate right
                extended_result := extended_b(0) & extended_b(7 downto 1);
            when others =>
                extended_result := extended_result;
            end case;
            
            -- if i_update_status_flags = '1' then
            --     update_flags(result, o_minus_flag, o_equal_flag);
            -- end if;

            o_out <= extended_result(7 downto 0);

        end process;

    --     process(i_clk)
    --     begin
    --         if rising_edge(i_clk) then
    --             carry_flag <= internal_results(8);
    --             equal_flag <= '1' when result = (others => '0');
    --             minus_flag <= internal_result(7);
    --                 --     minus_flag_sig <= '1' when result(7) = '1' else '0';
    -- --     equal_flag_sig <= '1' when result = "00000000" else '0';





    -- process (i_input_1, i_input_2, i_op, i_update_status_flags)
    --     variable result : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    -- begin
    --     if i_op = "0001" then -- ADD
    --         result := std_logic_vector(unsigned(i_input_1) + unsigned(i_input_2));
    --         update_flags(result, o_minus_flag, o_equal_flag, i_update_status_flags);
    --     elsif i_op = "0010" then  -- SUB
    --         result := std_logic_vector(unsigned(i_input_1) - unsigned(i_input_2));
    --         update_flags(result, o_minus_flag, o_equal_flag, i_update_status_flags);
    --     elsif i_op = "0011" then  -- INC
    --         result := std_logic_vector(unsigned(i_input_2) + 1);
    --         update_flags(result, o_minus_flag, o_equal_flag, i_update_status_flags);
    --     elsif i_op = "0100" then  -- DEC
    --         result := std_logic_vector(unsigned(i_input_2) - 1);
    --         update_flags(result, o_minus_flag, o_equal_flag, i_update_status_flags);
    --     elsif i_op = "0101" then  -- AND
    --         result := std_logic_vector(unsigned(i_input_1) AND unsigned(i_input_2));
    --         update_flags(result, o_minus_flag, o_equal_flag, i_update_status_flags);
    --     elsif i_op = "0110" then  -- OR
    --         result := std_logic_vector(unsigned(i_input_1) OR unsigned(i_input_2));
    --         update_flags(result, o_minus_flag, o_equal_flag, i_update_status_flags);
    --     elsif i_op = "0111" then  -- XOR
    --         result := std_logic_vector(unsigned(i_input_1) XOR unsigned(i_input_2));
    --         update_flags(result, o_minus_flag, o_equal_flag, i_update_status_flags);
    --     elsif i_op = "1000" then  -- Complement
    --         result := std_logic_vector(not unsigned(i_input_2));
    --         -- do not update flags in this case
    --     elsif i_op = "1001" then -- rotate left
    --         result := i_input_2(6 downto 0) & i_input_2(7);
    --     elsif i_op = "1010" then -- rotate right
    --         result := i_input_2(0) & i_input_2(7 downto 1);
    --     else
    --         result := result;
    --         -- no action. typically this would be op = 0
    --     end if;
    --     o_out <= result;
    -- end process;
end rtl;
