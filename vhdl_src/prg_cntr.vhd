library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity prg_cntr is
    port(
        -- Clock and reset
        i_clk : in std_logic;
        i_rst : in std_logic;

        -- Inputs from the instruction decode pipeline stage
        -- i_jump: used for unconditional jumping, result replaces the pcu value
        -- i_branch: used for conditional branches, result is added to pcu in addition to the increment
        -- i_j: control unit jump signal
        -- i_b: control unit branch signal
        i_jump : in std_logic_vector(25 downto 0);
        i_branch : in std_logic_vector(31 downto 0);
        i_j : in std_logic;
        i_b : in std_logic;

        -- Outputs from the program counter
        -- o_pcu: the current state of the program counter, used to fetch instruction from cache
        -- o_pcu: the next state of the program counter
        o_pcu : out std_logic_vector(31 downto 0)
    );
end prg_cntr;

architecture arch of prg_cntr is
    signal pcu : std_logic_vector(29 downto 0) := (others => '0');  -- Placeholder for the actual program counter
    signal pcu_n : std_logic_vector(29 downto 0);                   -- Placeholder for program counter increment
    signal pcu_x : std_logic_vector(29 downto 0);                   -- Placeholder for the next expected program counter

    signal jump_format : std_logic_vector(29 downto 0);     -- Placeholder for the jump address setup
    signal branch_format : std_logic_vector(29 downto 0);   -- Placeholder for the branch vector setup
begin

    pcu_n <= pcu + '1';

    -- Jump and branch calculations
    jump_format <= pcu(29 downto 26) & i_jump;
    branch_format <= pcu + i_branch(29 downto 0);

    --! Jumps and branches are expected to execute at the same time!!!

    -- Bypass the pc register if branching or jumping
    -- Appending zeroes here for easier simulation
    -- From the scope of the designer, this increments by 1, from the scope of the CPU, it increments by 4
    pcu_x <= jump_format when i_j = '1' else
             branch_format when i_b = '1' else pcu_n;

    o_pcu <= jump_format & "00" when i_j = '1' else
             branch_format & "00" when i_b = '1' else
             pcu & "00";

    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                pcu <= (others => '0');
            else
                pcu <= pcu_x;
            end if;
        end if;
    end process;
end arch;