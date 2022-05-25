library IEEE;
use IEEE.std_logic_1164.all;

package LFSRPackage is
  -- Because of a bug in Vivado, the following will not work, because it gives problems when overwriting the size of the generic array
  --type t_TapsArr is array (natural range <>) of boolean;
  -- instead this workaround is used:
  constant c_MaxTaps : integer := 19;
  type t_TapsArr is array (c_MaxTaps-1 downto 1) of boolean;
end LFSRPackage;
