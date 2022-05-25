library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.LFSRPackage.all;
use work.Components.all;

use STD.textio.all;
use ieee.std_logic_textio.all;

entity TB_LFSR is
end TB_LFSR;

architecture Behavioral of TB_LFSR is

  -- select the correct version by (un)commenting:
  -- DON'T FORGET TO CHANGE THE TESTVECTOR ALSO IN the p_Main process
  -- taps [16, 15, 13, 4]
  --constant c_Size : integer := 16;
  --constant c_Taps : t_TapsArr := (15 => true, 13 => true, 4 => true, others => false);
  -- taps [19, 18, 17, 14]
  --constant c_Size : integer := 19;
  --constant c_Taps : t_TapsArr := (18 downto 17 => true, 14 => true, others => false);
  -- taps [7,6]
  constant c_Size : integer := 7;
  constant c_Taps : t_TapsArr := (6 => true, others => false);

  signal Clk      : std_logic := '0';
  signal ResetN   : std_logic := '0';
  signal LFSRReg  : std_logic_vector(c_Size-1 downto 0);

begin

  Clk    <= not Clk after 5 ns;          -- 100 MHz => 10 ns period
  ResetN <= '0', '1' after 30 ns;

  p_Main: process(Clk)
    -- DON'T FORGET TO SELECT THE CORRECT TESTVECTOR HERE
    file TestVector : text open read_mode is "LFSRVectorSize7.txt";
    --file TestVector : text open read_mode is "LFSRVectorSize19.txt";
    --file TestVector : text open read_mode is "LFSRVectorSize16.txt";
    variable Row    : line;
    variable Val    : std_logic_vector(c_Size-1 downto 0);
    -- These string variables are needed because the assert statement cannot
    -- "print" std_logic_vectors, so we convert them to strings first.
    variable LFSRString : string(c_Size downto 1);
    variable ValString : string(c_Size downto 1);
  begin
    if rising_edge(Clk) then
      if ResetN = '1' then
        if(not endfile(TestVector)) then
          readline(TestVector,Row);
          read(Row,Val);
          -- conversion to strings
          BuildLFSRString: for A in c_Size-1 downto 0 loop
            if LFSRReg(A) = '0' then
              LFSRString(A+1) := '0';
            else
              LFSRString(A+1) := '1';
            end if;
          end loop BuildLFSRString;
          BuildValString: for A in c_Size-1 downto 0 loop
            if Val(A) = '0' then
              ValString(A+1) := '0';
            else
              ValString(A+1) := '1';
            end if;
          end loop BuildValString;
          assert Val = LFSRReg report "Error: value " & LFSRString & " does not match expected value " & ValString severity warning;
        else
          assert false report "End of simulation. Not an error." severity failure;
        end if;
      end if;
    end if;
  end process p_Main;
  
  LFSR0: LFSR
    generic map (
      g_Size   => c_Size,
      g_Taps   => c_Taps
      )
    port map (
      Clk      => Clk,
      ResetN   => ResetN,
      LFSR     => LFSRReg
      );

end Behavioral;
