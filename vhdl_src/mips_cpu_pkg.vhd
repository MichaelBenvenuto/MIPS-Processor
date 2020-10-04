library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;

package MIPS_CPU_PKG is


    constant INSTRUCTION_MEMORY_SIZE : integer := 2048; -- Size in words (4 8bit bytes)

    -- DO NOT CHANGE ANYTHING BELOW!!!

    constant CONT_BRANCH    : integer := 0;
    constant CONT_JUMP      : integer := 1;
    constant CONT_MEMA      : integer := 2;
    constant CONT_MEMWR     : integer := 3;
    constant CONT_ALUSRC    : integer := 4;
    constant CONT_REGWR     : integer := 5;
    constant CONT_REGDST    : integer := 6;
    constant CONT_LINK      : integer := 7;
    constant CONT_JUMPREG   : integer := 8;

    subtype CONT_WORD is integer range 10 downto 0;

    subtype INSTR_OPCODE is integer range 31 downto 26;
    subtype INSTR_RS     is integer range 25 downto 21;
    subtype INSTR_RT     is integer range 20 downto 16;
    subtype INSTR_RD     is integer range 15 downto 11;
    subtype INSTR_SA     is integer range 10 downto 6;
    subtype INSTR_FUNC   is integer range 5 downto 0;
    subtype INSTR_IMM    is integer range 15 downto 0;
    subtype INSTR_TRGT   is integer range 25 downto 0;

    constant PROGRAM_COUNTER_BITS    : integer := integer(ceil(log2(real(INSTRUCTION_MEMORY_SIZE))));
    constant INSTRUCTION_MEMORY_BITS : integer := PROGRAM_COUNTER_BITS + 2;

    type pipeline_32 is array(integer range <>) of STD_LOGIC_VECTOR(31 downto 0);

end MIPS_CPU_PKG;