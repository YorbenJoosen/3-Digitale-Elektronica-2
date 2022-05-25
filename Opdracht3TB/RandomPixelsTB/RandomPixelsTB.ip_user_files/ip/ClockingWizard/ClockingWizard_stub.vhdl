-- Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2021.1 (win64) Build 3247384 Thu Jun 10 19:36:33 MDT 2021
-- Date        : Wed Sep 15 13:20:06 2021
-- Host        : LivingPC running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               D:/Workdir/Xilinx/3-BasisDigitaleElektronica2/IPGen/IPGen.runs/ClockingWizard_synth_1/ClockingWizard_stub.vhdl
-- Design      : ClockingWizard
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ClockingWizard is
  Port ( 
    PixelClk : out STD_LOGIC;
    Clk100MHz : out STD_LOGIC;
    locked : out STD_LOGIC;
    SysClk100MHz : in STD_LOGIC
  );

end ClockingWizard;

architecture stub of ClockingWizard is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "PixelClk,Clk100MHz,locked,SysClk100MHz";
begin
end;
