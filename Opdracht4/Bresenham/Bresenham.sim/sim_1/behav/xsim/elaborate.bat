@echo off
REM ****************************************************************************
REM Vivado (TM) v2021.1.1 (64-bit)
REM
REM Filename    : elaborate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for elaborating the compiled design
REM
REM Generated by Vivado on Tue Dec 21 12:26:50 +0100 2021
REM SW Build 3286242 on Wed Jul 28 13:10:47 MDT 2021
REM
REM IP Build 3279568 on Wed Jul 28 16:48:48 MDT 2021
REM
REM usage: elaborate.bat
REM
REM ****************************************************************************
REM elaborate design
echo "xelab -wto eca2c867e5734e3ea1946c274f00b91a --incr --debug typical --rangecheck --relax --mt 2 -L xil_defaultlib -L secureip --snapshot TB_behav xil_defaultlib.TB -log elaborate.log"
call xelab  -wto eca2c867e5734e3ea1946c274f00b91a --incr --debug typical --rangecheck --relax --mt 2 -L xil_defaultlib -L secureip --snapshot TB_behav xil_defaultlib.TB -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
