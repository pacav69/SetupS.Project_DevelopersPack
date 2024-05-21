@echo off

:Begin (requires: AutoIt3 plus SciTE)
set Reporting=/NoStatus
set AutoIt3Compiler="%ProgramFiles%\AutoIt3\SciTE\AutoIt3Wrapper\AutoIt3Wrapper.exe"
if exist "%ProgramFiles(x86)%\AutoIt3\SciTE\AutoIt3Wrapper\AutoIt3Wrapper.exe" set AutoIt3Compiler="%ProgramFiles(x86)%\AutoIt3\SciTE\AutoIt3Wrapper\AutoIt3Wrapper.exe"
if [%2]==[x86Only] Goto x86Only
if [%2]==[x64Only] Goto x64Only
Goto Dual

:Dual
echo Compiling dual-arch EXE's from %1.au3
Goto x86

:x86Only
echo Compiling (x86) EXE from %1.au3
Goto x86

:x64Only
echo Compiling (x64) EXE from %1.au3
Goto x64

:x86
copy "%1.au3" "%1_x86.au3" /y >nul:
fart -q -i %1_x86.au3 "#AutoIt3Wrapper_UseX64=y" "#AutoIt3Wrapper_UseX64=n" >nul:
fart -q -i %1_x86.au3 "%1_x64.exe" "%1.exe" >nul:
fart -q -i %1_x86.au3 ";#x86_only#" " " >nul:
%AutoIt3Compiler% /in "%1_x86.au3" %Reporting%
if exist "debug\%1_x86_obfuscated.au3" del /F /Q "debug\%1_x86_obfuscated.au3" >nul:
if exist "%1_x86.au3" del /F /Q "%1_x86.au3" >nul:
if [%2]==[x86Only] goto Cleanup

:x64
copy "%1.au3" "%1_x64.au3" /y >nul:
fart -q -i %1_x64.au3 "#AutoIt3Wrapper_UseX64=n" "#AutoIt3Wrapper_UseX64=y" >nul:
fart -q -i %1_x64.au3 ";#x64_only#" " " >nul:
fart -q -i %1_x64.au3 "%1.exe" "%1_x64.exe" >nul:
%AutoIt3Compiler% /in "%1_x64.au3" %Reporting%
if exist "debug\%1_x64_obfuscated.au3" del /F /Q "debug\%1_x64_obfuscated.au3" >nul:
if exist "%1_x64.au3" del /F /Q "%1_x64.au3" >nul:

:Cleanup
if exist "BackUp" rd /s /q "BackUp" >nul:
if exist "UDFs\BackUp" rd /s /q "UDFs\BackUp" >nul:
if exist "..\UDFs\BackUp" rd /s /q "..\UDFs\BackUp" >nul:

:Debug files
if not exist "*_obfuscated.au3" goto MoveEXE
if not exist "debug" md "debug" >nul:
copy "*_obfuscated.au3" "debug" /y >nul:
del /F /Q "*_obfuscated.au3" >nul:

:MoveEXE
if [%2]==[Move2Tools] goto Move2Tools
if [%2]==[Move2DualArchTools] goto Move2DualArchTools
if [%3]==[Move2Tools] goto Move2Tools
if [%3]==[Move2DualArchTools] goto Move2DualArchTools
goto Exit

:Move2Tools
if exist "%1.exe" copy "%1.exe" "Tools\%1.exe" /y >nul:
if exist "%1.exe" del /F /Q "%1.exe" >nul:
if exist "%1_x64.exe" copy "%1_x64.exe" "Tools\%1_x64.exe" /y >nul:
if exist "%1_x64.exe" del /F /Q "%1_x64.exe" >nul:
goto Exit

:Move2DualArchTools
if exist "%1.exe" copy "%1.exe" "Tools\_x86\%1.exe" /y >nul:
if exist "%1.exe" del /F /Q "%1.exe" >nul:
if exist "%1_x64.exe" copy "%1_x64.exe" "Tools\_x64\%1.exe" /y >nul:
if exist "%1_x64.exe" del /F /Q "%1_x64.exe" >nul:
goto Exit

:Exit