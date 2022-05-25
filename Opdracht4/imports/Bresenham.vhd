library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.Components.all;
use work.BresenhamPackage.all;
use work.VGAPackage.all;

entity Bresenham is
 Port (Clk      : in std_logic;
       ResetN   : in std_logic;
       X0       : in unsigned(Log2Ceil(c_HRes)-1 downto 0);
       Y0       : in unsigned(Log2Ceil(c_VRes)-1 downto 0);
       X1       : in unsigned(Log2Ceil(c_HRes)-1 downto 0);
       Y1       : in unsigned(Log2Ceil(c_VRes)-1 downto 0);
       Start    : in std_logic;
       PlotX    : out unsigned(Log2Ceil(c_HRes)-1 downto 0);
       PlotY    : out unsigned(Log2Ceil(c_Vres)-1 downto 0);
       Plotting : out std_logic
 );
end Bresenham;

architecture RTL of Bresenham is

signal DifferenceX: unsigned(Log2Ceil(c_HRes)-1 downto 0);
signal DifferenceY: unsigned(Log2Ceil(c_Hres)-1 downto 0);

begin

pBresenham: process(X0, X1, Y0, Y1)
begin
DifferenceX <= X1 - X0;
DifferenceY <= Y1 - Y0;
end process;

end RTL;
