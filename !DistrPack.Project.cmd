@REM // SetupS-Project
@REM // Copyright (c) 2023 LastOS Team
@REM // All rights reserved. License: MIT License
:This script creates dual architecture (x86|x64) distribution packages. Does NOT require an x64-machine to run.
: it also uploads the created files tp ftp sites
:Assumes the following are installed: "AutoIt3" (plus SciTE), and "Inno Setup". Plus, Winscp, "HelpNDoc" (v8) and "Microsoft's HTML Help Workshop" should be installed in order to update the help-files.
:The following folders also need to be present: bin, sfx, winscp and curl.
:7zip.exe will be required but is already included in the Tools folder.

@echo off
@REM ref https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/color
@REM black / green color 02
@REM color 02
@REM blue / white color 17
@REM color 17
  @REM black / Light Green color 0A
color 0A
cls
call !RestoreOriginals.cmd

goto :getVer

@REM @echo off
@REM SET /A a = 5
@REM SET /A b = 10
@REM SET /A c = %a% + %b%
@REM if %c%==15 (echo "The value of variable c is 15") else (echo "Unknown value")
@REM if %c%==10 (echo "The value of variable c is 10") else (echo "Unknown value")

::ask set Upload=No
@REM If (condition) (do_something) ELSE (do_something_else)
@REM pause
echo Upload = %Upload%
@REM pause
@REM if [%DoUploads%]==[No] goto RestoreOriginals
@REM goto
if  [%Upload%]==[No](echo.
echo  Upload parameter is set to 'No'
@REM https://www.robvanderwoude.com/choice.php
CHOICE /C:YN /N /M "Are you sure you want to continue? ['Y'es/'N'o] : "
if errorlevel 2 goto :somewhere_else
if errorlevel 1 goto :somewhere

:somewhere
@REM echo "I am here because you typed Y"
echo continuing ...
goto :getVer


:somewhere_else
rem echo "I am here because you typed N"
echo
  echo.===============================================================================
echo.
echo. aborting creating distribution packages
echo. change parameter to Upload=Yes in file !!Make.SetupS-Project.cmd
echo then rerun
echo.
  echo.===============================================================================
@REM pause
goto :Quit
)else(goto :getVer)

:getVer
if [%1]==[] goto setVer
set ProjectVersion=%1
goto getDate

:setVer
set ProjectVersion=23.09.26.0
goto getDate

:getDate
if [%2]==[] goto setDate
set ProjectDate=%2
goto getDoUploads

:setDate
set ProjectDate=2023-09-26
goto getDoUploads

:getDoUploads
if [%3]==[] goto setDoUploads
set DoUploads=%3
goto setText

:setDoUploads
set DoUploads=No
goto setText

@REM #######################################################
@REM ###  setText
@REM #######################################################
:setText
set cYear=2023
set cHolder=Vergitek Solutions


@REM #######################################################
@REM ###  WebLink1=sstek.vergitek.com
@REM #######################################################

set WebSite1=ssTek Forum
set WebLink1=sstek.vergitek.com
set domain1=setups@lastos.org
set ftp1=ftp.vergitek.com
set Webfolder1=
set filesini1=filesvergitek.ini
set mvfilesini1=mvfiles1.ini

@REM #######################################################
@REM ###  WebLink2=www.lastos.org
@REM #######################################################
set WebSite2=LastOS Forum
set WebLink2=www.lastos.org
set domain2=setups@lastos.org
set ftp2=ftp.lastos.org
set Webfolder2=
set filesini2=fileslastos.ini
set mvfilesini2=mvfiles.ini


@REM #######################################################
@REM ###  Alternate login
@REM #######################################################
set WebLink5=lastos.vergitek.com

:set ANSI colors
@REM ref: https://ss64.com/nt/syntax-ansi.html
Set _bBlack=[40m
Set _fGreen=[32m
Set _fBGreen=[92m
Set _fRed=[31m
Set _fYellow=[33m
Set _bBlue=[44m
Set _RESET=[0m
Set _fBWhite=[97m
Set _bBWhite=[107m

@REM Echo %_fRed%%_bBlack% error
@REM Echo %_RESET%
@REM Echo %_fBGreen%%_bBlack%
@REM echo working
@REM Echo %_fYellow%%_bBlue%
@REM echo finished
@REM @REM Echo %_RESET%
Echo %_fBGreen%%_bBlack%

@REM bintray no longer exists
@REM #######################################################
@REM ###  WebLink3=dl.bintray.com/sstek
@REM #######################################################
@REM set WebSite3=ssTek Distribution
@REM set WebLink3=dl.bintray.com/sstek

@REM #######################################################
@REM ###   WebSite4=ssTek Development
@REM #######################################################
set WebSite4=ssTek Development
set WebLink4=sstek.vergitek.com

@REM #######################################################
set LastosUploads=No

@REM #######################################################
@REM ###    WebSite6=github files
@REM #######################################################
set WebSite6=github files
set WebLink6=github.com/pacav69/SetupS.Project_DevelopersPack
set NewTagLine=%Website1%: Tools for custom Operating Systems!

@REM #######################################################
@REM ###    versioning
@REM #######################################################
set CoreVersion=%ProjectVersion%
set ssEditorVersion=%ProjectVersion%

goto Begin

@REM #######################################################
@REM ###  Begin
@REM #######################################################
:Begin
echo ###########################################################
echo.
echo #    Welcome to  the LastOS SetupS Project Developers Pack
echo #    This will compile and upload the SetupS Suite
echo.
echo ###########################################################
echo.

@REM https://www.robvanderwoude.com/choice.php
CHOICE /C:YN /N /T 5 /D N  /M "Do you want to upload files with Winscp at the end, default is No ['Y'es/'N'o] : "
if errorlevel 2 goto :somewhere_else
if errorlevel 1 goto :somewhere
echo.
:somewhere
@REM echo "I am here because you typed Y"
set LastosUploads=Yes
echo.

Echo %_bBWhite%%_bBlue%####################################################### %_fBGreen%%_bBlack%
echo Files will be uploaded at end of compilation
echo.

timeout /T 5
goto check2

:somewhere_else
@REM echo "I am here because you typed N"
set LastosUploads=No

@REM goto starttest

@REM :starttest
@REM echo.
@REM echo LastosUploads = %LastosUploads%
@REM echo.
@REM pause

@REM sstek.vergitek.com check2

:check2
echo.
@REM https://www.robvanderwoude.com/choice.php
choice /C:YN /N /T 5 /D N  /M "Do you want to upload files with Winscp to Vergitek at the end, default is No ['Y'es/'N'o] : "
if errorlevel 2 goto :somewhere_else2
if errorlevel 1 goto :somewhere2
echo.
:somewhere2
@REM echo "I am here because you typed Y"
set vergitekUploads=Yes
echo.

Echo %_bBWhite%%_bBlue%####################################################### %_fBGreen%%_bBlack%
echo Files will be uploaded at end of compilation
echo.
timeout /T 5
goto start

:somewhere_else2
@REM echo "I am here because you typed N"
set vergitekUploads=No
echo.
@REM goto starttest


:start
echo.
echo *********************************************************
echo Begin ... SetupS Project (version: %ProjectVersion%)
set sc=Source.Code
set EditorPath=ssEditor
set ssPIPath=ssPreinstaller
set path=%path%;%~dp0bin;%~dp0%sc%\Tools;%~dp0%sc%\Tools\_x86
cd "%~dp0"
if exist "%sc%\default.ini" xcopy "%sc%\default.ini\*.*" "%sc%\*.*" /y/e/s >nul:
if exist "%sc%\%EditorPath%\default.ini" xcopy "%sc%\%EditorPath%\default.ini\*.*" "%sc%\%EditorPath%\*.*" /y/e/s >nul:

:SetAutoIt3 working variable
set AutoIt3="%ProgramFiles%\AutoIt3\AutoIt3.exe"
if exist "%ProgramFiles(x86)%\AutoIt3\AutoIt3.exe" set AutoIt3="%ProgramFiles(x86)%\AutoIt3\AutoIt3.exe"
FOR %%i IN (C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO IF EXIST "%%i:\ppApps\AutoIt3\AutoIt3.exe" (SET AutoIt3="%%i:\ppApps\AutoIt3\AutoIt3.exe"& goto SetHHCompiler)

:SetHHCompiler working variable
set HHCompiler="%ProgramFiles%\HTML Help Workshop\hhc.exe"
if exist "%ProgramFiles(x86)%\HTML Help Workshop\hhc.exe" set HHCompiler="%ProgramFiles(x86)%\HTML Help Workshop\hhc.exe"
FOR %%i IN (C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO IF EXIST "%%i:\ppApps\HTML Help Workshop\hhc.exe" (SET HHCompiler="%%i:\ppApps\HTML Help Workshop\hhc.exe"& goto MakeBackups)

:MakeBackups of originals

:SetHelpNDoc8 working variable
set HelpNDoc8="%ProgramFiles%\HelpNDoc8HelpNDoc8\hnd8.exe"
if exist "%ProgramFiles(x86)%\HelpNDoc8\hnd8.exe" set HelpNDoc8="%ProgramFiles(x86)%\HelpNDoc8\hnd8.exe"
FOR %%i IN (C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO IF EXIST "%%i:\ppApps\HelpNDoc8\hnd8.exe" (SET HelpNDoc8="%%i:\ppApps\HelpNDoc8\hnd8.exe"& goto doitnow)

:doitnow

echo Backing up originals...
cd "%~dp0"
if exist "%sc%\originals" goto Cleaning
md "%sc%\originals\%EditorPath%"
md "%sc%\originals\%ssPIPath%"
copy "%sc%\*.au3" "%sc%\originals" /y >nul:
copy "%sc%\*.iss" "%sc%\originals" /y >nul:
copy "%sc%\*.app" "%sc%\originals" /y >nul:
copy "%sc%\%EditorPath%\*.au3" "%sc%\originals\%EditorPath%" /y >nul:
copy "%sc%\%EditorPath%\*.app" "%sc%\originals\%EditorPath%" /y >nul:
copy "%sc%\%ssPIPath%\*.au3" "%sc%\originals\%ssPIPath%" /y >nul:
copy "%sc%\%ssPIPath%\*.ini" "%sc%\originals\%ssPIPath%" /y >nul:
copy "%sc%\SetupS-*.htm" "%sc%\originals" /y >nul:

:Find And Replace Text for the following (requires: bin\fart.exe)
echo Updating file resource info ...
cd "%~dp0"

@REM #######################################################
@REM ###  versioning
@REM #######################################################
::versioning
fart -q -i "%sc%\*.au3" "#ProjectVersion#" "%ProjectVersion%" >nul:
fart -q -i "%sc%\*.iss" "#ProjectVersion#" "%ProjectVersion%" >nul:
fart -q -i "%sc%\*.app" "#ProjectVersion#" "%ProjectVersion%" >nul:
fart -q -i "%sc%\*.au3" "#CoreVersion#" "%CoreVersion%" >nul:
fart -q -i "%sc%\*.iss" "#CoreVersion#" "%CoreVersion%" >nul:
fart -q -i "%sc%\*.app" "#CoreVersion#" "%CoreVersion%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#ProjectVersion#" "%ProjectVersion%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#ProjectVersion#" "%ProjectVersion%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#ssEditorVersion#" "%ssEditorVersion%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#ssEditorVersion#" "%ssEditorVersion%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#CoreVersion#" "%CoreVersion%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#CoreVersion#" "%CoreVersion%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#ProjectVersion#" "%ProjectVersion%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#ProjectVersion#" "%ProjectVersion%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#CoreVersion#" "%CoreVersion%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#CoreVersion#" "%CoreVersion%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#ProjectVersion#" "%ProjectVersion%" >nul:

@REM #######################################################
@REM ###  ProjectDate
@REM #######################################################
::ProjectDate
fart -q -i "%sc%\*.au3" "#ProjectDate#" "%ProjectDate%" >nul:
fart -q -i "%sc%\*.iss" "#ProjectDate#" "%ProjectDate%" >nul:
fart -q -i "%sc%\*.app" "#ProjectDate#" "%ProjectDate%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#ProjectDate#" "%ProjectDate%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#ProjectDate#" "%ProjectDate%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#ProjectDate#" "%ProjectDate%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#ProjectDate#" "%ProjectDate%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#ProjectDate#" "%ProjectDate%" >nul:

@REM #######################################################
@REM ###  cYear
@REM #######################################################
::cYear
fart -q -i "%sc%\*.au3" "#cYear#" "%cYear%" >nul:
fart -q -i "%sc%\*.iss" "#cYear#" "%cYear%" >nul:
fart -q -i "%sc%\*.app" "#cYear#" "%cYear%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#cYear#" "%cYear%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#cYear#" "%cYear%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#cYear#" "%cYear%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#cYear#" "%cYear%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#cYear#" "%cYear%" >nul:

@REM #######################################################
@REM ###  cHolder
@REM #######################################################
::cHolder
fart -q -i "%sc%\*.au3" "#cHolder#" "%cHolder%" >nul:
fart -q -i "%sc%\*.iss" "#cHolder#" "%cHolder%" >nul:
fart -q -i "%sc%\*.app" "#cHolder#" "%cHolder%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#cHolder#" "%cHolder%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#cHolder#" "%cHolder%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#cHolder#" "%cHolder%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#cHolder#" "%cHolder%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#cHolder#" "%cHolder%" >nul:

@REM #######################################################
@REM ###  ::WebSite1
@REM #######################################################
::WebSite1
fart -q -i "%sc%\*.au3" "#WebSite1#" "%WebSite1%" >nul:
fart -q -i "%sc%\*.iss" "#WebSite1#" "%WebSite1%" >nul:
fart -q -i "%sc%\*.app" "#WebSite1#" "%WebSite1%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#WebSite1#" "%WebSite1%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#WebSite1#" "%WebSite1%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#WebSite1#" "%WebSite1%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#WebSite1#" "%WebSite1%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#WebSite1#" "%WebSite1%" >nul:

@REM #######################################################
@REM ###  ::WebLink1
@REM #######################################################
::WebLink1
fart -q -i "%sc%\*.au3" "#WebLink1#" "%WebLink1%" >nul:
fart -q -i "%sc%\*.iss" "#WebLink1#" "%WebLink1%" >nul:
fart -q -i "%sc%\*.app" "#WebLink1#" "%WebLink1%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#WebLink1#" "%WebLink1%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#WebLink1#" "%WebLink1%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#WebLink1#" "%WebLink1%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#WebLink1#" "%WebLink1%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#WebLink1#" "%WebLink1%" >nul:

@REM #######################################################
@REM ###  WebSite2
@REM #######################################################
::WebSite2
fart -q -i "%sc%\*.au3" "#WebSite2#" "%WebSite2%" >nul:
fart -q -i "%sc%\*.iss" "#WebSite2#" "%WebSite2%" >nul:
fart -q -i "%sc%\*.app" "#WebSite2#" "%WebSite2%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#WebSite2#" "%WebSite2%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#WebSite2#" "%WebSite2%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#WebSite2#" "%WebSite2%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#WebSite2#" "%WebSite2%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#WebSite2#" "%WebSite2%" >nul:

@REM #######################################################
@REM ###  WebLink2
@REM #######################################################
::WebLink2
fart -q -i "%sc%\*.au3" "#WebLink2#" "%WebLink2%" >nul:
fart -q -i "%sc%\*.iss" "#WebLink2#" "%WebLink2%" >nul:
fart -q -i "%sc%\*.app" "#WebLink2#" "%WebLink2%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#WebLink2#" "%WebLink2%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#WebLink2#" "%WebLink2%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#WebLink2#" "%WebLink2%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#WebLink2#" "%WebLink2%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#WebLink2#" "%WebLink2%" >nul:

@REM #######################################################
@REM ###  WebSite3
@REM #######################################################
::WebSite3
fart -q -i "%sc%\*.au3" "#WebSite3#" "%WebSite3%" >nul:
fart -q -i "%sc%\*.iss" "#WebSite3#" "%WebSite3%" >nul:
fart -q -i "%sc%\*.app" "#WebSite3#" "%WebSite3%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#WebSite3#" "%WebSite3%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#WebSite3#" "%WebSite3%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#WebSite3#" "%WebSite3%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#WebSite3#" "%WebSite3%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#WebSite3#" "%WebSite3%" >nul:

@REM #######################################################
@REM ###  WebLink3
@REM #######################################################
::WebLink3
fart -q -i "%sc%\*.au3" "#WebLink3#" "%WebLink3%" >nul:
fart -q -i "%sc%\*.iss" "#WebLink3#" "%WebLink3%" >nul:
fart -q -i "%sc%\*.app" "#WebLink3#" "%WebLink3%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#WebLink3#" "%WebLink3%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#WebLink3#" "%WebLink3%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#WebLink3#" "%WebLink3%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#WebLink3#" "%WebLink3%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#WebLink3#" "%WebLink3%" >nul:

@REM #######################################################
@REM ###  WebSite4
@REM #######################################################
::WebSite4
fart -q -i "%sc%\*.au3" "#WebSite4#" "%WebSite4%" >nul:
fart -q -i "%sc%\*.iss" "#WebSite4#" "%WebSite4%" >nul:
fart -q -i "%sc%\*.app" "#WebSite4#" "%WebSite4%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#WebSite4#" "%WebSite4%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#WebSite4#" "%WebSite4%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#WebSite4#" "%WebSite4%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#WebSite4#" "%WebSite4%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#WebSite4#" "%WebSite4%" >nul:

@REM #######################################################
@REM ###  WebLink4
@REM #######################################################
::WebLink4
fart -q -i "%sc%\*.au3" "#WebLink4#" "%WebLink4%" >nul:
fart -q -i "%sc%\*.iss" "#WebLink4#" "%WebLink4%" >nul:
fart -q -i "%sc%\*.app" "#WebLink4#" "%WebLink4%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#WebLink4#" "%WebLink4%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#WebLink4#" "%WebLink4%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#WebLink4#" "%WebLink4%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#WebLink4#" "%WebLink4%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#WebLink4#" "%WebLink4%" >nul:


@REM #######################################################
@REM ###  WebSite6 github
@REM #######################################################
:: WebSite6 github
::WebSite6
fart -q -i "%sc%\*.au3" "#WebSite6#" "%WebSite6%" >nul:
fart -q -i "%sc%\*.iss" "#WebSite6#" "%WebSite6%" >nul:
fart -q -i "%sc%\*.app" "#WebSite6#" "%WebSite6%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#WebSite6#" "%WebSite6%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#WebSite6#" "%WebSite6%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#WebSite6#" "%WebSite6%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#WebSite6#" "%WebSite6%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#WebSite6#" "%WebSite6%" >nul:

@REM #######################################################
@REM ### weblink6 github
@REM #######################################################
:: weblink6 github
::WebLink6
fart -q -i "%sc%\*.au3" "#WebLink6#" "%WebLink6%" >nul:
fart -q -i "%sc%\*.iss" "#WebLink6#" "%WebLink6%" >nul:
fart -q -i "%sc%\*.app" "#WebLink6#" "%WebLink6%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#WebLink6#" "%WebLink6%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#WebLink6#" "%WebLink6%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#WebLink6#" "%WebLink6%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#WebLink6#" "%WebLink6%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#WebLink6#" "%WebLink6%" >nul:

@REM #######################################################
@REM ### :CompileEXE's (requires: AutoIt3 plus SciTE)
@REM #######################################################
:CompileEXE's (requires: AutoIt3 plus SciTE)
cd "%~dp0%sc%"
call Compile.AutoIt.Script.cmd SetupS
call Compile.AutoIt.Script.cmd ssRegenerator
call Compile.AutoIt.Script.cmd ssControlPanel
call Compile.AutoIt.Script.cmd AddonInstaller Move2DualArchTools
call Compile.AutoIt.Script.cmd AddToHosts Move2DualArchTools
call Compile.AutoIt.Script.cmd ProcessKill Move2DualArchTools
call Compile.AutoIt.Script.cmd WaitForIt Move2DualArchTools
call Compile.AutoIt.Script.cmd RunRUNAway x86Only
call Compile.AutoIt.Script.cmd ssRegeneratorAlias x86Only
call Compile.AutoIt.Script.cmd ssControlPanelAlias x86Only
rem call Compile.AutoIt.Script.cmd LinuxSendTo x86Only
copy "tools\SetupScp.exe" "tools\ssCP.exe" /y >nul:
copy "tools\Regenerator.exe" "tools\ssRegen.exe" /y >nul:

@REM #######################################################
@REM ### Create ssPreinstaller
@REM #######################################################
:ssPreinstaller
cd "%ssPIPath%"
call Compile.AutoIt.Script.cmd ssPreinstaller
cd ".."

@REM #######################################################
@REM ### Create ssEditor
@REM #######################################################
:ssEditor
cd "%EditorPath%"
call Compile.AutoIt.Script.cmd %EditorPath%

@REM #######################################################
@REM ### MakeHelpFiles
@REM #######################################################
:MakeHelpFiles
set UpdateHelpPath=%~dp0%sc%
set UpdateHelpFile=ssTek

@REM #######################################################
@REM ### UpdateHelpFile
@REM #######################################################
:UpdateHelpFile
echo Updating the help-file for %UpdateHelpFile%...
cd "%UpdateHelpPath%"
if exist "%UpdateHelpFile%.html" del /F /Q "%UpdateHelpFile%.html" >nul:
if exist "files" rd /s /q "files" >nul:
@REM cd "%~dp0%bin"

@REM #######################################################
@REM ### build help file using HelpNDoc8
@REM #######################################################
:HelpNDoc8
@REM build help file using HelpNDoc8
@REM %HelpNDoc8% %UpdateHelpPath%\%UpdateHelpFile%.hnd build -x="Build chm documentation" -o=%UpdateHelpFile% & ".chm:.\"
set htmlhelp=%UpdateHelpPath%\sstekhelpfiles\files
if exist "htmlhelp" rd /s /q "htmlhelp" >nul:
if not exist "htmlhelp"  mkdir "htmlhelp" >nul:
echo Compiling help
echo.
@REM other options change silent to verysilent for no progress display
@REM verbose
%HelpNDoc8% %UpdateHelpPath%\%UpdateHelpFile%.hnd build  -silent -x="Build chm documentation" -o=%UpdateHelpFile%.chm"
@REM %HelpNDoc8% %UpdateHelpPath%\%UpdateHelpFile%.hnd build -silent -x="Build HTML documentation" -o="Build HTML documentation:%~dp0\html\%UpdateHelpFile%.html"
%HelpNDoc8% %UpdateHelpPath%\%UpdateHelpFile%.hnd build -silent -x="Build HTML documentation" -o="Build HTML documentation:%htmlhelp%\%UpdateHelpFile%.html"

@REM echo finished
@REM original autoit file
@REM %AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript CompileHND2.au3 "%UpdateHelpPath%" "%UpdateHelpFile%"
cd "%UpdateHelpPath%"
@REM echo here after compile
@REM pause
@REM %AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript CompileHND.au3 "%UpdateHelpPath%" "%UpdateHelpFile%"
cd "%UpdateHelpPath%"
if exist "help" rd /s /q "help" >nul:
hh.exe -decompile help %UpdateHelpFile%.chm
fart -qiC ".\%UpdateHelpFile%.html" "<head>" "<head><link rel=\"shortcut icon\" href=\"favicon.ico\" />"
fart -q -i -r ".\*.html" "#ProjectVersion#" "%ProjectVersion%" >nul:
fart -q -i -r ".\*.html" "#ProjectDate#" "%ProjectDate%" >nul:
fart -q -i -r ".\*.html" "#CoreVersion#" "%CoreVersion%" >nul:
fart -q -i -r ".\*.html" "#ssEditorVersion#" "%ssEditorVersion%" >nul:
fart -q -i -r ".\*.html" "#cYear#" "%cYear%" >nul:
fart -q -i -r ".\*.html" "#cHolder#" "%cHolder%" >nul:
fart -q -i -r ".\*.html" "#WebSite1#" "%WebSite1%" >nul:
fart -q -i -r ".\*.html" "#WebSite2#" "%WebSite2%" >nul:
fart -q -i -r ".\*.html" "#WebSite3#" "%WebSite3%" >nul:
fart -q -i -r ".\*.html" "#WebSite4#" "%WebSite4%" >nul:
fart -q -i -r ".\*.html" "#WebSite6#" "%WebSite6%" >nul:
fart -q -i -r ".\*.html" "#WebLink1#" "%WebLink1%" >nul:
fart -q -i -r ".\*.html" "#WebLink2#" "%WebLink2%" >nul:
fart -q -i -r ".\*.html" "#WebLink3#" "%WebLink3%" >nul:
fart -q -i -r ".\*.html" "#WebLink4#" "%WebLink4%" >nul:
fart -q -i -r ".\*.html" "#WebLink5#" "%WebLink5%" >nul:
fart -q -i -r ".\*.html" "#WebLink6#" "%WebLink6%" >nul:
::Modify adverts
fart -q -i -r ".\*.html" ">Created with the Freeware Edition of HelpNDoc: </span>" "></span>"
fart -q -i -r ".\*.html" "http://www.helpndoc.com" "http://%WebLink1%"
fart -q -i -r ".\*.html" ">Easily create Help documents</a></p>" ">%NewTagLine%</a></p>"
fart -q -i -r ".\*.html" ">Easily create CHM Help documents</a></p>" ">%NewTagLine%</a></p>"
fart -q -i -r ".\*.html" ">Easily create HTML Help documents</a></p>" ">%NewTagLine%</a></p>"
fart -q -i -r ".\*.html" ">Easily create PDF Help documents</a></p>" ">%NewTagLine%</a></p>"
fart -q -i -r ".\*.html" ">Easily create Web Help sites</a></p>" ">%NewTagLine%</a></p>"
fart -q -i -r ".\*.html" ">Single source CHM, PDF, DOC and HTML Help creation</a></p>" ">%NewTagLine%</a></p>"
fart -q -i -r ".\*.html" ">Create HTML Help, DOC, PDF and print manuals from 1 single source</a></p>" ">%NewTagLine%</a></p>"
fart -q -i -r ".\*.html" ">Easy to use tool to create HTML Help files and Help web sites</a></p>" ">%NewTagLine%</a></p>"
fart -q -i -r ".\*.html" ">Full featured Help generator</a></p>" ">%NewTagLine%</a></p>"
fart -q -i -r ".\*.html" ">Full featured multi-format Help generator</a></p>" ">%NewTagLine%</a></p>"
fart -q -i -r ".\*.html" ">Full featured Documentation generator</a></p>" ">%NewTagLine%</a></p>"
fart -q -i -r ".\*.html" ">Easy CHM and documentation editor</a></p>" ">%NewTagLine%</a></p>"
fart -q -i -r ".\*.html" ">Free CHM Help documentation generator</a></p>" ">%NewTagLine%</a></p>"
fart -q -i -r ".\*.html" ">Free PDF documentation generator</a></p>" ">%NewTagLine%</a></p>"
fart -q -i -r ".\*.html" ">Free HTML Help documentation generator</a></p>" ">%NewTagLine%</a></p>"
fart -q -i -r ".\*.html" ">Free Web Help generator</a></p>" ">%NewTagLine%</a></p>"
fart -q -i -r ".\*.html" ">Free help authoring environment</a></p>" ">%NewTagLine%</a></p>"
fart -q -i -r ".\*.html" ">Free help authoring tool</a></p>" ">%NewTagLine%</a></p>"
if exist "%UpdateHelpFile%.hhp" copy "%UpdateHelpFile%.hhp" "help\*.*" /y >nul:
if exist "%UpdateHelpFile%.hhp" del /F /Q "%UpdateHelpFile%.hhp" >nul:
if exist "help\%UpdateHelpFile%.hhp" %HHCompiler% "help\%UpdateHelpFile%.hhp" >nul:
if exist "help\%UpdateHelpFile%.chm" copy "help\%UpdateHelpFile%.chm" /y >nul:
if exist "help" rd /s /q "help" >nul:

@REM #######################################################
@REM ### CopyHelpFiles
@REM #######################################################
:CopyHelpFiles
cd "%~dp0%sc%"
if exist "ssTek.chm" copy "ssTek.chm" "Tools\ssTek.chm" /y >nul:

@REM #######################################################
@REM ### create ssEditorppApp
@REM #######################################################
:CreatessEditorppApp
cd "%~dp0%sc%\%EditorPath%"
call "Create.ppApp.package.cmd" %EditorPath%

@REM #######################################################
@REM ### Create Inno Installer (requires: Inno Setup)
@REM #######################################################
:Create Inno Installer (requires: Inno Setup)
echo Compiling the InnoSetup Installer package...
cd "%~dp0%sc%"
set ssII=Install.SetupS_v%ProjectVersion%
set InnoCompiler="%ProgramFiles%\Inno Setup 5\compil32.exe"
if exist "%ProgramFiles(x86)%\Inno Setup 5\compil32.exe" set InnoCompiler="%ProgramFiles(x86)%\Inno Setup 5\compil32.exe"
%InnoCompiler% /cc "SetupS.iss"
copy "Inno.Output\%ssII%.exe" "..\*.*" /y >nul:
if exist "Inno.Output\%ssII%.exe" del /F /Q "Inno.Output\%ssII%.exe" >nul:

@REM #######################################################
@REM ### Create dual-arch SetupS.Uninstaller.EXE (requires: 7zip & sfx)
@REM #######################################################
:Create dual-arch SetupS.Uninstaller.EXE (requires: 7zip & sfx)
echo Constructing the dual-arch SetupS.Uninstaller package...
cd "%~dp0"
set ssUI=SetupS.Uninstaller_v%ProjectVersion%
if exist "%ssUI%" rd /s /q "%ssUI%" >nul:
md "%ssUI%" >nul:
cd "%ssUI%" >nul:
copy "..\%sc%\%ssPIPath%\ssPreinstaller.exe" /y >nul:
copy "..\%sc%\%ssPIPath%\ssPreinstaller_x64.exe" /y >nul:
copy "..\%sc%\%ssPIPath%\ssPreinstaller.ini" /y >nul:
echo ;!@Install@!UTF-8!>"..\sfx\Config.txt"
echo MiscFlags="4">>"..\sfx\Config.txt"
echo RunProgram="x86:ssPreinstaller.exe -StartMenuOnly">>"..\sfx\Config.txt"
echo RunProgram="x64:ssPreinstaller_x64.exe -StartMenuOnly">>"..\sfx\Config.txt"
echo GUIMode="1">>"..\sfx\Config.txt"
echo ;!@InstallEnd@!>>"..\sfx\Config.txt"
7z a "%ssUI%.7z" -ms=on -mx=9 -m0=lzma2 >nul:
copy /b "..\sfx\7zSD.sfx" + "..\sfx\Config.txt" + "%ssUI%.7z" "..\%ssUI%.exe" /y >nul:

@REM #######################################################
@REM ### Create SetupS.SendTo.Suite_ssApp.APZ
@REM #######################################################
:Create SetupS.SendTo.Suite_ssApp.APZ (requires: 7zip)
echo Constructing the ssWPI deployment package (as APZ)...
cd "%~dp0"
set ssApp=SetupS.SendTo.Suite_v%ProjectVersion%_ssApp
if exist "%ssApp%" rd /s /q "%ssApp%" >nul:
md "%ssApp%" >nul:
cd "%ssApp%" >nul:
copy "..\%ssII%.exe" /y >nul:
copy "..\%sc%\%ssPIPath%\ssPreinstaller.exe" /y >nul:
copy "..\%sc%\%ssPIPath%\ssPreinstaller_x64.exe" /y >nul:
copy "..\%sc%\%ssPIPath%\ssPreinstaller.ini" /y >nul:
copy "..\%sc%\ssApp.app" /y >nul:
copy "..\%sc%\ssApp.ico" /y >nul:
copy "..\%sc%\ssApp.png" /y >nul:
copy "..\%sc%\ssApp.jpg" /y >nul:
copy "..\%sc%\folder.jpg" /y >nul:
7z a "%ssApp%.apz" -ms=off -mx=9 -m0=lzma2 >nul:
copy "%ssApp%.apz" "..\%ssApp%.apz" /y >nul:

@REM #######################################################
@REM ### Create SetupS.SendTo.Suite_ssApp.EXE
@REM #######################################################
:Create SetupS.SendTo.Suite_ssApp.EXE (requires: 7zip and sfx)
echo Constructing the ssApp deployment package (as EXE)...
cd "%~dp0"
cd "%ssApp%" >nul:
if exist "%ssApp%.apz" del /F /Q "%ssApp%.apz" >nul:
copy "..\%sc%\Tools\SetupS.exe" /y >nul:
copy "..\%sc%\Tools\SetupS_x64.exe" /y >nul:
copy "..\%sc%\Tools\Tools.ico" /y >nul:
xcopy "..\%sc%\Tools\Menus\*.*" "Menus\*.*" /y/e/s >nul:
xcopy "..\%sc%\Tools\_x64\7z.*" "_x64\*.*" /y/e/s >nul:
xcopy "..\%sc%\Tools\_x86\7z.*" "_x86\*.*" /y/e/s >nul:
echo ;!@Install@!UTF-8!>"..\sfx\Config.txt"
echo MiscFlags="4">>"..\sfx\Config.txt"
echo RunProgram="x86:SetupS.exe -SplashOnly -Fadertainer=Off">>"..\sfx\Config.txt"
echo RunProgram="x64:SetupS_x64.exe -SplashOnly -Fadertainer=Off">>"..\sfx\Config.txt"
echo GUIMode="1">>"..\sfx\Config.txt"
echo ;!@InstallEnd@!>>"..\sfx\Config.txt"
7z a "%ssApp%.7z" -ms=on -mx=9 -m0=lzma2 >nul:
copy /b "..\sfx\7zSD.sfx" + "..\sfx\Config.txt" + "%ssApp%.7z" "..\%ssApp%.exe" /y >nul:

@REM #######################################################
@REM ### Create ssWPI update package
@REM #######################################################
:Create ssWPI update package (requires: 7zip)
echo Constructing the ssWPI update package (as 7z)...
cd "%~dp0"
set ppApp=SetupS_v%ProjectVersion%_ssWPI.Update.Package
if exist "%ppApp%" rd /s /q "%ppApp%"  >nul:
md "%ppApp%\Tools\Menus" >nul:
md "%ppApp%\Tools\_x86" >nul:
md "%ppApp%\Tools\_x64" >nul:
cd "%ppApp%" >nul:
xcopy "..\%sc%\Licenses\*.*" "Licenses\*.*" /y/e/s >nul:
xcopy "..\%sc%\Tools\*.*" "Tools\*.*" /y/e/s >nul:
copy "..\%sc%\*.ini" "Tools\*.ini" /y >nul:
xcopy "..\%sc%\%EditorPath%\templates\*.*" "Tools\%EditorPath%\templates\*.*" /y/e/s >nul:
xcopy "..\%sc%\%EditorPath%\bin\*.*" "Tools\%EditorPath%\bin\*.*" /y/e/s >nul:
copy "..\%sc%\%EditorPath%\*.exe" "Tools\%EditorPath%\*.exe" /y >nul:
copy "..\%sc%\%EditorPath%\*.lst" "Tools\%EditorPath%\*.lst" /y >nul:
copy "..\%sc%\%EditorPath%\*.ini" "Tools\%EditorPath%\*.ini" /y >nul:
if exist "Tools\update.ini" del /F /Q "Tools\update.ini" >nul:
7z a "%ppApp%.7z" -ms=on -mx=9 -m0=lzma2 >nul:
copy "%ppApp%.7z" "..\%ppApp%.7z" /y >nul:

@REM #######################################################
@REM ### Create SourceCodePack
@REM #######################################################
:Create SourceCodePack (requires: 7zip)
echo Constructing the GPLv3-friendly Source Code package (as 7z)...
cd "%~dp0"
set scp=SetupS.Project_v%ProjectVersion%_SourceCode
if exist "%scp%" rd /s /q "%scp%" >nul:
md "%scp%\%sc%\Inno.Output" >nul:
cd "%scp%" >nul:
copy "..\ChangeLog.txt" /y >nul:
copy "..\%sc%\*.au3" "%sc%" /y >nul:
copy "..\%sc%\*.ini" "%sc%" /y >nul:
copy "..\%sc%\*.iss" "%sc%" /y >nul:
copy "..\%sc%\*.app" "%sc%" /y >nul:
copy "..\%sc%\*.kxf" "%sc%" /y >nul:
copy "..\%sc%\*.ico" "%sc%" /y >nul:
copy "..\%sc%\*.jpg" "%sc%" /y >nul:
copy "..\%sc%\*.png" "%sc%" /y >nul:
if exist "..\%sc%\*.cmd" copy "..\%sc%\*.cmd" "%sc%" /y >nul:
if exist "..\%sc%\*.reg" copy "..\%sc%\*.reg" "%sc%" /y >nul:
xcopy "..\%sc%\UDFs\*.*" "%sc%\UDFs\*.*" /y/e/s >nul:
xcopy "..\%sc%\Licenses\*.*" "%sc%\Licenses\*.*" /y/e/s >nul:
xcopy "..\%sc%\default.ini\*.*" "%sc%\default.ini\*.*" /y/e/s >nul:
if exist "%sc%\Tools" rd /s /q "%sc%\Tools" >nul:
xcopy "..\%sc%\%EditorPath%\*.au3" "%sc%\%EditorPath%\*.*" /y/e/s >nul:
copy "..\%sc%\%EditorPath%\*.ini" "%sc%\%EditorPath%" /y >nul:
copy "..\%sc%\%EditorPath%\*.lst" "%sc%\%EditorPath%" /y >nul:
copy "..\%sc%\%EditorPath%\*.kxf" "%sc%\%EditorPath%" /y >nul:
copy "..\%sc%\%EditorPath%\*.ico" "%sc%\%EditorPath%" /y >nul:
copy "..\%sc%\%EditorPath%\*.jpg" "%sc%\%EditorPath%" /y >nul:
copy "..\%sc%\%EditorPath%\*.png" "%sc%\%EditorPath%" /y >nul:
copy "..\%sc%\%EditorPath%\*.icl" "%sc%\%EditorPath%" /y >nul:
copy "..\%sc%\%EditorPath%\*.cmd" "%sc%\%EditorPath%" /y >nul:
copy "..\%sc%\%EditorPath%\BinPackingList.txt" "%sc%\%EditorPath%" /y >nul:
xcopy "..\%sc%\%EditorPath%\templates\*.*" "%sc%\%EditorPath%\templates\*.*" /y/e/s >nul:
xcopy "..\%sc%\%EditorPath%\default.ini\*.*" "%sc%\%EditorPath%\default.ini\*.*" /y/e/s >nul:
if exist "%sc%\%EditorPath%\files" rd /s /q "%sc%\%EditorPath%\files" >nul:
if exist "%sc%\%EditorPath%\%EditorPath%_ppApp" rd /s /q "%sc%\%EditorPath%\%EditorPath%_ppApp" >nul:
if exist "%sc%\%EditorPath%\*.cmd" del /F /Q "%sc%\%EditorPath%\*.cmd" >nul:
if exist "%sc%\%EditorPath%\folder.jpg" del /F /Q "%sc%\%EditorPath%\folder.jpg" >nul:
if exist "%sc%\%EditorPath%\ppApp.*" del /F /Q "%sc%\%EditorPath%\ppApp.*" >nul:
xcopy "..\%sc%\%ssPIPath%\*.au3" "%sc%\%ssPIPath%\*.*" /y/e/s >nul:
copy "..\%sc%\%ssPIPath%\*.ini" "%sc%\%ssPIPath%" /y >nul:
copy "..\%sc%\%ssPIPath%\ppApp.*" "%sc%\%ssPIPath%" /y >nul:
7z a "%scp%.7z" -ms=on -mx=9 -m0=lzma2 >nul:
copy "%scp%.7z" "..\*.*" /y >nul:

@REM #######################################################
@REM ### UpdateINI
@REM #######################################################
:UpdateINI
if [%DoUploads%]==[No] goto RestoreOriginals
echo Refresh the "Update.ini" file...
cd "%~dp0%bin"
%AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "UpdateINI.au3" "%~dp0%sc%" "exe" "%WebLink1%/files"
copy "%~dp0%sc%\SetupS-*.htm" "%~dp0" /y >nul:
copy "%~dp0%sc%\SetupS-*.png" "%~dp0" /y >nul:

:RestoreOriginals
echo Restoring originals...
cd "%~dp0" >nul:
call !RestoreOriginals.cmd

@REM #######################################################
@REM ### Create DevelopersPack
@REM #######################################################
:Create DevelopersPack (requires: 7zip)
echo Constructing the Developers package (as 7z)...
cd "%~dp0" >nul:
set devpack=SetupS.Project_v%ProjectVersion%_DevelopersPack
if exist "%devpack%" rd /s /q "%devpack%" >nul:
md "%devpack%\%sc%\Inno.Output" >nul:
cd "%devpack%" >nul:
copy "..\ChangeLog.txt" /y >nul:
copy "..\!DistrPack.Project.cmd" /y >nul:
copy "..\!!Make.SetupS-Project.cmd" /y >nul:
copy "..\!RestoreOriginals.cmd" /y >nul:
if exist "..\bin\BackUp" rd /s /q "..\bin\BackUp" >nul:
if exist "..\bin\ftpcmd.dat" del /F /Q "..\bin\ftpcmd.dat" >nul:
xcopy "..\bin\*.*" "bin\*.*" /y/e/s >nul:
xcopy "..\curl\*.*" "curl\*.*" /y/e/s >nul:
xcopy "..\sfx\*.*" "sfx\*.*" /y/e/s >nul:
copy "..\%sc%\*.au3" "%sc%" /y >nul:
copy "..\%sc%\*.ini" "%sc%" /y >nul:
copy "..\%sc%\*.iss" "%sc%" /y >nul:
copy "..\%sc%\*.app" "%sc%" /y >nul:
copy "..\%sc%\*.hnd" "%sc%" /y >nul:
copy "..\%sc%\*.kxf" "%sc%" /y >nul:
copy "..\%sc%\*.ico" "%sc%" /y >nul:
copy "..\%sc%\*.jpg" "%sc%" /y >nul:
copy "..\%sc%\*.png" "%sc%" /y >nul:
copy "..\%sc%\*.py" "%sc%" /y >nul:
if exist "..\%sc%\*.cmd" copy "..\%sc%\*.cmd" "%sc%" /y >nul:
if exist "..\%sc%\*.reg" copy "..\%sc%\*.reg" "%sc%" /y >nul:
if exist "%sc%\*.exe" del /F /Q "%sc%\*.exe" >nul:
rem xcopy "..\%sc%\SetupS_ppApp\ppApp.*" "%sc%\SetupS_ppApp\*.*" /y/e/s >nul:
rem xcopy "..\%sc%\SetupS_ppApp\folder.*" "%sc%\SetupS_ppApp\*.*" /y/e/s >nul:
xcopy "..\%sc%\UDFs\*.*" "%sc%\UDFs\*.*" /y/e/s >nul:
if exist "..\%sc%\debug\*.au3" xcopy "..\%sc%\debug\*.au3" "%sc%\debug\*.au3" /y/e/s >nul:
xcopy "..\%sc%\bin\*.*" "%sc%\bin\*.*" /y/e/s >nul:
xcopy "..\%sc%\Licenses\*.*" "%sc%\Licenses\*.*" /y/e/s >nul:
xcopy "..\%sc%\default.ini\*.*" "%sc%\default.ini\*.*" /y/e/s >nul:
xcopy "..\%sc%\Tools\_x86\7z.*" "%sc%\Tools\_x86\*.*" /y/e/s >nul:
xcopy "..\%sc%\Tools\_x64\7z.*" "%sc%\Tools\_x64\*.*" /y/e/s >nul:
xcopy "..\%sc%\Tools\_x86\FontReg.exe" "%sc%\Tools\_x86\*.*" /y/e/s >nul:
xcopy "..\%sc%\Tools\_x64\FontReg.exe" "%sc%\Tools\_x64\*.*" /y/e/s >nul:
xcopy "..\%sc%\Tools\Default\*.*" "%sc%\Tools\Default\*.*" /y/e/s >nul:
xcopy "..\%sc%\Tools\Menus\*.*" "%sc%\Tools\Menus\*.*" /y/e/s >nul:
xcopy "..\%sc%\Tools\FaderModules\*.*" "%sc%\Tools\FaderModules\*.*" /y/e/s >nul:
if exist "%sc%\Tools\FaderModules\*.exe" del /F /Q "%sc%\Tools\FaderModules\*.exe" >nul:
xcopy "..\%sc%\Tools\SetUserFTA\*.*" "%sc%\Tools\SetUserFTA\*.*" /y/e/s >nul:
copy "..\%sc%\Tools\*.*" "%sc%\Tools\*.*" /y >nul:
if exist "%sc%\Tools\*.exe" del /F /Q "%sc%\Tools\*.exe" >nul:
if exist "%sc%\Tools\*.chm" del /F /Q "%sc%\Tools\*.chm" >nul:
xcopy "..\%sc%\%EditorPath%\*.au3" "%sc%\%EditorPath%\*.*" /y/e/s >nul:
copy "..\%sc%\%EditorPath%\*.ini" "%sc%\%EditorPath%" /y >nul:
copy "..\%sc%\%EditorPath%\*.lst" "%sc%\%EditorPath%" /y >nul:
copy "..\%sc%\%EditorPath%\*.app" "%sc%\%EditorPath%" /y >nul:
copy "..\%sc%\%EditorPath%\*.kxf" "%sc%\%EditorPath%" /y >nul:
copy "..\%sc%\%EditorPath%\*.ico" "%sc%\%EditorPath%" /y >nul:
copy "..\%sc%\%EditorPath%\*.jpg" "%sc%\%EditorPath%" /y >nul:
copy "..\%sc%\%EditorPath%\*.png" "%sc%\%EditorPath%" /y >nul:
copy "..\%sc%\%EditorPath%\*.icl" "%sc%\%EditorPath%" /y >nul:
copy "..\%sc%\%EditorPath%\*.cmd" "%sc%\%EditorPath%" /y >nul:
copy "..\%sc%\%EditorPath%\BinPackingList.txt" "%sc%\%EditorPath%" /y >nul:
xcopy "..\%sc%\%EditorPath%\bin\*.*" "%sc%\%EditorPath%\bin\*.*" /y/e/s >nul:
xcopy "..\%sc%\%EditorPath%\templates\*.*" "%sc%\%EditorPath%\templates\*.*" /y/e/s >nul:
xcopy "..\%sc%\%EditorPath%\default.ini\*.*" "%sc%\%EditorPath%\default.ini\*.*" /y/e/s >nul:
if exist "%sc%\%EditorPath%\%EditorPath%_ppApp" rd /s /q "%sc%\%EditorPath%\%EditorPath%_ppApp" >nul:
if exist "%sc%\%EditorPath%\files" rd /s /q "%sc%\%EditorPath%\files" >nul:
if exist "%sc%\%EditorPath%\lib" rd /s /q "%sc%\%EditorPath%\lib" >nul:
if exist "%sc%\%EditorPath%\*.exe" del /F /Q "%sc%\%EditorPath%\*.exe" >nul:
if exist "%sc%\%EditorPath%\*.chm" del /F /Q "%sc%\%EditorPath%\*.chm" >nul:
xcopy "..\%sc%\%ssPIPath%\ssPreinstaller*.*" "%sc%\%ssPIPath%\*.*" /y/e/s >nul:
copy "..\%sc%\%ssPIPath%\*.ini" "%sc%\%ssPIPath%" /y >nul:
copy "..\%sc%\%ssPIPath%\ppApp.*" "%sc%\%ssPIPath%" /y >nul:
if exist "%sc%\%ssPIPath%\*.exe" del /F /Q "%sc%\%ssPIPath%\*.exe" >nul:
copy "..\%sc%\SetupS-*.htm" "%sc%" /y >nul:
copy "..\%sc%\SetupS-*.png" "%sc%" /y >nul:
7z a "%devpack%.7z" -ms=on -mx=9 -m0=lzma2 >nul:
copy "%devpack%.7z" "..\*.*" /y >nul:

@REM #######################################################
@REM ### Create Checksums
@REM #######################################################
:Create Checksums (requires: md5sum.exe)
echo Calculating md5 checksums...
cd "%~dp0"
if exist "checksums.md5" del /F /Q "checksums.md5" >nul:
md5sum %ssApp%.exe >>checksums.md5
md5sum %ssApp%.apz >>checksums.md5
md5sum %ppApp%.7z >>checksums.md5
md5sum %ssUI%.exe >>checksums.md5
md5sum %scp%.7z >>checksums.md5
md5sum %devpack%.7z >>checksums.md5
md5sum %ssII%.exe >>checksums.md5
copy "checksums.md5" "checksums_v%ProjectVersion%.md5" /y >nul:
if exist "checksums.md5" del /F /Q "checksums.md5" >nul:

:UploadProject
@REM  now going to lastosftp for new process
goto :LastOSmvftp


@REM echo Upload project? %DoUploads%
@REM echo.
@REM @REM if [%DoUploads%]==[No] goto Cleaning
@REM if [%DoUploads%]==[No] goto Movefiles
@REM cd "%~dp0"
@REM if exist "upload-help.cmd" call upload-help.cmd %sc% ssTek

@REM bintray no longer exists
@REM example of using Bintray and curl
:Bintray (requires cURL)
@REM %AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "bin\GetAccountInfo.au3" "%WebLink3%"
@REM call UploadMe.cmd %ssApp%.exe files SetupS %ProjectVersion%
@REM call UploadMe.cmd %ssApp%.apz files SetupS %ProjectVersion%
@REM call UploadMe.cmd %ppApp%.7z files SetupS %ProjectVersion%
@REM call UploadMe.cmd %ssUI%.exe files SetupS %uploadvergitekfilesProjectVersion%
@@REM call UploadMe.cmd %scp%.7z files SetupS %ProjectVersion%
@REM call UploadMe.cmd %devpack%.7z files SetupS %ProjectVersion%
@REM call UploadMe.cmd %ssII%.exe files SetupS %ProjectVersion%
@REM call UploadMe.cmd checksums_v%ProjectVersion%.md5 files SetupS %ProjectVersion%
@REM echo.

@REM GoogleCode no longer exists
@REM example of using GoogleCode and python
:GoogleCode (requires python)
@REM %AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "bin\GetAccountInfo.au3" "%WebLink4%"
@REM call UploadMe.cmd %ssApp%.exe "SetupS Installer (as a ssApp-EXE package)" Type-Installer,OpSys-Windows
@REM call UploadMe.cmd %ssApp%.apz "SetupS Installer (as an ssApp-APZ package)" Type-Package
@REM call UploadMe.cmd %ppApp%.7z "ssWPI update package" Type-Archive
@REM call UploadMe.cmd %ssUI%.exe "SetupS Uninstaller" Type-Executable,OpSys-Windows
@REM call UploadMe.cmd %scp%.7z "GPLv3 Source Code" Type-Source
@REM call UploadMe.cmd %devpack%.7z "Full Developers Package" Type-Source
@REM call UploadMe.cmd checksums_v%ProjectVersion%.md5 "MD5 checksums"



@REM :lastos.vergitek.com (requires cURL)
@REM %AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "bin\GetAccountInfo.au3" "%WebLink5%"
@REM call UploadMe.cmd update.ini files/ .\ lastos.vergitek.com
@REM call UploadMe.cmd %ssApp%.exe files/ .\ lastos.vergitek.com
@REM call UploadMe.cmd %ssApp%.apz files/ .\ lastos.vergitek.com
@REM call UploadMe.cmd %ppApp%.7z files/ .\ lastos.vergitek.com
@REM call UploadMe.cmd %ssUI%.exe files/ .\ lastos.vergitek.com
@REM call UploadMe.cmd %scp%.7z files/ .\ lastos.vergitek.com
@REM call UploadMe.cmd %devpack%.7z files/ .\ lastos.vergitek.com
@REM call UploadMe.cmd %ssII%.exe files/ .\ lastos.vergitek.com
@REM call UploadMe.cmd checksums_v%ProjectVersion%.md5 files/ .\ lastos.vergitek.com
@REM call UploadMe.cmd ChangeLog.txt files/ .\ lastos.vergitek.com
@REM call UploadMe.cmd SetupS-files.htm files/ .\ lastos.vergitek.com
@REM call UploadMe.cmd SetupS-title.png files/ .\ lastos.vergitek.com
@REM echo.

@REM :LastOSForum (requires cURL)
@REM %AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "bin\GetAccountInfo.au3" "%WebLink2%"
@REM rem call UploadMe.cmd %ssApp%.exe files/ .\ LastOS.org
@REM rem call UploadMe.cmd %ssApp%.apz files/ .\ LastOS.org
@REM rem call UploadMe.cmd %ppApp%.7z files/ .\ LastOS.org
@REM rem call UploadMe.cmd %ssUI%.exe files/ .\ LastOS.org
@REM rem call UploadMe.cmd %scp%.7z files/ .\ LastOS.org
@REM rem call UploadMe.cmd %devpack%.7z files/ .\ LastOS.org
@REM call UploadMe.cmd checksums_v%ProjectVersion%.md5 files/ .\ LastOS.org
@REM call UploadMe.cmd ChangeLog.txt files/ .\ LastOS.org
@REM call UploadMe.cmd SetupS-files.htm files/ .\ LastOS.org
@REM call UploadMe.cmd SetupS-title.png files/ .\ LastOS.org
@REM call UploadMe.cmd update.ini files/ .\ LastOS.org
@REM echo.

@REM #######################################################
@REM ### LastOS ftp create move list
@REM #######################################################

:LastOSmvftp
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
@REM call updfiles.cmd %mvfilesini2%
@REM call movedfilesftp.cmd %mvfilesini2%


@REM #######################################################
@REM ### LastOS ftp upload create list
@REM #######################################################
@REM refer to set filesini2
:LastOSftp
@REM set oldfies = SetupSoldfies
echo creating %filesini2% for upload...
cd "%~dp0"
@REM create files to upload script for winscp useage
@REM ref: https://winscp.net/eng/docs/commandline
@REM https://winscp.net/eng/docs/scripting
@REM To insert comments into the script file, start the line with # (hash):
if exist "%filesini2%" del /F /Q "%filesini2%" >nul:
echo ; connect to ftp server  >>%filesini2%
echo open ftp://%domain2%:#Password#@%ftp2%/%Webfolder2%>>%filesini2%
echo # files to move >>%filesini2%
@REM if file does not exist then mv will fail terminating session
@REM it can be achieved by using ,net assembly refer to ref
@REM ref: https://winscp.net/eng/docs/library_session_fileexists
@REM add list of files to move to oldfies/
@REM echo echo moving files on ftp server
@REM if remote directory does not exist then session will fail and terminate
@REM set oldfies = SetupSoldfies\
@REM echo mkdir %oldfies%/>>%filesini2%

@REM add files for upload
@REM echo echo uploading files
echo ; files to upload >>%filesini2%
echo put .\files\update.ini>>%filesini2%
echo put .\files\%ssApp%.exe>>%filesini2%
echo put .\files\%ssApp%.apz>>%filesini2%
echo put .\files\%ppApp%.7z>>%filesini2%
echo put .\files\%ssUI%.exe>>%filesini2%
echo put .\files\%scp%.7z>>%filesini2%
echo put .\files\%devpack%.7z>>%filesini2%
echo put .\files\%ssII%.exe>>%filesini2%
echo put .\files\checksums_v%ProjectVersion%.md5>>%filesini2%
echo put .\files\ChangeLog.txt>>%filesini2%
echo put .\files\SetupS-files.htm>>%filesini2%
echo put .\files\SetupS-title.png>>%filesini2%
echo exit >>%filesini2%



@REM #######################################################
@REM ### vergitek ftp upload create list %filesini1%
@REM #######################################################
@REM refer to set filesini1
:vergitekftp
echo creating %filesini1% for upload...
cd "%~dp0"
@REM create files to upload script for winscp useage
@REM ref: https://winscp.net/eng/docs/commandline
@REM https://winscp.net/eng/docs/scripting
@REM To insert comments into the script file, start the line with # (hash):
if exist "%filesini1%" del /F /Q "%filesini1%" >nul:
echo ; connect to ftp server  >>%filesini1%
echo open ftp://%domain1%:#Password#@%ftp1%/%Webfolder1%>>%filesini1%
echo ; files to move >>%filesini1%
@REM add list of files to move to oldfies/
@REM if file does not exist then mv will fail terminating session
@REM it can be achieved by using ,net assembly refer to ref
@REM ref: https://winscp.net/eng/docs/library_session_fileexists
@REM add list of files to move to oldfies/



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
@REM allows script to continue if error
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



@REM add files for upload
echo echo uploading files
echo ; files to upload >>%filesini1%
echo put .\files\update.ini>>%filesini1%
echo put .\files\%ssApp%.exe>>%filesini1%
echo put .\files\%ssApp%.apz>>%filesini1%
echo put .\files\%ppApp%.7z>>%filesini1%
echo put .\files\%ssUI%.exe>>%filesini1%
echo put .\files\%scp%.7z>>%filesini1%
echo put .\files\%devpack%.7z>>%filesini1%
echo put .\files\%ssII%.exe>>%filesini1%
echo put .\files\checksums_v%ProjectVersion%.md5>>%filesini1%
echo put .\files\ChangeLog.txt>>%filesini1%
echo put .\files\SetupS-files.htm>>%filesini1%
echo put .\files\SetupS-title.png>>%filesini1%
echo exit >>%filesini1%

@REM pause
@REM call  updfiles.cmd with  %filesini1%
@REM call updfiles.cmd %filesini1%
@REM call updfiles.cmd %filesini2%


@REM #######################################################
@REM ### Movefiles
@REM #######################################################
:Movefiles
echo Moving files to files directory ...
set completedfiles=files

:move files to files directory
@REM echo moving files to files directory..
if exist "%completedfiles%" rd /s /q "%completedfiles%" >nul:
md "%completedfiles%"
echo copying setups files to files directory..
@REM set Upload=Yes
if NOT exist "SetupS-*.htm" echo File not found Change in Make.SetupS-Project.cmd to 'set Upload=Yes'&pause&goto Cleaning
echo copying htm files to files directory..
copy "SetupS-*.htm" "%completedfiles%\" /y >nul:
echo copying SetupS-*.png files to files directory..
copy "%~dp0SetupS-*.png" "%~dp0\%completedfiles%" /y >nul
echo copying .7z files to files directory..
@REM SetupS.Project_v23.07.18.1_DevelopersPack.7z
copy "*.7z" "%completedfiles%\" /y >nul:
echo copying apz files to files directory..
@REM SetupS.SendTo.Suite_v23.07.18.1_ssApp.apz
copy "*.apz" "%completedfiles%\" /y >nul:
echo copying exe files to files directory..
@REM SetupS.SendTo.Suite_v23.07.18.1_ssApp.exe
copy "*.exe" "%completedfiles%\" /y >nul:
echo copying UploadMe.cmd files to files directory..
@REM UploadMe.cmd
copy "UploadMe.cmd" "%completedfiles%\" /y >nul:
@REM update.ini
copy "update.ini" "%completedfiles%\" /y >nul:
echo copying Uchecksums files to files directory..
@REM checksums_v23.07.18.1.md5
copy "checksums*.md5" "%completedfiles%\" /y >nul:
@REM ChangeLog.txt
copy "ChangeLog.txt" "%completedfiles%\" /y >nul:
@REM pause

@REM #######################################################
@REM ### Upload files
@REM #######################################################
:upload files to LastOSForum
if [%DoUploads%]==[No] goto Finish


@REM #######################################################
@REM ### Upload Vergitek files
@REM #######################################################
if [%vergitekUploads%]==[No] goto uploadlastosfiles

echo vergitekUploads = %vergitekUploads%
echo.
@REM pause


:uploadvergitekfiles
@REM :sstek.vergitek.com (requires cURL)
@REM echo #######################################################
@REM echo.
@REM echo Upload Vergitek files
@REM echo.
@REM echo #######################################################
@REM echo #######################################################
@REM echo Start  time
@REM FOR %%A IN (%Date%) DO SET Today=%%A
@REM SET Now=%Time%
@REM ECHO It's %Today%  %Now%
@REM @REM echo  %date%-%time%
@REM echo #######################################################
@REM echo.
@REM echo uploading files to vergitek
@REM echo.
@REM %AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "bin\GetAccountInfo.au3" "%WebLink1%"
@REM call UploadMe.cmd update.ini files/ .\ sstek.vergitek.com
@REM call UploadMe.cmd %ssApp%.exe files/ .\ sstek.vergitek.com
@REM call UploadMe.cmd %ssApp%.apz files/ .\ sstek.vergitek.com
@REM call UploadMe.cmd %ppApp%.7z files/ .\ sstek.vergitek.com
@REM call UploadMe.cmd %ssUI%.exe files/ .\ sstek.vergitek.com
@REM call UploadMe.cmd %scp%.7z files/ .\ sstek.vergitek.com
@REM call UploadMe.cmd %devpack%.7z files/ .\ sstek.vergitek.com
@REM call UploadMe.cmd %ssII%.exe files/ .\ sstek.vergitek.com
@REM call UploadMe.cmd checksums_v%ProjectVersion%.md5 files/ .\ sstek.vergitek.com
@REM call UploadMe.cmd ChangeLog.txt files/ .\ sstek.vergitek.com
@REM call UploadMe.cmd SetupS-files.htm files/ .\ sstek.vergitek.com
@REM call UploadMe.cmd SetupS-title.png files/ .\ sstek.vergitek.com
@REM echo.

echo.

echo===============================================================================
@REM echo moving old files  to /SetupSoldfies/ folder on FTP site
echo Uploading SetupS Project v%ProjectVersion% to  %WebSite1%
  echo===============================================================================
echo.
echo =======================================================
echo Start  time
FOR /F %%A IN ('TIME/T') DO SET Now=%%A
FOR %%A IN (%Date%) DO SET Today=%%A
SET Now=%Time%
ECHO It's %Today%  %Now%
@REM echo  %date%-%time%
echo =======================================================
echo.
@REM this will update the .ini file with the password for ftp
@REM call updfiles.cmd
call updfiles.cmd %filesini1%

@REM move files before upload of new files
call updfiles.cmd %mvfilesini1%
call movedfilesftp.cmd %mvfilesini1%

@REM this will move old  files to  /SetupSoldfies/ then upload the new files using winscp
@REM log file .\WinSCP\winscp.log
@REM call uploadfilesftp.cmd %filesini1%
@REM this will upload the files to the value of  %filesini1%
call uploadfilesftp.cmd %filesini1%

echo.
echo ###########################################mvfilesini1############
echo End time
FOR %%A IN (%Date%) DO SET Today=%%A
SET Now=%Time%
ECHO It's %Today%  %Now%
@REM echo  %date%-%time%
echo #######################################################
echo.

@REM #######################################################
@REM ### Upload files to LastOS
@REM #######################################################
:uploadlastosfiles
if [%LastosUploads%]==[No] goto Finish
echo.
@REM echo #######################################################
@REM echo.
@REM echo Upload LastOS files
@REM echo.
@REM echo #######################################################
@REM echo.
echo =======================================================
echo Start  time
FOR /F %%A IN ('TIME/T') DO SET Now=%%A
FOR %%A IN (%Date%) DO SET Today=%%A
SET Now=%Time%
ECHO It's %Today%  %Now%
@REM echo  %date%-%time%
echo =======================================================
echo.
  echo ===============================================================================
  echo moving old files  to /SetupSoldfies/ folder on FTP site
echo Uploading SetupS Project v%ProjectVersion% to %WebSite2%
  echo ===============================================================================
echo.
@REM this will update the %filesini2% with the password for ftp
@REM call updfiles.cmd %filesini2%
call updfiles.cmd %filesini2%

@REM this will update the %mvfilesini2% with the password for ftp
call updfiles.cmd %mvfilesini2%
@REM this will move old files to  /SetupSoldfies/ using winscp
@REM move files before uploading new files
call movedfilesftp.cmd %mvfilesini2%

@REM log file .\WinSCP\winscp.log
@REM this will upload the files to the value of %filesini2%
call uploadfilesftp.cmd  %filesini2%
echo.
echo =======================================================
echo End time
FOR %%A IN (%Date%) DO SET Today=%%A
SET Now=%Time%
ECHO It's %Today%  %Now%
@REM echo  %date%-%time%
echo =======================================================
echo.

@REM #######################################################
@REM ### Finish
@REM #######################################################
:Finish

@REM #######################################################
@REM ### Cleaning
@REM #######################################################
:Cleaning
echo #######################################################
echo Cleaning up...
echo.
echo  Deleting compilied files after upload
echo #######################################################
cd "%~dp0"
:Deleting files
@REM echo deleting SetupS-*.htm
if exist "SetupS-*.htm" del /F /Q "SetupS-*.htm" >nul:
@REM echo deleting SetupS-*.png
if exist "SetupS-*.png" del /F /Q "SetupS-*.png" >nul:
@REM echo deleting 7z
if exist "*.7z" del /F /Q "*.7z" >nul:
@REM echo deleting apz
if exist "*.apz" del /F /Q "*.apz" >nul:
@REM echo deleting exe
if exist "*.exe" del /F /Q "*.exe" >nul:
@REM echo deleting UploadMe.cmd
if exist "UploadMe.cmd" del /F /Q "UploadMe.cmd" >nul:
@REM echo deleting update.ini
if exist "update.ini" del /F /Q "update.ini" >nul:
@REM echo deleting checksums
if exist "checksums*.md5" del /F /Q "checksums*.md5" >nul:

echo  #######################################################
echo   ### Final cleanup
echo #######################################################
%AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "bin\GetAccountInfo.au3" "Kill"
if exist "%ssApp%" rd /s /q "%ssApp%" >nul:
if exist "%ppApp%" rd /s /q "%ppApp%" >nul:
if exist "%scp%" rd /s /q "%scp%" >nul:
if exist "%devpack%" rd /s /q "%devpack%" >nul:
if exist "%ssUI%" rd /s /q "%ssUI%" >nul:
rem if exist "%ssII%.exe" del /F /Q "%ssII%.exe" >nul:
if exist "%~dp0%sc%\ssTek.chm" del /F /Q "%~dp0%sc%\ssTek.chm" >nul:
if exist "%~dp0%sc%\ssTek.html" del /F /Q "%~dp0%sc%\ssTek.html" >nul:
if exist "%~dp0%sc%\files" rd /s /q "%~dp0%sc%\files" >nul:
if exist "%~dp0%sc%\%EditorPath%\ssEditor.html" del /F /Q "%~dp0%sc%\%EditorPath%\ssEditor.html" >nul:
if exist "%~dp0%sc%\%EditorPath%\files" rd /s /q "%~dp0%sc%\%EditorPath%\files" >nul:
if exist "%sc%\originals" echo Originals already exists!

@REM Echo %_fRed%%_bBlack% error
@REM Echo %_RESET%
@REM Echo %_fBGreen%%_bBlack%
@REM echo working
@REM Echo %_fYellow%%_bBlue%
@REM echo finished
@REM @REM Echo %_RESET%
@REM Echo %_fBGreen%%_bBlack%
Echo %_bBWhite%%_bBlue% ####################################################### %_fBGreen%%_bBlack%
echo.
echo SetupS Project v%ProjectVersion% ... Done!
echo.
Echo %_bBWhite%%_bBlue%#######################################################%_fBGreen%%_bBlack%
echo.
:Quit
Echo %_fBGreen%%_bBlack%
