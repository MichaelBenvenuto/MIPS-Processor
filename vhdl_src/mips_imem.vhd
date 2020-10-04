library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use WORK.MIPS_CPU_PKG.ALL;
use STD.TEXTIO.ALL;

entity mips_imem is
    port(
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;

        cs_i  : in STD_LOGIC;

        prg_en : in STD_LOGIC;

        programmer_mem_addr : in STD_LOGIC_VECTOR(PROGRAM_COUNTER_BITS-1 downto 0);
        programmer_mem_data : in STD_LOGIC_VECTOR(31 downto 0);

        main_mem_addr : in STD_LOGIC_VECTOR(PROGRAM_COUNTER_BITS-1 downto 0);
        main_mem_data : out STD_LOGIC_VECTOR(31 downto 0);

        pcu_addr : in STD_LOGIC_VECTOR(PROGRAM_COUNTER_BITS-1 downto 0);
        pcu_data : out STD_LOGIC_VECTOR(31 downto 0)
    );
end mips_imem;

architecture arch of mips_imem is
    type IMEM_RAM is array(0 to INSTRUCTION_MEMORY_SIZE-1) of STD_LOGIC_VECTOR(31 downto 0);

    impure function init_ram_hex(dir : in string) return IMEM_RAM is
        file text_file : text open read_mode is dir;
        variable text_line : line;
        variable ram_content : IMEM_RAM;
    begin
        for i in IMEM_RAM'range loop
            readline(text_file, text_line);
            hread(text_line, ram_content(i));
        end loop;
        return ram_content;
    end function;

    signal memory : IMEM_RAM := init_ram_hex("test/test.txt");

begin

    process(clk_i, rst_i, cs_i)
    begin
        if rst_i = '1' then
            memory <= (others => x"00000000");
        elsif rising_edge(clk_i) and cs_i = '1' then
            if prg_en = '1' then
                memory(to_integer(unsigned(programmer_mem_addr))) <= programmer_mem_data;
            else
                main_mem_data <= memory(to_integer(unsigned(programmer_mem_addr)));
                pcu_data <= memory(to_integer(unsigned(pcu_addr)));
            end if;
        end if;
    end process;
end arch;