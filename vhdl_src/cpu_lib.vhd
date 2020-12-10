library IEEE;
use IEEE.std_logic_1164.all;

package cpu_lib is
    type instruction_t is std_logic_vector(31 downto 0);

    type control_t is record

        opcode : std_logic_vector(5 downto 0);

        immediate : std_logic;
        alu_op : std_logic_vector(1 downto 0);
        mem_wr : std_logic;
        mem_rd : std_logic;
        branch : std_logic;
        jump : std_logic;
    end record control_t;

    constant control_zero : control_t := (
        immediate => '0',
        alu_op => "00",
        mem_wr => '0',
        mem_rd => '0',
        branch => '0',
        jump => '0'
    );
end cpu_lib;