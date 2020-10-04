library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.MIPS_CPU_PKG.ALL;

entity mips_pipeline_if is
    port(
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;

        cs_i  : in STD_LOGIC;

        branch : in STD_LOGIC;
        jump   : in STD_LOGIC;

        branch_addr : in STD_LOGIC_VECTOR(PROGRAM_COUNTER_BITS-1 downto 0);
        jump_addr : in STD_LOGIC_VECTOR(PROGRAM_COUNTER_BITS-1 downto 0);

        main_mem_addr : in STD_LOGIC_VECTOR(PROGRAM_COUNTER_BITS-1 downto 0);
        main_mem_data : out STD_LOGIC_VECTOR(31 downto 0);

        pcu_o : out STD_LOGIC_VECTOR(PROGRAM_COUNTER_BITS-1 downto 0);

        --uart_programmer_ena   : in STD_LOGIC;
        --uart_programmer_addr  : in STD_LOGIC_VECTOR(11 downto 0);
        --uart_programmer_instr : in STD_LOGIC_VECTOR(31 downto 0);

        instr_o : out STD_LOGIC_VECTOR(31 downto 0)
    );
end mips_pipeline_if;

architecture arch of mips_pipeline_if is
    signal pcu : STD_LOGIC_VECTOR(PROGRAM_COUNTER_BITS-1 downto 0);
begin

    pcu_o <= pcu;

    PROGRAM_COUNTER : entity work.mips_pcu
    port map(
        clk_i => clk_i,
        rst_i => rst_i,

        cs_i => cs_i,

        pcu_branch => branch,
        pcu_jump => jump,

        pcu_branch_addr => branch_addr,
        pcu_jump_addr => jump_addr,

        pcu_o => pcu
    );

    INSTRUCTION_MEMORY : entity work.mips_imem
    port map(
        clk_i => clk_i,
        rst_i => rst_i,

        cs_i => cs_i,

        prg_en => '0',

        programmer_mem_addr => (others => '0'),
        programmer_mem_data => (others => '0'),

        main_mem_addr => main_mem_addr,
        main_mem_data => main_mem_data,

        pcu_addr => pcu,
        pcu_data => instr_o
    );

end arch;