library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity w_bus is
  Port (i_driver_sel_def : in STD_LOGIC_VECTOR(3 downto 0);         -- select component to drive the bus from main controller
        i_driver_sel_io : in STD_LOGIC_VECTOR(3 downto 0);          -- select component to drive the bus from io controller
        i_we_sel_def : in STD_LOGIC_VECTOR(0 to 13);                -- select write enabled component from main controller
        i_we_sel_io : in STD_LOGIC_VECTOR(0 to 13);                 -- select write enabled conponent from io controller
        i_io_controller_active : in STD_LOGIC;                                   -- '1' when IO controller is active and driving the bus. otherwise main controller drives
        i_pc_data : in STD_LOGIC_VECTOR(15 downto 0);
        i_sp_data : in STD_LOGIC_VECTOR(15 downto 0);
        i_ir_operand_full : in STD_LOGIC_VECTOR(15 downto 0);
        i_acc_data : in STD_LOGIC_VECTOR(7 downto 0);
        i_alu_data  : in STD_LOGIC_VECTOR(7 downto 0);
        i_mdr_fm_data : in STD_LOGIC_VECTOR(7 downto 0);
        i_b_data : in STD_LOGIC_VECTOR(7 downto 0);
        i_c_data : in STD_LOGIC_VECTOR(7 downto 0);
        i_tmp_data : in STD_LOGIC_VECTOR(7 downto 0);
        i_input_port_1_data : in STD_LOGIC_VECTOR(7 downto 0);
        i_input_port_2_data : in STD_LOGIC_VECTOR(7 downto 0);
        o_bus_data : out STD_LOGIC_VECTOR(15 downto 0);
        o_acc_we : out STD_LOGIC;
        o_b_we : out STD_LOGIC;
        o_c_we : out STD_LOGIC;
        o_tmp_we : out STD_LOGIC;
        o_mar_we : out STD_LOGIC;
        o_pc_we_full : out STD_LOGIC;
        o_pc_we_low : out STD_LOGIC;
        o_pc_we_high : out STD_LOGIC;
        o_mdr_tm_we : out STD_LOGIC;
        o_ir_opcode_we : out STD_LOGIC;
        o_ir_operand_we_low : out STD_LOGIC;
        o_ir_operand_we_high : out STD_LOGIC;
        o_out_port_3_we : out STD_LOGIC;
        o_out_port_4_we : out STD_LOGIC
  );
end w_bus;

architecture rtl of w_bus is
    signal r_driver_sel : STD_LOGIC_VECTOR(3 downto 0);
    signal r_we_sel : STD_LOGIC_VECTOR(0 to 13);
begin

    r_driver_sel <= i_driver_sel_io when i_io_controller_active = '1' else i_driver_sel_def;
    r_we_sel <= i_we_sel_io when i_io_controller_active = '1' else i_we_sel_def;    

    process(r_driver_sel)
    begin
        case r_driver_sel is
            when "0000" => o_bus_data <= (others => '0');  -- zero
            when "0001" => o_bus_data <= i_pc_data;
            when "0010" => o_bus_data <= i_ir_operand_full;
            when "0011" => o_bus_data <= ("00000000" & i_alu_data);
            when "0100" => o_bus_data <= ("00000000" & i_mdr_fm_data);
            when "0101" => o_bus_data <= ("00000000" & i_acc_data);
            when "0110" => o_bus_data <= ("00000000" & i_b_data);
            when "0111" => o_bus_data <= ("00000000" & i_c_data);
            when "1000" => o_bus_data <= ("00000000" & i_tmp_data);
            when "1001" => o_bus_data <= ("00000000" & i_input_port_1_data);
            when "1010" => o_bus_data <= ("00000000" & i_input_port_2_data);
            when "1011" => o_bus_data <= ("00000000" & i_pc_data(7 downto 0));
            when "1100" => o_bus_data <= ("00000000" & i_pc_data(15 downto 8));
            when "1101" => o_bus_data <= i_sp_data;
            when others => o_bus_data <= (others => '0');
        end case;
    end process;

    process(r_we_sel)
    begin
        o_acc_we <= r_we_sel(0);
        o_b_we <= r_we_sel(1);
        o_c_we <= r_we_sel(2);
        o_tmp_we <= r_we_sel(3);
        o_mar_we <= r_we_sel(4);
        o_pc_write_enable <= r_we_sel(5);
        o_mdr_tm_we <= r_we_sel(6);
        o_ir_opcode_we <= r_we_sel(7);
        o_ir_operand_we_low <= r_we_sel(8);
        o_ir_operand_we_high <= r_we_sel(9);
        o_out_port_3_we <= r_we_sel(10);
        o_out_port_4_we <= r_we_sel(11);
        o_pc_write_enable_low <= r_we_sel(12);
        o_pc_write_enable_high <= r_we_sel(13);
    end process;
end rtl;
