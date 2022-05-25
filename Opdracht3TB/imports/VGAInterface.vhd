library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;
use work.VGAPackage.all;
use work.Components.all;
use work.LFSRPackage.all;

entity VGAInterface is
  port ( Clk100MHz : in std_logic;
         ResetN    : in std_logic;
         HSync     : out std_logic;
         VSync     : out std_logic;
         Dips      : in  std_logic_vector(15 downto 0);
         Leds      : out std_logic_vector(15 downto 0);
         Red       : out std_logic_vector(3 downto 0);
         Green     : out std_logic_vector(3 downto 0);
         Blue      : out std_logic_vector(3 downto 0));
end VGAInterface;

architecture RTL of VGAInterface is

-- s ervoor om verwarring te voorkomen
signal s_PixelClk: std_logic;
signal s_locked: std_logic;
signal ClockingWizard100MHz: std_logic;
signal VideoActive: boolean;
signal Hcount: integer range 0 to c_HTotal-1 := 0;
signal Vcount: integer range 0 to c_VTotal-1:= 0;
signal s_clka : STD_LOGIC:= '0';
signal s_wea : STD_LOGIC_VECTOR(0 DOWNTO 0);
signal s_addra : STD_LOGIC_VECTOR(c_VidMemAddrWidth - 1 DOWNTO 0);
signal s_dina : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal s_douta : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal s_clkb : STD_LOGIC;
signal s_web : STD_LOGIC_VECTOR(0 DOWNTO 0):= "0"; -- Wordt niet gebruikt dus heeft een vaste waarde nodig
signal s_addrb : STD_LOGIC_VECTOR(c_VidMemAddrWidth - 1 DOWNTO 0);
signal s_dinb : STD_LOGIC_VECTOR(2 DOWNTO 0):= (others => '0'); -- Wordt niet gebruikt dus heeft een vaste waarde nodig
signal s_doutb : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal s_LFSR : std_logic_vector(18 downto 0);
signal s_ClrMem : std_logic:= '0'; -- Wordt niet gebruikt dus heeft een vaste waarde nodig
signal s_Enable : std_logic;
signal counter_klokdeler: integer:= 0;

begin

clockingwizard_invoegen : ClockingWizard
port map (
    PixelClk => s_PixelClk,
    Clk100MHz => ClockingWizard100MHz,              
    locked => s_locked,
    SysClk100MHz => Clk100MHz
);
 
VGATiming_invoegen : VGATiming
port map (
    PixelClk => s_PixelClk,
    ResetN => ResetN,
    HSync => HSync,
    VSync => VSync,
    VideoActive => VideoActive,
    HCount => HCount,
    VCount => Vcount 
);
 
VideoMemory_invoegen : VideoMemory
port map (
    clka => Clk100MHz,
    wea => s_wea,
    addra => s_addra,
    dina => s_dina,
    douta => s_douta,
    clkb => Clk100MHz,
    web => s_web,
    addrb => s_addrb,
    dinb => s_dinb,
    doutb => s_doutb
    );
    
WriteVideoMemory_invoegen : WriteVideoMemory
port map (
    Clk => Clk100MHz,
    ResetN => ResetN,
    X => unsigned(s_LFSR(18 downto 9)),
    Y => unsigned(s_LFSR(8 downto 0)),
    ClrMem => s_ClrMem,
    Addr => s_addra,
    WriteData => s_dina,
    ReadData => s_douta,
    WEn => s_wea(0)
);

LFSR_invoegen : LFSR
port map (
Clk => Clk100MHz,
ResetN => ResetN,
Enable => s_Enable,
LFSR => s_LFSR
);

pKlokDeler: process(Clk100MHz)
begin
if rising_edge(Clk100MHz) then
    if counter_klokdeler = 10000 then
        s_Enable <= '1'; -- Om de 10000 cycli laten we een LFSR waarde genereren
        counter_klokdeler <= 0;
    else
        s_Enable <= '0'; -- In de periodes ertussen laten we geen LFSR waarde genereren
        counter_klokdeler <= counter_klokdeler + 1;
    end if;
end if;
end process;

pClock : process(s_PixelClk)
begin
if rising_edge(s_PixelClk) then
    if VideoActive = TRUE then
            if to_integer(unsigned(s_addrb)) = (c_HRes * c_VRes - 1) or ResetN = '0' then
                s_addrb <= (others => '0');
            else
                s_addrb <= std_logic_vector(unsigned(s_addrb) + 1);
            end if;
            if s_doutb(2) = '1' then
                Red <= (others => '1');
            else
                Red <= (others => '0');
            end if;
            if s_doutb(1) = '1' then
                Green <= (others => '1');
            else
                Green <= (others => '0');
            end if;
            if s_doutb(0) = '1' then
                Blue <= (others => '1');
            else
                Blue <= (others => '0');
            end if;
    else
        Red <= (others => '0');
        Green <= (others => '0');
        Blue <= (others => '0');
    end if;
end if;
end process;

end RTL;
