library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.MIPS_CPU_PKG.ALL;

entity mips_pipeline_id is
    port(
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;

        cs_i : in STD_LOGIC;

        instr : in STD_LOGIC_VECTOR(31 downto 0);
        ctrl  : out STD_LOGIC_VECTOR(CONT_WORD);
        instr_o : out STD_LOGIC_VECTOR(31 downto 0);

        pcu : in STD_LOGIC_VECTOR(PROGRAM_COUNTER_BITS - 1 downto 0);

        forward_data1 : in STD_LOGIC;
        forward_data1_data : in STD_LOGIC_VECTOR(31 downto 0);
        forward_data2 : in STD_LOGIC;
        forward_data2_data : in STD_LOGIC_VECTOR(31 downto 0);

        imm32_nopipe : out STD_LOGIC_VECTOR(31 downto 0);

        imm32_o : out STD_LOGIC_VECTOR(31 downto 0);

        data1_o : out STD_LOGIC_VECTOR(31 downto 0);
        data2_o : out STD_LOGIC_VECTOR(31 downto 0);

        branch : out STD_LOGIC;
        jump   : out STD_LOGIC;

        jump_addr : out STD_LOGIC_VECTOR(PROGRAM_COUNTER_BITS - 1 downto 0);
        link_reg  : out STD_LOGIC_VECTOR(4 downto 0);

        plwb_regw : in STD_LOGIC;
        plwb_wb   : in STD_LOGIC_VECTOR(4 downto 0);
        plwb_data : in STD_LOGIC_VECTOR(31 downto 0)
    );
end mips_pipeline_id;

architecture arch of mips_pipeline_id is
    signal data1, data_a : STD_LOGIC_VECTOR(31 downto 0);
    signal data2, data_b : STD_LOGIC_VECTOR(31 downto 0);

    signal b_data1 : STD_LOGIC_VECTOR(31 downto 0);
    signal b_data2 : STD_LOGIC_VECTOR(31 downto 0);

    signal control : STD_LOGIC_VECTOR(CONT_WORD);

    signal imm32 : STD_LOGIC_VECTOR(31 downto 0);

    signal int_br : STD_LOGIC;
    signal int_jp : STD_LOGIC;

    signal pcu_pipe : STD_LOGIC_VECTOR(PROGRAM_COUNTER_BITS - 1 downto 0);
begin

    branch <= int_br and control(CONT_BRANCH);
    jump   <= control(CONT_JUMP);
    imm32 <= (0 to 15 => instr(INSTR_IMM)(15)) & instr(INSTR_IMM);

    jump_addr <= data1(PROGRAM_COUNTER_BITS - 1 downto 0) when control(CONT_JUMPREG) = '1' else 
                 instr(PROGRAM_COUNTER_BITS - 1 downto 0);

    imm32_nopipe <= imm32;

    data_a <= (31 downto PROGRAM_COUNTER_BITS => '0') & (pcu_pipe + '1') when control(CONT_LINK) = '1' else 
              forward_data1_data when forward_data1 = '1' else data1;

    data_b <= (others => '0') when control(CONT_LINK) = '1' else forward_data2_data when forward_data2 = '1' else data2; 

    process(clk_i, rst_i, cs_i)
    begin
        if rst_i = '1' then
            imm32_o <= (others => '0');
            ctrl <= (others => '0');
            data1_o <= (others => '0');
            data2_o <= (others => '0');
            instr_o <= (others => '0');
            pcu_pipe <= (others => '0');
        elsif rising_edge(clk_i) and cs_i = '1' then
            imm32_o <= imm32;
            ctrl <= control;
            data1_o <= data_a;
            data2_o <= data_b;
            instr_o <= instr;
            pcu_pipe <= pcu;
            if (control(CONT_LINK) and control(CONT_REGWR)) = '1' then
                link_reg <= INSTR(INSTR_RD);
            else
                link_reg <= "11111";
            end if;
        end if;
    end process;

    REGISTER_FILE : entity work.mips_regfile
    port map(
        clk_i => clk_i,
        rst_i => rst_i,

        regw => plwb_regw,

        reg1 => instr(INSTR_RS),
        reg2 => instr(INSTR_RT),

        regwb => plwb_wb,

        data1 => data1,
        data2 => data2,

        data_wb => plwb_data
    );

    BRANCH_CONTROLLER : entity work.mips_bcon
    port map(
        clk_i => clk_i,
        rst_i => rst_i,

        opd_a => data_a,
        opd_b => data_b,

        branch_opcode => instr(INSTR_OPCODE),
        branch_opextd => instr(INSTR_RT),

        branch => int_br
    );

    GENERAL_CONTROLLER : entity work.mips_gcu
    port map(
        instr => instr,
        cw_o => control
    );
end arch;