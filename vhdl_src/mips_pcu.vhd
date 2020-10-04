library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use WORK.MIPS_CPU_PKG.ALL;

entity mips_pcu is
    port(
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;
        cs_i : in STD_LOGIC;

        pcu_branch : in STD_LOGIC;
        pcu_jump   : in STD_LOGIC;

        pcu_branch_addr : in STD_LOGIC_VECTOR(PROGRAM_COUNTER_BITS-1 downto 0);
        pcu_jump_addr   : in STD_LOGIC_VECTOR(PROGRAM_COUNTER_BITS-1 downto 0);

        pcu_n : out STD_LOGIC_VECTOR(PROGRAM_COUNTER_BITS-1 downto 0); --The next iteration of the pcu (pcu_o + 1)
        pcu_o : out STD_LOGIC_VECTOR(PROGRAM_COUNTER_BITS-1 downto 0) --The current iteration of the pcu
    );
end mips_pcu;

architecture arch of mips_pcu is
    signal pcun : STD_LOGIC_VECTOR(PROGRAM_COUNTER_BITS-1 downto 0);
    signal pcu  : STD_LOGIC_VECTOR(PROGRAM_COUNTER_BITS-1 downto 0) := (others => '0');
begin
    pcun <= pcu + 1;
    pcu_o <= pcu_jump_addr         when pcu_jump = '1'   else 
             pcu + pcu_branch_addr when pcu_branch = '1' else pcu;
    pcu_n <= pcun;
    process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            pcu <= (others => '0');
        elsif rising_edge(clk_i) then
            if cs_i = '1' then
                if pcu_jump = '1' then
                    pcu <= pcu_branch_addr;
                elsif pcu_branch = '1' then
                    pcu <= pcu + pcu_branch_addr;
                else
                    pcu <= pcun;
                end if;
            end if;
        end if;
    end process;
end arch;
