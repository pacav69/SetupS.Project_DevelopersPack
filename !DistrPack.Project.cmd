:This script creates dual architecture (x86|x64) distribution packages. Does NOT require an x64-machine to run.
:Assumes the following are installed: "AutoIt3" (plus SciTE), and "Inno Setup". Plus, "HelpNDoc" (v2 only) and "Microsoft's HTML Help Workshop" should be installed in order to update the help-files.
:The following folders also need to be present: bin, sfx, and curl.
:7zip.exe will be required but is already included in the Tools folder.

@echo off
call !RestoreOriginals.cmd

:getVer
if [%1]==[] goto setVer
set ProjectVersion=%1
goto getDate

:setVer
@REM ProjectVersion= YY.MM.DD.0 ONLY numbers
@REM seperated with periods in the form XX.XX.XX.XX
@REM use the date of compilatation YY.MM.DD.Incremental number usually 0
set ProjectVersion=13.11.23.0
goto getDate

:getDate
if [%2]==[] goto setDate
set ProjectDate=%2
goto getDoUploads

:setDate
@REM ProjectDate=YY-MM-DD ONLY numbers
@REM use the date of compilatation YY-MM-DD
@REM use the date of compilatation YY-MM-DD seperated by a '-'
set ProjectDate=23-07-17
goto getDoUploads

:getDoUploads
if [%3]==[] goto setDoUploads
set DoUploads=%3
goto setText

:setDoUploads
set DoUploads=No
goto setText

:setText
set cYear=2017-2023
set cHolder=Vergitek Solutions
set WebSite1=ssTek Forum
set WebLink1=sstek.vergitek.com
set WebSite2=LastOS Team
set WebLink2=www.lastos.org
set WebSite3=ssTek Distribution
set WebLink3=dl.bintray.com/sstek
set WebSite4=ssTek Development
set WebLink4=sstek.vergitek.com
set WebSite5=LastOS Forum
set WebLink5=lastos.vergitek.com
set WebSite6=github files
set WebLink6=github.com/pacav69/SetupS.Project_DevelopersPack
set NewTagLine=%Website1%: Tools for custom Operating Systems!
set CoreVersion=%ProjectVersion%
set ssEditorVersion=%ProjectVersion%
goto Begin

:Begin
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
echo Backing up originals...
cd "%~dp0"
if exist "%sc%\originals" goto exit
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

::ProjectDate
fart -q -i "%sc%\*.au3" "#ProjectDate#" "%ProjectDate%" >nul:
fart -q -i "%sc%\*.iss" "#ProjectDate#" "%ProjectDate%" >nul:
fart -q -i "%sc%\*.app" "#ProjectDate#" "%ProjectDate%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#ProjectDate#" "%ProjectDate%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#ProjectDate#" "%ProjectDate%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#ProjectDate#" "%ProjectDate%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#ProjectDate#" "%ProjectDate%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#ProjectDate#" "%ProjectDate%" >nul:

::cYear
fart -q -i "%sc%\*.au3" "#cYear#" "%cYear%" >nul:
fart -q -i "%sc%\*.iss" "#cYear#" "%cYear%" >nul:
fart -q -i "%sc%\*.app" "#cYear#" "%cYear%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#cYear#" "%cYear%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#cYear#" "%cYear%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#cYear#" "%cYear%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#cYear#" "%cYear%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#cYear#" "%cYear%" >nul:

::cHolder
fart -q -i "%sc%\*.au3" "#cHolder#" "%cHolder%" >nul:
fart -q -i "%sc%\*.iss" "#cHolder#" "%cHolder%" >nul:
fart -q -i "%sc%\*.app" "#cHolder#" "%cHolder%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#cHolder#" "%cHolder%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#cHolder#" "%cHolder%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#cHolder#" "%cHolder%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#cHolder#" "%cHolder%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#cHolder#" "%cHolder%" >nul:

::WebSite1
fart -q -i "%sc%\*.au3" "#WebSite1#" "%WebSite1%" >nul:
fart -q -i "%sc%\*.iss" "#WebSite1#" "%WebSite1%" >nul:
fart -q -i "%sc%\*.app" "#WebSite1#" "%WebSite1%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#WebSite1#" "%WebSite1%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#WebSite1#" "%WebSite1%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#WebSite1#" "%WebSite1%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#WebSite1#" "%WebSite1%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#WebSite1#" "%WebSite1%" >nul:

::WebLink1
fart -q -i "%sc%\*.au3" "#WebLink1#" "%WebLink1%" >nul:
fart -q -i "%sc%\*.iss" "#WebLink1#" "%WebLink1%" >nul:
fart -q -i "%sc%\*.app" "#WebLink1#" "%WebLink1%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#WebLink1#" "%WebLink1%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#WebLink1#" "%WebLink1%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#WebLink1#" "%WebLink1%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#WebLink1#" "%WebLink1%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#WebLink1#" "%WebLink1%" >nul:

::WebSite2
fart -q -i "%sc%\*.au3" "#WebSite2#" "%WebSite2%" >nul:
fart -q -i "%sc%\*.iss" "#WebSite2#" "%WebSite2%" >nul:
fart -q -i "%sc%\*.app" "#WebSite2#" "%WebSite2%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#WebSite2#" "%WebSite2%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#WebSite2#" "%WebSite2%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#WebSite2#" "%WebSite2%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#WebSite2#" "%WebSite2%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#WebSite2#" "%WebSite2%" >nul:

::WebLink2
fart -q -i "%sc%\*.au3" "#WebLink2#" "%WebLink2%" >nul:
fart -q -i "%sc%\*.iss" "#WebLink2#" "%WebLink2%" >nul:
fart -q -i "%sc%\*.app" "#WebLink2#" "%WebLink2%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#WebLink2#" "%WebLink2%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#WebLink2#" "%WebLink2%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#WebLink2#" "%WebLink2%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#WebLink2#" "%WebLink2%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#WebLink2#" "%WebLink2%" >nul:

::WebSite3
fart -q -i "%sc%\*.au3" "#WebSite3#" "%WebSite3%" >nul:
fart -q -i "%sc%\*.iss" "#WebSite3#" "%WebSite3%" >nul:
fart -q -i "%sc%\*.app" "#WebSite3#" "%WebSite3%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#WebSite3#" "%WebSite3%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#WebSite3#" "%WebSite3%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#WebSite3#" "%WebSite3%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#WebSite3#" "%WebSite3%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#WebSite3#" "%WebSite3%" >nul:

::WebLink3
fart -q -i "%sc%\*.au3" "#WebLink3#" "%WebLink3%" >nul:
fart -q -i "%sc%\*.iss" "#WebLink3#" "%WebLink3%" >nul:
fart -q -i "%sc%\*.app" "#WebLink3#" "%WebLink3%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#WebLink3#" "%WebLink3%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#WebLink3#" "%WebLink3%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#WebLink3#" "%WebLink3%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#WebLink3#" "%WebLink3%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#WebLink3#" "%WebLink3%" >nul:


::WebSite4
fart -q -i "%sc%\*.au3" "#WebSite4#" "%WebSite4%" >nul:
fart -q -i "%sc%\*.iss" "#WebSite4#" "%WebSite4%" >nul:
fart -q -i "%sc%\*.app" "#WebSite4#" "%WebSite4%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#WebSite4#" "%WebSite4%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#WebSite4#" "%WebSite4%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#WebSite4#" "%WebSite4%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#WebSite4#" "%WebSite4%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#WebSite4#" "%WebSite4%" >nul:

::WebLink4
fart -q -i "%sc%\*.au3" "#WebLink4#" "%WebLink4%" >nul:
fart -q -i "%sc%\*.iss" "#WebLink4#" "%WebLink4%" >nul:
fart -q -i "%sc%\*.app" "#WebLink4#" "%WebLink4%" >nul:
fart -q -i "%sc%\%EditorPath%\*.au3" "#WebLink4#" "%WebLink4%" >nul:
fart -q -i "%sc%\%EditorPath%\*.app" "#WebLink4#" "%WebLink4%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.au3" "#WebLink4#" "%WebLink4%" >nul:
fart -q -i "%sc%\%ssPIPath%\*.ini" "#WebLink4#" "%WebLink4%" >nul:
fart -q -i "%sc%\SetupS-*.htm" "#WebLink4#" "%WebLink4%" >nul:

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

:ssPreinstaller
cd "%ssPIPath%"
call Compile.AutoIt.Script.cmd ssPreinstaller
cd ".."

:ssEditor
cd "%EditorPath%"
call Compile.AutoIt.Script.cmd %EditorPath%

:MakeHelpFiles
set UpdateHelpPath=%~dp0%sc%
set UpdateHelpFile=ssTek

:UpdateHelpFile
echo Updating the help-file for %UpdateHelpFile%...
cd "%UpdateHelpPath%"
if exist "%UpdateHelpFile%.html" del /F /Q "%UpdateHelpFile%.html" >nul:
if exist "files" rd /s /q "files" >nul:
cd "%~dp0%bin"
%AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript CompileHND.au3 "%UpdateHelpPath%" "%UpdateHelpFile%"
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

:CopyHelpFiles
cd "%~dp0%sc%"
if exist "ssTek.chm" copy "ssTek.chm" "Tools\ssTek.chm" /y >nul:

:CreatessEditorppApp
cd "%~dp0%sc%\%EditorPath%"
call "Create.ppApp.package.cmd" %EditorPath%

:Create Inno Installer (requires: Inno Setup)
echo Compiling the InnoSetup Installer package...
cd "%~dp0%sc%"
set ssII=Install.SetupS_v%ProjectVersion%
set InnoCompiler="%ProgramFiles%\Inno Setup 5\compil32.exe"
if exist "%ProgramFiles(x86)%\Inno Setup 5\compil32.exe" set InnoCompiler="%ProgramFiles(x86)%\Inno Setup 5\compil32.exe"
%InnoCompiler% /cc "SetupS.iss"
copy "Inno.Output\%ssII%.exe" "..\*.*" /y >nul:
if exist "Inno.Output\%ssII%.exe" del /F /Q "Inno.Output\%ssII%.exe" >nul:

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
echo Upload project? %DoUploads%
echo.
if [%DoUploads%]==[No] goto Exit
cd "%~dp0"
if exist "upload-help.cmd" call upload-help.cmd %sc% ssTek

:Bintray (requires cURL)
%AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "bin\GetAccountInfo.au3" "%WebLink3%"
call UploadMe.cmd %ssApp%.exe files SetupS %ProjectVersion%
call UploadMe.cmd %ssApp%.apz files SetupS %ProjectVersion%
call UploadMe.cmd %ppApp%.7z files SetupS %ProjectVersion%
call UploadMe.cmd %ssUI%.exe files SetupS %ProjectVersion%
call UploadMe.cmd %scp%.7z files SetupS %ProjectVersion%
call UploadMe.cmd %devpack%.7z files SetupS %ProjectVersion%
call UploadMe.cmd %ssII%.exe files SetupS %ProjectVersion%
call UploadMe.cmd checksums_v%ProjectVersion%.md5 files SetupS %ProjectVersion%
echo.

:GoogleCode (requires python)
rem %AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "bin\GetAccountInfo.au3" "%WebLink4%"
rem call UploadMe.cmd %ssApp%.exe "SetupS Installer (as a ssApp-EXE package)" Type-Installer,OpSys-Windows
rem call UploadMe.cmd %ssApp%.apz "SetupS Installer (as an ssApp-APZ package)" Type-Package
rem call UploadMe.cmd %ppApp%.7z "ssWPI update package" Type-Archive
rem call UploadMe.cmd %ssUI%.exe "SetupS Uninstaller" Type-Executable,OpSys-Windows
rem call UploadMe.cmd %scp%.7z "GPLv3 Source Code" Type-Source
rem call UploadMe.cmd %devpack%.7z "Full Developers Package" Type-Source
rem call UploadMe.cmd checksums_v%ProjectVersion%.md5 "MD5 checksums"

:sstek.vergitek.com (requires cURL)
%AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "bin\GetAccountInfo.au3" "%WebLink1%"
call UploadMe.cmd update.ini files/ .\ sstek.vergitek.com
call UploadMe.cmd %ssApp%.exe files/ .\ sstek.vergitek.com
call UploadMe.cmd %ssApp%.apz files/ .\ sstek.vergitek.com
call UploadMe.cmd %ppApp%.7z files/ .\ sstek.vergitek.com
call UploadMe.cmd %ssUI%.exe files/ .\ sstek.vergitek.com
call UploadMe.cmd %scp%.7z files/ .\ sstek.vergitek.com
call UploadMe.cmd %devpack%.7z files/ .\ sstek.vergitek.com
call UploadMe.cmd %ssII%.exe files/ .\ sstek.vergitek.com
call UploadMe.cmd checksums_v%ProjectVersion%.md5 files/ .\ sstek.vergitek.com
call UploadMe.cmd ChangeLog.txt files/ .\ sstek.vergitek.com
call UploadMe.cmd SetupS-files.htm files/ .\ sstek.vergitek.com
call UploadMe.cmd SetupS-title.png files/ .\ sstek.vergitek.com
echo.

:lastos.vergitek.com (requires cURL)
%AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "bin\GetAccountInfo.au3" "%WebLink5%"
call UploadMe.cmd update.ini files/ .\ lastos.vergitek.com
call UploadMe.cmd %ssApp%.exe files/ .\ lastos.vergitek.com
call UploadMe.cmd %ssApp%.apz files/ .\ lastos.vergitek.com
call UploadMe.cmd %ppApp%.7z files/ .\ lastos.vergitek.com
call UploadMe.cmd %ssUI%.exe files/ .\ lastos.vergitek.com
call UploadMe.cmd %scp%.7z files/ .\ lastos.vergitek.com
call UploadMe.cmd %devpack%.7z files/ .\ lastos.vergitek.com
call UploadMe.cmd %ssII%.exe files/ .\ lastos.vergitek.com
call UploadMe.cmd checksums_v%ProjectVersion%.md5 files/ .\ lastos.vergitek.com
call UploadMe.cmd ChangeLog.txt files/ .\ lastos.vergitek.com
call UploadMe.cmd SetupS-files.htm files/ .\ lastos.vergitek.com
call UploadMe.cmd SetupS-title.png files/ .\ lastos.vergitek.com
echo.

:LastOSForum (requires cURL)
%AutoIt3% /ErrorStdOut /AutoIt3ExecuteScript "bin\GetAccountInfo.au3" "%WebLink2%"
rem call UploadMe.cmd %ssApp%.exe files/ .\ LastOS.org
rem call UploadMe.cmd %ssApp%.apz files/ .\ LastOS.org
rem call UploadMe.cmd %ppApp%.7z files/ .\ LastOS.org
rem call UploadMe.cmd %ssUI%.exe files/ .\ LastOS.org
rem call UploadMe.cmd %scp%.7z files/ .\ LastOS.org
rem call UploadMe.cmd %devpack%.7z files/ .\ LastOS.org
call UploadMe.cmd checksums_v%ProjectVersion%.md5 files/ .\ LastOS.org
call UploadMe.cmd ChangeLog.txt files/ .\ LastOS.org
call UploadMe.cmd SetupS-files.htm files/ .\ LastOS.org
call UploadMe.cmd SetupS-title.png files/ .\ LastOS.org
call UploadMe.cmd update.ini files/ .\ LastOS.org
echo.


:Movefiles
echo Begin ... SetupS Project (version: %ProjectVersion%)
echo Moving files to files directory
set completedfiles=files
set EditorPath=ssEditor
set ssPIPath=ssPreinstaller
set path=%path%;%~dp0bin;%~dp0%completedfiles%\Tools;%~dp0%completedfiles%\Tools\_x86
cd "%~dp0"
if exist "%completedfiles%\default.ini" xcopy "%completedfiles%\default.ini\*.*" "%completedfiles%\*.*" /y/e/s >nul:
if exist "%completedfiles%\%EditorPath%\default.ini" xcopy "%completedfiles%\%EditorPath%\default.ini\*.*" "%completedfiles%\%EditorPath%\*.*" /y/e/s >nul:

:move files to files directory
echo oving files to files directory..
cd "%~dp0"
if exist "%completedfiles%\files" goto exit
md "%completedfiles%\files\%EditorPath%"
md "%completedfiles%\files\%ssPIPath%"
copy "%completedfiles%\*.au3" "%completedfiles%\files" /y >nul:
copy "%completedfiles%\*.iss" "%completedfiles%\files" /y >nul:
copy "%completedfiles%\*.app" "%completedfiles%\files" /y >nul:
copy "%completedfiles%\%EditorPath%\*.au3" "%completedfiles%\files\%EditorPath%" /y >nul:
copy "%completedfiles%\%EditorPath%\*.app" "%completedfiles%\files\%EditorPath%" /y >nul:
copy "%completedfiles%\%ssPIPath%\*.au3" "%completedfiles%\files\%ssPIPath%" /y >nul:
copy "%completedfiles%\%ssPIPath%\*.ini" "%completedfiles%\files\%ssPIPath%" /y >nul:
copy "%completedfiles%\SetupS-*.htm" "%completedfiles%\files" /y >nul:


:Exit
echo Cleaning up...
cd "%~dp0"
%AutoIt3% /ErrorStdOut /AutoIt3Executecompletedfilesript "bin\GetAccountInfo.au3" "Kill"
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
echo.
echo SetupS Project v%ProjectVersion% ... Done!
echo.