library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.VGAPackage.all;
use work.LFSRPackage.all;

package Components is

  component VGAInterface is
    port ( Clk100MHz : in std_logic;
           ResetN    : in std_logic;
           HSync     : out std_logic;
           VSync     : out std_logic;
           Dips      : in  std_logic_vector(15 downto 0);
           Leds      : out std_logic_vector(15 downto 0);
           Red       : out std_logic_vector(3 downto 0);
           Green     : out std_logic_vector(3 downto 0);
           Blue      : out std_logic_vector(3 downto 0);
           TB_LFSR      : out std_logic_vector(18 downto 0);
           TB_Enable    : out std_logic 
           );
  end component;

  component ClockingWizard
    port
      ( SysClk100MHz    : in  std_logic;
        PixelClk        : out std_logic;
        locked          : out std_logic;
        Clk100Mhz       : out std_logic
        );
  end component;

  component VGATiming
    port ( PixelClk     : in std_logic;
           ResetN       : in std_logic;
           HSync        : out std_logic;
           VSync        : out std_logic;
           VideoActive  : out boolean;
           HCount       : out integer range 0 to c_HTotal-1;
           VCount       : out integer range 0 to c_VTotal-1);
  end component;

  component VideoMemory
    port (
      clka      : in std_logic;
      wea       : in std_logic_vector(0 downto 0);
      --addra     : in std_logic_vector(18 downto 0);
      addra     : in std_logic_vector(c_VidMemAddrWidth - 1 downto 0);
      dina      : in std_logic_vector(2 downto 0);
      douta     : out std_logic_vector(2 downto 0);
      clkb      : in std_logic;
      web       : in std_logic_vector(0 downto 0);
      --addrb     : in std_logic_vector(18 downto 0);
      addrb     : in std_logic_vector(c_VidMemAddrWidth - 1 downto 0);
      dinb      : in std_logic_vector(2 downto 0);
      doutb     : out std_logic_vector(2 downto 0)
      );
  end component;

  component LFSR
    generic (
      -- g_Size should match the size of the LFSR
      -- the bits in g_Taps that are true should correspond to active taps
      -- bit 0 of the array is not included, since it's always a tap
      -- the highest tap is never mentioned. f.i. taps [19,18,17,14]:
      g_Size : integer range 2 to c_MaxTaps := 19;
      g_Taps : t_TapsArr := (18 downto 17 => true, 14 => true, others => false));
    port (
      Clk       : in std_logic;
      ResetN    : in std_logic;
      Enable    : in std_logic;
      LFSR      : out std_logic_vector(g_Size-1 downto 0));
  end component;

  component WriteVideoMemory is
    port ( Clk          : in std_logic;
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
  end component;
end Components;

