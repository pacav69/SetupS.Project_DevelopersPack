@echo off

:getPath
if [%1]==[] goto setPath
set HelpPath=%1
set HelpFile=%2
goto Begin

:setPath
set HelpPath=Source.Code
set HelpFile=ssTek

:Begin
echo Uploading help file from "%HelpPath%" ...


set ssTekFTP=\\Vergitek\d\xampp\htdocs\sstek

@REM remove old help files

if exist "%ssTekFTP%\help" rd /s /q "%ssTekFTP%\help" >nul:

@REM put files

xcopy "%HelpPath%\files\*.*" "%ssTekFTP%\help\files\*.*" /s/e/y >nul:
copy "%HelpPath%\%HelpFile%.html" "%ssTekFTP%\help\%HelpFile%.html" /y >nul:
copy "%HelpPath%\favicon.ico" "%ssTekFTP%\help\favicon.ico" /y >nul:

:Exit
echo.