library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.LFSRPackage.all;

entity LFSR is
    generic (
      -- g_Size should match the size of the LFSR
      -- the bits in g_Taps that are true should correspond to active taps
      -- bit 0 of the array is not included, since it's always a tap
      -- the highest tap is never mentioned. f.i. taps [7,6]:
      g_Size : integer range 2 to c_MaxTaps := 7;
      g_Taps : t_TapsArr := (6 => true, others => false));
    port (
      Clk       : in std_logic;
      ResetN    : in std_logic;
      LFSR      : out std_logic_vector(g_Size - 1 downto 0)
      );
end LFSR;

architecture RTL of LFSR is
-- Downto is van de MSB naar de LSB, dus van links naar rechts
signal XorSum: std_logic_vector(g_Size - 1 downto 0):= (0 => '1', others => '0'); -- Seed instellen met als LSB 1 en de rest 0
signal CurrentState : std_logic_vector(g_Size - 1 downto 0):= (0 => '1', others => '0'); -- Seed instellen met als LSB 1 en de rest 0

begin

GenFeedback: for I in (g_Size - 1) downto 1 generate -- We gaan van MSB naar LSB, dus van links naar rechts
    XorSum(0) <= CurrentState(0);
    GenXOR: if g_taps(I) = TRUE generate -- Kijken of de tap true is
        XorSum(I) <= CurrentState(I) xor XorSum(I - 1); -- Nieuwe XorSum bepalen met de CurrentState en de vorige XorSum
    end generate GenXOR;
    GenNoXOR: if g_Taps(I) = FALSE generate
        XorSum(I) <= XorSum(I - 1); -- XorSum opschuiven naar links om de volgende XorSum te kunnen berekenen
    end generate GenNoXOR;
end generate GenFeedback;

pClock: process(Clk)
begin
if rising_edge(Clk) then
    if ResetN = '0' then -- Actief lage reset
        CurrentState <= (0 => '1', others => '0'); -- Bij een reset wordt de CurrentState terug naar zijn beginwaarde aka de seed gezet
    else
        CurrentState <= XorSum(g_Size - 1) & CurrentState(g_Size - 1 downto 1); -- MSB van XorSum links invoegen en de rest van de bits opschuiven naar rechts via CurrentState
    end if;
end if;
LFSR <= CurrentState; -- Currentstate doorgeven aan LFSR
end process;

end RTL;