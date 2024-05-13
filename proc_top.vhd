library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity proc_top is
    generic (
        SIMULATION_MODE : boolean := false
    );
    port( i_clk : in STD_LOGIC;
          i_reset : in STD_LOGIC;  -- map to FPGA clock will be stepped down to 1HZ
                                -- for simulation TB should generate clk of 1HZ
--          S1_addr_in : in STD_LOGIC_VECTOR(15 downto 0);       -- address setting - S1 in ref
--          S2_prog_run_switch : in STD_LOGIC;       -- prog / run switch (prog=0, run=1)
--          S3_data_in : in STD_LOGIC_VECTOR(7 downto 0);       -- data setting      S3 in ref
--          S4_read_write_switch : in STD_LOGIC;       -- read/write toggle   -- 1 to write values to ram. 0 to read. needs to be 0 for run mode
--          S5_clear_start : in STD_LOGIC;       -- start/clear (reset)  -- 
--          S6_step_toggle : in STD_LOGIC;       -- single step -- 1 for a single step
--          S7_manual_auto_switch : in STD_LOGIC;       -- manual/auto mode - 0 for manual, 1 for auto. 
--          memory_access_clk : in STD_LOGIC;  -- toogle memory write. if in program, write and manual mode. this is the ram clock for prog mode. execution mode should use the system clock.
          in_port_1 : in STD_LOGIC_VECTOR(7 downto 0);
          in_port_2 : in STD_LOGIC_VECTOR(7 downto 0);
          out_port_3 : out STD_LOGIC_VECTOR(7 downto 0);
          out_port_4 : out STD_LOGIC_VECTOR(7 downto 0);
          --data_out : out STD_LOGIC_VECTOR(7 downto 0);
         -- o_running : out STD_LOGIC;
        --   s7_anodes_out : out STD_LOGIC_VECTOR(3 downto 0);      -- maps to seven segment display
        --   s7_cathodes_out : out STD_LOGIC_VECTOR(6 downto 0);     -- maps to seven segment display
     --     phase_out : out STD_LOGIC_VECTOR(5 downto 0);
        --  clear_out : out STD_LOGIC;
        --  step_out : out STD_LOGIC;
          o_HLTBar : out STD_LOGIC;
          o_address : out STD_LOGIC_VECTOR(15 downto 0);         -- 16 bit output address
          i_data : in STD_LOGIC_VECTOR(7 downto 0);          -- 8 bit bidirectional data
          o_data: out STD_LOGIC_VECTOR(7 downto 0);
          o_rd : out STD_LOGIC;                          -- active high signal to read from memory using o_address and i_data 
          o_ram_we : out STD_LOGIC                           -- active high signal to write from memory using o_address and o_data

    );
    attribute MARK_DEBUG : string;
    --attribute MARK_DEBUG of S5_clear_start : signal is "true";
--    attribute MARK_DEBUG of S6_step_toggle : signal is "true";
--    attribute MARK_DEBUG of S7_manual_auto_switch : signal is "true";
    --attribute MARK_DEBUG of o_running : signal is "true";

end proc_top;

architecture rtl of proc_top is

--    attribute MARK_DEBUG : string;

    signal clk_ext_converted_sig : STD_LOGIC;
    signal w_clkbar : std_logic;
    signal clk_disp_refresh_1KHZ_sig : std_logic;
    signal w_hltbar : std_logic := '1';
    signal clr_sig : STD_LOGIC;
    signal clrbar_sig : STD_LOGIC;
    signal wbus_sel_sig : STD_LOGIC_VECTOR(3 downto 0);
    signal wbus_sel_io_sig : STD_LOGIC_VECTOR(3 downto 0);       
    signal alu_op_sig : std_logic_vector(3 downto 0);
    signal acc_data_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal alu_data_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal IR_operand_sig : STD_LOGIC_VECTOR(15 downto 0);
    signal IR_opcode_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal ir_clear_sig : STD_LOGIC;
    signal RAM_data_out_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal w_bus_data_out_sig : STD_LOGIC_VECTOR(15 downto 0);
    signal w_mar_addr: STD_LOGIC_VECTOR(15 downto 0);
    signal ram_addr_in_sig : STD_LOGIC_VECTOR(15 downto 0);
    signal ram_data_in_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal b_data_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal c_data_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal tmp_data_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal display_data : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal stage_counter_sig : INTEGER;
    signal output_1_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal output_2_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal w_write_enable_PC : STD_LOGIC;
    signal pc_increment_sig : STD_LOGIC;
    signal write_enable_ir_opcode_sig : STD_LOGIC;
    signal write_enable_low_sig : STD_LOGIC;
    signal write_enable_high_sig : STD_LOGIC;
    signal operand_low_out_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal operand_high_out_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal ram_write_enable_sig : STD_LOGIC;
    signal selected_ram_write_enable_sig : STD_LOGIC;
    signal ram_clk_in_sig : STD_LOGIC;
    signal write_enable_acc_sig : STD_LOGIC;
    signal w_write_enable_mar : STD_LOGIC;
    signal write_enable_B_sig: STD_LOGIC;
    signal write_enable_C_sig : STD_LOGIC;
    signal write_enable_output_sig : STD_LOGIC;
    signal write_enable_tmp_sig : STD_LOGIC;
    signal out_port_3_write_enable_sig : STD_LOGIC;
    signal out_port_4_write_enable_sig : STD_LOGIC;
    signal pc_data_out_sig : STD_LOGIC_VECTOR(15 downto 0);
    signal w_minus_flag : STD_LOGIC;
    signal w_equal_flag : STD_LOGIC;
    signal alu_buffer_out : STD_LOGIC_VECTOR(7 downto 0);
    signal mdr_data_out_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal mdr_direction_sig : STD_LOGIC;
    signal write_enable_mdr_sig : STD_LOGIC;
    signal write_enable_alu_out_sig : STD_LOGIC;
    signal alu_data_out : STD_LOGIC_VECTOR(7 downto 0);
    signal update_status_flags_sig : STD_LOGIC;
    signal data_out_signal : STD_LOGIC_VECTOR(7 downto 0); 
    signal input_port_1_data_in_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal input_port_2_data_in_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal controller_wait_sig : STD_LOGIC;
    signal io_active_sig : STD_LOGIC;
    signal mdr_fm_data_out_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal wbus_output_connected_components_write_enable_sig : STD_LOGIC_VECTOR(0 to 11);
    signal wbus_output_we_default_sig : STD_LOGIC_VECTOR(0 to 12);
    signal wbus_output_we_io_sig : STD_LOGIC_VECTOR(0 to 12);
    signal write_enable_mdr_fm_sig : STD_LOGIC;
    signal mdr_tm_data_out_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal acc_write_enable : STD_LOGIC;
    signal write_enable_mdr_tm_sig : STD_LOGIC;
    signal sp_increment_sig : STD_LOGIC;
    signal sp_decrement_sig : STD_LOGIC;
    signal sp_data_out_sig : STD_LOGIC_VECTOR(15 downto 0);
    signal w_pc_write_enable_low : STD_LOGIC;
    signal w_pc_write_enable_high : STD_LOGIC;
    signal w_ir_we : STD_LOGIC_VECTOR(0 to 1);

    attribute MARK_DEBUG of clk_ext_converted_sig : signal is "true";
    --attribute MARK_DEBUG of i_clk : signal is "true";
    attribute MARK_DEBUG of w_clkbar : signal is "true";
    
    attribute MARK_DEBUG of w_hltbar : signal is "true";
    attribute MARK_DEBUG of clrbar_sig : signal is "true";
    attribute MARK_DEBUG of clr_sig : signal is "true";
    attribute MARK_DEBUG of alu_op_sig : signal is "true";
    attribute MARK_DEBUG of w_mar_addr : signal is "true";
    attribute MARK_DEBUG of IR_opcode_sig : signal is "true";
    attribute MARK_DEBUG of IR_operand_sig : signal is "true";
    attribute MARK_DEBUG of acc_data_sig : signal is "true";
    attribute MARK_DEBUG of b_data_sig : signal is "true";
    attribute MARK_DEBUG of output_1_sig : signal is "true";
begin

    clr_sig <= i_reset;
--    clr_sig <= '1' when S5_clear_start = '1' else '0';
    clrbar_sig <= not clr_sig;
    o_hltbar <= w_hltbar;
--    o_running <= S7_manual_auto_switch and hltbar_sig;
   -- clear_out <= S5_clear_start;
 --   step_out <= S6_step_toggle; 
    o_data <= ram_data_out_sig;

    w_clkbar <= not i_clk;

    IR_operand_sig <= operand_high_out_sig & operand_low_out_sig;

    -- tie the MAR address output to the address output for the proc
    o_address <= w_mar_addr;

    o_ram_we <= ram_write_enable_sig;
     
   -- phase_out <= std_logic_vector(shift_left(unsigned'("000001"), stage_counter_sig - 1));
    

    -- TODO move out
    -- GENERATING_CLOCK_CONVERTER:
    --     if SIMULATION_MODE
    --     generate
    --         passthrough_clock_converter : entity work.passthrough_clock_converter
    --         port map (
    --             clrbar => clrbar_sig,
    --             clk_in => clk_ext,   -- simulation test bench should generate a 1HZ clock
    --             clk_out => clk_ext_converted_sig
    --         );
    --     else generate
    --         FPGA_clock_converter : entity work.clock_converter
    --         port map (
    --             clrbar => clrbar_sig,
    --             clk_in_100MHZ => clk_ext,
    --             clk_out_1HZ => clk_ext_converted_sig,
    --             clk_out_1KHZ => clk_disp_refresh_1KHZ_sig
    --         );
    --     end generate;

    -- -- TODO move out        
    -- CLOCK_CTRL : entity work.clock_controller 

    --     port map (
    --         clk_in => clk_ext_converted_sig,
    --         prog_run_switch => S2_prog_run_switch,
    --         step_toggle => S6_step_toggle,
    --         manual_auto_switch => S7_manual_auto_switch,
    --         hltbar => hltbar_sig,
    --         clrbar => clrbar_sig,
    --         clk_out => i_clk,
    --         clkbar_out => w_clkbar
    --     );

    
    -- single_pulse_generator : entity work.single_pulse_generator
    --     port map(
    --         clk => clk_out_1HZ,
    --         start => pulse,
    --         pulse_out => clock_pulse
    --     );

    --REDO to separate address and data
    -- also ram abd io ports are moving out of the processor but the 
    -- registers are staying. so this is more the internal data buss.
    internal_bus : entity work.internal_bus
        port map(
            i_src_sel_def => wbus_sel_sig,
            i_src_sel_io => wbus_sel_io_sig, 
            i_dest_sel_def => wbus_output_we_default_sig,
            i_dest_sel_io => wbus_output_we_io_sig,
            i_io_controller_active => io_active_sig,
            i_pc_data => pc_data_out_sig,
            i_sp_data => sp_data_out_sig,
            i_ir_operand_full => IR_operand_sig,
            i_acc_data => acc_data_sig,
            i_alu_data => alu_data_sig,
            i_mdr_fm_data => mdr_fm_data_out_sig,
            i_b_data => b_data_sig,
            i_c_data => c_data_sig, 
            i_tmp_data => tmp_data_sig,
            i_input_port_1_data => input_port_1_data_in_sig,
            i_input_port_2_data => input_port_2_data_in_sig,
            o_bus_data => w_bus_data_out_sig,
            o_acc_we => write_enable_acc_sig,
            o_b_we => write_enable_B_sig,
            o_c_we => write_enable_C_sig,
            o_tmp_we => write_enable_tmp_sig,
            o_mar_we => w_write_enable_mar,
            o_pc_we_full => w_write_enable_PC,
            o_pc_we_low => w_pc_write_enable_low,
            o_pc_we_high => w_pc_write_enable_high,
            o_mdr_tm_we => write_enable_mdr_tm_sig,
            o_ir_we => w_ir_we,
            -- o_ir_opcode_we => write_enable_ir_opcode_sig,
            -- o_ir_operand_we_low => write_enable_low_sig,
            -- o_ir_operand_we_high => write_enable_high_sig,
            o_out_port_3_we => out_port_3_write_enable_sig,
            o_out_port_4_we => out_port_4_write_enable_sig
        );

    PC : entity work.program_counter
        Generic Map(16)
        port map(
            i_clk => w_clkbar,
            i_reset => i_reset,
            i_write_enable_full => w_write_enable_PC,
            i_write_enable_low => w_pc_write_enable_low,
            i_write_enable_high => w_pc_write_enable_high,
            i_increment => pc_increment_sig,
            i_data => w_bus_data_out_sig,
            o_data => pc_data_out_sig
        );

    -- MEMORY ADDRESS REGISTER
    MAR : entity work.data_register
        Generic Map(16)
        port map(
            i_clk => i_clk,
            i_rst => clr_sig,
            i_write_enable => w_write_enable_mar,
            i_data => w_bus_data_out_sig,
            o_data => w_mar_addr
            );
            
    -- MEMORY DATA_REGISTER - From Ram        
    MDR_FM : entity work.data_register
        Generic Map(8)
        port map(
            i_clk => i_clk,
            i_rst => clr_sig,
            -- write enable for both modes
            i_write_enable => write_enable_mdr_fm_sig,
            -- bus to mem (write) mode ports (write to memory)
            i_data => ram_data_out_sig,
            -- mem to bus (read) mode ports (read from memory)
            o_data => mdr_fm_data_out_sig
        );              

            -- MEMORY DATA_REGISTER - To Ram        
    MDR_TM : entity work.data_register
    Generic Map(8)
    port map(
        i_clk => i_clk,
        i_rst => clr_sig,
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
            i_clr => ir_clear_sig,
            i_data => w_bus_data_out_sig(7 downto 0),
            i_sel_we => w_ir_we,
            o_opcode => IR_opcode_sig,
            o_operand_low => operand_low_out_sig,
            o_operand_high => operand_high_out_sig
        );

    -- IR : entity work.data_register
    --     generic map(8)
    --     port map(
    --         i_clk => i_clk,
    --         i_clr => ir_clear_sig,
    --         i_write_enable => write_enable_ir_opcode_sig,
    --         i_data => w_bus_data_out_sig(7 downto 0),
    --         o_data => IR_opcode_sig        
    --     );

    -- IR_Operand : entity work.IR_operand_latch
    --         port map(
    --             clk => i_clk,
    --             clr => ir_clear_sig,
    --             ir_operand_in => w_bus_data_out_sig(7 downto 0),
    --             write_enable_low => write_enable_low_sig,
    --             write_enable_high => write_enable_high_sig,
    --             operand_low_out => operand_low_out_sig,
    --             operand_high_out => operand_high_out_sig
    --         );

    SP : entity work.stack_pointer
            port map(
                i_clk => i_clk,
                i_clr => clr_sig,
                i_inc => sp_increment_sig,
                i_dec => sp_decrement_sig,
                o_data => sp_data_out_sig
            );


    -- input_port_multipler : entity work.input_port_multiplexer
    --     port map(
    --         input_port_select_in => ,
    --         input_port_1 => in_port_1,
    --         input_port_2 => in_port_2,
    --         input_port_out => input_port_data_in_sig);

    -- --TODO MOVE OUT
    -- ram_bank_input : entity work.memory_input_multiplexer            
    --      port map(prog_run_select => S2_prog_run_switch,
    --              prog_data_in => S3_data_in,
    --              run_data_in => mdr_tm_data_out_sig,
    --              prog_addr_in => S1_addr_in,
    --              run_addr_in => w_mar_addr,
    --              prog_clk_in => memory_access_clk,
    --              run_clk_in => i_clk,
    --              prog_write_enable => S4_read_write_switch,
    --              run_write_enable => ram_write_enable_sig,
    --              select_data_in => ram_data_in_sig,
    --              select_addr_in => ram_addr_in_sig,
    --              select_clk_in => ram_clk_in_sig,
    --              select_write_enable => selected_ram_write_enable_sig
    --          );

    -- --TODO MOVE OUT
    -- ram_bank : entity work.ram_bank
    --     port map(
    --         clk => ram_clk_in_sig,
    --         addr => ram_addr_in_sig,
    --         data_in => ram_data_in_sig,
    --         write_enable => selected_ram_write_enable_sig,
    --         data_out => ram_data_out_sig
    --     );

    proc_controller : entity work.proc_controller
        port map(
            i_clk => w_clkbar,
            i_clrbar => clrbar_sig,
            i_opcode => IR_opcode_sig,
            i_minus_flag => w_minus_flag,
            i_equal_flag => w_equal_flag,

            o_wbus_sel => wbus_sel_sig,
            o_alu_op => alu_op_sig,
            o_wbus_control_word => wbus_output_we_default_sig,
            o_pc_inc => pc_increment_sig,
            o_mdr_fm_we => write_enable_mdr_fm_sig,
            o_ram_we => ram_write_enable_sig,
            o_ir_clr => ir_clear_sig,
            o_update_status_flags => update_status_flags_sig,
            o_controller_wait => controller_wait_sig,
            o_sp_inc => sp_increment_sig,
            o_sp_dec => sp_decrement_sig,
            o_HLTBar => w_hltbar,
            o_stage => stage_counter_sig
        );
        
    acc : entity work.data_register 
        Generic Map(8)
        Port Map (
            i_clk => i_clk,
            i_rst => clr_sig,
            i_write_enable => write_enable_acc_sig,
            i_data => w_bus_data_out_sig(7 downto 0),
            o_data => acc_data_sig
        ); 

    B : entity work.data_register 
    Generic Map(8)
    Port Map (
        i_clk => i_clk,
        i_rst => clr_sig,
        i_write_enable => write_enable_B_sig,
        i_data => w_bus_data_out_sig(7 downto 0),
        o_data => b_data_sig
    );


    C : entity work.data_register 
    Generic Map(8)
    Port Map (
        i_clk => i_clk,
        i_rst => clr_sig,
        i_write_enable => write_enable_C_sig,
        i_data => w_bus_data_out_sig(7 downto 0),
        o_data => c_data_sig
    );


    TMP : entity work.data_register 
    Generic Map(8)
    Port Map (
        i_clk => i_clk,
        i_rst => clr_sig,
        i_write_enable => write_enable_tmp_sig,
        i_data => w_bus_data_out_sig(7 downto 0),
        o_data => tmp_data_sig
    );
        
    ALU : entity work.ALU
        port map (
            i_clr => clr_sig,
            i_op => alu_op_sig,
            i_input_1 => acc_data_sig,
            i_input_2 => tmp_data_sig,
            o_out => alu_data_sig,
            i_update_status_flags => update_status_flags_sig,
            o_minus_flag => w_minus_flag,
            o_equal_flag => w_equal_flag
            );

    OUTPUT_PORT_3 : entity work.data_register
    Generic Map(8)
    port map (
        i_clk => i_clk,
        i_rst => clr_sig,
        i_write_enable => out_port_3_write_enable_sig,
        i_data => w_bus_data_out_sig(7 downto 0),
        o_data => output_1_sig
    );

    OUTPUT_PORT_4 : entity work.data_register
    Generic Map(8)
    port map (
        i_clk => i_clk,
        i_rst => clr_sig,
        i_write_enable => out_port_4_write_enable_sig,
        i_data => w_bus_data_out_sig(7 downto 0),
        o_data => output_2_sig
    );

    IO : entity work.IO_controller
        Port map(
            i_clk => w_clkbar,
            i_rst => clr_sig,
            i_opcode => IR_opcode_sig,
            i_portnum => IR_operand_sig(2 downto 0),
            o_bus_src_sel => wbus_sel_io_sig,
            o_bus_dest_sel => wbus_output_we_io_sig,
            o_active => io_active_sig
        );

    REGISTER_LOG : process(i_clk)
    begin
        Report "Current Simulation Time: " & time'image(now)
            & ", PC: " & to_string(pc_data_out_sig)
            & ", MAR: " & to_string(w_mar_addr)
            & ", MDR: " & to_string(mdr_data_out_sig)
            & ", OPCODE: " & to_string(IR_opcode_sig)
            & ", ACC: " & to_string(acc_data_sig)
            & ", B: " & to_string(b_data_sig)
            & ", C: " & to_string(c_data_sig);
    end process;

    -- OUTPUT_REG : entity work.output
    --         port map (
    --             clk => i_clk,
    --             clr => clr_sig,
    --             load_OUT_bar => enable_write_output_sig,
    --             output_in => w_bus_data_out_sig(7 downto 0),
    --             output_out => output_sig
    --         );
        
    -- display_data <= ("00000000" & output_sig) when not running else
    --                 ("0000" & pc_data_sig & IR_opcode_sig & IR_operand_sig) when running;
    -- TODO use a multiplexer so different types of output can be used on the seven segment displays
--    display_data(7 downto 4) <= IR_opcode_sig when running;
--    display_data(3 downto 0) <= IR_operand_sig when running;
--    display_data(11 downto 8) <= pc_data_sig when running;
        
    -- TODO Move Out
    -- GENERATING_FPGA_OUTPUT : if SIMULATION_MODE = false
    --     generate  
    --         display_controller : entity work.display_controller
    --         port map(
    --            clk => clk_disp_refresh_1KHZ_sig,
    --            rst => clr_sig,
    --            data_in => display_data,
    --            anodes_out => s7_anodes_out,
    --            cathodes_out => s7_cathodes_out
    --        );
    --    end generate;                        

end rtl;
    
          