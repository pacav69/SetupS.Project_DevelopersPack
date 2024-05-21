@echo off
set sc=Source.Code
cd "%~dp0"
if exist "%sc%\originals\*.*" xcopy "%sc%\originals\*.*" "%sc%" /s/e/y >nul:
if exist "%sc%\originals" rd /s /q "%sc%\originals" >nul:
if exist "%sc%\*_x86.au3" del "%sc%\*_x86.au3" >nul:
if exist "%sc%\*_x64.au3" del "%sc%\*_x64.au3" >nul: