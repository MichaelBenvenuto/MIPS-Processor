library IEEE;
use IEEE.std_logic_1164.all;
use work.cpu_lib.all;

entity fetch is
    port(
        i_clk : in std_logic;
        i_rst : in std_logic;

        i_pc_next : in std_logic_vector(29 downto 0);
        i_pc_change : in std_logic;

        i_isp_write : in std_logic;
        i_isp_addr : in std_logic_vector(10 downto 0);
        i_isp_data : in std_logic_vector(31 downto 0);

        o_instr : out instruction_t;
        o_pcu : out std_logic_vector(31 downto 0)
    );
end fetch;

architecture arch of fetch is
    signal pcu : std_logic_vector(31 downto 0);
    signal instr : instruction_t;
begin

    o_pcu <= (others => '0') when i_pc_change = '1' else pcu;

    program_counter : entity work.prg_cntr
    port map(
        i_clk => i_clk,
        i_rst => i_rst,

        i_pc_next => i_pc_next,
        i_pc_change => i_pc_change,

        o_pcu => pcu
    );

    -- This is only temporary
    -- Need to implement a stream cache for instructions
    imemory : entity work.imemory
    port map(
        i_clk => i_clk,
        
        i_isp_wr => i_isp_write,
        i_isp_addr => i_isp_addr,
        i_isp_data => i_isp_data,

        i_oena => (not i_pc_change),

        -- For the harvard architecture prototype. Proper instruction memory would trigger a bus cycle
        i_addr => pcu(12 downto 2),
        o_instr => instr
    );

end arch;