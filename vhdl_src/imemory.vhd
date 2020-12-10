library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity imemory is
    generic(
        WORD_SIZE : integer := 2048
    );
    port(
        i_clk : in std_logic;

        i_isp_wr : in std_logic;
        i_isp_addr : in std_logic_vector(integer(ceil(log2(real(WORD_SIZE)))) - 1 downto 0);
        i_isp_data : in std_logic_vector(31 downto 0);

        i_oena : in std_logic;

        i_addr : in std_logic_vector(integer(ceil(log2(real(WORD_SIZE)))) - 1 downto 0);
        o_instr : out std_logic_vector(31 downto 0)
    );
end imemory;

architecture arch of imemory is
    type memory_t is array(WORD_SIZE - 1 downto 0) of std_logic_vector(31 downto 0);
    signal memory : memory_t;

    signal instr : std_logic_vector(31 downto 0);
begin

    o_instr <= instr when i_oena = '1' else (others => '0');

    process(i_clk) 
        variable instr_addr : integer := 0;
        variable isp_addr : integer := 0;
    begin
        if rising_edge(i_clk) then
            isp_addr := to_integer(unsigned(i_isp_addr));
            instr_addr := to_integer(unsigned(i_addr));
            
            if i_isp_wr = '1' then
                memory(isp_addr) <= i_isp_data;
            end if;

            instr <= memory(instr_addr);
        end if;
    end process;
end arch;