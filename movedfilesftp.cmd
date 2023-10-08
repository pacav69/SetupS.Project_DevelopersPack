@echo off
@REM movedfilesftp.cmd %1
@REM moves old files on lastos.org site
@REM echo moving files...
@REM ANSI ref https://ss64.com/nt/syntax-ansi.html
Set _bBlack=[40m
Set _fGreen=[32m
Set _fBGreen=[92m
Set _fRed=[31m
Set _fYellow=[33m
Set _bBlue=[44m
Set _RESET=[0m

@REM Echo %_fRed%%_bBlack% error
@REM Echo %_RESET%
@REM Echo %_fBGreen%%_bBlack%
@REM echo working
@REM Echo %_fYellow%%_bBlue%
@REM echo finished
@REM @REM Echo %_RESET%
@REM Echo %_fBGreen%%_bBlack%
@REM black / redgreen color 02
@REM color 02

Echo %_fBGreen%%_bBlack%
@REM %1 is the filename passed in from the call function of main file
@REM .\WinSCP\WinSCP.com  /log=".\WinSCP\winscp.log" /ini=nul /script=fileslastos.ini
.\WinSCP\WinSCP.com  /log=".\WinSCP\winscp.log" /ini=nul /script=%1
@REM %1

set WINSCP_RESULT=%ERRORLEVEL%
echo error code %WINSCP_RESULT%
if %WINSCP_RESULT% equ 0 (
    echo.
Echo %_fYellow%%_bBlue%#######################################################%_fBGreen%%_bBlack%
echo ### Successfully moved old files
Echo %_fYellow%%_bBlue%#######################################################%_fBGreen%%_bBlack%
  echo.
) else (
echo.
@REM black / red color 04
@REM color 04
Echo %_fRed%%_bBlack% #######################################################%_fBGreen%%_bBlack%
echo ### an Error occured
echo error code %WINSCP_RESULT%
echo ### displaying %1
echo %_fRed%%_bBlack%####################################################### %_fBGreen%%_bBlack%
  echo.
  @REM pause
@REM color 02
    type %1
  goto Finish
)

@REM @REM delete fileslastos.ini file after sucessfull upload
@REM echo Deleting fileslastos.ini file
if exist "%1" del /F /Q "%1" >nul:

:Finish
exit /b %WINSCP_RESULT%