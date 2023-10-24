@echo off
@REM makehelp.cmd
@REM make help script for upload
cls
color 0a
@REM debug
@REM goto confirmdelhelp

@REM #######################################################
@REM ###  WebLink1=sstek.vergitek.com
@REM #######################################################

set WebSite1=ssTek Forum
set WebLink1=sstek.vergitek.com
set domain1=dev@lastos.org
set ftp1=ftp.vergitek.com
set Webfolder1=
set Webfolder2=files/
set helpfilesini1=helpvergitek.ini



@REM  get the path from command line else set the default
:getPath
if [%1]==[] goto setPath
set HelpPath=%1
set HelpFile=%2
goto Begin

:setPath
set HelpPath=Source.Code\sstekhelpfiles
set HelpPathsupport=Source.Code\htmlhelp
set HelpFile=ssTek

@REM create script file for upload
echo creating %helpfilesini1% for upload...
cd "%~dp0"
@REM create files to upload script for winscp useage
@REM ref: https://winscp.net/eng/docs/commandline
@REM https://winscp.net/eng/docs/scripting
@REM To insert comments into the script file, start the line with # (hash):
if exist "%helpfilesini1%" del /F /Q "%helpfilesini1%" >nul:
@REM echo ; connect to ftp server  >>%helpfilesini1%
@REM this opens connection to help/%Webfolder2%
echo open ftp://%domain1%:#Password#@%ftp1%/%Webfolder2%>>%helpfilesini1%

echo put "%HelpPath%\files\*.* ">>%helpfilesini1%
echo exit >>%helpfilesini1%

@REM this opens connection to help/%Webfolder1%
echo open ftp://%domain1%:#Password#@%ftp1%/%Webfolder1%>>%helpfilesini1%
echo put "%HelpPathsupport%\%HelpFile%.html">>%helpfilesini1%
echo put "%HelpPathsupport%\favicon.ico">>%helpfilesini1%

echo exit >>%helpfilesini1%


@REM this will update the .ini file with the password for ftp
@REM call updfiles.cmd <filename>
call updfiles.cmd %helpfilesini1%

type %helpfilesini1%

@REM this will upload the files to the contents of  %helpfilesini1%
@REM call uploadfilesftp.cmd <filename>
call uploadfilesftp.cmd %helpfilesini1%

goto confirmdelhelp


@REM #######################################################
@REM ###  confirmdelhelp
@REM #######################################################
:confirmdelhelp
@REM https://www.robvanderwoude.com/choice.php
CHOICE /C:YN /N /T 5 /D N  /M "Do you want to DELETE help files, default is No ['Y'es/'N'o] : "
if errorlevel 2 goto :somewhere_else
if errorlevel 1 goto :somewhere
echo.
:somewhere
@REM echo "I am here because you typed Y"
set deletehelp=Yes
echo.

Echo %_bBWhite%%_bBlue%####################################################### %_fBGreen%%_bBlack%
echo Help Files will be deleted
echo.

timeout /T 5
goto deletehelp

:somewhere_else
@REM echo "I am here because you typed N"
set deletehelp=No
goto exit

@REM #######################################################
@REM ###  deletehelp
@REM #######################################################
:deletehelp
if exist "%~dp0%sc%\htmlhelp" rd /s /q "%~dp0%sc%\htmlhelp" >nul:

@REM #######################################################
@REM ###  exit
@REM #######################################################
:exit

