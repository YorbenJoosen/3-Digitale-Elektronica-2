library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package BresenhamPackage is
  -- definieer hier de functie AbsVal om de absolute waarde te
  -- berekenen van een integer
  function AbsVal(Value: integer)
  return integer;
end BresenhamPackage;

package body BresenhamPackage is

function AbsVal (Value: integer) return integer is
    variable Output: integer;
    begin
        if Value > 0 then
            Output := Value;
        else
            Output := Value * (-1);
        end if;
        return Output;
        end AbsVal;
                 
end BresenhamPackage;
