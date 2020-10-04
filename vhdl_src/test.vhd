library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test is
end test;

architecture arch of test is
    signal a,b : STD_LOGIC_VECTOR(31 downto 0);
    signal res : STD_LOGIC_VECTOR(63 downto 0);
begin
    res <= STD_LOGIC_VECTOR(unsigned(a)*unsigned(b));
end arch;