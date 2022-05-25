library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.LFSRPackage.all;
use work.Components.all;

use STD.textio.all;
use ieee.std_logic_textio.all;

entity TB is
end TB;

architecture Behavioral of TB is

  -- taps [19, 18, 17, 14]
  constant c_Size : integer := 19;
  constant c_Taps : t_TapsArr := (18 downto 17 => true, 14 => true, others => false);
  constant Columns: integer := 2; --Aantal kolommen in TestVector.txt

  signal Clk      : std_logic := '0';
  signal s_ResetN   : std_logic := '0';
  signal LFSRReg  : std_logic_vector(c_Size-1 downto 0);
  signal s_Enable : std_logic;
  signal s_HSync  : std_logic;
  signal s_VSync  : std_logic;
  signal s_Red    : std_logic_vector(3 downto 0);
  signal s_Green  : std_logic_vector(3 downto 0);
  signal s_Blue   : std_logic_vector(3 downto 0);
  signal s_Dips   : std_logic_vector(15 downto 0);
  signal s_Leds   : std_logic_vector(15 downto 0);
  signal IngelezenX        : unsigned(9 downto 0);
  signal IngelezenY        : unsigned(8 downto 0);
  signal LFSRX             : unsigned(9 downto 0);
  signal LFSRY             : unsigned(8 downto 0);

begin

  Clk    <= not Clk after 5 ns;          -- 100 MHz => 10 ns period
  s_ResetN <= '0', '1' after 30 ns;

  TopLevel: VGAInterface
  port map (
    Clk100MHz => Clk,
    ResetN    => s_ResetN,
    HSync     => s_HSync,
    VSync     => s_VSync,
    Dips      => s_Dips,
    Leds      => s_Leds,
    Red       => s_Red,
    Green     => s_Green,
    Blue      => s_Blue,
    TB_LFSR      => LFSRReg, --TB ervoor gezet anders problemen met LFSR invoegen
    TB_Enable    => s_Enable 
    );

  p_Main: process(Clk)
    file TestVector : text open read_mode is "TestVector.txt";
    variable Row    : line;
    -- These string variables are needed because the assert statement cannot
    -- "print" std_logic_vectors, so we convert them to strings first.
    variable ValString : string(c_Size downto 1);
    variable IngelezenXString         : string(10 downto 1);
    variable IngelezenYString         : string(9 downto 1);
    variable LFSRXString              : string(10 downto 1);
    variable LFSRYString              : string(9 downto 1);
    type t_integer_array is array(integer range <> ) of integer;
    variable v_data_read        : t_integer_array(1 to Columns);
    
  begin
  if s_Enable = '1' then --Pas checken wanneer er effectief pixels gekleurd worden
    if rising_edge(Clk) then
      if s_ResetN = '1' then --Actief lage reset
        if(not endfile(TestVector)) then -- Zien of we op het einde van de file zitten
          readline(TestVector,Row); -- Lees een lijn
          for kk in 1 to Columns loop
            read(row, v_data_read(kk));
          end loop;
          LFSRX <= unsigned(LFSRReg(18 downto 9)); -- We lezen de X waarde in die de LFSR genereert 
          LFSRY <= unsigned(LFSRReg(8 downto 0)); -- We lezen de Y waarde in die de LFSR genereert 
          IngelezenX <= to_unsigned(v_data_read(1),10); -- We lezen de waarde van de X kolom in
          IngelezenY <= to_unsigned(v_data_read(2),9); -- We lezen de waarde van de Y kolom in 
          
          -- Conversion to strings
          BuildLFSRXString: for A in 9 downto 0 loop
            if LFSRX(A) = '0' then
              LFSRXString(A+1) := '0';
            else
              LFSRXString(A+1) := '1';
            end if;
          end loop BuildLFSRXString;
          
          BuildLFSRYString: for A in 8 downto 0 loop
            if LFSRY(A) = '0' then
              LFSRYString(A+1) := '0';
            else
              LFSRYString(A+1) := '1';
            end if;
          end loop BuildLFSRYString;
          
          BuildIngelezenXString: for A in 9 downto 0 loop
            if IngelezenX(A) = '0' then
                IngelezenXString(A+1) := '0';
            else
                IngelezenXString(A+1) := '1';
            end if;
            end loop BuildIngelezenXString;
          
          BuildIngelezenYString: for A in 8 downto 0 loop
            if IngelezenY(A) = '0' then
                IngelezenYString(A+1) := '0';
            else
                IngelezenYString(A+1) := '1';
            end if;
            end loop BuildIngelezenYString;
            
            -- Kijken of de x waarden gelijk zijn en desnoods een error geven
            assert IngelezenX = LFSRX report "Error: X_Value " & LFSRXString & " does not match expected value " & IngelezenXString severity warning;
            -- Kijken of de y waarden gelijk zijn en desnoods een error geven
            assert IngelezenY = LFSRY report "Error: Y_Value " & LFSRYString & " does not match expected value " & IngelezenYString severity warning;
        else
          -- Als alles klopt geven we een melding dat er geen error is gevonden
          assert false report "End of simulation. Not an error." severity failure;
        end if;
      end if;
    end if;
  end if;
  end process p_Main;
end Behavioral;
