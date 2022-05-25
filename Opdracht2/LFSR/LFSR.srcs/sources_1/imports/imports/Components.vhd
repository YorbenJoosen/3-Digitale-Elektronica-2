library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.LFSRPackage.all;

package Components is

  component LFSR
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
      LFSR      : out std_logic_vector(g_Size-1 downto 0));
  end component;

end Components;

