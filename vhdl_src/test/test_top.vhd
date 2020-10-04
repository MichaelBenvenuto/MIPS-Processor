library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_top is
    port(
        clk_i : in STD_LOGIC;

        leds : out STD_LOGIC_VECTOR(3 downto 0)
    );
end test_top;

architecture arch of test_top is
    signal data : STD_LOGIC_VECTOR(31 downto 0);
    signal addr : STD_LOGIC_VECTOR(31 downto 0);
    signal ackn : STD_LOGIC;
begin

    MIPS_CPU_CORE : entity work.mips_cpu
    port map(
        clk_i => clk_i,
        rst_i => '0',

        ext_ackn => ackn,
        ext_intr => '0',
        ext_addr => addr,
        ext_read => (others => '0'),
        ext_data => data
    );

    process(clk_i, ackn)
    begin
        if rising_edge(clk_i) and ackn = '1' then
            if addr = x"00002000" then
                leds <= data(3 downto 0);
            end if;
        end if;
    end process;

end arch;