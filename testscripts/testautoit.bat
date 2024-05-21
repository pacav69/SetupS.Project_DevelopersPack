@echo off
@REM https://ss64.com/nt/if.html

:SetAutoIt3 working variable
set AutoIt3="%ProgramFiles%\AutoIt3\AutoIt3.exe"
if exist "%ProgramFiles(x86)%\AutoIt3\AutoIt3.exe" set AutoIt3="%ProgramFiles(x86)%\AutoIt3\AutoIt3.exe"
FOR %%i IN (C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO IF EXIST "%%i:\ppApps\AutoIt3\AutoIt3.exe" (SET AutoIt3="%%i:\ppApps\AutoIt3\AutoIt3.exe"& goto abortautoit)
:abortautoit
echo AutoIt3= %AutoIt3%
@REM pause
@REM if autoit not found display error - file not found
 IF NOT EXIST %AutoIt3% (goto fail) ELSE (goto np)
:fail
echo Autoit not found
goto end 

:np
echo everything ok

:end
echo ended 
