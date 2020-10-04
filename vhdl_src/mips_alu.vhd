library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.MIPS_CPU_PKG.ALL;

entity mips_alu is
    port(
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;

        alu_opcode : in STD_LOGIC_VECTOR(5 downto 0);
        alu_funct  : in STD_LOGIC_VECTOR(5 downto 0);
        alu_sa     : in STD_LOGIC_VECTOR(4 downto 0);

        opd_a : in STD_LOGIC_VECTOR(31 downto 0);
        opd_b : in STD_LOGIC_VECTOR(31 downto 0);

        alu_busy : out STD_LOGIC;
        alu_trap : out STD_LOGIC;

        alu_res : out STD_LOGIC_VECTOR(31 downto 0)
    );
end mips_alu;

architecture arch of mips_alu is
    signal hilo_register    : STD_LOGIC_VECTOR(63 downto 0);

    signal div_m_register   : STD_LOGIC_VECTOR(31 downto 0);
    signal div_aq_register  : STD_LOGIC_VECTOR(63 downto 0);
    signal div_counter      : STD_LOGIC_VECTOR(5 downto 0);

    signal opd_a_pipe       : pipeline_32(0 to 1);
    signal opd_b_pipe       : pipeline_32(0 to 1);
    signal pipe_timer       : STD_LOGIC;

    signal multdiv_usign    : STD_LOGIC;
    signal cs_multdiv       : STD_LOGIC := '0';
    signal divide           : STD_LOGIC;
    signal div_fsign        : STD_LOGIC;

    signal div_a_abs        : STD_LOGIC_VECTOR(31 downto 0);
    signal div_b_abs        : STD_LOGIC_VECTOR(31 downto 0);

    signal alu_op           : STD_LOGIC_VECTOR(3 downto 0);

    signal alu_sub          : STD_LOGIC_VECTOR(32 downto 0);
    signal alu_add          : STD_LOGIC_VECTOR(32 downto 0);
begin

    div_a_abs <= ((opd_a(31) and not multdiv_usign) xor opd_a) + opd_a(31);
    div_b_abs <= ((opd_b(31) and not multdiv_usign) xor opd_b) + opd_b(31);

    alu_op <= alu_funct(3 downto 0) when alu_opcode = "000000" else alu_opcode(3 downto 0);

    alu_sub <= ('0' & opd_a) - ('0' & opd_b);
    alu_add <= ('0' & opd_a) + ('0' & opd_b);

    -- Process: General ALU Functions
    process(alu_opcode, alu_funct, alu_op, opd_a, opd_b, alu_sub, alu_add, hilo_register, cs_multdiv)
    begin
        alu_res <= (others => '0');
        alu_trap <= '0';
        alu_busy <= '0';
        if std_match(alu_opcode, "001---") or (std_match(alu_funct, "10----") and alu_opcode = "000000") then
            case alu_op is
                when "0000"|"1000" =>
                    alu_res <= alu_add(31 downto 0);
                    alu_trap <= alu_add(32);
                when "0001"|"1001" =>
                    alu_res <= alu_add(31 downto 0);
                when "0100"|"1100" =>
                    alu_res <= opd_a and opd_b;
                when "1111" =>
                    alu_res <= opd_b(15 downto 0) & (0 to 15 => '0');
                when "0111" =>
                    alu_res <= opd_a nor opd_b;
                when "0101"|"1101" =>
                    alu_res <= opd_a or opd_b;
                when "1010" =>
                    alu_res <= (0 to 30 => '0') & alu_sub(31);
                when "1011" =>
                    alu_res <= (0 to 30 => '0') & alu_sub(32);
                when "0010" =>
                    alu_res <= alu_sub(31 downto 0);
                    alu_trap <= alu_sub(32);
                when "0011" =>
                    alu_res <= alu_sub(31 downto 0);
                when "0110"|"1110" =>
                    alu_res <= opd_a xor opd_b;
                when others =>
                    alu_res <= (others => '0');
            end case;
        elsif alu_opcode = "00000" and std_match(alu_funct, "00----") then
            case alu_op is
                when "0000" =>
                    alu_res <= std_logic_vector(shift_left(unsigned(opd_a), to_integer(unsigned(alu_sa))));
                when "0100" =>
                    alu_res <= std_logic_vector(shift_left(unsigned(opd_a), to_integer(unsigned(opd_b))));
                when "0011" =>
                    alu_res <= std_logic_vector(shift_right(signed(opd_a), to_integer(unsigned(alu_sa))));
                when "0111" =>
                    alu_res <= std_logic_vector(shift_right(signed(opd_a), to_integer(unsigned(opd_b))));
                when "0010" =>
                    alu_res <= std_logic_vector(shift_right(unsigned(opd_a), to_integer(unsigned(alu_sa))));
                when "0110" =>
                    alu_res <= std_logic_vector(shift_right(unsigned(opd_a), to_integer(unsigned(opd_b))));
                when "1001"|"1000" =>
                    alu_res <= alu_add(31 downto 0);
                when others =>
                    alu_res <= (others => '0');
            end case;
        elsif alu_opcode = "000000" and std_match(alu_funct, "01----") then
            case alu_op is
                when "0000" =>
                    alu_busy <= cs_multdiv;
                    alu_res <= hilo_register(63 downto 32);
                when "0010" =>
                    alu_busy <= cs_multdiv;
                    alu_res <= hilo_register(31 downto 0);
                when others =>
                    alu_res <= (others => '0');
            end case;
        elsif std_match(alu_opcode, "00001-") or std_match(alu_opcode, "10----") then
            alu_res <= alu_add(31 downto 0);
        end if;

    end process;

    -- Process: Advanced ALU Functions
    process(clk_i, rst_i)
        variable aq : STD_LOGIC_VECTOR(63 downto 0);
    begin
        if rst_i = '1' then
            hilo_register <= (others => '0');
            div_aq_register <= (others => '0');
            div_m_register <= (others => '0');
            cs_multdiv <= '0';
        elsif rising_edge(clk_i) then
            opd_a_pipe <= x"00000000" & opd_a_pipe(0);
            opd_b_pipe <= x"00000000" & opd_b_pipe(0);
            pipe_timer <= '0';
            if cs_multdiv = '1' then
                if divide = '1' then
                    if div_counter /= "000000" then
                        div_counter <= div_counter - 1;
                        aq := div_aq_register(62 downto 0) & '0';
                        if div_aq_register(63) = '1' then
                            aq(63 downto 32) := (aq(63 downto 32) + div_m_register);
                        else
                            aq(63 downto 32) := (aq(63 downto 32) - div_m_register);
                        end if;
                        aq(0) := not aq(63);
                        div_aq_register <= aq;
                    else
                        hilo_register(63 downto 32) <= (div_fsign xor div_aq_register(63 downto 32)) + div_fsign;
                        hilo_register(31 downto 0)  <= (div_fsign xor div_aq_register(31 downto 0))  + div_fsign;
                        cs_multdiv <= '0';
                    end if;
                else
                    if pipe_timer = '0' then
                        if multdiv_usign = '1' then
                            hilo_register <= std_logic_vector(unsigned(opd_a_pipe(1)) * unsigned(opd_b_pipe(1)));
                        else
                            hilo_register <= std_logic_vector(signed(opd_a_pipe(1)) * signed(opd_b_pipe(1)));
                        end if;
                        cs_multdiv <= '0';
                    end if;
                end if;
            end if;

            if alu_opcode = "000000" then
                if std_match(alu_funct, "0110--") then
                    if cs_multdiv = '0' then
                        cs_multdiv <= '1';
                        divide <= alu_funct(1);
                        if alu_funct(1) = '1' then
                            div_counter <= "100000";
                            div_aq_register <= (0 to 31 => '0') & div_a_abs;
                            div_m_register <= div_b_abs;
                            div_fsign <= (opd_a(31) xor opd_b(31)) and not alu_funct(0);
                        else
                            opd_a_pipe(0) <= opd_a;
                            opd_b_pipe(0) <= opd_b;
                            pipe_timer <= '1';
                        end if;
                        multdiv_usign <= alu_funct(0);
                    end if;
                end if;
            end if;
        end if;
    end process;
end arch;