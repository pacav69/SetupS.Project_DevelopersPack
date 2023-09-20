@REM uploadlastos.cmd
@REM uploads files to lastos.org site
echo uploading files...
.\WinSCP\WinSCP.com  /log=".\WinSCP\winscp.log" /ini=nul /script=fileslastos.ini
