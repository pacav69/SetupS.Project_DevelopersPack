@echo off
@REM uploadlastos.cmd
@REM uploads files to vergitek.com site
@REM echo uploading files...
@REM ANSI ref https://ss64.com/nt/syntax-ansi.html
Set _bBlack=[40m
Set _fGreen=[32m
Set _fBGreen=[92m
Set _fRed=[31m
Set _fYellow=[33m
Set _bBlue=[44m
Set _RESET=[0m

set filesini1=filesvergitek

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
.\WinSCP\WinSCP.com  /log=".\WinSCP\winscp.log" /ini=nul /script=%filesini1%.ini

set WINSCP_RESULT=%ERRORLEVEL%
if %WINSCP_RESULT% equ 0 (
    echo.
Echo %_fYellow%%_bBlue%#######################################################%_fBGreen%%_bBlack%
echo ### Successfully moved old and uploaded files
Echo %_fYellow%%_bBlue%#######################################################%_fBGreen%%_bBlack%
  echo.
) else (
echo.
@REM black / red color 04
@REM color 04
Echo %_fRed%%_bBlack% #######################################################%_fBGreen%%_bBlack%
echo ### an Error occured
echo ### displaying %filesini1%.ini
echo %_fRed%%_bBlack%####################################################### %_fBGreen%%_bBlack%
  echo.
  @REM pause
@REM color 02
    type %filesini1%.ini
  goto Finish
)

@REM delete %filesini1%.ini file after sucessfull upload
echo Deleting %filesini1%.ini file
if exist "%filesini1%.ini" del /F /Q "%filesini1%.ini" >nul:

:Finish
exit /b %WINSCP_RESULT%