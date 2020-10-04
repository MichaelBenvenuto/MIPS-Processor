library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.MIPS_CPU_PKG.ALL;

entity mips_cpu is
    port(
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;

        ext_intr : in  STD_LOGIC;
        ext_ackn : out STD_LOGIC;
        ext_addr : out STD_LOGIC_VECTOR(31 downto 0);
        ext_read : in  STD_LOGIC_VECTOR(31 downto 0);
        ext_data : out STD_LOGIC_VECTOR(31 downto 0)
    );
end mips_cpu;

architecture arch of mips_cpu is
    signal main_imem_addr : STD_LOGIC_VECTOR(PROGRAM_COUNTER_BITS - 1 downto 0)         := (others => '0');
    signal id_branch, id_jump : STD_LOGIC                                               := '0';
    signal id_instr, ie_instr, im_instr, main_imem_data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal ie_control, im_control, wb_control : STD_LOGIC_VECTOR(CONT_WORD)             := (others => '0');
    signal ie_data, im_data, im_addr, wb_memdata : STD_LOGIC_VECTOR(31 downto 0)        := (others => '0');

    signal ie_wb, im_wb, wb_reg : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');

    alias wb_regw : STD_LOGIC is wb_control(CONT_REGWR);

    signal wb_data, wb_data1 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    signal id_imm32, ie_imm32 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    signal id_forward1, id_forward2 : STD_LOGIC;
    signal id_forward1_data, id_forward2_data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    signal ie_data1, ie_data2 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    signal ie_forward1, ie_forward2 : STD_LOGIC := '0';
    signal ie_forward1_data, ie_forward2_data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    signal im_forward : STD_LOGIC := '0';
    signal im_forward_data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    signal ie_data_to_forward, im_data_to_forward : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    signal jump_addr, id_pcu : STD_LOGIC_VECTOR(PROGRAM_COUNTER_BITS - 1 downto 0) := (others => '0');

    signal id_link_reg : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');

    signal ie_inter, im_inter, im_except : STD_LOGIC := '0';

begin

    FETCH : entity work.mips_pipeline_if
    port map(
        clk_i => clk_i,
        rst_i => rst_i,

        cs_i => not (ie_inter or im_inter or im_except),

        branch => id_branch,
        jump => id_jump,
        branch_addr => id_imm32(PROGRAM_COUNTER_BITS-1 downto 0),
        jump_addr => jump_addr,
        main_mem_addr => main_imem_addr,
        main_mem_data => main_imem_data,

        pcu_o => id_pcu,

        instr_o => id_instr
    );

    DECODE : entity work.mips_pipeline_id
    port map(
        clk_i => clk_i,
        rst_i => rst_i,

        cs_i => not (ie_inter or im_inter or im_except),

        instr => id_instr,
        instr_o => ie_instr,
        ctrl => ie_control,

        forward_data1 => id_forward1,
        forward_data1_data => id_forward1_data,
        forward_data2 => id_forward2,
        forward_data2_data => id_forward2_data,

        imm32_nopipe => id_imm32,
        imm32_o => ie_imm32,

        data1_o => ie_data1,
        data2_o => ie_data2,

        branch => id_branch,
        jump => id_jump,

        pcu => id_pcu,

        jump_addr => jump_addr,
        link_reg => id_link_reg,

        plwb_regw => wb_regw,
        plwb_wb   => wb_reg,
        plwb_data => wb_data
    );

    EXECUTE : entity work.mips_pipeline_ie
    port map(
        clk_i => clk_i,
        rst_i => rst_i,

        cs_i => not (im_inter or im_except),

        ctrl => ie_control,
        ctrl_o => im_control,

        instr => ie_instr,
        instr_o => im_instr,

        forward_data1 => ie_forward1,
        forward_data1_data => ie_forward1_data,
        forward_data2 => ie_forward2,
        forward_data2_data => ie_forward2_data,

        data_1 => ie_data1,
        data_2 => ie_data2,

        link_reg => id_link_reg,

        imm32 => ie_imm32,
        
        im_data => im_data,
        im_addr => im_addr,

        ie_data_to_forward => ie_data_to_forward,

        ie_wb => ie_wb,
        reg_wb => im_wb,

        alu_busy => ie_inter
    );

    MEMORY : entity work.mips_pipeline_im
    port map(
        clk_i => clk_i,
        rst_i => rst_i,

        ctrl => im_control,
        ctrl_o => wb_control,
        instr => im_instr,
        
        mem_wdata => im_data,
        mem_addr  => im_addr,
        mem_rdata => wb_memdata,

        imem_addr => main_imem_addr,
        imem_data => main_imem_data,

        forward_data => im_forward,
        forward_data_data => im_forward_data,

        exception => im_except,
        interrupt => im_inter,

        im_data_to_forward => im_data_to_forward,

        im_wr_reg => im_wb,
        
        wb_exe_data => wb_data1,
        wb_wr_reg => wb_reg,

        ext_mem_intr_i => ext_intr,
        ext_mem_ackn_o => ext_ackn,
        ext_mem_addr_o => ext_addr,
        ext_mem_data_i => ext_read,
        ext_mem_data_o => ext_data
    );

    FORWARD : entity work.mips_forward
    port map(
        id_rs => id_instr(INSTR_RS),
        id_rt => id_instr(INSTR_RT),

        id_forward1 => id_forward1,
        id_forward1_data => id_forward1_data,
        id_forward2 => id_forward2,
        id_forward2_data => id_forward2_data,

        ie_rs => ie_instr(INSTR_RS),
        ie_rt => ie_instr(INSTR_RT),
        ie_wb => ie_wb,

        ie_forward1 => ie_forward1,
        ie_forward1_data => ie_forward1_data,
        ie_forward2 => ie_forward2,
        ie_forward2_data => ie_forward2_data,

        ie_data_to_forward => ie_data_to_forward,

        im_wb => im_wb,

        im_rt => im_instr(INSTR_RT),

        im_forward => im_forward,
        im_forward_data => im_forward_data,

        im_data_to_forward => im_data_to_forward,

        wb_reg => wb_reg,

        wb_data_to_forward => wb_data
    );

    wb_data <= wb_memdata when wb_control(CONT_MEMA) = '1' and wb_control(CONT_MEMWR) = '0' else wb_data1;

end arch;