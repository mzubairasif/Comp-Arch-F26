@echo off
set BIN=D:\Xilinx\Vivado\2020.1\bin
cd /d "%~dp0"
echo Compiling...
call "%BIN%\xvlog.bat" -nolog "..\lab-05.srcs\sources_1\new\fsm_counter.v" "..\lab-05.srcs\sim_1\new\fsm_counter_tb.v"
if errorlevel 1 goto error

echo Elaborating...
call "%BIN%\xelab.bat" -nolog -top fsm_counter_tb -snapshot fsm_counter_tb_snap -debug typical
if errorlevel 1 goto error

echo Simulating...
call "%BIN%\xsim.bat" -nolog fsm_counter_tb_snap -runall
goto end

:error
echo An error occurred during simulation!
exit /b 1

:end
echo Done!
