library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mips_forward is
    port(
        id_rs : in STD_LOGIC_VECTOR(4 downto 0);
        id_rt : in STD_LOGIC_VECTOR(4 downto 0);

        id_forward1         : out STD_LOGIC;
        id_forward1_data    : out STD_LOGIC_VECTOR(31 downto 0);
        id_forward2         : out STD_LOGIC;
        id_forward2_data    : out STD_LOGIC_VECTOR(31 downto 0);

        ie_rs : in STD_LOGIC_VECTOR(4 downto 0);
        ie_rt : in STD_LOGIC_VECTOR(4 downto 0);
        ie_wb : in STD_LOGIC_VECTOR(4 downto 0);

        ie_forward1         : out STD_LOGIC;
        ie_forward1_data    : out STD_LOGIC_VECTOR(31 downto 0);
        ie_forward2         : out STD_LOGIC;
        ie_forward2_data    : out STD_LOGIC_VECTOR(31 downto 0);

        ie_data_to_forward : in STD_LOGIC_VECTOR(31 downto 0);

        im_wb    : in STD_LOGIC_VECTOR(4 downto 0);

        im_rt : in STD_LOGIC_VECTOR(4 downto 0);

        im_forward         : out STD_LOGIC;
        im_forward_data    : out STD_LOGIC_VECTOR(31 downto 0);

        im_data_to_forward : in STD_LOGIC_VECTOR(31 downto 0);

        wb_reg : in STD_LOGIC_VECTOR(4 downto 0);

        wb_data_to_forward : in STD_LOGIC_VECTOR(31 downto 0)
    );
end mips_forward;

architecture arch of mips_forward is
begin

    id_forward1 <= '1' when (id_rs = ie_wb) or (id_rs = im_wb) or (id_rs = wb_reg) else '0';

    id_forward1_data <= ie_data_to_forward when id_rs = ie_wb else
                        im_data_to_forward when id_rs = im_wb else wb_data_to_forward;

    id_forward2 <= '1' when id_rt = ie_wb or id_rt = im_wb or id_rt = wb_reg else '0';

    id_forward2_data <= ie_data_to_forward when id_rt = ie_wb else
                        im_data_to_forward when id_rt = im_wb else wb_data_to_forward;

    ie_forward1 <= '1' when ie_rs = im_wb or ie_rs = wb_reg else '0';

    ie_forward1_data <= im_data_to_forward when ie_rs = im_wb else wb_data_to_forward;

    ie_forward2 <= '1' when ie_rt = im_wb or ie_rt = wb_reg else '0';

    ie_forward2_data <= im_data_to_forward when ie_rt = im_wb else wb_data_to_forward;

    im_forward <= '1' when im_rt = wb_reg else '0';

    -- This is kinda pointless, but its for my own sanity
    im_forward_data <= wb_data_to_forward;
    
end arch;