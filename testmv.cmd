
@REM #######################################################
@REM ###  WebLink2=www.lastos.org
@REM #######################################################
set WebSite2=LastOS Forum
set WebLink2=www.lastos.org
set domain2=setups@lastos.org
set ftp2=ftp.lastos.org
set Webfolder2=
@REM set filesini2=fileslastos.ini
@REM #######################################################
@REM ###  WebLink1=sstek.vergitek.com
@REM #######################################################

set WebSite1=ssTek Forum
set WebLink1=sstek.vergitek.com
set domain1=setups@lastos.org
set ftp1=ftp.vergitek.com
set Webfolder1=
set filesini1=filesvergitek.ini


set path=%path%;%~dp0bin;%~dp0%sc%\Tools;%~dp0%sc%\Tools\_x86
cd "%~dp0"

set mvfilesini1=mvfiles1.ini

@REM #######################################################
@REM ###  ftp move list
@REM #######################################################
@REM refer to set filesini2
:LastOSftp
@REM set oldfies = SetupSoldfies
echo creating %mvfilesini1% for upload...
cd "%~dp0"
@REM create files to upload script for winscp useage
@REM ref: https://winscp.net/eng/docs/commandline
@REM https://winscp.net/eng/docs/scripting
@REM To insert comments into the script file, start the line with # (hash):
if exist "%mvfilesini1%" del /F /Q "%mvfilesini1%" >nul:
echo ; connect to ftp server  >>%mvfilesini1%
echo open ftp://%domain1%:#Password#@%ftp1%/%Webfolder1%>>%mvfilesini1%
echo # files to move >>%mvfilesini1%
echo option confirm on >>%mvfilesini1%
@REM option batch	off|on|abort|continue
echo option batch continue >>%mvfilesini1%


@REM if file does not exist then mv will fail terminating session
@REM it can be achieved by using .net assembly refer to ref
@REM ref: https://winscp.net/eng/docs/library_session_fileexists

@REM add list of files to move to oldfies/
@REM echo echo moving files on ftp server
@REM if remote directory does not exist then session will fail and terminate
@REM set oldfies = SetupSoldfies/
@REM echo mkdir SetupSoldfies/>>%mvfilesini1%
@REM files will move to SetupSoldfies/ if exist then skip
echo mv checksums*.md5 SetupSoldfies/>>%mvfilesini1%
echo mv SetupS.*  setupsoldfies/>>%mvfilesini1%
echo mv Install.SetupS*.* SetupSoldfies/>>%mvfilesini1%

@REM move the files first then remove after attempt
@REM  otherwise it will fail if file exists
echo mv SetupS-files.htm  setupsoldfies/>>%mvfilesini1%
echo rm SetupS-files.htm >>%mvfilesini1%
echo mv SetupS-title.png  setupsoldfies/>>%mvfilesini1%
echo rm  SetupS-title.png >>%mvfilesini1%
echo mv ChangeLog.txt  setupsoldfies/>>%mvfilesini1%
echo rm ChangeLog.txt  >>%mvfilesini1%
echo mv update.ini  setupsoldfies/>>%mvfilesini1%
echo rm update.ini >>%mvfilesini1%


echo exit >>%mvfilesini1%

call updfiles.cmd %mvfilesini1%
call movedfilesftp.cmd %mvfilesini1%



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
@REM echo exit >>%mvfilesini1%

@REM call  updfiles.cmd with  %mvfilesini1%
@REM call updfiles.cmd %mvfilesini1%

@REM call movedfilesftp.cmd %mvfilesini1%