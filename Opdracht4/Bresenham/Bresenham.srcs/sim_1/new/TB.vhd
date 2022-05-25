library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use work.Components.all;
use work.VGAPackage.all;
use STD.textio.all;

entity TB is
end TB;

architecture Behavioral of TB is

constant Columns: integer := 2; -- Aantal kolommen in TestBresenham.txt

signal s_Clk              : std_logic := '0';
signal s_ResetN         : std_logic := '0';
signal s_X0             : unsigned(Log2Ceil(c_HRes) - 1 downto 0):= to_unsigned(300,Log2Ceil(c_HRes));
signal s_Y0             : unsigned(Log2Ceil(c_VRes) - 1 downto 0):= to_unsigned(200,Log2Ceil(c_VRes));
signal s_X1             : unsigned(Log2Ceil(c_HRes) - 1 downto 0):= to_unsigned(200,Log2Ceil(c_HRes));
signal s_Y1             : unsigned(Log2Ceil(c_VRes) - 1 downto 0):= to_unsigned(150,Log2Ceil(c_VRes));
signal s_Start          : std_logic := '0';
signal s_PlotX          : unsigned(Log2Ceil(c_HRes) - 1 downto 0):= (others => '0');
signal s_PlotY          : unsigned(Log2Ceil(c_VRes) - 1 downto 0):= (others => '0');
signal s_Plotting       : std_logic;
signal s_IngelezenPlotX : unsigned(Log2Ceil(c_HRes) - 1 downto 0):= (others => '0');
signal s_IngelezenPlotY : unsigned(Log2Ceil(c_VRes) - 1 downto 0):= (others => '0');
signal StartBoolean     : boolean := false;

begin

s_Clk <= not s_Clk after 5ns; -- 100MHz => 10ns period
s_ResetN <= '0', '1' after 30ns;

p_Timeout: process
--zorgen dat elke variabele een waarde heeft gekregen
begin
    wait for 40 ms;
    assert false report "AUTOCHECK: niet oké" severity failure;
end process p_Timeout;
  
pStart: process(s_Clk)
begin
if rising_edge(s_Clk) then
    if s_ResetN = '1' then
        if StartBoolean = false then
            s_Start <= '1';
            StartBoolean <= true;
        else
            s_Start <= '0';
            StartBoolean <= true;
        end if;
    end if;
end if;
end process;

TopLevel: Bresenham
port map (Clk      => s_Clk,
          ResetN   => s_ResetN,
          X0       => s_X0,
          Y0       => s_Y0,
          X1       => s_X1,
          Y1       => s_Y1,
          Start    => s_Start,
          PlotX    => s_PlotX,
          PlotY    => s_PlotY,
          Plotting => s_Plotting
          );
          
pMain: process(s_Clk)

file TestLijn             : text open read_mode is "TestBresenham8.txt";
variable Row              : line;
-- These string variables are needed because the assert statement cannot
-- "print" std_logic_vectors, so we convert them to strings first.
variable IngelezenXString : string(Log2Ceil(c_HRes) downto 1);
variable IngelezenYString : string(Log2Ceil(c_VRes) downto 1);
variable BresenhamXString : string(Log2Ceil(c_HRes) downto 1);
variable BresenhamYString : string(Log2Ceil(c_VRes) downto 1);
type t_integer_array is array(integer range <> ) of integer;
variable v_data_read      : t_integer_array(1 to Columns);

begin
if rising_edge(s_Clk) then
    if s_ResetN = '1' and s_Plotting = '1' then -- Actief lage reset en we wachten tot er effectief waardes geplot worden
        if(not endfile(TestLijn)) then -- Zien of we op het einde van de file zitten
            readline(TestLijn, Row); -- Lees een lijn
            for kk in 1 to Columns loop
                read(row, v_data_read(kk)); -- We lezen de waardes uit het tekstbestand en plaatsen deze in de array
            end loop;
            s_IngelezenPlotX <= to_unsigned(v_data_read(1), Log2Ceil(c_HRes)); -- We halen de waarde van de X kolom uit de array
            s_IngelezenPlotY <= to_unsigned(v_data_read(2), Log2Ceil(c_VRes)); -- We halen de waarde van de Y kolom uit de array
            
            -- Conversion to strings
            BuildBresenhamXString: for A in (Log2Ceil(c_HRes) - 1) downto 0 loop
                if s_PlotX(A) = '0' then
                    BresenhamXString(A+1) := '0';
                else
                    BresenhamXString(A+1) := '1';
                end if;
            end loop;
            
            BuildBresenhamYString: for A in (Log2Ceil(c_VRes) - 1) downto 0 loop
                if s_PlotY(A) = '0' then
                    BresenhamYString(A+1) := '0';
                else
                    BresenhamYString(A+1) := '1';
                end if;
            end loop;
            
            BuildIngelezenXString: for A in (Log2Ceil(c_HRes) - 1) downto 0 loop
                if s_IngelezenPlotX(A) = '0' then
                    IngelezenXString(A+1) := '0';
                else
                    IngelezenXString(A+1) := '1';
                end if;
                end loop;
            
            BuildIngelezenYString: for A in (Log2Ceil(c_VRes) - 1) downto 0 loop
                if s_IngelezenPlotY(A) = '0' then
                    IngelezenYString(A+1) := '0';
                else
                    IngelezenYString(A+1) := '1';
                end if;
                end loop;
                
            assert s_IngelezenPlotX = s_PlotX report "Error: X_Value " & BresenhamXString & " does not match expected value " & IngelezenXString severity warning;
            assert s_IngelezenPlotY = s_PlotY report "Error: Y_Value " & BresenhamYString & " does not match expected value " & IngelezenYString severity warning;
        else
            assert false report "End of simulation. Not an error." severity failure;
        end if;
    end if;
end if;
end process;
end Behavioral;
