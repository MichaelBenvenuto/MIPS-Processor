library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.MIPS_CPU_PKG.ALL;

entity mips_pipeline_ie is
    port(
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;

        cs_i  : in STD_LOGIC;

        ctrl : in STD_LOGIC_VECTOR(CONT_WORD);
        ctrl_o : out STD_LOGIC_VECTOR(CONT_WORD);

        instr : in STD_LOGIC_VECTOR(31 downto 0);
        instr_o : out STD_LOGIC_VECTOR(31 downto 0);

        forward_data1 : in STD_LOGIC;
        forward_data1_data : in STD_LOGIC_VECTOR(31 downto 0);
        forward_data2 : in STD_LOGIC;
        forward_data2_data : in STD_LOGIC_VECTOR(31 downto 0);

        data_1 : in STD_LOGIC_VECTOR(31 downto 0);
        data_2 : in STD_LOGIC_VECTOR(31 downto 0);

        link_reg : in STD_LOGIC_VECTOR(4 downto 0);

        imm32 : in STD_LOGIC_VECTOR(31 downto 0);

        im_data : out STD_LOGIC_VECTOR(31 downto 0);
        im_addr : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

        ie_data_to_forward : out STD_LOGIC_VECTOR(31 downto 0);

        ie_wb : out STD_LOGIC_VECTOR(4 downto 0);
        
        reg_wb : out STD_LOGIC_VECTOR(4 downto 0);

        alu_busy : out STD_LOGIC
    );
end mips_pipeline_ie;

architecture arch of mips_pipeline_ie is
    signal data_a, data_b, data_mem : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_res : STD_LOGIC_VECTOR(31 downto 0);
    signal busy : STD_LOGIC;
begin

    data_a <= forward_data1_data when forward_data1 = '1' else data_1;
    data_b <= imm32 when ctrl(CONT_ALUSRC) = '1' else data_mem;
    data_mem <= forward_data2_data when forward_data2 = '1' else data_2;

    ie_data_to_forward <= alu_res;

    ie_wb <= link_reg        when ctrl(CONT_LINK) = '1'   else
             instr(INSTR_RT) when ctrl(CONT_REGDST) = '1' else instr(INSTR_RD);

    alu_busy <= busy;

    process(clk_i, rst_i, cs_i)
    begin
        if rst_i = '1' then
            im_addr <= (others => '0');
            im_data <= (others => '0');
            ctrl_o  <= (others => '0');
            instr_o <= (others => '0');
            reg_wb  <= (others => '0');
        elsif rising_edge(clk_i) and cs_i = '1' and busy = '0' then
            im_addr <= alu_res;
            im_data <= data_mem;
            ctrl_o  <= ctrl;
            instr_o <= instr;
            reg_wb  <= ie_wb;
        end if;
    end process;

    ALU : entity work.mips_alu
    port map(
        clk_i => clk_i,
        rst_i => rst_i,

        alu_opcode => instr(INSTR_OPCODE),
        alu_funct => instr(INSTR_FUNC),
        alu_sa => instr(INSTR_SA),

        opd_a => data_a,
        opd_b => data_b,

        alu_busy => busy,

        alu_res => alu_res
    );

end arch;