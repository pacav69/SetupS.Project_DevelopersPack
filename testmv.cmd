
@REM #######################################################
@REM ###  WebLink2=www.lastos.org
@REM #######################################################
set WebSite2=LastOS Forum
set WebLink2=www.lastos.org
set domain2=setups@lastos.org
set ftp2=ftp.lastos.org
set Webfolder2=
@REM set filesini2=fileslastos.ini

set path=%path%;%~dp0bin;%~dp0%sc%\Tools;%~dp0%sc%\Tools\_x86
cd "%~dp0"

set mvfilesini2=mvfiles.ini

@REM #######################################################
@REM ### LastOS ftp move list
@REM #######################################################
@REM refer to set filesini2
:LastOSftp
@REM set oldfies = SetupSoldfies
echo creating %mvfilesini2% for upload...
cd "%~dp0"
@REM create files to upload script for winscp useage
@REM ref: https://winscp.net/eng/docs/commandline
@REM https://winscp.net/eng/docs/scripting
@REM To insert comments into the script file, start the line with # (hash):
if exist "%mvfilesini2%" del /F /Q "%mvfilesini2%" >nul:
echo ; connect to ftp server  >>%mvfilesini2%
echo open ftp://%domain2%:#Password#@%ftp2%/%Webfolder2%>>%mvfilesini2%
echo # files to move >>%mvfilesini2%
@REM if file does not exist then mv will fail terminating session
@REM it can be achieved by using ,net assembly refer to ref
@REM ref: https://winscp.net/eng/docs/library_session_fileexists
@REM add list of files to move to oldfies/
@REM echo echo moving files on ftp server
@REM if remote directory does not exist then session will fail and terminate
set oldfies = SetupSoldfies\
@REM echo mkdir %oldfies%/>>%filesini2%
echo mv checksums_*.md5 oldfies/>>%mvfilesini2%
echo mv update.ini  oldfies/>>%mvfilesini2%
echo mv SetupS*.*  oldfies/>>%mvfilesini2%
echo mv ChangeLog.txt  oldfies/>>%mvfilesini2%
echo mv Install.SetupS*.*  oldfies/>>%mvfilesini2%
echo exit >>%mvfilesini2%
@REM call  updfiles.cmd with  %mvfilesini2%
call updfiles.cmd %mvfilesini2%

call movedfilesftp.cmd %mvfilesini2%



@REM add files for upload
@REM echo echo uploading files
@REM echo ; files to upload >>%filesini2%
@REM echo put .\files\update.ini>>%filesini2%
@REM echo put .\files\%ssApp%.exe>>%filesini2%
@REM echo put .\files\%ssApp%.apz>>%filesini2%
@REM echo put .\files\%ppApp%.7z>>%filesini2%
@REM echo put .\files\%ssUI%.exe>>%filesini2%
@REM echo put .\files\%scp%.7z>>%filesini2%
@REM echo put .\files\%devpack%.7z>>%filesini2%
@REM echo put .\files\%ssII%.exe>>%filesini2%
@REM echo put .\files\checksums_v%ProjectVersion%.md5>>%filesini2%
@REM echo put .\files\ChangeLog.txt>>%filesini2%
@REM echo put .\files\SetupS-files.htm>>%filesini2%
@REM echo put .\files\SetupS-title.png>>%filesini2%
@REM echo exit >>%mvfilesini2%

@REM call  updfiles.cmd with  %mvfilesini2%
@REM call updfiles.cmd %mvfilesini2%

@REM call movedfilesftp.cmd %mvfilesini2%