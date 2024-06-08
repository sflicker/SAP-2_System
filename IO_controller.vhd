library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity IO_controller is
    Port(
        i_clk : IN STD_LOGIC;
        i_rst : IN STD_LOGIC;
        i_opcode : IN STD_LOGIC_VECTOR(7 downto 0);
        i_portnum : IN STD_LOGIC_VECTOR(2 downto 0);      -- portnum (0 none, 1 input 1, 2 input 2, 3 output 1, 4 output 2)
        o_bus_src_sel : OUT STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
        o_bus_dest_sel : OUT STD_LOGIC_VECTOR(0 to 12) := (others => '0');
        o_active : OUT STD_LOGIC := '0'
        
    );
end IO_controller;

architecture rtl of IO_controller is
    constant c_IN_byte_OPCODE : STD_LOGIC_VECTOR(7 downto 0) := x"DB";
    constant c_OUT_byte_OPCODE : STD_LOGIC_VECTOR(7 downto 0) := x"D3";
    type t_State is (s_IDLE, s_EXECUTE, s_COOL);
    signal r_state, r_next_state : t_State;
begin
    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            Report "Resetting";
--            bus_selector <= (others => '0');
--            bus_we_select <= (others => '0');
--            output1_write_enable <= '0';
--            output2_write_enable <= '0';
  --          select_input_out <= (others => '0');
  --          output1 <= (others => '0');
  --          output2 <= (others => '0');
          --  active <= '0';
            r_state <= s_IDLE;

        elsif rising_edge(i_clk) then
            Report "Setting State to " & to_string(r_next_state);
            r_state <= r_next_state;
        end if;            
    end process;
            
    process(r_state, i_opcode, i_portnum)
    begin
        Report "Processing - state: " & to_string(r_state) & 
            ", opcode: " & to_string(i_opcode) & ", portnum: " & to_string(i_portnum);
        r_next_state <= r_state;  -- default next state to current
        case r_state is
            when s_IDLE =>
                if (i_opcode = c_IN_byte_OPCODE and (i_portnum = "001" or i_portnum = "010"))
                                or (i_opcode = c_OUT_byte_OPCODE and (i_portnum = "011" or i_portnum = "100")) then
                    Report "IO opcode detected activating";
                    r_next_state <= s_EXECUTE;
                end if;
            
            when s_EXECUTE =>
                if i_opcode = c_IN_BYTE_OPCODE then
                    if i_portnum = "001" then
                        o_active <= '1';
                        o_bus_src_sel <= "1001";
                        o_bus_dest_sel <= "1000000000000";
                    elsif i_portnum = "010" then
                        o_active <= '1';
                        o_bus_src_sel <= "1010";
                        o_bus_dest_sel <= "1000000000000";
                    end if;
                elsif i_opcode = c_OUT_BYTE_OPCODE then
                    if i_portnum = "011" then
                        o_active <= '1';
                        o_bus_src_sel <= "0101";
                        o_bus_dest_sel <= "0000000001000";
                    elsif i_portnum = "100" then
                        o_active <= '1';
                        o_bus_src_sel <= "0101";
                        o_bus_dest_sel <= "0000000000100";
                    end if;
                end if;
                r_next_state <= s_COOL;

            when s_COOL =>
                -- cool down for a state while main controller resumes control
                r_next_state <= s_IDLE;
                o_active <= '0';
            when others =>
                r_next_state <= s_IDLE;
                o_active <= '0';
        end case;
    end process;

end rtl;
