library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.MIPS_CPU_PKG.ALL;

entity mips_pipeline_im is
    port(
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;

        ctrl : in STD_LOGIC_VECTOR(CONT_WORD);
        ctrl_o : out STD_LOGIC_VECTOR(CONT_WORD);

        instr : in STD_LOGIC_VECTOR(31 downto 0);

        mem_wdata : in STD_LOGIC_VECTOR(31 downto 0);
        mem_addr  : in STD_LOGIC_VECTOR(31 downto 0);
        mem_rdata : out STD_LOGIC_VECTOR(31 downto 0);

        imem_addr : out STD_LOGIC_VECTOR(PROGRAM_COUNTER_BITS - 1 downto 0);
        imem_data : in STD_LOGIC_VECTOR(31 downto 0);

        forward_data : in STD_LOGIC;
        forward_data_data : in STD_LOGIC_VECTOR(31 downto 0);

        im_data_to_forward : out STD_LOGIC_VECTOR(31 downto 0);

        exception : out STD_LOGIC;
        interrupt : out STD_LOGIC;

        im_wr_reg : in STD_LOGIC_VECTOR(4 downto 0);

        wb_exe_data : out STD_LOGIC_VECTOR(31 downto 0);
        wb_wr_reg   : out STD_LOGIC_VECTOR(4 downto 0);

        ext_mem_intr_i : in  STD_LOGIC;
        ext_mem_ackn_o : out STD_LOGIC;
        ext_mem_addr_o : out STD_LOGIC_VECTOR(31 downto 0);
        ext_mem_data_i : in  STD_LOGIC_VECTOR(31 downto 0);
        ext_mem_data_o : out STD_LOGIC_VECTOR(31 downto 0)
    );
end mips_pipeline_im;

architecture arch of mips_pipeline_im is
    signal imem_except : STD_LOGIC := '0';

    signal memory_data : STD_LOGIC_VECTOR(31 downto 0);
    signal formatted_memory : STD_LOGIC_VECTOR(31 downto 0);
    signal byte : STD_LOGIC_VECTOR(7 downto 0);
    signal half : STD_LOGIC_VECTOR(15 downto 0);
begin

    byte <= memory_data(7 downto 0) when mem_addr(1 downto 0) = "00" else
            memory_data(15 downto 8) when mem_addr(1 downto 0) = "01" else
            memory_data(23 downto 16) when mem_addr(1 downto 0) = "10" else
            memory_data(31 downto 24);

    half <= memory_data(15 downto 0) when mem_addr(1) = '0' else
            memory_data(31 downto 16);

    exception <= ctrl(CONT_MEMA) when ((instr(27 downto 26) and mem_addr(1 downto 0)) /= "00") or imem_except = '1' else '0';

    im_data_to_forward <= mem_addr when ctrl(CONT_MEMA) = '0' else formatted_memory;

    process(clk_i, rst_i, ext_mem_intr_i)
        variable opcode : STD_LOGIC_VECTOR(5 downto 0);
    begin
        if rst_i = '1' then
            mem_rdata <= (others => '0');
            wb_exe_data <= (others => '0');
            ctrl_o <= (others => '0');
            wb_wr_reg <= (others => '0');
        elsif rising_edge(clk_i) and ext_mem_intr_i = '0' then
            opcode := instr(INSTR_OPCODE);
            wb_wr_reg <= im_wr_reg;
            ctrl_o <= ctrl;
            mem_rdata <= formatted_memory;
            wb_exe_data <= mem_addr;
        end if;
    end process;

    process(mem_wdata, mem_addr, imem_data, forward_data, forward_data_data, ext_mem_data_i, ctrl, instr, ext_mem_intr_i)
        variable opcode : STD_LOGIC_VECTOR(5 downto 0);
    begin
        opcode := instr(INSTR_OPCODE);
        ext_mem_addr_o <= (others => '0');
        ext_mem_data_o <= (others => '0');
        ext_mem_ackn_o <= '0';
        interrupt <= '0';
        if ctrl(CONT_MEMA) = '1' then
            if mem_addr(31 downto INSTRUCTION_MEMORY_BITS) = (31 downto INSTRUCTION_MEMORY_BITS => '0') then
                imem_addr <= mem_addr(INSTRUCTION_MEMORY_BITS - 1 downto 2);
                memory_data <= imem_data;
                imem_except <= ctrl(CONT_MEMWR);
            else
                ext_mem_addr_o <= mem_addr;
                memory_data <= ext_mem_data_i;
                ext_mem_ackn_o <= '1';
                if forward_data = '1' then
                    ext_mem_data_o <= forward_data_data;
                else
                    ext_mem_data_o <= mem_wdata;
                end if;

                interrupt <= ext_mem_intr_i;

                if std_match(opcode, "10---00") then
                    formatted_memory <= (0 to 23 => (not opcode(2) and byte(7))) & byte;
                elsif std_match(opcode, "10---01") then
                    formatted_memory <= (0 to 15 => (not opcode(2) and half(15))) & half;
                else
                    formatted_memory <= memory_data;
                end if;

                memory_data <= ext_mem_data_i;
            end if;
        end if;
    end process;
end arch;