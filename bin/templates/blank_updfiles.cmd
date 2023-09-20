@echo off
color 02
@REM updfiles.cmd
@REM this file has been added to .gitignore to prevent upload to github
@REM of sensitive data
@REM this script changes the password in fileslastos.ini to the correct one
@REM change mypass to correct password
set pw=mypass
@REM this will replace the txt label of #password# to pw
echo.
echo updating fileslastos.ini
echo.
fart -q -i -r ".\fileslastos.ini" "#password#" "%pw%" >nul:
