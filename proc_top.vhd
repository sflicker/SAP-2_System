library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity proc_top is
    generic (
        SIMULATION_MODE : boolean := false
    );
    port( i_clk : in STD_LOGIC;
          i_rst : in STD_LOGIC;  -- map to FPGA clock will be stepped down to 1HZ
                                -- for simulation TB should generate clk of 1HZ
          i_port_1 : in STD_LOGIC_VECTOR(7 downto 0);
          i_port_2 : in STD_LOGIC_VECTOR(7 downto 0);
          o_port_3 : out STD_LOGIC_VECTOR(7 downto 0);
          o_port_4 : out STD_LOGIC_VECTOR(7 downto 0);
          o_HLTBar : out STD_LOGIC;
          o_address : out STD_LOGIC_VECTOR(15 downto 0);         -- 16 bit output address
          i_data : in STD_LOGIC_VECTOR(7 downto 0);          -- 8 bit bidirectional data
          o_data: out STD_LOGIC_VECTOR(7 downto 0);
          o_rd : out STD_LOGIC;                          -- active high signal to read from memory using o_address and i_data 
          o_ram_we : out STD_LOGIC                           -- active high signal to write from memory using o_address and o_data

    );

end proc_top;

architecture rtl of proc_top is

    signal w_clkbar : std_logic;
    signal w_hltbar : std_logic := '1';
    signal w_wbus_sel_def : STD_LOGIC_VECTOR(3 downto 0);
    signal w_wbus_sel_io_def : STD_LOGIC_VECTOR(3 downto 0);       
    signal w_alu_op : std_logic_vector(3 downto 0);
    signal w_acc_data : STD_LOGIC_VECTOR(7 downto 0);
    signal w_alu_data : STD_LOGIC_VECTOR(7 downto 0);
    signal w_ir_opcode : STD_LOGIC_VECTOR(7 downto 0);
    signal w_ir_clr : STD_LOGIC;
    signal w_bus_data_out_sig : STD_LOGIC_VECTOR(15 downto 0);
    signal w_mar_addr: STD_LOGIC_VECTOR(15 downto 0);
    signal w_b_data : STD_LOGIC_VECTOR(7 downto 0);
    signal w_c_data : STD_LOGIC_VECTOR(7 downto 0);
    signal w_tmp_data : STD_LOGIC_VECTOR(7 downto 0);
    signal w_stage_counter : INTEGER;
    signal w_output_3 : STD_LOGIC_VECTOR(7 downto 0);
    signal w_output_4 : STD_LOGIC_VECTOR(7 downto 0);
    signal w_write_enable_PC : STD_LOGIC;
    signal w_pc_increment : STD_LOGIC;
    signal w_operand_low : STD_LOGIC_VECTOR(7 downto 0);
    signal w_operand_high : STD_LOGIC_VECTOR(7 downto 0);
    signal w_ram_write_enable : STD_LOGIC;
    signal w_acc_we : STD_LOGIC;
    signal w_mar_we : STD_LOGIC;
    signal w_b_we: STD_LOGIC;
    signal w_c_we : STD_LOGIC;
    signal w_tmp_we : STD_LOGIC;
    signal w_out_port_3_we : STD_LOGIC;
    signal w_out_port_4_we : STD_LOGIC;
    signal w_pc_data : STD_LOGIC_VECTOR(15 downto 0);
    signal w_minus_flag : STD_LOGIC;
    signal w_equal_flag : STD_LOGIC;
    signal mdr_direction_sig : STD_LOGIC;
    signal write_enable_mdr_sig : STD_LOGIC;
    signal write_enable_alu_out_sig : STD_LOGIC;
    signal update_status_flags_sig : STD_LOGIC;
    signal controller_wait_sig : STD_LOGIC;
    signal io_active_sig : STD_LOGIC;
    signal mdr_fm_data_out_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal wbus_output_connected_components_write_enable_sig : STD_LOGIC_VECTOR(0 to 11);
    signal wbus_output_we_default_sig : STD_LOGIC_VECTOR(0 to 12);
    signal wbus_output_we_io_sig : STD_LOGIC_VECTOR(0 to 12);
    signal write_enable_mdr_fm_sig : STD_LOGIC;
    signal mdr_tm_data_out_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal acc_write_enable : STD_LOGIC := '0';
    signal write_enable_mdr_tm_sig : STD_LOGIC;
    signal sp_increment_sig : STD_LOGIC;
    signal sp_decrement_sig : STD_LOGIC;
    signal sp_data_out_sig : STD_LOGIC_VECTOR(15 downto 0);
    signal w_pc_write_enable_low : STD_LOGIC;
    signal w_pc_write_enable_high : STD_LOGIC;
    signal w_ir_we : STD_LOGIC_VECTOR(0 to 1);
    signal w_first_stage : STD_LOGIC := '0';
    signal w_last_stage : STD_LOGIC := '0';

begin

    o_hltbar <= w_hltbar;
    o_data <= mdr_tm_data_out_sig;

    w_clkbar <= not i_clk;

    -- tie the MAR address output to the address output for the proc
    o_address <= w_mar_addr;

    o_ram_we <= w_ram_write_enable;
     
   o_port_3 <= w_output_3;
   o_port_4 <= w_output_4;
    
    internal_bus : entity work.internal_bus
    port map(
        i_src_sel_def => w_wbus_sel_def,
        i_src_sel_io => w_wbus_sel_io_def, 
        i_dest_sel_def => wbus_output_we_default_sig,
        i_dest_sel_io => wbus_output_we_io_sig,
        i_io_controller_active => io_active_sig,
        i_pc_data => w_pc_data,
        i_sp_data => sp_data_out_sig,
        i_ir_operand_full => w_operand_high & w_operand_low,
        i_acc_data => w_acc_data,
        i_alu_data => w_alu_data,
        i_mdr_fm_data => mdr_fm_data_out_sig,
        i_b_data => w_b_data,
        i_c_data => w_c_data, 
        i_tmp_data => w_tmp_data,
        i_input_port_1_data => i_port_1,
        i_input_port_2_data => i_port_2,
        o_bus_data => w_bus_data_out_sig,
        o_acc_we => w_acc_we,
        o_b_we => w_b_we,
        o_c_we => w_c_we,
        o_tmp_we => w_tmp_we,
        o_mar_we => w_mar_we,
        o_pc_we_full => w_write_enable_PC,
        o_pc_we_low => w_pc_write_enable_low,
        o_pc_we_high => w_pc_write_enable_high,
        o_mdr_tm_we => write_enable_mdr_tm_sig,
        o_ir_we => w_ir_we,
        o_out_port_3_we => w_out_port_3_we,
        o_out_port_4_we => w_out_port_4_we
    );

    PC : entity work.program_counter
        Generic Map(16)
        port map(
            i_clk => w_clkbar,
            i_reset => i_rst,
            i_write_enable_full => w_write_enable_PC,
            i_write_enable_low => w_pc_write_enable_low,
            i_write_enable_high => w_pc_write_enable_high,
            i_increment => w_pc_increment,
            i_data => w_bus_data_out_sig,
            o_data => w_pc_data
        );

    -- MEMORY ADDRESS REGISTER
    MAR : entity work.data_register
        Generic Map(16)
        port map(
            i_clk => i_clk,
            i_rst => i_rst,
            i_write_enable => w_mar_we,
            i_data => w_bus_data_out_sig,
            o_data => w_mar_addr
            );
            
    -- MEMORY DATA_REGISTER - From Ram        
    MDR_FM : entity work.data_register
        Generic Map(8)
        port map(
            i_clk => i_clk,
            i_rst => i_rst,
            -- write enable for both modes
            i_write_enable => write_enable_mdr_fm_sig,
            -- bus to mem (write) mode ports (write to memory)
            i_data => i_data,
            -- mem to bus (read) mode ports (read from memory)
            o_data => mdr_fm_data_out_sig
        );              

            -- MEMORY DATA_REGISTER - To Ram        
    MDR_TM : entity work.data_register
    Generic Map(8)
    port map(
        i_clk => i_clk,
        i_rst => i_rst,
        -- write enable for both modes
        i_write_enable => write_enable_mdr_tm_sig,
        -- bus to mem (write) mode ports (write to memory)
        i_data => w_bus_data_out_sig(7 downto 0),
        -- mem to bus (read) mode ports (read from memory)
        o_data => mdr_tm_data_out_sig
    );              


    IR : entity work.instruction_register
        port map(
            i_clk => i_clk,
            i_clr => w_ir_clr,
            i_data => w_bus_data_out_sig(7 downto 0),
            i_sel_we => w_ir_we,
            o_opcode => w_ir_opcode,
            o_operand_low => w_operand_low,
            o_operand_high => w_operand_high
        );

    SP : entity work.stack_pointer
            port map(
                i_clk => i_clk,
                i_rst => i_rst,
                i_inc => sp_increment_sig,
                i_dec => sp_decrement_sig,
                o_data => sp_data_out_sig
            );

    proc_controller : entity work.proc_controller
        port map(
            i_clk => w_clkbar,
            i_rst => i_rst,
            i_opcode => w_ir_opcode,
            i_minus_flag => w_minus_flag,
            i_equal_flag => w_equal_flag,

            o_wbus_sel => w_wbus_sel_def,
            o_alu_op => w_alu_op,
            o_wbus_control_word => wbus_output_we_default_sig,
            o_pc_inc => w_pc_increment,
            o_mdr_fm_we => write_enable_mdr_fm_sig,
            o_ram_we => w_ram_write_enable,
            o_ir_clr => w_ir_clr,
            o_update_status_flags => update_status_flags_sig,
            o_controller_wait => controller_wait_sig,
            o_sp_inc => sp_increment_sig,
            o_sp_dec => sp_decrement_sig,
            o_HLTBar => w_hltbar,
            o_stage => w_stage_counter,
            o_first_stage => w_first_stage,
            o_last_stage => w_last_stage
        );
        
    acc : entity work.data_register 
        Generic Map(8)
        Port Map (
            i_clk => i_clk,
            i_rst => i_rst,
            i_write_enable => w_acc_we,
            i_data => w_bus_data_out_sig(7 downto 0),
            o_data => w_acc_data
        ); 

    B : entity work.data_register 
    Generic Map(8)
    Port Map (
        i_clk => i_clk,
        i_rst => i_rst,
        i_write_enable => w_b_we,
        i_data => w_bus_data_out_sig(7 downto 0),
        o_data => w_b_data
    );

    C : entity work.data_register 
    Generic Map(8)
    Port Map (
        i_clk => i_clk,
        i_rst => i_rst,
        i_write_enable => w_c_we,
        i_data => w_bus_data_out_sig(7 downto 0),
        o_data => w_c_data
    );


    TMP : entity work.data_register 
    Generic Map(8)
    Port Map (
        i_clk => i_clk,
        i_rst => i_rst,
        i_write_enable => w_tmp_we,
        i_data => w_bus_data_out_sig(7 downto 0),
        o_data => w_tmp_data
    );
        
    ALU : entity work.ALU
        port map (
            i_rst => i_rst,
            i_op => w_alu_op,
            i_input_1 => w_acc_data,
            i_input_2 => w_tmp_data,
            o_out => w_alu_data,
            i_update_status_flags => update_status_flags_sig,
            o_minus_flag => w_minus_flag,
            o_equal_flag => w_equal_flag
            );

    OUTPUT_PORT_3 : entity work.data_register
    Generic Map(8)
    port map (
        i_clk => i_clk,
        i_rst => i_rst,
        i_write_enable => w_out_port_3_we,
        i_data => w_bus_data_out_sig(7 downto 0),
        o_data => w_output_3
    );

    OUTPUT_PORT_4 : entity work.data_register
    Generic Map(8)
    port map (
        i_clk => i_clk,
        i_rst => i_rst,
        i_write_enable => w_out_port_4_we,
        i_data => w_bus_data_out_sig(7 downto 0),
        o_data => w_output_4
    );

    IO : entity work.IO_controller
        Port map(
            i_clk => w_clkbar,
            i_rst => i_rst,
            i_opcode => w_ir_opcode,
            i_portnum => w_operand_low(2 downto 0),
            o_bus_src_sel => w_wbus_sel_io_def,
            o_bus_dest_sel => wbus_output_we_io_sig,
            o_active => io_active_sig
        );

    REGISTER_LOG : process(i_clk)
    begin
        if rising_edge(i_clk) and w_last_stage = '1' then
            Report "Current Simulation Time: " & time'image(now)
                & ", PC: " & to_hex_string(w_pc_data)
                & ", MAR: " & to_hex_string(w_mar_addr)
                & ", MDR-FM: " & to_hex_string(mdr_fm_data_out_sig)
                & ", MDR-TM: " & to_hex_string(mdr_tm_data_out_sig)
                & ", OPCODE: " & to_hex_string(w_ir_opcode)
                & ", ACC: " & to_hex_string(w_acc_data)
                & ", B: " & to_hex_string(w_b_data)
                & ", C: " & to_hex_string(w_c_data)
                & ", TMP: " & to_hex_string(w_tmp_data)
                & ", ALU: " & to_hex_string(w_alu_data)
                & ", OUT-3: " & to_hex_string(w_output_3)
                & ", OUT-4: " & to_hex_string(w_output_4);
        end if;
    end process;

end rtl;
    
          