#NoTrayIcon
#region
#AutoIt3Wrapper_Icon=SetupS.ico
#AutoIt3Wrapper_Outfile=Tools\ssRegenerator.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=SetupS Regenerator. Process all your ssApps, ppApps, & ppGames on all your drives.
#AutoIt3Wrapper_Res_Fileversion=#ProjectVersion#
#AutoIt3Wrapper_Res_LegalCopyright=©#cYear#, #cHolder#
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_Field=Release Date|#ProjectDate#
#AutoIt3Wrapper_Res_Field=#WebSite1#|http://#WebLink1#
#AutoIt3Wrapper_Res_Field=#WebSite2#|http://#WebLink2#
#AutoIt3Wrapper_Res_Field=#WebSite3#|http://#WebLink3#
#AutoIt3Wrapper_Au3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/pr=1 /uv=3 /tc=0 /sf /reel /refc /rerc /kv=100
#AutoIt3Wrapper_UseX64=n
#endregion

#cs ##################################################################################

	SetupS Regenerator (ssRegenerator) v#ProjectVersion#
	Copyright © #cYear#, #cHolder#
	All rights reserved.

	This file is part of the SetupS SendTo Suite.

	The SetupS SendTo Suite is open-source software: you can redistribute it and/or
	modify it under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your option)
	any later version of the License.

	DISCLAIMER:
	The SetupS SendTo Suite is distributed in the hope that it will be useful, but is
	provided by #cHolder# "AS IS", without warranty of any kind, express or
	implied, including but not limited to the warranties of MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE, TITLE and NON-INFRINGEMENT. In no event shall
	the authors or #cHolder# be liable for any direct, indirect, incidental, special,
	exemplary, or consequential damages (including, but not limited to, procurement of
	substitute goods or services; loss of use, data, or profits; or business
	interruption) however caused and on any theory of liability, whether in an action
	of contract, strict liability, or tort (including negligence or otherwise) arising
	from, out of or in connection with the software or the use or other dealings in the
	software, even if advised of the possibility of such damage.

	See the GNU General Public License for more details. You should have received a
	copy of the GNU General Public License along with the SetupS SendTo Suite. If not,
	see <http://www.gnu.org/licenses/>.

#ce ##################################################################################
#cs ##################################################################################

	Script Function:
	SetupS process all Apps and ppGames on all drives such as creating StartMenu
	Shortcuts using the chosen StartMenu layout (Kazz/ssTek/Default)...

#ce ##################################################################################
#include <SetupS.Core.au3>

;------------------------------------------------------ Debug & Testing -----------------------------------------------------------
If Not @Compiled Then
	If $CLIparameters[0] = 0 Then
		;Some examples of how to use this:

		$CLIparameters[0] += 1
		ReDim $CLIparameters[$CLIparameters[0] + 1]
		$CLIparameters[$CLIparameters[0]] = '-ppGames' ;'--ppApps' ;'--ppGames' ;'--ssApps' ; AppType

;~ 		$CLIparameters[0] += 1
;~ 		ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 		$CLIparameters[$CLIparameters[0]] = '-ppGames' ;'--ppApps' ;'--ppGames' ;'--ssApps' ; AppType

;~ 		$CLIparameters[0] += 1
;~ 		ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 		$CLIparameters[$CLIparameters[0]] = '--TrayOnly' ;'--Mute' ;'--TrayOnly' ; Switches
;~ 		$CLIparameters[$CLIparameters[0]] = '--ppAppsDriveMove=D:' ;(internal use only)
;~ 		$CLIparameters[$CLIparameters[0]] = '-ssAppsShortcutsSkip'
;~ 		$CLIparameters[$CLIparameters[0]] = '-FaderInstallsOnly=No'
;~ 		$CLIparameters[$CLIparameters[0]] = '-Help'

	EndIf
EndIf

;------------------------------------------------------ Declarations -------------------------------------------------------------
SetThisApp() ; Sets $ThisAppTitle, $ThisAppVersion, & $ThisAppFilename; plus DualArch
Global $Timer1, $ssConfigINI = CheckINI('ssConfig.ini')
;~ If $MakeDefaultINI Then SetSetupSOptions($ssConfigINI)
Local $SplashTemp, $Drives[1]
$HelpFile = FindMe('ssTek.chm')

;----------------------------------------------------- Get Parameters ------------------------------------------------------------
GetSetupSOptions($ssConfigINI)
GetReportingMode($ssConfigINI)
If $Debug Then _ConsoleWrite('@@ Debug Start (' & @ScriptName & ') : ' & _NowCalc(), True) ; set 2nd arg = True to start a new file
If $BalloonTips Then
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', '2')
	Opt('TrayIconHide', 0) ;Show tray icon
	Opt('TrayAutoPause', 0) ;Turn off autopause
	_TrayTip($ThisAppTitle, 'Initializing...', 300, 16)
	_ShowTray() ;AdlibRegister('_ShowTray', 5000)
Else
	;RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', '0')
	Opt('TrayIconHide', 1) ;Hide tray icon
EndIf
If $SplashTips Then SplashThis($ThisAppFilename, 'Initializing...')
;~ If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Initializing...' & @CRLF, True)
GetFaderMode($ssConfigINI)
GetRegeneratorMode($ssConfigINI)
GetScMode($ssConfigINI)
If GetParameter('Help') Or GetParameter('?') Or GetParameter('About') Then EndGame('Help requested', 'See displayed', True)

;------------------------------------------------------ Get System Info ----------------------------------------------------------
GetppDrives()
GetMenuStyle()

;------------------------------------------------------ Begin -------------------------------------------------------------
FileChangeDir(@ScriptDir)
;Timer($Timer1)
Local $Do_ppApps = GetParameter('ppApps'), $Do_ppGames = GetParameter('ppGames'), $Do_ssApps = GetParameter('ssApps') Or GetParameter('SetupS')
If Not ($Do_ppApps Or $Do_ppGames Or $Do_ssApps) Then
	$Do_ssApps = True
	$Do_ppApps = True
	$Do_ppGames = True
EndIf
If $Do_ssApps Then ssGenerator()
If $Do_ppApps Then ppGenerator('ppApps')
If $Do_ppGames Then ppGenerator('ppGames')
If $ssCleaner > 0 Then
	If $ssCleaner = 2 Then ;All
		If $BalloonTips Then _TrayTip('Cleaning', 'All dud shortcuts...', 300, 16)
		If $SplashTips Then
			SplashThis('Cleaning', 'All dud shortcuts...')
			$SplashTips = False
		EndIf
		ssCleaner(@StartMenuCommonDir) ; All Users Start Menu
		ssCleaner(@StartMenuDir) ; Current User Start Menu
		ssCleaner(@DesktopCommonDir) ; All Users Desktop
		ssCleaner(@DesktopDir) ; Current User Desktop
		ssCleaner(EnvGet('ALLUSERSPROFILE') & '\SendTo'); All Users Sendto
		ssCleaner(@UserProfileDir & '\SendTo') ; Current User Sendto
		ssCleaner(@AppDataDir & '\Microsoft\Internet Explorer\Quick Launch') ; QuickLaunch
	Else ;Startmenu only
		If $BalloonTips Then _TrayTip('Cleaning', 'StartMenu dud shortcuts', 300, 16)
		If $SplashTips Then
			SplashThis('Cleaning', 'StartMenu dud shortcuts')
			$SplashTips = False
		EndIf
		ssCleaner(@StartMenuCommonDir) ; All Users Start Menu
		ssCleaner(@StartMenuDir) ; Current User Start Menu
	EndIf
	If $KeepStartMenuFolders Then CopyMenu($MenuStyle)
EndIf
If $ssCleanerDeleteUninstalled Then
	If $Do_ssApps Then
		DeleteUninstalled(@ProgramFilesDir)
		If StringInStr(@CommonFilesDir, @ProgramFilesDir) <> 1 Then DeleteUninstalled(@CommonFilesDir); In case not a subdir
		If $OSArch64 And $ProgramFilesDir32 Then
			DeleteUninstalled(EnvGet('ProgramFiles(x86)'))
			If StringInStr(EnvGet('COMMONPROGRAMFILES(x86)'), EnvGet('ProgramFiles(x86)')) <> 1 Then DeleteUninstalled(EnvGet('COMMONPROGRAMFILES(x86)')); In case not a subdir
		EndIf
		DeleteUninstalled(@WindowsDir)
		If StringInStr(@SystemDir, @WindowsDir) <> 1 Then DeleteUninstalled(@SystemDir); In case not a subdir
	EndIf
	If $Do_ppApps Then
		DeleteUninstalled($ppAppsDrive & '\ppApps')
	EndIf
	If $Do_ppGames Then
		DeleteUninstalled($ppGamesDrive & '\ppGames')
	EndIf
EndIf
;Timer($Timer1, 'Post-processing done!', True)
EndGame('SetupS Regenerator', 'Done!')

#region ;########################################## FUNCTIONS BELOW #############################################################

Func ppGenerator($ppType)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|ppGenerator(): $ppType=' & $ppType & @CRLF)
	Local $Drive, $Init;, $ppDriveMove = ''
	;If $ppAppsDriveMove Then $ppDriveMove = $ppDriveMove & ' --ppAppsDriveMove=' & $ppAppsDriveMove
	;If $ppGamesDriveMove Then $ppDriveMove = $ppDriveMove & ' --ppGamesDriveMove=' & $ppGamesDriveMove
	Select
		Case $RegenAllDrives ;Get All Drives with a ppFolder
			If IsArray($AllDrivesList) Then
				For $Drive = 1 To $AllDrivesList[0]
					Process_ppDrive($AllDrivesList[$Drive], $ppType)
				Next
			EndIf
		Case $ppType = 'ppApps'
			Process_ppDrive($ppAppsDrive, $ppType)
		Case $ppType = 'ppGames'
			Process_ppDrive($ppGamesDrive, $ppType)
	EndSelect
	;_ArrayDisplay($Drives, $ppType & ' $Drives')
	For $Drive = 1 To $Drives[0] - 1
		$Init = $Init & $Drives[$Drives] & ', '
	Next
	$Init = $Init & $Drives[$Drives[0]]
	If $BalloonTips Then _TrayTip($ThisAppTitle, $ppType & ' Drives found = ' & $Init, 300, 16)
	If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & $ppType & ' Drives found = ' & $Init & @CRLF)
EndFunc

Func Process_ppDrive($ppDrive, $ppType) ; External SetupS.exe method
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Process_ppDrive(): $ppDrive=' & $ppDrive & ' : $ppType = ' & $ppType & @CRLF)
	;No recursion required since ppApps & ppGames are always on one level
	Local $i, $Found, $ppDriveMove = '';, $FileList
	;ErrorProtection('off')
	$Found = FileExists($ppDrive & '\' & $ppType)
	;ErrorProtection('on')
	If $Found Then
		$Drives[0] += 1
		ReDim $Drives[$Drives[0] + 1]
		$Drives[$Drives[0]] = $ppDrive
		If $SplashTips Then
			$i = ' -SplashOnly'
		Else
			$i = ' -Mute'
		EndIf
		If $FaderInstallsOnly Then $i = $i & ' -Fadertainer=Off'
		$i = $i & ' -Regen'
		If $ppAppsDriveMove Then $ppDriveMove = $ppDriveMove & ' -ppAppsDriveMove=' & $ppAppsDriveMove
		If $ppGamesDriveMove Then $ppDriveMove = $ppDriveMove & ' -ppGamesDriveMove=' & $ppGamesDriveMove
		If $BalloonTips Then _TrayTip('Processing', $ppType & ' on Drive ' & StringUpper($ppDrive), 300, 16)
		If $SplashTips Then SplashOff()
		If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Processing ' & $ppType & ' on Drive ' & StringUpper($ppDrive) & @CRLF)
		RunWait($SetupS & ' "' & StringUpper($ppDrive) & '\' & $ppType & '"' & $i & $ppDriveMove & ' -ssClean=off')
	EndIf
EndFunc

Func Process_ssDir($ssDir) ; External SetupS.exe method
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Process_ssDir(): $ssDir = ' & $ssDir & @CRLF)
	Local $i, $Found
	;ErrorProtection('off')
	$Found = FileExists($ssDir)
	;ErrorProtection('on')
	If $Found Then
		If $SplashTips Then
			$i = ' -SplashOnly'
		Else
			$i = ' -Mute'
		EndIf
		If $FaderInstallsOnly Then $i = $i & ' -Fadertainer=Off'
		$i = $i & ' -Regen'
		If $SplashTips Then SplashOff()
		RunWait($SetupS & ' "' & $ssDir & '"' & $i & ' -ssClean=off')
	EndIf
EndFunc

Func ssGenerator()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|ssGenerator()' & @CRLF)
	If $BalloonTips Then _TrayTip($ThisAppTitle, 'Processing ssApps', 300, 16)
	If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Processing ssApps' & @CRLF)
	Process_ssDir(@ProgramFilesDir)
	If Not StringInStr(@CommonFilesDir, @ProgramFilesDir) Then Process_ssDir(@CommonFilesDir); In case not a subdir
	If $OSArch64 And $ProgramFilesDir32 Then
		Process_ssDir(EnvGet('ProgramFiles(x86)'))
		If StringInStr(EnvGet('COMMONPROGRAMFILES(x86)'), EnvGet('ProgramFiles(x86)')) = 0 Then Process_ssDir(EnvGet('COMMONPROGRAMFILES(x86)')); In case not a subdir
	EndIf
	Process_ssDir(@WindowsDir)
	If Not StringInStr(@SystemDir, @WindowsDir) Then Process_ssDir(@SystemDir); In case not a subdir
EndFunc
#endregion
