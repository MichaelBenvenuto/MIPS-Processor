library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mips_regfile is
    port(
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;

        regw : in STD_LOGIC;

        reg1 : in STD_LOGIC_VECTOR(4 downto 0);
        reg2 : in STD_LOGIC_VECTOR(4 downto 0);
        regwb : in STD_LOGIC_VECTOR(4 downto 0);

        data1 : out STD_LOGIC_VECTOR(31 downto 0);
        data2 : out STD_LOGIC_VECTOR(31 downto 0);

        data_wb : in STD_LOGIC_VECTOR(31 downto 0)
    );
end mips_regfile;

architecture arch of mips_regfile is
    type REGFILE is array(0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal registers : REGFILE := (others => x"00000000");
begin
    process(clk_i, rst_i, reg1, reg2)
    begin
        data1 <= registers(to_integer(unsigned(reg1)));
        data2 <= registers(to_integer(unsigned(reg2)));
        if rst_i = '1' then
            registers <= (others => x"00000000");
        elsif rising_edge(clk_i) then
            if regwb /= "00000" and regw = '1' then
                registers(to_integer(unsigned(regwb))) <= data_wb;
            end if;
        end if;
    end process;
end arch;