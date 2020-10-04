library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mips_bcon is
    port(
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;

        opd_a : in STD_LOGIC_VECTOR(31 downto 0);
        opd_b : in STD_LOGIC_VECTOR(31 downto 0);

        branch_opcode : in STD_LOGIC_VECTOR(5 downto 0);
        branch_opextd : in STD_LOGIC_VECTOR(4 downto 0);

        branch : out STD_LOGIC
    );
end mips_bcon;

architecture arch of mips_bcon is
    signal eq : STD_LOGIC;
    signal lte : STD_LOGIC;
    signal lt : STD_LOGIC;
    signal gte : STD_LOGIC;
    signal gt : STD_LOGIC;
    signal neg_a : STD_LOGIC_VECTOR(31 downto 0);
    signal branch_ext : STD_LOGIC;
begin
    neg_a <= (not opd_a) + 1;
    eq <= '1' when (opd_a = opd_b) else '0';
    lte <= opd_a(31);
    gte <= neg_a(31);
    gt <= not lte;
    lt <= not gte;

    branch_ext <= gte xnor branch_opextd(0) when (branch_opextd(3 downto 1) = "000") else '0';
    branch <= branch_ext when (branch_opcode = "000001") else
              eq xor branch_opcode(0) when (branch_opcode(5 downto 1) = "00010") else
              gt xnor branch_opcode(0) when (branch_opcode(5 downto 1) = "00011") else '0';
end arch;
