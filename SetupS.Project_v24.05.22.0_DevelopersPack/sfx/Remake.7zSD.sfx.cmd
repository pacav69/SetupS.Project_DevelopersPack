@echo off
copy "7zsd_All.sfx" "7zSD.sfx" /y >nul: 
Resourcer -op:upd -src:"7zSD.sfx" -type:icon -name:101 -file:"..\Source.Code\ssApp.ico" 
upx --ultra-brute "7zSD.sfx" 
rem copy "7zSD.sfx" "..\bin\7zSD.sfx" /y >nul:
rem if exist "7zSD.sfx" del /F /Q "7zSD.sfx" >nul: