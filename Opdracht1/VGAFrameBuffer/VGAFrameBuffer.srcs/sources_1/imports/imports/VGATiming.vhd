library IEEE;
use IEEE.std_logic_1164.ALL;
use work.VGAPackage.all;

entity VGATiming is
  port ( PixelClk    : in std_logic;
         ResetN      : in std_logic; -- active low, synchronous
         HSync       : out std_logic;
         VSync       : out std_logic;
         VideoActive : out boolean;
         HCount      : out integer range 0 to c_HTotal-1;
         VCount      : out integer range 0 to c_VTotal-1
         );
end VGATiming;

architecture RTL of VGATiming is

signal HCounter: integer := 0;
signal VCounter: integer := 0;

begin

  -- assuming the following counting scheme (neg polarity):
  -- +     +------------------+     +...
  -- |     |                  |     |
  -- |     |                  |     |
  -- +-----+                  +-----+
  -- |                        |
  -- 0                      Total
  -- |<--->|<-->|<------>|<-->|<--->|...
  --  Sync   BP   Active   FP  Sync

HCount <= HCounter;
VCount <= VCounter;

pinstellen_scherm_teller: process(PixelClk)
begin
if rising_edge(PixelClk) then
    if ResetN = '1' then
        if HCounter = (c_Htotal - 1) then
            HCounter <= 0;
            if VCounter = (c_Vtotal - 1) then
                VCounter <= 0;
            else
                VCounter <= VCounter +1;
            end if;
        else 
            HCounter <= HCounter+1;
        end if;
    else
        HCounter <= 0;
        VCounter <= 0;
    end if; 
end if;
 
end process;

pdoorgeven_waarde: process(HCounter, VCounter)
begin
if VCounter >= (c_VRes + c_VFP) and VCounter < (c_VTotal - c_VBP) then -- Zien of we nog in het beeld zitten, zo niet dan geven we een puls om van rechtsonder naar linksboven te gaan
    VSync <= '0';
else
    VSync <= '1';
end if;
if HCounter >= (c_HRes + c_HFP) and HCounter < (c_HTotal - c_HBP) then -- Zien of we nog op de lijn zitten, zo niet dan geven we een puls om naar de volgende lijn te gaan
    HSync <= '0';
else -- Puls geven dat het naar de volgende lijn mag
    HSync <= '1';
end if;
if (HCounter < c_HRes and VCounter < c_VRes) then
    VideoActive <= TRUE ;
else
    VideoActive <= False;
end if;
end process;
end RTL;