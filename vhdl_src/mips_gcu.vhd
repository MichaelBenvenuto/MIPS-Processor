library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.MIPS_CPU_PKG.ALL;

entity mips_gcu is
    port(
        instr : in STD_LOGIC_VECTOR(31 downto 0);

        cw_o : out STD_LOGIC_VECTOR(CONT_WORD)
    );
end mips_gcu;

architecture arch of mips_gcu is
begin
    process(instr)
    begin
        cw_o <= (others => '0');
        if instr(INSTR_OPCODE) = "000000" then
            if std_match(instr(INSTR_FUNC), "00100-") then
                cw_o(CONT_BRANCH) <= '1';
                cw_o(CONT_JUMP) <= '1';
                cw_o(CONT_JUMPREG) <= '1';
                cw_o(CONT_LINK) <= instr(0);
                cw_o(CONT_REGWR) <= instr(0);
            elsif std_match(instr(INSTR_FUNC), "10----") then
                cw_o(CONT_REGWR) <= '1';
            elsif std_match(instr(INSTR_FUNC), "0100-0") then
                cw_o(CONT_REGWR) <= '1';
            end if;
        elsif std_match(instr(INSTR_OPCODE), "001---") then
            cw_o(CONT_ALUSRC) <= '1';
            cw_o(CONT_REGDST) <= '1';
            cw_o(CONT_REGWR) <= '1';
        elsif std_match(instr(INSTR_OPCODE), "10----") then
            cw_o(CONT_MEMA) <= '1';
            cw_o(CONT_MEMWR) <= instr(29);
            cw_o(CONT_ALUSRC) <= '1';
        elsif instr(INSTR_OPCODE) = "000001" or std_match(instr(INSTR_OPCODE), "0001--") then
            cw_o(CONT_BRANCH) <= '1';
        elsif std_match(instr(INSTR_OPCODE), "00001-") then
            cw_o(CONT_BRANCH) <= '1';
            cw_o(CONT_JUMP) <= '1';
            cw_o(CONT_LINK) <= instr(26);
            cw_o(CONT_REGWR) <= instr(26);
        end if;
    end process;
end arch;