library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.cpu_lib.all;

entity control is
    port(
        i_clk : in std_logic;
        i_rst : in std_logic;

        i_ex_branch : in std_logic;

        i_instr : in instruction_t;
        o_ctrl : out std_logic
    );
end control;

architecture arch of control is
    
begin
    process(i_clk, i_rst, i_ex_branch) 
        variable ctrl : control_t;

        variable opcode_row : std_logic_vector(2 downto 0);
        variable opcode_col : std_logic_vector(2 downto 0);
    begin
        ctrl := control_zero;
        if (i_rst or i_ex_branch) = '1' then
            o_ctrl <= ctrl;
        elsif rising_edge(i_clk) then
            ctrl.opcode := i_instr(31 downto 26);
            opcode_row := i_instr(31 downto 29);
            opcode_col := i_instr(28 downto 26);

            if opcode_row = "000" then
                if opcode_col = "000" then
                    ctrl.alu_op := "11";
                end if;
            elsif opcode_row = "001" then
                
            end if;
        end if;
    end process;
end arch;