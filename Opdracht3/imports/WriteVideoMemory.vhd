library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.VGAPackage.all;
use work.LFSRPackage.all;
use work.Components.all;

entity WriteVideoMemory is
  Port (   Clk          : in std_logic;
           ResetN       : in std_logic;
           -- X and Y coordinate of the pixel to color
           X            : in unsigned (c_NumXBits-1 downto 0);
           Y            : in unsigned (c_NumYBits-1 downto 0);
           -- to clear the entire memory (for debug purposes)
           ClrMem       : in std_logic;
           -- Interface with the video memory
           Addr         : out std_logic_vector(c_VidMemAddrWidth - 1 downto 0);
           WriteData    : out std_logic_vector(2 downto 0);
           ReadData     : in std_logic_vector(2 downto 0);
           WEn          : out std_logic);
end WriteVideoMemory;

architecture RTL of WriteVideoMemory is
begin

pClock: process(Clk)
begin
if rising_edge(Clk) then
    if ResetN = '1' then -- Actief lage reset
        Addr <= std_logic_vector(to_unsigned((to_integer(Y)*c_Hres + to_integer(X)), 19));
        -- 19 geeft het max aantal bits weer
        -- We doen maal c_Hres, omdat bv de tweede rij in het begin 641 is en we doen Y maal 640=c_Hres + X=1 om 641 te krijgen, hetzelfde dan voor elke rij
        WEn <= '1'; -- WriteEnable is 1 dus er mag in het geheugen geschreven worden
        WriteData <= "100"; -- Dit bepaalt de kleur in RGB, in dit geval dus Addr
    else -- Reset wordt ingeduwd
        Addr <= (others => '0'); -- We zetten addres terug op 0 
        WEn <= '0'; -- Er mag niet geschreven worden terwijl de reset ingeduwd wordt 
        WriteData <= "000"; -- We moeten dit een waarde geven doordat het in de if gebruikt wordt
    end if;
end if;
end process;

end RTL;
