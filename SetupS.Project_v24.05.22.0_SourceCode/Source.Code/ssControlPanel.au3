#NoTrayIcon
#region
#AutoIt3Wrapper_Icon=ssControlPanel.ico
#AutoIt3Wrapper_Outfile=Tools\ssControlPanel.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=SetupS Control Panel. An applet to select an Advanced StartMenu/Sorting Style, ppDrives, etc.
#AutoIt3Wrapper_Res_Fileversion=24.05.22.0
#AutoIt3Wrapper_Res_LegalCopyright=©2024, Vergitek Solutions
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_Field=Release Date|2024-05-22
#AutoIt3Wrapper_Res_Field=ssTek Forum|http://sstek.vergitek.com
#AutoIt3Wrapper_Res_Field=LastOS Forum|http://www.lastos.org
#AutoIt3Wrapper_Res_Field=#WebSite3#|http://#WebLink3#
#AutoIt3Wrapper_Au3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/pr=1 /uv=3 /tc=0 /sf /reel /refc /rerc /kv=100
#AutoIt3Wrapper_UseX64=n
#endregion

#cs ##################################################################################
	
	SetupS Control Panel v24.05.22.0
	Copyright © 2024, Vergitek Solutions
	All rights reserved.
	
	This file is part of the SetupS SendTo Suite.
	
	The SetupS SendTo Suite is open-source software: you can redistribute it and/or
	modify it under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your option)
	any later version of the License.
	
	DISCLAIMER:
	The SetupS SendTo Suite is distributed in the hope that it will be useful, but is
	provided by Vergitek Solutions "AS IS", without warranty of any kind, express or
	implied, including but not limited to the warranties of MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE, TITLE and NON-INFRINGEMENT. In no event shall
	the authors or Vergitek Solutions be liable for any direct, indirect, incidental, special,
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
	Applet to select an Advanced StartMenu/Sorting Style, ppDrives, etc.
	
#ce ##################################################################################
#include <SetupS.Core.au3>

;------------------------------------------------------ Debug & Testing -----------------------------------------------------------
If Not @Compiled And Not GetParameter('Test') Then
	If $CLIparameters[0] = 0 Then
		;$Debug = True
		;$CLIparameters[0] += 1
		;ReDim $CLIparameters[$CLIparameters[0] + 1]
		;$CLIparameters[$CLIparameters[0]] = '';'-LastOS -SortDefaults'

		;Some examples of how to use this:

;~ 		$CLIparameters[0] += 1
;~ 		ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 		$CLIparameters[$CLIparameters[0]] = '-ssClean=StartMenuOnly,DudInstallPaths,DeepScan'

;~ 		$CLIparameters[0] += 1
;~ 		ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 		$CLIparameters[$CLIparameters[0]] = '-autoupdate=yes'

;~ 		$CLIparameters[0] += 1
;~ 		ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 		$CLIparameters[$CLIparameters[0]] = '-ssUninstall=off,refresh'

;~ 		$CLIparameters[0] += 1
;~ 		ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 		$CLIparameters[$CLIparameters[0]] = '-Path=del'

;~ 		$CLIparameters[0] += 1
;~ 		ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 		$CLIparameters[$CLIparameters[0]] = '-uninstall="%ProgramFiles%\Inno Setup 5"'
;~ 		$CLIparameters[$CLIparameters[0]] = '-uninstall="%ProgramFiles%\AutoIt3"'
;~ 		$CLIparameters[$CLIparameters[0]] = '-uninstall="%ProgramFiles%\SetupS.SendTo"'

		Opt('TrayIconDebug', 1)
	EndIf
Else
	Opt('TrayAutoPause', 0) ;Turn off autopause
EndIf
Opt('TrayIconHide', 0) ;Show tray icon

;------------------------------------------------------ Declarations -------------------------------------------------------------
SetThisApp() ; Sets $ThisAppTitle, $ThisAppVersion, & $ThisAppFilename; plus DualArch

#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>
#include <GuiStatusBar.au3>
#include <UDFs\icons.au3>

Global $ForceMenu = False, $ForceNoMenu, $MenuInstallOnly, $Timer1
Global $ssUpdateINI = CheckINI('ssUpdate.ini'), $ssConfigINI = CheckINI('ssConfig.ini')
;~ If $MakeDefaultINI Then SetSetupSOptions($ssConfigINI)
Local $Mute, $TrayOnly, $SplashOnly
Local $aPos, $CleanStartMenuDir = False, $ppDrivesRunRegen = False, $CLIparametersCount = $CLIparameters[0]
Opt('GUIOnEventMode', 1)
Local $tdReg, $tdCmd, $tdApp
$HelpFile = FindMe('ssTek.chm')

;------------------------------------------------------ Get System Info ----------------------------------------------------------
GetppDrives()
If $ToolsPath = '' Then GetToolsFolder() ;$ToolsPath ;EnvGet('Path')
GetMenuStyle()

;------------------------------------------------------ Begin --------------------------------------------------------------------
If FileExists($ssConfigINI) Then GetReportingMode($ssConfigINI)
If $Debug Then _ConsoleWrite('@@ Debug Start (' & @ScriptName & ') : ' & _NowCalc(), True) ; set 2nd arg = True to start a new file
If $BalloonTips Then
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', '2')
	;Opt('TrayIconHide', 0) ;Show tray icon
	;Opt('TrayAutoPause', 0) ;Turn off autopause
	_ShowTray() ;AdlibRegister('_ShowTray', 5000)
Else
	;RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', '0')
	;Opt('TrayIconHide', 1) ;Hide tray icon
EndIf
;~ If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Initializing...' & @CRLF, True)
GetFaderMode($ssConfigINI)
GetRegeneratorMode($ssConfigINI)
GetScMode($ssConfigINI)
GetSetupSOptions($ssConfigINI)
GetAlternateDistribution($ssUpdateINI)
Local $UseGUI = ($CLIparametersCount = $AutoUpdateReturn)
If $AutoUpdate Then UpdateMe('update.ini', @ScriptDir, $UseGUI)
If $UseGUI Then
	Global $MenuStyleChoices = 'Standard (Uninstall Advanced StartMenu)'
	Global $ppAppsDriveChoices = StringUpper($ppAppsDrive)
	Global $ppGamesDriveChoices = StringUpper($ppGamesDrive)
	Global $CDDriveChoices = StringUpper($CDDrive)
	For $i = 1 To $MenuStyles[0][0]
		;MsgBox(4096, '', 'Key: ' & $MenuStyles[$i][0] & @CRLF & 'Value: ' & $MenuStyles[$i][1])
		$MenuStyleChoices = $MenuStyleChoices & '|' & $MenuStyles[$i][1]
	Next
	Local $AllDrivesList = DriveGetDrive('ALL')
	If Not @error Then
		If IsArray($AllDrivesList) Then
			For $i = 1 To $AllDrivesList[0]
				If ($AllDrivesList[$i] <> $ppAppsDrive) Then $ppAppsDriveChoices = $ppAppsDriveChoices & '|' & StringUpper($AllDrivesList[$i])
				If ($AllDrivesList[$i] <> $ppGamesDrive) Then $ppGamesDriveChoices = $ppGamesDriveChoices & '|' & StringUpper($AllDrivesList[$i])
				If ($AllDrivesList[$i] <> $CDDrive) Then $CDDriveChoices = $CDDriveChoices & '|' & StringUpper($AllDrivesList[$i])
			Next
		EndIf
	EndIf

	#region ### START Koda GUI section ### Form=ssControlPanel.kxf
	Global $ssControlPanel = GUICreate("SetupS ControlPanel (ssControlPanel) v88.88.88.88", 441, 261, -1, -1)
	GUISetOnEvent($GUI_EVENT_CLOSE, "ssControlPanelClose")
	GUISetOnEvent($GUI_EVENT_MINIMIZE, "ssControlPanelMinimize")
	GUISetOnEvent($GUI_EVENT_MAXIMIZE, "ssControlPanelMaximize")
	GUISetOnEvent($GUI_EVENT_RESTORE, "ssControlPanelRestore")
	Global $TabMenu = GUICtrlCreateTab(5, 10, 420, 198)
	GUICtrlSetOnEvent($TabMenu, "TabMenuChange")
	Global $TabSheet_StartMenu = GUICtrlCreateTabItem("StartMenu")
	Global $LabelMenu = GUICtrlCreateLabel("Install an Advanced StartMenu:", 107, 83, 153, 17)
	GUICtrlSetFont($LabelMenu, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetTip($LabelMenu, "Force or change to an Advanced or Standard/non-SetupS Startmenu sorting-structure(s)")
	GUICtrlSetOnEvent($LabelMenu, "LabelMenuClick")
	Global $CheckboxMenuSort = GUICtrlCreateCheckbox("Sort (organize) Startmenu shortcuts.", 112, 139, 190, 17)
	GUICtrlSetFont($CheckboxMenuSort, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetTip($CheckboxMenuSort, "Disable this to install the Startmenu structure only.")
	GUICtrlSetOnEvent($CheckboxMenuSort, "CheckboxMenuSortClick")
	Global $ComboMenuStyle = GUICtrlCreateCombo("Choose:", 112, 108, 145, 100, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
	GUICtrlSetFont($ComboMenuStyle, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetTip($ComboMenuStyle, "Sorts (organizes) the Startmenu using the selected Startmenu preference.")
	GUICtrlSetOnEvent($ComboMenuStyle, "ComboMenuStyleChange")
	Global $Label_CurrentMenuStyle = GUICtrlCreateLabel("Current Menu Style:", 98, 45, 97, 17)
	GUICtrlSetFont($Label_CurrentMenuStyle, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetOnEvent($Label_CurrentMenuStyle, "Label_CurrentMenuStyleClick")
	Global $Label_MenuStyle = GUICtrlCreateLabel("ssTek", 224, 44, 47, 20)
	GUICtrlSetFont($Label_MenuStyle, 11, 800, 0, "MS Sans Serif")
	GUICtrlSetColor($Label_MenuStyle, 0xFF0000)
	GUICtrlSetOnEvent($Label_MenuStyle, "Label_MenuStyleClick")
	Global $Checkbox_KeepStartMenuFolders = GUICtrlCreateCheckbox("Keep empty Advanced Startmenu folders.", 112, 178, 225, 17)
	GUICtrlSetFont($Checkbox_KeepStartMenuFolders, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetTip($Checkbox_KeepStartMenuFolders, "Enable this to install (and retain) the full selected Advanced Startmenu including empty folders.")
	GUICtrlSetOnEvent($Checkbox_KeepStartMenuFolders, "Checkbox_KeepStartMenuFoldersClick")
	Global $Checkbox_KeepStartMenuDefaults = GUICtrlCreateCheckbox("Ignore Startmenu Defaults", 130, 157, 225, 17)
	GUICtrlSetFont($Checkbox_KeepStartMenuDefaults, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetTip($Checkbox_KeepStartMenuDefaults, "Enable this to skip sorting/organizing the standard (default) shortcuts into an Advanced Startmenu")
	GUICtrlSetOnEvent($Checkbox_KeepStartMenuDefaults, "Checkbox_KeepStartMenuDefaultsClick")
	Global $TabSheet_Preferences = GUICtrlCreateTabItem("Preferences")
	Global $Group_Reporting = GUICtrlCreateGroup("Default reporting / notifications:", 17, 40, 199, 74)
	GUICtrlSetFont($Group_Reporting, 9, 800, 0, "MS Sans Serif")
	GUICtrlSetColor($Group_Reporting, 0x000080)
	Global $radioShow = GUICtrlCreateRadio("Show Everything", 22, 57, 102, 17)
	GUICtrlSetFont($radioShow, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetTip($radioShow, "Show progress as both splash text and tray-balloon tips.")
	GUICtrlSetOnEvent($radioShow, "radioShowClick")
	Global $radioMute = GUICtrlCreateRadio("Hide Everything", 22, 74, 102, 17)
	GUICtrlSetFont($radioMute, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetTip($radioMute, "Totally silent install; hides everything including system tray icon and balloon tips.")
	GUICtrlSetOnEvent($radioMute, "radioMuteClick")
	Global $radioTrayOnly = GUICtrlCreateRadio("Tray Only", 134, 57, 80, 17)
	GUICtrlSetFont($radioTrayOnly, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetTip($radioTrayOnly, "Show progress only as balloon tips from the tray.")
	GUICtrlSetOnEvent($radioTrayOnly, "radioTrayOnlyClick")
	Global $radioSplashOnly = GUICtrlCreateRadio("Splash Only", 134, 74, 80, 17)
	GUICtrlSetFont($radioSplashOnly, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetTip($radioSplashOnly, "Show progress only as splash text/message boxes and hides both the tray icon and any balloon tips from the tray.")
	GUICtrlSetOnEvent($radioSplashOnly, "radioSplashOnlyClick")
	Global $Checkbox_AlwaysOnTop = GUICtrlCreateCheckbox("Always On Top (Splash)", 50, 92, 137, 17)
	GUICtrlSetFont($Checkbox_AlwaysOnTop, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetOnEvent($Checkbox_AlwaysOnTop, "Checkbox_AlwaysOnTopClick")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $Group_Safeties = GUICtrlCreateGroup("Options:", 317, 40, 96, 74)
	GUICtrlSetFont($Group_Safeties, 9, 800, 0, "MS Sans Serif")
	GUICtrlSetColor($Group_Safeties, 0x000080)
	Global $Checkbox_SafeInstall = GUICtrlCreateCheckbox("Safe Install", 324, 57, 75, 17)
	GUICtrlSetState($Checkbox_SafeInstall, $GUI_CHECKED)
	GUICtrlSetFont($Checkbox_SafeInstall, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Checkbox_SafeInstall, 0x000000)
	GUICtrlSetState($Checkbox_SafeInstall, $GUI_DISABLE)
	GUICtrlSetOnEvent($Checkbox_SafeInstall, "Checkbox_SafeInstallClick")
	Global $Checkbox_SkipOSArch = GUICtrlCreateCheckbox("Skip OSArch", 324, 74, 84, 17)
	GUICtrlSetFont($Checkbox_SkipOSArch, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Checkbox_SkipOSArch, 0x000000)
	GUICtrlSetTip($Checkbox_SkipOSArch, "SetupS/Regenerator option to process or skip apps/games based on the <Architecture> and/or <OS> information in an .app/.ppg file.")
	GUICtrlSetOnEvent($Checkbox_SkipOSArch, "Checkbox_SkipOSArchClick")
	Global $Checkbox_ssUninstall = GUICtrlCreateCheckbox("ssUninstall", 324, 91, 84, 17)
	GUICtrlSetFont($Checkbox_ssUninstall, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Checkbox_ssUninstall, 0x000000)
	GUICtrlSetTip($Checkbox_ssUninstall, "Use to completely uninstall.")
	GUICtrlSetOnEvent($Checkbox_ssUninstall, "Checkbox_ssUninstallClick")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $Group_Logging = GUICtrlCreateGroup("Logging:", 224, 40, 85, 74)
	GUICtrlSetFont($Group_Logging, 9, 800, 0, "MS Sans Serif")
	GUICtrlSetColor($Group_Logging, 0x000080)
	Global $Checkbox_LogDebugging = GUICtrlCreateCheckbox("Debugging", 231, 74, 76, 17)
	GUICtrlSetFont($Checkbox_LogDebugging, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Checkbox_LogDebugging, 0x000000)
	GUICtrlSetTip($Checkbox_LogDebugging, "Turns on Debug-mode. Files created are in the form ''DebugConsole.000x.txt''.")
	GUICtrlSetOnEvent($Checkbox_LogDebugging, "Checkbox_LogDebuggingClick")
	Global $Checkbox_LogReporting = GUICtrlCreateCheckbox("Reporting", 231, 57, 68, 17)
	GUICtrlSetFont($Checkbox_LogReporting, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Checkbox_LogReporting, 0x000000)
	GUICtrlSetTip($Checkbox_LogReporting, "Creates activity logs. Files created are in the form ''ReportingConsole.000x.txt''.")
	GUICtrlSetOnEvent($Checkbox_LogReporting, "Checkbox_LogReportingClick")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $Group_AutoUpdate = GUICtrlCreateGroup("Updates:", 133, 119, 280, 74)
	GUICtrlSetFont($Group_AutoUpdate, 9, 800, 0, "MS Sans Serif")
	GUICtrlSetColor($Group_AutoUpdate, 0x000080)
	Global $Checkbox_AutoUpdate = GUICtrlCreateCheckbox("Auto Update", 314, 119, 84, 17)
	GUICtrlSetFont($Checkbox_AutoUpdate, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Checkbox_AutoUpdate, 0x000000)
	GUICtrlSetTip($Checkbox_AutoUpdate, "Automatic online updates of the SetupS Sendto Suite using one of the Repo links, below.")
	GUICtrlSetOnEvent($Checkbox_AutoUpdate, "Checkbox_AutoUpdateClick")
	Global $Label_RepoLink = GUICtrlCreateLabel("Primary:", 138, 141, 44, 17, $SS_RIGHT)
	GUICtrlSetFont($Label_RepoLink, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Label_RepoLink, 0x000000)
	GUICtrlSetOnEvent($Label_RepoLink, "Label_RepoLinkClick")
	Global $Label_BackupRepoLink = GUICtrlCreateLabel("Backup:", 138, 167, 44, 17, $SS_RIGHT)
	GUICtrlSetFont($Label_BackupRepoLink, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Label_BackupRepoLink, 0x000000)
	GUICtrlSetOnEvent($Label_BackupRepoLink, "Label_BackupRepoLinkClick")
	Global $Input_RepoLink = GUICtrlCreateInput("", 184, 138, 224, 21)
	GUICtrlSetFont($Input_RepoLink, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Input_RepoLink, 0x000000)
	GUICtrlSetOnEvent($Input_RepoLink, "Input_RepoLinkChange")
	Global $Input_BackupRepoLink = GUICtrlCreateInput("", 184, 164, 224, 21)
	GUICtrlSetFont($Input_BackupRepoLink, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Input_BackupRepoLink, 0x000000)
	GUICtrlSetOnEvent($Input_BackupRepoLink, "Input_BackupRepoLinkChange")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $Group_DualArchInstalls = GUICtrlCreateGroup("DualArch Installs:", 17, 119, 118, 74)
	GUICtrlSetFont($Group_DualArchInstalls, 9, 800, 0, "MS Sans Serif")
	GUICtrlSetColor($Group_DualArchInstalls, 0x000080)
	Global $Radio_ForceType2a = GUICtrlCreateRadio("Force Type 2a", 22, 136, 100, 17)
	GUICtrlSetState($Radio_ForceType2a, $GUI_CHECKED)
	GUICtrlSetFont($Radio_ForceType2a, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetTip($Radio_ForceType2a, "Packages marked as ''DualArch'' will always install as Type 2a (only the system arch is installed and present).")
	GUICtrlSetOnEvent($Radio_ForceType2a, "Radio_ForceType2aClick")
	Global $Radio_ForceType2b = GUICtrlCreateRadio("Force Type 2b", 22, 153, 100, 17)
	GUICtrlSetFont($Radio_ForceType2b, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetTip($Radio_ForceType2b, "Packages marked as ''DualArch'' will always install as Type 2b (both arches are installed and present).")
	GUICtrlSetOnEvent($Radio_ForceType2b, "Radio_ForceType2bClick")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $TabSheet_ShortcutS = GUICtrlCreateTabItem("Shortcuts")
	Global $Group_ProcessWithoutShortcuts = GUICtrlCreateGroup("Skip shortcuts:", 16, 40, 101, 74)
	GUICtrlSetFont($Group_ProcessWithoutShortcuts, 9, 800, 0, "MS Sans Serif")
	GUICtrlSetColor($Group_ProcessWithoutShortcuts, 0x000080)
	Global $Checkbox_ppGamesShortcutsSkip = GUICtrlCreateCheckbox("ppGames", 23, 91, 68, 17)
	GUICtrlSetFont($Checkbox_ppGamesShortcutsSkip, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Checkbox_ppGamesShortcutsSkip, 0x000000)
	GUICtrlSetTip($Checkbox_ppGamesShortcutsSkip, "Do not create or process any shortcuts for ppGames.")
	GUICtrlSetOnEvent($Checkbox_ppGamesShortcutsSkip, "Checkbox_ppGamesShortcutsSkipClick")
	Global $Checkbox_ppAppsShortcutsSkip = GUICtrlCreateCheckbox("ppApps", 23, 74, 59, 17)
	GUICtrlSetFont($Checkbox_ppAppsShortcutsSkip, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Checkbox_ppAppsShortcutsSkip, 0x000000)
	GUICtrlSetTip($Checkbox_ppAppsShortcutsSkip, "Do not create or process any shortcuts for ppApps.")
	GUICtrlSetOnEvent($Checkbox_ppAppsShortcutsSkip, "Checkbox_ppAppsShortcutsSkipClick")
	Global $Checkbox_ssAppsShortcutsSkip = GUICtrlCreateCheckbox("ssApps", 23, 57, 57, 17)
	GUICtrlSetFont($Checkbox_ssAppsShortcutsSkip, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Checkbox_ssAppsShortcutsSkip, 0x000000)
	GUICtrlSetTip($Checkbox_ssAppsShortcutsSkip, "Do not create or process any shortcuts for ssApps.")
	GUICtrlSetOnEvent($Checkbox_ssAppsShortcutsSkip, "Checkbox_ssAppsShortcutsSkipClick")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlSetTip($Group_ProcessWithoutShortcuts, "Do not create or process any shortcuts for ...")
	Global $Group_RemovePreExisting = GUICtrlCreateGroup("Remove pre-existing:", 150, 40, 252, 96)
	GUICtrlSetFont($Group_RemovePreExisting, 9, 800, 0, "MS Sans Serif")
	GUICtrlSetColor($Group_RemovePreExisting, 0x000080)
	Global $Checkbox_scDesktopRemoval = GUICtrlCreateCheckbox("Desktop", 299, 62, 90, 17)
	GUICtrlSetColor($Checkbox_scDesktopRemoval, 0x000000)
	GUICtrlSetTip($Checkbox_scDesktopRemoval, "Create shortcut on ''Desktop''. Only the first shortcut from ''Shortcut Names to Keep'' or from ''Definitions''.")
	GUICtrlSetOnEvent($Checkbox_scDesktopRemoval, "Checkbox_scDesktopRemovalClick")
	Global $Checkbox_scQLaunchRemoval = GUICtrlCreateCheckbox("Quick Launch", 299, 78, 90, 17)
	GUICtrlSetColor($Checkbox_scQLaunchRemoval, 0x000000)
	GUICtrlSetTip($Checkbox_scQLaunchRemoval, "Create shortcut in ''QuickLaunch''. Only the first shortcut from ''Shortcut Names to Keep'' or from ''Definitions''.")
	GUICtrlSetOnEvent($Checkbox_scQLaunchRemoval, "Checkbox_scQLaunchRemovalClick")
	Global $Checkbox_scSendToRemoval = GUICtrlCreateCheckbox("SendTo", 299, 94, 90, 17)
	GUICtrlSetColor($Checkbox_scSendToRemoval, 0x000000)
	GUICtrlSetTip($Checkbox_scSendToRemoval, "Create shortcut in ''SendTo'' context-menu. Only the first shortcut from ''Shortcut Names to Keep'' or from ''Definitions''.")
	GUICtrlSetOnEvent($Checkbox_scSendToRemoval, "Checkbox_scSendToRemovalClick")
	Global $Checkbox_scTaskbarPinRemoval = GUICtrlCreateCheckbox("Taskbar Pin", 299, 110, 90, 17)
	GUICtrlSetColor($Checkbox_scTaskbarPinRemoval, 0x000000)
	GUICtrlSetTip($Checkbox_scTaskbarPinRemoval, "Pin shortcut to the Taskbar (Windows 7 only)")
	GUICtrlSetOnEvent($Checkbox_scTaskbarPinRemoval, "Checkbox_scTaskbarPinRemovalClick")
	Global $Group_StartmenuRemovals = GUICtrlCreateGroup("Startmenu:", 157, 56, 125, 71)
	GUICtrlSetColor($Group_StartmenuRemovals, 0x800080)
	Global $Checkbox_scRootRemoval = GUICtrlCreateCheckbox("Root", 163, 71, 45, 17)
	GUICtrlSetColor($Checkbox_scRootRemoval, 0x000000)
	GUICtrlSetTip($Checkbox_scRootRemoval, "Create shortcut in ''Start Menu'' (Root). Only the first shortcut from ''Shortcut Names to Keep'' or from ''Definitions''.")
	GUICtrlSetOnEvent($Checkbox_scRootRemoval, "Checkbox_scRootRemovalClick")
	Global $Checkbox_scProgramsRemoval = GUICtrlCreateCheckbox("Programs", 163, 86, 68, 17)
	GUICtrlSetColor($Checkbox_scProgramsRemoval, 0x000000)
	GUICtrlSetTip($Checkbox_scProgramsRemoval, "Create shortcut in ''Start Menu\Programs''. Only the first shortcut from ''Shortcut Names to Keep'' or from ''Definitions''.")
	GUICtrlSetOnEvent($Checkbox_scProgramsRemoval, "Checkbox_scProgramsRemovalClick")
	Global $Checkbox_scStartupRemoval = GUICtrlCreateCheckbox("Startup", 163, 101, 64, 17)
	GUICtrlSetColor($Checkbox_scStartupRemoval, 0x000000)
	GUICtrlSetTip($Checkbox_scStartupRemoval, "Create shortcut in ''Start Menu\Programs\Startup''. Only the first shortcut from ''Shortcut Names to Keep'' or from ''Definitions''.")
	GUICtrlSetOnEvent($Checkbox_scStartupRemoval, "Checkbox_scStartupRemovalClick")
	Global $Checkbox_scStartmenuPinRemoval = GUICtrlCreateCheckbox("Pin", 235, 72, 43, 17)
	GUICtrlSetColor($Checkbox_scStartmenuPinRemoval, 0x000000)
	GUICtrlSetTip($Checkbox_scStartmenuPinRemoval, "Pin shortcut to the Startmenu (Windows 7 only)")
	GUICtrlSetOnEvent($Checkbox_scStartmenuPinRemoval, "Checkbox_scStartmenuPinRemovalClick")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlSetTip($Group_RemovePreExisting, "Automatically remove pre-existing shortcuts for the following")
	Global $TabSheet_Fadertainer = GUICtrlCreateTabItem("Fadertainer")
	GUICtrlSetState($TabSheet_Fadertainer, $GUI_SHOW)
	Global $Checkbox_Fadertainer = GUICtrlCreateCheckbox("Activate", 32, 46, 70, 17)
	GUICtrlSetFont($Checkbox_Fadertainer, 9, 800, 0, "MS Sans Serif")
	GUICtrlSetOnEvent($Checkbox_Fadertainer, "Checkbox_FadertainerClick")
	Global $Label_Faderspeed = GUICtrlCreateLabel("Speed:", 41, 118, 38, 17, $SS_RIGHT)
	GUICtrlSetFont($Label_Faderspeed, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetOnEvent($Label_Faderspeed, "Label_FaderspeedClick")
	Global $Input_FaderSpeed = GUICtrlCreateInput("", 82, 115, 27, 21)
	GUICtrlSetFont($Input_FaderSpeed, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetOnEvent($Input_FaderSpeed, "Input_FaderSpeedChange")
	Global $Label_FaderSec = GUICtrlCreateLabel("(sec.)", 111, 118, 30, 17)
	GUICtrlSetFont($Label_FaderSec, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetOnEvent($Label_FaderSec, "Label_FaderSecClick")
	Global $Group_Fadertainer = GUICtrlCreateGroup("", 191, 46, 171, 98)
	GUICtrlSetFont($Group_Fadertainer, 9, 400, 0, "MS Sans Serif")
	Global $Radio_FadertainerTL = GUICtrlCreateRadio("TL", 201, 67, 40, 17)
	GUICtrlSetTip($Radio_FadertainerTL, "Top Left")
	GUICtrlSetOnEvent($Radio_FadertainerTL, "Radio_FadertainerTLClick")
	Global $Radio_FadertainerBL = GUICtrlCreateRadio("BL", 201, 114, 40, 17)
	GUICtrlSetTip($Radio_FadertainerBL, "Bottom Left")
	GUICtrlSetOnEvent($Radio_FadertainerBL, "Radio_FadertainerBLClick")
	Global $Radio_FadertainerTR = GUICtrlCreateRadio("TR", 302, 67, 40, 17)
	GUICtrlSetTip($Radio_FadertainerTR, "Top Right")
	GUICtrlSetOnEvent($Radio_FadertainerTR, "Radio_FadertainerTRClick")
	Global $Radio_FadertainerBR = GUICtrlCreateRadio("BR", 302, 114, 40, 17)
	GUICtrlSetTip($Radio_FadertainerBR, "Bottom Right")
	GUICtrlSetOnEvent($Radio_FadertainerBR, "Radio_FadertainerBRClick")
	Global $Radio_FadertainerTC = GUICtrlCreateRadio("TC", 251, 67, 40, 17)
	GUICtrlSetTip($Radio_FadertainerTC, "Top Center")
	GUICtrlSetOnEvent($Radio_FadertainerTC, "Radio_FadertainerTCClick")
	Global $Radio_FadertainerBC = GUICtrlCreateRadio("BC", 251, 114, 40, 17)
	GUICtrlSetTip($Radio_FadertainerBC, "Bottom Center")
	GUICtrlSetOnEvent($Radio_FadertainerBC, "Radio_FadertainerBCClick")
	Global $Radio_FadertainerMC = GUICtrlCreateRadio("MC", 251, 90, 40, 17)
	GUICtrlSetTip($Radio_FadertainerMC, "Middle Center")
	GUICtrlSetOnEvent($Radio_FadertainerMC, "Radio_FadertainerMCClick")
	Global $Radio_FadertainerML = GUICtrlCreateRadio("ML", 201, 90, 40, 17)
	GUICtrlSetTip($Radio_FadertainerML, "Middle Left")
	GUICtrlSetOnEvent($Radio_FadertainerML, "Radio_FadertainerMLClick")
	Global $Radio_FadertainerMR = GUICtrlCreateRadio("MR", 302, 90, 40, 17)
	GUICtrlSetTip($Radio_FadertainerMR, "Middle Right")
	GUICtrlSetOnEvent($Radio_FadertainerMR, "Radio_FadertainerMRClick")
	Global $Radio_FadertainerDefault = GUICtrlCreateRadio("Screen Location:", 201, 46, 102, 17)
	GUICtrlSetTip($Radio_FadertainerDefault, "T=Top, L=Left, R=Right, C=Center, M=Middle, B=Bottom")
	GUICtrlSetOnEvent($Radio_FadertainerDefault, "Radio_FadertainerDefaultClick")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $Checkbox_FaderAlwaysOnTop = GUICtrlCreateCheckbox("Always On Top", 32, 67, 90, 17)
	GUICtrlSetFont($Checkbox_FaderAlwaysOnTop, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetOnEvent($Checkbox_FaderAlwaysOnTop, "Checkbox_FaderAlwaysOnTopClick")
	Global $Combo_FaderModule = GUICtrlCreateCombo("(none)", 152, 162, 177, 100, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
	GUICtrlSetFont($Combo_FaderModule, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetOnEvent($Combo_FaderModule, "Combo_FaderModuleChange")
	Global $Label_FaderModule = GUICtrlCreateLabel("Fader Module:", 76, 166, 72, 17, $SS_RIGHT)
	GUICtrlSetFont($Label_FaderModule, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetOnEvent($Label_FaderModule, "Label_FaderModuleClick")
	Global $Checkbox_FaderDuringInstallsOnly = GUICtrlCreateCheckbox("During Installs Only", 32, 88, 114, 17)
	GUICtrlSetFont($Checkbox_FaderDuringInstallsOnly, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetTip($Checkbox_FaderDuringInstallsOnly, "for Regenerator only")
	GUICtrlSetOnEvent($Checkbox_FaderDuringInstallsOnly, "Checkbox_FaderDuringInstallsOnlyClick")
	Global $TabSheet_ppDrives = GUICtrlCreateTabItem("ppDrives")
	Global $LabelppApps = GUICtrlCreateLabel("ppApps:", 219, 56, 52, 17, $SS_RIGHT)
	GUICtrlSetFont($LabelppApps, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetOnEvent($LabelppApps, "LabelppAppsClick")
	Global $LabelppGames = GUICtrlCreateLabel("ppGames:", 219, 86, 52, 17, $SS_RIGHT)
	GUICtrlSetFont($LabelppGames, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetOnEvent($LabelppGames, "LabelppGamesClick")
	Global $Combo_ppAppsDrive = GUICtrlCreateCombo("", 273, 54, 65, 100, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
	GUICtrlSetFont($Combo_ppAppsDrive, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetOnEvent($Combo_ppAppsDrive, "Combo_ppAppsDriveChange")
	Global $Combo_ppGamesDrive = GUICtrlCreateCombo("", 273, 84, 65, 100, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
	GUICtrlSetFont($Combo_ppGamesDrive, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetOnEvent($Combo_ppGamesDrive, "Combo_ppGamesDriveChange")
	Global $Group_SetNow = GUICtrlCreateGroup("Options:", 76, 122, 254, 75)
	GUICtrlSetFont($Group_SetNow, 9, 800, 0, "MS Sans Serif")
	GUICtrlSetColor($Group_SetNow, 0x000080)
	Global $Checkbox_RegenAllDrives = GUICtrlCreateCheckbox("Regenerator processes all available ppDrives.", 83, 173, 240, 17)
	GUICtrlSetFont($Checkbox_RegenAllDrives, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Checkbox_RegenAllDrives, 0x000000)
	GUICtrlSetTip($Checkbox_RegenAllDrives, "Disable this to regen on only the drives listed here.")
	GUICtrlSetOnEvent($Checkbox_RegenAllDrives, "Checkbox_RegenAllDrivesClick")
	Global $Checkbox_RunRegen = GUICtrlCreateCheckbox("Run Regenerator (after setting)", 83, 139, 240, 17)
	GUICtrlSetFont($Checkbox_RunRegen, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Checkbox_RunRegen, 0x000000)
	GUICtrlSetTip($Checkbox_RunRegen, "Regen on ppDrives only")
	GUICtrlSetOnEvent($Checkbox_RunRegen, "Checkbox_RunRegenClick")
	Global $CheckboxppDrivesMove = GUICtrlCreateCheckbox("Move ppDrives (after setting)", 83, 156, 240, 17)
	GUICtrlSetFont($CheckboxppDrivesMove, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($CheckboxppDrivesMove, 0x000000)
	GUICtrlSetState($CheckboxppDrivesMove, $GUI_DISABLE)
	GUICtrlSetOnEvent($CheckboxppDrivesMove, "CheckboxppDrivesMoveClick")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlSetState($Group_SetNow, $GUI_HIDE)
	Global $Group_ppDriveRescan = GUICtrlCreateGroup("ppDrive Scan Direction:", 31, 37, 156, 81)
	GUICtrlSetFont($Group_ppDriveRescan, 9, 800, 0, "MS Sans Serif")
	GUICtrlSetColor($Group_ppDriveRescan, 0x000080)
	Global $Button_ppDrivesRescan = GUICtrlCreateButton("Rescan && Set Now!", 42, 92, 110, 21)
	GUICtrlSetFont($Button_ppDrivesRescan, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Button_ppDrivesRescan, 0x000000)
	GUICtrlSetOnEvent($Button_ppDrivesRescan, "Button_ppDrivesRescanClick")
	Global $Radio_ppDriveScanForwards = GUICtrlCreateRadio("Forwards (c: to z:)", 38, 71, 113, 17)
	GUICtrlSetFont($Radio_ppDriveScanForwards, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Radio_ppDriveScanForwards, 0x000000)
	GUICtrlSetOnEvent($Radio_ppDriveScanForwards, "Radio_ppDriveScanForwardsClick")
	Global $Radio_ppDriveScanBackwards = GUICtrlCreateRadio("Backwards (z: to c:)", 38, 54, 113, 17)
	GUICtrlSetState($Radio_ppDriveScanBackwards, $GUI_CHECKED)
	GUICtrlSetFont($Radio_ppDriveScanBackwards, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Radio_ppDriveScanBackwards, 0x000000)
	GUICtrlSetOnEvent($Radio_ppDriveScanBackwards, "Radio_ppDriveScanBackwardsClick")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $TabSheet_ssCleaner = GUICtrlCreateTabItem("ssCleaner")
	Global $Group_ssCleanerOptions = GUICtrlCreateGroup("Dud-shortcut removal:", 17, 40, 190, 92)
	GUICtrlSetFont($Group_ssCleanerOptions, 9, 800, 0, "MS Sans Serif")
	GUICtrlSetColor($Group_ssCleanerOptions, 0x000080)
	Global $Radio_ssCleanerAllShortcuts = GUICtrlCreateRadio("All Dud Shortcuts", 24, 91, 113, 17)
	GUICtrlSetFont($Radio_ssCleanerAllShortcuts, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Radio_ssCleanerAllShortcuts, 0x000000)
	GUICtrlSetTip($Radio_ssCleanerAllShortcuts, "All shortcut locations such as Desktop, Sendto, & QuickLaunch will be included in the cleaning.")
	GUICtrlSetOnEvent($Radio_ssCleanerAllShortcuts, "Radio_ssCleanerAllShortcutsClick")
	Global $Radio_ssCleanerStartmenuOnly = GUICtrlCreateRadio("Startmenu Only", 24, 74, 113, 17)
	GUICtrlSetFont($Radio_ssCleanerStartmenuOnly, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Radio_ssCleanerStartmenuOnly, 0x000000)
	GUICtrlSetTip($Radio_ssCleanerStartmenuOnly, "Limits the cleaning location to only the Startmenu.")
	GUICtrlSetOnEvent($Radio_ssCleanerStartmenuOnly, "Radio_ssCleanerStartmenuOnlyClick")
	Global $Radio_ssCleanerDisabled = GUICtrlCreateRadio("Disabled", 24, 57, 113, 17)
	GUICtrlSetFont($Radio_ssCleanerDisabled, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Radio_ssCleanerDisabled, 0x000000)
	GUICtrlSetTip($Radio_ssCleanerDisabled, "Do not perform any cleaning functions.")
	GUICtrlSetOnEvent($Radio_ssCleanerDisabled, "Radio_ssCleanerDisabledClick")
	Global $Checkbox_ssCleanerRemoved = GUICtrlCreateCheckbox("Check removed Startmenu items", 24, 108, 180, 17)
	GUICtrlSetFont($Checkbox_ssCleanerRemoved, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Checkbox_ssCleanerRemoved, 0x000000)
	GUICtrlSetTip($Checkbox_ssCleanerRemoved, "Cleaning is automatically performed when shortcuts are removed such as during Startmenu Style changes.")
	GUICtrlSetOnEvent($Checkbox_ssCleanerRemoved, "Checkbox_ssCleanerRemovedClick")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $Group_ssCleanerNow = GUICtrlCreateGroup("Instant ssCleaning", 229, 40, 170, 160)
	GUICtrlSetFont($Group_ssCleanerNow, 9, 800, 0, "MS Sans Serif")
	GUICtrlSetColor($Group_ssCleanerNow, 0x000080)
	Global $Button_ssCleanerNow = GUICtrlCreateButton("ssClean Now!", 257, 173, 110, 21)
	GUICtrlSetFont($Button_ssCleanerNow, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Button_ssCleanerNow, 0x000000)
	GUICtrlSetOnEvent($Button_ssCleanerNow, "Button_ssCleanerNowClick")
	Global $Group_ssCleanerNowAppPathRemoval = GUICtrlCreateGroup("Remove Folders:", 234, 108, 160, 57)
	Global $Checkbox_ssCleanerNowDeleteDudAppPath = GUICtrlCreateCheckbox("Dud Installed-to paths", 241, 125, 148, 17)
	GUICtrlSetFont($Checkbox_ssCleanerNowDeleteDudAppPath, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Checkbox_ssCleanerNowDeleteDudAppPath, 0x000000)
	GUICtrlSetTip($Checkbox_ssCleanerNowDeleteDudAppPath, "Whether or not to remove the install-to paths referenced by dud shortcuts.")
	GUICtrlSetOnEvent($Checkbox_ssCleanerNowDeleteDudAppPath, "Checkbox_ssCleanerNowDeleteDudAppPathClick")
	Global $Checkbox_ssCleanerNowDeleteUninstalled = GUICtrlCreateCheckbox("Uninstalled (deep scan)", 241, 142, 148, 17)
	GUICtrlSetFont($Checkbox_ssCleanerNowDeleteUninstalled, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Checkbox_ssCleanerNowDeleteUninstalled, 0x000000)
	GUICtrlSetTip($Checkbox_ssCleanerNowDeleteUninstalled, "Do a deep-scan of uninstalled apps or games and remove their folders.")
	GUICtrlSetOnEvent($Checkbox_ssCleanerNowDeleteUninstalled, "Checkbox_ssCleanerNowDeleteUninstalledClick")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $Group_ssCleanerNowOptions = GUICtrlCreateGroup("Dud-shortcut removal:", 234, 54, 160, 54)
	Global $Radio_ssCleanerNowStartmenuOnly = GUICtrlCreateRadio("Startmenu Only", 241, 71, 113, 17)
	GUICtrlSetState($Radio_ssCleanerNowStartmenuOnly, $GUI_CHECKED)
	GUICtrlSetFont($Radio_ssCleanerNowStartmenuOnly, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Radio_ssCleanerNowStartmenuOnly, 0x000000)
	GUICtrlSetTip($Radio_ssCleanerNowStartmenuOnly, "Limits the cleaning location to only the Startmenu.")
	GUICtrlSetOnEvent($Radio_ssCleanerNowStartmenuOnly, "Radio_ssCleanerNowStartmenuOnlyClick")
	Global $Radio_ssCleanerNowAllShortcuts = GUICtrlCreateRadio("All Dud Shortcuts", 241, 88, 113, 17)
	GUICtrlSetFont($Radio_ssCleanerNowAllShortcuts, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Radio_ssCleanerNowAllShortcuts, 0x000000)
	GUICtrlSetTip($Radio_ssCleanerNowAllShortcuts, "All shortcut locations such as Desktop, Sendto, & QuickLaunch will be included in the cleaning.")
	GUICtrlSetOnEvent($Radio_ssCleanerNowAllShortcuts, "Radio_ssCleanerNowAllShortcutsClick")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $Group_AppPathRemoval = GUICtrlCreateGroup("Remove Folders:", 16, 136, 190, 61)
	GUICtrlSetFont($Group_AppPathRemoval, 9, 800, 0, "MS Sans Serif")
	GUICtrlSetColor($Group_AppPathRemoval, 0x000080)
	Global $Checkbox_ssCleanerDeleteDudAppPath = GUICtrlCreateCheckbox("Dud Installed-to paths", 23, 153, 180, 17)
	GUICtrlSetFont($Checkbox_ssCleanerDeleteDudAppPath, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Checkbox_ssCleanerDeleteDudAppPath, 0x000000)
	GUICtrlSetTip($Checkbox_ssCleanerDeleteDudAppPath, "Whether or not to remove the install-to paths referenced by dud shortcuts.")
	GUICtrlSetOnEvent($Checkbox_ssCleanerDeleteDudAppPath, "Checkbox_ssCleanerDeleteDudAppPathClick")
	Global $Checkbox_ssCleanerDeleteUninstalled = GUICtrlCreateCheckbox("Uninstalled (deep scan)", 23, 170, 180, 17)
	GUICtrlSetFont($Checkbox_ssCleanerDeleteUninstalled, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor($Checkbox_ssCleanerDeleteUninstalled, 0x000000)
	GUICtrlSetTip($Checkbox_ssCleanerDeleteUninstalled, "Do a deep-scan of uninstalled apps or games and remove their folders.")
	GUICtrlSetOnEvent($Checkbox_ssCleanerDeleteUninstalled, "Checkbox_ssCleanerDeleteUninstalledClick")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $TabSheet_About = GUICtrlCreateTabItem("About")
	Global $About_Version = GUICtrlCreateLabel("Version xx.xx.xx.xx", 101, 42, 129, 20)
	GUICtrlSetFont($About_Version, 11, 800, 0, "MS Sans Serif")
	GUICtrlSetOnEvent($About_Version, "About_VersionClick")
	Global $About_Logo = GUICtrlCreateIcon("", -1, 18, 48, 59, 59)
	GUICtrlSetOnEvent($About_Logo, "About_LogoClick")
	Global $About_Copyright = GUICtrlCreateLabel("(c)2012, Team ssTek", 96, 62, 130, 20)
	GUICtrlSetFont($About_Copyright, 11, 400, 0, "MS Sans Serif")
	GUICtrlSetOnEvent($About_Copyright, "About_CopyrightClick")
	Global $About_URL = GUICtrlCreateLabel("ssTek Forum", 129, 84, 75, 17)
	GUICtrlSetFont($About_URL, 9, 800, 4, "MS Sans Serif")
	GUICtrlSetColor($About_URL, 0x0000FF)
	GUICtrlSetOnEvent($About_URL, "About_URLClick")
	Global $About_Comment = GUICtrlCreateLabel("Built on LXP Technology", 138, 144, 144, 17)
	GUICtrlSetFont($About_Comment, 9, 800, 0, "MS Sans Serif")
	GUICtrlSetColor($About_Comment, 0x008000)
	GUICtrlSetOnEvent($About_Comment, "About_CommentClick")
	Global $About_CoreVer = GUICtrlCreateLabel("Licensed under the terms of GPLv3", 108, 159, 204, 17)
	GUICtrlSetFont($About_CoreVer, 9, 800, 4, "MS Sans Serif")
	GUICtrlSetColor($About_CoreVer, 0x0000FF)
	GUICtrlSetOnEvent($About_CoreVer, "About_CoreVerClick")
	Global $Label_CLIswitches = GUICtrlCreateLabel("List of command-line switches", 124, 186, 173, 17)
	GUICtrlSetFont($Label_CLIswitches, 9, 800, 4, "MS Sans Serif")
	GUICtrlSetColor($Label_CLIswitches, 0x0000FF)
	GUICtrlSetOnEvent($Label_CLIswitches, "Label_CLIswitchesClick")
	Global $About_URL2 = GUICtrlCreateLabel("LastOS Forum", 129, 102, 75, 17)
	GUICtrlSetFont($About_URL2, 9, 800, 4, "MS Sans Serif")
	GUICtrlSetColor($About_URL2, 0x0000FF)
	GUICtrlSetOnEvent($About_URL2, "About_URL2Click")
	Global $About_URL3 = GUICtrlCreateLabel("#WebSite3#", 129, 120, 75, 17)
	GUICtrlSetFont($About_URL3, 9, 800, 4, "MS Sans Serif")
	GUICtrlSetColor($About_URL3, 0x0000FF)
	GUICtrlSetOnEvent($About_URL3, "About_URL3Click")
	GUICtrlCreateTabItem("")
	Global $ButtonOkay = GUICtrlCreateButton("Begin", 218, 221, 46, 20)
	GUICtrlSetOnEvent($ButtonOkay, "ButtonOkayClick")
	Global $ButtonCancel = GUICtrlCreateButton("Cancel", 159, 221, 46, 20)
	GUICtrlSetOnEvent($ButtonCancel, "ssControlPanelClose")
	Global $Label_CheckForUpdate = GUICtrlCreateLabel("Check for update...", 299, 233, 114, 17, $SS_RIGHT)
	GUICtrlSetFont($Label_CheckForUpdate, 8, 800, 4, "MS Sans Serif")
	GUICtrlSetColor($Label_CheckForUpdate, 0x0000FF)
	GUICtrlSetOnEvent($Label_CheckForUpdate, "Label_CheckForUpdateClick")
	Global $Label_Helpfile = GUICtrlCreateLabel("Help-file (F1)", 7, 233, 77, 17)
	GUICtrlSetFont($Label_Helpfile, 8, 800, 4, "MS Sans Serif")
	GUICtrlSetColor($Label_Helpfile, 0x0000FF)
	GUICtrlSetOnEvent($Label_Helpfile, "Label_HelpfileClick")
	Global $Label_ResetINI = GUICtrlCreateLabel("Restore Defaults", 7, 212, 99, 17)
	GUICtrlSetFont($Label_ResetINI, 8, 800, 4, "MS Sans Serif")
	GUICtrlSetColor($Label_ResetINI, 0x0000FF)
	GUICtrlSetOnEvent($Label_ResetINI, "Label_ResetINIClick")
	#endregion ### END Koda GUI section ###

	;Detail ssControlPanel form
	;GetSetupSOptions($ssConfigINI)
	GUICtrlSetData($About_Version, 'Version ' & $ThisAppVersion)
	GUICtrlSetData($About_Copyright, '© 2024, Vergitek Solutions')
	GUICtrlSetData($About_URL, 'ssTek Forum')
	GUICtrlSetData($About_URL2, 'LastOS Forum')
	GUICtrlSetData($About_URL3, '#WebSite3#')
	$aPos = ControlGetPos('', '', $ssControlPanel)
	Local $ssControlPanel_Width = $aPos[2], $ssControlPanel_Height = $aPos[3], $CtrlOffset
	CenterMe($ssControlPanel, $TabMenu, $ssControlPanel_Width, 0)
	$aPos = ControlGetPos($ssControlPanel, '', $TabMenu)
	Local $TabMenu_Left = $aPos[0] * 2, $TabMenu_Top = $aPos[1], $TabMenu_Width = $aPos[2], $TabMenu_Height = $aPos[3]
	$aPos = ControlGetPos($ssControlPanel, '', $ButtonOkay)
	Local $Button_Width = $aPos[2], $Button_Height = $aPos[3], $Button_Top = $TabMenu_Height + 8 * 2
;~ 	GUICtrlSetPos($ButtonOkay, ($ssControlPanel_Width - $Button_Width * 3) / 2 - 9, $Button_Top, $Button_Width, $Button_Height);l,t,w,h
;~ 	GUICtrlSetPos($ButtonCancel, ($ssControlPanel_Width - $Button_Width * 3) / 2 + $Button_Width * 2 - 30, $Button_Top, $Button_Width, $Button_Height);l,t,w,h
	GUICtrlSetState($TabSheet_StartMenu, $GUI_SHOW)
	ControlSetText('', '', $ssControlPanel, $ThisAppTitle)
	GUICtrlSetCursor($Label_CheckForUpdate, 0)
	GUICtrlSetCursor($Label_Helpfile, 0)
	GUICtrlSetCursor($Label_ResetINI, 0)
	If $NoUpdate Then GUICtrlSetState($Label_CheckForUpdate, $GUI_DISABLE)

	;StartMenu Tab
	$HelpTopic = 'StartmenuOpt'
	GUICtrlSetData($Label_MenuStyle, $MenuStyles[$MenuStyle][1])
	ResizeMe($ssControlPanel, $Label_MenuStyle, 10, 800, 0, 'MS Sans Serif')
	$aPos = ControlGetPos($ssControlPanel, GUICtrlRead($Label_MenuStyle), $Label_MenuStyle)
	Local $Label_MenuStyle_Width = $aPos[2], $Label_MenuStyle_Height = $aPos[3]
	CenterMe($ssControlPanel, $Label_CurrentMenuStyle, $ssControlPanel_Width, 0)
	$aPos = ControlGetPos($ssControlPanel, GUICtrlRead($Label_CurrentMenuStyle), $Label_CurrentMenuStyle)
	GUICtrlSetPos($Label_CurrentMenuStyle, $aPos[0] - ($Label_MenuStyle_Width / 2), $aPos[1])
	$aPos = ControlGetPos($ssControlPanel, GUICtrlRead($Label_CurrentMenuStyle), $Label_CurrentMenuStyle)
	GUICtrlSetPos($Label_MenuStyle, $aPos[0] + $aPos[2], $aPos[1] - 2, $Label_MenuStyle_Width, $Label_MenuStyle_Height);l,t,w,h
	CenterMe($ssControlPanel, $LabelMenu, $ssControlPanel_Width, 0)
	$aPos = ControlGetPos($ssControlPanel, GUICtrlRead($LabelMenu), $LabelMenu)
	$CtrlOffset = 75
	GUICtrlSetPos($ComboMenuStyle, 5 + $CtrlOffset, $aPos[1] + 20, $TabMenu_Width - $CtrlOffset * 2, $GUI_DOCKHEIGHT);l,t,w,h
	GUICtrlSetData($ComboMenuStyle, $MenuStyleChoices)
;~ 	GUICtrlSetPos($CheckboxMenuSort, ($TabMenu_Width - 70) / 2, $aPos[1] + 50, 70, 17);l,t,w,h
	GUICtrlSetState($CheckboxMenuSort, $GUI_CHECKED)
	If $KeepStartMenuFolders Then GUICtrlSetState($Checkbox_KeepStartMenuFolders, $GUI_CHECKED)
	If $KeepStartMenuDefaults Then GUICtrlSetState($Checkbox_KeepStartMenuDefaults, $GUI_CHECKED)

	;Preferences Tab
	Select
		Case $Mute
			GUICtrlSetState($radioMute, $GUI_CHECKED)
			GUICtrlSetState($Checkbox_AlwaysOnTop, $GUI_DISABLE)
		Case $TrayOnly
			GUICtrlSetState($radioTrayOnly, $GUI_CHECKED)
			GUICtrlSetState($Checkbox_AlwaysOnTop, $GUI_DISABLE)
		Case $SplashOnly
			GUICtrlSetState($radioSplashOnly, $GUI_CHECKED)
			GUICtrlSetState($Checkbox_AlwaysOnTop, $GUI_ENABLE)
		Case Else ; Show
			GUICtrlSetState($radioShow, $GUI_CHECKED)
			GUICtrlSetState($Checkbox_AlwaysOnTop, $GUI_ENABLE)
	EndSelect
	If $SplashOnTop Then GUICtrlSetState($Checkbox_AlwaysOnTop, $GUI_CHECKED)
	If $SafeInstall Then GUICtrlSetState($Checkbox_SafeInstall, $GUI_CHECKED)
	If $ssUninstall Then GUICtrlSetState($Checkbox_ssUninstall, $GUI_CHECKED)
	If $SkipOSArch Then GUICtrlSetState($Checkbox_SkipOSArch, $GUI_CHECKED)
	If $Debug Then GUICtrlSetState($Checkbox_LogDebugging, $GUI_CHECKED)
	If $Log Then GUICtrlSetState($Checkbox_LogReporting, $GUI_CHECKED)
	GUICtrlSetData($Input_RepoLink, $RepoLink & '/' & $RepoFolder)
	GUICtrlSetData($Input_BackupRepoLink, $BackupRepoLink & '/' & $RepoFolder)
	If $AutoUpdate Then GUICtrlSetState($Checkbox_AutoUpdate, $GUI_CHECKED)
	If $DualArchInstalls = 'a' Then
		GUICtrlSetState($Radio_ForceType2a, $GUI_CHECKED)
	Else
		GUICtrlSetState($Radio_ForceType2b, $GUI_CHECKED)
	EndIf

	;Shortcuts Tab
	If $ssAppsShortcutsSkip Then GUICtrlSetState($Checkbox_ssAppsShortcutsSkip, $GUI_CHECKED)
	If $ppAppsShortcutsSkip Then GUICtrlSetState($Checkbox_ppAppsShortcutsSkip, $GUI_CHECKED)
	If $ppGamesShortcutsSkip Then GUICtrlSetState($Checkbox_ppGamesShortcutsSkip, $GUI_CHECKED)
	If $remDesktop Then GUICtrlSetState($Checkbox_scDesktopRemoval, $GUI_CHECKED)
	If $remProgramsRoot Then GUICtrlSetState($Checkbox_scProgramsRemoval, $GUI_CHECKED)
	If $remStartup Then GUICtrlSetState($Checkbox_scStartupRemoval, $GUI_CHECKED)
	If $remSendto Then GUICtrlSetState($Checkbox_scSendToRemoval, $GUI_CHECKED)
	If $remStartmenuPin Then GUICtrlSetState($Checkbox_scStartmenuPinRemoval, $GUI_CHECKED)
	If $remStartmenuRoot Then GUICtrlSetState($Checkbox_scRootRemoval, $GUI_CHECKED)
	If $remQuickLaunch Then GUICtrlSetState($Checkbox_scQLaunchRemoval, $GUI_CHECKED)
	If $remTaskbarPin Then GUICtrlSetState($Checkbox_scTaskbarPinRemoval, $GUI_CHECKED)

	;Fadertainer Tab
	SetFadertainer()
	Combo_FaderModulePopulate()

	;ppDrives Tab
	$CtrlOffset = 30
	GUICtrlSetData($Combo_ppAppsDrive, $ppAppsDriveChoices, $ppAppsDrive)
	GUICtrlSetData($Combo_ppGamesDrive, $ppGamesDriveChoices, $ppGamesDrive)
	GUICtrlSetState($CheckboxppDrivesMove, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_RegenAllDrives, $GUI_UNCHECKED)
	If $RegenAllDrives Then GUICtrlSetState($Checkbox_RegenAllDrives, $GUI_CHECKED)
	If $ppDrivesScanDirection = 1 Then
		GUICtrlSetState($Radio_ppDriveScanForwards, $GUI_CHECKED)
	Else
		GUICtrlSetState($Radio_ppDriveScanBackwards, $GUI_CHECKED)
	EndIf

	;ssCleaner Tab
	Switch $ssCleaner
		Case 0
			GUICtrlSetState($Radio_ssCleanerDisabled, $GUI_CHECKED)
			GUICtrlSetState($Checkbox_ssCleanerDeleteDudAppPath, $GUI_DISABLE)
			GUICtrlSetState($Checkbox_ssCleanerDeleteUninstalled, $GUI_DISABLE)
			GUICtrlSetState($Checkbox_ssCleanerRemoved, $GUI_DISABLE)
		Case 2
			GUICtrlSetState($Radio_ssCleanerAllShortcuts, $GUI_CHECKED)
			GUICtrlSetState($Checkbox_ssCleanerDeleteDudAppPath, $GUI_ENABLE)
			GUICtrlSetState($Checkbox_ssCleanerDeleteUninstalled, $GUI_ENABLE)
			GUICtrlSetState($Checkbox_ssCleanerRemoved, $GUI_ENABLE)
		Case Else
			GUICtrlSetState($Radio_ssCleanerStartmenuOnly, $GUI_CHECKED)
			GUICtrlSetState($Checkbox_ssCleanerDeleteDudAppPath, $GUI_ENABLE)
			GUICtrlSetState($Checkbox_ssCleanerDeleteUninstalled, $GUI_ENABLE)
			GUICtrlSetState($Checkbox_ssCleanerRemoved, $GUI_ENABLE)
	EndSwitch
	If $ssCleanRemovedMenuItem Then
		GUICtrlSetState($Checkbox_ssCleanerRemoved, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_ssCleanerRemoved, $GUI_UNCHECKED)
	EndIf
	If $ssCleanerDeleteUninstalled Then
		GUICtrlSetState($Checkbox_ssCleanerDeleteUninstalled, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_ssCleanerDeleteUninstalled, $GUI_UNCHECKED)
	EndIf
	If $ssCleanerDeleteDudAppPath Then
		GUICtrlSetState($Checkbox_ssCleanerDeleteDudAppPath, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_ssCleanerDeleteDudAppPath, $GUI_UNCHECKED)
	EndIf

	;About Tab
	If $TempPixDir = '' Then
		$TempPixDir = GenerateTempFolder()
		DirCreate($TempPixDir)
	EndIf
	If Not FileExists($TempPixDir & '\' & $ThisAppFilename & '.ico') Then FileInstall('.\ssControlPanel.ico', $TempPixDir & '\' & $ThisAppFilename & '.ico')
	If FileExists($TempPixDir & '\' & $ThisAppFilename & '.ico') Then GUICtrlSetImage($About_Logo, $TempPixDir & '\' & $ThisAppFilename & '.ico')

	$aPos = ControlGetPos($ssControlPanel, '', $About_Logo)
	Local $About_Logo_Left = $aPos[0], $About_Logo_Top = $aPos[1], $About_Logo_Width = $aPos[2], $About_Logo_Height = $aPos[3]

	;Logo upper left corner w/ Text-only centering
	ResizeMe($ssControlPanel, $About_Version, 10, 800, 0, 'MS Sans Serif')
	CenterMe($ssControlPanel, $About_Version, $ssControlPanel_Width, $TabMenu_Left)
	ResizeMe($ssControlPanel, $About_CoreVer, 8, 800, 0, 'MS Sans Serif')
	CenterMe($ssControlPanel, $About_CoreVer, $ssControlPanel_Width, $TabMenu_Left)
	GUICtrlSetCursor($About_CoreVer, 0) ; hand-hover
	ResizeMe($ssControlPanel, $About_Copyright, 10, 400, 0, 'MS Sans Serif')
	CenterMe($ssControlPanel, $About_Copyright, $ssControlPanel_Width, $TabMenu_Left)
	ResizeMe($ssControlPanel, $About_URL, 8, 800, 4, 'MS Sans Serif')
	CenterMe($ssControlPanel, $About_URL, $ssControlPanel_Width, $TabMenu_Left)
	ResizeMe($ssControlPanel, $About_URL2, 8, 800, 4, 'MS Sans Serif')
	CenterMe($ssControlPanel, $About_URL2, $ssControlPanel_Width, $TabMenu_Left)
	ResizeMe($ssControlPanel, $About_URL3, 8, 800, 4, 'MS Sans Serif')
	CenterMe($ssControlPanel, $About_URL3, $ssControlPanel_Width, $TabMenu_Left)
	GUICtrlSetCursor($About_URL, 0)
	GUICtrlSetCursor($About_URL2, 0)
	GUICtrlSetCursor($About_URL3, 0)
	ResizeMe($ssControlPanel, $About_Comment, 8, 800, 0, 'MS Sans Serif')
	CenterMe($ssControlPanel, $About_Comment, $ssControlPanel_Width, $TabMenu_Left)
	ResizeMe($ssControlPanel, $Label_CLIswitches, 8, 800, 0, 'MS Sans Serif')
	CenterMe($ssControlPanel, $Label_CLIswitches, $ssControlPanel_Width, $TabMenu_Left)
	GUICtrlSetCursor($Label_CLIswitches, 0) ; hand-hover

	GUIRegisterMsg($WM_COMMAND, "MY_WM_COMMAND")
	GUISetState(@SW_SHOW, $ssControlPanel)
	HotKeySet('{F1}', 'HelpReq')
	$HelpTopic = 'ssControlPanel'

	Global $SortNow = True, $MoveNow = False, $SetNow = False
	While 1
		Sleep(100)
	WEnd
Else
	Main()
EndIf

#region ;########################################## Form Controls ###############################################################

Func About_CommentClick()
EndFunc

Func About_CopyrightClick()
EndFunc

Func About_CoreVerClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|About_CoreVerClick()' & @CRLF)
	$HelpTopic = 'GNUGeneralPublicLicenseGPLv3'
	If ProcessExists($Help_PID) Then ProcessClose($Help_PID)
	$Help_PID = Run('hh.exe ' & $HelpFile & '::/' & $HelpTopic & '.html')
EndFunc

Func About_LogoClick()
EndFunc

Func About_URL2Click()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|About_URL2Click()' & @CRLF)
	ShellExecute($AboutLink2)
EndFunc
Func About_URL3Click()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|About_URL3Click()' & @CRLF)
	ShellExecute($AboutLink3)
EndFunc

Func About_URLClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|About_URLClick()' & @CRLF)
	ShellExecute($AboutLink1)
EndFunc

Func About_VersionClick()
EndFunc

Func Button_ppDrivesRescanClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_ppDrivesRescanClick()' & @CRLF)
	If $ppDrivesScanDirection = 1 Then
		NeoIniWrite($ssConfigINI, 'Options', 'ppDrivesScanDirection', 'Forwards')
	Else
		NeoIniWrite($ssConfigINI, 'Options', 'ppDrivesScanDirection', 'Backwards')
	EndIf
	FileDelete(@WindowsDir & '\ppAppDrive.ini')
	FileDelete(@WindowsDir & '\ppGameDrive.ini')
	$ppAppsDrive = ''
	$ppGamesDrive = ''
	GUICtrlSetData($Combo_ppAppsDrive, $ppAppsDrive, $ppAppsDrive)
	GUICtrlSetData($Combo_ppGamesDrive, $ppGamesDrive, $ppGamesDrive)
	GetppDrives()
	GUICtrlSetData($Combo_ppAppsDrive, $ppAppsDriveChoices, $ppAppsDrive)
	GUICtrlSetData($Combo_ppGamesDrive, $ppGamesDriveChoices, $ppGamesDrive)
	If $ppDrivesRunRegen Then
		GUISetState(@SW_DISABLE, $ssControlPanel)
		GUICtrlSetState($TabMenu, $GUI_DISABLE)
		RunShortcutsGenerator()
		Checkbox_RunRegenClick()
		GUICtrlSetState($Checkbox_RunRegen, $GUI_DISABLE)
		GUICtrlSetState($TabMenu, $GUI_ENABLE)
		GUISetState(@SW_ENABLE, $ssControlPanel)
	EndIf
	$SetNow = False
EndFunc

Func Button_ssCleanerNowClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_ssCleanerNowClick()' & @CRLF)
	Local $BalloonTipsIn = True, $SplashTipsIn = False
	Local $ssCleaner_Temp = $ssCleaner, $ssCleanerDeleteUninstalled_Temp = $ssCleanerDeleteUninstalled, $ssCleanerDeleteDudAppPath_Temp = $ssCleanerDeleteDudAppPath
	Select
		Case BitAND(GUICtrlRead($Radio_ssCleanerNowStartmenuOnly), $GUI_CHECKED) = $GUI_CHECKED
			$ssCleaner = 1
		Case BitAND(GUICtrlRead($Radio_ssCleanerNowAllShortcuts), $GUI_CHECKED) = $GUI_CHECKED
			$ssCleaner = 2
	EndSelect
	$ssCleanerDeleteUninstalled = (BitAND(GUICtrlRead($Checkbox_ssCleanerNowDeleteUninstalled), $GUI_CHECKED) = $GUI_CHECKED)
	$ssCleanerDeleteDudAppPath = (BitAND(GUICtrlRead($Checkbox_ssCleanerNowDeleteDudAppPath), $GUI_CHECKED) = $GUI_CHECKED)
	If $ssCleaner > 0 Then
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
		If $ssCleanerDeleteUninstalled Then
			DeleteUninstalled(@ProgramFilesDir)
			If StringInStr(@CommonFilesDir, @ProgramFilesDir) <> 1 Then DeleteUninstalled(@CommonFilesDir); In case not a subdir
			If $OSArch64 And $ProgramFilesDir32 Then
				DeleteUninstalled(EnvGet('ProgramFiles(x86)'))
				If StringInStr(EnvGet('COMMONPROGRAMFILES(x86)'), EnvGet('ProgramFiles(x86)')) <> 1 Then DeleteUninstalled(EnvGet('COMMONPROGRAMFILES(x86)')); In case not a subdir
			EndIf
			DeleteUninstalled(@WindowsDir)
			If StringInStr(@SystemDir, @WindowsDir) <> 1 Then DeleteUninstalled(@SystemDir); In case not a subdir
			DeleteUninstalled($ppAppsDrive & '\ppApps')
			DeleteUninstalled($ppGamesDrive & '\ppGames')
		EndIf
	EndIf
	If $KeepStartMenuFolders Then CopyMenu($MenuStyle)
	$ssCleaner = $ssCleaner_Temp
	$ssCleanerDeleteUninstalled = $ssCleanerDeleteUninstalled_Temp
	$ssCleanerDeleteDudAppPath = $ssCleanerDeleteDudAppPath_Temp
	_TrayTip($ThisAppTitle, '', 300, 16)
	SplashOff()
	If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Scanning Done' & @CRLF)
EndFunc

Func ButtonOkayClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|ButtonOkayClick()' & @CRLF)
	Local $n = GUICtrlRead($ComboMenuStyle)
	Select
		Case (StringLeft($n, 9) = 'Standard ')
			$CLIparameters[0] += 1
			ReDim $CLIparameters[$CLIparameters[0] + 1]
			$CLIparameters[$CLIparameters[0]] = '--Standard'
		Case (StringLeft($n, 7) <> 'Choose:')
			$CLIparameters[0] += 1
			ReDim $CLIparameters[$CLIparameters[0] + 1]
			$CLIparameters[$CLIparameters[0]] = '--' & $n
	EndSelect
	If Not $SortNow Then
		$CLIparameters[0] += 1
		ReDim $CLIparameters[$CLIparameters[0] + 1]
		$CLIparameters[$CLIparameters[0]] = '--MenuInstallOnly'
	EndIf
	$n = GUICtrlRead($Combo_ppAppsDrive)
	If ($n <> $ppAppsDrive) Or $SetNow Then
		$CLIparameters[0] += 1
		ReDim $CLIparameters[$CLIparameters[0] + 1]
		$CLIparameters[$CLIparameters[0]] = '--ppAppsDrive=' & $n
		If $MoveNow Then
			$CLIparameters[0] += 1
			ReDim $CLIparameters[$CLIparameters[0] + 1]
			$CLIparameters[$CLIparameters[0]] = '--ppAppsDriveMove=' & $n
		EndIf
	EndIf
	$n = GUICtrlRead($Combo_ppGamesDrive)
	If ($n <> $ppGamesDrive) Or $SetNow Then
		$CLIparameters[0] += 1
		ReDim $CLIparameters[$CLIparameters[0] + 1]
		$CLIparameters[$CLIparameters[0]] = '--ppGamesDrive=' & $n
		If $MoveNow Then
			$CLIparameters[0] += 1
			ReDim $CLIparameters[$CLIparameters[0] + 1]
			$CLIparameters[$CLIparameters[0]] = '--ppGamesDriveMove=' & $n
		EndIf
	EndIf
	GUISetState(@SW_HIDE, $ssControlPanel)
	If FileExists($ssConfigINI) Then
		NeoIniWrite($ssConfigINI, 'Reporting Mode', 'Mute', $Mute)
		NeoIniWrite($ssConfigINI, 'Reporting Mode', 'TrayOnly', $TrayOnly)
		NeoIniWrite($ssConfigINI, 'Reporting Mode', 'SplashOnly', $SplashOnly)
		NeoIniWrite($ssConfigINI, 'Reporting Mode', 'SplashOnTop', $SplashOnTop)
		NeoIniWrite($ssConfigINI, 'Reporting Mode', 'Debug', $Debug)
		NeoIniWrite($ssConfigINI, 'Reporting Mode', 'Log', $Log)
	EndIf
	GetReportingMode($ssConfigINI)
	If $BalloonTips Then
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', '2')
		Opt('TrayIconHide', 0) ;Show tray icon
		Opt('TrayAutoPause', 0) ;Turn off autopause
	Else
		Opt('TrayIconHide', 1) ;Hide tray icon
	EndIf
	Main()
EndFunc

Func Checkbox_AlwaysOnTopClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_AlwaysOnTopClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_AlwaysOnTop)
		Case $GUI_CHECKED
			$SplashOnTop = True
		Case $GUI_UNCHECKED
			$SplashOnTop = False
	EndSwitch
EndFunc

Func Checkbox_AutoUpdateClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_AutoUpdateClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_AutoUpdate)
		Case $GUI_CHECKED
			$AutoUpdate = True
		Case $GUI_UNCHECKED
			$AutoUpdate = False
	EndSwitch
EndFunc

Func Checkbox_FaderAlwaysOnTopClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_FaderAlwaysOnTopClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_FaderAlwaysOnTop)
		Case $GUI_CHECKED
			$FaderOnTop = True
		Case $GUI_UNCHECKED
			$FaderOnTop = False
	EndSwitch
EndFunc

Func Checkbox_FaderDuringInstallsOnlyClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_FaderDuringInstallsOnlyClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_FaderDuringInstallsOnly)
		Case $GUI_CHECKED
			$FaderInstallsOnly = True
		Case $GUI_UNCHECKED
			$FaderInstallsOnly = False
	EndSwitch
EndFunc

Func Checkbox_FadertainerClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_FadertainerClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_Fadertainer)
		Case $GUI_CHECKED
			$Fadertainer = True
		Case $GUI_UNCHECKED
			$Fadertainer = False
	EndSwitch
	SetFadertainer()
EndFunc

Func Checkbox_KeepStartMenuFoldersClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_KeepStartMenuFoldersClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_KeepStartMenuFolders)
		Case $GUI_CHECKED
			$KeepStartMenuFolders = True
		Case $GUI_UNCHECKED
			$KeepStartMenuFolders = False
	EndSwitch
EndFunc

Func Checkbox_KeepStartMenuDefaultsClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_KeepStartMenuDefaultsClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_KeepStartMenuDefaults)
		Case $GUI_CHECKED
			$KeepStartMenuDefaults = True
		Case $GUI_UNCHECKED
			$KeepStartMenuDefaults = False
	EndSwitch
EndFunc

Func Checkbox_LogDebuggingClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_LogDebuggingClick()' & @CRLF)
	$Debug = Not $Debug
	If $Debug Then
		GUICtrlSetState($Checkbox_LogDebugging, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_LogDebugging, $GUI_UNCHECKED)
	EndIf
EndFunc

Func Checkbox_LogReportingClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_LogReportingClick()' & @CRLF)
	$Log = Not $Log
	If $Log Then
		GUICtrlSetState($Checkbox_LogReporting, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_LogReporting, $GUI_UNCHECKED)
	EndIf
EndFunc

Func Checkbox_ppAppsShortcutsSkipClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_ppAppsShortcutsSkipClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_ppAppsShortcutsSkip)
		Case $GUI_CHECKED
			$ppAppsShortcutsSkip = True
		Case $GUI_UNCHECKED
			$ppAppsShortcutsSkip = False
	EndSwitch
EndFunc

Func Checkbox_ppGamesShortcutsSkipClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_ppGamesShortcutsSkipClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_ppGamesShortcutsSkip)
		Case $GUI_CHECKED
			$ppGamesShortcutsSkip = True
		Case $GUI_UNCHECKED
			$ppGamesShortcutsSkip = False
	EndSwitch
EndFunc

Func Checkbox_RegenAllDrivesClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_RegenAllDrivesClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_RegenAllDrives)
		Case $GUI_CHECKED
			$RegenAllDrives = True
		Case $GUI_UNCHECKED
			$RegenAllDrives = False
	EndSwitch
EndFunc

Func Checkbox_RunRegenClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_RunRegenClick()' & @CRLF)
	$ppDrivesRunRegen = Not $ppDrivesRunRegen
	$MoveNow = False
	If $ppDrivesRunRegen Then
		GUICtrlSetState($Checkbox_RunRegen, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_RunRegen, $GUI_UNCHECKED)
	EndIf
EndFunc

Func Checkbox_SafeInstallClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_SafeInstallClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_SafeInstall)
		Case $GUI_CHECKED
			$SafeInstall = True
		Case $GUI_UNCHECKED
			$SafeInstall = False
	EndSwitch
EndFunc

Func Checkbox_scDesktopRemovalClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_scDesktopRemovalClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_scDesktopRemoval)
		Case $GUI_CHECKED
			$remDesktop = True
		Case $GUI_UNCHECKED
			$remDesktop = False
	EndSwitch
EndFunc

Func Checkbox_scProgramsRemovalClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_scProgramsRemovalClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_scProgramsRemoval)
		Case $GUI_CHECKED
			$remProgramsRoot = True
		Case $GUI_UNCHECKED
			$remProgramsRoot = False
	EndSwitch
EndFunc

Func Checkbox_scQLaunchRemovalClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_scQLaunchRemovalClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_scQLaunchRemoval)
		Case $GUI_CHECKED
			$remQuickLaunch = True
		Case $GUI_UNCHECKED
			$remQuickLaunch = False
	EndSwitch
EndFunc

Func Checkbox_scRootRemovalClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_scRootRemovalClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_scRootRemoval)
		Case $GUI_CHECKED
			$remStartmenuRoot = True
		Case $GUI_UNCHECKED
			$remStartmenuRoot = False
	EndSwitch
EndFunc

Func Checkbox_scSendToRemovalClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_scSendToRemovalClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_scSendToRemoval)
		Case $GUI_CHECKED
			$remSendto = True
		Case $GUI_UNCHECKED
			$remSendto = False
	EndSwitch
EndFunc

Func Checkbox_scStartupRemovalClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_scStartupRemovalClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_scStartupRemoval)
		Case $GUI_CHECKED
			$remStartup = True
		Case $GUI_UNCHECKED
			$remStartup = False
	EndSwitch
EndFunc

Func Checkbox_scStartmenuPinRemovalClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_scStartmenuPinRemovalClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_scStartmenuPinRemoval)
		Case $GUI_CHECKED
			$remStartmenuPin = True
		Case $GUI_UNCHECKED
			$remStartmenuPin = False
	EndSwitch
EndFunc

Func Checkbox_scTaskbarPinRemovalClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_scTaskbarPinRemovalClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_scTaskbarPinRemoval)
		Case $GUI_CHECKED
			$remTaskbarPin = True
		Case $GUI_UNCHECKED
			$remTaskbarPin = False
	EndSwitch
EndFunc

Func Checkbox_SkipOSArchClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_SkipOSArchClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_SkipOSArch)
		Case $GUI_CHECKED
			$SkipOSArch = True
		Case $GUI_UNCHECKED
			$SkipOSArch = False
	EndSwitch
EndFunc

Func Checkbox_ssAppsShortcutsSkipClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_ssAppsShortcutsSkipClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_ssAppsShortcutsSkip)
		Case $GUI_CHECKED
			$ssAppsShortcutsSkip = True
		Case $GUI_UNCHECKED
			$ssAppsShortcutsSkip = False
	EndSwitch
EndFunc

Func Checkbox_ssCleanerNowDeleteUninstalledClick()
EndFunc

Func Checkbox_ssCleanerDeleteDudAppPathClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_ssCleanerDeleteDudAppPathClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_ssCleanerDeleteDudAppPath)
		Case $GUI_CHECKED
			$ssCleanerDeleteDudAppPath = True
		Case $GUI_UNCHECKED
			$ssCleanerDeleteDudAppPath = False
	EndSwitch
EndFunc

Func Checkbox_ssCleanerDeleteUninstalledClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_ssCleanerDeleteUninstalledClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_ssCleanerDeleteUninstalled)
		Case $GUI_CHECKED
			$ssCleanerDeleteUninstalled = True
		Case $GUI_UNCHECKED
			$ssCleanerDeleteUninstalled = False
	EndSwitch
EndFunc
Func Checkbox_ssCleanerNowDeleteDudAppPathClick()
EndFunc

Func Checkbox_ssCleanerRemovedClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_ssCleanerRemovedClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_ssCleanerRemoved)
		Case $GUI_CHECKED
			$ssCleanRemovedMenuItem = True
		Case $GUI_UNCHECKED
			$ssCleanRemovedMenuItem = False
	EndSwitch
EndFunc

Func Checkbox_ssUninstallClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_SafeInstallClick()' & @CRLF)
	Switch GUICtrlRead($Checkbox_ssUninstall)
		Case $GUI_CHECKED
			If Not $ssUninstall Then $ssUninstallChanged = True
			$ssUninstall = True
		Case $GUI_UNCHECKED
			If $ssUninstall Then $ssUninstallChanged = True
			$ssUninstall = False
	EndSwitch
EndFunc

Func CheckboxMenuSortClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|CheckboxMenuSortClick()' & @CRLF)
	Switch GUICtrlRead($CheckboxMenuSort)
		Case $GUI_CHECKED
			$SortNow = True
		Case $GUI_UNCHECKED
			$SortNow = False
	EndSwitch
EndFunc

Func CheckboxppDrivesMoveClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|CheckboxppDrivesMoveClick()' & @CRLF)
	$MoveNow = Not $MoveNow
	$ppDrivesRunRegen = False
	If $MoveNow Then
		GUICtrlSetState($CheckboxppDrivesMove, $GUI_CHECKED)
	Else
		GUICtrlSetState($CheckboxppDrivesMove, $GUI_UNCHECKED)
	EndIf
EndFunc

Func Combo_FaderModuleChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Combo_FaderModuleChange()' & @CRLF)
	$FaderModule = GUICtrlRead($Combo_FaderModule)
	If (StringLeft($FaderModule, 6) = '(none)') Then $FaderModule = ''
EndFunc

Func Combo_FaderModulePopulate()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Combo_FaderModulePopulate()' & @CRLF)
	If $ToolsPath <> '' Then
		Local $i, $FileList, $Combo_FaderModule_Data = ''
		$FileList = _FileListToArray($ToolsPath & '\FaderModules', '*.exe', 1) ; Return files only
		If @error = 0 Then
			For $i = 1 To $FileList[0]
				If $Combo_FaderModule_Data <> '' Then $Combo_FaderModule_Data = $Combo_FaderModule_Data & '|'
				$Combo_FaderModule_Data = $Combo_FaderModule_Data & $FileList[$i]
			Next
			GUICtrlSetData($Combo_FaderModule, $Combo_FaderModule_Data, $FaderModule)
			GUICtrlSetTip($Combo_FaderModule, '')
		EndIf
	EndIf
EndFunc

Func Combo_ppAppsDriveChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Combo_ppAppsDriveChange()' & @CRLF)
	$SetNow = True
	GUICtrlSetState($Checkbox_RunRegen, $GUI_ENABLE)
EndFunc

Func Combo_ppGamesDriveChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Combo_ppGamesDriveChange()' & @CRLF)
	$SetNow = True
	GUICtrlSetState($Checkbox_RunRegen, $GUI_ENABLE)
EndFunc

Func ComboMenuStyleChange()
EndFunc

Func Icon_LogoClick()
EndFunc

Func Input_BackupRepoLinkChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_BackupRepoLinkChange()' & @CRLF)
	If GUICtrlRead($Input_BackupRepoLink) <> $BackupRepoLink & '/' & $RepoFolder Then
		$BackupRepoLink = GetFolderPath(GUICtrlRead($Input_BackupRepoLink))
		$RepoFolder = GetFilename(GUICtrlRead($Input_BackupRepoLink))
		GUICtrlSetData($Input_RepoLink, $RepoLink & '/' & $RepoFolder)
		GUICtrlSetData($Input_BackupRepoLink, $BackupRepoLink & '/' & $RepoFolder)
	EndIf
EndFunc

Func Input_FaderSpeedChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_FaderSpeedChange()' & @CRLF)
	If GUICtrlRead($Input_FaderSpeed) <> $FaderSpeed Then $FaderSpeed = GUICtrlRead($Input_FaderSpeed)
EndFunc

Func Input_RepoLinkChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_RepoLinkChange()' & @CRLF)
	If GUICtrlRead($Input_RepoLink) <> $RepoLink & '/' & $RepoFolder Then
		$RepoLink = GetFolderPath(GUICtrlRead($Input_RepoLink))
		$RepoFolder = GetFilename(GUICtrlRead($Input_RepoLink))
		GUICtrlSetData($Input_BackupRepoLink, $BackupRepoLink & '/' & $RepoFolder)
		GUICtrlSetData($Input_RepoLink, $RepoLink & '/' & $RepoFolder)
	EndIf
EndFunc

Func Label_BackupRepoLinkClick()
EndFunc

Func Label_CheckForUpdateClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_CheckForUpdateClick()' & @CRLF)
	UpdateMe('update.ini', @ScriptDir, True, $UseGUI)
EndFunc

Func Label_CLIswitchesClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_CLIswitches()' & @CRLF)
	$HelpTopic = 'ssControlPanelCommands'
	If ProcessExists($Help_PID) Then ProcessClose($Help_PID)
	$Help_PID = Run('hh.exe ' & $HelpFile & '::/' & $HelpTopic & '.html')
EndFunc
Func Label_CurrentMenuStyleClick()
EndFunc
Func Label_FaderModuleClick()
EndFunc
Func Label_FaderSecClick()
EndFunc
Func Label_FaderspeedClick()
EndFunc

Func Label_HelpfileClick()
	HelpReq()
EndFunc
Func Label_MenuStyleClick()
EndFunc
Func Label_RepoLinkClick()
EndFunc

Func Label_ResetINIClick()
	ResetINI('ssConfig.ini')
	Local $TempDL = GenerateTempFolder(), $File = FileOpen($TempDL & '\' & 'ResetMe.cmd', 10)
	If $File <> -1 Then
		FileWrite($File, 'cd ..' & @CRLF)
		FileWrite($File, '"' & @ScriptFullPath & '" -AutoUpdate=' & $TempDL & @CRLF)
		FileWrite($File, 'exit' & @CRLF)
		FileClose($File)
		FileChangeDir($TempDL)
		If $SetupSFolder <> '' And Not StringInStr(EnvGet('Path'), $SetupSFolder) Then EnvSet('path', $SetupSFolder & ';' & EnvGet('path'))
		Run('ResetMe.cmd', $TempDL, @SW_HIDE)
		Sleep(100)
		FileChangeDir(@ScriptDir)
		Cleanup()
		Exit
	EndIf
EndFunc

Func LabelMenuClick()
EndFunc
Func LabelppAppsClick()
EndFunc
Func LabelppGamesClick()
EndFunc

Func MY_WM_COMMAND($hWnd, $msg, $wParam, $lParam)
	;If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MY_WM_COMMAND()' & @CRLF)
	Local $nNotifyCode = _HiWord($wParam), $hCtrl = $lParam, $nID = _LoWord($wParam)
	Switch $nID
;~ 			Case $Input_AppPath
;~ 				Switch $nNotifyCode
;~ 					Case $EN_CHANGE ; 0x300
;~ 						$AppPathChange = True
;~ 					Case $EN_KILLFOCUS ; 0x200
;~ 						If $AppPathChange Then
;~ 							$AppPathChange = False
;~ 							Input_AppPathChange()
;~ 						EndIf
;~ 					Case $EN_UPDATE ; 0x400
;~ 						$AppPathChange = True
;~ 				EndSwitch
;~ 				$HelpTopic = 'InstalltoPath'
;~ 			Case $Input_DefaultMenu
;~ 				Switch $nNotifyCode
;~ 					Case $EN_CHANGE ; 0x300
;~ 						$DefaultMenuChange = True
;~ 					Case $EN_KILLFOCUS ; 0x200
;~ 						If $DefaultMenuChange Then
;~ 							$DefaultMenuChange = False
;~ 							Input_DefaultMenuChange()
;~ 						EndIf
;~ 					Case $EN_UPDATE ; 0x400
;~ 						$DefaultMenuChange = True
;~ 				EndSwitch
;~ 				$HelpTopic = 'DefaultMenu'
;~ 			Case $Edit_CatalogList
;~ 				Switch $nNotifyCode
;~ 					Case $EN_CHANGE ; 0x300
;~ 						$CatalogListChange = True
;~ 					Case $EN_KILLFOCUS ; 0x200
;~ 						If $CatalogListChange Then
;~ 							$CatalogListChange = False
;~ 							Edit_CatalogListChange()
;~ 							PopulateCombo_Catalog()
;~ 						EndIf
;~ 					Case $EN_UPDATE ; 0x400
;~ 						$CatalogListChange = True
;~ 				EndSwitch
;~ 				$HelpTopic = 'MenuCatalog'
;~ 				;General Tab
;~ 			Case $Input_Title
;~ 				$HelpTopic = 'Title'
;~ 			Case $Input_Version
;~ 				$HelpTopic = 'Version'
;~ 			Case $Input_Publisher, $Input_Language, $Input_Releaser, $Input_Additional, $Input_ReleaseDate, $Input_RequiredRuntimes, $Input_Rating, $Input_InstalledSize, $Input_ReleaseVersion
;~ 				$HelpTopic = 'MetadataEditor'
;~ 			Case $Input_Tags
;~ 				$HelpTopic = 'TagList'
;~ 			Case $Edit_URLs
;~ 				$HelpTopic = 'URLs'
;~ 			Case $Combo_Category, $Input_Categories, $Checkbox_Game
;~ 				$HelpTopic = 'Category'
;~ 			Case $Edit_Description
;~ 				$HelpTopic = 'Description'
;~ 			Case $Radio_Build_ssApp, $Radio_Build_ppApp, $Radio_Build_ppGame, $Radio_Build_ppTweak
;~ 				$HelpTopic = 'BuildType'
;~ 			Case $Radio_Arch_Any, $Radio_Arch_x86, $Radio_Arch_x64
;~ 				$HelpTopic = 'Architecture'
;~ 			Case $Radio_OS_All, $Radio_OS_XP, $Radio_OS_Vista, $Radio_OS_Linux
;~ 				$HelpTopic = 'ForOS'
;~ 			Case $Checkbox_AlwaysShow, $Checkbox_AlwaysHide, $Checkbox_AtSetupOnly, $Checkbox_InstallT13, $Checkbox_RunAsx64, $Checkbox_InstallInstant, $Checkbox_InstallInstant
;~ 				$HelpTopic = 'ssWPIOptions'
;~ 				;Assembly Tab
		Case $ComboMenuStyle
			$HelpTopic = 'MenuStyle'
;~ 			Case $Input_Switches
;~ 				Switch $nNotifyCode
;~ 					Case $EN_CHANGE ; 0x300
;~ 						$Installer_Change = True
;~ 					Case $EN_KILLFOCUS ; 0x200
;~ 						If $Installer_Change And GUICtrlRead($Combo_Installer) <> '' Then
;~ 							$Installers[$Installer_Selected][5] = StringStripWS('"' & GUICtrlRead($Combo_Installer) & '" ' & GUICtrlRead($Input_Switches), 3)
;~ 							GUICtrlSetState($Button_Add_Installer, $GUI_ENABLE)
;~ 						EndIf
;~ 					Case $EN_UPDATE ; 0x400
;~ 						$Installer_Change = True
;~ 				EndSwitch
;~ 				$HelpTopic = 'InstallerDetails'
;~ 			Case $Edit_Installers
;~ 				$HelpTopic = 'ProcessOrder'
;~ 				;Post-processing Tab
;~ 			Case $Edit_Cmd
;~ 				$HelpTopic = 'ScriptBatchCmd'
;~ 			Case $Edit_Reg
;~ 				$HelpTopic = 'RegistryEntriesReg'
;~ 			Case $Edit_FileAssoc
;~ 				$HelpTopic = 'AppExts'
;~ 			Case $Edit_InstallFonts
;~ 				$HelpTopic = 'InstallFonts'
;~ 			Case $Edit_RegisterDLL
;~ 				$HelpTopic = 'RegisterServer'
;~ 			Case $Checkbox_MakeNonething, $Checkbox_NeverUpdateAppFile
;~ 				$HelpTopic = 'PostprocessingOptions'
;~ 				;Shortcuts Tab
;~ 			Case $Combo_Catalog
;~ 				$HelpTopic = 'MenuCatalog'
;~ 			Case $Combo_scName
;~ 				$HelpTopic = 'ShortcutsDefinitions'
;~ 				Switch $nNotifyCode
;~ 					Case 5 ;$EN_CHANGE ; 0x300
;~ 						$scName_Change = True
;~ 					Case 10 ;$EN_KILLFOCUS ; 0x200
;~ 						If $scName_Change Then
;~ 							;PopulateCombo_scName()
;~ 							Combo_scNameChange()
;~ 							$scName_Change = False
;~ 						EndIf
;~ 				EndSwitch
;~ 			Case $Checkbox_scAllUsers, $Checkbox_scStartMenu, $Checkbox_scRoot, $Checkbox_scPrograms, $Checkbox_scStartup, $Checkbox_scDesktop, $Checkbox_scQLaunch, $Checkbox_scSendTo, $Checkbox_scTaskbarPin, $Checkbox_scStartmenuPin
;~ 				$HelpTopic = 'Shortcutsto'
;~ 			Case $Checkbox_scNeverSort, $Checkbox_scAlwaysSort, $Checkbox_scKeepInFolder, $Checkbox_scKeepAll, $Checkbox_scRefreshExplorer, $Checkbox_NoMenuIcons, $Checkbox_LivePE
;~ 				$HelpTopic = 'ShortcutsOptions'
;~ 			Case $Edit_scKeep ;Label_scKeepClick
;~ 				$HelpTopic = 'ShortcutNamestoKeep'
;~ 			Case $Input_scTarget, $Input_scWorkDir, $Input_scIcon, $Input_scArgs, $Input_scExt, $Input_scDesc, $Input_scFlags, $Input_scCatalog
;~ 				$HelpTopic = 'ShortcutsDefinitions'
		Case Else
;~ 			MsgBox(262144, 'Debug line ~' & @ScriptLineNumber, 'Selection:' & @LF & '$nID' & @LF & @LF & 'Return:' & @LF & $nID)
	EndSwitch
EndFunc

Func Radio_FadertainerDefaultClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_FadertainerDefaultClick()' & @CRLF)
	GetFaderLocation()
EndFunc

Func Radio_FadertainerTLClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_FadertainerTLClick()' & @CRLF)
	GetFaderLocation()
EndFunc

Func Radio_FadertainerBLClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_FadertainerBLClick()' & @CRLF)
	GetFaderLocation()
EndFunc

Func Radio_FadertainerTRClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_FadertainerTRClick()' & @CRLF)
	GetFaderLocation()
EndFunc

Func Radio_FadertainerBRClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_FadertainerBRClick()' & @CRLF)
	GetFaderLocation()
EndFunc

Func Radio_FadertainerTCClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_FadertainerTCClick()' & @CRLF)
	GetFaderLocation()
EndFunc

Func Radio_FadertainerBCClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_FadertainerBCClick()' & @CRLF)
	GetFaderLocation()
EndFunc

Func Radio_FadertainerMCClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_FadertainerMCClick()' & @CRLF)
	GetFaderLocation()
EndFunc

Func Radio_FadertainerMLClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_FadertainerMLClick()' & @CRLF)
	GetFaderLocation()
EndFunc

Func Radio_FadertainerMRClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_FadertainerMRClick()' & @CRLF)
	GetFaderLocation()
EndFunc

Func Radio_ForceType2aClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_ForceType2aClick()' & @CRLF)
	$DualArchInstalls = 'a'
EndFunc

Func Radio_ForceType2bClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_ForceType2bClick()' & @CRLF)
	$DualArchInstalls = 'b'
EndFunc

Func Radio_ppDriveScanForwardsClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_ppDriveScanForwardsClick()' & @CRLF)
	$ppDrivesScanDirection = +1
EndFunc

Func Radio_ppDriveScanBackwardsClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_ppDriveScanBackwardsClick()' & @CRLF)
	$ppDrivesScanDirection = -1
EndFunc

Func Radio_ssCleanerAllShortcutsClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_ssCleanerAllShortcutsClick()' & @CRLF)
	GUICtrlSetState($Checkbox_ssCleanerDeleteDudAppPath, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_ssCleanerDeleteUninstalled, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_ssCleanerRemoved, $GUI_ENABLE)
EndFunc
Func Radio_ssCleanerDisabledClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_ssCleanerDisabledClick()' & @CRLF)
	GUICtrlSetState($Checkbox_ssCleanerDeleteDudAppPath, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_ssCleanerDeleteUninstalled, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_ssCleanerRemoved, $GUI_DISABLE)
EndFunc
Func Radio_ssCleanerNowStartmenuOnlyClick()
EndFunc
Func Radio_ssCleanerNowAllShortcutsClick()
EndFunc
Func Radio_ssCleanerStartmenuOnlyClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_ssCleanerStartmenuOnlyClick()' & @CRLF)
	GUICtrlSetState($Checkbox_ssCleanerDeleteDudAppPath, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_ssCleanerDeleteUninstalled, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_ssCleanerRemoved, $GUI_ENABLE)
EndFunc

Func RadioMuteClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|radioMuteClick()' & @CRLF)
	$SplashTips = False
	$BalloonTips = False
	GUICtrlSetState($Checkbox_AlwaysOnTop, $GUI_DISABLE)
	SetReportingFlags()
EndFunc

Func RadioShowClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|radioShowClick()' & @CRLF)
	$SplashTips = True
	$BalloonTips = True
	GUICtrlSetState($Checkbox_AlwaysOnTop, $GUI_ENABLE)
	SetReportingFlags()
EndFunc

Func RadioSplashOnlyClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|radioSplashOnlyClick()' & @CRLF)
	$SplashTips = True
	$BalloonTips = False
	GUICtrlSetState($Checkbox_AlwaysOnTop, $GUI_ENABLE)
	SetReportingFlags()
EndFunc

Func RadioTrayOnlyClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|radioTrayOnlyClick()' & @CRLF)
	$SplashTips = False
	$BalloonTips = True
	GUICtrlSetState($Checkbox_AlwaysOnTop, $GUI_DISABLE)
	SetReportingFlags()
EndFunc

Func ssControlPanelClose()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|ssControlPanelClose()' & @CRLF)
	SaveSettings()
	Cleanup()
	If $ForceMenu Then
		EndGame('Finished', '"' & $MenuStyles[$MenuStyle][1] & '" StartMenu Sorting Installed')
	ElseIf $ForceNoMenu Then
		EndGame('Finished', '"Standard" StartMenu Sorting Installed')
	Else
		If ProcessExists($Help_PID) Then ProcessClose($Help_PID)
		Exit
	EndIf
EndFunc

Func ssControlPanelMaximize()
EndFunc
Func ssControlPanelMinimize()
EndFunc
Func ssControlPanelRestore()
EndFunc

Func TabMenuChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|TabMenuChange()' & @CRLF)
	Switch GUICtrlRead($TabMenu)
		Case 0
			$HelpTopic = 'StartmenuOpt'
		Case 1
			$HelpTopic = 'PreferencesOpt'
		Case 2
			$HelpTopic = 'ShortcutsOpt'
		Case 3
			$HelpTopic = 'FadertainerOpt'
		Case 4
			$HelpTopic = 'ppDrivesOpt'
		Case 5
			$HelpTopic = 'ssCleanerOpt'
		Case 6
			$HelpTopic = 'Introduction'
	EndSwitch
EndFunc
#endregion

#region ;########################################## FUNCTIONS BELOW #############################################################

Func Adjust($What)
	Local $i, $FileList, $temp
	$FileList = _FileListToArray($What, '*.*', 2) ; Return folders only
	If @error = 0 Then
		For $i = 1 To $FileList[0]
			Adjust($What & '\' & $FileList[$i])
		Next
	EndIf
	$FileList = _FileListToArray($What, 'desktop.ini', 1) ; Return files only
	If @error = 0 Then
		For $i = 1 To $FileList[0]
			$temp = IniRead($What & '\' & $FileList[$i], '.ShellClassInfo', 'IconFile', '')
			If $temp <> '' Then IniWrite($What & '\' & $FileList[$i], '.ShellClassInfo', 'IconFile', StringReplace(StringReplace($temp, '\LastOS\', '\ssTek\'), 'LastOS_', 'LXP_'))
		Next
	EndIf
EndFunc

Func DeleteUninstalledGlobal()
	DeleteUninstalled(@ProgramFilesDir)
	If StringInStr(@CommonFilesDir, @ProgramFilesDir) <> 1 Then DeleteUninstalled(@CommonFilesDir); In case not a subdir
	If $OSArch64 And $ProgramFilesDir32 Then
		DeleteUninstalled(EnvGet('ProgramFiles(x86)'))
		If StringInStr(EnvGet('COMMONPROGRAMFILES(x86)'), EnvGet('ProgramFiles(x86)')) <> 1 Then DeleteUninstalled(EnvGet('COMMONPROGRAMFILES(x86)')); In case not a subdir
	EndIf
	DeleteUninstalled(@WindowsDir)
	If StringInStr(@SystemDir, @WindowsDir) <> 1 Then DeleteUninstalled(@SystemDir); In case not a subdir
	DeleteUninstalled($ppAppsDrive & '\ppApps')
	DeleteUninstalled($ppGamesDrive & '\ppGames')
EndFunc

Func GetFaderLocation()
	Select
		Case GUICtrlRead($Radio_FadertainerTL) = $GUI_CHECKED
			If $FaderLocation <> 'TL' Then $FaderLocation = 'TL'
		Case GUICtrlRead($Radio_FadertainerTC) = $GUI_CHECKED
			If $FaderLocation <> 'TC' Then $FaderLocation = 'TC'
		Case GUICtrlRead($Radio_FadertainerTR) = $GUI_CHECKED
			If $FaderLocation <> 'TR' Then $FaderLocation = 'TR'
		Case GUICtrlRead($Radio_FadertainerML) = $GUI_CHECKED
			If $FaderLocation <> 'ML' Then $FaderLocation = 'ML'
		Case GUICtrlRead($Radio_FadertainerMC) = $GUI_CHECKED
			If $FaderLocation <> 'MC' Then $FaderLocation = 'MC'
		Case GUICtrlRead($Radio_FadertainerMR) = $GUI_CHECKED
			If $FaderLocation <> 'MR' Then $FaderLocation = 'MR'
		Case GUICtrlRead($Radio_FadertainerBL) = $GUI_CHECKED
			If $FaderLocation <> 'BL' Then $FaderLocation = 'BL'
		Case GUICtrlRead($Radio_FadertainerBC) = $GUI_CHECKED
			If $FaderLocation <> 'BC' Then $FaderLocation = 'BC'
		Case GUICtrlRead($Radio_FadertainerBR) = $GUI_CHECKED
			If $FaderLocation <> 'BR' Then $FaderLocation = 'BR'
		Case GUICtrlRead($Radio_FadertainerDefault) = $GUI_CHECKED
			If $FaderLocation <> '' Then $FaderLocation = ''
	EndSelect
EndFunc

Func GetParameterInfo()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|GetParameterInfo()' & @CRLF)
	Local $n, $File, $Found, $i, $j, $k, $test, $kList, $jList, $oldpath, $newpath, $value, $key
	If GetParameter('Help') Or GetParameter('?') Or GetParameter('About') Then EndGame('Help requested', 'See displayed', True)
	GetReportingMode($ssConfigINI)
	If GetParameter('SortDefaults') Then
		$KeepStartMenuDefaults = False
	EndIf
	If GetParameter('ppDriveRegen') Or GetParameter('ppDrivesRegen') Then
		$ppDrivesRunRegen = True
	EndIf
	$n = GetParameter('ppDrivesScan', '=')
	If $n Then
		FileDelete(@WindowsDir & '\ppAppDrive.ini')
		FileDelete(@WindowsDir & '\ppGameDrive.ini')
		Switch $n
			Case 'up', 'forwards', '+', 'ascend', 'ascending', '1'
				$ppDrivesScanDirection = 1
			Case Else
				$ppDrivesScanDirection = -1
		EndSwitch
	Else
		If GetParameter('ppDrivesScan') Then
			FileDelete(@WindowsDir & '\ppAppDrive.ini')
			FileDelete(@WindowsDir & '\ppGameDrive.ini')
		EndIf
	EndIf
	$ppAppsDriveMove = GetParameter('ppAppsDriveMove', '=')
	$ppGamesDriveMove = GetParameter('ppGamesDriveMove', '=')
	$n = GetParameter('ppAppsDrive', '=')
	If $n Then
		$File = FileOpen(@WindowsDir & '\ppAppDrive.ini', 2)
		FileWriteLine($File, $n)
		FileClose($File)
	EndIf
	If GetParameter('Type2b') Then $DualArchInstalls = 'b'
	If GetParameter('Type2a') Then $DualArchInstalls = 'a'
	$n = GetParameter('Type2', '=')
	If $n Then $DualArchInstalls = $n
	$n = GetParameter('ppGamesDrive', '=')
	If $n Then
		$File = FileOpen(@WindowsDir & '\ppGameDrive.ini', 2)
		FileWriteLine($File, $n)
		FileClose($File)
	EndIf
	$MenuInstallOnly = GetParameter('MenuInstallOnly')
	GetScMode($ssConfigINI)
	If GetParameter('resort') Then
		SetSortMethod()
		If $MenuStyle = 0 Then
			$ForceNoMenu = True
		Else
			$ForceMenu = $MenuStyle
		EndIf
	Else
		$ForceNoMenu = GetParameter('NoMenu') Or GetParameter('NoSetupSMenu') Or GetParameter('Standard')
		For $i = 1 To $MenuStyles[0][0]
			;MsgBox(4096, '', 'Key: ' & $MenuStyles[$i][0] & @CRLF & 'Value: ' & $MenuStyles[$i][1])
			If GetParameter($MenuStyles[$i][1]) Then
				$ForceMenu = $MenuStyles[$i][0]
				ExitLoop
			EndIf
		Next
		Select
			Case GetParameter('LastXP') Or GetParameter('LastOS') Or GetParameter('ssTek')
				$ForceMenu = $MenuStyles[1][0]
			Case GetParameter('Kazz')
				$ForceMenu = $MenuStyles[2][0]
		EndSelect
	EndIf
	$n = GetParameter('path', '=')
	If $n Then
		ModPath($n)
		If Not $ssClean_enforced Then $ssCleaner = 0
	EndIf
	$n = GetParameter('ssUninstall', '=')
	If $n <> '' Then
		Local $set = '', $refresh = False, $parmlist = StringSplit($n, ',')
		For $i = 1 To $parmlist[0]
			Switch $parmlist[$i]
				Case 'on', 'yes', '1', 'true', 'always'
					$set = 'on'
				Case 'off', 'no', '0', 'false', 'never'
					$set = 'off'
			EndSwitch
		Next
		If $set = '' Then
			$n = $ssUninstall
		Else
			$n = ($set = 'on')
		EndIf
		For $i = 1 To $parmlist[0]
			Switch $parmlist[$i]
				Case 'refresh', 'force'
					$refresh = True
				Case 'recover', 'fix'
					$n = False
					$refresh = True
					$ssUninstallRecover = True
			EndSwitch
		Next
		If $refresh Or $n <> $ssUninstall Then
			$ssUninstall = $n
			NeoIniWrite($ssConfigINI, 'Options', 'ssUninstall', $ssUninstall)
			$ssUninstallChanged = True
		Else
			If Not $ssClean_enforced Then $ssCleaner = 0
		EndIf
	EndIf
	$n = GetParameter('uninstall', '=')
	If $n Then
		_AppReset()
		$App_File = _AppRead(StringReplace(ConvertFromVars($n), '"', ''))
		$ssCleaner = 0
		If $App_File <> '' And IsArray($App_Uninstall) And $App_Uninstall[0][0] > 0 Then
			;_ArrayDisplay($App_Uninstall, @ScriptLineNumber)
			;If $TempDir = '' Then $TempDir = GenerateTempFolder()
			For $i = 1 To $App_Uninstall[0][0]
				$key = GetUninstallKey($App_Uninstall[$i][0], $value)
				If $key <> '' And $value <> '' And RegRead($key, 'ssUninstallRecovery') <> '' Then
					$App_Uninstall[$i][4] = RegRead($key, 'ssUninstallRecovery')
					$n = StringStripWS(ConvertFromVars(ConvertToVars($App_Uninstall[$i][4])), 3)
					If StringInStr($n, '"') = 0 And (StringInStr($n, '.exe') Or StringInStr($n, '.msi') Or StringInStr($n, '.com') Or StringInStr($n, '.bat') Or StringInStr($n, '.cmd')) Then
						$n = '"' & $n
						$n = StringReplace($n, '.exe', '.exe"')
						$n = StringReplace($n, '.msi', '.msi"')
						$n = StringReplace($n, '.com', '.com"')
						$n = StringReplace($n, '.bat', '.bat"')
						$n = StringReplace($n, '.cmd', '.cmd"')
					EndIf
					If IsAssocFile($n, '.msi') Then $n = 'msiexec.exe /i ' & $n
					If FileGetShortName(ConvertFromVars(GetFolderPath($App_File))) = FileGetShortName(ConvertFromVars(GetFolderPath(@ScriptFullPath))) Then ;
						;Prep to uninstall SetupS itself...
						If $n <> '' Then
							Local $BootUnstrap = _TempFile(@TempDir, '~', '.cmd')
							NeoFileCopy(@ScriptFullPath, @TempDir)
							$File = FileOpen($BootUnstrap, 10)
							If $File <> -1 Then
								FileWrite($File, $n & @CRLF)
								FileWrite($File, 'rd /s /q "' & ConvertFromVars(GetFolderPath($App_File)) & '" >nul:')
								FileWrite($File, @TempDir & '\' & @ScriptName & ' -ssClean=StartMenuOnly,NotDudInstallPaths,NoDeepScan' & @CRLF)
								FileWrite($File, 'del /F /Q "' & @ScriptName & '" >nul:')
								FileClose($File)
								Cleanup()
								FileChangeDir(@TempDir)
								Run($BootUnstrap, @TempDir, @SW_HIDE)
								Exit
							EndIf
						EndIf
					EndIf
					$kList = ProcessList()
					RunWait($n, @ScriptDir, @SW_HIDE)
					$jList = ProcessList()
					For $j = 1 To $jList[0][0]
						$Found = True
						For $k = 1 To $kList[0][0]
							If $jList[$j][0] = $kList[$k][0] And $jList[$j][1] = $kList[$k][1] Then
								$Found = False
								ExitLoop
							EndIf
						Next
						If $Found Then
							$test = $jList[$j][1]
							ExitLoop
						EndIf
					Next
					If $Found Then
						While ProcessExists($test)
							Sleep(250)
						WEnd
					EndIf
					$ssCleanerDeleteDudAppPath = True
					If $App_scCount > 0 Then ;ssCleaner Switches
						$ssCleaner = 1
						$ssCleanerDeleteUninstalled = False
					Else
						$ssCleaner = 0
						$ssCleanerDeleteUninstalled = True
					EndIf
				EndIf
			Next
			If $ssCleaner = 1 Then
				ssCleaner(@StartMenuCommonDir) ; All Users Start Menu
				ssCleaner(@StartMenuDir) ; Current User Start Menu
				$ssCleaner = 0
			EndIf
			If $ssCleanerDeleteUninstalled Then
				DeleteUninstalled(GetFolderPath($App_File))
				$ssCleanerDeleteUninstalled = False
			EndIf
		EndIf
	EndIf
EndFunc

Func Main()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Main()' & @CRLF)
	If $AutoUpdate Then UpdateMe('update.ini', @ScriptDir, $UseGUI)
	If $SetupS <> '' Then
		GetParameterInfo()
		GetppDrives()
		SetSortMethod()
		If $ForceNoMenu Or $ForceMenu Then
			InstallMenu($MenuStyle)
			If Not $KeepStartMenuDefaults Then SetDefaultShortcuts()
		EndIf
		If $ppAppsDriveMove Or $ppGamesDriveMove Or $ForceNoMenu Or $ForceMenu Or $ppDrivesRunRegen Then
			RunShortcutsGenerator($ForceNoMenu Or $ForceMenu)
			$App_RefreshExplorer = True
		ElseIf $CleanStartMenuDir Then
			$ssCleaner = 1
		EndIf
		If $ssUninstallChanged Then
			$ssCleanerDeleteDudAppPath = True
			$ssCleaner = 1
			$ssCleanerDeleteUninstalled = True
		EndIf
		If $ssCleaner > 0 Then
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
			If $ssCleanerDeleteUninstalled Then DeleteUninstalledGlobal()
		EndIf
	EndIf
	If $KeepStartMenuFolders Then CopyMenu($MenuStyle)
	ssControlPanelClose()
EndFunc

Func ModPath($n)
	Local $i, $oldpath = StringSplit(RegRead("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", "Path"), ";"), $newpath = ''
	; tokenize path, look for existing entry
	For $i = 1 To $oldpath[0]
		If @ScriptDir <> $oldpath[$i] Then $newpath = $newpath & ';' & $oldpath[$i]
	Next
	If StringLeft($newpath, 1) = ';' Then $newpath = StringMid($newpath, 2)
	If $n = 'add' Then $newpath = $newpath & ';' & @ScriptDir
	RegWrite('HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', 'REG_EXPAND_SZ', $newpath)
	RegWrite('HKCU\Environment', 'Path', 'REG_EXPAND_SZ', $newpath)
	;EnvUpdate()
	_EnvUpdate('PATH')
EndFunc

Func RemoveDefaultS($where, $What)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|RemoveDefaultS(): $where = ' & $where & ' : $what = ' & $What & @CRLF)
	Local $i, $FileList, $Path, $details, $SectionName, $var, $Removed = False
	If FileExists($where) Then
		$FileList = _FileListToArray($where, '*.*', 2) ; Return folders only
		If @error = 0 Then
			For $i = 1 To $FileList[0]
				$Removed = RemoveDefaultS($where & '\' & $FileList[$i], $What)
			Next
		EndIf
		$FileList = _FileListToArray($where, '*.lnk', 1) ; Return files only
		If @error = 0 Then
			For $i = 1 To $FileList[0]
				If ($FileList[$i] = $What) Then
					FileRecycle($where & '\' & $FileList[$i])
;~ 					If $FileList[$i] <> '' Then
;~ 						If $OS_Linux Then ; :o
;~ 							FileDelete($LinuxHome & '\.config\menus\applications-merged\wine-Programs-' & StringReplace(StringReplace(StringReplace($where, @UserProfileDir & '\Start Menu\Programs\', '', 0) & '\' & $FileList[$i], '\', '-', 0), '.lnk', '', 0) & '.menu')
;~ 						EndIf
;~ 					EndIf
					$Removed = True
				EndIf
			Next
		EndIf
	EndIf
	Return $Removed
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

Func RunShortcutsGenerator($SetMenu = False)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|RunShortcutsGenerator()' & @CRLF)
	Local $i
	If Not $MenuInstallOnly Then
		If @Compiled Then
			If $OSArch64 Then $i = FileGetShortName(FindMe('ssRegenerator_x64.exe'))
			If $i = '' Then $i = FileGetShortName(FindMe('ssRegenerator.exe'))
		Else
			$i = 'AutoIt3.exe /ErrorStdOut /AutoIt3ExecuteScript ' & FileGetShortName(FindMe('ssRegenerator.au3'))
		EndIf
		If $i <> '' Then
			If Not $SetMenu Then
				If $ppDrivesRunRegen Then
;~ 					$i = $i & ' -ppGames'
					$i = $i & ' -ppApps' & ' -ppGames'
				ElseIf $ppAppsDriveMove Or $ppGamesDriveMove Then
					If $ppAppsDriveMove Then $i = $i & ' -ppApps -ppAppsDrive=' & $ppAppsDriveMove
					If $ppGamesDriveMove Then $i = $i & ' -ppGames -ppGamesDrive=' & $ppGamesDriveMove
				EndIf
			Else
				If $ppAppsDriveMove Then $i = $i & ' -ppAppsDrive=' & $ppAppsDriveMove
				If $ppGamesDriveMove Then $i = $i & ' -ppGamesDrive=' & $ppGamesDriveMove
			EndIf
			Opt('TrayIconHide', 1) ;Hide tray icon
			RunWait($i, @ScriptDir)
			If $BalloonTips Then Opt('TrayIconHide', 0) ;Show tray icon
		EndIf
	EndIf
EndFunc

Func SaveSettings()
	If FileExists($ssConfigINI) And $UseGUI Then
		NeoIniWrite($ssConfigINI, 'Reporting Mode', 'Mute', $Mute)
		NeoIniWrite($ssConfigINI, 'Reporting Mode', 'TrayOnly', $TrayOnly)
		NeoIniWrite($ssConfigINI, 'Reporting Mode', 'SplashOnly', $SplashOnly)
		NeoIniWrite($ssConfigINI, 'Reporting Mode', 'SplashOnTop', $SplashOnTop)
		NeoIniWrite($ssConfigINI, 'Reporting Mode', 'Debug', $Debug)
		NeoIniWrite($ssConfigINI, 'Reporting Mode', 'Log', $Log)
		NeoIniWrite($ssConfigINI, 'Process Without Shortcuts', 'ssApps', $ssAppsShortcutsSkip)
		NeoIniWrite($ssConfigINI, 'Process Without Shortcuts', 'ppApps', $ppAppsShortcutsSkip)
		NeoIniWrite($ssConfigINI, 'Process Without Shortcuts', 'ppGames', $ppGamesShortcutsSkip)
		NeoIniWrite($ssConfigINI, 'Remove Pre-existing', 'Desktop', $remDesktop)
		NeoIniWrite($ssConfigINI, 'Remove Pre-existing', 'QuickLaunch', $remQuickLaunch)
		NeoIniWrite($ssConfigINI, 'Remove Pre-existing', 'ProgramsRoot', $remProgramsRoot)
		NeoIniWrite($ssConfigINI, 'Remove Pre-existing', 'Sendto', $remSendto)
		NeoIniWrite($ssConfigINI, 'Remove Pre-existing', 'Startup', $remStartup)
		NeoIniWrite($ssConfigINI, 'Remove Pre-existing', 'StartmenuRoot', $remStartmenuRoot)
		NeoIniWrite($ssConfigINI, 'Remove Pre-existing', 'StartmenuPin', $remStartmenuPin)
		NeoIniWrite($ssConfigINI, 'Remove Pre-existing', 'TaskbarPin', $remTaskbarPin)
		Select
			Case BitAND(GUICtrlRead($Radio_ssCleanerDisabled), $GUI_CHECKED) = $GUI_CHECKED
				$ssCleaner = 0
				NeoIniWrite($ssConfigINI, 'ssCleaning', 'DudShortcuts', 'Never')
			Case BitAND(GUICtrlRead($Radio_ssCleanerStartmenuOnly), $GUI_CHECKED) = $GUI_CHECKED
				$ssCleaner = 1
				NeoIniWrite($ssConfigINI, 'ssCleaning', 'DudShortcuts', 'StartmenuOnly')
			Case BitAND(GUICtrlRead($Radio_ssCleanerAllShortcuts), $GUI_CHECKED) = $GUI_CHECKED
				$ssCleaner = 2
				NeoIniWrite($ssConfigINI, 'ssCleaning', 'DudShortcuts', 'AllShortcuts')
		EndSelect
		NeoIniWrite($ssConfigINI, 'ssCleaning', 'RemovedMenuItem', $ssCleanRemovedMenuItem)
		NeoIniWrite($ssConfigINI, 'ssCleaning', 'DudAppPaths', $ssCleanerDeleteDudAppPath)
		NeoIniWrite($ssConfigINI, 'ssCleaning', 'Uninstalled', $ssCleanerDeleteUninstalled)
		If GUICtrlRead($Input_FaderSpeed) <> $FaderSpeed Then $FaderSpeed = GUICtrlRead($Input_FaderSpeed)
		GetFaderLocation()
		NeoIniWrite($ssConfigINI, 'Fadertainer', 'Activate', $Fadertainer)
		NeoIniWrite($ssConfigINI, 'Fadertainer', 'Speed', $FaderSpeed)
		NeoIniWrite($ssConfigINI, 'Fadertainer', 'Module', $FaderModule)
		NeoIniWrite($ssConfigINI, 'Fadertainer', 'AlwaysOnTop', $FaderOnTop)
		NeoIniWrite($ssConfigINI, 'Fadertainer', 'Location', $FaderLocation)
		NeoIniWrite($ssConfigINI, 'Fadertainer', 'DuringInstallsOnly', $FaderInstallsOnly)
		NeoIniWrite($ssConfigINI, 'Regenerator', 'AllDrives', $RegenAllDrives)
		NeoIniWrite($ssConfigINI, 'Options', 'SafeInstall', $SafeInstall)
		NeoIniWrite($ssConfigINI, 'Options', 'SkipOSArch', $SkipOSArch)
		NeoIniWrite($ssConfigINI, 'Options', 'AutoUpdate', $AutoUpdate)
		NeoIniWrite($ssConfigINI, 'Options', 'ssUninstall', $ssUninstall)
		If GUICtrlRead($Input_RepoLink) <> $RepoLink & '/' & $RepoFolder Then
			$RepoLink = GetFolderPath(GUICtrlRead($Input_RepoLink))
			$RepoFolder = GetFilename(GUICtrlRead($Input_RepoLink))
		EndIf
		If GUICtrlRead($Input_BackupRepoLink) <> $BackupRepoLink & '/' & $RepoFolder Then
			$BackupRepoLink = GetFolderPath(GUICtrlRead($Input_BackupRepoLink))
			$RepoFolder = GetFilename(GUICtrlRead($Input_BackupRepoLink))
		EndIf
		NeoIniWrite($ssUpdateINI, 'Repo', 'Primary', $RepoLink)
		NeoIniWrite($ssUpdateINI, 'Repo', 'Backup', $BackupRepoLink)
		NeoIniWrite($ssUpdateINI, 'Repo', 'Folder', $RepoFolder)
		If $ppDrivesScanDirection = 1 Then
			NeoIniWrite($ssConfigINI, 'Options', 'ppDrivesScanDirection', 'Forwards')
		Else
			NeoIniWrite($ssConfigINI, 'Options', 'ppDrivesScanDirection', 'Backwards')
		EndIf
		Switch $DualArchInstalls
			Case 'b', 'Type 2b', 'Type2b', '2b'
				NeoIniWrite($ssConfigINI, 'Options', 'DualArchInstalls', 'Type 2b')
			Case 'a', 'Type 2a', 'Type2a', '2a'
				NeoIniWrite($ssConfigINI, 'Options', 'DualArchInstalls', 'Type 2a')
			Case Else
				NeoIniWrite($ssConfigINI, 'Options', 'DualArchInstalls', 'Type 2b')
		EndSwitch
		NeoIniWrite($ssConfigINI, 'Options', 'KeepStartMenuFolders', $KeepStartMenuFolders)
		NeoIniWrite($ssConfigINI, 'Options', 'KeepStartMenuDefaults', $KeepStartMenuDefaults)
	EndIf
EndFunc

Func SetDefaultShortcuts()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|SetDefaultShortcuts()' & @CRLF)
	Local $i, $j, $Found, $details[1], $CleanStartMenuCommonDir = False
	Local $MenuDefaultsINI = FindMe('MenuDefaults.ini') ;$ToolsPath & '\Menus\MenuDefaults.ini'
	If FileExists($MenuDefaultsINI) Then
		Local $MenuDefaultsList = IniReadSectionNames($MenuDefaultsINI)
		If IsArray($MenuDefaultsList) Then
			;_ArrayDisplay($MenuDefaultsINI, '$MenuDefaultsINI')
			ReDim $details[11 + 1]
			For $i = 1 To $MenuDefaultsList[0]
				$details[0] = $MenuDefaultsList[$i]
				$details[1] = ConvertFromVars(IniRead($MenuDefaultsINI, $details[0], 'Target', ''))
				$details[2] = ConvertFromVars(IniRead($MenuDefaultsINI, $details[0], 'Arguments', ''))
				$details[3] = NoBackslash(ConvertFromVars(IniRead($MenuDefaultsINI, $details[0], 'WorkingDir', '')))
				$details[4] = ConvertFromVars(IniRead($MenuDefaultsINI, $details[0], 'Icon', ''))
				$details[5] = IniRead($MenuDefaultsINI, $details[0], 'Index', '')
				$details[6] = IniRead($MenuDefaultsINI, $details[0], 'State', '')
				$details[7] = IniRead($MenuDefaultsINI, $details[0], 'Description', '')
				$details[8] = NoBackslash(ConvertFromVars(IniRead($MenuDefaultsINI, $details[0], 'Default', '')))
				$details[9] = IniRead($MenuDefaultsINI, $details[0], 'Catalog', '')
				$details[10] = ConvertFromVars(IniRead($MenuDefaultsINI, $details[0], 'Shortcut', ''))
				$details[11] = IniRead($MenuDefaultsINI, $details[0], 'Hotkey', '')
				$Found = True
				Do
					Select
						Case StripOS($details[0], 'WIN_7')
						Case StripOS($details[0], 'WIN_XP')
						Case StripOS($details[0], 'WIN_2003')
						Case StripOS($details[0], 'WIN_2000')
						Case StripOS($details[0], 'WIN_VISTA')
						Case StripOS($details[0], 'WIN_XPe')
						Case StripOS($details[0], 'WIN_2008')
						Case StripOS($details[0], 'WIN_2008R2')
						Case StripOS($details[0], 'WIN_NONE')
						Case StripOS($details[0], 'OSARCH_X64')
						Case StripOS($details[0], 'OSARCH_X86')
						Case StripOS($details[0], 'WIN_8')
						Case StripOS($details[0], 'WIN_10')
						Case Else
							$Found = False
					EndSelect
				Until Not $Found
				If ($details[0] <> $MenuDefaultsList[$i]) Then ; don't create if:
					$Found = False
					Select
						Case Not (StringInStr($MenuDefaultsList[$i], '.' & $OSVersion) Or StringInStr($MenuDefaultsList[$i], '.OSARCH_x' & StringRight(@OSArch, 2)))
						Case StringInStr($MenuDefaultsList[$i], '.WIN_None')
						Case Else
							$Found = True
					EndSelect
					If Not $Found Then
						$details[8] = ''
						$details[9] = ''
					EndIf
				EndIf
				If $details[10] = '' Then $details[10] = $details[0]
				If (StringRight($details[10], 4) <> '.lnk') Then $details[10] = $details[10] & '.lnk'
				$SnM = StringSplit($details[9], '|')
				If $SnM[1] = '' Then $SnM[0] = 0
				$smDestination = $SnM
				For $j = 1 To $SnM[0]
					$SnM[$j] = IniRead(GetMenuDefs($MenuStyle), 'Catalog', $SnM[$j], '')
					$smDestination[$j] = NoBackslash(ConvertFromVars(@ProgramsDir & '\' & $SnM[$j]))
					;$smDestination[$j] = NoBackslash(ConvertFromVars(@ProgramsCommonDir & '\' & $SnM[$j]))
				Next
				If $details[8] <> '' Then
					If StringInStr($details[8], 'Administrative Tools') > 0 Then
						$j = 'Copying'
					Else
						$j = 'Moving'
						If RemoveDefaultS(@StartMenuCommonDir, $details[10]) Then $CleanStartMenuCommonDir = True
						If ($details[10] <> $details[0]) Then
							If RemoveDefaultS(@StartMenuCommonDir, $details[0]) Then $CleanStartMenuCommonDir = True
						EndIf
					EndIf
					If $SplashTips Then SplashThis($j, '[' & $i & ' of ' & $MenuDefaultsList[0] & ']... ' & StringLeft($details[10], StringLen($details[10]) - 4))
					If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & '[' & $i & ' of ' & $MenuDefaultsList[0] & ']... ' & $j & ' ' & StringLeft($details[10], StringLen($details[10]) - 4) & @CRLF)
					If RemoveDefaultS(@StartMenuDir, $details[10]) Then $CleanStartMenuDir = True
					If ($details[10] <> $details[0]) Then
						If RemoveDefaultS(@StartMenuDir, $details[0]) Then $CleanStartMenuDir = True
					EndIf
				EndIf
				If $details[4] = '' Or FileExists($details[4]) Then
					If $MenuStyle = 0 Then
						If $details[8] <> '' Then
							If StringInStr($details[8], 'Administrative Tools') = 0 Or Not FileExists($details[8] & '\' & $details[10]) Then
								DirCreate($details[8])
								FileCreateShortcut($details[1], $details[8] & '\' & $details[10], $details[3], $details[2], $details[7], $details[4], '', $details[5], $details[6])
							EndIf
						EndIf
					Else
						If FileExists($details[1]) Then
							For $j = 1 To $smDestination[0]
								DirCreate($smDestination[$j])
								FileCreateShortcut($details[1], $smDestination[$j] & '\' & $details[10], $details[3], $details[2], $details[7], $details[4], '', $details[5], $details[6])
							Next
							StartMenuIcons($SnM)
						EndIf
					EndIf
				EndIf
			Next
		EndIf
	EndIf
	If $MenuStyle = 0 Then ;Show AdminTools
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'StartMenuAdminTools', 'REG_SZ', 'YES')
		If FileExists(@ProgramsDir & '\Administrative Tools') Then RunWait($CLIprefix & 'attrib . +s -h', @ProgramsDir & '\Administrative Tools', @SW_HIDE)
		If FileExists(@ProgramsCommonDir & '\Administrative Tools') Then RunWait($CLIprefix & 'attrib . +s -h', @ProgramsCommonDir & '\Administrative Tools', @SW_HIDE)
	Else ;Hide AdminTools
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'StartMenuAdminTools', 'REG_SZ', 'NO')
		If FileExists(@ProgramsDir & '\Administrative Tools') Then RunWait($CLIprefix & 'attrib . +s +h', @ProgramsDir & '\Administrative Tools', @SW_HIDE)
		If FileExists(@ProgramsCommonDir & '\Administrative Tools') Then RunWait($CLIprefix & 'attrib . +s +h', @ProgramsCommonDir & '\Administrative Tools', @SW_HIDE)
	EndIf
	If $BalloonTips Then _TrayTip('Installing', '', 300, 16)
	If $SplashTips Then SplashOff()
	If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Installing' & @CRLF)
EndFunc

Func SetFadertainer()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|SetFadertainer()' & @CRLF)
	GUICtrlSetData($Input_FaderSpeed, $FaderSpeed)
	If $FaderOnTop Then
		GUICtrlSetState($Checkbox_FaderAlwaysOnTop, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_FaderAlwaysOnTop, $GUI_UNCHECKED)
	EndIf
	If $FaderInstallsOnly Then
		GUICtrlSetState($Checkbox_FaderDuringInstallsOnly, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_FaderDuringInstallsOnly, $GUI_UNCHECKED)
	EndIf
	Switch $FaderLocation
		Case 'TL'
			GUICtrlSetState($Radio_FadertainerTL, $GUI_CHECKED)
		Case 'TC'
			GUICtrlSetState($Radio_FadertainerTC, $GUI_CHECKED)
		Case 'TR'
			GUICtrlSetState($Radio_FadertainerTR, $GUI_CHECKED)
		Case 'ML'
			GUICtrlSetState($Radio_FadertainerML, $GUI_CHECKED)
		Case 'MC'
			GUICtrlSetState($Radio_FadertainerMC, $GUI_CHECKED)
		Case 'MR'
			GUICtrlSetState($Radio_FadertainerMR, $GUI_CHECKED)
		Case 'BL'
			GUICtrlSetState($Radio_FadertainerBL, $GUI_CHECKED)
		Case 'BC'
			GUICtrlSetState($Radio_FadertainerBC, $GUI_CHECKED)
		Case 'BR'
			GUICtrlSetState($Radio_FadertainerBR, $GUI_CHECKED)
		Case Else
			GUICtrlSetState($Radio_FadertainerDefault, $GUI_CHECKED)
	EndSwitch
	If $Fadertainer Then
		GUICtrlSetState($Checkbox_Fadertainer, $GUI_CHECKED)
		GUICtrlSetState($Checkbox_FaderAlwaysOnTop, $GUI_ENABLE)
		GUICtrlSetState($Checkbox_FaderDuringInstallsOnly, $GUI_ENABLE)
		GUICtrlSetState($Input_FaderSpeed, $GUI_ENABLE)
		GUICtrlSetState($Label_Faderspeed, $GUI_ENABLE)
		GUICtrlSetState($Label_FaderSec, $GUI_ENABLE)
		GUICtrlSetState($Group_Fadertainer, $GUI_ENABLE)
		GUICtrlSetState($Radio_FadertainerTL, $GUI_ENABLE)
		GUICtrlSetState($Radio_FadertainerTC, $GUI_ENABLE)
		GUICtrlSetState($Radio_FadertainerTR, $GUI_ENABLE)
		GUICtrlSetState($Radio_FadertainerML, $GUI_ENABLE)
		GUICtrlSetState($Radio_FadertainerMC, $GUI_ENABLE)
		GUICtrlSetState($Radio_FadertainerMR, $GUI_ENABLE)
		GUICtrlSetState($Radio_FadertainerBL, $GUI_ENABLE)
		GUICtrlSetState($Radio_FadertainerBC, $GUI_ENABLE)
		GUICtrlSetState($Radio_FadertainerBR, $GUI_ENABLE)
		GUICtrlSetState($Radio_FadertainerDefault, $GUI_ENABLE)
		GUICtrlSetState($Combo_FaderModule, $GUI_ENABLE)
		GUICtrlSetState($Label_FaderModule, $GUI_ENABLE)
	Else
		GUICtrlSetState($Checkbox_Fadertainer, $GUI_UNCHECKED)
		GUICtrlSetState($Checkbox_FaderAlwaysOnTop, $GUI_DISABLE)
		GUICtrlSetState($Checkbox_FaderDuringInstallsOnly, $GUI_DISABLE)
		GUICtrlSetState($Input_FaderSpeed, $GUI_DISABLE)
		GUICtrlSetState($Label_Faderspeed, $GUI_DISABLE)
		GUICtrlSetState($Label_FaderSec, $GUI_DISABLE)
		GUICtrlSetState($Group_Fadertainer, $GUI_DISABLE)
		GUICtrlSetState($Radio_FadertainerTL, $GUI_DISABLE)
		GUICtrlSetState($Radio_FadertainerTC, $GUI_DISABLE)
		GUICtrlSetState($Radio_FadertainerTR, $GUI_DISABLE)
		GUICtrlSetState($Radio_FadertainerML, $GUI_DISABLE)
		GUICtrlSetState($Radio_FadertainerMC, $GUI_DISABLE)
		GUICtrlSetState($Radio_FadertainerMR, $GUI_DISABLE)
		GUICtrlSetState($Radio_FadertainerBL, $GUI_DISABLE)
		GUICtrlSetState($Radio_FadertainerBC, $GUI_DISABLE)
		GUICtrlSetState($Radio_FadertainerBR, $GUI_DISABLE)
		GUICtrlSetState($Radio_FadertainerDefault, $GUI_DISABLE)
		GUICtrlSetState($Combo_FaderModule, $GUI_DISABLE)
		GUICtrlSetState($Label_FaderModule, $GUI_DISABLE)
	EndIf
EndFunc

Func SetSortMethod()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|SetSortMethod()' & @CRLF)
	If $ForceNoMenu Then $MenuStyle = SetMenuStyle(0)
	If $ForceMenu Then $MenuStyle = SetMenuStyle($ForceMenu)
	If $MenuStyle > 0 Then
		$MenuDefinitionINI = $ToolsPath & '\Menus\' & $MenuStyles[$MenuStyle][1] & 'Menu\Definitions.ini'
	Else
		$MenuDefinitionINI = ''
	EndIf
EndFunc

Func StripOS(ByRef $What, $OS)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|StripOS(): $what = ' & $What & ' : $OS = ' & $OS & @CRLF)
	$What = StringReplace($What, '.' & $OS, '')
	Local $TotalReplacements = @extended
	Return @extended > 0
EndFunc
#endregion

