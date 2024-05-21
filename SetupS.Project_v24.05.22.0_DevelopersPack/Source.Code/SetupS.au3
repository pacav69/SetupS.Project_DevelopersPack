#NoTrayIcon
#region
#AutoIt3Wrapper_Icon=ssApp.ico
#AutoIt3Wrapper_Outfile=Tools\SetupS.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=SetupS(ilently) Installer
#AutoIt3Wrapper_Res_Fileversion=#ProjectVersion#
#AutoIt3Wrapper_Res_LegalCopyright=©#cYear#, #cHolder#
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_Field=Release Date|#ProjectDate#
#AutoIt3Wrapper_Res_Field=#WebSite1#|http://#WebLink1#
#AutoIt3Wrapper_Res_Field=#WebSite2#|http://#WebLink2#
#AutoIt3Wrapper_Res_Field=#WebSite3#|http://#WebLink3#
#AutoIt3Wrapper_Res_Field=Original Concept|Glenn L. Chugg (ReturnOfNights)
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/pr=1 /uv=3 /tc=0 /sf /reel /refc /rerc /kv=100
#AutoIt3Wrapper_UseX64=y
#endregion

#cs ##################################################################################

	SetupS SendTo Extension v#ProjectVersion#
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
	Allows for easy and automated installing of SetupS apps such as ssApp's, ppApp's,
	or ppGame's. Simply right-click on an archive or the entire folder and SendTo
	'SetupS' or double-click on the '.app' or '.ppg' file (or, right-click
	'Open with' SetupS)

#ce ##################################################################################
#include <SetupS.Core.au3>

;------------------------------------------------------ Debug & Testing -----------------------------------------------------------
If Not @Compiled And Not GetParameter('Test') Then
	If $CLIparameters[0] = 0 Then
		;Some examples of how to use this:
		$CLIparameters[0] += 1
		ReDim $CLIparameters[$CLIparameters[0] + 1]
		$CLIparameters[$CLIparameters[0]] = 'D:\ssTEK.Projects' ;test folder
;~ 		$CLIparameters[$CLIparameters[0]] = 'D:\ssInstalls\AIMP_v3.60_ssApp' ;test folder
;~ 		$CLIparameters[$CLIparameters[0]] &= 'Ben.There,.Dan.That!_c2008_ppGame.pgz' ;specific test

;~ 		$CLIparameters[0] += 1
;~ 		ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 		$CLIparameters[$CLIparameters[0]] = '-Wait' ; '-Quiet' ; '-Debug' ; '-Mute' ; '-TrayOnly' ; '-Help'  ; Switches

;~ 		$CLIparameters[0] += 1
;~ 		ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 		$CLIparameters[$CLIparameters[0]] = '-Fadertainer=off' ; '-Debug' ; '-Mute' ; '-TrayOnly' ; '-Help'  ; Switches

;~ 		$CLIparameters[0] += 1
;~ 		ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 		$CLIparameters[$CLIparameters[0]] = '-Regen' ; '-Debug' ; '-Mute' ; '-TrayOnly' ; '-Help'  ; Switches

;~ 		$CLIparameters[0] += 1
;~ 		ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 		$CLIparameters[$CLIparameters[0]] = '-ssClean=off' ; '-Debug' ; '-Mute' ; '-TrayOnly' ; '-Help'  ; Switches

	EndIf
	Opt('TrayIconDebug', 1)
EndIf

#region ;-------------------------------------- _SetupS Declarations Below -------------------------------------------------------
WaitForOne()
SetThisApp('SetupS SendTo Extension') ; Sets $ThisAppTitle, $ThisAppVersion, & $ThisAppFilename; plus DualArch

#include <UDFs\WinAPIEx.au3>
#include <UDFs\icons.au3>
Global $hFadertainer = '', $hFader, $UseTempDir4AppPath, $RegenOnly, $ExtCmdOnly, $ExtRegOnly, $ProgramsDir_EX
Global $ProcessShortcutS, $AppPathFolderIcon, $ProcessScript, $ProcessRegistry, $ssInstall, $RegisterDLLs, $InstallFonts
Local $OSArchGate_App, $OSVersionGate_App, $ScanMethod = '', $TempCMD = 'SetupS~.cmd', $TempREG = 'SetupS~.reg'
Local $InitUninstallReg, $App_Uninstall_Diff
Global $UserAccounts[1], $ApplyPatch, $ssConfigINI = CheckINI('ssConfig.ini')
Global $NoArch=False
;~ If $MakeDefaultINI Then SetSetupSOptions($ssConfigINI)
$UserAccounts[0] = 0
Opt('GUIOnEventMode', 1)
#endregion
;Local $test = SetGates('This is a#Is_NT>=5.0##Is_NT<6.0# test', $OSArchGate_App, $OSVersionGate_App)
;~ Local $Test = ConvertFromVars('%SystemRoot%\Resources\Themes')
;~ MsgBox(262144, 'Debug line ~' & @ScriptLineNumber, 'Selection:' & @CRLF & '$test' & @CRLF & @CRLF & 'Return:' & @CRLF & $Test) ;### Debug MSGBOX
;~ Exit

;------------------------------------------------------ Declarations -------------------------------------------------------------
Local $PID, $BType = 'any', $TempToolsDir
$HelpFile = FindMe('ssTek.chm')

;----------------------------------------------------- Get Parameters ------------------------------------------------------------
GetReportingMode($ssConfigINI)
If $Debug Then _ConsoleWrite('@@ Debug Start (' & @ScriptName & ') : ' & _NowCalc(), True) ; set 2nd arg = True to start a new file
If $BalloonTips Then
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', '2')
	Opt('TrayIconHide', 0) ;Show tray icon
	Opt('TrayAutoPause', 0) ;Turn off autopause
	_TrayTip($ThisAppTitle, 'Initializing...', 30, 17)
	_ShowTray();AdlibRegister('_ShowTray', 5000)
Else
	;RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', '0')
	Opt('TrayIconHide', 1) ;Hide tray icon
EndIf
If $SplashTips Then SplashThis($ThisAppFilename, 'Initializing...')
If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Initializing...' & @CRLF, True)
GetFaderMode($ssConfigINI)
GetScMode($ssConfigINI)
GetSetupSOptions($ssConfigINI)
Local $FadertainerOriginal = $Fadertainer
$ppAppsDriveMove = GetParameter('ppAppsDriveMove', '=')
$ppGamesDriveMove = GetParameter('ppGamesDriveMove', '=')
If GetParameter('Regenerate') Or GetParameter('Regen') Then $RegenOnly = True
If GetParameter('Help') Or GetParameter('?') Or GetParameter('About') Then EndGame('Help requested', 'See displayed', True)
;------------------------------------------------------ Get System Info ----------------------------------------------------------
GetppDrives()
;~ GetOpticalDrive() ; Only use if %CDROM% variable is used. Moved to --> ConvertFromVar().
If $ToolsPath = '' Then GetToolsFolder() ;$ToolsPath ;EnvGet('Path')
GetMenuStyle()

;------------------------------------------------------ Begin --------------------------------------------------------------------
; Get the Source Path(s)
If Not GetSrcPath($SrcPath) Then
	$ScanDirs = NoBackslash($SrcPath)
	If $BalloonTips Then _TrayTip('Scanning', $ScanDirs, 30, 17)
	If $SplashTips Then SplashThis('Scanning', $ScanDirs)
	If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Scanning --> ' & $ScanDirs & @CRLF)
	If StringInStr(StringMid($ScanDirs, 3), '\ssApps') = 1 Then $BType = 'app'
	If StringInStr(StringMid($ScanDirs, 3), '\SetupSApps') = 1 Then $BType = 'app'
	If StringInStr(StringMid($ScanDirs, 3), '\ppApps') = 1 Then
		$BType = 'app'
		$ScanMethod = 'Old'
	EndIf
	If StringInStr(StringMid($ScanDirs, 3), '\ppGames') = 1 Then
		$BType = 'ppg'
		$ScanMethod = 'Old'
	EndIf
;~ 	Timer($StopWatch) ; start timer
	If $RegenOnly Then
		ScanForExpressInstall($ScanDirs, True, $BType, $ScanMethod)
	Else
		ScanForExpressInstall($ScanDirs, False, $BType, $ScanMethod)
	EndIf
EndIf
If $ExpressInstall[0] = 0 Then ; only one to process: $SrcPath
	$ExpressInstall[0] += 1
	ReDim $ExpressInstall[$ExpressInstall[0] + 1]
	$ExpressInstall[$ExpressInstall[0]] = NoBackslash($SrcPath)
EndIf
Switch DriveGetFileSystem(StringLeft($SrcPath, 2)) ;Check File System
	Case 'NTFS', 'UDF', 'CDFS', 1
	Case Else
		If $ExpressInstall[0] > 0 Then _ArraySort($ExpressInstall, 0, 1)
EndSwitch
;~ Timer($StopWatch, 'ScanForExpressInstall', True) ; stop timer
;~ Exit

If $ToolsPath <> '' And $Fadertainer Then
	If FileExists($ToolsPath & '\FaderModules\' & $FaderModule) Then Run($ToolsPath & '\FaderModules\' & $FaderModule)
EndIf
For $xi = 1 To $ExpressInstall[0]
	If FileExists($ExpressInstall[$xi]) And NormalizeInstallPath($ExpressInstall[$xi]) <> '' Then ; in case _SetupS() deletes the path
		_AppReset()
		$Fadertainer = $FadertainerOriginal
		$SrcPath = $ExpressInstall[$xi]
		If $ToolsPath <> '' And $Fadertainer And StringInStr(FileGetAttrib($SrcPath), 'D') = 0 Then ; a file
			Switch StringRight($SrcPath, 4)
				Case '.apz', '.pgz'
					If $hFadertainer = '' And GetFileFromArchive('*.png', $SrcPath) Then
						Fadertainer($TempDir, $hFadertainer, $hFader)
						HotKeySet('{ESC}', 'FadertainerClose')
					EndIf
			EndSwitch
		EndIf
		If Not GetArchivedApp($SrcPath) Then EndGame('Error (193) SetupS was not able to install:', '"' & $SrcPath & '" is not a recognized SetupS file or folder.', False, 20, True)

		;--- Install App --- ($SrcPath at this point is a folder)
		If $App_File = '' Then $App_File = _AppRead($SrcPath, False, False)
		If FileExists($App_File) Then
			$INIname = GetFilename($App_File)
			$SplashTemp = $App_Title
			If $App_Version <> '' And $App_Type < 5 Then $SplashTemp = $SplashTemp & ' ' & $App_Version
			$OSArchGate_App = True
			$OSVersionGate_App = True
			If $App_Architecture > 0 Then
				Switch $App_Architecture
					Case 1 ; 'x86'
						$SplashTemp = $SplashTemp & ' (x86)'
						If $SkipOSArch Then $OSArchGate_App = Not $OSArch64
					Case 2 ; 'x64'
						$SplashTemp = $SplashTemp & ' (x64)'
						If $SkipOSArch Then $OSArchGate_App = $OSArch64
				EndSwitch
			EndIf
			If 0 < $App_OS And $App_OS < 15 Then
				Select
					Case VersionCompare($WINNTVersion, '=', '5') ; 'NT5 (XP/2000/2k3)'
						$SplashTemp = $SplashTemp & ' (XP/2000/2k3)'
						If $SkipOSArch Then $OSVersionGate_App = BitAND($App_OS, 1) = 1
					Case VersionCompare($WINNTVersion, '>=', '6.0') And VersionCompare($WINNTVersion, '<', '6.2') ; 'NT6 (Vista/7)'
						$SplashTemp = $SplashTemp & ' (Vista/7)'
						If $SkipOSArch Then $OSVersionGate_App = BitAND($App_OS, 2) = 2
					Case VersionCompare($WINNTVersion, '>=', '6.2') And VersionCompare($WINNTVersion, '<', '10.0') ; 'NT6 (8/8.1)'
						$SplashTemp = $SplashTemp & ' (8/8.1)'
						If $SkipOSArch Then $OSVersionGate_App = BitAND($App_OS, 4) = 4
					Case VersionCompare($WINNTVersion, '>=', '10.0') ; 'NT6 (10)'
						$SplashTemp = $SplashTemp & ' (10)'
						If $SkipOSArch Then $OSVersionGate_App = BitAND($App_OS, 8) = 8
				EndSelect
			EndIf
			;Glenn 2023 Bypass Gates
			;If $OSArchGate_App And $OSVersionGate_App Then
			If $OSVersionGate_App Then
				If $BalloonTips Then _TrayTip('Processing', $App_Title, 30, 17)
				If $SplashTips Then SplashThis('Processing', $SplashTemp)
				If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Processing --> ' & $SplashTemp & @CRLF)
				If $FaderInstallsOnly And IsRegenMode($SrcPath) Then $Fadertainer = False
				If $Fadertainer And $hFadertainer = '' Then
					Fadertainer($SrcPath, $hFadertainer, $hFader)
					HotKeySet('{ESC}', 'FadertainerClose')
				EndIf
				_SetupS($SrcPath)
				Cleanup() ; temp files, folders, etc.
				$AppInstallCount += 1
				If $xi < $ExpressInstall[0] And $Fadertainer And $hFadertainer <> '' Then
					HotKeySet('{ESC}')
					FadeOutBitmap($hFadertainer, $hFader, $FaderSpeed)
					$hFadertainer = ''
				EndIf
			Else
				If $BalloonTips Then _TrayTip('Skipping', $App_Title, 30, 17)
				If $SplashTips Then SplashThis('Skipping', $SplashTemp)
				If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Skipping --> ' & $SplashTemp & @CRLF)
			EndIf
		ElseIf $ExpressInstall[0] = 1 And $ScanDepth = 1 Then
			Select
				;Case ($SrcPath & '\'= $ppAppsDrive & '\ppApps\')
				;Case ($SrcPath & '\'= $ppGamesDrive & '\ppGames\')
				Case StringInStr($SrcPath & '\', '\ppApps\') = 3
				Case StringInStr($SrcPath & '\', '\ppGames\') = 3
				Case StringInStr($SrcPath & '\', '\ppAppsLive\') = 3
				Case StringInStr($SrcPath & '\', '\ppAppLive\') = 3
				Case StringInStr($SrcPath & '\', '\ppGamesLive\') = 3
				Case StringInStr($SrcPath & '\', '\ppGameLive\') = 3
				Case StringInStr($SrcPath & '\', '\SetupSApps\') = 3
				Case StringInStr($SrcPath & '\', '\SetupSApp\') = 3
				Case StringInStr($SrcPath & '\', '\ssAppsInstalls\') = 3
				Case StringInStr($SrcPath & '\', '\ssAppsInstall\') = 3
				Case StringInStr($SrcPath & '\', '\ssAppInstalls\') = 3
				Case StringInStr($SrcPath & '\', '\ssAppInstall\') = 3
				Case StringInStr($SrcPath & '\', '\ppAppsInstalls\') = 3
				Case StringInStr($SrcPath & '\', '\ppAppsInstall\') = 3
				Case StringInStr($SrcPath & '\', '\ppAppInstalls\') = 3
				Case StringInStr($SrcPath & '\', '\ppAppInstall\') = 3
				Case StringInStr($SrcPath & '\', '\ppGamesInstalls\') = 3
				Case StringInStr($SrcPath & '\', '\ppGamesInstall\') = 3
				Case StringInStr($SrcPath & '\', '\ppGameInstalls\') = 3
				Case StringInStr($SrcPath & '\', '\ppGameInstall\') = 3
				Case Else
					EndGame('Error (273) SetupS was not able to install:', '"' & $SrcPath & '" is not a recognized SetupS file or folder.', False, 20, True)
			EndSelect
		EndIf
	EndIf
Next
If $ToolsPath <> '' And $Fadertainer Then
	If FileExists($ToolsPath & '\FaderModules\' & $FaderModule) Then
		$PID = ProcessExists($FaderModule)
		If $PID Then ProcessClose($PID)
	EndIf
EndIf
If $ssCleanRemovedMenuItem And $RemovedMenuItem Then
	Switch $ssCleaner
		Case 1
			ssCleaner(@StartMenuCommonDir) ; All Users Start Menu
			ssCleaner(@StartMenuDir) ; Current User Start Menu
		Case 2
			ssCleaner(@StartMenuCommonDir) ; All Users Start Menu
			ssCleaner(@StartMenuDir) ; Current User Start Menu
			ssCleaner(@DesktopCommonDir) ; All Users Desktop
			ssCleaner(@DesktopDir) ; Current User Desktop
			ssCleaner(EnvGet('ALLUSERSPROFILE') & '\SendTo'); All Users Sendto
			ssCleaner(@UserProfileDir & '\SendTo') ; Current User Sendto
			ssCleaner(@AppDataDir & '\Microsoft\Internet Explorer\Quick Launch') ; QuickLaunch
	EndSwitch
EndIf
If $ssCleaner > 0 And $KeepStartMenuFolders Then CopyMenu($MenuStyle)
If $TempToolsDir <> '' Then DeleteMe($TempToolsDir)
If $Fadertainer And $hFadertainer <> '' Then FadeOutBitmap($hFadertainer, $hFader, $FaderSpeed)
Switch $AppInstallCount
	Case 0
		EndGame('Finished Scanning...', '0 Titles Found.');, False, 5)
	Case 1
		EndGame('Finished Processing', $App_Title);, False, 5)
	Case Else
		EndGame('Finished.', $AppInstallCount & ' Titles Processed.');, False, 5)
EndSwitch

;---------------------------------------------------- Finished ------------------------------------------------------------------
Exit

#region ;######################################### _SetupS Functions Below #######################################################

Func _SetupS($SrcPath)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|_SetupS(): $SrcPath=' & $SrcPath & @CRLF)
	FileChangeDir($SrcPath)
	Local $i, $j, $Line, $File, $SelfInstall = '', $WriteMode, $App_InstallPath_Original = $App_InstallPath, $ForceUpdateINI = False
	$ApplyPatch = False
	$ProcessShortcutS = False
	$AppPathFolderIcon = False
	$ProcessScript = False
	$ProcessRegistry = False
	$CopyFromLive = False
	$ssInstall = False
	$UseTempDir4AppPath = ''
	$App_smSource = ConvertFromVars(ConvertToVars($App_smSource))
	$App_InstallPath = ConvertFromVars(ConvertToVars($App_InstallPath))
	$ProgramsDir_EX = @ProgramsDir
	If $App_AllUsers Then $ProgramsDir_EX = @ProgramsCommonDir

	;------------------------- Fixups -------------------------
	If NormalizeInstallPath($App_InstallPath) = '' Then
		$InstallFromAppPath = (StringInStr($SrcPath, @ProgramFilesDir & '\') = 1)
		$InstallFromAppPath = (StringInStr($SrcPath, EnvGet('ProgramFiles(x86)') & '\') = 1 And $OSArch64) Or $InstallFromAppPath
		$InstallFromAppPath = (StringInStr($SrcPath, @WindowsDir & '\') = 1) Or $InstallFromAppPath
		$InstallFromAppPath = (StringInStr($SrcPath, $ppAppsDrive & '\ppApps\') = 1) Or $InstallFromAppPath
		$InstallFromAppPath = (StringInStr($SrcPath, $ppGamesDrive & '\ppGames\') = 1) Or $InstallFromAppPath
	Else
		If StringInStr($App_InstallPath, ':') = 0 Or Not FileExists($App_InstallPath) Then
			GetInstallPath($App_InstallPath)
		EndIf
		$InstallFromAppPath = ($SrcPath = $App_InstallPath)
		$InstallFromAppPath = (($SrcPath = StringReplace($App_InstallPath, @ProgramFilesDir, EnvGet('ProgramFiles(x86)'))) And $OSArch64) Or $InstallFromAppPath
	EndIf
	If $App_Type < 3 And Not $InstallFromAppPath Then ; Keep searching...
		If $App_InstallPath <> '' Then
			If $OSArch64 Then
				$InstallFromAppPath = StringInStr($SrcPath, EnvGet('ProgramFiles(x86)'))
			Else
				$InstallFromAppPath = StringInStr($SrcPath, @ProgramFilesDir)
			EndIf
		EndIf
	EndIf
	If $App_Type = 5 Then
		For $i = 1 To $App_Category[0]
			If StringInStr($App_Category[$i], 'Games\') <> 1 Then $App_Category[$i] = 'Games\' & $App_Category[$i]
			$App_Category[$i] = StringReplace($App_Category[$i], 'Games\Games', 'Games', 0) ; Category Games Games...??
		Next
		If $App_Category[0] > 0 Then $GamesProgramsDir = $ProgramsDir_EX & '\' & $App_Category[1] ;only the first one listed (for now)
		If $GamesProgramsDir = '' Then $GamesProgramsDir = $ProgramsDir_EX & '\Games'
	EndIf

	;------------------------- Assembly -------------------------
	If $RegenOnly Then $InstallFromAppPath = True
	If $InstallFromAppPath Then ; Regen-mode
		$App_InstallPath = $SrcPath
		ProcessAssembly($InstallFromAppPath)
	Else
		ProcessAssembly() ; Includes any ssApp installers or post-install directives, pre-install .cmd/.reg and/or psuedo-variables
		If Not FileExists($MenuDefinitionINI) Then ; another special case where SetupS is installing itself
			GetToolsFolder()
			GetMenuStyle()
			InstallMenu($MenuStyle)
			StartMenuDestPath()
		EndIf
	EndIf
	If IsWriteProtected($App_InstallPath) Then $AppWriteProtected = True
	If Not $ssInstall And Not $RegenOnly Then ssInstall() ;  Includes any ppApp/ppGame 'installs' plus Aux files copied ;Glenn_v20.02.13

	;------------------------- Post-processing -------------------------
	If Not $ApplyPatch And Not $RegenOnly Then ApplyPatch() ; Patch archive/folder ;Glenn_v20.02.13
	If Not $ProcessShortcutS Then ProcessShortcutS() ; all shortcut/startmenu related tasks
	If Not $AppPathFolderIcon And Not $RegenOnly Then AppPathFolderIcon() ; Install-path (AppPath) Folder Icon ;Glenn_v20.02.13
	If Not $ProcessScript Then ProcessScript() ; Script handling
	If Not $ProcessRegistry Then ProcessRegistry() ; Registry handling
	If Not $InstallFonts Then InstallFonts()
	If Not $RegisterDLLs Then RegisterDLLs()
	If IsArray($App_Uninstall_Diff) And $App_Uninstall_Diff[0][0] > 0 Then ;Possible ssApp
		$App_Uninstall = $App_Uninstall_Diff
	Else ;Possible ppApp/ppGame or a reinstall
		$App_Uninstall_Diff = ProcessUninstall()
		If IsArray($App_Uninstall_Diff) And $App_Uninstall_Diff[0][0] > 0 Then $App_Uninstall = $App_Uninstall_Diff
	EndIf

	;------------------------- Check for InstallPath -------------------------
	If Not (GetInstallPath($App_InstallPath) Or StringInStr($App_InstallPath, 'nonething')) Then
		; unlikely installer created an Install-path so need to derive one instead:
		If NormalizeInstallPath($App_InstallPath) = '' Then
			; First check if original supplied <AppPath> from source is okay to use
			If NormalizeInstallPath($App_InstallPath_Original) <> '' Then
				$App_InstallPath = $App_InstallPath_Original
			Else
				$App_InstallPath = GetAppPathComplete($App_InstallPath)
			EndIf
		EndIf
		DirCreate($App_InstallPath)
	EndIf

	;------------------------- Get ssUninstall info -------------------------
	If $App_InstallPath <> '' And $App_Uninstall[0][0] = 0 Then ;Possible regen or a reinstall
		$App_Uninstall = GetUninstallData($App_InstallPath)
		If $App_Uninstall[0][0] > 0 Then $ForceUpdateINI = True ;  And $App_UpdateAppFile And $InstallFromAppPath
	EndIf
	;_ArrayDisplay($App_Uninstall, @ScriptLineNumber)

	;------------------- Check Architecture --------------------
	$NoArch=False
	If $App_Architecture = 0 Then $NoArch=True
	If $App_Architecture = 0 Then ; affects ssApps only
		If @AutoItX64 Then
			Select
				Case StringInStr($App_InstallPath, @ProgramFilesDir & '\') Or StringInStr($App_InstallPath, @SystemDir & '\')
					$App_Architecture = 2
				Case StringInStr($App_InstallPath, EnvGet('ProgramFiles(x86)') & '\') Or StringInStr($App_InstallPath, @WindowsDir & '\SYSWOW64\')
					$App_Architecture = 1
			EndSelect
		ElseIf StringInStr($App_InstallPath, @ProgramFilesDir & '\') Or StringInStr($App_InstallPath, @SystemDir & '\') Then
			$App_Architecture = 1
		EndIf
	EndIf

	;---------- Fix Startup folder icon if missing or changed -------------
	If $MenuStyle > 0 And Not $RegenOnly Then ;Glenn_v20.02.13
		Local $StartupOk = False
		Select
			Case Not FileExists(@StartupDir & '\desktop.ini')
			Case Not FileExists(@StartupCommonDir & '\desktop.ini')
			Case Not FileCompare($ssTekResources & '\Menu\Startup' & '\desktop.ini', @StartupDir & '\desktop.ini')
			Case Not FileCompare($ssTekResources & '\Menu\Startup' & '\desktop.ini', @StartupCommonDir & '\desktop.ini')
			Case Else
				$StartupOk = True
		EndSelect
		If Not $StartupOk Then InstallMenu($MenuStyle)
	EndIf

	;---------- Make new .app/.ppg (ie, convert or update AppFile) -------------
	Local $NewFile, $TempINI = $App_InstallPath & '\' & $INIname, $UpdateINI = Not $InstallFromAppPath
	If $UseTempDir4AppPath <> '' Then $App_InstallPath = $UseTempDir4AppPath
	If FileExists($TempDir & '\' & $scFolder) And Not $RegenOnly Then GetShortcutS($TempDir & '\' & $scFolder) ;Glenn_v20.02.13
	Select
		Case Not FileExists($TempINI)
		Case $App_scCount > 0
		Case VersionCompare($SetupSFileVersion, '=', '9') And $App_FileFormat = 0 ; GetVersionNumber($SetupSFileVersion) = 9
		Case Else
			$UpdateINI = False
	EndSelect
	If Not $App_UpdateAppFile And Not $InstallFromAppPath Then $UpdateINI = False ; Install-mode only and UpdateAppFile = off
	If Not IsWriteProtected($App_InstallPath) And Not $RegenOnly Then ;Glenn_v20.02.13
		If $App_InstallPath <> $App_InstallPath_Original Then
			FileMove($App_InstallPath_Original & '\' & StringLeft($INIname, StringLen($INIname) - 4) & '.*', $App_InstallPath & '\', 9)
			;check for empty $App_InstallPath_Original and delete it if so
		EndIf
		If $App_NoneThing Then
			FileDelete($App_InstallPath & '\' & GetAppTypeBase($App_Type) & '\')
			FileDelete($App_InstallPath & '\' & GetAppTypeBase($App_Type) & '.cmd')
			FileDelete($App_InstallPath & '\' & GetAppTypeBase($App_Type) & '.bat')
			FileDelete($App_InstallPath & '\' & GetAppTypeBase($App_Type) & '.reg')
			FileDelete($TempINI)
		ElseIf $UpdateINI Or $ForceUpdateINI Then
			If VersionCompare($SetupSFileVersion, '=', '9') Then ;GetVersionNumber($SetupSFileVersion) = 9
				If $App_FileFormat = 0 Then
					$WriteMode = 'New'
					$NewFile = _TempFile()
				Else
					$WriteMode = 'Update'
					$NewFile = $TempINI
				EndIf
			Else ; 'Legacy' still
				$WriteMode = 'Legacy'
				$NewFile = _TempFile()
			EndIf
			$NewFile = _AppWrite($NewFile, $WriteMode)
			If $NewFile <> $TempINI Then
				If FileExists($NewFile) And Not FileCompare($NewFile, $TempINI) Then FileMove($NewFile, $TempINI, 9)
				If FileExists(GetFolderPath($NewFile) & '\' & GetAppTypeBase($App_Type) & '.reg') And Not FileCompare(GetFolderPath($NewFile) & '\' & GetAppTypeBase($App_Type) & '.reg', GetFolderPath($TempINI) & '\' & GetAppTypeBase($App_Type) & '.reg') Then FileMove(GetFolderPath($NewFile) & '\' & GetAppTypeBase($App_Type) & '.reg', GetFolderPath($TempINI) & '\' & GetAppTypeBase($App_Type) & '.reg', 9)
				If FileExists(GetFolderPath($NewFile) & '\' & GetAppTypeBase($App_Type) & '.cmd') And Not FileCompare(GetFolderPath($NewFile) & '\' & GetAppTypeBase($App_Type) & '.cmd', GetFolderPath($TempINI) & '\' & GetAppTypeBase($App_Type) & '.cmd') Then FileMove(GetFolderPath($NewFile) & '\' & GetAppTypeBase($App_Type) & '.cmd', GetFolderPath($TempINI) & '\' & GetAppTypeBase($App_Type) & '.cmd', 9)
				FileDelete($NewFile)
				FileDelete(GetFolderPath($NewFile) & '\' & GetAppTypeBase($App_Type) & '.reg')
				FileDelete(GetFolderPath($NewFile) & '\' & GetAppTypeBase($App_Type) & '.cmd')
				FileSetTime($TempINI, $App_TDStamp)
			EndIf
			#cs
				DeleteDuplicates(GetFolderPath($TempINI), GetAppTypeBase($App_Type) & '.cmd', '.cmd')
				DeleteDuplicates(GetFolderPath($TempINI), GetAppTypeBase($App_Type) & '.cmd', '.bat')
				DeleteDuplicates(GetFolderPath($TempINI), GetAppTypeBase($App_Type) & '.reg', '.reg')
				DeleteDuplicates(GetFolderPath($TempINI), GetAppTypeBase($App_Type) & '.jpg', '.jpg')
				DeleteDuplicates(GetFolderPath($TempINI), GetAppTypeBase($App_Type) & '.mp4', '.mp4')
				DeleteDuplicates(GetFolderPath($TempINI), GetAppTypeBase($App_Type) & '.png', '.png')
				DeleteDuplicates(GetFolderPath($TempINI), GetAppTypeBase($App_Type) & '.ico', '.ico')
			#ce
		EndIf
	EndIf
EndFunc

Func AddonInstaller($Line, $SrcPath, $Method = 1)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|AddonInstaller()' & @CRLF)
	If FileExists($Line) Then
		Local $INF, $temp = $TempDir & '\AddonInst', $PID, $var
		DirRemove($temp, 1)
		RunWait($CLIprefix & '7z x -y -aoa "' & $Line & '" -o"' & $temp & '"', $SrcPath, @SW_HIDE)
		RunWait($CLIprefix & '7z x -y -aoa "' & $temp & '\*.cab" -o"' & $temp & '\i386"', $SrcPath, @SW_HIDE)
		RunWait($CLIprefix & '7z x -y -aoa "' & $temp & '\*.in_" -o"' & $temp & '"', $SrcPath, @SW_HIDE)
		$INF = _FileListToArray($temp, '*.inf', 1)
		If @error <> 1 Then
			Switch $Method
				Case 1
					$PID = Run(@SystemDir & '\rundll32.exe advpack.dll,LaunchINFSectionEx ' & $temp & '\' & $INF[1] & ',,,4,N', $temp, @SW_SHOWNOACTIVATE) ;method 2
				Case 2
					$PID = Run(@SystemDir & '\rundll32.exe syssetup,SetupInfObjectInstallAction DefaultInstall 128 ' & $temp & '\' & $INF[1], $temp, @SW_SHOWNOACTIVATE) ;method 1
				Case 3
					$PID = Run(@SystemDir & '\rundll32.exe setupapi.dll,InstallHinfSection DefaultInstall 132 ' & $temp & '\' & $INF[1], $temp, @SW_SHOWNORMAL)
			EndSwitch
			Do
				Sleep(100)
				;	$var = ControlGetText('Confirm File Replace', 'target file exists', 'Button3')
				;	If $var <> '' Then ClickMe('Confirm File Replace', 'target file exists', 'Button3')
			Until Not ProcessExists($PID)
			FileCopy($temp & '\' & $INF[1], @WindowsDir & '\inf', 1)
			Sleep(100)
		EndIf
		RunWait(@ComSpec & ' /c attrib . -R -S -H', $temp, @SW_HIDE)
		FileSetAttrib($temp & '\*.*', '-R-S-H+N', 1)
		DirRemove($temp, 1)
		Return True
	Else
		Return False
	EndIf
EndFunc

Func AddToHosts($CL)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|AddToHosts(): $CL=' & $CL & @CRLF)
	Local $Test = HostsLine($CL), $File = @SystemDir & '\drivers\etc\hosts'
	If $Test <> '' And StringInStr($Test, ' ') Then
		Local $hFile = FileOpen($File, 0), $Found = False, $FilePos = 0, $Line, $EOF, $LastChar
		If $hFile <> -1 Then
			Do
				$Line = FileReadLine($hFile)
				$EOF = (@error = -1)
				If $EOF Then
					$FilePos = FileGetPos($hFile)
				ElseIf (HostsLine($Line) = $Test) Then
					$Found = True
				EndIf
			Until $EOF Or $Found
			FileClose($hFile)
			$hFile = FileOpen($File, 0)
			FileSetPos($hFile, $FilePos - 1, $FILE_BEGIN)
			$LastChar = Asc(FileRead($hFile))
			FileClose($hFile)
			FileSetAttrib($File, '-RH')
			If Not $Found Then
				FileSetAttrib($File, '-RH')
				$hFile = FileOpen($File, 1)
				If $hFile <> -1 Then
					If Not ($LastChar = 10 Or $LastChar = 13) Then FileWriteLine($hFile, '')
					FileWriteLine($hFile, $CL)
					FileClose($hFile)
				EndIf
				FileSetAttrib($File, '+RH')
			EndIf
		EndIf
	EndIf
EndFunc

Func ApplyPatch() ; Patch Archive/folder
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|ApplyPatch()' & @CRLF)
	If $ToolsPath <> '' Then
		InstallArchive('Patch.7z')
		InstallArchive('Patch.rar')
		InstallArchive('Patch.cab')
		InstallArchive('Patch.zip')
	EndIf
	If FileExists($SrcPath & '\Patch\') Then NeoDirCopy($SrcPath & '\Patch', $App_InstallPath)
	If FileExists($SrcPath & '\ssApp\') Then NeoDirCopy($SrcPath & '\ssApp', $App_InstallPath)
	If FileExists($SrcPath & '\ppApp\') Then NeoDirCopy($SrcPath & '\ppApp', $App_InstallPath)
	If FileExists($SrcPath & '\ppGame\') Then NeoDirCopy($SrcPath & '\ppGame', $App_InstallPath)
	If FileExists($SrcPath & '\SetupS\') Then NeoDirCopy($SrcPath & '\SetupS', $App_InstallPath)
	Return True
EndFunc

Func AppPathFolderIcon() ; Install-path (AppPath) Folder Icon
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|AppPathFolderIcon()' & @CRLF)
	If $App_NoneThing Then Return True
	Select
		Case CreateFolderDesktopINI('ppApp.ico', $App_InstallPath)
		Case CreateFolderDesktopINI('ppGame.ico', $App_InstallPath)
		Case CreateFolderDesktopINI('ssApp.ico', $App_InstallPath)
		Case CreateFolderDesktopINI('SetupS.ico', $App_InstallPath)
	EndSelect
	Return True
EndFunc

Func CopyExt($Ext)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|CopyExt(): $Ext=' & $Ext & @CRLF)
	If FileExists($SrcPath & '\' & StringLeft($INIname, StringLen($INIname) - 4) & $Ext) Then
		FileCopy($SrcPath & '\' & StringLeft($INIname, StringLen($INIname) - 4) & $Ext, $App_InstallPath & '\', 9)
	ElseIf $App_Type > 2 Then
		If StringLeft($Ext, 2) = '*.' Then $Ext = StringMid($Ext, 2)
		FileCopy($SrcPath & '\*' & $Ext, $App_InstallPath & '\', 9)
	EndIf
EndFunc

Func CreateFileAssociation($Extension, $ClassName, $Description, $ExeProgram)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|CreateFileAssociation(): $Extension=' & $Extension & ' : $ClassName=' & $ClassName & ' : $Description=' & $Description & ' : $ExeProgram=' & $ExeProgram & @CRLF)
	Local $S, $E2, $S2
	If StringLeft($Extension, 1) <> '.' Then $Extension = '.' & $Extension
	$S = RegRead('HKEY_CLASSES_ROOT', $Extension)
	If $S <> '' Then ;we have an association already
		If StringLen($S) > 6 Then ;min length
			If StringRight($S, 6) = 'SetupS' Then
				Return 50 ;done already, quit (assume backup is OK too)
			EndIf
		EndIf
		;Backup OLD value, its possible for another app to steal association
		;in which case we just restore our association without doing a backup of the stolen ass.
		$E2 = 'SetupS.Bak'
		$S2 = RegRead('HKEY_CLASSES_ROOT\' & $Extension, $E2) ;check its not already backed up
		If $S2 = '' Or $S2 = 'Error; Bad Value Type' Then ;we haven't already have backed up this key in the past
			RegWrite('HCEY_CLASSES_ROOT\' & $Extension, $E2, 'REG_SZ', $S) ;old value backed up
		EndIf
	EndIf
	;procede if not already a SetupS association
	RegWrite('HKEY_CLASSES_ROOT\' & $Extension, '', 'REG_SZ', $ClassName) ; create a value for this key that contains the classname
	RegWrite('HKEY_CLASSES_ROOT\' & $ClassName & '\Shell\Open\Command', '', 'REG_SZ', $ExeProgram & ' "%1"') ; set its value to the command line
	RegWrite('HKEY_CLASSES_ROOT\' & $ClassName & '\defaulticon', '', 'REG_SZ', $ExeProgram & ',0') ; set extension to app's default icon
	DllCall('shell32.dll', 'int', 'SHChangeNotify', 'long', 0x8000000, 'long', 0, 'long', 0, 'long', 0)
EndFunc

Func EnumAllUserAccounts()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|EnumAllUserAccounts()' & @CRLF)
	If $UserAccounts[0] = 0 Then
		Local $temp = _FileListToArray(@UserProfileDir & '\..', '*.*', 2)
		If IsArray($temp) Then
			$UserAccounts = $temp
		Else ; alternate "backup" method
			$temp = _SystemUsers(1)
			If IsArray($temp) Then
				$UserAccounts = $temp
			Else ; get at least the "Current User"
				$UserAccounts[0] += 1
				ReDim $UserAccounts[$UserAccounts[0] + 1]
				$UserAccounts[$UserAccounts[0]] = @UserName
			EndIf
		EndIf
		$UserAccounts[0] += 1
		ReDim $UserAccounts[$UserAccounts[0] + 1]
		$UserAccounts[$UserAccounts[0]] = 'Default User'
	EndIf
EndFunc

Func ExtractArc($ArchiveExt, ByRef $ArchiveFolder)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|ExtractArc(): $ArchiveExt=' & $ArchiveExt & ' : $ArchiveFolder=' & $ArchiveFolder & @CRLF)
	Local $i, $FileList
	Local $subtext = '... "' & GetFilename($i) & '"' ;& @CRLF & @CRLF & 'Press <ESC> to abort'
	If $ToolsPath <> '' And (StringLower(StringRight($SrcPath, StringLen($ArchiveExt))) = StringLower($ArchiveExt)) Then
		;DirRemove($TempDir, 1)
		$i = FileGetLongName($SrcPath)
		If $BalloonTips Then _TrayTip('Extracting archive', GetFilename($i), 30, 17)
		If $SplashTips Then SplashThis('Extracting archive', GetFilename($i))
		If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Extracting archive --> ' & GetFilename($i) & @CRLF)
		RunWait($CLIprefix & '7z x -y -aos "' & $SrcPath & '" -o"' & $TempDir & '"', '', @SW_HIDE)
		If FileExists($TempDir & '\*.app') Or FileExists($TempDir & '\*.ppg') Or FileExists($TempDir & '\SetupS.ini') Then
			$ArchiveFolder = $TempDir
			Return True
		Else
			$FileList = _FileListToArray($TempDir, '*.*', 2)
			If @error > 0 Then
				Switch @error
					Case 1 ;Path not found or invalid
					Case 2 ;Invalid $sFilter
					Case 3 ;Invalid $iFlag
					Case 4 ;No File(s) Found
				EndSwitch
				$ArchiveFolder = ''
				Return False
			Else
				For $i = 1 To $FileList[0]
					If FileExists($TempDir & '\' & $FileList[$i] & '\*.app') Or FileExists($TempDir & '\' & $FileList[$i] & '\*.ppg') Or FileExists($TempDir & '\' & $FileList[$i] & '\*.ini') Then
						$ArchiveFolder = $TempDir & '\' & $FileList[$i]
						Return True
					EndIf
				Next
			EndIf
		EndIf
	EndIf
	$ArchiveFolder = ''
	Return False
EndFunc

Func FadeInBitmap($hForm, $hBitmap, $Time) ;$time is in seconds
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|FadeInBitmap(): $Time=' & $Time & @CRLF)
	SetBitmap($hForm, $hBitmap, 0)
	GUISetState(@SW_SHOW, $hForm)
	Local $timer = TimerInit(), $title = ControlGetText('', '', $hForm), $delay = $Time * 1000, $trans = 0
	Do
		SetBitmap($hForm, $hBitmap, $trans)
		$trans = 255 * TimerDiff($timer) / $delay
	Until $trans >= 255
	SetBitmap($hForm, $hBitmap, 255)
EndFunc

Func FadeOutBitmap($hForm, $hBitmap, $Time) ;$time is in seconds
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|FadeOutBitmap(): $Time=' & $Time & @CRLF)
	Local $timer = TimerInit(), $title = ControlGetText('', '', $hForm), $delay = $Time * 1000, $trans = 255
	Do
		SetBitmap($hForm, $hBitmap, $trans)
		$trans = 255 - (255 * TimerDiff($timer) / $delay)
	Until $trans <= 0
	SetBitmap($hForm, $hBitmap, 0)
	GUISetState(@SW_HIDE, $hForm)
EndFunc

Func Fadertainer($SrcPath, ByRef $hFadertainer, ByRef $hFader)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Fadertainer(): $SrcPath=' & $SrcPath & @CRLF)
	If $OS_Linux Then Return False ; skips Fadertainer in Linux
	Local $FaderPic = '', $FileList, $iSize, $imgWidth, $imgHeight, $FaderLeft, $FaderTop
	Local $i, $j, $Found, $FaderList[1], $GameFolder = ''
	$FaderList[0] = 0
	Select
		Case FileExists($SrcPath & '\' & GetAppTypeBase($App_Type) & '.png')
			$FaderPic = $SrcPath & '\' & GetAppTypeBase($App_Type) & '.png'
		Case FileExists($SrcPath & '\' & GetFilename($SrcPath) & '.png')
			$FaderPic = $SrcPath & '\' & GetFilename($SrcPath) & '.png'
		Case Else
			$FileList = _FileListToArray($SrcPath, '*.png', 1) ; Return files only
			If @error = 0 Then $FaderPic = $SrcPath & '\' & $FileList[1]
	EndSelect
	If $App_Type = 5 Then $GameFolder = 'Games\'
	If Not FileExists($FaderPic) And FileExists($CategoryINI) Then ; Gather a fader list from Cats
		For $i = 1 To $App_Category[0]
			$Found = False
			For $j = 1 To $FaderList[0]
				If $FaderList[$j] = $App_Category[$i] Then
					$Found = True
					ExitLoop
				EndIf
			Next
			If Not $Found Then
				$FaderList[0] += 1
				ReDim $FaderList[$FaderList[0] + 1]
				$FaderList[$FaderList[0]] = $App_Category[$i]
			EndIf
		Next
		For $i = 1 To $App_Catalog[0]
			$Found = False
			For $j = 1 To $FaderList[0]
				If $FaderList[$j] = GetFirstWord(StringReplace($App_Catalog[$i], 'Game ', $GameFolder)) Then
					$Found = True
					ExitLoop
				EndIf
			Next
			If Not $Found Then
				$FaderList[0] += 1
				ReDim $FaderList[$FaderList[0] + 1]
				$FaderList[$FaderList[0]] = GetFirstWord(StringReplace($App_Catalog[$i], 'Game ', $GameFolder))
			EndIf
		Next
	EndIf
	If $FaderList[0] > 0 Then ; Use Cats list
		If $FaderList[0] = 1 Then ; just the one
			$FaderPic = IniRead($CategoryINI, 'Fader', $FaderList[1], '')
			If $FaderPic <> '' Then $FaderPic = $ToolsPath & '\Default\Faders\' & $FaderPic
		Else ; more than one
			For $i = 1 To $FaderList[0] ; -- randomly pick
				$FaderPic = IniRead($CategoryINI, 'Fader', $FaderList[Random(1, $FaderList[0], 1)], '')
				If $FaderPic <> '' Then
					$FaderPic = $ToolsPath & '\Default\Faders\' & $FaderPic
					If FileExists($FaderPic) Then ExitLoop
				EndIf
			Next
			If Not FileExists($FaderPic) Then
				For $i = 1 To $FaderList[0] ;  -- first available
					$FaderPic = IniRead($CategoryINI, 'Fader', $FaderList[$i], '')
					If $FaderPic <> '' Then
						$FaderPic = $ToolsPath & '\Default\Faders\' & $FaderPic
						If FileExists($FaderPic) Then ExitLoop
					EndIf
				Next
			EndIf
		EndIf
	EndIf
	If Not FileExists($FaderPic) Then $FaderPic = $ToolsPath & '\Default\Faders\' & $GameFolder & 'Default.png'
	If FileExists($FaderPic) Then
		$iSize = StringSplit(StringStripWS(_GetFileProperty($FaderPic, 'Dimensions'), 8), 'x');1=w, 2=h
		If IsArray($iSize) Then
			If $iSize[0] > 1 Then
				$imgWidth = $iSize[1]
				Switch $OSVersion
					Case 'WIN_XP', 'WIN_2003', 'WIN_XPe', 'WIN_2000' ; NT5
					Case Else ; NT6
						$imgWidth = Number(StringMid($imgWidth, 2))
				EndSwitch
				$imgHeight = $iSize[2]
				Local $NewImageWidth, $NewImageHeight, $x
				Select
					Case $imgWidth > $maxFaderSize
						$x = $maxFaderSize / $imgWidth
					Case $imgHeight > $maxFaderSize
						$x = $maxFaderSize / $imgHeight
					Case Else
						;$x = $maxFaderSize / $imgWidth ; for up-sizing/standardizing to $maxFaderSize
						$x = 1
				EndSelect
				$NewImageWidth = $imgWidth * $x
				$NewImageHeight = $imgHeight * $x
				Switch $FaderLocation
					Case 'TL'
						$FaderTop = 1
						$FaderLeft = 1
					Case 'TC'
						$FaderTop = 1
						$FaderLeft = (@DesktopWidth - $imgWidth) / 2
					Case 'TR'
						$FaderTop = 1
						$FaderLeft = @DesktopWidth - $imgWidth
					Case 'ML'
						$FaderTop = (@DesktopHeight - $imgHeight) / 2
						$FaderLeft = 1
					Case 'MC'
						$FaderTop = (@DesktopHeight - $imgHeight) / 2
						$FaderLeft = (@DesktopWidth - $imgWidth) / 2
					Case 'MR'
						$FaderTop = (@DesktopHeight - $imgHeight) / 2
						$FaderLeft = @DesktopWidth - $imgWidth
					Case 'BL'
						$FaderTop = @DesktopHeight - $imgHeight
						$FaderLeft = 1
					Case 'BC'
						$FaderTop = @DesktopHeight - $imgHeight
						$FaderLeft = (@DesktopWidth - $imgWidth) / 2
					Case 'BR'
						$FaderTop = @DesktopHeight - $imgHeight
						$FaderLeft = @DesktopWidth - $imgWidth
					Case Else
						$FaderTop = -1
						$FaderLeft = -1
				EndSwitch
				If $FaderOnTop Then
					$hFadertainer = GUICreate('FaderIcon', 64, 64, $FaderLeft, $FaderTop, $WS_POPUP, BitOR($WS_EX_LAYERED, $WS_EX_TOOLWINDOW, $WS_EX_TOPMOST))
				Else
					$hFadertainer = GUICreate('FaderIcon', 64, 64, $FaderLeft, $FaderTop, $WS_POPUP, BitOR($WS_EX_LAYERED, $WS_EX_TOOLWINDOW))
				EndIf
				$hFader = _Icons_Bitmap_Load($FaderPic)
				$hFader = _Icons_Bitmap_Resize($hFader, $NewImageWidth, $NewImageHeight)
				GUISetState(@SW_SHOWNOACTIVATE, $hFadertainer);GUISetState()
				FadeInBitmap($hFadertainer, $hFader, $FaderSpeed)
				GUISetOnEvent($GUI_EVENT_SECONDARYDOWN, 'FadertainerClose', $hFadertainer)
			EndIf
		EndIf
	Else
	EndIf
	Return $FaderPic
EndFunc

Func FadertainerClose()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|FadertainerClose()' & @CRLF)
	If $Fadertainer And $hFadertainer <> '' Then
		HotKeySet('{ESC}')
		FadeOutBitmap($hFadertainer, $hFader, $FaderSpeed)
		$Fadertainer = False
		$hFadertainer = ''
	EndIf
EndFunc

Func FilterGates($What)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|FilterGates(): $What=' & $What & @CRLF)
	Local $Line, $OSArchGate, $OSVersionGate
	If IsArray($What) Then
		Local $KeepMe[1]
		$KeepMe[0] = 0
		For $i = 1 To $What[0]
			$Line = SetGates($What[$i], $OSArchGate, $OSVersionGate)
			If $OSArchGate And $OSVersionGate Then
				$KeepMe[0] += 1
				ReDim $KeepMe[$KeepMe[0] + 1]
				$KeepMe[$KeepMe[0]] = $Line
			EndIf
		Next
	Else
		Local $KeepMe = ''
		$Line = SetGates($What, $OSArchGate, $OSVersionGate)
		If $OSArchGate And $OSVersionGate Then $KeepMe = $Line
	EndIf
	Return $KeepMe
EndFunc

Func GetArchivedApp(ByRef $SrcPath)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|GetArchivedApp(): $SrcPath=' & $SrcPath & @CRLF)
	If StringInStr(FileGetAttrib($SrcPath), 'D') = 0 Then ; Still a file... probably an archive passed via Commandline
		Local $ArchiveFolder = ''
		Select
			Case ExtractArc('.apz', $ArchiveFolder)
			Case ExtractArc('.pgz', $ArchiveFolder)
			Case ExtractArc('.7z', $ArchiveFolder)
			Case ExtractArc('.rar', $ArchiveFolder)
			Case ExtractArc('.zip', $ArchiveFolder)
			Case ExtractArc('.cab', $ArchiveFolder)
			Case ExtractArc('.arj', $ArchiveFolder)
			Case ExtractArc('.z', $ArchiveFolder) ; these could also be checked: .gz .gzip .tar .tgz .taz .lzh .lha ;-)
		EndSelect
		If $ArchiveFolder <> '' Then
			$SrcPath = $ArchiveFolder
			Return True
		Else ; non-recognized SetupS archive
			Return False
		EndIf
	Else ; Is a folder so continue
		Return True
	EndIf
EndFunc

Func GetFirstWord($temp)
	Local $a = StringInStr(StringStripWS($temp, 3), ' ')
	If $a > 0 Then $temp = StringLeft($temp, $a - 1)
	Return $temp
EndFunc

Func HostsLine($CL)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|HostsLine(): $CL=' & $CL & @CRLF)
	Local $temp = StringSplit($CL, ' ')
	If IsArray($temp) Then
		If $temp[0] > 1 Then ; Only first two
			Return StringStripWS(StringReplace($temp[1] & ' ' & $temp[2], '"', ''), 7)
		EndIf
	EndIf
	Return ''
EndFunc

Func ImportReg($What, $where) ; .reg file
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|ImportReg(): $What=' & $What & ' : $where=' & $where & @CRLF)
	If FileExists($where & '\' & $What) Then
		Local $Temp_RegFile = File2String($where & '\' & $What), $Temp_OSArchGated = False
		If $Temp_RegFile <> '' Then
			If IsGated($Temp_RegFile, $Temp_OSArchGated) Then
				Local $HeaderInUse = False, $Temp_RegEntries = FilterGates(SingleLine2Multi($Temp_RegFile, @CRLF))
				If $Temp_RegEntries[0] > 0 Then
					Local $i, $Line, $File = FileOpen(@TempDir & '\' & $TempREG, 10)
					FileWriteLine($File, 'Windows Registry Editor Version 5.00')
					FileWriteLine($File, '')
					For $i = 1 To $Temp_RegEntries[0]
						$Line = StringStripWS(ConvertFromVars(ConvertToVars($Temp_RegEntries[$i], True), True), 3)
						If ($Line = 'Windows Registry Editor Version 5.00') Or ($Line = 'REGEDIT4') Then
							$HeaderInUse = True
						Else
							If $HeaderInUse And $Line <> '' Then $HeaderInUse = False
							If Not $HeaderInUse Then FileWriteLine($File, $Line)
						EndIf
					Next
					FileClose($File)
				EndIf
			Else
				String2File(ConvertFromVars(ConvertToVars($Temp_RegFile, True), True), @TempDir & '\' & $TempREG)
			EndIf
			If FileExists(@TempDir & '\' & $TempREG) Then
				If $Temp_OSArchGated Or Not (@AutoItX64 And $App_Architecture < 2) Then ;Arch dependent (Is_x86 or Is_x64, or dual-arch)
					RunWait($CLIprefix & 'reg import ' & @TempDir & '\' & $TempREG, '.', @SW_HIDE)
					RunWait('regedit /s ' & @TempDir & '\' & $TempREG, '.', @SW_HIDE)
					;ShellExecuteWait('regedit', ' /s ' & @TempDir & '\' & $TempREG, '.', 'Open', @SW_HIDE); Alternative
				Else
					Switch $App_Architecture
						Case 0 ;Import via x86 AND x64
							RunWait(RunWait86() & $CLIprefix & 'reg import ' & @TempDir & '\' & $TempREG, '.', @SW_HIDE)
							RunWait(RunWait86() & 'regedit /s ' & @TempDir & '\' & $TempREG, '.', @SW_HIDE)
							RunWait($CLIprefix & 'reg import ' & @TempDir & '\' & $TempREG, '.', @SW_HIDE)
							RunWait('regedit /s ' & @TempDir & '\' & $TempREG, '.', @SW_HIDE)
						Case 1 ;Import via x86 only
							RunWait(RunWait86() & $CLIprefix & 'reg import ' & @TempDir & '\' & $TempREG, '.', @SW_HIDE)
							RunWait(RunWait86() & 'regedit /s ' & @TempDir & '\' & $TempREG, '.', @SW_HIDE)
					EndSwitch
				EndIf
				Return True
			EndIf
		EndIf
	EndIf
	Return False
EndFunc

Func InstallArchive($What)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|InstallArchive(): $What=' & $What & @CRLF)
	If FileExists($SrcPath & '\' & $What) Then
		If $App_Type > 2 And ($App_Architecture = 0 Or ($App_Architecture = 3 And $DualArchInstalls = 'a')) Then
			If $OSArch64 Then
				RunWait($CLIprefix & '7z x -y -aoa "' & $SrcPath & '\' & $What & '" -o"' & $App_InstallPath & '" -x!_x86\*', $SrcPath, @SW_HIDE)
				If FileExists($App_InstallPath & '\_x86') Then DirRemove($App_InstallPath & '\_x86')
			Else
				RunWait($CLIprefix & '7z x -y -aoa "' & $SrcPath & '\' & $What & '" -o"' & $App_InstallPath & '" -x!_x64\*', $SrcPath, @SW_HIDE)
				If FileExists($App_InstallPath & '\_x64') Then DirRemove($App_InstallPath & '\_x64')
			EndIf
			If Not (FileExists($App_InstallPath & '\_x86') Or FileExists($App_InstallPath & '\_x64')) Then
				RunWait($CLIprefix & '7z x -y -aoa "' & $SrcPath & '\' & $What & '" -o"' & $App_InstallPath & '"', $SrcPath, @SW_HIDE)
			EndIf
		Else
			RunWait($CLIprefix & '7z x -y -aoa "' & $SrcPath & '\' & $What & '" -o"' & $App_InstallPath & '"', $SrcPath, @SW_HIDE)
		EndIf
		If $CopyFromLive Then FileDelete($App_InstallPath & '\' & $What)
		Return True
	Else
		Return False
	EndIf
EndFunc

Func InstallBuildTypeArc($Ext)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|InstallBuildTypeArc(): $Ext=' & $Ext & @CRLF)
	If InstallArchive(GetAppTypeBase($App_Type) & $Ext) Then Return
	Switch GetAppTypeBase($App_Type)
		Case 'SetupS'
			If InstallArchive('ssApp' & $Ext) Then Return
			If InstallArchive('ppApp' & $Ext) Then Return
			If InstallArchive('ppGame' & $Ext) Then Return
		Case 'ssApp'
			If InstallArchive('SetupS' & $Ext) Then Return
			If InstallArchive('ppApp' & $Ext) Then Return
			If InstallArchive('ppGame' & $Ext) Then Return
		Case 'ppApp'
			If InstallArchive('SetupS' & $Ext) Then Return
			If InstallArchive('ssApp' & $Ext) Then Return
			If InstallArchive('ppGame' & $Ext) Then Return
		Case 'ppGame'
			If InstallArchive('SetupS' & $Ext) Then Return
			If InstallArchive('ssApp' & $Ext) Then Return
			If InstallArchive('ppApp' & $Ext) Then Return
	EndSwitch
	If InstallArchive(GetFilename($SrcPath) & $Ext) Then Return
	If InstallArchive(GetFilename($App_InstallPath) & $Ext) Then Return
EndFunc

Func InstallFonts() ;Install Font(s)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|InstallFonts()' & @CRLF)
	Local $a, $i, $Line
	$a = FilterGates($App_InstallFonts)
	For $i = 1 To $a[0]
		$Line = ConvertFromVars(ConvertToVars($a[$i]))
		If Not FileExists($App_InstallPath & '\' & $Line) Then NeoFileCopy($SrcPath & '\' & $Line, $App_InstallPath & '\' & $Line)
		If FileExists($App_InstallPath & '\' & $Line) Then
			NeoFileCopy($App_InstallPath & '\' & $Line, $TempDir & '\Fonts\' & GetFilename($App_InstallPath & '\' & $Line))
			;If Not InstallFontEx($App_InstallPath & '\' & $Line) Then
			;	;MsgBox(262144, 'Debug line ~' & @ScriptLineNumber, 'Selection:' & @LF & '$Line' & @LF & @LF & 'Return:' & @LF & $Line)
			;EndIf
		Else
			NeoFileCopy($SrcPath & '\' & $Line, $TempDir & '\Fonts\' & GetFilename($SrcPath & '\' & $Line))
			;If Not InstallFontEx($SrcPath & '\' & $Line) Then
			;	;MsgBox(262144, 'Debug line ~' & @ScriptLineNumber, 'Selection:' & @LF & '$Line' & @LF & @LF & 'Return:' & @LF & $Line)
			;EndIf
		EndIf
	Next
	If FileExists($TempDir & '\Fonts') Then RunWait($CLIprefix & 'FontReg /copy', $TempDir & '\Fonts', @SW_HIDE)
	Return True
EndFunc

Func InstallMisc($Ext)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|InstallMisc(): $Ext=' & $Ext & @CRLF)
	Local $FileList = _FileListToArray($SrcPath, '*' & $Ext, 1)
	If @error = 0 Then
		For $i = 1 To $FileList[0]
			Switch $FileList[$i] ; these should already have been "installed"
				Case 'SetupS' & $Ext
				Case 'Patch' & $Ext
				Case 'ssApp' & $Ext
				Case 'ppApp' & $Ext
				Case 'ppGame' & $Ext
				Case GetFilename($SrcPath) & $Ext
				Case GetFilename($App_InstallPath) & $Ext
				Case Else
					InstallArchive($FileList[$i])
			EndSwitch
		Next
	EndIf
EndFunc

Func IsGated($What, ByRef $OSArchGated)
	Local $Found = True
	Select
		Case StringInStr($What, '#Is_x86#')
			$OSArchGated = True
		Case StringInStr($What, '#Is_x64#')
			$OSArchGated = True
		Case StringInStr($What, '#Is_NT5#')
		Case StringInStr($What, '#Is_NT6#')
		Case StringInStr($What, '#Is_Metro#')
		Case StringInStr($What, '#Is_OS')
		Case StringInStr($What, '#Is_NT')
		Case Else
			$Found = False
	EndSelect
	Return $Found
EndFunc

Func IsRegenMode($SrcPath)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|IsRegenMode(): $SrcPath=' & $SrcPath & @CRLF)
	Local $RegenMode = False, $AIP = ConvertFromVars(ConvertToVars($App_InstallPath))
	$RegenMode = ($SrcPath = $AIP)
	$RegenMode = $RegenMode Or (($SrcPath = StringReplace($AIP, @ProgramFilesDir, EnvGet('ProgramFiles(x86)'))) And $OSArch64)
	Return $RegenMode
EndFunc

Func MakeSpecials($What)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MakeSpecials(): $What=' & $What & @CRLF)
	Local $fnWhat = GetFilename($What), $i, $temp
	Local $KeepMe = WhereIsWhat($TempDir & '\' & $scFolder, $fnWhat & '.lnk') & '\' & $fnWhat & '.lnk'
	If FileExists($KeepMe) Then
		If $App_AllUsers Then
			If $App_MakeInRoot Then NeoFileCopy($KeepMe, @StartMenuCommonDir & '\' & $fnWhat & '.lnk', True)
			If $App_MakeInPrograms Then NeoFileCopy($KeepMe, @ProgramsCommonDir & '\' & $fnWhat & '.lnk', True)
			If $App_MakeStartup Then NeoFileCopy($KeepMe, @StartupCommonDir & '\' & $fnWhat & '.lnk', True)
			If $App_MakeDesktop Then NeoFileCopy($KeepMe, @DesktopCommonDir & '\' & $fnWhat & '.lnk', True)
			If $App_MakeQuickLaunch Then
				EnumAllUserAccounts()
				For $i = 1 To $UserAccounts[0]
					$temp = StringReplace($QuickLaunch, '\' & @UserName & '\', '\' & $UserAccounts[$i] & '\')
					If FileExists($temp) Or ($UserAccounts[$i] = 'Default User') Then NeoFileCopy($KeepMe, $temp & '\' & $fnWhat & '.lnk', True)
				Next
			EndIf
			If $App_MakeSendTo Then
				EnumAllUserAccounts()
				For $i = 1 To $UserAccounts[0]
					$temp = StringReplace($SendToPath, '\' & @UserName & '\', '\' & $UserAccounts[$i] & '\')
					If FileExists($temp) Or ($UserAccounts[$i] = 'Default User') Then NeoFileCopy($KeepMe, $temp & '\' & $fnWhat & '.lnk', True)
				Next
			EndIf
		Else
			If $App_MakeInRoot Then NeoFileCopy($KeepMe, @StartMenuDir & '\' & $fnWhat & '.lnk', True)
			If $App_MakeInPrograms Then NeoFileCopy($KeepMe, @ProgramsDir & '\' & $fnWhat & '.lnk', True)
			If $App_MakeStartup Then NeoFileCopy($KeepMe, @StartupDir & '\' & $fnWhat & '.lnk', True)
			If $App_MakeDesktop Then NeoFileCopy($KeepMe, @DesktopDir & '\' & $fnWhat & '.lnk', True)
			If $App_MakeQuickLaunch Then NeoFileCopy($KeepMe, $QuickLaunch & '\' & $fnWhat & '.lnk', True)
			If $App_MakeSendTo Then NeoFileCopy($KeepMe, $SendToPath & '\' & $fnWhat & '.lnk', True)
		EndIf
		If $App_TaskbarPin Then PinItem($KeepMe, 'Taskbar', True)
		If $App_StartmenuPin Then PinItem($KeepMe, 'Startmenu', True)
		Local $Details = FileGetShortcutEx($KeepMe)
		If @error = 0 And IsArray($Details) Then Return $Details[0]
	EndIf
	Return ''
EndFunc

Func PinItem($filepath, $loc = 'Taskbar', $pin = True, $arguments = '')
	;Allows pinning (default) or unpinning to/from the Taskbar (default) or Startmenu, in any language.
	;Also allows defining argument(s) for the pinned applications.
;~ 	If @OSBuild < 7600 Then Return SetError(1) ; Windows 7 or greater only
	Local $target, $val
	If StringRight($filepath, 4) = '.lnk' Then
		$target = FileGetShortcutEx($filepath)
		If @error = 0 And IsArray($target) Then
			$filepath = $target[0]
			$arguments = $target[2]
		EndIf
	EndIf
	If $pin And Not FileExists($filepath) Then Return SetError(2) ; Target does not exist

	;split path, filename and extension
	Local $pathsplit = StringSplit($filepath, '\')
	Local $File = $pathsplit[$pathsplit[0]]
	Local $path = GetFolderPath($filepath)
	Local $filesplit = StringSplit($File, '.')
	Local $fileext = $filesplit[$filesplit[0]]
	Local $filename = StringReplace($File, '.' & $fileext, '', 1)

	;define code to use depending on actions choosen
	Local $code = 0
	If $pin Then
		Switch StringLeft($loc, 2)
			Case 'ta', 'tb' ;pin to Taskbar
				$code = 5386
			Case Else ;pin to Startmenu
				$code = 5381
		EndSwitch
		If $arguments <> '' Then ;make a temporary shortcut and pin that.
			If $TempDir = '' Then
				$TempDir = GenerateTempFolder()
				DirCreate($TempDir)
			EndIf
			FileCreateShortcut($filepath, $TempDir & '\' & $filename & '.lnk', $path, $arguments, $filename & ' ' & $arguments, $filepath)
			$path = $TempDir
			$File = $filename & '.lnk'
		EndIf
	Else
		Switch StringLeft($loc, 2)
			Case 'ta', 'tb' ;unpin from Taskbar
				$code = 5387
			Case Else ;unpin from Startmenu
				$code = 5382
		EndSwitch
	EndIf
	If Not FileExists($filepath) Then Return SetError(2) ; Target does not exist

	;retrieve Localized text for action
	Local $hInstance = _WinAPI_LoadLibraryEx('shell32.dll', $LOAD_LIBRARY_AS_DATAFILE), $localizedstring
	If $hInstance Then
		$localizedstring = _WinAPI_LoadString($hInstance, $code)
		_WinAPI_FreeLibrary($hInstance)
	EndIf

	;pin/unpin
	If @OSBuild < 7600 Then Return SetError(1) ; Not Windows 7 or greater
	If $code = 5381 Then ; check if already Pinned to Startmenu
		Local $PinnedSM = @UserProfileDir & '\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\StartMenu'
		Local $aFile = _FileListToArray($PinnedSM, '*.lnk', 1)
		If Not @error Then
			Local $i
			For $i = 1 To $aFile[0]
				$target = FileGetShortcutEx($PinnedSM & '\' & $aFile[$i])
				If @error = 0 And IsArray($target) Then
					If $target[0] = $filepath Then
						Return SetError(3)
					EndIf
				EndIf
			Next
		EndIf
	EndIf
	Local $ObjShell = ObjCreate('Shell.Application')
	Local $objFolder = $ObjShell.Namespace($path)
	Local $objFolderItem = $objFolder.ParseName($File)
	For $val In $objFolderItem.Verbs()
		If StringInStr($val(), $localizedstring) Then $val.DoIt()
	Next
	If $code = 5382 Then ;when unpining from Start Menu, use the shortcut that is effectively pinned to do so
		Local $PinnedSM = @UserProfileDir & '\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\StartMenu'
		Local $aFile = _FileListToArray($PinnedSM, '*.lnk', 1)
		If Not @error Then
			Local $i
			For $i = 1 To $aFile[0]
				$target = FileGetShortcutEx($PinnedSM & '\' & $aFile[$i])
				If @error = 0 And IsArray($target) Then
					If $target[0] = $filepath Then
						$objFolder = $ObjShell.Namespace($PinnedSM)
						$objFolderItem = $objFolder.ParseName($aFile[$i])
						For $val In $objFolderItem.Verbs()
							If StringInStr($val(), $localizedstring) Then $val.DoIt()
						Next
					EndIf
				EndIf
			Next
		EndIf
	EndIf
EndFunc

Func ProcessAssembly($InstallFromAppPath = False)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|ProcessAssembly(): $InstallFromAppPath=' & $InstallFromAppPath & @CRLF)
	Local $a, $i, $Line, $CTV, $PID, $Installer, $Found, $App_InstallPath_Original = $App_InstallPath, $arg, $NoWait
	If $App_Type > 2 Then ;ppApp/ppGame
		DirCreate($App_InstallPath) ; Makes dest dir, regardless if different from actual.
		$ppInstall = False
		$CopyFromLive = True
		If $RegenOnly = True Then $CopyFromLive = False ;Glenn_v20.02.13
		Select ;The following keeps CopyFromLive TRUE if:
			Case StringInStr($SrcPath, '\ppAppsLive\') > 0 And ($App_Type = 3 Or $App_Type = 4)
			Case StringInStr($SrcPath, '\ppGamesLive\') > 0 And $App_Type = 5
			Case (StringInStr($SrcPath, $ppAppsDrive & '\ppApps\') = 0 And ($App_Type = 3 Or $App_Type = 4)) Or (StringInStr($SrcPath, $ppGamesDrive & '\ppGames\') = 0 And $App_Type = 5)
				If $App_Type = 5 And $App_Legacy And (FileExists($SrcPath & '\*.7z') Or FileExists($SrcPath & '\*.rar') Or FileExists($SrcPath & '\*.zip') Or FileExists($SrcPath & '\*.cab')) Then
					$CopyFromLive = False
				Else
					Select
						Case FileExists($SrcPath & '\' & GetAppTypeBase($App_Type) & '.7z') Or FileExists($SrcPath & '\' & GetAppTypeBase($App_Type) & '.rar') Or FileExists($SrcPath & '\' & GetAppTypeBase($App_Type) & '.zip') Or FileExists($SrcPath & '\' & GetAppTypeBase($App_Type) & '.cab')
							$ppInstall = True
							$CopyFromLive = False
						Case FileExists($SrcPath & '\' & GetFilename($SrcPath) & '.7z') Or FileExists($SrcPath & '\' & GetFilename($SrcPath) & '.rar') Or FileExists($SrcPath & '\' & GetFilename($SrcPath) & '.zip') Or FileExists($SrcPath & '\' & GetFilename($SrcPath) & '.cab')
							$ppInstall = True
							$CopyFromLive = False
						Case FileExists($SrcPath & '\' & GetFilename($App_InstallPath) & '.7z') Or FileExists($SrcPath & '\' & GetFilename($App_InstallPath) & '.rar') Or FileExists($SrcPath & '\' & GetFilename($App_InstallPath) & '.zip') Or FileExists($SrcPath & '\' & GetFilename($App_InstallPath) & '.cab')
							$ppInstall = True
							$CopyFromLive = False
						Case Not $App_Legacy
							$ppInstall = True
					EndSelect
				EndIf
			Case $ppDriveOld And (StringInStr($SrcPath, '\ppApps\') = 3 Or StringInStr($SrcPath, '\ppGames\') = 3)
			Case Else ; don't CopyFromLive
				$CopyFromLive = False
		EndSelect
		If $CopyFromLive Then NeoDirCopy($SrcPath, $App_InstallPath, False, True) ; And Not (FileExists($SrcPath & '\*.7z') Or FileExists($SrcPath & '\*.rar') Or FileExists($SrcPath & '\*.zip') Or FileExists($SrcPath & '\*.cab'))
	EndIf
	If Not $InstallFromAppPath Then ; Install-mode
		$InitUninstallReg = UninstallEnum()
		;NeoFileCopy(StringLeft($App_File, StringLen($App_File) - 4) & '.*', $App_InstallPath & '\', 9) ;Copy in case App locks path after install
		NeoDirCopy(@StartMenuCommonDir, $TempDir & '\sm1')
		NeoDirCopy(@StartMenuDir, $TempDir & '\sm1')
	EndIf
	$a = FilterGates($App_Assembly)
	For $i = 1 To $a[0] ; <Assembly> Section
		$CTV = ConvertToVars($a[$i])
		$NoWait = StringInStr($CTV, '#NoWait#') Or $App_AssemblyNoWait
		If $NoWait Then $CTV = StringReplace($CTV, '#NoWait#', '')
		If StringLeft($CTV, 1) <> ';' Then
			$Installer = False
			Select
				Case StringInStr($CTV, '#ssInstall#')
					If GetInstallPath($App_InstallPath) Then $ssInstall = ssInstall()
				Case StringInStr($CTV, '#CMD#') Or StringInStr($CTV, '#DOS#')
					If GetInstallPath($App_InstallPath) Then
						If Not $ssInstall Then $ssInstall = ssInstall()
					EndIf
					If $NoWait Then
						Run(StringStripWS(StringReplace(StringReplace(ConvertFromVars($CTV), '#CMD#', ''), '#DOS#', ''), 3), $SrcPath, @SW_HIDE)
					Else
						RunWait(StringStripWS(StringReplace(StringReplace(ConvertFromVars($CTV), '#CMD#', ''), '#DOS#', ''), 3), $SrcPath, @SW_HIDE)
					EndIf
				Case StringInStr($CTV, '#Registry#') Or StringInStr($CTV, '#ProcessRegistry#') Or StringInStr($CTV, '#ImportRegistry#') Or StringInStr($CTV, '#ApplyRegistry#')
					If GetInstallPath($App_InstallPath) Then
						If Not $ssInstall Then $ssInstall = ssInstall() ; And Not $InstallFromAppPath ??
						$ProcessRegistry = ProcessRegistry()
					EndIf
				Case StringInStr($CTV, '#Script#') Or StringInStr($CTV, '#ProcessScript#') Or StringInStr($CTV, '#RunScript#')
					If GetInstallPath($App_InstallPath) Then
						If Not $ssInstall Then $ssInstall = ssInstall()
						$ProcessScript = ProcessScript()
					EndIf
				Case StringInStr($CTV, '#RegisterDLL#') Or StringInStr($CTV, '#RegisterDLLs#')
					If GetInstallPath($App_InstallPath) Then
						If Not $ssInstall Then $ssInstall = ssInstall()
						$RegisterDLLs = RegisterDLLs()
					EndIf
				Case StringInStr($CTV, '#InstallFonts#') Or StringInStr($CTV, '#InstallFont#')
					If GetInstallPath($App_InstallPath) Then
						If Not $ssInstall Then $ssInstall = ssInstall()
						$InstallFonts = InstallFonts()
					EndIf
				Case StringInStr($CTV, '#ShortcutS#') Or StringInStr($CTV, '#ProcessShortcutS#')
					If GetInstallPath($App_InstallPath) Then
						If Not $ssInstall Then $ssInstall = ssInstall()
						$ProcessShortcutS = ProcessShortcutS()
					EndIf
				Case StringInStr($CTV, '#AppPathFolderIcon#') Or StringInStr($CTV, '#AppPathFolderIcons#')
					If GetInstallPath($App_InstallPath) Then
						If Not $ssInstall Then $ssInstall = ssInstall()
						$AppPathFolderIcon = AppPathFolderIcon()
					EndIf
				Case StringInStr($CTV, '#ApplyPatch#')
					If GetInstallPath($App_InstallPath) Then
						If Not $ssInstall Then $ssInstall = ssInstall()
						$ApplyPatch = ApplyPatch()
					EndIf
				Case Else
					If Not $InstallFromAppPath Then ; Install-mode only
						Select
							Case StringInStr($CTV, '%ProcessKill%')
								ProcessKill(StringStripWS(ConvertFromVars(StringReplace(StringReplace($CTV, '"', ''), '%ProcessKill% ', '')), 3))
							Case StringInStr($CTV, '%AddonInstaller%')
								$Installer = AddonInstaller(StringStripWS(ConvertFromVars(StringReplace(StringReplace($CTV, '"', ''), '%AddonInstaller% ', '')), 3), $SrcPath)
							Case StringInStr($CTV, '%WaitForIt%')
								WaitForIt(StringStripWS(ConvertFromVars(StringReplace(StringReplace($CTV, '"', ''), '%WaitForIt% ', '')), 3))
							Case StringInStr($CTV, '%ClickMe%')
								$arg = StringSplit(StringStripWS(ConvertFromVars(StringReplace($CTV, '%ClickMe% ', '')), 3), '"')
								If IsArray($arg) Then
									;_ArrayDisplay($arg)
									Switch $arg[0]
										Case 3
											ClickMe($arg[2])
										Case 5
											ClickMe($arg[2], $arg[4])
										Case 7
											ClickMe($arg[2], $arg[4], $arg[6])
									EndSwitch
								EndIf
							Case StringInStr($CTV, '%SelectMe%')
								SelectMe(StringStripWS(ConvertFromVars(StringReplace(StringReplace($CTV, '"', ''), '%SelectMe% ', '')), 3))
;~ 								$arg = StringSplit(StringStripWS(ConvertFromVars(StringReplace($CTV, '%SelectMe% ', '')), 3), '"')
;~ 								If IsArray($arg) Then
;~ 									;_ArrayDisplay($arg)
;~ 									Switch $arg[0]
;~ 										Case 3
;~ 											SelectMe($arg[2])
;~ 									EndSwitch
;~ 								EndIf
							Case StringInStr($CTV, '%SendMe%')
								SendMe(StringStripWS(ConvertFromVars(StringReplace(StringReplace($CTV, '"', ''), '%SendMe% ', '')), 3))
;~ 								$arg = StringSplit(StringStripWS(ConvertFromVars(StringReplace($CTV, '%SendMe% ', '')), 3), '"')
;~ 								If IsArray($arg) Then
;~ 									;_ArrayDisplay($arg)
;~ 									Switch $arg[0]
;~ 										Case 3
;~ 											SendMe($arg[2])
;~ 									EndSwitch
;~ 								EndIf
							Case StringInStr($CTV, '%WaitForMe%')
								$arg = StringSplit(StringStripWS(ConvertFromVars(StringReplace($CTV, '%WaitForMe% ', '')), 3), '"')
								If IsArray($arg) Then
									;_ArrayDisplay($arg)
									Switch $arg[0]
										Case 3
											WaitForMe($arg[2])
										Case 5
											WaitForMe($arg[2], $arg[4])
										Case 7
											WaitForMe($arg[2], $arg[4], $arg[6])
									EndSwitch
								EndIf
							Case StringInStr($CTV, '%CloseMe%')
								$arg = StringSplit(StringStripWS(ConvertFromVars(StringReplace($CTV, '%CloseMe% ', '')), 3), '"')
								If IsArray($arg) Then
									;_ArrayDisplay($arg)
									Switch $arg[0]
										Case 3
											CloseMe($arg[2])
										Case 5
											CloseMe($arg[2], $arg[4])
									EndSwitch
								EndIf
							Case StringInStr($CTV, '%AddToHosts%')
								AddToHosts(StringStripWS(ConvertFromVars(StringReplace(StringReplace($CTV, '"', ''), '%AddToHosts% ', '')), 3))
							Case StringInStr($CTV, '%SetUserFTA%')
								If $NoWait Then
									Run(ConvertFromVars($CTV), $SrcPath, @SW_HIDE)
								Else
									RunWait(ConvertFromVars($CTV), $SrcPath, @SW_HIDE)
								EndIf
							Case StringInStr($CTV, '%Extract%')
								If $NoWait Then
									Run(ConvertFromVars($CTV), $SrcPath, @SW_HIDE)
								Else
									RunWait(ConvertFromVars($CTV), $SrcPath, @SW_HIDE)
								EndIf
							Case StringInStr($CTV, '%MSIexec%')
								If $NoWait Then
									$Installer = Run('msiexec.exe /i ' & StringStripWS(StringReplace(ConvertFromVars($CTV), '%MSIexec%', ''), 3), $SrcPath, @SW_SHOWNOACTIVATE) <> 0
								Else
									$Installer = RunWait('msiexec.exe /i ' & StringStripWS(StringReplace(ConvertFromVars($CTV), '%MSIexec%', ''), 3), $SrcPath, @SW_SHOWNOACTIVATE) <> 0
								EndIf
							Case StringRight($CTV, 4) = '.cmd' Or StringRight($CTV, 4) = '.bat' Or StringRight($CTV, 5) = '.cmd"' Or StringRight($CTV, 5) = '.bat"'
								If $NoWait Then
									Run(ConvertFromVars($CTV), $SrcPath, @SW_HIDE)
								Else
									RunWait(ConvertFromVars($CTV), $SrcPath, @SW_HIDE)
								EndIf
							Case IsAssocFile($CTV, '.reg')
								ImportReg(StringStripWS(ConvertFromVars($CTV), 3), $SrcPath)
							Case IsAssocFile($CTV, '.msi')
								If $NoWait Then
									$Installer = Run('msiexec.exe /i ' & StringStripWS(ConvertFromVars($CTV), 3), $SrcPath, @SW_SHOWNOACTIVATE) <> 0
								Else
									$Installer = RunWait('msiexec.exe /i ' & StringStripWS(ConvertFromVars($CTV), 3), $SrcPath, @SW_SHOWNOACTIVATE) <> 0
								EndIf
							Case Else
								If $NoWait Then
									$Installer = Run(ConvertFromVars($CTV), $SrcPath, @SW_SHOWNOACTIVATE) <> 0 ;The is likely an installer or setup program of some kind
								Else
									$Installer = RunWait(ConvertFromVars($CTV), $SrcPath, @SW_SHOWNOACTIVATE) <> 0 ;The is likely an installer or setup program of some kind
								EndIf
						EndSelect
					EndIf
			EndSelect
		EndIf
	Next
	If Not $InstallFromAppPath Then ; Install-mode
		If $App_smSource = '' Or Not (FileExists(@StartMenuCommonDir & '\' & $App_smSource) Or FileExists(@StartMenuDir & '\' & $App_smSource) Or FileExists(@ProgramsCommonDir & '\' & $App_smSource) Or FileExists(@ProgramsDir & '\' & $App_smSource)) Then
			; this needs refined to use recursion for more thorough scanning...
			Local $App_smSource_Original = $App_smSource
			NeoDirCopy(@StartMenuCommonDir, $TempDir & '\sm2')
			NeoDirCopy(@StartMenuDir, $TempDir & '\sm2')
			Local $sm1 = _FileListToArray($TempDir & '\sm1', '*', 2)
			Local $sm2 = _FileListToArray($TempDir & '\sm2', '*', 2)
			$App_smSource = ''
			If IsArray($sm1) And IsArray($sm2) Then
				If $sm1[0] = $sm2[0] Then
					$sm1 = _FileListToArray($TempDir & '\sm1\Programs', '*', 2)
					$sm2 = _FileListToArray($TempDir & '\sm2\Programs', '*', 2)
					If IsArray($sm1) And IsArray($sm2) Then
						If $sm1[0] < $sm2[0] Then
							_ArraySort($sm1, 0, 1)
							_ArraySort($sm2, 0, 1)
							$Found = False
							For $i = 1 To $sm1[0]
								If $sm1[$i] <> $sm2[$i] Then
									$Found = True
									ExitLoop
								EndIf
							Next
							If Not $Found Then
								$Found = True
								$i = $sm2[0]
							EndIf
							If $Found Then
								$App_smSource = $sm2[$i]
								$sm1 = _FileListToArray($TempDir & '\sm2\Programs\' & $App_smSource, '*', 1) ;check if files=0
								If @error = 4 Then
									$sm2 = _FileListToArray($TempDir & '\sm2\Programs\' & $App_smSource, '*', 2) ;and folders=1
									If IsArray($sm2) And $sm2[0] = 1 Then $App_smSource = $sm2[1]
								EndIf
							EndIf
						EndIf
					EndIf
				ElseIf $sm1[0] < $sm2[0] Then
					_ArraySort($sm1, 0, 1)
					_ArraySort($sm2, 0, 1)
					$Found = False
					For $i = 1 To $sm1[0]
						If $sm1[$i] <> $sm2[$i] Then
							$Found = True
							ExitLoop
						EndIf
					Next
					If Not $Found Then
						$Found = True
						$i = $sm2[0]
					EndIf
					If $Found Then
						$App_smSource = $sm2[$i]
						$sm1 = _FileListToArray($TempDir & '\sm2\' & $App_smSource, '*', 1) ;check if files=0
						If @error = 4 Then
							$sm2 = _FileListToArray($TempDir & '\sm2\' & $App_smSource, '*', 2) ;and folders=1
							If IsArray($sm2) And $sm2[0] = 1 Then $App_smSource = $sm2[1]
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		If $App_smSource = '' Then ; unlikely installer created one so need to derive one instead:
			If $App_smSource_Original = '' Then
				$App_smSource = GetApp_smSource($App_smSource)
			Else
				$App_smSource = $App_smSource_Original
			EndIf
		EndIf
		$App_Uninstall_Diff = ProcessUninstall()
	EndIf
EndFunc

Func ProcessRegistry() ; <Registry>
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|ProcessRegistry()' & @CRLF)
	Local $Found = True
	If $App_RegFile = '' Then $App_RegFile = File2String(_GetAuxFilename($App_InstallPath, '.reg'))
	If $App_RegFile <> '' Then
		If FileExists(@TempDir & '\' & $TempREG) Then FileDelete(@TempDir & '\' & $TempREG)
		If IsGated($App_RegFile, $App_OSArchGated) Then
			Local $HeaderInUse = False
			$App_RegEntries = FilterGates(SingleLine2Multi($App_RegFile, @CRLF))
			If $App_RegEntries[0] > 0 Then
				Local $i, $Line, $File = FileOpen(@TempDir & '\' & $TempREG, 10)
				FileWriteLine($File, 'Windows Registry Editor Version 5.00')
				FileWriteLine($File, '')
				For $i = 1 To $App_RegEntries[0]
					$Line = StringStripWS(ConvertFromVars(ConvertToVars($App_RegEntries[$i], True), True), 3)
					If ($Line = 'Windows Registry Editor Version 5.00') Or ($Line = 'REGEDIT4') Then
						$HeaderInUse = True
					Else
						If $HeaderInUse And $Line <> '' Then $HeaderInUse = False
						If Not $HeaderInUse Then FileWriteLine($File, $Line)
					EndIf
				Next
				FileClose($File)
			EndIf
		Else
			String2File(ConvertFromVars(ConvertToVars($App_RegFile, True), True), @TempDir & '\' & $TempREG)
		EndIf
		If FileExists(@TempDir & '\' & $TempREG) Then
			If $App_OSArchGated Or Not (@AutoItX64 And $App_Architecture < 2) Then ;Arch dependent (Is_x86 or Is_x64, or dual-arch)
				RunWait($CLIprefix & 'reg import ' & @TempDir & '\' & $TempREG, '.', @SW_HIDE)
				RunWait('regedit /s ' & @TempDir & '\' & $TempREG, '.', @SW_HIDE)
				;ShellExecuteWait('regedit', ' /s ' & @TempDir & '\' & $TempREG, '.', 'Open', @SW_HIDE); Alternative
			Else
				Switch $App_Architecture
					Case 0 ;Import via x86 AND x64
						RunWait(RunWait86() & $CLIprefix & 'reg import ' & @TempDir & '\' & $TempREG, '.', @SW_HIDE)
						RunWait(RunWait86() & 'regedit /s ' & @TempDir & '\' & $TempREG, '.', @SW_HIDE)
						RunWait($CLIprefix & 'reg import ' & @TempDir & '\' & $TempREG, '.', @SW_HIDE)
						RunWait('regedit /s ' & @TempDir & '\' & $TempREG, '.', @SW_HIDE)
					Case 1 ;Import via x86 only
						RunWait(RunWait86() & $CLIprefix & 'reg import ' & @TempDir & '\' & $TempREG, '.', @SW_HIDE)
						RunWait(RunWait86() & 'regedit /s ' & @TempDir & '\' & $TempREG, '.', @SW_HIDE)
				EndSwitch
			EndIf
			If FileExists(@TempDir & '\' & $TempREG) Then FileDelete(@TempDir & '\' & $TempREG)
		EndIf
		If $ExtRegOnly Then
			$App_RegEntries[0] = 0
			ReDim $App_RegEntries[$App_RegEntries[0] + 1]
		EndIf
	EndIf
	Return True
EndFunc

Func ProcessScript() ; <Script> section
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|ProcessScript()' & @CRLF)
	Local $i, $Line, $File, $TempFile = $TempCMD, $CurrentWorkingDir = @WorkingDir, $Found = True
	If $App_CmdFile = '' Then $App_CmdFile = File2String(_GetAuxFilename($App_InstallPath, '.cmd'))
	If $App_CmdFile = '' Then $App_CmdFile = File2String(_GetAuxFilename($App_InstallPath, '.bat'))
	If $App_CmdFile <> '' Then
		If Not FileExists($App_InstallPath) Or StringInStr(FileGetAttrib($App_InstallPath), 'R') Or $AppWriteProtected Then $TempFile = @TempDir & '\' & $TempCMD
		If FileExists($App_InstallPath) Then FileChangeDir($App_InstallPath) ;works better if located at the install path
		If IsGated($App_CmdFile, $Found) Then
			$App_Script = FilterGates(SingleLine2Multi($App_CmdFile, @CRLF))
			If $App_Script[0] > 0 Then
				$File = FileOpen($TempFile, 10)
				If $File <> -1 Then
					For $i = 1 To $App_Script[0]
						$Line = StringStripWS(ConvertFromVars(ConvertToVars($App_Script[$i])), 3)
						If IsAssocFile($Line, '.msi') Then
							$Line = 'msiexec.exe /i ' & StringStripWS($Line, 3)
						ElseIf IsAssocFile($Line, '.reg') Then
							FileWriteLine($File, 'reg import ' & StringStripWS($Line, 3))
							$Line = 'regedit /s ' & StringStripWS($Line, 3)
						EndIf
						FileWriteLine($File, $Line)
					Next
					FileClose($File) ; $App_InstallPath & '\' & $TempCMD
				EndIf
			EndIf
		Else
			If Not String2File(ConvertFromVars(ConvertToVars($App_CmdFile)), $TempFile) Then
				$AppWriteProtected = True
			EndIf
		EndIf
		If FileExists($TempFile) Then
			;MsgBox(0,"Tst","Wait") ;Pauses running modified script For Debugging (%AppPath%\~SetupS.cmd)
			RunWait($TempFile, '.', @SW_HIDE)
			If Not DeleteMe($TempFile) Then $AppWriteProtected = True
		EndIf
		FileChangeDir($CurrentWorkingDir)
		If $ExtCmdOnly Then
			$App_Script[0] = 0
			ReDim $App_Script[$App_Script[0] + 1]
		EndIf
	EndIf
	Return True
EndFunc

Func ProcessShortcutS()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|ProcessShortcutS()' & @CRLF)
	If $App_NoneThing Then Return True
	Local $a, $i, $j, $Line, $TargetFile = '', $UseLegacyStartMenuDest = False, $Found = False, $Test
	Local $App_KeepInFolder_MS = $App_KeepInFolder, $App_KeepAll_MS = $App_KeepAll, $App_NoIcons_MS = $App_NoIcons
	Local $App_NeverSort_MS = $App_NeverSort, $MenuStyle_MS = $MenuStyle, $scFlagsParsed, $OSArchGate, $OSVersionGate

	;------------------------- Validate pre-existing Shortcut(s) -------------------------
	;check special locations
	;_ArrayDisplay($App_scKeep, @ScriptLineNumber)
	For $i = 1 To $App_scKeep[0]
		ValidateShortcut(@StartMenuDir & '\' & $App_scKeep[$i] & '.lnk')
		ValidateShortcut(@StartMenuCommonDir & '\' & $App_scKeep[$i] & '.lnk')
		ValidateShortcut(@ProgramsDir & '\' & $App_scKeep[$i] & '.lnk')
		ValidateShortcut(@ProgramsCommonDir & '\' & $App_scKeep[$i] & '.lnk')
		ValidateShortcut(@StartupDir & '\' & $App_scKeep[$i] & '.lnk')
		ValidateShortcut(@StartupCommonDir & '\' & $App_scKeep[$i] & '.lnk')
		ValidateShortcut(@DesktopCommonDir & '\' & $App_scKeep[$i] & '.lnk')
		ValidateShortcut(@DesktopDir & '\' & $App_scKeep[$i] & '.lnk')
		ValidateShortcut($SendToPath & '\' & $App_scKeep[$i] & '.lnk')
		ValidateShortcut($QuickLaunch & '\' & $App_scKeep[$i] & '.lnk')
	Next

	;------------------------- Shortcut Creating -------------------------
	If Not ($ppGamesShortcutsSkip And $App_Type = 5) Then
		If FileExists($App_InstallPath) Then ; create shortcuts for ppApp/ppGame and extra shortcuts for SetupS/ssApp
			For $i = 1 To $App_scCount
				;$scFlagsParsed = StringSplit($App_scFlags[$i], '|')
				;For $j = 1 To $scFlagsParsed[0]
				;	$scFlagsParsed[$j]=StringStripWS(StringReplace($scFlagsParsed[$j], '#', ''), 3)
				;Next
				SetGates($App_scFlags[$i], $OSArchGate, $OSVersionGate, False)
				;If $OSArchGate And $OSVersionGate Then
				If 1 = 1 Then ; Glenn 2023 - turn off the gates and make ALL shortcuts
					$App_scEXE[$i] = ConvertFromVars(ConvertToVars($App_scEXE[$i]))
					If $App_scEXE[$i] <> '' And StringInStr($App_scEXE[$i], ':') = 0 Then $App_scEXE[$i] = $App_InstallPath & '\' & $App_scEXE[$i]
					If FileExists($App_scEXE[$i]) Then
						$App_scArgs[$i] = ConvertFromVars(ConvertToVars($App_scArgs[$i])) ;If $App_scArgs[$i] <> '' Then
						$App_scWorkDir[$i] = ConvertFromVars(ConvertToVars($App_scWorkDir[$i]))
						If $App_scWorkDir[$i] = '' Then
							If $App_scWorkDir[$i] = '' Then $App_scWorkDir[$i] = ConvertFromVars(ConvertToVars(GetFolderPath($App_scEXE[$i])))
							If $App_scWorkDir[$i] = '' Then $App_scWorkDir[$i] = $App_InstallPath
						Else
							If StringInStr($App_scWorkDir[$i], ':') = 0 Then $App_scWorkDir[$i] = $App_InstallPath & '\' & $App_scWorkDir[$i]
						EndIf
						$App_scIcon[$i] = ConvertFromVars(ConvertToVars($App_scIcon[$i]))
						If $App_scIcon[$i] <> '' And StringInStr($App_scIcon[$i], ':') = 0 Then $App_scIcon[$i] = $App_InstallPath & '\' & $App_scIcon[$i]
						$App_scLNK[$i] = ConvertFromVars(ConvertToVars($App_scLNK[$i]))
						If StringInStr($App_scLNK[$i], '\') > 0 Then
							DirCreate($TempDir & '\' & $scFolder & '\' & StringLeft($App_scLNK[$i], StringInStr($App_scLNK[$i], '\', -1, -1) - 1))
						Else
							DirCreate($TempDir & '\' & $scFolder)
						EndIf
						If $App_scIndex[$i] = '' Then $App_scIndex[$i] = 0
						If $App_scState[$i] = '' Then $App_scState[$i] = @SW_SHOWNORMAL
						$Test = FileCreateShortcut($App_scEXE[$i], $TempDir & '\' & $scFolder & '\' & $App_scLNK[$i] & '.lnk', $App_scWorkDir[$i], $App_scArgs[$i], $App_scDesc[$i], $App_scIcon[$i], $App_scKey[$i], $App_scIndex[$i], @SW_SHOWNORMAL)
						If $App_scExt[$i] <> '' Then
							Local $assoc = StringSplit($App_scExt[$i], ' ')
							For $j = 1 To $assoc[0]
								CreateFileAssociation($assoc[$j], StringReplace($App_scLNK[$i], ' ', '') & '.' & $assoc[$j], $App_Title, $App_scEXE[$i])
							Next
						EndIf
					Else
					EndIf
				EndIf
			Next
		EndIf

		;------------------------- Shortcut Placement (StartMenu, Desktop, etc.) -------------------------
		$App_smSource = ConvertFromVars(ConvertToVars($App_smSource))
		$App_NeverSort = ($App_NeverSort Or $App_smSource = '' Or StringInStr($App_InstallPath, 'nonething'))
		If Not $App_NeverSort Then ; Sort!
			If $App_AlwaysSort And $MenuStyle = 0 Then $MenuStyle = 1
			If $MenuStyle = 0 And $App_Type < 5 Then ; some standard StartMenu overrides
				$App_KeepInFolder = True
				$App_KeepAll = True
				$App_NoIcons = True
			EndIf
			If $MetroPresent And $App_MetroFriendly And ($App_scKeep[0] > 0 Or $App_scCount > 0) Then
				;If $MetroPresent And $App_MetroFriendly And $App_scKeep[0] > 0 Then
				$App_KeepInFolder = False
				$App_KeepAll = False
			EndIf
			;Determine StartMenu final destination (standard/advanced)
			If FileExists(GetMenuDefs(1)) Then ; use Catalog
				Local $MenuCatalog[1]
				If $WholeCatalog[0][0] = '' Then $WholeCatalog = IniReadSection(GetMenuDefs(1), 'Catalog')
				If IsArray($WholeCatalog) Then
					If $App_Catalog[0] > 0 Then
						$MenuCatalog = $App_Catalog
					Else ; rebuild it from legacy
						For $i = 1 To $App_StartMenu[0]
							For $j = 1 To $WholeCatalog[0][0]
								;MsgBox(4096, '', 'Key: ' & $WholeCatalog[$i][0] & @CRLF & 'Value: ' & $WholeCatalog[$i][1])
								If ($WholeCatalog[$j][1] = $App_StartMenu[$i]) Then
									$MenuCatalog[0] += 1
									ReDim $MenuCatalog[$MenuCatalog[0] + 1]
									$MenuCatalog[$MenuCatalog[0]] = $WholeCatalog[$j][0]
								EndIf
							Next
						Next
					EndIf
					If FileExists($ToolsPath) Then ; remove any found shortcuts from other menu styles
						For $i = 1 To $MenuStyles[0][0]
							For $j = 1 To $MenuCatalog[0]
								If ($MenuStyle <> $MenuStyles[$i][0]) Or (Not $App_MakeStartMenu) Or ($App_MakeStartMenu And $App_AllUsers) Then
									If RemoveShortcutS(@ProgramsDir & '\' & IniRead($ToolsPath & '\Menus\' & $MenuStyles[$i][1] & 'Menu\Definitions.ini', 'Catalog', $MenuCatalog[$j], '')) Then $RemovedMenuItem = True
								EndIf
								If ($MenuStyle <> $MenuStyles[$i][0]) Or (Not $App_MakeStartMenu) Or ($App_MakeStartMenu And Not $App_AllUsers) Then
									If RemoveShortcutS(@ProgramsCommonDir & '\' & IniRead($ToolsPath & '\Menus\' & $MenuStyles[$i][1] & 'Menu\Definitions.ini', 'Catalog', $MenuCatalog[$j], '')) Then $RemovedMenuItem = True
								EndIf
							Next
						Next
					EndIf
					If $MenuStyle > 0 Then
						For $i = 1 To $App_StartMenu[0]
							If Not FileExists($ssTekResources & '\Menu\' & $App_StartMenu[$i]) Then InstallMenu($MenuStyle)
							If $App_KeepInFolder And StringLower(StringRight($App_StartMenu[$i], StringLen($App_smSource))) <> StringLower($App_smSource) Then $App_StartMenu[$i] = $App_StartMenu[$i] & '\' & $App_smSource
						Next
					EndIf
				Else
					$UseLegacyStartMenuDest = True
				EndIf
			Else
				$UseLegacyStartMenuDest = True
			EndIf
			Switch $MenuStyle
				Case 1 ; 'LastOS'
					For $i = 1 To $App_smLegacySecondary[0]
						If RemoveShortcutS(@ProgramsDir & '\' & $App_smLegacySecondary[$i]) Then $RemovedMenuItem = True
						If RemoveShortcutS(@ProgramsCommonDir & '\' & $App_smLegacySecondary[$i]) Then $RemovedMenuItem = True
					Next
					For $i = 1 To $App_smLegacyPrimary[0]
						If (Not $App_MakeStartMenu) Or ($App_MakeStartMenu And $App_AllUsers) Then
							If RemoveShortcutS(@ProgramsDir & '\' & $App_smLegacyPrimary[$i]) Then $RemovedMenuItem = True
						EndIf
						If (Not $App_MakeStartMenu) Or ($App_MakeStartMenu And Not $App_AllUsers) Then
							If RemoveShortcutS(@ProgramsCommonDir & '\' & $App_smLegacyPrimary[$i]) Then $RemovedMenuItem = True
						EndIf
					Next
					If $UseLegacyStartMenuDest Then ; use legacy sorting
						$App_StartMenu = $App_smLegacyPrimary
						For $i = 1 To $App_StartMenu[0]
							If Not FileExists($ssTekResources & '\Menu\' & $App_smLegacyPrimary[$i]) Then InstallMenu($MenuStyle)
							If $App_KeepInFolder And StringLower(StringRight($App_StartMenu[$i], StringLen($App_smSource))) <> StringLower($App_smSource) Then $App_StartMenu[$i] = $App_StartMenu[$i] & '\' & $App_smSource
						Next
					EndIf
				Case 2 ; 'Kazz'
					For $i = 1 To $App_smLegacyPrimary[0]
						If RemoveShortcutS(@ProgramsDir & '\' & $App_smLegacyPrimary[$i]) Then $RemovedMenuItem = True
						If RemoveShortcutS(@ProgramsCommonDir & '\' & $App_smLegacyPrimary[$i]) Then $RemovedMenuItem = True
					Next
					For $i = 1 To $App_smLegacySecondary[0]
						If (Not $App_MakeStartMenu) Or ($App_MakeStartMenu And $App_AllUsers) Then
							If RemoveShortcutS(@ProgramsDir & '\' & $App_smLegacySecondary[$i]) Then $RemovedMenuItem = True
						EndIf
						If (Not $App_MakeStartMenu) Or ($App_MakeStartMenu And Not $App_AllUsers) Then
							If RemoveShortcutS(@ProgramsCommonDir & '\' & $App_smLegacySecondary[$i]) Then $RemovedMenuItem = True
						EndIf
					Next
					If $UseLegacyStartMenuDest Then ; use legacy sorting
						$App_StartMenu = $App_smLegacySecondary
						For $i = 1 To $App_StartMenu[0]
							If Not FileExists($ssTekResources & '\Menu\' & $App_smLegacySecondary[$i]) Then InstallMenu($MenuStyle)
							If $App_KeepInFolder And StringLower(StringRight($App_StartMenu[$i], StringLen($App_smSource))) <> StringLower($App_smSource) Then $App_StartMenu[$i] = $App_StartMenu[$i] & '\' & $App_smSource
						Next
					EndIf
				Case Else ; Standard (or otherwise)
					ReDim $App_StartMenu[2]
					$App_StartMenu[0] = 1
					$App_StartMenu[1] = $App_smSource
					For $i = 1 To $App_smLegacySecondary[0]
						If RemoveShortcutS(@ProgramsDir & '\' & $App_smLegacySecondary[$i]) Then $RemovedMenuItem = True
						If RemoveShortcutS(@ProgramsCommonDir & '\' & $App_smLegacySecondary[$i]) Then $RemovedMenuItem = True
					Next
					For $i = 1 To $App_smLegacyPrimary[0]
						If RemoveShortcutS(@ProgramsDir & '\' & $App_smLegacyPrimary[$i]) Then $RemovedMenuItem = True
						If RemoveShortcutS(@ProgramsCommonDir & '\' & $App_smLegacyPrimary[$i]) Then $RemovedMenuItem = True
					Next
			EndSwitch
			$smDestination = $App_StartMenu
			For $i = 1 To $App_StartMenu[0]
				If $App_Type = 5 And $MenuStyle = 0 Then
					$smDestination[$i] = $GamesProgramsDir & '\' & $App_StartMenu[$i]
				Else
					$smDestination[$i] = $ProgramsDir_EX & '\' & $App_StartMenu[$i]
				EndIf
			Next
			If StringInStr($App_smSource, '\') > 0 Then
				$UberFolder = StringLeft($App_smSource, StringInStr($App_smSource, '\') - 1)
			Else
				$UberFolder = $App_smSource
			EndIf

			;Move shortcuts from All Users StartMenu to SetupS.Shortcuts
			If FileExists(@ProgramsCommonDir & '\' & $UberFolder) Then
				NeoDirCopy(@ProgramsCommonDir & '\' & $App_smSource, $TempDir & '\' & $scFolder)
				DirRemove(@ProgramsCommonDir & '\' & $UberFolder, 1)
;~ 				If $UberFolder <> '' Then
;~ 					If $OS_Linux Then
;~ 						FileDelete($LinuxHome & '\.config\menus\applications-merged\wine-Programs-' & $UberFolder & '*.menu')
;~ 					EndIf
;~ 				EndIf
			EndIf

			;Also check special locations
			For $i = 1 To $App_scKeep[0]
				If $remStartmenuRoot Then
					If ValidateShortcut(@StartMenuDir & '\' & $App_scKeep[$i] & '.lnk') Then FileMove(@StartMenuDir & '\' & $App_scKeep[$i] & '.lnk', $TempDir & '\' & $scFolder & '\', 9); from Current User 'StartMenu' (Root)
					If ValidateShortcut(@StartMenuCommonDir & '\' & $App_scKeep[$i] & '.lnk') Then FileMove(@StartMenuCommonDir & '\' & $App_scKeep[$i] & '.lnk', $TempDir & '\' & $scFolder & '\', 9); from All Users 'StartMenu' (Root)
				Else
					If ValidateShortcut(@StartMenuDir & '\' & $App_scKeep[$i] & '.lnk') Then FileCopy(@StartMenuDir & '\' & $App_scKeep[$i] & '.lnk', $TempDir & '\' & $scFolder & '\', 9); from Current User 'StartMenu' (Root)
					If ValidateShortcut(@StartMenuCommonDir & '\' & $App_scKeep[$i] & '.lnk') Then FileCopy(@StartMenuCommonDir & '\' & $App_scKeep[$i] & '.lnk', $TempDir & '\' & $scFolder & '\', 9); from All Users 'StartMenu' (Root)
				EndIf
				If $remProgramsRoot Then
					If ValidateShortcut(@ProgramsDir & '\' & $App_scKeep[$i] & '.lnk') Then FileMove(@ProgramsDir & '\' & $App_scKeep[$i] & '.lnk', $TempDir & '\' & $scFolder & '\', 9); from Current User 'Programs'
					If ValidateShortcut(@ProgramsCommonDir & '\' & $App_scKeep[$i] & '.lnk') Then FileMove(@ProgramsCommonDir & '\' & $App_scKeep[$i] & '.lnk', $TempDir & '\' & $scFolder & '\', 9); from All Users 'Programs'
				Else
					If ValidateShortcut(@ProgramsDir & '\' & $App_scKeep[$i] & '.lnk') Then FileCopy(@ProgramsDir & '\' & $App_scKeep[$i] & '.lnk', $TempDir & '\' & $scFolder & '\', 9); from Current User 'Programs'
					If ValidateShortcut(@ProgramsCommonDir & '\' & $App_scKeep[$i] & '.lnk') Then FileCopy(@ProgramsCommonDir & '\' & $App_scKeep[$i] & '.lnk', $TempDir & '\' & $scFolder & '\', 9); from All Users 'Programs'
				EndIf
				If $remStartup Then
					If ValidateShortcut(@StartupDir & '\' & $App_scKeep[$i] & '.lnk') Then FileMove(@StartupDir & '\' & $App_scKeep[$i] & '.lnk', $TempDir & '\' & $scFolder & '\', 9); from Current User Startup
					If ValidateShortcut(@StartupCommonDir & '\' & $App_scKeep[$i] & '.lnk') Then FileMove(@StartupCommonDir & '\' & $App_scKeep[$i] & '.lnk', $TempDir & '\' & $scFolder & '\', 9); from All Users Startup
				Else
					If ValidateShortcut(@StartupDir & '\' & $App_scKeep[$i] & '.lnk') Then FileCopy(@StartupDir & '\' & $App_scKeep[$i] & '.lnk', $TempDir & '\' & $scFolder & '\', 9); from Current User Startup
					If ValidateShortcut(@StartupCommonDir & '\' & $App_scKeep[$i] & '.lnk') Then FileCopy(@StartupCommonDir & '\' & $App_scKeep[$i] & '.lnk', $TempDir & '\' & $scFolder & '\', 9); from All Users Startup
				EndIf
				If $remDesktop Then
					If ValidateShortcut(@DesktopDir & '\' & $App_scKeep[$i] & '.lnk') Then FileMove(@DesktopDir & '\' & $App_scKeep[$i] & '.lnk', $TempDir & '\' & $scFolder & '\', 9); from Current User Desktop
					If ValidateShortcut(@DesktopCommonDir & '\' & $App_scKeep[$i] & '.lnk') Then FileMove(@DesktopCommonDir & '\' & $App_scKeep[$i] & '.lnk', $TempDir & '\' & $scFolder & '\', 9); from All Users Desktop
				Else
					If ValidateShortcut(@DesktopDir & '\' & $App_scKeep[$i] & '.lnk') Then FileCopy(@DesktopDir & '\' & $App_scKeep[$i] & '.lnk', $TempDir & '\' & $scFolder & '\', 9); from Current User Desktop
					If ValidateShortcut(@DesktopCommonDir & '\' & $App_scKeep[$i] & '.lnk') Then FileCopy(@DesktopCommonDir & '\' & $App_scKeep[$i] & '.lnk', $TempDir & '\' & $scFolder & '\', 9); from All Users Desktop
				EndIf
				If $remSendto Then
					If ValidateShortcut($SendToPath & '\' & $App_scKeep[$i] & '.lnk') Then FileMove($SendToPath & '\' & $App_scKeep[$i] & '.lnk', $TempDir & '\' & $scFolder & '\', 9); from Current User SendTo
				Else
					If ValidateShortcut($SendToPath & '\' & $App_scKeep[$i] & '.lnk') Then FileCopy($SendToPath & '\' & $App_scKeep[$i] & '.lnk', $TempDir & '\' & $scFolder & '\', 9); from Current User SendTo
				EndIf
				If $remQuickLaunch Then
					If ValidateShortcut($QuickLaunch & '\' & $App_scKeep[$i] & '.lnk') Then FileMove($QuickLaunch & '\' & $App_scKeep[$i] & '.lnk', $TempDir & '\' & $scFolder & '\', 9); from Current User QuickLaunch
				Else
					If ValidateShortcut($QuickLaunch & '\' & $App_scKeep[$i] & '.lnk') Then FileCopy($QuickLaunch & '\' & $App_scKeep[$i] & '.lnk', $TempDir & '\' & $scFolder & '\', 9); from Current User QuickLaunch
				EndIf
				If FileExists($TempDir & '\' & $scFolder & '\' & $App_scKeep[$i] & '.lnk') Then
					If $remTaskbarPin Then PinItem($TempDir & '\' & $scFolder & '\' & $App_scKeep[$i] & '.lnk', 'Taskbar', False)
					If $remStartmenuPin Then PinItem($TempDir & '\' & $scFolder & '\' & $App_scKeep[$i] & '.lnk', 'Startmenu', False)
				EndIf
			Next

			;Create (Advanced) or remake (Standard) shortcuts to the Current User StartMenu
			If FileExists(@ProgramsDir & '\' & $UberFolder) Then
				NeoDirCopy(@ProgramsDir & '\' & $App_smSource, $TempDir & '\' & $scFolder)
				DirRemove(@ProgramsDir & '\' & $UberFolder, 1)
			EndIf
			If FileExists(@ProgramsCommonDir & '\' & $UberFolder) Then
				NeoDirCopy(@ProgramsCommonDir & '\' & $App_smSource, $TempDir & '\' & $scFolder)
				DirRemove(@ProgramsCommonDir & '\' & $UberFolder, 1)
			EndIf
			If $App_Type = 5 Then
				If FileExists($GamesProgramsDir & '\' & $UberFolder) Then NeoDirCopy($GamesProgramsDir & '\' & $App_smSource, $TempDir & '\' & $scFolder)
				DirRemove($GamesProgramsDir & '\' & $UberFolder, 1)
			EndIf
;~ 			If $UberFolder <> '' Then
;~ 				If $OS_Linux Then
;~ 					FileDelete($LinuxHome & '\.config\menus\applications-merged\wine-Programs-' & $UberFolder & '*.menu')
;~ 				EndIf
;~ 			EndIf
			If Not $RegenOnly Then RemoveSpecials($TempDir & '\' & $scFolder) ; (all) from specialized locations ;Glenn_v20.02.13
			If $App_MakeStartMenu Then
				For $j = 1 To $smDestination[0]
					DirCreate($smDestination[$j]) ; ; now create (or remake) the STARTMENU shortcuts here:
					If $App_KeepAll Then
						NeoDirCopy($TempDir & '\' & $scFolder, $smDestination[$j], True)
					Else
						If $App_scKeep[0] > 0 Then ; Use all of these:
							For $i = 1 To $App_scKeep[0]
								If $App_KeepInFolder Then
									$KeepMe = WhereIsWhat($TempDir & '\' & $scFolder, GetFilename($App_scKeep[$i]) & '.lnk') & '\' & GetFilename($App_scKeep[$i]) & '.lnk'
									NeoFileCopy($KeepMe, $smDestination[$j] & '\' & $App_scKeep[$i] & '.lnk', True)
								Else
									$KeepMe = WhereIsWhat($TempDir & '\' & $scFolder, GetFilename($App_scKeep[$i]) & '.lnk') & '\' & GetFilename($App_scKeep[$i]) & '.lnk'
									NeoFileCopy($KeepMe, $smDestination[$j] & '\' & GetFilename($App_scKeep[$i]) & '.lnk', True)
								EndIf
							Next
						ElseIf $App_scCount > 0 Then ; Only the FIRST shortcut:
							;If $App_Type > 2 Then ;ppApp
							If $App_KeepInFolder Then
								$KeepMe = WhereIsWhat($TempDir & '\' & $scFolder, GetFilename($App_scLNK[1]) & '.lnk') & '\' & GetFilename($App_scLNK[1]) & '.lnk'
								NeoFileCopy($KeepMe, $smDestination[$j] & '\' & $App_scLNK[1] & '.lnk', True)
							Else
								$KeepMe = WhereIsWhat($TempDir & '\' & $scFolder, GetFilename($App_scLNK[1]) & '.lnk') & '\' & GetFilename($App_scLNK[1]) & '.lnk'
								NeoFileCopy($KeepMe, $smDestination[$j] & '\' & GetFilename($App_scLNK[1]) & '.lnk', True)
							EndIf
							;Else ;ssApp
							; N/A because this would be an unlikely scenario
							;EndIf
						EndIf
					EndIf
					If FileFindFirstFile($smDestination[$j] & '\*.*') = -1 Then $RemovedMenuItem = True
				Next
			EndIf

			;Create requested extra shortcuts for specialized locations: Desktop, QuickLaunch, SeJndTo, Startup and StartMenu root
			If $App_Type > 2 Then ; ppApp/ppGame
				If $App_scCount > 0 Then ; Only the FIRST shortcut:
					$TargetFile = MakeSpecials($App_scLNK[1])
				EndIf
			Else ; ssApp
				If $App_scKeep[0] > 0 Then ; Only the FIRST shortcut in the keep list:
					$TargetFile = MakeSpecials($App_scKeep[1])
				Else
;~ 				If $App_scCount > 0 Then ; Only the FIRST shortcut:
;~ 					MakeSpecials($App_scLNK[1])
;~ 				EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	; File Associations (process after shortcut creation in case it wipes them)
	If $TargetFile <> '' Then
		$a = FilterGates($App_FileType)
		For $i = 1 To $a[0]
			$Line = ConvertFromVars(ConvertToVars($a[$i]))
			CreateFileAssociation(StringReplace($Line, '.', ''), StringReplace($Line, '.', '') & 'SetupS', $App_Title, $TargetFile)
		Next
	EndIf

	; StartMenu Folder Icons
	If Not $App_NoIcons Then StartMenuIcons($App_StartMenu, $ProgramsDir_EX)

	$App_NeverSort = $App_NeverSort_MS
	$App_KeepInFolder = $App_KeepInFolder_MS
	$App_KeepAll = $App_KeepAll_MS
	$App_NoIcons = $App_NoIcons_MS
	If $App_AlwaysSort And $MenuStyle_MS = 0 Then $MenuStyle = SetMenuStyle($MenuStyle_MS)
	Return True
EndFunc

Func ProcessUninstall()
	If IsArray($InitUninstallReg) Then
		Local $j, $App_Uninstall = UninstallDiff($InitUninstallReg, UninstallEnum())
		If IsArray($App_Uninstall) And $App_Uninstall[0][0] > 0 Then
			; the following uses the Uninstall section of the Registry to find where App is actually installed (if needed)
			Local $App_InstallPath_new = ''
			If $App_Title <> '' Then $App_InstallPath_new = GetAppPathFromUninstall($App_Uninstall, $App_Title)
			If Not FileExists($App_InstallPath_new) Or NormalizeInstallPath($App_InstallPath_new) = '' Then $App_InstallPath_new = GetAppPathFromUninstall($App_Uninstall)
			If $App_InstallPath_new <> '' And $App_InstallPath_new <> $App_InstallPath And Not (GetInstallPath($App_InstallPath) Or StringInStr($App_InstallPath, 'nonething')) Then $App_InstallPath = $App_InstallPath_new
			;Uses the Uninstall section of the Registry to determine Architecture (if needed):
			If $App_Architecture = 0 Then
				;_ArrayDisplay($App_Uninstall, @ScriptLineNumber)
				For $j = 1 To $App_Uninstall[0][0]
					If RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' & '\' & $App_Uninstall[$j][0], 'UninstallString') <> '' Then
						If @AutoItX64 Then
							$App_Architecture = 2
						Else
							$App_Architecture = 1
						EndIf
					ElseIf @AutoItX64 And RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' & '\' & $App_Uninstall[$j][0], 'UninstallString') <> '' Then
						$App_Architecture = 1
					EndIf
					If $App_Architecture <> 0 Then ExitLoop
				Next
			EndIf
			Return $App_Uninstall
		Else
			Return ''
		EndIf
	Else
		Return ''
	EndIf
EndFunc

Func RegisterDLLs() ; <RegisterDLL>
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|RegisterDLLs()' & @CRLF)
	Local $a = FilterGates($App_RegisterDLL)
	If $a[0] > 0 Then
		Local $CurrentWorkingDir = @WorkingDir, $Line
		FileChangeDir($App_InstallPath) ;works better if located at the install path
		For $i = 1 To $a[0]
			$Line = ConvertFromVars(ConvertToVars($a[$i]))
			If Not FileExists($App_InstallPath & '\' & $Line) Then NeoFileCopy($SrcPath & '\' & $Line, $App_InstallPath & '\' & $Line)
			RunWait('regsvr32 /s ' & $Line)
		Next
		FileChangeDir($CurrentWorkingDir)
	EndIf
	Return True
EndFunc

Func RemoveShortcutS($from)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|RemoveShortcutS(): $from=' & $from & @CRLF)
	;Recursive function to delete any shortcuts ONLY used by ssApp's, ppApp's, or ppGames.
	Local $i, $j, $FileList, $Removed = False, $scFileList[1]
	If FileExists($from) Then
		$FileList = _FileListToArray($from, '*.*', 2) ; Return folders only
		If @error = 0 Then
			For $i = 1 To $FileList[0]
				$Removed = RemoveShortcutS($from & '\' & $FileList[$i]) Or $Removed
			Next
		EndIf
		$FileList = _FileListToArray($from, '*.*', 1) ; Return files only
		If @error = 0 Then
			For $i = 1 To $FileList[0]
				If $App_Type < 3 Then ; SetupS/ssApp
					If FileExists($TempDir & '\' & $scFolder) Then
						scFolderListToArray($TempDir & '\' & $scFolder, $scFileList)
						For $j = 1 To $scFileList[0]
							If ($FileList[$i] = $scFileList[$j]) Then
								FileRecycle($from & '\' & $FileList[$i])
;~ 								If $FileList[$i] <> '' Then
;~ 									If $OS_Linux Then
;~ 										FileDelete($LinuxHome & '\.config\menus\applications-merged\wine-Programs-' & StringReplace(StringReplace(StringReplace($from, @UserProfileDir & '\Start Menu\Programs\', '', 0) & '\' & $FileList[$i], '\', '-', 0), '.lnk', '', 0) & '.menu')
;~ 									EndIf
;~ 								EndIf
								$Removed = True
								ExitLoop
							EndIf
						Next
					EndIf
				Else ; ppApp/ppGame
					For $j = 1 To $App_scCount ;$App_scKeep[0]
						If ($FileList[$i] = $App_scLNK[$j] & '.lnk') Then
							FileRecycle($from & '\' & $FileList[$i])
;~ 							If $FileList[$i] <> '' Then
;~ 								If $OS_Linux Then
;~ 									FileDelete($LinuxHome & '\.config\menus\applications-merged\wine-Programs-' & StringReplace(StringReplace(StringReplace($from, @UserProfileDir & '\Start Menu\Programs\', '', 0) & '\' & $FileList[$i], '\', '-', 0), '.lnk', '', 0) & '.menu')
;~ 								EndIf
;~ 							EndIf
							$Removed = True
							ExitLoop
						EndIf
					Next
				EndIf
			Next
		EndIf
	EndIf
	Return $Removed
EndFunc

Func RemoveSpecials($What)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|RemoveSpecials(): $What=' & $What & @CRLF)
	Local $i, $FileList, $j, $fx1, $fx2
	If FileExists($What) Then
		$FileList = _FileListToArray($What, '*.*', 1) ; Return files only
		If @error = 0 Then
			For $i = 1 To $FileList[0]
				If $remStartmenuRoot Then
					DeleteMe(@StartMenuDir & '\' & $FileList[$i]); from Current User 'StartMenu' (Root)
					DeleteMe(@StartMenuCommonDir & '\' & $FileList[$i]); from All Users 'StartMenu' (Root)
				EndIf
				If $remProgramsRoot Then
					DeleteMe(@ProgramsDir & '\' & $FileList[$i]); from Current User 'Programs'
					DeleteMe(@ProgramsCommonDir & '\' & $FileList[$i]); from All Users 'Programs'
				EndIf
				If $remStartup Then
					DeleteMe(@StartupDir & '\' & $FileList[$i]); from Current User Startup
					DeleteMe(@StartupCommonDir & '\' & $FileList[$i]); from All Users Startup
				EndIf
				If $remDesktop Then
					DeleteMe(@DesktopDir & '\' & $FileList[$i]); from Current User Desktop
					DeleteMe(@DesktopCommonDir & '\' & $FileList[$i]); from All Users Desktop
				EndIf
				If $remSendto Then
					DeleteMe($SendToPath & '\' & $FileList[$i]); from Current User SendTo
					If FileExists(StringReplace($SendToPath, '\' & @UserName & '\', '\Default User\') & '\' & $FileList[$i]) Then
						EnumAllUserAccounts()
						For $j = 1 To $UserAccounts[0]
							DeleteMe(StringReplace($SendToPath, '\' & @UserName & '\', '\' & $UserAccounts[$j] & '\') & '\' & $FileList[$i]); from All Users SendTo
						Next
					EndIf
				EndIf
				If $remQuickLaunch Then
					DeleteMe($QuickLaunch & '\' & $FileList[$i]); from Current User QuickLaunch
					If FileExists(StringReplace($QuickLaunch, '\' & @UserName & '\', '\Default User\') & '\' & $FileList[$i]) Then
						EnumAllUserAccounts()
						For $j = 1 To $UserAccounts[0]
							DeleteMe(StringReplace($QuickLaunch, '\' & @UserName & '\', '\' & $UserAccounts[$j] & '\') & '\' & $FileList[$i]); from All Users QuickLaunch
						Next
					EndIf
				EndIf
				If $remTaskbarPin Then PinItem($What & '\' & $FileList[$i], 'Taskbar', False); remove pin from Taskbar
				If $remStartmenuPin Then PinItem($What & '\' & $FileList[$i], 'Startmenu', False); remove pin from Startmenu
			Next
		EndIf
		$FileList = _FileListToArray($What, '*.*', 2) ; Return folders only
		If @error = 0 Then
			For $i = 1 To $FileList[0]
				RemoveSpecials($What & '\' & $FileList[$i])
			Next
		EndIf
	EndIf
EndFunc

Func RunWait86()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|RunWait86(): @AutoItX64=' & @AutoItX64 & @CRLF)
	;#x86_only##cs
	If Not FileExists(@TempDir & '\RunWait86.exe') Then
		Local $CurrentWorkingDir = @WorkingDir
		FileChangeDir(@ScriptDir)
		FileInstall('.\bin\RunWait86.exe', @TempDir & '\RunWait86.exe', 1)
		Do
			Sleep(10)
		Until FileExists(@TempDir & '\RunWait86.exe')
		FileChangeDir($CurrentWorkingDir)
	EndIf
	Return @TempDir & '\RunWait86.exe '
	;#x86_only##ce
EndFunc

Func scFolderListToArray($from, ByRef $scFileList)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|scFolderListToArray(): $from=' & $from & @CRLF)
	;Recursive function to populate an array ($scFileList)
	;with shortcuts from a folder passed via $from
	Local $i, $j, $Found, $FileList
	$FileList = _FileListToArray($from, '*.*', 2) ; Return folders only
	If @error = 0 Then
		For $i = 1 To $FileList[0]
			scFolderListToArray($from & '\' & $FileList[$i], $scFileList)
		Next
	EndIf
	$FileList = _FileListToArray($from, '*.*', 1) ; Return files only
	If @error = 0 Then
		For $i = 1 To $FileList[0]
			$Found = False
			For $j = 1 To $scFileList[0]
				If $scFileList[$j] = $FileList[$i] Then
					$Found = True
					ExitLoop
				EndIf
			Next
			If Not $Found Then
				$scFileList[0] += 1
				ReDim $scFileList[$scFileList[0] + 1]
				$scFileList[$scFileList[0]] = $FileList[$i]
			EndIf
		Next
	EndIf
EndFunc

Func SetBitmap($hWnd, $hBitmap, $iOpacity)
	;If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|SetBitmap(): $iOpacity=' & $iOpacity & @CRLF)
	Local $hDC, $hMemDC, $tBlend, $tSize, $tSource
	$hDC = _WinAPI_GetDC($hWnd)
	$hMemDC = _WinAPI_CreateCompatibleDC($hDC)
	_WinAPI_SelectObject($hMemDC, $hBitmap)
	$tSize = _WinAPI_GetBitmapDimension($hBitmap)
	$tSource = DllStructCreate($tagPOINT)
	$tBlend = DllStructCreate($tagBLENDFUNCTION)
	DllStructSetData($tBlend, 'Alpha', $iOpacity)
	DllStructSetData($tBlend, 'Format', 1)
	_WinAPI_UpdateLayeredWindow($hWnd, $hDC, 0, DllStructGetPtr($tSize), $hMemDC, DllStructGetPtr($tSource), 0, DllStructGetPtr($tBlend), $ULW_ALPHA)
	_WinAPI_ReleaseDC($hWnd, $hDC)
	_WinAPI_DeleteDC($hMemDC)
EndFunc

Func SetGates($Line, ByRef $OSArchGate, ByRef $OSVersionGate, $Directive = True)
	;If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|SetGates(): $Line=' & $Line & @CRLF)
	Local $d = '', $Found, $t1, $t2, $t3, $t4, $t5, $Test, $compare, $gate
	If $Directive Then $d = '#'
	$OSArchGate = True
	$OSVersionGate = True
	Do
		$Found = False
		Select
			Case StringInStr($Line, $d & '#Is_x86#' & $d)
				$OSArchGate = $OSArchGate And Not $OSArch64
				$Line = StringStripWS(StringReplace($Line, $d & '#Is_x86#' & $d, ''), 3)
				$Found = True
			Case StringInStr($Line, $d & '#Is_x64#' & $d)
				$OSArchGate = $OSArchGate And $OSArch64
				$Line = StringStripWS(StringReplace($Line, $d & '#Is_x64#' & $d, ''), 3)
				$Found = True
			Case StringInStr($Line, $d & 'Is_x86' & $d)
				$OSArchGate = $OSArchGate And Not $OSArch64
				$Line = StringStripWS(StringReplace($Line, $d & 'Is_x86' & $d, ''), 3)
				$Found = True
			Case StringInStr($Line, $d & 'Is_x64' & $d)
				$OSArchGate = $OSArchGate And $OSArch64
				$Line = StringStripWS(StringReplace($Line, $d & 'Is_x64' & $d, ''), 3)
				$Found = True
			Case StringInStr($Line, $d & 'Is_86' & $d)
				$OSArchGate = $OSArchGate And Not $OSArch64
				$Line = StringStripWS(StringReplace($Line, $d & 'Is_86' & $d, ''), 3)
				$Found = True
			Case StringInStr($Line, $d & 'Is_64' & $d)
				$OSArchGate = $OSArchGate And $OSArch64
				$Line = StringStripWS(StringReplace($Line, $d & 'Is_64' & $d, ''), 3)
				$Found = True
		EndSelect
		Select
			Case StringInStr($Line, $d & 'Is_NT5' & $d)
				$OSVersionGate = $OSVersionGate And $OS_NT5
				$Line = StringStripWS(StringReplace($Line, $d & 'Is_NT5' & $d, ''), 3)
				$Found = True
			Case StringInStr($Line, $d & 'Is_NT6' & $d)
				$OSVersionGate = $OSVersionGate And Not $OS_NT5
				$Line = StringStripWS(StringReplace($Line, $d & 'Is_NT6' & $d, ''), 3)
				$Found = True
			Case StringInStr($Line, $d & 'Is_Metro' & $d)
				$OSVersionGate = $OSVersionGate And $MetroPresent
				$Line = StringStripWS(StringReplace($Line, $d & 'Is_Metro' & $d, ''), 3)
				$Found = True
			Case StringInStr($Line, $d & 'Is_OS') Or StringInStr($Line, $d & 'Is_NT')
				If StringInStr($Line, $d & 'Is_OS') Then $gate = 'Is_OS'
				If StringInStr($Line, $d & 'Is_NT') Then $gate = 'Is_NT'
				If $WINNTVersion <> '' Then
					$t1 = StringMid($Line, StringInStr($Line, $d & $gate) + StringLen($d & $gate), 1)
					$t2 = StringMid($Line, StringInStr($Line, $d & $gate) + StringLen($d & $gate) + 1, 1)
					Switch $t1
						Case '<'
							Switch $t2
								Case '=' ;lte
									$compare = '<='
								Case '>' ;not
									$compare = '<>'
								Case Else ;lt
									$t2 = ''
									$compare = '<'
							EndSwitch
						Case '='
							Switch $t2
								Case '<' ;lte
									$compare = '<='
								Case '>' ;gte
									$compare = '>='
								Case Else ;equal
									$t2 = ''
									$compare = '='
							EndSwitch
						Case '>'
							Switch $t2
								Case '=' ;gte
									$compare = '>='
								Case '<' ;not
									$compare = '<>'
								Case Else ;gt
									$t2 = ''
									$compare = '>'
							EndSwitch
						Case Else
					EndSwitch
					$t4 = StringInStr($Line, '#', 0, 1, StringInStr($Line, $d & $gate) + 1)
					$t5 = StringInStr($Line, $d & $gate) + StringLen($d & $gate) + 1 + StringLen($t2)
					$t3 = StringMid($Line, $t5, $t4 - $t5)
					If $t4 Then
						$Test = $d & $gate & $t1 & $t2 & $t3 & $d
						If StringInStr($Line, $Test) Then
							$OSVersionGate = $OSVersionGate And VersionCompare($WINNTVersion, $compare, StringStripWS($t3, 8))
							$Line = StringStripWS(StringReplace($Line, $Test, ''), 3)
							$Found = True
						EndIf
					EndIf
				EndIf
		EndSelect
	Until Not $Found
	Return $Line
EndFunc

Func ssInstall()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|ssInstall()' & @CRLF)
	Local $FileList, $UseTempDir = True
	Select ;Check if App has a valid InstallPath... if not, use the temp folder
		Case Not FileExists($App_InstallPath)
		Case NormalizeInstallPath($App_InstallPath) = '' ; And $SafeInstall
		Case (NormalizeInstallPath($App_InstallPath) = 'nonething')
		Case Else
			$UseTempDir = False
	EndSelect
	If $UseTempDir Then
		$UseTempDir4AppPath = $App_InstallPath
		$App_InstallPath = $TempDir
		DirCreate($App_InstallPath)
	EndIf
	; pp-style 'Install':
	If $ToolsPath <> '' And Not $InstallFromAppPath Then ; Install-mode
		InstallBuildTypeArc('.7z')
		InstallBuildTypeArc('.rar')
		InstallBuildTypeArc('.cab')
		InstallBuildTypeArc('.zip')
		If $App_Type > 2 And Not $ppInstall Then
			InstallMisc('.7z')
			InstallMisc('.rar')
			InstallMisc('.cab')
			InstallMisc('.zip')
		EndIf
	EndIf
	If $CopyFromLive Then ; cleanup (special .apz/pgz cases)
		FileDelete($App_InstallPath & '\' & GetAppTypeBase($App_Type) & '\')
		FileDelete($App_InstallPath & '\' & GetAppTypeBase($App_Type) & '.md5')
	EndIf
	If $App_NoneThing Then ; cleanup in case the archives contained these files anyway
		FileDelete($App_InstallPath & '\' & GetAppTypeBase($App_Type) & '.md5')
		FileDelete($App_InstallPath & '\' & GetAppTypeBase($App_Type) & '*.mp4')
		FileDelete($App_InstallPath & '\' & GetAppTypeBase($App_Type) & '*.jpg')
		FileDelete($App_InstallPath & '\' & GetAppTypeBase($App_Type) & '.png')
		FileDelete($App_InstallPath & '\' & GetAppTypeBase($App_Type) & '.ico')
		FileDelete($App_InstallPath & '\folder.gif')
		FileDelete($App_InstallPath & '\folder.jpg')
	Else ; Copy aux files:
		CopyExt('*.mp4'); videos
		CopyExt('*.jpg'); screen-shots
		CopyExt('.png'); faders
		CopyExt('.ico'); icons
		FileCopy($SrcPath & '\folder.gif', $App_InstallPath & '\', 9); folder picture
		FileCopy($SrcPath & '\folder.jpg', $App_InstallPath & '\', 9); folder picture
	EndIf
	CopyExt('.cmd'); scripts (cmd)
	CopyExt('.bat'); scripts (bat)
	CopyExt('.reg'); registry files
	Return True
EndFunc

Func WaitForOne() ;Self-queue this instance such that only one at a time is running
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|WaitForOne(): $ThisAppFilename=' & $ThisAppFilename & @CRLF)
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') @AutoItX64 = ' & @AutoItX64 & @CRLF)
	Local $InstanceList = ProcessList($ThisAppFilename & '.exe'); get a "snap-shot" of all SetupS instances
	If Not IsArray($InstanceList) Then Return
	Local $InstanceFound = False, $i, $Others = 0, $Pass = 0, $memInfo, $Stuck = False, $StuckWaits = 0, $CurrentMemInfo
	If $OSArch64 Then
		Local $InstanceList_x64 = ProcessList($ThisAppFilename & '_x64.exe')
		If IsArray($InstanceList_x64) Then
			;_ArrayDisplay($InstanceList_x64)
			For $i = 1 To $InstanceList_x64[0][0]
				$InstanceList[0][0] += 1
				ReDim $InstanceList[$InstanceList[0][0] + 1][2]
				$InstanceList[$InstanceList[0][0]][0] = $InstanceList_x64[$i][0]
				$InstanceList[$InstanceList[0][0]][1] = $InstanceList_x64[$i][1]
			Next
		EndIf
	EndIf
	For $i = 1 To $InstanceList[0][0] ;Count how many others
		If $InstanceList[$i][1] <> @AutoItPID And $InstanceList[$i][1] <> $x86PID Then
			If ProcessExists($InstanceList[$i][1]) Then
				$InstanceFound = True
				$Others = $Others + 1
			EndIf
		EndIf
	Next
	While $InstanceFound And $StuckWaits < 10
		$InstanceFound = False
		$Others = 0
		$Stuck = True
		For $i = 1 To $InstanceList[0][0] ; Wait for all the others (in the "snap-shot") to finish first
			If $InstanceList[$i][1] <> @AutoItPID Then
				If ProcessExists($InstanceList[$i][1]) Then
					$InstanceFound = True
					$Others = $Others + 1
					$memInfo = ProcessGetStats($InstanceList[$i][1])
					If $memInfo[0] <> $InstanceList[$i][0] Then ; record current working MemSize
						$InstanceList[$i][0] = $memInfo[0]
						$Stuck = False
					EndIf
				EndIf
			EndIf
		Next
		If $Pass <> $Others Then
			ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') Warning: other occurrences of ' & $ThisAppFilename & ' ahead of this one: ' & $Others & @CRLF)
			$Pass = $Others
			$Stuck = False
		EndIf
		If $Stuck Then
			$StuckWaits += 1
		Else
			$StuckWaits = 0
		EndIf
		Sleep(500)
	WEnd
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') Okay: this occurrence of ' & $ThisAppFilename & ' is now running.' & @CRLF)
EndFunc

Func WhereIsWhat($where, $What)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|WhereIsWhat(): $where=' & $where & ' : $What=' & $What & @CRLF)
	;recursive function to find
	;the path of $what from $Where
	Local $i, $FileList, $path = ''
	If FileExists($where & '\' & $What) Then
		$path = $where
	Else
		$FileList = _FileListToArray($where, '*.*', 2) ; Return folders only
		If @error = 0 Then
			For $i = 1 To $FileList[0]
				$path = WhereIsWhat($where & '\' & $FileList[$i], $What)
				If $path <> '' Then ExitLoop
			Next
		EndIf
	EndIf
	Return $path
EndFunc
#endregion

#region ;**** Special Windows functions (components) ****

Func ClickMe($title, $text = '', $controlID = '') ;Sends a mouse click command to a given control.
	Do
		Sleep(10)
	Until ControlCommand($title, $text, $controlID, "IsVisible", "")
	Do
		Sleep(10)
	Until ControlCommand($title, $text, $controlID, "IsEnabled", "")
	ControlClick($title, $text, $controlID)
EndFunc

Func CloseMe($title, $text = '')
;~ 	Do
	WinClose($title, $text)
;~ 	WinKill($title, $text)
;~ 		Sleep(10)
;~ 	Until Not WinExists($title) ;WinWaitClose($title)
EndFunc

Func ProcessKill($Line)
	$PID = ProcessExists($Line)
	Do
		If $PID Then ProcessClose($PID)
		Sleep(100)
	Until Not ProcessExists($PID)
EndFunc

Func SelectMe($title)
	WinWait($title)
	Do
		WinActivate($title)
		Sleep(10)
	Until WinActive($title) ;WinWaitActive($title)
	SendKeepActive($title)
EndFunc

Func SendMe($keys)
	Send($keys)
EndFunc

Func WaitForIt($Line) ;filename or processname
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|WaitForIt(): $Line=' & $Line & @CRLF)
	Do
		Sleep(10)
	Until FileExists($Line) Or ProcessExists($Line)
EndFunc

Func WaitForMe($title, $text = '', $timeout = '')
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|WaitForMe(): $Line=' & $title & @CRLF)
	Do
		If $timeout = '' Then
			WinWait($title, $text)
		Else
			WinWait($title, $text, $timeout)
		EndIf
		Sleep(10)
	Until WinExists($title)
EndFunc
#endregion

;~ End Of File

