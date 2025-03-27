--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC - Emerging technologies, Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     two_k_bram_imem - Behavioural
-- Project Name:    two_k_bram_imem
-- Description:     
--
-- Revision     Date       Author     Comments
-- v0.1         20250204   VlJo       Initial version
--
--------------------------------------------------------------------------------
library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    -- use IEEE.NUMERIC_STD.ALL;

Library UNISIM;
    use UNISIM.vcomponents.all;

entity two_k_bram_imem is
    port(
        clock : in STD_LOGIC;

        init_data_in : in STD_LOGIC_VECTOR(31 downto 0);
        init_write_enable : in STD_LOGIC;
        init_address : in STD_LOGIC_VECTOR(10 downto 0);

        data_in : in STD_LOGIC_VECTOR(31 downto 0);
        write_enable : in STD_LOGIC;
        address : in STD_LOGIC_VECTOR(10 downto 0);
        data_out : out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity two_k_bram_imem;

architecture Behavioural of two_k_bram_imem is

    -- (DE-)LOCALISING IN/OUTPUTS
    signal clock_i : STD_LOGIC;
    signal init_data_in_i : STD_LOGIC_VECTOR(31 downto 0);
    signal init_write_enable_i : STD_LOGIC;
    signal init_address_i : STD_LOGIC_VECTOR(10 downto 0);
    signal data_in_i : STD_LOGIC_VECTOR(31 downto 0);
    signal write_enable_i : STD_LOGIC;
    signal address_i : STD_LOGIC_VECTOR(10 downto 0);
    signal data_out_o : STD_LOGIC_VECTOR(31 downto 0);

    constant C_NULL : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
    constant C_ONES : STD_LOGIC_VECTOR(31 downto 0) := x"FFFFFFFF";

    signal init_address_00, init_address_01 : STD_LOGIC_VECTOR(15 downto 0);
    signal init_write_enable_00, init_write_enable_01 : STD_LOGIC;
    signal init_write_enable_00_vec, init_write_enable_01_vec : STD_LOGIC_VECTOR(3 downto 0);

    signal address_00, address_01 : STD_LOGIC_VECTOR(15 downto 0);
    signal write_enable_00, write_enable_01 : STD_LOGIC;
    signal write_enable_00_vec, write_enable_01_vec : STD_LOGIC_VECTOR(7 downto 0);
    signal data_out_00, data_out_01 : STD_LOGIC_VECTOR(31 downto 0);


begin

    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    clock_i <= clock;
    init_data_in_i <= init_data_in;
    init_write_enable_i <= init_write_enable;
    init_address_i <= init_address;

    data_in_i <= data_in;
    write_enable_i <= write_enable;
    address_i <= address;
    data_out <= data_out_o;


    init_address_00 <= "0" & init_address_i(9 downto 0) & "00000";
    init_address_01 <= "0" & init_address_i(9 downto 0) & "00000";
    init_write_enable_00 <= init_write_enable_i and not(init_address(10));
    init_write_enable_01 <= init_write_enable_i and init_address(10);    
    init_write_enable_00_vec <= (others => init_write_enable_00);
    init_write_enable_01_vec <= (others => init_write_enable_01);
    
    address_00 <= "0" & address_i(9 downto 0) & "00000";
    address_01 <= "0" & address_i(9 downto 0) & "00000";
    write_enable_00 <= write_enable_i and not(address_i(10));
    write_enable_01 <= write_enable_i and address_i(10);
    write_enable_00_vec <= (others => write_enable_00);
    write_enable_01_vec <= (others => write_enable_01);
    data_out_o <= data_out_00 when address_i(10) = '0' else data_out_01;
    

    -------------------------------------------------------------------------------
    -- BRAM PRIMITIVES
    -------------------------------------------------------------------------------
    RAMB36E1_inst00 : RAMB36E1
    generic map (
        RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
        SIM_COLLISION_CHECK => "ALL",
        DOA_REG => 0,
        DOB_REG => 0,
        EN_ECC_READ => FALSE,
        EN_ECC_WRITE => FALSE,
        -- INIT_00 to INIT_7F: Initial contents of the data memory array
        INIT_00 => X"004124230031222300112023340111730000001300000013000000131140006f",
        INIT_01 => X"02c1242302b1222302a1202300912e2300812c2300712a230061282300512623",
        INIT_02 => X"05412423053122230521202303112e2303012c2302f12a2302e1282302d12623",
        INIT_03 => X"07c1242307b1222307a1202305912e2305812c2305712a230561282305512623",
        INIT_04 => X"00812203004121830001208337c000ef3420357307f12a2307e1282307d12623",
        INIT_05 => X"02812603024125830201250301c1248301812403014123830101230300c12283",
        INIT_06 => X"04812a03044129830401290303c1288303812803034127830301270302c12683",
        INIT_07 => X"06812e0306412d8306012d0305c12c8305812c0305412b8305012b0304c12a83",
        INIT_08 => X"000001930000011300000093302000733401117307412f8307012f0306c12e83",
        INIT_09 => X"0000059300000513000004930000041300000393000003130000029300000213",
        INIT_0A => X"0000099300000913000008930000081300000793000007130000069300000613",
        INIT_0B => X"00000d9300000d1300000c9300000c1300000b9300000b1300000a9300000a13",
        INIT_0C => X"eef18193deadc1b7fe0101130000113700000f9300000f1300000e9300000e13",
        INIT_0D => X"3004507330511073e60101130000011734011073000101130000113700018213",
        INIT_0E => X"00112023ff4101130540006f3a8000ef001000733b0000ef30411073fff00113",
        INIT_0F => X"0005853300029663fff50293000583330280006f000514630061242300512223",
        INIT_10 => X"00812303004122830001208300030533fe029ce3fff2829300b303330140006f",
        INIT_11 => X"800007370000806700a7a023800007b70000006f0000006f0000806700c10113",
        INIT_12 => X"0025959304058263fedff06f00f7202300150513000080670007946300054783",
        INIT_13 => X"fc1ff06f02c50513000035370005d863800006b703070713ffc5859300003737",
        INIT_14 => X"00008067fd9ff06f00f6a023ffc585930007c78300f707b300f7f79300b557b3",
        INIT_15 => X"ff1ff06f00f70733001505130000806700e5d463000005130005071300050793",
        INIT_16 => X"8000033704460613000008130007069302878793000036370007079300002737",
        INIT_17 => X"0005c58300e605b300080e630007146302b55c6300088593000007130007a883",
        INIT_18 => X"02c5051300003537fcd796e3ffc787930010081302e594630000059300b32023",
        INIT_19 => X"fcdff06f41050533001585930007a803fc1ff06f011585b300170713f1dff06f",
        INIT_1A => X"ffc7f79300072783810007370000806700f720230037e7930007278381000737",
        INIT_1B => X"00c120830007278381000737fe5ff0ef00112623ff0101130000806700f72023",
        INIT_1C => X"81000737fbdff0ef00112623ff010113000080670101011300f720230017e793",
        INIT_1D => X"0007a703810007b7000080670101011300f720230027e79300c1208300072783",
        INIT_1E => X"0007a7030000806700e50c630020071300e508630010071300e7a023ff377713",
        INIT_1F => X"0007278381000737ff1ff06f008767130007a7030000806700e7a02300476713",
        INIT_20 => X"fff008130000071300812623ff010113000080670000806700f720230107e793",
        INIT_21 => X"0000079300d708b300c7033300b70e3300a70eb30200029300800f9300400f13",
        INIT_22 => X"0103802300f883b30003802300f303b30003802300fe03b30103802300fe83b3",
        INIT_23 => X"0003802300f303b30103802300fe03b30003802300fe83b3fde79ee300178793",
        INIT_24 => X"00400f93fff00813f8571ce300870713fdf79ee3001787930103802300f883b3",
        INIT_25 => X"0000079300e6833300e60e3300e58eb300e50f33040003930080029307f00893",
        INIT_26 => X"0104002300f304330104002300fe04330004002300fe84330004002300ff0433",
        INIT_27 => X"0114002300fe04330114002300fe84330114002300ff0433fdf79ee300178793",
        INIT_28 => X"0101011300c12403f8771ce300870713fc579ee3001787930104002300f30433",
        INIT_29 => X"001787930006478300b7802300f707b303f00693000647830005270300008067",
        INIT_2A => X"00810793fb01011302f6f06300f600230ff7f793001787930006478304f70023",
        INIT_2B => X"27412c23d70101130000806700008067050101130006002300e5202304f72223",
        INIT_2C => X"28912223288124232811262300810513048105930881061310810a130c810693",
        INIT_2D => X"27a120232791222327812423277126232761282327512a2327312e2329212023",
        INIT_2E => X"250107130007a02315010793e41ff0ef000101a3014122231401262325b12e23",
        INIT_2F => X"06f0059300310613f31ff0ef004105130710059300310613fef71ae300478793",
        INIT_30 => X"0660059300310613f11ff0ef004105130690059300310613f21ff0ef00410513",
        INIT_31 => X"0000059300310613ef1ff0ef004105130000059300310613f01ff0ef00410513",
        INIT_32 => X"0080059300310613ed1ff0ef004105130000059300310613ee1ff0ef00410513",
        INIT_33 => X"0000059300310613eb1ff0ef004105130000059300310613ec1ff0ef00410513",
        INIT_34 => X"0080059300310613e91ff0ef004105130000059300310613ea1ff0ef00410513",
        INIT_35 => X"0031061300000593e71ff0ef004105130030059300310613e81ff0ef00410513",
        INIT_36 => X"00000c1300000c9300000d130ff00b13fff0059300800a93e61ff0ef00410513",
        INIT_37 => X"009786330481079311841a63000644030097863300810793ff8a849300300b93",
        INIT_38 => X"009786330c8107930fa61a630006460300978633088107931196126300064603",
        INIT_39 => X"0031061300c59c6303f006134185d59301859593001585930f66126300064603",
        INIT_3A => X"04800613008a8a93f89a9ae300148493fff00593dddff0ef004105130ff00593",
        INIT_3B => X"da9ff0ef004105130ff5f59300310613fc05859300f58c63fff00793f8ca92e3",
        INIT_3C => X"d89ff0ef004105130000059300310613d99ff0ef004105130000059300310613",
        INIT_3D => X"d69ff0ef004105130000059300310613d79ff0ef004105130000059300310613",
        INIT_3E => X"d49ff0ef004105130000059300310613d59ff0ef004105130000059300310613",
        INIT_3F => X"d29ff0ef004105130010059300310613d39ff0ef004105130000059300310613",
        INIT_40 => X"004105130ff5f59300310613fc05859300f58c63fff007930000006f220a1a63",
        INIT_41 => X"000649830c8107930097863308810793000649030097863304810793d05ff0ef",
        INIT_42 => X"0039961300c585b3008585b301260633002916130014159300064d8300978633",
        INIT_43 => X"0109151300c585b341b606330026161301b60633001d961300c585b341360633",
        INIT_44 => X"00278533250507930025951300a606330089951303f5f59300a6063301841613",
        INIT_45 => X"0bc0006f000d8b13c71ff0ef004105130031061300c89c6301b60633f0052883",
        INIT_46 => X"0ff777130ff7f7934199073300f407b3418787b300200793116d9063f0c52023",
        INIT_47 => X"0ff5f593002685930ff6f69341a986b306cbe6630ff676130027061306fbec63",
        INIT_48 => X"00410513003106130ff77593fa0707130ff7fc130087079302b5766300300513",
        INIT_49 => X"0026161300d585b304268693004795930180006f00ec05b3004c1713c05ff0ef",
        INIT_4A => X"0ff7f793020707930240006fbd5ff0ef004105130ff5f5930031061300c585b3",
        INIT_4B => X"00090c9300098d13f987fee300f007930ff7fc130087079302f6e26303f00693",
        INIT_4C => X"0004059300310613b91ff0ef004105130fe0059300310613dc9ff06f00040c13",
        INIT_4D => X"0009859300310613b71ff0ef004105130009059300310613b81ff0ef00410513",
        INIT_4E => X"004105130004059300310613b55ff0ef004105130ff0059300310613f8dff06f",
        INIT_4F => X"004105130009859300310613b35ff0ef004105130009059300310613b45ff0ef",
        INIT_50 => X"0ff47413001404130007c503008a07b3ea5ff06f000d859300310613b25ff0ef",
        INIT_51 => X"00000000fedff06f00000413dd1ff06f044a2a03fef464e3040a4783811ff0ef",
        INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_A => X"000000000",
        INIT_B => X"000000000",
        INIT_FILE => "NONE",
        RAM_MODE => "TDP", -- RAM Mode: "SDP" or "TDP" 
        RAM_EXTENSION_A => "NONE", -- RAM_EXTENSION_A, RAM_EXTENSION_B: Selects cascade mode ("UPPER", "LOWER", or "NONE")
        RAM_EXTENSION_B => "NONE",
        READ_WIDTH_A => 36, -- 0-72
        READ_WIDTH_B => 36, -- 0-36
        WRITE_WIDTH_A => 36, -- 0-36
        WRITE_WIDTH_B => 36, -- 0-72
        RSTREG_PRIORITY_A => "RSTREG", ---- RSTREG_PRIORITY_A, RSTREG_PRIORITY_B: Reset or enable priority ("RSTREG" or "REGCE")
        RSTREG_PRIORITY_B => "RSTREG",
        SRVAL_A => X"000000000", -- SRVAL_A, SRVAL_B: Set/reset value for output
        SRVAL_B => X"000000000",
        SIM_DEVICE => "7SERIES",
        WRITE_MODE_A => "WRITE_FIRST",  -- WriteMode: Value on output upon a write ("WRITE_FIRST", "READ_FIRST", or "NO_CHANGE")
        WRITE_MODE_B => "WRITE_FIRST" 
    )
   port map (
        CASCADEOUTA => open,
        CASCADEOUTB => open,
        DBITERR => open,
        ECCPARITY => open,
        RDADDRECC => open,
        SBITERR => open,
        DOADO => open,
        DOPADOP => open,
        DOBDO => data_out_00,
        DOPBDOP => open,
        CASCADEINA => C_NULL(0),
        CASCADEINB => C_NULL(0),
        INJECTDBITERR => C_NULL(0),
        INJECTSBITERR => C_NULL(0),
        ADDRARDADDR => init_address_00,
        CLKARDCLK => clock_i,
        ENARDEN => C_NULL(0),
        REGCEAREGCE => C_NULL(0),
        RSTRAMARSTRAM => C_NULL(0),
        RSTREGARSTREG => C_NULL(0),
        WEA => init_write_enable_00_vec,
        DIADI => init_data_in_i,
        DIPADIP => C_NULL(3 downto 0),
        ADDRBWRADDR => address_00,
        CLKBWRCLK => clock_i,
        ENBWREN => C_ONES(0),
        REGCEB => C_NULL(0),
        RSTRAMB => C_NULL(0),
        RSTREGB => C_NULL(0),
        WEBWE => write_enable_00_vec,
        DIBDI => data_in_i,
        DIPBDIP => C_NULL(3 downto 0)
    );

    RAMB36E1_inst01 : RAMB36E1
    generic map (
        RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
        SIM_COLLISION_CHECK => "ALL",
        DOA_REG => 0,
        DOB_REG => 0,
        EN_ECC_READ => FALSE,
        EN_ECC_WRITE => FALSE,
        -- INIT_00 to INIT_7F: Initial contents of the data memory array
        INIT_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_10 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_11 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_12 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_13 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_14 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_15 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_16 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_17 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_18 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_19 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_1A => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_1B => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_1C => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_40 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_41 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_42 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_A => X"000000000",
        INIT_B => X"000000000",
        INIT_FILE => "NONE",
        RAM_MODE => "TDP", -- RAM Mode: "SDP" or "TDP" 
        RAM_EXTENSION_A => "NONE", -- RAM_EXTENSION_A, RAM_EXTENSION_B: Selects cascade mode ("UPPER", "LOWER", or "NONE")
        RAM_EXTENSION_B => "NONE",
        READ_WIDTH_A => 36, -- 0-72
        READ_WIDTH_B => 36, -- 0-36
        WRITE_WIDTH_A => 36, -- 0-36
        WRITE_WIDTH_B => 36, -- 0-72
        RSTREG_PRIORITY_A => "RSTREG", ---- RSTREG_PRIORITY_A, RSTREG_PRIORITY_B: Reset or enable priority ("RSTREG" or "REGCE")
        RSTREG_PRIORITY_B => "RSTREG",
        SRVAL_A => X"000000000", -- SRVAL_A, SRVAL_B: Set/reset value for output
        SRVAL_B => X"000000000",
        SIM_DEVICE => "7SERIES",
        WRITE_MODE_A => "WRITE_FIRST",  -- WriteMode: Value on output upon a write ("WRITE_FIRST", "READ_FIRST", or "NO_CHANGE")
        WRITE_MODE_B => "WRITE_FIRST" 
    )
   port map (
        CASCADEOUTA => open,
        CASCADEOUTB => open,
        DBITERR => open,
        ECCPARITY => open,
        RDADDRECC => open,
        SBITERR => open,
        DOADO => open,
        DOPADOP => open,
        DOBDO => data_out_01,
        DOPBDOP => open,
        CASCADEINA => C_NULL(0),
        CASCADEINB => C_NULL(0),
        INJECTDBITERR => C_NULL(0),
        INJECTSBITERR => C_NULL(0),
        ADDRARDADDR => init_address_01,
        CLKARDCLK => clock_i,
        ENARDEN => C_NULL(0),
        REGCEAREGCE => C_NULL(0),
        RSTRAMARSTRAM => C_NULL(0),
        RSTREGARSTREG => C_NULL(0),
        WEA => init_write_enable_01_vec,
        DIADI => init_data_in_i,
        DIPADIP => C_NULL(3 downto 0),
        ADDRBWRADDR => address_01,
        CLKBWRCLK => clock_i,
        ENBWREN => C_ONES(0),
        REGCEB => C_NULL(0),
        RSTRAMB => C_NULL(0),
        RSTREGB => C_NULL(0),
        WEBWE => write_enable_01_vec,
        DIBDI => data_in_i,
        DIPBDIP => C_NULL(3 downto 0)
    );

end Behavioural;
