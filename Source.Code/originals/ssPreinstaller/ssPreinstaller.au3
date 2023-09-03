#NoTrayIcon
#region
#AutoIt3Wrapper_Icon=ppApp.ico
#AutoIt3Wrapper_Outfile=ssPreinstaller.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=Kludge to pre-install/uninstall SetupS (experimental)
#AutoIt3Wrapper_Res_Fileversion=#ProjectVersion#
#AutoIt3Wrapper_Res_LegalCopyright=© #cYear# #cHolder#
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_Field=Release Date|#ProjectDate#
#AutoIt3Wrapper_Res_Field=ssTek Forum|http://#WebLink1#
#AutoIt3Wrapper_Res_Field=ssTek Development|http://#WebLink2#
#AutoIt3Wrapper_Res_Field=LastOS Team|http://#WebLink3#
#AutoIt3Wrapper_Au3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/pr=1 /uv=3 /tc=0 /sf /reel /refc /rerc /kv=10
#AutoIt3Wrapper_UseX64=y
#endregion

#cs ##################################################################################
	
	ssPreinstaller v#ProjectVersion#
	Copyright © #cYear#, #cHolder#
	All rights reserved.
	
	ssPreinstaller is open-source software: you can redistribute it and/or
	modify it under the terms of the GNU General Public License as published
	by the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version of the License.
	
	DISCLAIMER:
	ssPreinstaller is distributed in the hope that it will be useful, but
	is provided by #cHolder# "AS IS", without warranty of any kind,
	express or implied, including but not limited to the warranties of
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE and NON-INFRINGEMENT.
	In no event shall the authors or #cHolder# be liable for any direct,
	indirect, incidental, special, exemplary, or consequential damages
	(including, but not limited to, procurement of substitute goods or
	services; loss of use, data, or profits; or business interruption)
	however caused and on any theory of liability, whether in an action of
	contract, strict liability, or tort (including negligence or otherwise)
	arising from, out of or in connection with the software or the use or
	other dealings in the software, even if advised of the possibility of
	such damage.
	
	See the GNU General Public License for more details. You should have
	received a copy of the GNU General Public License along with ssPreinstaller.
	If not, see <http://www.gnu.org/licenses/>.
	
#ce ##################################################################################
#cs ##################################################################################
	
	Script Function:
	Kludge to pre-uninstall SetupS (experimental)
	
#ce ##################################################################################
#include <..\SetupS.Core.au3>

;------------------------------------------------------ Debug & Testing -----------------------------------------------------------
If Not @Compiled Then
	If $CLIparameters[0] = 0 Then
		;Some examples of how to use this:
		ReDim $CLIparameters[UBound($CLIparameters) + 1]
		$CLIparameters[0] = $CLIparameters[0] + 1
		$CLIparameters[$CLIparameters[0]] = "--StartMenuOnly"

		ReDim $CLIparameters[UBound($CLIparameters) + 1]
		$CLIparameters[0] = $CLIparameters[0] + 1
		$CLIparameters[$CLIparameters[0]] = "--TrayOnly" ;"--Mute" ;"--TrayOnly" ; Switches

;~ 	ReDim $CLIparameters[UBound($CLIparameters) + 1]
;~ 	$CLIparameters[0] = $CLIparameters[0] + 1
;~ 	$CLIparameters[$CLIparameters[0]] = "Install.SetupS_v8.11.7.0.exe"

;~ 	ReDim $CLIparameters[UBound($CLIparameters) + 1]
;~ 	$CLIparameters[0] = $CLIparameters[0] + 1
;~ 	$CLIparameters[$CLIparameters[0]] = "/VERYSILENT"

;~ 	ReDim $CLIparameters[UBound($CLIparameters) + 1]
;~ 	$CLIparameters[0] = $CLIparameters[0] + 1
;~ 	$CLIparameters[$CLIparameters[0]] = "/SUPPRESSMSGBOXES"

;~ 	ReDim $CLIparameters[UBound($CLIparameters) + 1]
;~ 	$CLIparameters[0] = $CLIparameters[0] + 1
;~ 	$CLIparameters[$CLIparameters[0]] = "/NORESTART"

;~ 	ReDim $CLIparameters[UBound($CLIparameters) + 1]
;~ 	$CLIparameters[0] = $CLIparameters[0] + 1
;~ 	$CLIparameters[$CLIparameters[0]] = "/SP-"

	EndIf
	Opt('TrayIconDebug', 1)
EndIf

;------------------------------------------------------ Declarations -------------------------------------------------------------
SetThisApp() ; Sets $ThisAppTitle, $ThisAppVersion, & $ThisAppFilename; plus DualArch

Dim $szDrive, $szDir, $szFName, $szExt, $Ver2Install = ''
Local $AutoClose = 3, $MyName = _PathSplit(@ScriptFullPath, $szDrive, $szDir, $szFName, $szExt)
Local $RunProgram, $StartMenuOnly = GetParameter("StartMenuOnly"), $Filelist, $Found = False

;----------------------------------------------------- Get Parameters -------------------------------------------------------------
GetReportingMode($szDrive & $szDir & $szFName & '.ini')
Local $SplashTipsLocal = $SplashTips
If $BalloonTips Then
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', '2')
	Opt('TrayIconHide', 0) ;Show tray icon
	Opt('TrayAutoPause', 0) ;Turn off autopause
	If $ssUninstall Then
		_TrayTip($ThisAppTitle, 'Disabling ssUninstall...', 300, 16)
	Else
		_TrayTip($ThisAppTitle, 'Initializing...', 300, 16)
	EndIf
	_ShowTray()
Else
	;RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', '0')
	Opt('TrayIconHide', 1) ;Hide tray icon
EndIf
If $SplashTips Then
	If $ssUninstall Then
		SplashThis($ThisAppFilename, 'Disabling ssUninstall(s)...')
	Else
		SplashThis($ThisAppFilename, 'Initializing...')
	EndIf
EndIf
If GetParameter("Help") Or GetParameter("?") Then EndGame("Help requested", "See displayed", True)

;------------------------------------------------------ Begin -------------------------------------------------------------
; SetupS Uninstall strings (various)
UninstallMe('HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\SetupS_is1')
UninstallMe('HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\Setup SetupS_is1')
UninstallMe('HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\SetupS.SendTo_is1')

; Remove registry entries
RegDelete('HKEY_CLASSES_ROOT\.app')
RegDelete('HKEY_CLASSES_ROOT\.ppg')
RegDelete('HKEY_CLASSES_ROOT\.apz')
RegDelete('HKEY_CLASSES_ROOT\.pgz')
RegDelete('HKEY_CLASSES_ROOT\SetupS.SendTo')
RegDelete('HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\SetupS_is1')
RegDelete('HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\Setup SetupS_is1')
RegDelete('HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\SetupS.SendTo_is1')
RegDelete('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers', @ProgramFilesDir & '\SetupS.SendTo\SetupS.exe')
RegDelete('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers', @ProgramFilesDir & '\SetupS.SendTo\ssEditor\ssEditor.exe')
RegDelete('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers', @ProgramFilesDir & '\SetupS.SendTo\ssRegenerator.exe')
RegDelete('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers', @ProgramFilesDir & '\SetupS.SendTo\ssControlPanel.exe')
RegDelete('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers', @ProgramFilesDir & '\SetupS.SendTo\ssRegen.exe')
RegDelete('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers', @ProgramFilesDir & '\SetupS.SendTo\ssCP.exe')
RegDelete('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers', @ProgramFilesDir & '\SetupS.SendTo\Regenerator.exe')
RegDelete('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers', @ProgramFilesDir & '\SetupS.SendTo\SetupSCP.exe')

; Remove any Advanced Startmenus (infrastructure only)
RemoveResources(@WindowsDir & '\LastXP')
RemoveResources(@WindowsDir & '\LastOS')
RemoveResources($ssTekResources)

; Remove any remaining folders
DeleteMe(@ProgramFilesDir & '\SetupS.SendTo')
DeleteMe(@ProgramFilesDir & '\SetupSetupS')
DeleteMe(@ProgramFilesDir & '\SetupS')

; Remove shortcuts
If $BalloonTips Then _TrayTip($ThisAppTitle, 'Cleaning shortcuts', 300, 16)
If $SplashTips Then
	SplashThis($ThisAppFilename, 'Cleaning shortcuts...')
	$SplashTips = False
EndIf
ssCleaner(@StartMenuCommonDir) ; All Users Start Menu
ssCleaner(@StartMenuDir) ; Current User Start Menu
ssCleaner(EnvGet("ALLUSERSPROFILE") & "\SendTo"); All Users Sendto
ssCleaner(@UserProfileDir & "\SendTo") ; Current User Sendto
$SplashTips = $SplashTipsLocal
;EnvUpdate()
_EnvUpdate()

;SetupS Installer (if available)
If IsArray($CLIparameters) Then
	If $CLIparameters[0] > 0 Then ; anything left is the program to run next
		For $i = 1 To $CLIparameters[0]
			$RunProgram = $RunProgram & ' ' & $CLIparameters[$i]
		Next
		$RunProgram = StringStripWS($RunProgram, 3)
	EndIf
EndIf
If $RunProgram <> '' Then
	$Filelist = StringSplit($RunProgram, ' ')
	If @error = 0 And IsArray($Filelist) Then
		If $Filelist[0] > 0 Then
			If FileExists($Filelist[1]) Then
				$Found = True
			EndIf
		EndIf
	EndIf
EndIf
If Not $Found Then
	$RunProgram = ''
	$Filelist = _FileListToArray(@ScriptDir, '*.exe', 1)
	If @error = 0 And IsArray($Filelist) Then
		For $i = 1 To $Filelist[0]
			If StringLeft($Filelist[$i], 16) = 'Install.SetupS_v' Then
				$RunProgram = $Filelist[$i] & ' /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
				$Found = True
				$Ver2Install = StringLeft(StringMid($Filelist[$i], 16), StringInStr(StringMid($Filelist[$i], 16), '.', -1, -1) - 1)
				ExitLoop
			EndIf
		Next
	EndIf
EndIf
If $Found And $RunProgram <> '' Then
	If $BalloonTips Then _TrayTip($ThisAppTitle, 'Installing SetupS ' & $Ver2Install & ' now', 300, 16)
	If $SplashTips Then SplashThis($ThisAppFilename, 'Installing SetupS ' & $Ver2Install & ' now...')
	;SplashOff()
	FileChangeDir(@ScriptDir)
	Do
		RunWait($RunProgram, '', @SW_HIDE)
		If @error <> 0 Then ExitLoop
	Until RegRead('HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\SetupS_is1', 'UninstallString') <> ''
EndIf

;---------------------------------------------------- Finished ------------------------------------------------------------------
Cleanup()
Adjust(@StartMenuDir)
Adjust(@StartMenuCommonDir)
EndGame('', 'Finished!');, False, 5)
Exit

Func Adjust($What)
	Local $i, $Filelist, $temp
	$Filelist = _FileListToArray($What, '*.*', 2) ; Return folders only
	If @error = 0 Then
		For $i = 1 To $Filelist[0]
			Adjust($What & '\' & $Filelist[$i])
		Next
	EndIf
	$Filelist = _FileListToArray($What, 'desktop.ini', 1) ; Return files only
	If @error = 0 Then
		For $i = 1 To $Filelist[0]
			$temp = IniRead($What & '\' & $Filelist[$i], '.ShellClassInfo', 'IconFile', '')
			If $temp <> '' Then IniWrite($What & '\' & $Filelist[$i], '.ShellClassInfo', 'IconFile', StringReplace(StringReplace($temp, '\LastOS\', '\ssTek\'), 'LastOS_', 'LXP_'))
		Next
	EndIf
EndFunc

Func RemoveResources($What)
	If FileExists($What) Then
		DeleteMe($What & '\Menu')
		DeleteMe($What & '\Icons')
		DeleteMe($What & '\Definitions.ini')
		DeleteMe(@StartupDir & '\Desktop.ini')
		DeleteMe(@StartupCommonDir & '\Desktop.ini')
		If $What <> $ssTekResources Then
			If FileExists($What & '\ssConfig.ini') Then
				NeoFileCopy($What & '\ssConfig.ini', $ssTekResources & '\ssConfig.ini')
				DeleteMe($What & '\ssConfig.ini')
			EndIf
			If FileExists($What & '\ssEditor.ini') Then
				NeoFileCopy($What & '\ssEditor.ini', $ssTekResources & '\ssEditor.ini')
				DeleteMe($What & '\ssEditor.ini')
			EndIf
		EndIf
	EndIf
EndFunc

Func UninstallMe($UninstallKey)
	If $UninstallKey <> '' Then
		Local $UninstallString = RegRead($UninstallKey, 'QuietUninstallString')
		If $UninstallString = '' Then
			$UninstallString = StringReplace(RegRead($UninstallKey, 'UninstallString'), '"', '')
			If $UninstallString <> '' And FileExists($UninstallString) Then
				RunWait('"' & $UninstallString & '" /SILENT')
				If @error = 0 And RegRead($UninstallKey, 'UninstallString') = '' Then Return True
			EndIf
		Else
			RunWait($UninstallString)
			If @error = 0 Then Return True
		EndIf
	EndIf
	Return False
EndFunc
