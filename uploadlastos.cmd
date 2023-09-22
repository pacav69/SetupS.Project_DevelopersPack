@echo off
@REM uploadlastos.cmd
@REM uploads files to lastos.org site
@REM echo uploading files...
@REM black / redgreen color 02
color 02
.\WinSCP\WinSCP.com  /log=".\WinSCP\winscp.log" /ini=nul /script=fileslastos.ini

set WINSCP_RESULT=%ERRORLEVEL%
if %WINSCP_RESULT% equ 0 (
    echo.
    echo #######################################################
echo ### Successfully moved old and uploaded files
echo #######################################################
  echo.
) else (
echo.
@REM black / red color 04
color 04
echo #######################################################
echo ### an Error occured
echo ### displaying fileslastos.ini
echo #######################################################
  echo.
  pause
color 02
    type fileslastos.ini
  goto Finish
)

@REM delete fileslastos.ini file after sucessfull upload
echo Deleting fileslastos.ini file
if exist "fileslastos.ini" del /F /Q "fileslastos.ini" >nul:

:Finish
exit /b %WINSCP_RESULT%