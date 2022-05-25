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

type StateType is (Idle, KeuzefactorCalc, Plot);
signal State: StateType := Idle;
signal DifferenceX      : integer range c_Hres - 1 downto 0; -- Max X verschil = lengte van het scherm
signal DifferenceY      : integer range c_VRes - 1 downto 0; -- Max Y verschil = hoogte van het scherm
-- Bresenham gaat van linksboven naar rechtsonder
signal RichtingX        : integer range -1 to 1; -- 1 is naar rechts, -1 naar links
signal RichtingY        : integer range -1 to 1; -- 1 is naar boven, -1 naar beneden
signal Keuzefactor            : integer;
signal NextX            : integer range c_Hres downto 0; -- Maximum waarde X = lengte scherm
signal NextY            : integer range c_VRes downto 0; -- Maximum waarde Y = hoogte scherm
begin

pFSM: process(Clk, ResetN)
begin
if rising_edge(Clk) then
    if ResetN = '1' then --Actief lage reset
        case State is
            when Idle => -- When the FSM is idle we wait for a new start signal to start calculating a new line
                    if X1 > X0 then -- We kijken of we naar links of rechts gaan
                        RichtingX <= 1; -- Naar rechts dus 1
                    else
                        RichtingX <= -1; -- Naar links dus -1
                    end if;
                    if Y1 > Y0 then -- We kijken of we naar onder of boven gaan
                        RichtingY <= 1; -- Naar onder dus 1
                    else
                        RichtingY <= -1; -- Naar boven dus -1
                    end if;
                    -- Waardes doorgeven voor te plotten
                    NextX <= to_integer(X0);
                    NextY <= to_integer(Y0);
                    DifferenceX <= AbsVal(to_integer(X1) - to_integer(X0)); -- Absolute X verschil tussen de 2 punten
                    DifferenceY <= AbsVal(to_integer(Y1) - to_integer(Y0)); -- Absolute Y verschil tussen de 2 punten
                    State <= KeuzeFactorCalc; -- We gaan de Keuzefactor berekenen
            when KeuzeFactorCalc =>
                if Start ='1' then
                    if DifferenceY < DifferenceX then -- Rico < 1, X verandert sneller dan Y, dus hiermee moeten we rekening houden met de bresenham berekening
                        Keuzefactor <= 2*DifferenceY - DifferenceX;
                    else -- Rico > 1, Y verandert sneller dan X, dus hiermee moeten we rekening houden met de bresenham berekening
                        Keuzefactor <= 2*DifferenceX - DifferenceY;
                    end if;
                    Plotting <= '1';
                    State <= Plot; -- We gaan de punten plotten
                end if;
            when Plot =>
                PlotX <= to_unsigned(NextX, Log2Ceil(c_HRes)); -- X-waarde van het punt dat geplot wordt
                PlotY <= to_unsigned(NextY, Log2Ceil(c_VRes)); -- Y-waarde van het punt dat geplot wordt
                if NextX = to_integer(X1) and NextY = to_integer(Y1) then -- Als de eindpixel bereikt is stoppen we met plotten
                    Plotting <= '0'; -- Eindpunt is bereikt dus er moet niet meer geplot worden
                    State <= Idle; -- Eindpunt bereikt dus zetten we state als idle
                else
                    if DifferenceY < DifferenceX then -- Rico < 1
                        NextX <= NextX + RichtingX;
                        if Keuzefactor <= 0 then
                            Keuzefactor <= Keuzefactor + 2*DifferenceY;
                            NextY <= NextY;
                        elsif Keuzefactor > 0 then
                            Keuzefactor <= Keuzefactor + 2*DifferenceY - 2*DifferenceX;
                            NextY <= NextY + RichtingY;
                        else
                            Keuzefactor <= Keuzefactor;
                            NextY <= NextY;
                        end if;
                    elsif DifferenceY > DifferenceX then -- Rico > 1
                        NextY <= NextY + RichtingY;
                        if Keuzefactor < 0 then
                            Keuzefactor <= Keuzefactor + 2*DifferenceX;
                            NextX <= NextX;
                        else
                            Keuzefactor <= Keuzefactor + 2*DifferenceX - 2*DifferenceY;
                            NextX <= NextX + RichtingX;
                        end if;
                    else
                        if DifferenceX = 0 then -- Voor verticale lijnen
                            NextX <= NextX;
                            NextY <= NextY + RichtingY;
                        elsif DifferenceY = 0 then -- Voor horizontale lijnen
                            NextY <= NextY;
                            NextX <= NextX + RichtingX;
                        else -- Voor 45 graden lijnen (DifferenceX = DifferenceY)
                            NextX <= NextX + RichtingX;
                            NextY <= NextY + RichtingY;
                        end if;
                     end if;
                end if;
            when others => 
                State <= Idle;
                Plotting <= '0';
                PlotX <= (others => '0');
                PlotY <= (others => '0');
        end case;
    else
        Plotting <= '0';
        PlotX <= (others => '0');
        PlotY <= (others => '0');
        State <= Idle;
        NextX <= 0;
        NextY <= 0;
        Keuzefactor <= 0;
    end if;
end if;
end process;

end RTL;
