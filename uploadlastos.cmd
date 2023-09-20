@REM uploadlastos.cmd
@REM uploads files to lastos.org site
@REM cd "%~dp0\winscp"
echo uploading files
@REM WinSCP.exe /script=lastosup.ini
.\WinSCP\WinSCP.com  /log=".\WinSCP\winscp.log" /ini=nul /script=fileslastos.ini
@REM cd "%~dp0"