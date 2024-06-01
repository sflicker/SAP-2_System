library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- bit 7 sign (minus) flag
-- bit 6 equals (zero) flag
-- bit 2 carry flag 
-- other bits in original 8085. bit 5 is auxiliary carry and bit 4 is parity. 
-- bits 3,2,1 and not used

entity status_register is
    Port (
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;

        i_minus_we : in STD_LOGIC;
        i_minus : in STD_LOGIC;
        o_minus : out STD_LOGIC := '0';
        
        i_equal_we : in STD_LOGIC;
        i_equal : in STD_LOGIC;
        o_equal : out STD_LOGIC := '0';
        
        i_carry_we : in STD_LOGIC;
        i_carry : in STD_LOGIC;
        o_carry : out STD_LOGIC := '0';

        i_we : in STD_LOGIC;
        i_data : in STD_LOGIC_VECTOR(7 downto 0);
        o_data : out STD_LOGIC_VECTOR(7 downto 0) := (others => '0')
    );
end status_register;

architecture rtl of status_register is
begin
    process(i_clk, i_rst) 
   --     variable internal_data : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    begin
        if i_rst = '1' then
            Report "Resetting Status Registers";
            o_minus <= '0';
            o_equal <= '0';
            o_carry <= '0';
            o_data <= (others => '0');
        elsif rising_edge(i_clk) then
            -- allow any combination to be read and stored
            -- but no consistency checks are made.
            if i_we = '1' then
--                Report "Setting Full Status Register to " & to_string(i_data);
--                internal_data := i_data;
                o_data <= i_data;
                o_minus <= i_data(7);
                o_equal <= i_data(6);
                o_carry <= i_data(2);
            end if;

            if i_minus_we = '1' then 
                Report "Setting Minus Flag to " & to_string(i_minus);
                internal_data(7) := i_minus;
                o_data(7) <= i_minus; 
                o_minus <= i_minus;
            end if;


            if i_equal_we = '1' then 
                Report "Setting Zero Flag to " & to_string(i_equal);
                internal_data(6) := i_equal;
                o_data(6) <= i_equal;
                o_equal <= i_equal;
            end if;

            if i_carry_we = '1' then 
                Report "Seting Carry Flag to " & to_string(i_carry);
                internal_data(2) := i_carry;
                o_data(2) <= i_carry;
                o_carry <= i_carry;
            end if;
        end if;
        -- o_minus <= internal_data(7);
        -- o_equal <= internal_data(6);
        -- o_carry <= internal_data(2);
        -- o_data <= internal_data;

    end process;

--    o_data <= o_minus & o_equal & "000" & o_carry & "00";

end rtl;