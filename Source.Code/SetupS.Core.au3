#NoTrayIcon
#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Run_Tidy=y
#endregion
#include-once
#cs ##################################################################################

	SetupS Project Core (Common Declarations & Functions) v#CoreVersion#
	Copyright � #cYear#, #cHolder#
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
	Allows for easier updating & maintenance, etc.

#ce ##################################################################################
Opt('MustDeclareVars', 1)
#include <String.au3>
#include <Array.au3>
#include <File.au3>
#include <Date.au3>
#include <WinAPI.au3>
#include <GUIConstantsEx.au3>
#include <Crypt.au3>
#include <UDFs\APIConstants.au3>
#include <UDFs\StringSize.au3>
#include <Constants.au3>
Opt("WinTitleMatchMode", 2) ;1=start, 2=subStr, 3=exact, 4=advanced, -1 to -4=Nocas

Global $Debug = False, $Log = False, $ErrorProtection = ErrorProtection('off'), $RepoLink, $BackupRepoLink, $RepoFolder
Global $ThisAppFilename = StringReplace(StringLeft(@ScriptName, StringInStr(@ScriptName, '.', -1, -1) - 1), '_x64', '')
Global $ThisAppTitle, $ThisAppVersion, $ThisAppBuildType, $ThisAppPath, $scFolder = 'SetupS.Shortcuts', $maxFaderSize = 256
Global $AutoUpdate = False, $AutoUpdateReturn = 0, $SafeInstall = False, $SkipOSArch = True
Global $Fadertainer = False, $FaderSpeed = '.5', $FaderLocation, $FaderModule, $FaderOnTop = True, $FaderInstallsOnly = True
Global $AllDrivesList = _DriveGetDrive('ALL'), $CDDrivesList = DriveGetDrive('CDROM'), $RegenAllDrives = False
Global $SrcPath = '', $CDDrive = '', $ppDriveOld = False, $ppAppsDrive = '', $SetupS, $SetupSFolder, $NoUpdate = False
Global $Mute = False, $TrayOnly = False, $SplashOnly = False, $SplashTips = True, $BalloonTips = True, $Verbose, $SplashOnTop ;Reporting
Global $ssAppsShortcutsSkip = False, $ppAppsShortcutsSkip = False, $ppGamesShortcutsSkip = False, $ppGamesDrive = ''
Global $ppAppsDriveMove = False, $ppGamesDriveMove = False, $MenuStylesINI, $MenuStyles[1][1], $App_Changed = False
Global $smDestination[1], $KeepMe = '', $SnM[1], $WholeCatalog[1][1], $MenuStyle = 0
Global $MSITStore = 'mk:@MSITStore:', $HelpFile, $HelpTopic, $Help_PID = False, $SplashControlID = 0, $AllCategories[1][1]
Global $HomeDrv = @HomeDrive, $SystemDrive = StringLeft(@WindowsDir, 2), $ppDrivesScanDirection = -1
Global $EnableBalloonTips = RegRead('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips')
Global $MenuDefinitionINI, $ToolsPath, $ToolsDrive, $ToolsDir, $7zFName, $7zExt, $Tools, $Tools_OSArch;, $7zEXE
Global $CLIprefix = @ComSpec & ' /c ', $CLIparameters = $CMDLine ;because $CMDLine is a constant and cannot be changed
Global $InstallFromAppPath, $GamesProgramsDir = '', $INIname, $UberFolder, $RemovedMenuItem = False, $DualArchInstalls = 'b'
Global $ExpressInstall[1], $ScanDepth, $xi, $SplashTemp, $ScanDirs, $AppInstallCount = 0, $SplashOnTop = 0
Global $WINNTVersion = _GetWINNTVersion(), $OS_NT5 = VersionCompare($WINNTVersion, '=', '5'), $OSVersion = @OSVersion
Global $OSArch64 = (StringRight(@OSArch, 2) = '64'), $MetroPresent = VersionCompare($WINNTVersion, '>=', '6.2')
If VersionCompare($WINNTVersion, '>=', '10.0') Then $OSVersion = 'WIN_10'
Global $KeepStartMenuFolders = False, $KeepStartMenuDefaults = False
;Global $ProgramFilesDir = @ProgramFilesDir ;StringLeft(@ProgramFilesDir, 2) & '\Program Files'
Global $ProgramFilesDir32 = Not Not FileExists(EnvGet('ProgramFiles(x86)')) ;32-bit ProgramFiles directory
;Global $SystemDir = @SystemDir ;@WindowsDir & '\System32'
Global $SystemDir32 = Not Not FileExists(@WindowsDir & '\SYSWOW64') ;32-bit System directory
Global $SetupS_CoreVer = '#CoreVersion#', $AbortDL, $AltDistr[1][2], $AltDistrOrder
Global $AboutLink1 = 'http://#WebLink1#', $AboutLink2 = 'http://#WebLink2#', $AboutLink3 = 'http://#WebLink3#', $AboutLink6 = 'http://#WebLink6#'
Global $CopyFromLive, $ppInstall, $AllUsersProfile = EnvGet('ALLUSERSPROFILE')
Global $LinuxHome = 'z:\home\' & @UserName, $OS_Linux = Not Not FileExists($LinuxHome), $WINEVersion = _GetWINEVersion() ; Linux via Wine handling
;~ Global $App_Title_SetupS, $App_BuildType_SetupS, $App_Version_SetupS, $App_InstallPath_SetupS

;--- ssClean.Support ---
Global Const $cSetupSFolder = 'SetupS.SendTo', $MAX_PATH = 260, $ssEOL = '', $tEOL = '^^';, $OCR_WAIT = 32514
Global $ssCleaner = 1, $LLChecked = 0, $LLDeleted = 0, $ssUninstall = False, $ssUninstallChanged = False, $ssUninstallRecover = False
Global $ssCleanRemovedMenuItem = True, $ssCleanerDeleteUninstalled = False, $ssCleanerDeleteDudAppPath = False
If $OS_NT5 Then
	Global $SendToPath = @UserProfileDir & '\SendTo'
	Global $LocalAppData = @UserProfileDir & '\Local Settings\Application Data'
	Global $PublicPath = GetFolderPath($AllUsersProfile) & '\Public'
Else
	Global $SendToPath = @AppDataDir & '\Microsoft\Windows\SendTo'
	Global $LocalAppData = EnvGet('LOCALAPPDATA')
	Global $PublicPath = EnvGet('PUBLIC')
EndIf
Global $QuickLaunch = @AppDataDir & '\Microsoft\Internet Explorer\Quick Launch', $StopWatch, $AppWriteProtected = False
Global $ssClean_enforced = False, $Sys_Uninstall[1][7]
$Sys_Uninstall[0][0] = 0 ; first row=count, 'key' thereafter
$Sys_Uninstall[0][1] = 'DisplayName'
$Sys_Uninstall[0][2] = 'InstallLocation'
$Sys_Uninstall[0][3] = 'DisplayIcon'
$Sys_Uninstall[0][4] = 'UninstallString'
$Sys_Uninstall[0][5] = 'Switches'
$Sys_Uninstall[0][6] = 'Script'

;Pre-existing shortcut removal flags
Global $remDesktop, $remStartmenuRoot, $remProgramsRoot, $remStartup, $remQuickLaunch, $remSendto, $remStartmenuPin, $remTaskbarPin

;-------------------------------------------------- .app Variables ---------------------------------------------------------------
;strings
Global $App_File, $App_Title, $App_Version, $App_smSource, $App_InstallPath, $App_TypeBase, $App_CmdFile, $App_RegFile, $App_BuildType
;values
Global $App_Architecture, $App_OS, $App_Type, $App_scCount, $App_TDStamp, $App_FileVersion, $App_FileFormat, $App_PriorityOrder
;flags
Global $App_MakeStartMenu, $App_KeepInFolder, $App_MakeInPrograms, $App_MakeInRoot, $App_AllUsers, $App_LivePE, $App_MakeStartup
Global $App_MakeDesktop, $App_Runx64, $App_MakeQuickLaunch, $App_NoIcons, $App_RefreshExplorer, $App_MakeSendTo, $App_AlwaysSort
Global $App_NeverSort, $App_KeepAll, $App_AlwaysShow, $App_NoneThing, $App_AlwaysHide, $App_DuringSetupOnly, $App_InstallT13
Global $App_InstallInstant, $App_TaskbarPin, $App_StartmenuPin, $App_UpdateAppFile, $App_MetroFriendly
Global $App_Legacy, $App_OSArchGated, $App_scReset = False, $App_ssUninstall = True, $App_AssemblyNoWait = False
;arrays
Local $App_Title_Section[1], $App_Version_Section[1], $App_Category_Section[1], $App_Flags_Section[1]
Global $App_Assembly[1], $App_InstallFonts[1], $App_Catalog[1], $App_scKeep[1], $App_scEXE[1], $App_scWorkDir[1], $App_scLNK[1]
Global $App_scDesc[1], $App_scArgs[1], $App_scIcon[1], $App_scExt[1], $App_scIndex[1], $App_scState[1], $App_scDefaults[1]
Global $App_scFlags[1], $App_scCatalog[1], $App_scKey[1]
Global $App_FileType[1], $App_Script[1], $App_RegEntries[1], $App_StartMenu[1], $App_smLegacySecondary[1]
Global $App_smLegacyPrimary[1], $App_URL[1], $App_Description[1], $App_RegisterDLL[1], $App_Category[1]
Global $App_Uninstall[1][1]

;-------------------------------------------------- Meta Variables ---------------------------------------------------------------
;strings
Global $App_Publisher, $App_Language, $App_Releaser, $App_Additional, $App_ReleaseDate, $App_ReleaseVersion
;values
Global $App_LicenseType, $App_Rating, $App_RequiredRuntimes, $App_InstalledSize
;arrays
Global $App_Tags[1]
Local $App_Meta_Section[1]

;----------------------------------------------- Settings -----------------------------------------------------------------------
Global $x86PID = GetParameter('x86PID', '=')
Global $ssTekResources = ConvertFromVars('%ssTekResources%'), $TempDir, $TempPixDir, $CategoryINI = FindMe('Category.ini')
If @Compiled Then
	If $OSArch64 Then $SetupS = FileGetShortName(FindMe('SetupS_x64.exe'))
	If $SetupS = '' Then $SetupS = FileGetShortName(FindMe('SetupS.exe'))
	$SetupSFolder = GetFolderPath($SetupS)
Else
	$SetupS = 'AutoIt3.exe /ErrorStdOut /AutoIt3ExecuteScript ' & FileGetShortName(FindMe('SetupS.au3'))
	$SetupSFolder = GetFolderPath(FileGetShortName(FindMe('SetupS.au3')))
	If StringLeft($SetupS_CoreVer, 1) = '#' And StringRight($SetupS_CoreVer, 1) = '#' Then
		If FindMe('SetupS.exe') <> '' Then
			$SetupS_CoreVer = FileGetVersion(FindMe('SetupS.exe'))
		Else
			If $ToolsPath = '' Then GetToolsFolder()
			If FileExists($ToolsPath & '\SetupS.exe') Then
				$SetupS_CoreVer = FileGetVersion($ToolsPath & '\SetupS.exe')
			Else
				$SetupS_CoreVer = '13.4.31.1'
			EndIf
		EndIf
	EndIf
	;$SetupS_CoreVer = '8.13.3.29' ;And StringInStr($SetupS_CoreVer, '#CoreVersion#') ;Use to test v8
	;$SetupS_CoreVer = '13.3.7.29' ;And StringInStr($SetupS_CoreVer, '#CoreVersion#') ;Use to test v13
EndIf
$SetupSFolder = FileGetShortName(ConvertFromVars("%ProgramFiles%\SetupS.SendTo"))

Global $SetupSFileVersion = 'v9.' ; To set a default file-format, use 'v8.' for legacy and 'v9.' for INI
$SetupSFileVersion = $SetupSFileVersion & GetVersionNumber($SetupS_CoreVer, 1) & '.' & GetVersionNumber($SetupS_CoreVer, 2) & '.' & GetVersionNumber($SetupS_CoreVer, 3) & '.' & GetVersionNumber($SetupS_CoreVer, 4)
$ExpressInstall[0] = 0
$App_Uninstall[0][0] = 0
$AboutLink1 = StringReplace($AboutLink1, '/dl.bintray.com/', '/bintray.com/')
$AboutLink2 = StringReplace($AboutLink2, '/dl.bintray.com/', '/bintray.com/')
$AboutLink3 = StringReplace($AboutLink3, '/dl.bintray.com/', '/bintray.com/')

#region ; ----- Project Functions ---------------------------------------------------------------------------------------------------

Func _ArrayRemoveBlanks(ByRef $What)
	Local $i, $j, $found
	Do
		$found = False
		For $i = 1 To $What[0]
			If StringStripWS($What[$i], 3) = '' Then
				For $j = $i + 1 To $What[0]
					$What[$i] = $What[$j]
				Next
				$found = True
				ExitLoop
			EndIf
		Next
		If $found Then
			$What[0] -= 1
			ReDim $What[$What[0] + 1]
		EndIf
	Until Not $found
EndFunc

Func _ConsoleWrite($Data, $new = False)
	;Example of use:
	;_ConsoleWrite('@@ Debug(799) _SetupS.au3|ProcessShortcutS() : $MenuDefinitionINI=' & $MenuDefinitionINI & @crlf & '>Error code: ' & @error & @crlf)
	If $Debug Then _ConsoleWriteDebug($Data, $new, True)
	If $Log Then _ConsoleWriteLog($Data, $new)
	ConsoleWrite($Data)
EndFunc

Func _ConsoleWriteDebug($Data, $new = False, $NoConsoleWrite = False)
	Local $file, $i = 0
	Do
		$i += 1
	Until Not FileExists(@ScriptDir & '\DebugConsole.' & StringFormat("%04s", $i) & '.txt')
	If Not $new Then $i -= 1
	If $i = 0 Then
		$i = 1
		$file = FileOpen(@ScriptDir & '\DebugConsole.' & StringFormat("%04s", $i) & '.txt', 10)
		FileClose($file)
	EndIf
	$file = FileOpen(@ScriptDir & '\DebugConsole.' & StringFormat("%04s", $i) & '.txt', 9)
	FileWriteLine($file, StringReplace($Data, @CRLF, ' : '))
	If Not $NoConsoleWrite Then ConsoleWrite($Data)
	FileClose($file)
EndFunc

Func _ConsoleWriteLog($Data, $new = False)
	Local $file, $i = 0
	Do
		$i += 1
	Until Not FileExists(@ScriptDir & '\ReportingConsole.' & StringFormat("%04s", $i) & '.txt')
	If Not $new Then $i -= 1
	If $i = 0 Then
		$i = 1
		$file = FileOpen(@ScriptDir & '\ReportingConsole.' & StringFormat("%04s", $i) & '.txt', 10)
		FileClose($file)
	EndIf
	$file = FileOpen(@ScriptDir & '\ReportingConsole.' & StringFormat("%04s", $i) & '.txt', 9)
	FileWriteLine($file, StringReplace($Data, @CRLF, ' : '))
	FileClose($file)
EndFunc

Func _DriveGetDrive($What)
	Local $temp[2], $DrvLst = DriveGetDrive($What)
	If @error Then
		$temp[0] = 0
		$temp[1] = ''
		Return $temp
	Else
		Return $DrvLst
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _EnvUpdate
; Description ...: Refreshes the OS environment.
; Syntax.........: _EnvUpdate( ["EnvVariable" [, "Value" [, CurrentUser [, Machine ]]]] )
; Parameters ....: EnvVariable  - [optional] Name of the environment variable to set. If no variable, refreshes all variables.
;                  Value        - [optional] Value to set the environment variable to. If a value is not used the environment
;                                   variable will be deleted.
;                  CurrentUser  - [optional] Sets the variable in current user environment.
;                  Machine      - [optional] Sets the variable in the machine environment.
; Return values .: Success      - None
;                  Failure      - Sets @error to 1.
; Author ........: Jo�o Carlos (jscript)
; Support .......: trancexx, PsaltyDS, KaFu
; Modified.......:
; Remarks .......: Replaces built-in EnvUpdate()
; Related .......:
; Link ..........;
; Example .......; _EnvUpdate("TEMP", @SystemDir & "TEMP", True, True)
; ===============================================================================================================================
Func _EnvUpdate($sEnvVar = "", $vValue = "", $fCurrentUser = True, $fMachine = False)
	Local $sREG_TYPE = "REG_SZ", $iRet1, $iRet2
	Local $MAX_VALUE_NAME = 1024, $HWND_BROADCAST = 0xffff, $WM_SETTINGCHANGE = 0x001A, $MSG_TIMEOUT = 5000
	If $sEnvVar <> "" Then
		If StringInStr($sEnvVar, "\") Then $sREG_TYPE = "REG_EXPAND_SZ"
		If $vValue <> "" Then
			If $fCurrentUser Then RegWrite("HKCU\Environment", $sEnvVar, $sREG_TYPE, $vValue)
			If $fMachine Then RegWrite("HKLM\System\CurrentControlSet\Control\Session Manager\Environment", $sEnvVar, $sREG_TYPE, $vValue)
		Else
			If $fCurrentUser Then RegDelete("HKCU\Environment", $sEnvVar)
			If $fMachine Then RegDelete("HKLM\System\CurrentControlSet\Control\Session Manager\Environment", $sEnvVar)
		EndIf
		; <a href='http://msdn.microsoft.com/en-us/library/ms686206%28VS.85%29.aspx' class='bbc_url' title='External link' rel='nofollow external'>http://msdn.microsoft.com/en-us/library/ms686206%28VS.85%29.aspx</a>
		$iRet1 = DllCall("Kernel32.dll", "BOOL", "SetEnvironmentVariable", "str", $sEnvVar, "str", $vValue)
		If $iRet1[0] = 0 Then Return SetError(1)
	EndIf
	; <a href='http://msdn.microsoft.com/en-us/library/ms644952%28VS.85%29.aspx' class='bbc_url' title='External link' rel='nofollow external'>http://msdn.microsoft.com/en-us/library/ms644952%28VS.85%29.aspx</a>
	$iRet2 = DllCall("user32.dll", "lresult", "SendMessageTimeoutW", _
			"hwnd", $HWND_BROADCAST, _
			"dword", $WM_SETTINGCHANGE, _
			"ptr", 0, _
			"wstr", "Environment", _
			"dword", $SMTO_ABORTIFHUNG, _
			"dword", $MSG_TIMEOUT, _
			"dword_ptr*", 0)
	If $iRet2[0] = 0 Then Return SetError(1)
EndFunc

Func _FileListToArrayPlus($sPath, $sFilter = '', $iFlag = 0, $sOrder = '')
	;	================================================================
	;	(Conceptual replacement for _FileListToArray)
	;
	;	Description .....
	;		Lists files and\or folders in a specified path (actually uses Dir /B)
	;
	;	Syntax ..........
	;		_FileListToArrayPlus($sPath[, $sFilter = ''[, $iFlag = 0[, $sOrder = 0]]])
	;
	;	Parameters ......
	;		$sPath   - Path to generate filelist for.
	;		$sFilter - Optional the filter to use (same syntax as DIR).
	;		$iFlag   - Optional: specifies results to return (add values to combine).
	;			|0 Return both files and folders (Default)
	;			|1 Return files only
	;			|2 Return Folders only
	;			|4 Return full-path
	;			|8 Recurse sub-folders
	;		$sOrder  - Optional: specifies how to sort returned files/folders.
	;			N  By name (alphabetic)       S  By size (smallest first)
	;			E  By extension (alphabetic)  D  By date/time (oldest first)
	;			G  Group directories first    -  Prefix to reverse order
	;				eg. "GN" for folders first then alphabetically by name
	;
	;	Return values ...
	;		One-dimensional array made up as follows:
	;			$array[0] = Number of Files\Folders returned
	;			$array[1] = 1st File\Folder
	;			$array[2] = 2nd File\Folder
	;			$array[3] = 3rd File\Folder
	;			$array[n] = nth File\Folder
	;
	;		@Error -
	;				|1 = Path not found or invalid
	;				|2 = Invalid $sFilter
	;	================================================================
	Local $i, $foo, $line, $aFileList, $sRecurse, $sAttrib = '/a'
	$sPath = NoBackslash(StringRegExpReplace($sPath, '[\\/]+\z', ''))
	If Not FileExists($sPath) Then Return SetError(1, 1, '')
	If StringRegExp($sFilter, '[\\/:><\|]|(?s)\A\s*\z') Then Return SetError(2, 2, '')
	If $sFilter = '*' Or $sFilter = '*.*' Then $sFilter = ''
	If $sFilter <> '' Then $sFilter = '\' & $sFilter
	If Not (BitAND($iFlag, 1) = 1 And BitAND($iFlag, 2) = 2) Then ; in case $iFlag is 3, 7, 11, or 15 (assumes both files and folders)
		If BitAND($iFlag, 1) = 1 Then $sAttrib &= '-D' ;files only
		If BitAND($iFlag, 2) = 2 Then $sAttrib &= 'D' ;folders only
	EndIf
	If BitAND($iFlag, 8) = 8 Then $sRecurse &= '/s' ;recurse
	$sOrder = StringReplace(StringReplace($sOrder, '/o:', ''), '/o', '')
	If $sOrder <> '' Then $sOrder = '/o' & $sOrder
	$foo = Run($CLIprefix & 'DIR "' & $sPath & $sFilter & '" /b' & $sAttrib & $sRecurse & $sOrder, '', @SW_HIDE, $STDOUT_CHILD)
	Do
		$line &= StdoutRead($foo)
	Until @error
	$aFileList = StringSplit(StringLeft($line, StringLen($line) - 2), @CRLF, 1)
	If Not IsArray($aFileList) Then
		ReDim $aFileList[1]
		$aFileList[0] = 0
	ElseIf BitAND($iFlag, 8) <> 8 And BitAND($iFlag, 4) = 4 Then ; add full-path
		For $i = 1 To $aFileList[0]
			$aFileList[$i] = $sPath & '\' & $aFileList[$i]
		Next
	EndIf
	Return $aFileList
EndFunc

;===============================================================================
;
; Description:			Returns the requested property or an array of all properties
;							for the specified file.
; Syntax:				_GetFileProperty( $sPath, optional $sProp )
; Parameter(s):		$sPath -	Path and filename of the file to query
;							$sProp -	(optional) Name of property to return
;										if not specified will return array of all properties
; Requirement(s):		AutoIt 3.2 or higher
; Return Value(s):	On Success - Returns string value of property OR
;											 Returns 2 dimensional array (property name,value)
;							On Failure - Returns nothing
;											 @error = 1 - file does not exist
;											 @error = 2 - unable to get property
; Author(s):			Sean Hart (autoit AT hartmail DOT ca)
;							(idea from GetExtProperty by Simucal, thanks)
; Note(s):				Special
;
;===============================================================================
Func _GetFileProperty($sPath, $sProp = '')
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|_GetFileProperty(): $sPath=' & $sPath & @CRLF)
	; Declare local variables
	Local $sFile, $sDir, $oShell, $oDir, $oFile, $i, $count, $aProps[1][3]

	; Init counter used for array of properties
	$count = 0

	; Check file exists first
	If Not FileExists($sPath) Then
		SetError(1)
		Return
	Else
		; Pull file name and directory from full file path
		$sFile = StringTrimLeft($sPath, StringInStr($sPath, '\', 0, -1))
		$sDir = StringTrimRight($sPath, (StringLen($sPath) - StringInStr($sPath, '\', 0, -1)))
		If $sDir = '' Then $sDir = @WorkingDir

		; Create required objects
		$oShell = ObjCreate('shell.application')
		$oDir = $oShell.NameSpace($sDir)
		$oFile = $oDir.Parsename($sFile)

		; Loop through 99 possible property numbers (allows for future additions to property fields)
		For $i = 0 To 99
			; If no property specified then add to array
			If ($sProp = '') Then
				; Only add if property name is not blank
				If ($oDir.GetDetailsOf($oDir.Items, $i) <> '') Then
					; Increase counter and redimension array
					$count += 1
					ReDim $aProps[$count + 1][3]

					; Add property name and value to array
					$aProps[$count][1] = $oDir.GetDetailsOf($oDir.Items, $i)
					$aProps[$count][2] = $oDir.GetDetailsOf($oFile, $i)
				EndIf

				; If property name matches property being requested, return value
			ElseIf $oDir.GetDetailsOf($oDir.Items, $i) = $sProp Then
				Return $oDir.GetDetailsOf($oFile, $i)
			EndIf
		Next

		; If array was populated return array, otherwise return error 2
		If $count > 0 Then
			Return $aProps
		Else
			SetError(2)
			Return
		EndIf
	EndIf
EndFunc

Func _GetWINEVersion()
	Local $Ver = 0, $VersionString = '', $foo = Run(@ComSpec & " /c ver", @SystemDir, @SW_HIDE, 4 + 2) ;$STDERR_CHILD + $STDOUT_CHILD)
	Local $line = StdoutRead($foo)
	While Not @error
		If StringStripWS($line, 8) <> '' Then
			StdioClose($foo)
			Select
				Case StringInStr($line, 'WINE')
					$VersionString = StringSplit($line, '(')
					$Ver = StringStripWS($VersionString[2], 8)
					$Ver = StringLeft($Ver, StringLen($Ver) - 1)
				Case StringInStr($line, 'Microsoft Windows')
					$Ver = '' ;'1.7.4' ;'1.6.4' ;''
			EndSelect
			Return StringStripWS($Ver, 8)
		EndIf
		$line = StdoutRead($foo)
	WEnd
	Return False
EndFunc

Func _GetWINNTVersion()
	Local $Ver = 0, $VersionString = 'Version', $foo = Run(@ComSpec & " /c ver", @SystemDir, @SW_HIDE, 4 + 2) ;$STDERR_CHILD + $STDOUT_CHILD)
	Local $line = StdoutRead($foo)
	While Not @error
		If StringStripWS($line, 8) <> '' Then
			StdioClose($foo)
			Select
				Case StringInStr($line, 'WINE')
					$Ver = ''
				Case StringInStr($line, 'Microsoft Windows')
					$Ver = StringStripWS(StringReplace(StringReplace(StringMid($line, StringInStr($line, $VersionString)), $VersionString, ''), ']', ''), 8)
			EndSelect
			Return StringStripWS($Ver, 8)
		EndIf
		$line = StdoutRead($foo)
	WEnd
	Return False
EndFunc

Func _HiWord($x)
	Return BitShift($x, 16)
EndFunc

; ==============================================================================================
; Func _KeyModifiersToString($nModifiers, $bSendType = True)
;
; Convert modifiers to a string of characters, either AutoIt Send() style,
; or full descriptive key combo style ("SHIFT+CTRL"..)
;
; $nModifiers = Modifier value
;  This is a combo of any of these values:
;   HOTKEYF_SHIFT     0x01
;   HOTKEYF_CONTROL   0x02
;   HOTKEYF_ALT       0x04
;   HOTKEYF_EXT       0x08  ; This is used primarily for extended VK keys
;
; $bSendType = If non-zero or True (default, returns Send()-style key combo
;   Otherwise a full descriptive key combo string is returned ("SHIFT+CTRL"..)
;
; Returns:
;  Success: A string representing either the AutoIt modifiers, or a full descriptive key-combo
;           (depending on $bSendType)
;  Failure: none. An empty string means no modifiers were found
; ==============================================================================================
Func _KeyModifiersToString($nModifiers, $bSendType = True)
	Local $sModifiers = ""
	Local $sAutoItModifiers = ""
	; SHIFT?
	If BitAND($nModifiers, 1) Then
		$sModifiers &= "SHIFT+"
		$sAutoItModifiers &= '+'
	EndIf
	; CONTROL?
	If BitAND($nModifiers, 2) Then
		$sModifiers &= "CTRL+"
		$sAutoItModifiers &= '^'
	EndIf
	; ALT?
	If BitAND($nModifiers, 4) Then
		$sModifiers &= "ALT"
		$sAutoItModifiers &= '!'
	EndIf
	If $bSendType Then Return $sAutoItModifiers
	; Else
	If StringRight($sModifiers, 1) = '+' Then $sModifiers = StringTrimRight($sModifiers, 1)
	Return $sModifiers
EndFunc

; ==============================================================================================
; Func _KeyVirtualKeyToChar($nVKCode)
;
; Converts a Virtual-Key code to an ASCII character, if possible.
;  The exceptions are special keys like Arrow keys, function keys, etc, which return as ""
;
; $nVKCode = virtual key code
;
; Returns:
;  Success: Either "" for non-matching character, or the character itself. @error = 0
;  Failure: "" with @error set
; ==============================================================================================
Func _KeyVirtualKeyToChar($nVKCode)
	Local $aRet, $cChar = ""
	$aRet = DllCall("user32.dll", "uint", "MapVirtualKeyW", "uint", $nVKCode, "uint", 2)
	If @error Then Return SetError(2, @error, "")
	If $aRet[0] <> 0 Then
		$cChar = Chr(BitAND($aRet[0], 0xFF))
	EndIf
	Return $cChar
EndFunc

Func _LoWord($x)
	Return BitAND($x, 0xFFFF)
EndFunc
Func _ShowTray()
	TraySetIcon()
EndFunc

#cs ===============================================================================
	Function:      _SystemUsers($AccountType = 0)
	Description:   Return an array with the local or domain username
	Parameter(s):  $AccountType: Local, domain or both username
	0 = Local and Domain usernames
	1 = Local usernames only
	2 = Domain usernames only
	Returns:       An array with the list of usernames - Succeeded
	@error 1 - Didn't query any username
	@error 2 - Failed to create Win32_SystemUsers object
	@error 3 - Invalid $AccountType

	Author(s):  Danny35d
	Ref: http://www.autoitscript.com/forum/topic/112619-get-list-of-all-windows-users/
#ce ===============================================================================
Func _SystemUsers($AccountType = 0)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|_SystemUsers(): $AccountType=' & $AccountType & @CRLF)
	Local $aSystemUsers
	Local $wbemFlagReturnImmediately = 0x10, $wbemFlagForwardOnly = 0x20
	Local $colItems = "", $strComputer = "localhost", $Output, $temp
	If Not StringRegExp($AccountType, '[012]') Then Return SetError(3, 3, '')
	Local $objWMIService = ObjGet("winmgmts:\\" & $strComputer & "\root\CIMV2")
	If Not @error And IsObj($objWMIService) Then
;~ 		If Not FileExists($LinuxHome) Then ; skips this in Linux (because it doesn't work in Linux)
		$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_SystemUsers", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
;~ 		EndIf
		If IsObj($colItems) Then
			For $objItem In $colItems
				$Output = StringSplit($objItem.PartComponent, ',')
				If IsArray($Output) Then
					$temp = StringReplace(StringTrimLeft($Output[2], StringInStr($Output[2], '=', 0, -1)), '"', '')
					If ($AccountType = 1 And @ComputerName = $temp) Or $AccountType = 0 Then
						$aSystemUsers &= StringReplace(StringTrimLeft($Output[1], StringInStr($Output[1], '=', 0, -1)), '"', '') & '|'
					ElseIf $AccountType = 2 And @ComputerName <> $temp Then
						$aSystemUsers &= StringReplace(StringTrimLeft($Output[1], StringInStr($Output[1], '=', 0, -1)), '"', '') & '|'
					EndIf
				EndIf
			Next
			$aSystemUsers = StringTrimRight($aSystemUsers, 1)
			If $aSystemUsers = '' Then Return (SetError(1, 1, $aSystemUsers))
			Return (SetError(0, 0, StringSplit($aSystemUsers, '|')))
		Else
			$aSystemUsers = ''
			Return (SetError(2, 2, $aSystemUsers))
		EndIf
	EndIf
EndFunc

Func _TrayTip($title, $text, $timeout, $option = 0); TrayTip( "title", "text", timeout [, option])
	TraySetState(2) ; Hide the tray icon
	TraySetState() ; Show the tray icon
	TrayTip($title, $text, $timeout, $option = 0)
EndFunc

Func AddFlag(ByRef $temp, $This)
	;If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|AddFlag(): $Temp=' & $Temp & @CRLF)
	If $temp <> '' Then $temp = $temp & '|'
	$temp = $temp & $This
EndFunc

Func AddLegacy(ByRef $WholeCatalog, $What, $smLegacy)
	Local $i, $j, $found = False
	Switch $smLegacy
		Case 1
			If IsArray($App_smLegacyPrimary) Then
				For $i = 1 To $App_smLegacyPrimary[0]
					$found = False
					For $j = 1 To $WholeCatalog[0][0]
						If $WholeCatalog[$j][1] = $App_smLegacyPrimary[$i] Then
							If GetMenuDefs(1) <> '' Then IniWrite(GetMenuDefs(1), 'Catalog', $What, $App_smLegacyPrimary[$i])
							$found = True
							ExitLoop
						EndIf
					Next
				Next
			EndIf
		Case 2
			If IsArray($App_smLegacySecondary) Then
				For $i = 1 To $App_smLegacySecondary[0]
					$found = False
					For $j = 1 To $WholeCatalog[0][0]
						If $WholeCatalog[$j][1] = $App_smLegacySecondary[$i] Then
							If GetMenuDefs(2) <> '' Then IniWrite(GetMenuDefs(2), 'Catalog', $What, $App_smLegacySecondary[$i])
							$found = True
							ExitLoop
						EndIf
					Next
				Next
			EndIf
	EndSwitch
	Return $found
EndFunc

Func CenterMe($hForm, $hCtrl, $TotalWidth, $Offset = -1) ;, $CtrlTop, $CtrlHeight, $Size, $Weight, $Attribute, $Fontname, $Quality = 5)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|CenterMe(): $TotalWidth=' & $TotalWidth & @CRLF)
	Local $CtrlLeft, $CtrlTop, $CtrlWidth, $CtrlHeight
	Local $aCtrlPos = ControlGetPos($hForm, GUICtrlRead($hCtrl), $hCtrl);l[0],t[1],w[2],h[3];ControlGetText('', '', $hForm)
	If Not @error = 1 Then
		If $Offset = -1 Then $Offset = $aCtrlPos[0]
		$CtrlTop = $aCtrlPos[1]
		$CtrlWidth = $aCtrlPos[2];$aCtrlSize[2]
		$CtrlHeight = $aCtrlPos[3]
		If $CtrlWidth > $TotalWidth - $Offset Then $CtrlWidth = $TotalWidth - $Offset
		$CtrlLeft = $Offset + ($TotalWidth - $Offset - $CtrlWidth) / 2
		GUICtrlSetPos($hCtrl, $CtrlLeft, $CtrlTop, $CtrlWidth, $CtrlHeight);l,t,w,h
		Return True
	Else
		Return False
	EndIf
EndFunc

Func CheckINI($What)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|CheckINI(): $What=' & $What & @CRLF)
	Local $LocalINI, $j, $UsingLocal = (FindMe($What) <> $ssTekResources & '\' & $What), $UpdateINI = '', $UpdateINIMode = ''
	Select
		Case FileExists(@ScriptDir & '\' & $What) ;Current
			$LocalINI = @ScriptDir & '\' & $What
		Case FileExists(@ScriptDir & '\..\' & $What) ;Parent
			$LocalINI = @ScriptDir & '\..\' & $What
	EndSelect
	If IniRead_Binary($LocalINI, 'Updates', 'INI', 'No') Then $UpdateINI = $LocalINI
	If FileExists($ssTekResources & '\' & $What) And $UpdateINI = '' And IniRead_Binary($ssTekResources & '\' & $What, 'Updates', 'INI', 'No') Then $UpdateINI = $ssTekResources & '\' & $What
	Select
		Case $UsingLocal
			$UpdateINIMode = 'Reset'
		Case $UpdateINI <> ''
			$UpdateINIMode = IniRead($UpdateINI, 'Updates', 'Mode', 'Reset')
	EndSelect
	If FileExists($LocalINI) Then
		NeoIniWrite($LocalINI, 'Updates', 'INI', 'No')
		Switch $UpdateINIMode
			Case 'Reset' ; Reset (default)
				FileCopy($LocalINI, $ssTekResources & '\', 9)
			Case 'Merge' ; Add new keys/values but retain any old ones
				Local $ThisSection, $SectionsList = IniReadSectionNames($LocalINI)
				If Not @error Then
					For $i = 1 To $SectionsList[0]
						$ThisSection = IniReadSection($LocalINI, $SectionsList[$i])
						If Not @error Then
							For $j = 1 To $ThisSection[0][0]
								If IniRead($ssTekResources & '\' & $What, $SectionsList[$i], $ThisSection[$j][0], 'Not Exist') = 'Not Exist' Then
									;MsgBox(4096, "", "Section: " & $SectionsList[$i] & @CRLF & "Key: " & $ThisSection[$j][0] & @CRLF & "Value: " & $ThisSection[$j][1])
									NeoIniWrite($ssTekResources & '\' & $What, $SectionsList[$i], $ThisSection[$j][0], IniRead($LocalINI, $SectionsList[$i], $ThisSection[$j][0], ''))
								EndIf
							Next
						Else
							If $Debug Then _ConsoleWriteDebug('@@ Debug(1370) SetupS.Core.au3|CheckINI() : $i=' & $i & @CRLF & ': $SectionsList[$i]=' & $SectionsList[$i] & @CRLF & '>Error code: ' & @error & @CRLF)
						EndIf
					Next
				Else
					If $Debug Then _ConsoleWriteDebug('@@ Debug(1374) SetupS.Core.au3|CheckINI() : $What=' & $What & @CRLF & '>Error code: ' & @error & @CRLF)
				EndIf
		EndSwitch
	EndIf
	If FileExists($ssTekResources & '\' & $What) Then NeoIniWrite($ssTekResources & '\' & $What, 'Updates', 'INI', 'No')
	Return FindMe($What)
EndFunc

Func Cleanup($Extra = '')
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|Cleanup(): $Extra=' & $Extra & @CRLF)
	FileChangeDir(@ScriptDir)
	If $ppDriveOld Then ; 'remove' from old
		DirRemove($ppDriveOld & StringMid($App_InstallPath, 3), 1)
		If $App_Type = 5 Then
			RemoveEmptyDir($ppDriveOld & '\ppGames')
		Else
			RemoveEmptyDir($ppDriveOld & '\ppApps')
		EndIf
	EndIf
	If $App_RefreshExplorer Then Update_Explorer()
	FileDelete(@TempDir & '\SetupS*.*')
	DirRemove(@TempDir & '\SetupS*.*', 1)
	If $TempDir <> '' Then
		DeleteMe($TempDir)
		$TempDir = ''
	EndIf
	If $TempPixDir <> '' Then
		DeleteMe($TempPixDir)
		$TempPixDir = ''
	EndIf
	If $Extra <> '' Then DeleteMe($Extra, False)
	FileDelete(@TempDir & '\RunWait86.exe')
	If Not $Debug Then FileDelete(@ScriptDir & '\DebugConsole.*.txt')
	If Not $Log Then FileDelete(@ScriptDir & '\ReportingConsole.*.txt')
EndFunc

Func ConvertBackAllPathVars()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|ConvertBackAllPathVars()' & @CRLF)
	Local $i
	$App_smSource = ConvertToVars($App_smSource)
	$App_InstallPath = ConvertToVars($App_InstallPath)
	For $i = 1 To $App_Assembly[0]
		$App_Assembly[$i] = ConvertToVars($App_Assembly[$i])
	Next
	For $i = 1 To $App_InstallFonts[0]
		$App_InstallFonts[$i] = ConvertToVars($App_InstallFonts[$i], True)
	Next
	For $i = 1 To $App_scCount
		If $App_scEXE[$i] <> '' And $App_scLNK[$i] <> '' Then
			$App_scEXE[$i] = ConvertToVars($App_scEXE[$i])
			$App_scWorkDir[$i] = ConvertToVars($App_scWorkDir[$i])
			$App_scArgs[$i] = ConvertToVars($App_scArgs[$i])
			$App_scIcon[$i] = ConvertToVars($App_scIcon[$i])
			If StringInStr($App_scEXE[$i], '\') And StringInStr($App_scEXE[$i], $App_InstallPath & '\') Then
				$App_scEXE[$i] = StringMid($App_scEXE[$i], StringInStr($App_scEXE[$i], $App_InstallPath & '\') + StringLen($App_InstallPath & '\'))
			EndIf
			If $App_scWorkDir[$i] = '' Then $App_scWorkDir[$i] = ConvertToVars(GetFolderPath($App_scEXE[$i]))
			Select
;~ 				Case (StringReplace(NoBackslash($App_scWorkDir[$i]), '"', '') = StringReplace(NoBackslash($App_InstallPath), '"', ''))
;~ 					$App_scWorkDir[$i] = ''
				Case StringInStr($App_scWorkDir[$i], '\') And StringInStr($App_scWorkDir[$i], $App_InstallPath & '\')
					$App_scWorkDir[$i] = StringMid($App_scWorkDir[$i], StringInStr($App_scWorkDir[$i], $App_InstallPath & '\') + StringLen($App_InstallPath & '\'))
			EndSelect
			If StringInStr($App_scIcon[$i], '\') And StringInStr($App_scIcon[$i], $App_InstallPath & '\') Then
				$App_scIcon[$i] = StringMid($App_scIcon[$i], StringInStr($App_scIcon[$i], $App_InstallPath & '\') + StringLen($App_InstallPath & '\'))
			EndIf
			If StringInStr($App_scLNK[$i], '\') And StringInStr($App_scLNK[$i], $App_smSource & '\') Then
				$App_scLNK[$i] = StringMid($App_scLNK[$i], StringInStr($App_scLNK[$i], $App_smSource & '\') + StringLen($App_smSource & '\'))
			EndIf
		EndIf
	Next
	For $i = 1 To $App_Uninstall[0][0]
		If $App_Uninstall[$i][0] <> '' Then
			$App_Uninstall[$i][4] = ConvertToVars($App_Uninstall[$i][4])
			$App_Uninstall[$i][2] = ConvertToVars($App_Uninstall[$i][2])
			$App_Uninstall[$i][3] = ConvertToVars($App_Uninstall[$i][3])
			$App_Uninstall[$i][6] = ConvertToVars($App_Uninstall[$i][6])
		EndIf
	Next
	$App_CmdFile = ConvertToVars($App_CmdFile)
	$App_RegFile = ConvertToVars($App_RegFile, True)
EndFunc

Func ConvertFromVars($In, $RegPath = False) ; Replace Varibles sent in with Absolute Values
	;If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|ConvertFromVars()' & @CRLF)
	Local $Out = $In

	; Default System/Environment 														%Data%			NT/XP		Vista/7
	$Out = StringReplace($Out, '%SystemDrive%', RegPathConvert($SystemDrive, $RegPath)) ;%SYSTEMDRIVE% 	C: 	C:
	$Out = StringReplace($Out, '%SystemRoot%', RegPathConvert(@WindowsDir, $RegPath)) ;%SystemRoot% 	C:\Windows 	C:\Windows
	$Out = StringReplace($Out, '%WinDir%', RegPathConvert(@WindowsDir, $RegPath)) ; %WINDIR% 	C:\Windows 	C:\Windows
	If $OSArch64 Then
		$Out = StringReplace($Out, '%PROGRAMFILES(X86)%', RegPathConvert(EnvGet('PROGRAMFILES(X86)'), $RegPath)) ; %PROGRAMFILES(X86)% 	C:\Program Files (x86) (only in 64-bit version) 	C:\Program Files (x86) (only in 64-bit version)
		$Out = StringReplace($Out, '%COMMONPROGRAMFILES(x86)%', RegPathConvert(EnvGet('COMMONPROGRAMFILES(x86)'), $RegPath)) ; %COMMONPROGRAMFILES(x86)% 	C:\Program Files (x86)\Common Files 	C:\Program Files (x86)\Common Files
		If $App_Architecture = 1 And ($SystemDir32 Or $ProgramFilesDir32) Then
			$Out = StringReplace($Out, '%ProgramFiles%', RegPathConvert(EnvGet('PROGRAMFILES(X86)'), $RegPath)) ;%PROGRAMFILES% 	C:\Program Files 	C:\Program Files
			$Out = StringReplace($Out, '%CommonProgramFiles%', RegPathConvert(EnvGet('COMMONPROGRAMFILES(x86)'), $RegPath)) ; %COMMONPROGRAMFILES% 	C:\Program Files\Common Files 	C:\Program Files\Common Files @CommonFilesDir
			$Out = StringReplace($Out, '%SystemDir%', RegPathConvert(@WindowsDir & '\SYSWOW64', $RegPath))
		Else
			$Out = StringReplace($Out, '%ProgramFiles%', RegPathConvert(@ProgramFilesDir, $RegPath)) ;%PROGRAMFILES% 	C:\Program Files 	C:\Program Files
			$Out = StringReplace($Out, '%CommonProgramFiles%', RegPathConvert(@CommonFilesDir, $RegPath)) ; %COMMONPROGRAMFILES% 	C:\Program Files\Common Files 	C:\Program Files\Common Files @CommonFilesDir
			$Out = StringReplace($Out, '%SystemDir%', RegPathConvert(@SystemDir, $RegPath)) ; %SystemDir% 	C:\Windows\System32 	C:\Windows\System32
		EndIf
	Else ; x86
		$Out = StringReplace($Out, '%PROGRAMFILES(X86)%', RegPathConvert(@ProgramFilesDir, $RegPath)) ; %PROGRAMFILES(X86)% 	C:\Program Files (x86) (only in 64-bit version) 	C:\Program Files (x86) (only in 64-bit version)
		$Out = StringReplace($Out, '%COMMONPROGRAMFILES(x86)%', RegPathConvert(@CommonFilesDir, $RegPath)) ; %COMMONPROGRAMFILES(x86)% 	C:\Program Files (x86)\Common Files 	C:\Program Files (x86)\Common Files
		$Out = StringReplace($Out, '%ProgramFiles%', RegPathConvert(@ProgramFilesDir, $RegPath)) ;%PROGRAMFILES% 	C:\Program Files 	C:\Program Files
		$Out = StringReplace($Out, '%CommonProgramFiles%', RegPathConvert(@CommonFilesDir, $RegPath)) ; %COMMONPROGRAMFILES% 	C:\Program Files\Common Files 	C:\Program Files\Common Files @CommonFilesDir
		$Out = StringReplace($Out, '%SystemDir%', RegPathConvert(@SystemDir, $RegPath)) ; %SystemDir% 	C:\Windows\System32 	C:\Windows\System32
	EndIf
	$Out = StringReplace($Out, '%COMSPEC%', RegPathConvert(@ComSpec, $RegPath)) ; %COMSPEC% 	C:\Windows\System32\cmd.exe 	C:\Windows\System32\cmd.exe
	$Out = StringReplace($Out, '%PATH%', RegPathConvert(EnvGet('PATH'), $RegPath)) ; %PATH% 	C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;{plus program paths} 	C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;{plus program paths}
	$Out = StringReplace($Out, '%COMPUTERNAME%', RegPathConvert(@ComputerName, $RegPath)) ; %COMPUTERNAME% 	{computername} 	{computername}

	; 'Current User' data.
	$Out = StringReplace($Out, '%HomeDrive%', RegPathConvert(@HomeDrive, $RegPath)) ; %HOMEDRIVE% 	C: 	C:
	$Out = StringReplace($Out, '%HomePath%', RegPathConvert(@HomePath, $RegPath)) ; %HOMEPATH% 	\Documents and Settings\{username} 	\Users\{username}
	$Out = StringReplace($Out, '%UserProfile%', RegPathConvert(@UserProfileDir, $RegPath)) ; %USERPROFILE%	C:\Documents and Settings\{username} 	C:\Users\{username}
	$Out = StringReplace($Out, '%AppData%', RegPathConvert(@AppDataDir, $RegPath)) ; %APPDATA% 	%USERPROFILE%\Application Data 	%USERPROFILE%\AppData\Roaming
	$Out = StringReplace($Out, '%Temp%', RegPathConvert(@TempDir, $RegPath)) ;%TEMP% 	C:\Documents and Settings\{username}\Local Settings\Temp 	C:\Users\{username}\AppData\Local\Temp
	$Out = StringReplace($Out, '%Tmp%', RegPathConvert(@TempDir, $RegPath)) ; %TMP% 	C:\Documents and Settings\{username}\Local Settings\Temp 	C:\Users\{username}\AppData\Local\Temp
	$Out = StringReplace($Out, '%Desktop%', RegPathConvert(@DesktopDir, $RegPath)) ; %USERPROFILE%\Desktop	%USERPROFILE%\Desktop		%USERPROFILE%\Desktop
	$Out = StringReplace($Out, '%Favorites%', RegPathConvert(@FavoritesDir, $RegPath)) ; %USERPROFILE%\Favorites	%USERPROFILE%\Favorites		%USERPROFILE%\Favorites
	$Out = StringReplace($Out, '%MyDocuments%', RegPathConvert(@MyDocumentsDir, $RegPath)) ; %USERPROFILE%\My Documents	%USERPROFILE%\{username}'s Documents		%USERPROFILE%\Documents
	$Out = StringReplace($Out, '%StartMenu%', RegPathConvert(@StartMenuDir, $RegPath)) ; %USERPROFILE%\Start Menu 	%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu
	$Out = StringReplace($Out, '%Programs%', RegPathConvert(@ProgramsDir, $RegPath)) ; %USERPROFILE%\Start Menu\Programs		%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs
	$Out = StringReplace($Out, '%Startup%', RegPathConvert(@StartupDir, $RegPath)); %USERPROFILE%\Start Menu\Programs\Startup		%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
	$Out = StringReplace($Out, '%SendtoPath%', RegPathConvert($SendToPath, $RegPath));
	$Out = StringReplace($Out, '%QuickLaunch%', RegPathConvert($QuickLaunch, $RegPath))
	$Out = StringReplace($Out, '%UserName%', RegPathConvert(@UserName, $RegPath)) ; %USERNAME% 	{username} 	{username}
	$Out = StringReplace($Out, '%LocalAppData%', RegPathConvert($LocalAppData, $RegPath)) ; %LocalAppData% 	%USERPROFILE%\Local Settings\Application Data 	%UserProfile%\AppData\Local

	; 'All Users' data
	$Out = StringReplace($Out, '%AllUsersProfile%', RegPathConvert($AllUsersProfile, $RegPath)) ; %ALLUSERSPROFILE%	C:\Documents and Settings\All Users		C:\ProgramData
	$Out = StringReplace($Out, '%Public%', RegPathConvert($PublicPath, $RegPath))
	$Out = StringReplace($Out, '%DesktopCommon%', RegPathConvert(@DesktopCommonDir, $RegPath)) ; N/A	C:\Documents and Settings\All Users\Desktop		C:\Users\Public\Desktop
	$Out = StringReplace($Out, '%AppDataCommon%', RegPathConvert(@AppDataCommonDir, $RegPath)) ; N/A	%AllUsersProfile%\Application Data				%AllUsersProfile%\Application Data
	$Out = StringReplace($Out, '%DocumentsCommon%', RegPathConvert(@DocumentsCommonDir, $RegPath)) ; C:\Documents and Settings\All Users\Documents
	$Out = StringReplace($Out, '%FavoritesCommon%', RegPathConvert(@FavoritesCommonDir, $RegPath)) ; C:\Documents and Settings\All Users\Favorites
	$Out = StringReplace($Out, '%StartMenuCommon%', RegPathConvert(@StartMenuCommonDir, $RegPath)) ; C:\Documents and Settings\All Users\Start Menu	x:\ProgramData\Microsoft\Windows\Start Menu
	$Out = StringReplace($Out, '%ProgramsCommon%', RegPathConvert(@ProgramsCommonDir, $RegPath)); C:\Documents and Settings\All Users\Start Menu\Programs
	$Out = StringReplace($Out, '%StartupCommon%', RegPathConvert(@StartupCommonDir, $RegPath)); C:\Documents and Settings\All Users\Start Menu\Programs\Startup

	;SetupS vars
	$Out = StringReplace($Out, '%LastOSResources%', RegPathConvert(@WindowsDir & '\ssTek', $RegPath))
	$Out = StringReplace($Out, '%ssTekResources%', RegPathConvert(@WindowsDir & '\ssTek', $RegPath))
	$Out = StringReplace($Out, '%Resources%', RegPathConvert(@WindowsDir & '\Resources', $RegPath))
	$Out = StringReplace($Out, '%inipath%', RegPathConvert($SrcPath, $RegPath)) ; Full path (drive + folder)
	$Out = StringReplace($Out, '%sourcepath%', RegPathConvert($SrcPath, $RegPath)) ; Full path (drive + folder)
	$Out = StringReplace($Out, '%sourcedrive%', RegPathConvert(StringLeft($SrcPath, 2), $RegPath)) ; drive only
	$Out = StringReplace($Out, '%sourcefolder%', RegPathConvert(StringMid($SrcPath, 3), $RegPath)) ; folder only
	$Out = StringReplace($Out, '%ppAppsDrive%', RegPathConvert($ppAppsDrive, $RegPath)) ; drive only
	$Out = StringReplace($Out, '%ppApps%', RegPathConvert($ppAppsDrive & '\ppApps', $RegPath)) ; Full path (drive + folder)
	$Out = StringReplace($Out, '%ppGamesDrive%', RegPathConvert($ppGamesDrive, $RegPath)) ; Just the drive
	$Out = StringReplace($Out, '%ppGames%', RegPathConvert($ppGamesDrive & '\ppGames', $RegPath)) ; Full path (drive + folder)
	$Out = StringReplace($Out, '%tools%', RegPathConvert($ToolsPath, $RegPath)) ; Full path (drive + folder)
	If StringInStr($Out, '%ToolsDrive%') Then $Out = StringReplace($Out, '%toolsdrive%', RegPathConvert($ToolsDrive, $RegPath)) ; drive only
	$Out = StringReplace($Out, '%toolsfolder%', RegPathConvert($ToolsDir, $RegPath)) ; folder only
	$Out = StringReplace($Out, '%InstalledPath%', RegPathConvert($App_InstallPath, $RegPath)) ; Full path (drive + folder)
	$Out = StringReplace($Out, '%AppPath%', RegPathConvert($App_InstallPath, $RegPath)) ; Full path (drive + folder)
	$Out = StringReplace($Out, '%AppDrive%', RegPathConvert(StringLeft($App_InstallPath, 2), $RegPath)) ; drive only
	$Out = StringReplace($Out, '%AppFolder%', RegPathConvert(StringMid($App_InstallPath, 3), $RegPath)) ; folder only
	$Out = StringReplace($Out, '%ThisPath%', RegPathConvert(@ScriptDir, $RegPath)) ; Full path (drive + folder)
	$Out = StringReplace($Out, '%ThisDrive%', RegPathConvert(StringLeft(@ScriptDir, 2), $RegPath)) ; drive only
	$Out = StringReplace($Out, '%ThisFolder%', RegPathConvert(StringMid(@ScriptDir, 3), $RegPath)) ; folder only
	$Out = StringReplace($Out, '%tools%\addoninstaller ', RegPathConvert('%AddonInstaller% ', $RegPath))
	$Out = StringReplace($Out, '%tools%\addoninstaller"', RegPathConvert('%AddonInstaller%"', $RegPath))
	$Out = StringReplace($Out, '%tools%\addoninstaller.exe', RegPathConvert('%AddonInstaller% ', $RegPath))
	$Out = StringReplace($Out, 'addoninstaller ', RegPathConvert('AddonInstaller.exe ', $RegPath))
	$Out = StringReplace($Out, 'addoninstaller"', RegPathConvert('AddonInstaller.exe"', $RegPath))
	$Out = StringReplace($Out, 'addoninstaller.exe', RegPathConvert('AddonInstaller.exe ', $RegPath))
	$Out = StringReplace($Out, '#addoninstaller#', RegPathConvert('AddonInstaller.exe', $RegPath))
	$Out = StringReplace($Out, '%addoninstaller%', RegPathConvert('AddonInstaller.exe', $RegPath))
	$Out = StringReplace($Out, '#ProcessKill#', RegPathConvert('ProcessKill.exe', $RegPath))
	$Out = StringReplace($Out, '%ProcessKill%', RegPathConvert('ProcessKill.exe', $RegPath))
	$Out = StringReplace($Out, '#TaskKill#', RegPathConvert('ProcessKill.exe', $RegPath))
	$Out = StringReplace($Out, '%TaskKill%', RegPathConvert('ProcessKill.exe', $RegPath))
	$Out = StringReplace($Out, '#WaitForIt#', RegPathConvert('WaitForIt.exe', $RegPath))
	$Out = StringReplace($Out, '%WaitForIt%', RegPathConvert('WaitForIt.exe', $RegPath))
	$Out = StringReplace($Out, '#AddToHosts#', RegPathConvert('AddToHosts.exe', $RegPath))
	$Out = StringReplace($Out, '%AddToHosts%', RegPathConvert('AddToHosts.exe', $RegPath))
	$Out = StringReplace($Out, '#Extract#', RegPathConvert('7z.exe x -y -aoa', $RegPath))
	$Out = StringReplace($Out, '%Extract%', RegPathConvert('7z.exe x -y -aoa', $RegPath))
	If StringInStr($Out, '%OpticalDrive%') Or StringInStr($Out, '%cdrom%') Or StringInStr($Out, '%cddrive%') Then
		If $CDDrive = '' Then GetOpticalDrive()
		$Out = StringReplace($Out, '%OpticalDrive%', RegPathConvert($CDDrive, $RegPath)) ; drive only
		$Out = StringReplace($Out, '%cdrom%', RegPathConvert($CDDrive, $RegPath)) ; drive only
		$Out = StringReplace($Out, '%cddrive%', RegPathConvert($CDDrive, $RegPath)) ; drive only
	EndIf

	;Reg import
	$Out = StringReplace($Out, 'regedit /s', 'reg import')
	$Out = StringReplace($Out, 'regedit.exe /s', 'reg import')
	Return $Out
EndFunc

Func ConvertToVars($In, $RegPath = False) ; Replace Varibles sent in with Absolute Values
	;If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|ConvertToVars()' & @CRLF)
	Local $Out = $In ; $RegPath = True (for double-slash replacement in registry entries)
	; 'All Users' data
	If @DesktopCommonDir <> '' Then $Out = StringReplace($Out, RegPathConvert(@DesktopCommonDir, $RegPath), '%DesktopCommon%') ;  C:\Documents and Settings\All Users\Desktop		C:\Users\Public\Desktop
	If @FavoritesCommonDir <> '' Then $Out = StringReplace($Out, RegPathConvert(@FavoritesCommonDir, $RegPath), '%FavoritesCommon%') ; C:\Documents and Settings\All Users\Favorites
	If @DocumentsCommonDir <> '' Then $Out = StringReplace($Out, RegPathConvert(@DocumentsCommonDir, $RegPath), '%DocumentsCommon%') ; C:\Documents and Settings\All Users\Documents
	If @StartupCommonDir <> '' Then $Out = StringReplace($Out, RegPathConvert(@StartupCommonDir, $RegPath), '%StartupCommon%'); C:\Documents and Settings\All Users\Start Menu\Programs\Startup
	If @ProgramsCommonDir <> '' Then $Out = StringReplace($Out, RegPathConvert(@ProgramsCommonDir, $RegPath), '%ProgramsCommon%'); C:\Documents and Settings\All Users\Start Menu\Programs
	If @StartMenuCommonDir <> '' Then $Out = StringReplace($Out, RegPathConvert(@StartMenuCommonDir, $RegPath), '%StartmenuCommon%') ; C:\Documents and Settings\All Users\Start Menu
	If @AppDataCommonDir <> '' Then $Out = StringReplace($Out, RegPathConvert(@AppDataCommonDir, $RegPath), '%AppDataCommon%')
	If $AllUsersProfile <> '' Then $Out = StringReplace($Out, RegPathConvert($AllUsersProfile, $RegPath), '%AllUsersProfile%')
	If $PublicPath <> '' Then $Out = StringReplace($Out, RegPathConvert($PublicPath, $RegPath), '%Public%')

	; 'Current User' data.
	If @DesktopDir <> '' Then $Out = StringReplace($Out, RegPathConvert(@DesktopDir, $RegPath), '%Desktop%')
	If @FavoritesDir <> '' Then $Out = StringReplace($Out, RegPathConvert(@FavoritesDir, $RegPath), '%Favorites%')
	If @MyDocumentsDir <> '' Then $Out = StringReplace($Out, RegPathConvert(@MyDocumentsDir, $RegPath), '%MyDocuments%') ;
	If @StartupDir <> '' Then $Out = StringReplace($Out, RegPathConvert(@StartupDir, $RegPath), '%Startup%'); C:\Documents and Settings\{username}\Start Menu\Programs\Startup
	If @ProgramsDir <> '' Then $Out = StringReplace($Out, RegPathConvert(@ProgramsDir, $RegPath), '%Programs%') ; C:\Documents and Settings\{username}\Start Menu\Programs
	If @StartMenuDir <> '' Then $Out = StringReplace($Out, RegPathConvert(@StartMenuDir, $RegPath), '%Startmenu%') ; C:\Documents and Settings\{username}\Start Menu
	If $SendToPath <> '' Then $Out = StringReplace($Out, RegPathConvert($SendToPath, $RegPath), '%SendtoPath%')
	If @AppDataDir <> '' Then $Out = StringReplace($Out, RegPathConvert($QuickLaunch, $RegPath), '%QuickLaunch%')
	If @AppDataDir <> '' Then $Out = StringReplace($Out, RegPathConvert(@AppDataDir, $RegPath), '%AppData%') ; %APPDATA% 	C:\Documents and Settings\{username}\Application Data 	C:\Users\{username}\AppData\Roaming
	If $LocalAppData <> '' Then $Out = StringReplace($Out, RegPathConvert($LocalAppData, $RegPath), '%LocalAppData%') ; %LocalAppData% 	%USERPROFILE%\Local Settings\Application Data 	%UserProfile%\AppData\Local
	If @UserProfileDir <> '' Then $Out = StringReplace($Out, RegPathConvert(@UserProfileDir, $RegPath), '%UserProfile%') ;%USERPROFILE% 	C:\Documents and Settings\{username} 	C:\Users\{username}

	; Default System/Environment data	NT/XP	Vista/7
	If $OSArch64 And $ProgramFilesDir32 And EnvGet('COMMONPROGRAMFILES(x86)') <> '' Then $Out = StringReplace($Out, RegPathConvert(EnvGet('COMMONPROGRAMFILES(x86)'), $RegPath), '%CommonProgramFiles(x86)%')
	If $OSArch64 And $ProgramFilesDir32 Then
		Switch $App_Type
			Case 1, 2
				$Out = StringReplace($Out, RegPathConvert(EnvGet('PROGRAMFILES(X86)'), $RegPath), '%ProgramFiles(x86)%')
				$Out = StringReplace($Out, RegPathConvert('%ppApps%', $RegPath), '%ProgramFiles(x86)%')
				$Out = StringReplace($Out, RegPathConvert('%ppGames%', $RegPath), '%ProgramFiles(x86)%')
			Case 3, 4
				$Out = StringReplace($Out, RegPathConvert(EnvGet('PROGRAMFILES(X86)'), $RegPath), '%ppApps%')
				$Out = StringReplace($Out, RegPathConvert('%ProgramFiles%', $RegPath), '%ppApps%')
				$Out = StringReplace($Out, RegPathConvert('%ProgramFiles(x86)%', $RegPath), '%ppApps%')
				$Out = StringReplace($Out, RegPathConvert('%ppGames%', $RegPath), '%ppApps%')
			Case 5
				$Out = StringReplace($Out, RegPathConvert(EnvGet('PROGRAMFILES(X86)'), $RegPath), '%ppGames%')
				$Out = StringReplace($Out, RegPathConvert('%ProgramFiles%', $RegPath), '%ppGames%')
				$Out = StringReplace($Out, RegPathConvert('%ProgramFiles(x86)%', $RegPath), '%ppGames%')
				$Out = StringReplace($Out, RegPathConvert('%ppApps%', $RegPath), '%ppGames%')
			Case Else
				$Out = StringReplace($Out, RegPathConvert(EnvGet('PROGRAMFILES(X86)'), $RegPath), '%ProgramFiles(x86)%')
		EndSwitch
	EndIf
	If @CommonFilesDir <> '' Then $Out = StringReplace($Out, RegPathConvert(@CommonFilesDir, $RegPath), '%CommonProgramFiles%') ; %COMMONPROGRAMFILES% 	C:\Program Files\Common Files 	C:\Program Files\Common Files @CommonFilesDir
	If @ProgramFilesDir <> '' Then
		Switch $App_Type
			Case 1, 2
				$Out = StringReplace($Out, RegPathConvert(@ProgramFilesDir, $RegPath), '%ProgramFiles%') ;%PROGRAMFILES% 	C:\Program Files 	C:\Program Files
				$Out = StringReplace($Out, RegPathConvert('%ppApps%', $RegPath), '%ProgramFiles%')
				$Out = StringReplace($Out, RegPathConvert('%ppGames%', $RegPath), '%ProgramFiles%')
			Case 3, 4
				$Out = StringReplace($Out, RegPathConvert(@ProgramFilesDir, $RegPath), '%ppApps%') ;%PROGRAMFILES% 	C:\Program Files 	C:\Program Files
				$Out = StringReplace($Out, RegPathConvert('%ProgramFiles%', $RegPath), '%ppApps%')
				$Out = StringReplace($Out, RegPathConvert('%ProgramFiles(x86)%', $RegPath), '%ppApps%')
				$Out = StringReplace($Out, RegPathConvert('%ppGames%', $RegPath), '%ppApps%')
			Case 5
				$Out = StringReplace($Out, RegPathConvert(@ProgramFilesDir, $RegPath), '%ppGames%') ;%PROGRAMFILES% 	C:\Program Files 	C:\Program Files
				$Out = StringReplace($Out, RegPathConvert('%ProgramFiles%', $RegPath), '%ppGames%')
				$Out = StringReplace($Out, RegPathConvert('%ProgramFiles(x86)%', $RegPath), '%ppGames%')
				$Out = StringReplace($Out, RegPathConvert('%ppApps%', $RegPath), '%ppGames%')
			Case Else
				$Out = StringReplace($Out, RegPathConvert(@ProgramFilesDir, $RegPath), '%ProgramFiles%') ;%PROGRAMFILES% 	C:\Program Files 	C:\Program Files
		EndSwitch
	EndIf
	If @TempDir <> '' Then $Out = StringReplace($Out, RegPathConvert(@TempDir, $RegPath), '%TEMP%') ;%TEMP% 	C:\Documents and Settings\{username}\Local Settings\Temp 	C:\Users\{username}\AppData\Local\Temp
	If @HomePath <> '' Then
		If @HomeDrive <> '' Then $Out = StringReplace($Out, RegPathConvert(@HomeDrive & @HomePath, $RegPath), '%HOMEDRIVE%%HOMEPATH%') ; %HOMEDRIVE%%HOMEPATH% 	C:\Documents and Settings\{username} 	C:\Users\{username}
		$Out = StringReplace($Out, RegPathConvert(@HomePath, $RegPath), '%HOMEPATH%') ; %HOMEPATH% 	\Documents and Settings\{username} 	\Users\{username}
	EndIf
	If @ComSpec <> '' Then $Out = StringReplace($Out, RegPathConvert(@ComSpec, $RegPath), '%COMSPEC%') ; %COMSPEC% 	C:\Windows\System32\cmd.exe 	C:\Windows\System32\cmd.exe
	If EnvGet('PATH') <> '' Then $Out = StringReplace($Out, RegPathConvert(EnvGet('PATH'), $RegPath), '%PATH%') ; %PATH% 	C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;{plus program paths} 	C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;{plus program paths}
	If $OSArch64 And $SystemDir32 Then $Out = StringReplace($Out, RegPathConvert(@WindowsDir & '\SYSWOW64', $RegPath), '%SystemDir%') ; So that it will still work on 32-bit systems. 64-bit will automatically convert back to the (x86) ones
	If @SystemDir <> '' Then $Out = StringReplace($Out, RegPathConvert(@SystemDir, $RegPath), '%SystemDir%') ; %SystemDir% 	C:\Windows\System32 	C:\Windows\System32
	If @WindowsDir <> '' Then
		$Out = StringReplace($Out, RegPathConvert(@WindowsDir & '\ssTek', $RegPath), '%ssTekResources%')
		$Out = StringReplace($Out, RegPathConvert(@WindowsDir & '\Resources', $RegPath), '%Resources%')
		$Out = StringReplace($Out, RegPathConvert(@WindowsDir, $RegPath), '%SystemRoot%') ;%SystemRoot% 	C:\Windows 	C:\Windows
	EndIf

	;SetupS vars
	If $ppAppsDrive <> '' Then $Out = StringReplace($Out, RegPathConvert($ppAppsDrive & '\ppApps', $RegPath), '%ppApps%') ; Full path (drive + folder)
	If $ppGamesDrive <> '' Then $Out = StringReplace($Out, RegPathConvert($ppGamesDrive & '\ppGames', $RegPath), '%ppGames%') ; Full path (drive + folder)
	If $SrcPath <> '' Then $Out = StringReplace($Out, RegPathConvert($SrcPath, $RegPath), '%SourcePath%') ; Full path (drive + folder)
	If $ToolsPath <> '' Then $Out = StringReplace($Out, RegPathConvert($ToolsPath, $RegPath), '%Tools%') ; Full path (drive + folder)
	$Out = StringReplace($Out, RegPathConvert('addoninstaller.exe', $RegPath), '%AddonInstaller%')
	$Out = StringReplace($Out, RegPathConvert('addoninstaller ', $RegPath), '%AddonInstaller% ')
	$Out = StringReplace($Out, RegPathConvert('addoninstaller"', $RegPath), '%AddonInstaller%"')
	$Out = StringReplace($Out, RegPathConvert('#AddonInstaller#', $RegPath), '%AddonInstaller%')
	$Out = StringReplace($Out, RegPathConvert('%Tools%\%AddonInstaller%', $RegPath), '%AddonInstaller%')
	$Out = StringReplace($Out, RegPathConvert('pskill.exe', $RegPath), '%ProcessKill%')
	$Out = StringReplace($Out, RegPathConvert('pskill ', $RegPath), '%ProcessKill% ')
	$Out = StringReplace($Out, RegPathConvert('pskill"', $RegPath), '%ProcessKill%"')
	If StringInStr($Out, "taskkill") Then
		$Out = StringReplace($Out, '/F', '')
		$Out = StringReplace($Out, '/IM', '')
		$Out = StringReplace($Out, RegPathConvert('TASKKILL.EXE', $RegPath), '%ProcessKill%')
		$Out = StringReplace($Out, RegPathConvert('TASKKILL ', $RegPath), '%ProcessKill% ')
		$Out = StringReplace($Out, RegPathConvert('TASKKILL"', $RegPath), '%ProcessKill%"')
		$Out = StringReplace($Out, RegPathConvert('#TaskKill#', $RegPath), '%ProcessKill%')
		$Out = StringReplace($Out, RegPathConvert('#KillTask#', $RegPath), '%ProcessKill%')
		$Out = StringReplace($Out, RegPathConvert('%TaskKill%', $RegPath), '%ProcessKill%')
		$Out = StringReplace($Out, RegPathConvert('%KillTask%', $RegPath), '%ProcessKill%')
	EndIf
	$Out = StringReplace($Out, RegPathConvert('ProcessKill.exe', $RegPath), '%ProcessKill%')
	$Out = StringReplace($Out, RegPathConvert('ProcessKill ', $RegPath), '%ProcessKill% ')
	$Out = StringReplace($Out, RegPathConvert('ProcessKill"', $RegPath), '%ProcessKill%"')
	$Out = StringReplace($Out, RegPathConvert('#ProcessKill#', $RegPath), '%ProcessKill%')
	$Out = StringReplace($Out, RegPathConvert('#KillProcess#', $RegPath), '%ProcessKill%')
	$Out = StringReplace($Out, RegPathConvert('%KillProcess%', $RegPath), '%ProcessKill%')
	$Out = StringReplace($Out, RegPathConvert('%Tools%\%ProcessKill%', $RegPath), '%ProcessKill%')
	$Out = StringReplace($Out, RegPathConvert('%Tools%\%KillProcess%', $RegPath), '%ProcessKill%')
	$Out = StringReplace($Out, RegPathConvert('WaitForIt.exe', $RegPath), '%WaitForIt%')
	$Out = StringReplace($Out, RegPathConvert('WaitForIt ', $RegPath), '%WaitForIt% ')
	$Out = StringReplace($Out, RegPathConvert('WaitForIt"', $RegPath), '%WaitForIt%"')
	$Out = StringReplace($Out, RegPathConvert('#WaitForIt#', $RegPath), '%WaitForIt%')
	$Out = StringReplace($Out, RegPathConvert('%Tools%\%WaitForIt%', $RegPath), '%WaitForIt%')
	$Out = StringReplace($Out, RegPathConvert('AddToHosts.exe', $RegPath), '%AddToHosts%')
	$Out = StringReplace($Out, RegPathConvert('AddToHosts ', $RegPath), '%AddToHosts% ')
	$Out = StringReplace($Out, RegPathConvert('AddToHosts"', $RegPath), '%AddToHosts%"')
	$Out = StringReplace($Out, RegPathConvert('#AddToHosts#', $RegPath), '%AddToHosts%')
	$Out = StringReplace($Out, RegPathConvert('%Tools%\%AddToHosts%', $RegPath), '%AddToHosts%')
	$Out = StringReplace($Out, RegPathConvert('7z.exe x -y -aoa', $RegPath), '%Extract%')
	$Out = StringReplace($Out, RegPathConvert('7z.exe x -aoa -y', $RegPath), '%Extract%')
	$Out = StringReplace($Out, RegPathConvert('7z x -y -aoa', $RegPath), '%Extract%')
	$Out = StringReplace($Out, RegPathConvert('7z x -aoa -y', $RegPath), '%Extract%')
	$Out = StringReplace($Out, RegPathConvert('#Extract#', $RegPath), '%Extract%')
	$Out = StringReplace($Out, RegPathConvert('%Tools%\%Extract%', $RegPath), '%Extract%')

	;%ComputerName% @ComputerName
	If @ComputerName <> '' Then
		Select ; special case where ComputerName=Computer
			Case StringInStr($Out, '%' & @ComputerName & 'NAME%')
			Case Else
				$Out = ConvertToVars_Filter($Out, @ComputerName, '%COMPUTERNAME%')
		EndSelect
	EndIf

	;%UserName% @UserName
	If @UserName <> '' Then
		Select ; special case where UserName=User
			Case StringInStr($Out, '%' & @UserName & 'NAME%')
			Case StringInStr($Out, '%' & @UserName & 'PROFILE%')
			Case StringLeft($Out, 1) = '[' And StringRight($Out, 1) = ']' And StringInStr($Out, '_' & @UserName)
			Case StringInStr($Out, 'All ' & @UserName & 's')
			Case StringInStr($Out, 'Default ' & @UserName)
			Case StringInStr($Out, 'NT' & @UserName & '.')
			Case Else
				$Out = ConvertToVars_Filter($Out, @UserName, '%USERNAME%')
		EndSelect
	EndIf
	Return $Out
EndFunc

Func ConvertToVars_Filter($Out, $What, $var)
	;If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|ConvertToVars_Filter()' & @CRLF)
	If StringInStr($Out & '\', '\' & $What & '\') Then
		$Out = StringReplace($Out & '\', '\' & $What & '\', '\' & $var & '\')
		$Out = StringLeft($Out, StringLen($Out) - 1)
	EndIf
	If StringInStr($Out & '"', '"' & $What & '"') Then
		$Out = StringReplace($Out & '"', '"' & $What & '"', '"' & $var & '"')
		$Out = StringLeft($Out, StringLen($Out) - 1)
	EndIf
	If StringInStr($Out & '"', '\' & $What & '"') Then
		$Out = StringReplace($Out & '"', '\' & $What & '"', '\' & $var & '"')
		$Out = StringLeft($Out, StringLen($Out) - 1)
	EndIf
	If StringInStr($Out & '\', '"' & $What & '\') Then
		$Out = StringReplace($Out & '\', '"' & $What & '\', '"' & $var & '\')
		$Out = StringLeft($Out, StringLen($Out) - 1)
	EndIf
	Return $Out
EndFunc

Func CopyMenu($MenuStyle)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|CopyMenu(): $MenuStyle=' & $MenuStyle & @CRLF)
	If $MenuStyle > 0 Then
		Local $i, $Menu = $MenuStyles[$MenuStyle][1], $smStyle = FileGetShortName($ToolsPath & '\Menus\' & $Menu & 'Menu')
		If FileExists($smStyle) And $ToolsPath <> '' Then
			If $BalloonTips Then _TrayTip('Copying:', '"' & $Menu & '" StartMenu Sorting', 30, 17)
			If $SplashTips Then SplashThis('Copying:', '"' & $Menu & '" StartMenu Sorting')
			If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Copying "' & $Menu & '" StartMenu Sorting' & @CRLF)
			$MenuDefinitionINI = $ssTekResources & '\Definitions.ini'
			If Not FileExists($MenuDefinitionINI) Then $MenuDefinitionINI = $smStyle & '\Definitions.ini'
			If FileExists($MenuDefinitionINI) Then
				Local $layout, $IconFile, $IconIndex, $var = IniReadSectionNames($MenuDefinitionINI)
				If IsArray($var) Then
					For $i = 1 To $var[0]
						If Not (($var[$i] = 'Catalog') Or ($var[$i] = 'SetupS Menu')) Then
							;$IconFile = IniRead($ssTekResources & '\Definitions.ini', $var[$i], 'IconFile', '')
							;$IconIndex = IniRead($ssTekResources & '\Definitions.ini', $var[$i], 'IconIndex', '')
							$layout = @ProgramsCommonDir & '\' & $var[$i]
							If Not FileExists($layout) Then
								;NeoIniWrite($layout & '\Desktop.ini', '.ShellClassInfo', 'IconFile', $IconFile)
								;NeoIniWrite($layout & '\Desktop.ini', '.ShellClassInfo', 'IconIndex', $IconIndex)
								CreateMenuDesktopINI($ssTekResources & '\Menu\' & $var[$i], $layout)
							EndIf
						EndIf
					Next
				EndIf
			EndIf
		EndIf
	EndIf
EndFunc

Func CreateFolderDesktopINI($What, $IconLocation, $IconIndex = 0, $IniLocation = '.')
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|CreateFolderDesktopINI(): $What=' & $What & ' : $IconLocation=' & $IconLocation & @CRLF)
	If FileExists($IconLocation & '\' & $What) Then
		If $IniLocation = '.' Then
			$IniLocation = $IconLocation
			$IconLocation = '.'
		EndIf
		If FileExists($IniLocation & '\desktop.ini') Then
			If StringInStr(FileGetAttrib($IniLocation & '\desktop.ini'), "R") Then Return True
			FileSetAttrib(FileGetShortName($IniLocation & '\desktop.ini'), '-SH', 1)
		EndIf
		If IniWriteSection($IniLocation & '\desktop.ini', '.ShellClassInfo', 'ConfirmFileOp=0' & @LF & 'IconFile=' & $IconLocation & '\' & $What & @LF & 'IconIndex=' & $IconIndex) Then
			FileSetAttrib(FileGetShortName($IniLocation & '\desktop.ini'), '+SH', 1)
			RunWait($CLIprefix & 'attrib . +s', $IniLocation, @SW_HIDE)
		EndIf
		Return True
	Else
		Return False
	EndIf
EndFunc

Func CreateMenuDesktopINI($SrcINI, $Where)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|CreateMenuDesktopINI(): $SrcINI=' & $SrcINI & ' : $Where=' & $Where & @CRLF)
	;for some reason, Windows is sometimes finicky when it comes to these desktop.ini files...
	If Not FileExists($Where) Then DirCreate($Where)
	If FileExists($SrcINI & '\desktop.ini') Then
		RunWait($CLIprefix & 'attrib . +s', $Where, @SW_HIDE)
		FileSetAttrib(FileGetShortName($Where & '\desktop.ini'), '-SH', 1)
		Local $i, $DesktopINI = IniReadSectionNames($SrcINI & '\desktop.ini'), $test
		If Not @error Then
			If IsArray($DesktopINI) Then
				For $i = 1 To $DesktopINI[0]
					$test = IniReadSection($SrcINI & '\desktop.ini', $DesktopINI[$i])
					IniWriteSection($Where & '\desktop.ini', $DesktopINI[$i], $test)
				Next
				FileSetAttrib(FileGetShortName($Where & '\desktop.ini'), '+SH', 1)
			EndIf
		Else
			If $Debug Then _ConsoleWriteDebug('@@ Debug(1785) SetupS.Core.au3|CreateMenuDesktopINI() : $SrcINI & "\desktop.ini"=' & $SrcINI & '\desktop.ini' & @CRLF & '>Error code: ' & @error & @CRLF)
		EndIf
	Else
		If (StringMid($SrcINI, StringInStr($SrcINI, '\', -1, -1) + 1) = StringMid($Where, StringInStr($Where, '\', -1, -1) + 1)) Then
			Select
				Case CreateFolderDesktopINI('ssApp.ico', $App_InstallPath, 0, $Where)
				Case CreateFolderDesktopINI('ppApp.ico', $App_InstallPath, 0, $Where)
				Case CreateFolderDesktopINI('ppGame.ico', $App_InstallPath, 0, $Where)
				Case CreateFolderDesktopINI('SetupS.ico', $App_InstallPath, 0, $Where)
			EndSelect
		EndIf
	EndIf
EndFunc

Func DeleteDuplicates($TestPath, $TestFile, $TestExt)
	Local $i, $dups[1]
	$dups = _FileListToArray($TestPath, '*' & $TestExt, 1)
	If Not @error And IsArray($dups) Then
		For $i = 1 To $dups[0]
			If $dups[$i] <> $TestFile And FileCompare($TestPath & '\' & $dups[$i], $TestPath & '\' & $TestFile) Then
				FileDelete($TestPath & '\' & $dups[$i])
			EndIf
		Next
	EndIf
EndFunc

Func DeleteMe($What, $UseRecycleBin = False)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|DeleteMe(): $What=' & $What & ' : $UseRecycleBin=' & $UseRecycleBin & @CRLF)
	Local $Deleted = False
	If FileExists($What) Then
		$What = FileGetShortName($What)
		RemoveRSH($What)
		If StringInStr(FileGetAttrib($What), 'D') Then ; Folder
			If IsSafeDir($What) Then
				RunWait($CLIprefix & 'attrib . -R -S -H', $What, @SW_HIDE)
				FileSetAttrib($What & '\*.*', '-RSH+N', 1)
				Select
					Case $UseRecycleBin And DirRecycle($What)
					Case Not $UseRecycleBin And DirRemove($What, 1)
					Case Else
						RunWait($CLIprefix & 'rd /s /q "' & $What & '"', @ScriptDir, @SW_HIDE)
				EndSelect
				$Deleted = Not FileExists($What)
			EndIf
		Else ; File
			If $UseRecycleBin Then
				FileRecycle($What)
			Else
				FileDelete($What)
			EndIf
			If FileExists($What) Then
				Local $dirAttrib = FileGetAttrib(GetFolderPath($What)), $fnWhat = GetFilename($What), $fpWhat = GetFolderPath($What)
				RunWait($CLIprefix & 'attrib ' & $fnWhat & ' -R -S -H >nul:', $fpWhat, @SW_HIDE)
				RunWait($CLIprefix & 'del /F /Q ' & $fnWhat & ' >nul:', $fpWhat, @SW_HIDE)
				$Deleted = Not FileExists($What)
			Else
				$Deleted = True
			EndIf
		EndIf
	EndIf
	Return $Deleted
EndFunc

Func DirRecycle($What)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|DirRecycle(): $What=' & $What & @CRLF)
	If FileExists($What) Then
		If IsSafeDir($What) Then
			Local $i, $FileList
			$FileList = _FileListToArray($What, '*.*', 2) ; Return folders only
			If @error = 0 Then
				For $i = 1 To $FileList[0]
					DirRecycle($What & '\' & $FileList[$i])
				Next
			EndIf
			$FileList = _FileListToArray($What, '*.*', 1) ; Return files only
			If @error = 0 Then
				For $i = 1 To $FileList[0]
					FileRecycle($What & '\' & $FileList[$i]) ;Recycle File
				Next
			EndIf
			FileRecycle($What) ;Recycle Folder
			Return True
		EndIf
	Else ;Already deleted?
		Return True
	EndIf
	Return False
EndFunc

Func DualArch($EXEname)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|DualArch(): $EXEname=' & $EXEname & @CRLF)
	Local $ProcessName = GetParameter('KillLauncher', '=') Or GetParameter('KillProcess', '='), $Wait
	If ProcessExists($ProcessName) Then ProcessClose($ProcessName)
	$Wait = GetParameter('Wait') Or Not GetParameter('NoWait') ; Comment-out to force default to "NoWait"
	;If GetParameter('NoWait') Then $Wait = False ; Comment-out to force default to "Wait"
	If Not @AutoItX64 Then ; Running 32-bit version
		If @Compiled Then
			If $OSArch64 Then ; Need to switch to 64-bit
				Local $x64exe = FindMe($EXEname & '_x64.exe')
				If FileExists($x64exe) Then
					If $Wait Then
						RunWait('"' & $x64exe & '" ' & ReconstructCmdLine($CLIparameters) & ' -x86PID=' & @AutoItPID, '.', @SW_HIDE)
						Exit
					Else ;NoWait
						Run('"' & $x64exe & '" ' & ReconstructCmdLine($CLIparameters), '.', @SW_HIDE)
						Exit
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		$ThisAppTitle = $ThisAppTitle & ' (x64)'
	EndIf
EndFunc

Func EndGame($Title, $Message, $HelpReq = False, $AutoClose = 1.6, $ErrorMode = False)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|EndGame(): $title=' & $Title & ' : $Message=' & $Message & ' : $ErrorMode=' & $ErrorMode & @CRLF)
	Local $file, $HelpClose = 20
	If $ErrorMode Then
		SplashOff()
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', '2')
		Opt('TrayIconHide', 0) ;Show tray icon
		_TrayTip($Title, '', 30, 17)
		MsgBox(262144, $Title, $Message & @LF & @LF & '(This box will close in ' & $AutoClose & ' seconds)', $AutoClose)
	ElseIf $HelpReq Then
		SplashOff()
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', '2')
		Opt('TrayIconHide', 0) ;Show tray icon
		If FileExists(@ScriptDir & '\' & $ThisAppFilename & '.hlp') Then
			_TrayTip($Title, $Message, 30, 17)
			$HelpFile = @ScriptDir & '\' & $ThisAppFilename & '.hlp'
			;If $BalloonTips Then _TrayTip($Title, $Message, 300, 16)
			If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & $Title & ' ' & $Message & @CRLF)
			$file = FileOpen($HelpFile, 0)
			If $file <> -1 Then
				$Message = FileReadLine($file)
				While @error <> -1
					$Message = $Message & @LF & FileReadLine($file)
				WEnd
			EndIf
			FileClose($file)
			MsgBox(262144, 'Help Request', $Message & @LF & @LF & '(This box will close in ' & $HelpClose & ' seconds)', $HelpClose)
		ElseIf FileExists($HelpFile) Then
			_TrayTip($Title, $Message & @LF & @LF & '(Box will close in ' & $HelpClose & ' seconds)', 300, 16)
			Switch $ThisAppFilename
				Case 'SetupS'
					$HelpTopic = 'SetupSCommands'
				Case 'SetupScp', 'ssControlPanel', 'ssCP'
					$HelpTopic = 'ssControlPanelCommands'
				Case 'Regenerator', 'ssRegenerator', 'ssRegen'
					$HelpTopic = 'ssRegeneratorCommands'
				Case 'ssEditor'
					$HelpTopic = 'CommandLineUsage'
			EndSwitch
			If ProcessExists($Help_PID) Then ProcessClose($Help_PID)
			$Help_PID = Run('hh.exe ' & $HelpFile & '::/' & $HelpTopic & '.html')
			Sleep($HelpClose * 1000)
			If ProcessExists($Help_PID) Then ProcessClose($Help_PID)
		EndIf
	Else
		If $BalloonTips Then _TrayTip($Title, $Message, 30, 17)
		If $SplashTips Then
			SplashThis($Title, $Message)
			Sleep($AutoClose * 1000)
			SplashOff()
		EndIf
		If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & $Title & ' ' & $Message & @CRLF)
	EndIf
	TraySetState(2) ; Hide the tray icon
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', $EnableBalloonTips)
	ErrorProtection('on')
	Exit
EndFunc

Func ErrorProtection($ErrorMode)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|ErrorProtection(): $ErrorMode=' & $ErrorMode & @CRLF)
	Switch $ErrorMode
		Case 'off', 'no', False
			DllCall('kernel32.dll', 'dword', 'SetErrorMode', 'dword', 1) ;SetErrorMode(SEM_FAILCRITICALERRORS) ;Turn Error Protection off
			RegWrite('HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Windows', 'ErrorMode', 'REG_DWORD', '2')
			Return False
		Case 'yes', 'on', True
			DllCall('kernel32.dll', 'dword', 'SetErrorMode', 'dword', 0) ; SEM_FAILCRITICALERRORS ;Turn Error Protection on
			RegWrite('HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Windows', 'ErrorMode', 'REG_DWORD', '0')
			Return True
	EndSwitch
EndFunc

Func FadeInGUI($hForm, $Time) ;$time is in seconds
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|FadeInGUI(): $Time=' & $Time & @CRLF)
	WinSetTrans(ControlGetText('', '', $hForm), "", 0)
	GUISetState(@SW_SHOW, $hForm)
	Local $Timer = TimerInit(), $Title = ControlGetText('', '', $hForm), $delay = $Time * 1000, $trans = 0
	Do
		WinSetTrans($Title, "", $trans)
		$trans = 255 * TimerDiff($Timer) / $delay
	Until $trans >= 255
	WinSetTrans(ControlGetText('', '', $hForm), "", 255)
EndFunc

Func FadeOutGUI($hForm, $Time) ;$time is in seconds
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|FadeOutGUI(): $Time=' & $Time & @CRLF)
	Local $Timer = TimerInit(), $Title = ControlGetText('', '', $hForm), $delay = $Time * 1000, $trans = 255
	If $delay > 0 Then
		Do
			WinSetTrans($Title, '', $trans)
			$trans = 255 - (255 * TimerDiff($Timer) / $delay)
		Until $trans <= 0
		WinSetTrans(ControlGetText('', '', $hForm), "", 0)
	EndIf
	GUISetState(@SW_HIDE, $hForm)
EndFunc

Func FileCompare($File1, $File2) ; Returns True if files are the same
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|FileCompare(): $File1=' & $File1 & ' : $File2=' & $File2 & @CRLF)
	Local $line, $i = @ScriptDir & '\fc_list.txt', $found = False
	RunWait($CLIprefix & 'fc /b "' & $File1 & '" "' & $File2 & '" >"' & $i & '"', '.', @SW_HIDE)
	Local $file = FileOpen($i, 0)
	If $file <> -1 Then
		Local $EndOfFile = False
		Do ; Read in lines of text until the EOF is reached
			$line = FileReadLine($file)
			$EndOfFile = (@error = -1)
			If StringInStr($line, 'FC: no differences encountered') Then
				$found = True
				$EndOfFile = True
			EndIf
		Until $EndOfFile
	EndIf
	FileClose($file)
	FileDelete($i)
	Return $found
EndFunc

;$Details[0] = Shortcut target path
;$Details[1] = Working directory
;$Details[2] = Arguments
;$Details[3] = Description
;$Details[4] = Icon filename
;$Details[5] = Icon index
;$Details[6] = The shortcut state(@SW_SHOWNORMAL, @SW_SHOWMINNOACTIVE, @SW_SHOWMAXIMIZED)
;$Details[7] = Hotkey (using the Send() key format)
Func FileGetShortcutEx($link)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|FileGetShortcutEx(): $link=' & $link & @CRLF)
	If $link = '' Then Return SetError(1)
	Local $Details = FileGetShortcut($link)
	If @error Or Not IsArray($Details) Then Return SetError(1)
	ReDim $Details[UBound($Details) + 1]
	Local $Hotkey = Number(StringToBinary(StringMid(FileRead($link, 68), 65, 4)))
	Local $AutoItHotkey = GetHotkey($Hotkey)
	Local $DisplayHotkey = GetHotkey($Hotkey, True)
	$Details[7] = $AutoItHotkey
	Local $msitest = MSIShortcutTarget($link)
	If Not @error Then
		$Details[0] = $msitest
	Else
		If $Debug Then _ConsoleWriteDebug('@@ Debug(1386) SetupS.Core.au3|FileGetShortcutEx(): $link=' & $link & @CRLF & '>Error code: ' & @error & @CRLF)
	EndIf
	Return $Details
EndFunc

Func FindMe($What)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|FindMe(): $What=' & $What & @CRLF)
	Local $i = '', $j = ''
	If StringInStr(FileGetAttrib($SrcPath), 'D') = 0 Then ;File
		$j = GetFolderPath($SrcPath)
	Else ;Folder
		$j = NoBackslash($SrcPath)
	EndIf
	Select
		Case FileExists($ssTekResources & '\' & $What)
			$i = $ssTekResources & '\' & $What
		Case FileExists(@ScriptDir & '\' & $What) ;Current
			$i = @ScriptDir & '\' & $What
		Case FileExists(@ScriptDir & '\Tools\' & $What) ;Child
			$i = @ScriptDir & '\Tools\' & $What
		Case FileExists(@ScriptDir & '\..\' & $What) ;Parent
			$i = @ScriptDir & '\..\' & $What
		Case FileExists(@ScriptDir & '\..\Tools\' & $What) ;Sibling
			$i = @ScriptDir & '\..\Tools\' & $What
		Case FileExists(@ProgramFilesDir & '\' & $cSetupSFolder & '\Tools\' & $What)
			$i = @ProgramFilesDir & '\' & $cSetupSFolder & '\Tools\' & $What
		Case FileExists(@ProgramFilesDir & '\' & $cSetupSFolder & '\' & $What)
			$i = @ProgramFilesDir & '\' & $cSetupSFolder & '\' & $What
		Case $OSArch64 And FileExists(EnvGet('programfiles(x86)') & '\' & $cSetupSFolder & '\Tools\' & $What)
			$i = EnvGet('programfiles(x86)') & '\' & $cSetupSFolder & '\Tools\' & $What
		Case $OSArch64 And FileExists(EnvGet('programfiles(x86)') & '\' & $cSetupSFolder & '\' & $What)
			$i = EnvGet('programfiles(x86)') & '\' & $cSetupSFolder & '\' & $What
		Case FileExists($j & '\Tools\' & $What)
			$i = $j & '\Tools\' & $What
		Case FileExists($j & '\..\Tools\' & $What)
			$i = $j & '\..\Tools\' & $What
		Case FileExists($j & '\..\' & $What)
			$i = @ScriptDir & '\..\' & $What
		Case FileExists($j & '\' & $What)
			$i = $j & '\' & $What
		Case FileExists($CDDrive & '\MyOEM\ssWPI\Tools\' & $What)
			$i = $CDDrive & '\MyOEM\ssWPI\Tools\' & $What
		Case FileExists(@ScriptDir & '\Licenses\' & $What) ;Child
			$i = @ScriptDir & '\Licenses\' & $What
		Case FileExists(@ScriptDir & '\..\Licenses\' & $What) ;Sibling
			$i = @ScriptDir & '\..\Licenses\' & $What
		Case FileExists($ppAppsDrive & '\ppApps\' & $cSetupSFolder & '\Tools\' & $What)
			$i = $ppAppsDrive & '\ppApps\' & $cSetupSFolder & '\Tools\' & $What
		Case FileExists($ppAppsDrive & '\ppApps\' & $cSetupSFolder & '\' & $What)
			$i = $ppAppsDrive & '\ppApps\' & $cSetupSFolder & '\' & $What
		Case FileExists($ppGamesDrive & '\ppApps\' & $cSetupSFolder & '\Tools\' & $What)
			$i = $ppGamesDrive & '\ppApps\' & $cSetupSFolder & '\Tools\' & $What
		Case FileExists($ppGamesDrive & '\ppApps\' & $cSetupSFolder & '\' & $What)
			$i = $ppGamesDrive & '\ppApps\' & $cSetupSFolder & '\' & $What
;~ 		Case FileExists(EnvGet('PATH') & '\' & $What) Then
;~ 			$i = EnvGet('PATH') & '\' & $What
	EndSelect
	If $i = '' Then
		Return $i
	Else
		Return _PathFull($i)
	EndIf
EndFunc

Func GenerateTempFolder($What = ''); get a new unique temp folder (derived from the system one)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GenerateTempFolder()' & @CRLF)
	If $What <> '' Then DeleteMe($What)
	$What = _TempFile()
	Return FileGetShortName(StringLeft($What, StringLen($What) - 4))
EndFunc

Func GetAlternateDistribution($Defaults)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetAlternateDistribution(): $Defaults=' & $Defaults & @CRLF)
	Local $i, $AltDistrLink = ''
	If FileExists($Defaults) Then $AltDistr[0][0] = IniRead($Defaults, 'AlternateDistribution', 'Count', '0')
	If $AltDistr[0][0] > 0 Then
		ReDim $AltDistr[$AltDistr[0][0] + 1][2]
		$AltDistrLink = IniRead($Defaults, 'AlternateDistribution', 'Data', '')
		$AltDistrOrder = SingleLine2Multi(IniRead($Defaults, 'AlternateDistribution', 'Order', ''), '|')
		If $AltDistrLink <> '' Then
			For $i = 1 To $AltDistr[0][0]
				$AltDistr[$i][0] = IniRead($Defaults, $AltDistrLink & $i, 'Link', '')
				$AltDistr[$i][1] = IniRead($Defaults, $AltDistrLink & $i, 'Parm', '')
			Next
		EndIf
	EndIf
	$RepoLink = IniRead($Defaults, 'Repo', 'Primary', 'http://www.lastos.org')
	$BackupRepoLink = IniRead($Defaults, 'Repo', 'Backup', 'http://sstek.vergitek.com')
	If $RepoLink = $BackupRepoLink Then
		$RepoLink = 'http://www.lastos.org'
		$BackupRepoLink = 'http://sstek.vergitek.com'
	EndIf
	$RepoFolder = IniRead($Defaults, 'Repo', 'Folder', 'files')
	If $RepoLink & $BackupRepoLink = '' Then $NoUpdate = True
EndFunc

Func GetApp_smSource($App_smSource)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetApp_smSource(): $App_smSource=' & $App_smSource & @CRLF)
	Select
		Case $App_Title <> '' ; Based on <Title>
			$App_smSource = StringFilterFilename($App_Title)
		Case $App_InstallPath <> '' ; Based on <AppPath>
			$App_smSource = StringReplace(GetFilename($App_InstallPath), '.', ' ')
		Case $App_scCount > 0 ; Based on the name of the first <ShortcutS>
			$App_smSource = StringReplace(GetFilename($App_scLNK[1]), '.', ' ')
		Case $App_scKeep[0] > 0 ; Based on the name of the first <ShortCutNamesKeep>
			$App_smSource = StringReplace(GetFilename($App_scKeep[1]), '.', ' ')
		Case $SrcPath <> '' ; Based on the "parent" folder passed from "Sendto"
			$App_smSource = StringReplace(GetFilename($SrcPath), '.', ' ')
		Case Else ; Based on the "parent" folder of the current working folder
			$App_smSource = StringReplace(GetFilename(@WorkingDir), '.', ' ')
	EndSelect
	If $App_smSource = '' Then ; need a random folder name prefixed with "SetupS~"
		$App_smSource = GetFilename(GenerateTempFolder())
	EndIf
	Return $App_smSource
EndFunc

Func GetAppPathComplete($App_InstallPath)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetAppPathComplete(): $App_InstallPath=' & $App_InstallPath & @CRLF)
	If $App_InstallPath = '' Then $App_InstallPath = ConvertFromVars(ConvertToVars('%ProgramFiles%'))
	If NormalizeInstallPath($App_InstallPath) = '' Then
		Select
			Case $App_Title <> '' ; Based on <Title>
				$App_InstallPath = NoBackslash($App_InstallPath) & '\' & StringReplace(StringFilterFilename($App_Title), ' ', '.')
			Case $App_smSource <> '' ; Based on <StartMenuSourcePath>
				$App_InstallPath = NoBackslash($App_InstallPath) & '\' & StringReplace(GetFilename($App_smSource), ' ', '.')
			Case $App_scCount > 0 ; Based on the name of the first <ShortcutS>
				$App_InstallPath = NoBackslash($App_InstallPath) & '\' & StringReplace(GetFilename($App_scLNK[1]), ' ', '.')
			Case $App_scKeep[0] > 0 ; Based on the name of the first <ShortCutNamesKeep>
				$App_InstallPath = NoBackslash($App_InstallPath) & '\' & StringReplace(GetFilename($App_scKeep[1]), ' ', '.')
			Case $SrcPath <> '' ; Based on the "parent" folder passed from "Sendto"
				$App_InstallPath = NoBackslash($App_InstallPath) & '\' & StringReplace(GetFilename($SrcPath), ' ', '.')
			Case Else ; Based on the "parent" folder of the current working folder
				$App_InstallPath = NoBackslash($App_InstallPath) & '\' & StringReplace(GetFilename(@WorkingDir), ' ', '.')
		EndSelect
	EndIf
	If NormalizeInstallPath($App_InstallPath) = '' Then ; need a random folder name prefixed with "_SetupS~"
		$App_InstallPath = NoBackslash($App_InstallPath) & '\_SetupS' & GetFilename(GenerateTempFolder())
	EndIf
	Return $App_InstallPath
EndFunc

Func GetAppPathFrom($shortcut)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetAppPathFrom(): $shortcut=' & $shortcut & @CRLF)
	; $App_InstallPath is Global
	If $App_InstallPath = '' Then $App_InstallPath = GetAppPathViaShortcut($shortcut)
	Return ($App_InstallPath <> '')
EndFunc

Func GetAppPathFromUninstall(ByRef $aUninstall, $What = '')
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetAppPathFromUninstall(): $What=' & $What & @CRLF)
	If IsArray($aUninstall) Then
		Local $i, $j, $found = False, $test = ''
		If $What <> '' Then
			For $i = 1 To $aUninstall[0][0]
				If StringInStr($aUninstall[$i][0], $What) Or StringInStr($aUninstall[$i][1], $What) Then
					$test = GetPathFromUninstall($aUninstall, $i)
					ExitLoop
				EndIf
			Next
		EndIf
		If $test = '' Then
			For $i = 1 To $aUninstall[0][0]
				$test = GetPathFromUninstall($aUninstall, $i)
				If $test <> '' Then ExitLoop
			Next
		EndIf
		Return ConvertFromVars(ConvertToVars($test))
	Else
		Return ''
	EndIf
EndFunc

Func GetAppPathViaFolder($What)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetAppPathViaFolder(): $What=' & $What & @CRLF)
	; Recursively scan shortcuts folder ($What)
	; $App_InstallPath is Global
	Local $i, $j, $FileList, $Path, $Target = ''
	If FileExists($What) Then
		$FileList = _FileListToArray($What, '*.lnk', 1) ; Return files only
		If @error > 0 Then
			$FileList = _FileListToArray($What, '*.*', 2) ; Return folders only
			If @error > 0 Then Return ''
			For $j = 1 To $FileList[0]
				$Target = GetAppPathViaFolder($What & '\' & $FileList[$j])
				If $Target <> '' Then
					For $i = $j To $FileList[0]
						$Path = GetAppPathViaFolder($What & '\' & $FileList[$i])
						If $Path <> '' Then
							If StringLen($Path) < StringLen($Target) Then $Target = $Path
						EndIf
					Next
					ExitLoop
				EndIf
			Next
		Else
			For $j = 1 To $FileList[0]
				$Target = GetAppPathViaShortcut($What & '\' & $FileList[$j])
				If $Target <> '' Then ExitLoop
			Next
		EndIf
	EndIf
	Return $Target
EndFunc

Func GetAppPathViaShortcut($Shortcut, $exeTest = True)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetAppPathViaShortcut(): $Shortcut=' & $Shortcut & ' : $exeTest=' & $exeTest & @CRLF)
	If FileExists($Shortcut) Then
		Local $Target = FileGetShortcutEx($Shortcut)
		If @error = 0 And IsArray($Target) Then
			If $exeTest Then
				Local $test = StringLower(StringMid($Target[0], StringInStr($Target[0], '.', -1, -1) + 1))
				If $test = 'exe' Or $test = 'com' Or $test = 'cmd' Or $test = 'bat' Then
					Return GetFolderPath($Target[0])
				EndIf
			Else
				Return GetFolderPath($Target[0])
			EndIf
		EndIf
	EndIf
	Return ''
EndFunc

Func GetAppTypeBase($App_Type)
	;If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetAppTypeBase(): $App_Type=' & $App_Type & @CRLF)
	Local $App_TypeBase
	Switch $App_Type
		Case 1
			$App_TypeBase = 'SetupS'
		Case 2
			$App_TypeBase = 'ssApp'
		Case 3, 4
			$App_TypeBase = 'ppApp'
		Case 5
			$App_TypeBase = 'ppGame'
	EndSwitch
	Return $App_TypeBase
EndFunc

Func GetFaderMode($Defaults)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetFaderMode(): $Defaults=' & $Defaults & @CRLF)
	Local $test
	If FileExists($Defaults) Then ;Get default settings
		$Fadertainer = IniRead_Binary($Defaults, 'Fadertainer', 'Activate', 'No')
		$FaderSpeed = IniRead($Defaults, 'Fadertainer', 'Speed', '.5')
		$FaderLocation = IniRead($Defaults, 'Fadertainer', 'Location', '')
		$FaderModule = IniRead($Defaults, 'Fadertainer', 'Module', '')
		$FaderOnTop = IniRead_Binary($Defaults, 'Fadertainer', 'AlwaysOnTop', 'Yes')
		$FaderInstallsOnly = IniRead($Defaults, 'Fadertainer', 'DuringInstallsOnly', '')
		If $FaderInstallsOnly = '' Then
			$FaderInstallsOnly = IniRead($Defaults, 'Regenerator', 'FaderInstallsOnly', 'Yes')
			NeoIniWrite($Defaults, 'Fadertainer', 'DuringInstallsOnly', $FaderInstallsOnly)
		EndIf
		$FaderInstallsOnly = ($FaderInstallsOnly = 'Yes') Or ($FaderInstallsOnly = '1') Or ($FaderInstallsOnly = 'True') Or ($FaderInstallsOnly = 'On')
	EndIf
	$test = GetParameter('Fadertainer', '=')
	If $test <> '' Then
		$Fadertainer = ($test = 'Yes') Or ($test = '1') Or ($test = 'True') Or ($test = 'On')
	EndIf
	$test = GetParameter('FaderSpeed', '=')
	If $test <> '' Then
		$FaderSpeed = $test
	EndIf
	$test = GetParameter('FaderLocation', '=')
	If $test <> '' Then
		$FaderLocation = $test
	EndIf
	$test = GetParameter('FaderOnTop', '=')
	If $test <> '' Then
		$FaderOnTop = ($test = 'Yes') Or ($test = '1') Or ($test = 'True') Or ($test = 'On')
	EndIf
	$test = GetParameter('FaderInstallsOnly', '=')
	If $test <> '' Then
		$FaderInstallsOnly = ($test = 'Yes') Or ($test = '1') Or ($test = 'True') Or ($test = 'On')
	EndIf
	$test = GetParameter('FaderModule', '=')
	If $test <> '' Then
		$FaderModule = $test
	EndIf
EndFunc

Func GetFileFromArchive($What, $Archive)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetFileFromArchive(): $What=' & $What & ' : $Archive=' & $Archive & @CRLF)
	Local $switches = 'e -r0 '
	If StringInStr($What, '*') Or StringInStr($What, '?') Then $switches = 'x -y -aoa '
	RunWait($CLIprefix & '7z ' & $switches & '"' & $Archive & '" -o"' & $TempDir & '" ' & $What, '', @SW_HIDE)
	If StringInStr($What, '*') Or StringInStr($What, '?') Then
		Return FileExists($TempDir & '\')
	Else
		Return FileExists($TempDir & '\' & $What)
	EndIf
EndFunc

Func GetFilename($What)
	;If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetFilename(): $What=' & $What & @CRLF)
	If StringInStr($What, '/', -1, -1) Then Return StringRight($What, StringLen($What) - StringInStr($What, '/', -1, -1))
	Return StringRight($What, StringLen($What) - StringInStr($What, '\', -1, -1))
EndFunc

Func GetFolderPath($What)
	;If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetFolderPath(): $What=' & $What & @CRLF)
	If StringInStr($What, '/', -1, -1) Then Return StringLeft($What, StringInStr($What, '/', -1, -1) - 1)
	Return StringLeft($What, StringInStr($What, '\', -1, -1) - 1)
EndFunc

Func GetHotkey($What, $Display = False)
;~ 	ConsoleWrite("Shortcut key = 0x" & Hex($What, 4) & ", Upper byte = 0x" & Hex(BitShift($What, 8), 2) & @CRLF)
	Local $sAutoItModifiers = _KeyModifiersToString(BitShift($What, 8)); Upper byte required for this
	Local $sModifiers = _KeyModifiersToString(BitShift($What, 8), False); False for this call to get the full descriptive key combination
	Local $cChar = _KeyVirtualKeyToChar(BitAND($What, 0xFF)); Mask off the virtual-key code (lower byte)
;~ 	ConsoleWrite("Modifiers: " & $sModifiers & ", Char: '" & $cChar & "', AutoIt Send() Sequence = """ & $sAutoItModifiers & $cChar & '"' & @CRLF)
	If $Display Then
;~ 		Local $test = SetHotKey($sModifiers & '+' & $cChar)
		If $sModifiers & $cChar = '' Then Return ''
		Return $sModifiers & '+' & $cChar
	Else
		If Not StringInStr($sModifiers, "shift") Then $cChar = StringLower($cChar)
		Return $sAutoItModifiers & $cChar
	EndIf
EndFunc

Func GetInstallPath($Original)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetInstallPath(): $Original=' & $Original & @CRLF)
	Local $line = NormalizeInstallPath(ConvertFromVars($Original)), $found = ($line <> '')
	If $Original <> '' And $found Then
		Switch $App_Type
			Case 1, 2
				Select
					Case FileExists(@ProgramFilesDir & '\' & $line)
						$App_InstallPath = @ProgramFilesDir & '\' & $line
						If $App_Architecture = 0 Then
							If @AutoItX64 Then
								$App_Architecture = 2
							Else
								$App_Architecture = 1
							EndIf
						EndIf
						$found = True
					Case FileExists(EnvGet('ProgramFiles(x86)') & '\' & $line)
						$App_InstallPath = EnvGet('ProgramFiles(x86)') & '\' & $line
						If $App_Architecture = 0 And @AutoItX64 Then $App_Architecture = 1
						$found = True
					Case FileExists(@WindowsDir & '\' & $line)
						$App_InstallPath = @WindowsDir & '\' & $line
						$found = True
					Case FileExists(@SystemDir & '\' & $line)
						$App_InstallPath = @SystemDir & '\' & $line
						If $App_Architecture = 0 Then
							If @AutoItX64 Then
								$App_Architecture = 2
							Else
								$App_Architecture = 1
							EndIf
						EndIf
						$found = True
					Case FileExists(@WindowsDir & '\SYSWOW64\' & $line)
						$App_InstallPath = @WindowsDir & '\SYSWOW64\' & $line
						If $App_Architecture = 0 And @AutoItX64 Then $App_Architecture = 1
						$found = True
					Case FileExists(@CommonFilesDir & '\' & $line)
						$App_InstallPath = @CommonFilesDir & '\' & $line
						$found = True
					Case FileExists(EnvGet('COMMONPROGRAMFILES(x86)') & '\' & $line)
						$App_InstallPath = EnvGet('COMMONPROGRAMFILES(x86)') & '\' & $line
						If $App_Architecture = 0 And @AutoItX64 Then $App_Architecture = 1
						$found = True
					Case FileExists($SystemDrive & '\' & $line)
						$App_InstallPath = $SystemDrive & '\' & $line
						$found = True
					Case Else
				EndSelect
			Case 3, 4
				Select
					Case FileExists($ppAppsDrive & '\ppApps\' & StringFilterFilename($line, True))
						$App_InstallPath = $ppAppsDrive & '\ppApps\' & StringFilterFilename($line, True)
						$found = True
				EndSelect
			Case 5
				Select
					Case FileExists($ppGamesDrive & '\ppGames\' & StringFilterFilename($line, True))
						$App_InstallPath = $ppGamesDrive & '\ppGames\' & StringFilterFilename($line, True)
						$found = True
				EndSelect
		EndSwitch
	EndIf
	If Not $found Then $App_InstallPath = ''
	If ($found And Not FileExists($App_InstallPath)) Or Not $found Then ; <AppPath> is either bogus or blank
		; the following uses shortcuts to find where App is actually installed
		If $App_scKeep[0] > 0 Then
			Select
				Case GetAppPathFrom(@ProgramsCommonDir & '\' & $App_smSource & '\' & $App_scKeep[1] & '.lnk'); from All Users Start Menu (source)
				Case GetAppPathFrom(@ProgramsCommonDir & '\' & $App_scKeep[1] & '.lnk'); from All Users Start Menu (Programs/root)
				Case GetAppPathFrom(@ProgramsDir & '\' & $App_smSource & '\' & $App_scKeep[1] & '.lnk'); from Current User Start Menu (source)
				Case GetAppPathFrom($GamesProgramsDir & '\' & $App_smSource & '\' & $App_scKeep[1] & '.lnk') And $App_Type = 5
				Case GetAppPathFrom(@ProgramsDir & '\' & $App_scKeep[1] & '.lnk'); from Current User Start Menu (Programs/root)
				Case GetAppPathFrom(@DesktopCommonDir & '\' & $App_scKeep[1] & '.lnk'); from All Users Desktop
				Case GetAppPathFrom(@DesktopDir & '\' & $App_scKeep[1] & '.lnk'); from Current User Desktop
				Case GetAppPathFrom(@StartupCommonDir & '\' & $App_scKeep[1] & '.lnk'); from All Users Startup
				Case GetAppPathFrom(@StartupDir & '\' & $App_scKeep[1] & '.lnk'); from Current User Startup
				Case GetAppPathFrom($SendToPath & '\' & $App_scKeep[1] & '.lnk'); from Current User SendTo
				Case GetAppPathFrom($QuickLaunch & '\' & $App_scKeep[1] & '.lnk'); from Current User QuickLaunch
			EndSelect
		EndIf
		If $App_smSource <> '' And Not FileExists($App_InstallPath) Then ; recursively scan the starmenu source folders:
			Select
				Case FileExists(@ProgramsCommonDir & '\' & $App_smSource); from All Users Start Menu (source)
					$App_InstallPath = GetAppPathViaFolder(@ProgramsCommonDir & '\' & $App_smSource)
				Case FileExists(@ProgramsDir & '\' & $App_smSource); from Current User Start Menu (source)
					$App_InstallPath = GetAppPathViaFolder(@ProgramsDir & '\' & $App_smSource)
					If $App_Type = 5 And Not FileExists($App_InstallPath) Then $App_InstallPath = GetAppPathViaFolder($GamesProgramsDir & '\' & $App_smSource)
			EndSelect
		EndIf
	EndIf
	If FileExists($App_InstallPath) And NormalizeInstallPath($App_InstallPath) <> '' And Not StringInStr($App_InstallPath, 'nonething') Then
		Return True
	Else
		$App_InstallPath = $Original
		Return False
	EndIf
EndFunc

Func GetMenuDefs($MenuStyle)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetMenuDefs()' & @CRLF)
	Local $MenuDefinitionINI
	If $MenuStyles[0][0] = 0 Or $MenuStyles[0][0] = '' Then GetMenuStyles() ;Array
	If FileExists($ToolsPath) Then $MenuDefinitionINI = $ToolsPath & '\Menus\' & $MenuStyles[$MenuStyle][1] & 'Menu\Definitions.ini'
	If Not FileExists($MenuDefinitionINI) Then $MenuDefinitionINI = ''
	Return $MenuDefinitionINI
EndFunc

Func GetMenuStyle() ; Get StartMenu/Sorting Style
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetMenuStyle()' & @CRLF)
	Local $line, $file
	If $MenuStyles[0][0] = 0 Or $MenuStyles[0][0] = '' Then GetMenuStyles() ;Array
	If FileExists(@WindowsDir & '\SetupSMenu.ini') Then
		$line = IniRead(@WindowsDir & '\SetupSMenu.ini', 'SetupS Menu', 'Style', '')
		If $line = '' Then
			$file = FileOpen(@WindowsDir & '\SetupSMenu.ini', 0)
			$line = StringStripWS(FileReadLine($file), 3)
			FileClose($file)
		EndIf
		If $line <> '' Then
			For $i = 1 To $MenuStyles[0][0]
				If ($line = $MenuStyles[$i][1]) Then $MenuStyle = $MenuStyles[$i][0]
			Next
			If $MenuStyle = 0 Then
				Switch $line
					Case 'LastXP', 'LastOS', 'ssTek'
						$MenuStyle = $MenuStyles[1][0]
					Case 'Kazz'
						$MenuStyle = $MenuStyles[2][0]
				EndSwitch
			EndIf
		EndIf
	EndIf
	If $MenuStyle > 0 Then
		$MenuDefinitionINI = $ssTekResources & '\Definitions.ini'
		If Not FileExists($MenuDefinitionINI) Then
			If FileExists($ToolsPath) Then
				$MenuDefinitionINI = $ToolsPath & '\Menus\' & $MenuStyles[$MenuStyle][1] & 'Menu\Definitions.ini'
				If Not FileExists($MenuDefinitionINI) Then $MenuDefinitionINI = $MenuDefinitionINI = $ToolsPath & '\Menus\' & $MenuStyles[1][1] & 'Menu\Definitions.ini'
			EndIf
			If Not FileExists($MenuDefinitionINI) Then
				$MenuDefinitionINI = ''
				$MenuStyle = 0
			EndIf
		EndIf
	EndIf
	SetMenuStyle($MenuStyle)
EndFunc

Func GetMenuStyles()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetMenuStyles()' & @CRLF)
	$MenuStylesINI = $ToolsPath & '\Menus\MenuStyles.ini'
	If FileExists($MenuStylesINI) Then
		$MenuStyles = IniReadSection($MenuStylesINI, 'Styles')
		$MenuStyles[0][1] = 'Standard'
	Else ; use legacy sorting
		ReDim $MenuStyles[3][2]
		$MenuStyles[0][0] = 2
		$MenuStyles[1][0] = 1
		$MenuStyles[2][0] = 2
		$MenuStyles[0][1] = 'Standard'
		$MenuStyles[1][1] = 'LastOS'
		$MenuStyles[2][1] = 'Kazz'
	EndIf
EndFunc

Func GetOpticalDrive()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetOpticalDrive()' & @CRLF)
	Local $i, $found, $Drive, $file
	;ErrorProtection('off')
	; Check System Varibles
	If $HomeDrv = '' Then $HomeDrv = 'C:'
	If $SystemDrive = '' Then $SystemDrive = 'C:'

	; Get CD Drive (if any)
	If FileExists(@WindowsDir & '\SetupSCDDrive.ini') Then FileDelete(@WindowsDir & '\SetupSCDDrive.ini')
	If IsArray($CDDrivesList) Then
		If $CDDrivesList[0] > 0 Then
			For $Drive = 1 To $CDDrivesList[0]
;~ 				If FileExists($CDDrivesList[$Drive] & '\ssWPICD.ini') Then
				If $CDDrivesList[$Drive] = StringLeft(@ScriptDir, 2) Then ; Residing drive is on a CD-ROM
					$CDDrive = $CDDrivesList[$Drive]
					ExitLoop
				EndIf
			Next
		EndIf
	EndIf
	If $CDDrive = '' Or Not FileExists($CDDrive) Then ;pick the first available one
		If IsArray($CDDrivesList) Then
			If $CDDrivesList[0] > 0 Then
				$CDDrive = $CDDrivesList[1]
			Else
				$CDDrive = $SystemDrive
			EndIf
		Else
			$CDDrive = $SystemDrive
		EndIf
	EndIf
	$CDDrive = NoBackslash($CDDrive)
	;ErrorProtection('on')
EndFunc

Func GetParameter($What, $Delim = '')
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetParameter(): $What=' & $What & ' : $Delim=' & $Delim & @CRLF)
	Local $i, $j, $Start = 1, $value ; $CLIparameters is Global
	If IsArray($CLIparameters) And $CLIparameters[0] > 0 Then
		If FileExists($CLIparameters[1]) Then $Start = 2; Need to skip over first parameter in case path/filename contains a recognized parameter
		For $i = $Start To $CLIparameters[0]
			If StringInStr($CLIparameters[$i], '-' & $What & $Delim) > 0 Or StringInStr($CLIparameters[$i], '/' & $What & $Delim) > 0 Then
				If $Delim <> '' Then
					$value = StringMid($CLIparameters[$i], StringInStr($CLIparameters[$i], $Delim) + 1)
				EndIf
				For $j = $i To $CLIparameters[0] - 1
					$CLIparameters[$j] = $CLIparameters[$j + 1]
				Next
				ReDim $CLIparameters[$CLIparameters[0]]
				$CLIparameters[0] -= 1
				If $Delim = '' Then
					Return True
				Else
					Return $value
				EndIf
			EndIf
		Next
	EndIf
	If $Delim = '' Then
		Return False
	Else
		Return ''
	EndIf
EndFunc

Func GetPathFromUninstall(ByRef $aUninstall, $i)
	Local $test = '', $aTest
	Select
		Case $aUninstall[$i][2] <> '' ; From InstallLocation
			$test = NoBackslash(StringReplace($aUninstall[$i][2], '"', ''))
		Case $aUninstall[$i][3] <> '' ; From DisplayIcon
			$test = NoBackslash(GetFolderPath(StringReplace($aUninstall[$i][3], '"', '')))
		Case $aUninstall[$i][4] <> '' ; From UninstallString
			If StringInStr($aUninstall[$i][4], '"') Then
				$aTest = StringSplit($aUninstall[$i][4], '"', 1)
				If @error = 0 And FileExists($aTest[2]) Then $test = NoBackslash(GetFolderPath($aTest[2]))
			Else
				$aTest = StringSplit($aUninstall[$i][4], ' ', 1)
				If @error = 0 And FileExists($aTest[1]) Then $test = NoBackslash(GetFolderPath($aTest[1]))
			EndIf
	EndSelect
	Return $test
EndFunc

Func GetppDrives()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetppDrives()' & @CRLF)
	Local $i, $found, $Drive, $file, $LoopStart = $AllDrivesList[0], $LoopStop = 1
	If $ppDrivesScanDirection = 1 Then
		$LoopStart = 1
		$LoopStop = $AllDrivesList[0]
	EndIf
	;ErrorProtection('off')
	; Check System Varibles
	If $HomeDrv = '' Then $HomeDrv = 'C:'
	If $SystemDrive = '' Then $SystemDrive = 'C:'

	; Get the ppApps Drive letter
	If FileExists(@WindowsDir & '\ppAppDrive.ini') Then
		$file = FileOpen(@WindowsDir & '\ppAppDrive.ini', 0)
		$ppAppsDrive = StringUpper(ConvertFromVars(FileReadLine($file)))
		FileClose($file)
	EndIf
	If $ppAppsDrive = '' Or Not FileExists($ppAppsDrive) Then
		For $Drive = $LoopStart To $LoopStop Step $ppDrivesScanDirection
			If FileExists($AllDrivesList[$Drive] & '\ppApps') Then
				$found = False
				If IsArray($CDDrivesList) Then
					For $i = 1 To $CDDrivesList[0]
						If ($AllDrivesList[$Drive] = $CDDrivesList[$i]) Then
							$found = True
							ExitLoop
						EndIf
					Next
				EndIf
				If Not $found Then
					$ppAppsDrive = $AllDrivesList[$Drive]
					$file = FileOpen(@WindowsDir & '\ppAppDrive.ini', 2)
					FileWriteLine($file, StringUpper(ConvertToVars($ppAppsDrive)))
					FileClose($file)
					ExitLoop
				EndIf
			EndIf
		Next
	Else
	EndIf
	If $ppAppsDriveMove Then
		If ($ppAppsDrive <> $ppAppsDriveMove) Then
			$ppDriveOld = $ppAppsDrive
			$ppAppsDrive = $ppAppsDriveMove
		EndIf
	EndIf
	If $ppAppsDrive = '' Then $ppAppsDrive = $SystemDrive ;& '\'

	; Get the ppGames Drive letter
	If FileExists(@WindowsDir & '\ppGameDrive.ini') Then
		$file = FileOpen(@WindowsDir & '\ppGameDrive.ini', 0)
		$ppGamesDrive = StringUpper(ConvertFromVars(FileReadLine($file)))
		FileClose($file)
	EndIf
	If $ppGamesDrive = '' Or Not FileExists($ppGamesDrive) Then
		For $Drive = $LoopStart To $LoopStop Step $ppDrivesScanDirection
			If FileExists($AllDrivesList[$Drive] & '\ppGames') Then
				$found = False
				If IsArray($CDDrivesList) Then
					For $i = 1 To $CDDrivesList[0]
						If ($AllDrivesList[$Drive] = $CDDrivesList[$i]) Then
							$found = True
							ExitLoop
						EndIf
					Next
				EndIf
				If Not $found Then
					$ppGamesDrive = $AllDrivesList[$Drive]
					$file = FileOpen(@WindowsDir & '\ppGameDrive.ini', 2)
					FileWriteLine($file, StringUpper(ConvertToVars($ppGamesDrive)))
					FileClose($file)
					ExitLoop
				EndIf
			EndIf
		Next
	EndIf
	If $ppGamesDriveMove Then
		If ($ppGamesDrive <> $ppGamesDriveMove) Then
			$ppDriveOld = $ppGamesDrive
			$ppGamesDrive = $ppGamesDriveMove
		EndIf
	EndIf
	If $ppGamesDrive = '' Then $ppGamesDrive = $SystemDrive ;& '\'
	$ppAppsDrive = NoBackslash($ppAppsDrive)
	$ppGamesDrive = NoBackslash($ppGamesDrive)
	;ErrorProtection('on')
EndFunc

Func GetRegeneratorMode($Defaults)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetRegeneratorMode(): $Defaults=' & $Defaults & @CRLF)
	Local $test
	If FileExists($Defaults) Then ;Get default settings
;~ 		$FaderInstallsOnly = IniRead($Defaults, 'Regenerator', 'FaderInstallsOnly', 'Yes')
		$RegenAllDrives = IniRead_Binary($Defaults, 'Regenerator', 'AllDrives', 'No')
	EndIf
	$test = GetParameter('AllDrives', '=')
	If $test <> '' Then
		$RegenAllDrives = ($test = 'Yes') Or ($test = '1') Or ($test = 'True') Or ($test = 'On')
	EndIf
EndFunc

Func GetReportingMode($Defaults)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetReportingMode(): $Defaults=' & $Defaults & @CRLF)
	Local $found = False, $test
	If FileExists($Defaults) Then ;Get default settings
		$Mute = IniRead_Binary($Defaults, 'Reporting Mode', 'Mute', 'No')
		$TrayOnly = IniRead_Binary($Defaults, 'Reporting Mode', 'TrayOnly', 'No')
		$SplashOnly = IniRead_Binary($Defaults, 'Reporting Mode', 'SplashOnly', 'No')
		Select ; Status reporting mode
			Case $Mute
				$SplashTips = False
				$BalloonTips = False
			Case $TrayOnly
				$SplashTips = False
				$BalloonTips = True
			Case $SplashOnly
				$SplashTips = True
				$BalloonTips = False
			Case Else ; Verbose
				$SplashTips = True
				$BalloonTips = True
		EndSelect
		$SplashOnTop = IniRead_Binary($Defaults, 'Reporting Mode', 'SplashOnTop', 'No')
		$Debug = IniRead_Binary($Defaults, 'Reporting Mode', 'Debug', 'No')
		$Log = IniRead_Binary($Defaults, 'Reporting Mode', 'Log', 'No')
		$found = True
	EndIf
	Select ; Get switch settings (Supersedes the default ones)
		Case GetParameter('Verbose')
			$SplashTips = True
			$BalloonTips = True
		Case GetParameter('Mute') Or GetParameter('Quiet') Or GetParameter('Silent')
			$SplashTips = False
			$BalloonTips = False
		Case GetParameter('TrayOnly')
			$SplashTips = False
			$BalloonTips = True
		Case GetParameter('SplashOnly')
			$SplashTips = True
			$BalloonTips = False
	EndSelect
	SetReportingFlags()
	$test = GetParameter('Debug')
	If $test <> '' Then $Debug = ($test = 'Yes') Or ($test = '1') Or ($test = 'True') Or ($test = 'On')
	$test = GetParameter('Log')
	If $test <> '' Then $Log = ($test = 'Yes') Or ($test = '1') Or ($test = 'True') Or ($test = 'On')
	$test = GetParameter('SplashOnTop', '=')
	If $test <> '' Then
		$SplashOnTop = ($test = 'Yes') Or ($test = '1') Or ($test = 'True') Or ($test = 'On')
	EndIf
	Return $found
EndFunc

Func GetScMode($Defaults)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetScMode(): $Defaults=' & $Defaults & @CRLF)
	If FileExists($Defaults) Then ;Get default settings
		$ssAppsShortcutsSkip = IniRead_Binary($Defaults, 'Process Without Shortcuts', 'ssApps', 'No')
		$ppAppsShortcutsSkip = IniRead_Binary($Defaults, 'Process Without Shortcuts', 'ppApps', 'No')
		$ppGamesShortcutsSkip = IniRead_Binary($Defaults, 'Process Without Shortcuts', 'ppGames', 'No')
	EndIf
	; Get switch settings (Supersedes the default ones)
	If GetParameter('ssAppsShortcutsSkip') Or GetParameter('ssAppShortcutsSkip') Or GetParameter('ssAppShortcutSkip') Or GetParameter('ssAppsShortcutSkip') Then
		$ssAppsShortcutsSkip = True
	EndIf
	If GetParameter('ppAppsShortcutsSkip') Or GetParameter('ppAppShortcutsSkip') Or GetParameter('ppAppShortcutSkip') Or GetParameter('ppAppsShortcutSkip') Then
		$ppAppsShortcutsSkip = True
	EndIf
	If GetParameter('ppGamesShortcutsSkip') Or GetParameter('ppGameShortcutsSkip') Or GetParameter('ppGameShortcutSkip') Or GetParameter('ppGamesShortcutSkip') Then
		$ppGamesShortcutsSkip = True
	EndIf
EndFunc

Func GetSetupSOptions($Defaults)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetSetupSOptions(): $Defaults=' & $Defaults & @CRLF)
	Local $test, $parmlist, $i
	If FileExists($Defaults) Then ;Get default settings
		$SafeInstall = IniRead_Binary($Defaults, 'Options', 'SafeInstall', 'Yes')
		$ssUninstall = IniRead_Binary($Defaults, 'Options', 'ssUninstall', 'No')
		$AutoUpdate = IniRead_Binary($Defaults, 'Options', 'AutoUpdate', 'No')
		$SkipOSArch = IniRead_Binary($Defaults, 'Options', 'SkipOSArch', 'Yes')
		$KeepStartMenuFolders = IniRead_Binary($Defaults, 'Options', 'KeepStartMenuFolders', 'No')
		$KeepStartMenuDefaults = IniRead_Binary($Defaults, 'Options', 'KeepStartMenuDefaults', '')
		If $KeepStartMenuDefaults = '' Or $KeepStartMenuDefaults = 'Default' Then $KeepStartMenuDefaults = $MetroPresent
		Switch IniRead($Defaults, 'Options', 'DualArchInstalls', 'b')
			Case 'b', 'Type 2b', 'Type2b', '2b'
				$DualArchInstalls = 'b'
			Case 'a', 'Type 2a', 'Type2a', '2a'
				$DualArchInstalls = 'a'
			Case Else
				$DualArchInstalls = 'b'
		EndSwitch
		Switch IniRead($Defaults, 'Options', 'ppDrivesScanDirection', 'Backwards')
			Case 'forward', 'forwards', 'up', '+', 'ascend', 'ascending', '1'
				$ppDrivesScanDirection = 1
			Case Else
				$ppDrivesScanDirection = -1
		EndSwitch
		Switch IniRead($Defaults, 'ssCleaning', 'DudShortcuts', '')
			Case 'off', 'no', 'never'
				$ssCleaner = 0
			Case 'All', 'AllShortcuts'
				$ssCleaner = 2
			Case Else
				$ssCleaner = 1
		EndSwitch
		$ssCleanRemovedMenuItem = IniRead_Binary($Defaults, 'ssCleaning', 'RemovedMenuItem', 'Yes')
		$ssCleanerDeleteDudAppPath = IniRead_Binary($Defaults, 'ssCleaning', 'DudAppPaths', 'No')
		$ssCleanerDeleteUninstalled = IniRead_Binary($Defaults, 'ssCleaning', 'Uninstalled', 'No')
		$remDesktop = IniRead_Binary($Defaults, 'Remove Pre-existing', 'Desktop', 'Yes')
		$remQuickLaunch = IniRead_Binary($Defaults, 'Remove Pre-existing', 'QuickLaunch', 'Yes')
		$remProgramsRoot = IniRead_Binary($Defaults, 'Remove Pre-existing', 'ProgramsRoot', 'Yes')
		$remSendto = IniRead_Binary($Defaults, 'Remove Pre-existing', 'Sendto', 'No')
		$remStartup = IniRead_Binary($Defaults, 'Remove Pre-existing', 'Startup', 'Yes')
		$remStartmenuRoot = IniRead_Binary($Defaults, 'Remove Pre-existing', 'StartmenuRoot', 'Yes')
		$remStartmenuPin = IniRead_Binary($Defaults, 'Remove Pre-existing', 'StartmenuPin', 'No')
		$remTaskbarPin = IniRead_Binary($Defaults, 'Remove Pre-existing', 'TaskbarPin', 'No')
	EndIf
	$test = GetParameter('AutoUpdate', '=')
	If $test <> '' Then
		If FileExists($test) Then
			DeleteMe($test)
			$AutoUpdate = False
			$AutoUpdateReturn = 1
		Else
			$AutoUpdate = ($test = 'Yes') Or ($test = '1') Or ($test = 'True') Or ($test = 'On')
		EndIf
	EndIf
	$test = GetParameter('SafeInstall', '=')
	If $test <> '' Then
		$SafeInstall = ($test = 'Yes') Or ($test = '1') Or ($test = 'True') Or ($test = 'On')
	EndIf
	$test = GetParameter('SkipOSArch', '=')
	If $test <> '' Then
		$SkipOSArch = ($test = 'Yes') Or ($test = '1') Or ($test = 'True') Or ($test = 'On')
	EndIf
	$test = GetParameter('KeepStartmenuFolders', '=')
	If $test <> '' Then
		Switch $test
			Case 'off', 'no', 'false', '0', 'never'
				$KeepStartMenuFolders = False
			Case 'on', 'yes', 'true', '1', 'always'
				$KeepStartMenuFolders = True
		EndSwitch
	Else
		If GetParameter('KeepStartmenuFolders') Then
			$KeepStartMenuFolders = True
		EndIf
	EndIf
	$test = GetParameter('KeepStartMenuDefaults', '=')
	If $test <> '' Then
		Switch $test
			Case 'off', 'no', 'false', '0', 'never'
				$KeepStartMenuDefaults = False
			Case 'on', 'yes', 'true', '1', 'always'
				$KeepStartMenuDefaults = True
		EndSwitch
	Else
		If GetParameter('KeepStartMenuDefaults') Then
			$KeepStartMenuFolders = True
		EndIf
	EndIf
	$test = GetParameter('ppDrivesScanDirection', '=')
	If $test <> '' Then
		Switch $test
			Case 'forward', 'forwards', 'up', '+', 'ascend', 'ascending', '1'
				$ppDrivesScanDirection = 1
			Case Else
				$ppDrivesScanDirection = -1
		EndSwitch
	EndIf
	$test = GetParameter('ssCleanOptions', '=')
	If $test = '' Then $test = GetParameter('ssCleaningOptions', '=')
	If $test = '' Then $test = GetParameter('ssCleanerOptions', '=')
	If $test <> '' Then
		$parmlist = StringSplit($test, ',')
		For $i = 1 To $parmlist[0]
			Switch $parmlist[$i]
				Case 'off', 'no', 'never'
					$ssCleaner = 0
				Case 'Startmenu', 'StartmenuOnly'
					$ssCleaner = 1
				Case 'All', 'AllShortcuts'
					$ssCleaner = 2
				Case 'DudAppPaths', 'DudInstallPaths'
					$ssCleanerDeleteDudAppPath = True
				Case 'Uninstalled', 'DeepScan'
					$ssCleanerDeleteUninstalled = True
				Case 'NotDudAppPaths', 'NotDudInstallPaths'
					$ssCleanerDeleteDudAppPath = False
				Case 'NotUninstalled', 'NoDeepScan'
					$ssCleanerDeleteUninstalled = False
			EndSwitch
		Next
		Switch $ssCleaner
			Case 0
				NeoIniWrite($Defaults, 'ssCleaning', 'DudShortcuts', 'Never')
			Case 1
				NeoIniWrite($Defaults, 'ssCleaning', 'DudShortcuts', 'StartmenuOnly')
			Case 2
				NeoIniWrite($Defaults, 'ssCleaning', 'DudShortcuts', 'AllShortcuts')
			Case 3
				NeoIniWrite($Defaults, 'ssCleaning', 'DudShortcuts', 'Default')
		EndSwitch
		NeoIniWrite($Defaults, 'ssCleaning', 'DudAppPaths', $ssCleanerDeleteDudAppPath)
		NeoIniWrite($Defaults, 'ssCleaning', 'Uninstalled', $ssCleanerDeleteUninstalled)
	EndIf
	$test = GetParameter('ssClean', '=')
	If $test = '' Then $test = GetParameter('ssCleaning', '=')
	If $test = '' Then $test = GetParameter('ssCleaner', '=')
	If $test <> '' Then
		$ssClean_enforced = True
		$parmlist = StringSplit($test, ',')
		For $i = 1 To $parmlist[0]
			Switch $parmlist[$i]
				Case 'off', 'no', 'never'
					$ssCleaner = 0
				Case 'Startmenu', 'StartmenuOnly'
					$ssCleaner = 1
				Case 'All', 'AllShortcuts'
					$ssCleaner = 2
				Case 'DudAppPaths', 'DudInstallPaths'
					$ssCleanerDeleteDudAppPath = True
				Case 'Uninstalled', 'DeepScan'
					$ssCleanerDeleteUninstalled = True
				Case 'NotDudAppPaths', 'NotDudInstallPaths'
					$ssCleanerDeleteDudAppPath = False
				Case 'NotUninstalled', 'NoDeepScan'
					$ssCleanerDeleteUninstalled = False
			EndSwitch
		Next
	ElseIf GetParameter('ssClean') Or GetParameter('ssCleaning') Or GetParameter('ssCleaner') Then
		$ssCleaner = 1
	EndIf
EndFunc

Func GetShortcutS($Where)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetShortcutS(): $Where=' & $Where & @CRLF)
	;recursive function to populate
	;Global $App_scXXXXX arrays
	;with shortcuts from a folder passed via $Where
	;ie, GetShortcutS($TempDir & '\' & $scFolder)
	Local $i, $j, $found, $var, $FileList, $Path, $Details, $error
	If FileExists($Where) Then
		$FileList = _FileListToArray($Where, '*.lnk', 1) ; Return files only
		If @error = 0 Then
			For $i = 1 To $FileList[0]
				$Details = FileGetShortcutEx($Where & '\' & $FileList[$i])
				$error = @error
				If StringLen($TempDir & '\' & $scFolder) = StringLen($Where) Then
					$var = StringLeft($FileList[$i], StringInStr($FileList[$i], '.lnk') - 1)
				Else
					$var = StringMid($Where, StringLen($TempDir & '\' & $scFolder) + 2) & '\' & StringLeft($FileList[$i], StringInStr($FileList[$i], '.lnk') - 1)
				EndIf
				$found = False
				For $j = 1 To $App_scCount
					If ($var = $App_scLNK[$j]) Then
						$found = True
						ExitLoop
					EndIf
				Next
				If $error = 0 And IsArray($Details) And Not $found Then
					$App_scCount += 2
					ReDim $App_scEXE[$App_scCount] ;[UBound($App_scEXE) + 1]
					ReDim $App_scWorkDir[$App_scCount] ;[UBound($App_scWorkDir) + 1]
					ReDim $App_scLNK[$App_scCount] ;[UBound($App_scLNK) + 1]
					ReDim $App_scDesc[$App_scCount] ;[UBound($App_scDesc) + 1]
					ReDim $App_scArgs[$App_scCount] ;[UBound($App_scArgs) + 1]
					ReDim $App_scIcon[$App_scCount] ;[UBound($App_scIcon) + 1]
					ReDim $App_scExt[$App_scCount] ;[UBound($App_scExt) + 1]
					ReDim $App_scIndex[$App_scCount] ;[UBound($App_scIcon) + 1]
					ReDim $App_scState[$App_scCount] ;[UBound($App_scIcon) + 1]
					ReDim $App_scDefaults[$App_scCount]
					ReDim $App_scFlags[$App_scCount]
					ReDim $App_scCatalog[$App_scCount]
					ReDim $App_scKey[$App_scCount]
					$App_scCount -= 1
					$App_scEXE[$App_scCount] = $Details[0] ;Shortcut target path
					$App_scWorkDir[$App_scCount] = $Details[1] ;Working directory
					If StringLen($TempDir & '\' & $scFolder) = StringLen($Where) Then ;Display Name
						$App_scLNK[$App_scCount] = StringLeft($FileList[$i], StringInStr($FileList[$i], '.lnk') - 1)
					Else
						$App_scLNK[$App_scCount] = StringMid($Where, StringLen($TempDir & '\' & $scFolder) + 2) & '\' & StringLeft($FileList[$i], StringInStr($FileList[$i], '.lnk') - 1)
					EndIf
					$App_scArgs[$App_scCount] = $Details[2] ;Arguments
					$App_scDesc[$App_scCount] = $Details[3] ;Comment/Description
					$App_scIcon[$App_scCount] = $Details[4] ;Icon filename
					$App_scIndex[$App_scCount] = $Details[5] ;Icon index
					$App_scState[$App_scCount] = $Details[6] ;shortcut state
					$App_scKey[$App_scCount] = $Details[7] ;Hotkey
				EndIf
			Next
		EndIf
		$FileList = _FileListToArray($Where, '*.*', 2) ; Return folders only
		If @error = 0 Then
			For $i = 1 To $FileList[0]
				GetShortcutS($Where & '\' & $FileList[$i])
			Next
		EndIf
	EndIf
EndFunc

Func GetSrcPath(ByRef $SrcPath)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetSrcPath(): $SrcPath=' & $SrcPath & @CRLF)
	; Get the Source Path from anything left 'in' the command line
	; This should be invoked only after all other possible parameters
	; have been retrieved or accounted for.
	; Returns true if SetupS files found.
	Local $found = False, $i, $FileList, $temp, $Drive, $Dir, $FName, $Ext
	If $CLIparameters[0] = 0 Then $SrcPath = @ScriptDir ; Command line was empty so use current path.
	For $i = 1 To $CLIparameters[0]
		$SrcPath = $SrcPath & ' ' & StringReplace(ConvertFromVars($CLIparameters[$i]), '*', '&')
	Next
	$SrcPath = _PathFull(StringStripWS($SrcPath, 3))
	If StringInStr(FileGetAttrib($SrcPath), 'D') = 0 Then ;File
		$temp = _PathSplit($SrcPath, $Drive, $Dir, $FName, $Ext);0 = original path, 1 = drive, 2 = directory, 3 = filename, 4 = extension
		Switch $Ext
			Case '.app'
				Switch $FName
					Case 'SetupS', 'ssApp', 'ppApp'
						$SrcPath = NoBackslash($temp[1] & $temp[2])
						$found = True
				EndSwitch
			Case '.ppg'
				Switch $FName
					Case 'ppGame'
						$SrcPath = NoBackslash($temp[1] & $temp[2])
						$found = True
				EndSwitch
			Case '.ini'
				Switch $FName
					Case 'SetupS', 'ppApp'
						$SrcPath = NoBackslash($temp[1] & $temp[2])
						$found = True
				EndSwitch
			Case '.apz', '.pgz', '.rar', '.7z', '.zip', '.cab', '.arj', '.z', '.exe', '.lnk'
				$SrcPath = NoBackslash($temp[0])
				$found = True
		EndSwitch
	Else ;Folder
		$FileList = _FileListToArray($SrcPath, '*.*', 1)
		If @error = 0 Then
			For $i = 1 To $FileList[0]
				$temp = _PathSplit($SrcPath & '\' & $FileList[$i], $Drive, $Dir, $FName, $Ext);0 = original path, 1 = drive, 2 = directory, 3 = filename, 4 = extension
				Switch $Ext
					Case '.app'
						Switch $FName
							Case 'SetupS', 'ssApp', 'ppApp'
								$SrcPath = NoBackslash($temp[1] & $temp[2])
								$found = True
						EndSwitch
					Case '.ppg'
						Switch $FName
							Case 'ppGame'
								$SrcPath = NoBackslash($temp[1] & $temp[2])
								$found = True
						EndSwitch
					Case '.ini'
						Switch $FName
							Case 'SetupS', 'ppApp'
								$SrcPath = NoBackslash($temp[1] & $temp[2])
								$found = True
						EndSwitch
				EndSwitch
				If $found Then ExitLoop
			Next
		EndIf
	EndIf
	Return $found
EndFunc

Func GetToolsFolder()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetToolsFolder()' & @CRLF)
	$Tools = _PathSplit(FindMe('Tools.ico'), $ToolsDrive, $ToolsDir, $7zFName, $7zExt);0 = original path, 1 = drive, 2 = directory, 3 = filename, 4 = extension
	;$7zEXE = FileGetShortName($Tools[0])
	If IsArray($Tools) Then
		If FileExists($Tools[0]) Then
			$ToolsDir = FileGetShortName(NoBackslash($ToolsDir))
			$ToolsPath = $ToolsDrive & $ToolsDir
			If Not StringInStr(EnvGet('Path'), $ToolsPath) Then EnvSet('path', $ToolsPath & ';' & EnvGet('path'))
			;_PathSet('System', $ToolsPath, 'Add')
			;DualArch capability (SetupS as ppApp):
			If $OSArch64 Then
				If FileExists($ToolsPath & '\_x64') Then
					$Tools_OSArch = FileGetShortName($ToolsPath & '\_x64')
				ElseIf FileExists($ToolsPath & '\_x86') Then
					$Tools_OSArch = FileGetShortName($ToolsPath & '\_x86')
				EndIf
			Else
				If FileExists($ToolsPath & '\_x86') Then $Tools_OSArch = FileGetShortName($ToolsPath & '\_x86')
			EndIf
			If $Tools_OSArch <> '' Then EnvSet('path', $Tools_OSArch & ';' & EnvGet('path'))
			;If $Tools_OSArch <> '' Then _PathSet('System', $Tools_OSArch, 'Add')
			Return True
		EndIf
	EndIf
	Return False
EndFunc

Func GetUninstallData($App_InstallPath)
	Local $arr[1][7], $value, $key, $i, $j, $var, $test, $constr = 'ssControlPanel -uninstall="'
	If $Sys_Uninstall[0][0] = 0 Then $Sys_Uninstall = UninstallEnum()
	For $i = 1 To $Sys_Uninstall[0][0]
		$j = FileGetShortName(GetPathFromUninstall($Sys_Uninstall, $i))
		If $j = FileGetShortName($App_InstallPath) Then
			$var = $Sys_Uninstall[$i][0]
			ExitLoop
		EndIf
	Next
	$arr[0][0] = 0 ; first row=count, 'key' thereafter
	$arr[0][1] = 'DisplayName'
	$arr[0][2] = 'InstallLocation'
	$arr[0][3] = 'DisplayIcon'
	$arr[0][4] = 'UninstallString'
	$arr[0][5] = 'Switches'
	$arr[0][6] = 'Script'
	If $var <> '' Then $key = GetUninstallKey($var, $value)
	If $key <> '' And $value <> '' Then
		$arr[0][0] += 1
		$i = $arr[0][0]
		ReDim $arr[$i + 1][7]
		$arr[$i][0] = $var
		For $j = 1 To 4
			$arr[$i][$j] = RegRead($key, $arr[0][$j])
		Next
		$test = RegRead($key, 'QuietUninstallString')
		If $test <> '' Then $arr[$i][5] = $test
		$test = RegRead($key, 'ssUninstallRecovery')
		If $ssUninstall And $App_ssUninstall Then
			$arr[$i][6] = $constr & $App_InstallPath & '"'
			If StringInStr($arr[$i][4], $constr) Then
				If $test <> '' Then
					$arr[$i][4] = $test
				ElseIf $arr[$i][5] <> '' And Not StringInStr($arr[$i][5], $constr) Then
					$arr[$i][4] = $arr[$i][5]
					$arr[$i][4] = StringReplace($arr[$i][4], ' /SILENT', '')
					$arr[$i][4] = StringReplace($arr[$i][4], ' /qn', '')
					$arr[$i][4] = StringReplace($arr[$i][4], ' /qb', '')
				EndIf
			EndIf
			RegWrite($key, 'ssUninstallRecovery', 'REG_SZ', ConvertFromVars($arr[$i][4]))
			RegWrite($key, 'UninstallString', 'REG_SZ', ConvertFromVars($arr[$i][6]))
		Else
			If RegRead($key, 'ssUninstallRecovery') <> '' Then RegWrite($key, 'UninstallString', 'REG_SZ', ConvertFromVars(RegRead($key, 'ssUninstallRecovery')))
			RegDelete($key, 'ssUninstallRecovery')
		EndIf
	EndIf
	Return $arr
EndFunc

Func GetUninstallKey($What, ByRef $value, $ssUninstallCheck = False)
	Local $key = '', $name = 'UninstallString'
	If $ssUninstallCheck Then $name = 'ssUninstallRecovery'
	$value = RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' & '\' & $What, $name)
	If $value <> '' Then
		$key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' & '\' & $What
	ElseIf @AutoItX64 Then
		$value = RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' & '\' & $What, $name)
		If $value <> '' Then $key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' & '\' & $What
	EndIf
	Return $key
EndFunc

Func GetVersionFromTitle()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetVersionFromTitle()' & @CRLF)
	Local $i, $j, $AppValue, $temp, $found
	$found = False
	$temp = StringSplit($App_Title, ' ')
	If IsArray($temp) Then
		$found = False
		For $i = 2 To $temp[0]
			If StringIsDigit(StringLeft($temp[$i], 1)) Then
				$App_Version = 'v' & $temp[$i]
				$found = True
			Else
				$AppValue = StringInStr($temp[$i], 'v.')
				If $AppValue > 0 Then
					$AppValue = StringMid($temp[$i], $AppValue + 2, 1)
					If StringIsDigit($AppValue) Then
						$App_Version = $temp[$i]
						$found = True
					EndIf
				EndIf
				If Not $found Then
					$AppValue = StringInStr($temp[$i], 'v')
					If $AppValue > 0 Then
						$AppValue = StringMid($temp[$i], $AppValue + 1, 1)
						If StringIsDigit($AppValue) Then
							$App_Version = $temp[$i]
							$found = True
						EndIf
					EndIf
				EndIf
			EndIf
			If $found Then
				$App_Title = $temp[1]
				For $j = 2 To $i - 1
					$App_Title = $App_Title & ' ' & $temp[$j]
				Next
				For $j = $i + 1 To $temp[0]
					$App_Version = $App_Version & ' ' & $temp[$j]
				Next
				ExitLoop
			EndIf
		Next
	EndIf
EndFunc

Func GetVersionNumber($What, $Pos = 1)
	Local $a = StringSplit(StringMid($What, StringInStr($What, 'v') + 1), '.')
	If IsArray($a) And $a[0] >= $Pos Then Return $a[$Pos]
	Return ''
EndFunc

Func HelpReq()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|HelpReq()' & @CRLF)
	If ProcessExists($Help_PID) Then ProcessClose($Help_PID)
	If $HelpTopic = '' Then
		$Help_PID = Run('hh.exe ' & $HelpFile)
	Else
		$Help_PID = Run('hh.exe ' & $HelpFile & '::/' & $HelpTopic & '.html')
	EndIf
EndFunc

Func IniRead_Binary($IniFile, $IniSection, $IniKey, $IniDefault)
	Local $val = IniRead($IniFile, $IniSection, $IniKey, $IniDefault)
	Return ($val = 'Yes') Or ($val = '1') Or ($val = 'True') Or ($val = 'On')
EndFunc

Func InstallMenu($MenuStyle)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|InstallMenu(): $MenuStyle=' & $MenuStyle & @CRLF)
	If FileExists($ssTekResources) Then ; tabula rasa
		DeleteMe($ssTekResources & '\Menu')
		DeleteMe($ssTekResources & '\Icons')
		DeleteMe($ssTekResources & '\Definitions.ini')
		DeleteMe(@StartupDir & '\Desktop.ini')
		DeleteMe(@StartupCommonDir & '\Desktop.ini')
	EndIf
	If $MenuStyle > 0 Then
		Local $i, $Menu = $MenuStyles[$MenuStyle][1], $smStyle = FileGetShortName($ToolsPath & '\Menus\' & $Menu & 'Menu')
		If FileExists($smStyle) And $ToolsPath <> '' Then
			If $BalloonTips Then _TrayTip('Installing:', '"' & $Menu & '" StartMenu Sorting', 30, 17)
			If $SplashTips Then SplashThis('Installing:', '"' & $Menu & '" StartMenu Sorting')
			If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Installing "' & $Menu & '" StartMenu Sorting' & @CRLF)
			If FileExists($smStyle & '\Icons.exe') Then
				RunWait($smStyle & '\Icons.exe', @ScriptDir)
			Else
				RunWait($CLIprefix & '7z x -y -aoa "' & $smStyle & '\Icons.7z" -o"' & $ssTekResources & '\Icons"', @WorkingDir, @SW_HIDE)
			EndIf
			$MenuDefinitionINI = $ssTekResources & '\Definitions.ini'
			NeoFileCopy($smStyle & '\Definitions.ini', $MenuDefinitionINI)
			If Not FileExists($MenuDefinitionINI) Then $MenuDefinitionINI = $smStyle & '\Definitions.ini'
			If FileExists($MenuDefinitionINI) Then
				Local $layout, $IconFile, $IconIndex, $var = IniReadSectionNames($MenuDefinitionINI)
				If IsArray($var) Then
					For $i = 1 To $var[0]
						If Not (($var[$i] = 'Catalog') Or ($var[$i] = 'SetupS Menu')) Then
							$IconFile = IniRead($ssTekResources & '\Definitions.ini', $var[$i], 'IconFile', '')
							$IconIndex = IniRead($ssTekResources & '\Definitions.ini', $var[$i], 'IconIndex', '')
							$layout = $ssTekResources & '\Menu\' & $var[$i]
							DirCreate($layout)
							NeoIniWrite($layout & '\Desktop.ini', '.ShellClassInfo', 'IconFile', $IconFile)
							NeoIniWrite($layout & '\Desktop.ini', '.ShellClassInfo', 'IconIndex', $IconIndex)
						EndIf
					Next
					CreateMenuDesktopINI($ssTekResources & '\Menu\Startup', @StartupDir)
					CreateMenuDesktopINI($ssTekResources & '\Menu\Startup', @StartupCommonDir)
				EndIf
			EndIf
		EndIf
	Else
		If $BalloonTips Then _TrayTip('Installing:', '"Standard" StartMenu Sorting', 300, 16)
		If $SplashTips Then SplashThis('Installing:', '"Standard" StartMenu Sorting')
		If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Installing "Standard" StartMenu Sorting' & @CRLF)
	EndIf
	TraySetState(2) ; Hide the tray icon
	SetMenuStyle($MenuStyle)
EndFunc

Func IsAssocFile($line, $Ext)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|IsAssocFile(): $Line=' & $line & @CRLF)
	Local $SpaceFound = StringInStr($line, ' ', 0, 1), $QuoteFound = StringInStr($line, '"')
	Select
		Case $SpaceFound > 0 And $QuoteFound = 0 ;parameter space used after (potential) single path/file such as .msi
			$line = StringLeft($line, $SpaceFound - 1)
		Case $SpaceFound < $QuoteFound ;parameter space used so is not a single path/file
			$line = ''
		Case ($SpaceFound = 0 And $QuoteFound > 0) Or ($SpaceFound > $QuoteFound)
			$line = StringMid($line, $QuoteFound + 1, StringInStr($line, '"', 0, 1, $QuoteFound + 1) - $QuoteFound - 1)
	EndSelect
	Return StringRight($line, 4) = $Ext
EndFunc

Func IsSafeDir($What)
	Switch $What ; CANNOT delete if
		Case @WindowsDir & '\SYSWOW64'
		Case @SystemDir
		Case EnvGet('COMMONPROGRAMFILES(x86)')
		Case EnvGet('PROGRAMFILES(X86)')
		Case @ProgramFilesDir
		Case @WindowsDir
		Case @UserProfileDir
		Case @AppDataDir
		Case @AppDataCommonDir
		Case @DesktopDir
		Case @DesktopCommonDir
		Case @MyDocumentsDir
		Case @DocumentsCommonDir
		Case @FavoritesDir
		Case @FavoritesCommonDir
		Case @HomeDrive & @HomePath
		Case @HomeShare
		Case @TempDir
		Case @ComSpec
		Case @SystemDir & '\ShellExt'
		Case Else
			Return True
	EndSwitch
	Return False
EndFunc

Func MakeSafeFilename($n, $What)
	Local $Unsafe = StringInStr($n, $What)
	While $Unsafe > 0
		$n = StringLeft($n, $Unsafe - 1) & '-' & StringMid($n, $Unsafe + 1)
		$Unsafe = StringInStr($n, $What)
	WEnd
	Return $n
EndFunc

Func MSIShortcutTarget($link)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|MSIShortcutTarget(): $link=' & $link & @CRLF)
	Local Const $MsiDllName = 'msi.dll'
	Local Const $INSTALLSTATE_ABSENT = 2;   ;// uninstalled
	Local Const $INSTALLSTATE_LOCAL = 3;   ;// installed on local drive
	Local Const $INSTALLSTATE_SOURCE = 4;   ;// run from source, CD or net
	Local Const $INSTALLSTATE_SOURCEABSENT = -4;   ;// run from source, source is unavailable
	Local Const $INSTALLSTATE_NOTUSED = -7;   ;// component disabled
	Local Const $INSTALLSTATE_INVALIDARG = -2;   ;// invalid function argument
	Local Const $INSTALLSTATE_UNKNOWN = -1;   ;// unrecognized product or feature
	Const $ERROR_SUCCESS = 0
	Local $500Chr0 = _StringRepeat(Chr(0), 500)
	Local $shortcut, $szComponentCode, $szFeatureId, $szProductCode, $installstate
	$shortcut = DllCall($MsiDllName, 'int', 'MsiGetShortcutTarget', 'str', $link, 'str', $500Chr0, 'str', $500Chr0, 'str', $500Chr0)
	If @error Then Return SetError(@error, 0, 0)
	If $shortcut[0] <> $ERROR_SUCCESS Then Return SetError(4, 0, 0)
	$szProductCode = $shortcut[2]
	$szFeatureId = $shortcut[3]
	$szComponentCode = $shortcut[4]
	$installstate = DllCall($MsiDllName, 'int', 'MsiGetComponentPath', 'str', $szProductCode, 'str', $szComponentCode, 'str', $500Chr0, 'dword*', 500)
	If @error Then Return SetError(@error, 0, 0)
	If $installstate[0] = $INSTALLSTATE_LOCAL Or $installstate[0] = $INSTALLSTATE_SOURCE Then
		Switch StringLeft($installstate[3], 3)
			Case '00:', '20:'
				$installstate[3] = 'HKEY_CLASSES_ROOT' & StringMid($installstate[3], 4)
			Case '01:', '21:'
				$installstate[3] = 'HKEY_CURRENT_USER' & StringMid($installstate[3], 4)
			Case '02:', '22:'
				$installstate[3] = 'HKEY_LOCAL_MACHINE' & StringMid($installstate[3], 4)
			Case '03:', '23:'
				$installstate[3] = 'HKEY_USERS' & StringMid($installstate[3], 4)
		EndSwitch
		Return $installstate[3]
	EndIf
	Return SetError(5, 0, 0)
EndFunc

Func NeoDirCopy($from, $to, $IsShortcut = False, $CopyFromLive = False)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|NeoDirCopy(): $from=' & $from & ' : $to=' & $to & ' : $IsShortcut=' & $IsShortcut & ' : $CopyFromLive=' & $CopyFromLive & @CRLF)
	;This func replaces DIRCOPY due to AutoIt's implemenation inconsistencies between NT5 vs. NT6
	Local $i, $FileList, $Details
	If FileExists($from) Then
		$FileList = _FileListToArray($from, '*.*', 2) ; Return folders only
		If @error = 0 Then
			For $i = 1 To $FileList[0]
				If $IsShortcut Then
				EndIf
				If $CopyFromLive Then
					Select
						Case ($FileList[$i] = GetAppTypeBase($App_Type)) Or ($FileList[$i] = 'Patch')
						Case Else
							DirCreate($to & '\' & $FileList[$i])
							NeoDirCopy($from & '\' & $FileList[$i], $to & '\' & $FileList[$i], $IsShortcut, $CopyFromLive)
					EndSelect
				Else
					DirCreate($to & '\' & $FileList[$i])
					NeoDirCopy($from & '\' & $FileList[$i], $to & '\' & $FileList[$i], $IsShortcut, $CopyFromLive)
				EndIf
			Next
		EndIf
		$FileList = _FileListToArray($from, '*.*', 1) ; Return files only
		If @error = 0 Then
			For $i = 1 To $FileList[0]
				If $IsShortcut Then
				EndIf
				If $CopyFromLive Then
					Select
						Case ($FileList[$i] = GetAppTypeBase($App_Type) & '.7z')
						Case ($FileList[$i] = GetAppTypeBase($App_Type) & '.rar')
						Case ($FileList[$i] = GetAppTypeBase($App_Type) & '.cab')
						Case ($FileList[$i] = GetAppTypeBase($App_Type) & '.zip')
						Case ($FileList[$i] = GetAppTypeBase($App_Type) & '.md5')
						Case ($FileList[$i] = 'Patch.7z')
						Case ($FileList[$i] = 'Patch.rar')
						Case ($FileList[$i] = 'Patch.cab')
						Case ($FileList[$i] = 'Patch.zip')
						Case ($FileList[$i] = 'Patch.md5')
						Case ($FileList[$i] = GetFilename($from) & '.7z')
						Case ($FileList[$i] = GetFilename($from) & '.rar')
						Case ($FileList[$i] = GetFilename($from) & '.cab')
						Case ($FileList[$i] = GetFilename($from) & '.zip')
						Case ($FileList[$i] = GetFilename($from) & '.md5')
						Case Else
							NeoFileCopy($from & '\' & $FileList[$i], $to & '\' & $FileList[$i], $IsShortcut)
					EndSelect
				Else
					NeoFileCopy($from & '\' & $FileList[$i], $to & '\' & $FileList[$i], $IsShortcut)
				EndIf
			Next
		EndIf
	EndIf
EndFunc

Func NeoFileCopy($from, $to, $IsShortcut = False)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|NeoFileCopy(): $from=' & $from & ' : $to=' & $to & ' : $IsShortcut=' & $IsShortcut & @CRLF)
	;Uses FileCreateShortcut to copy shortcuts for Linux via Wine,
	;Otherwise standard FileCopy
	If $IsShortcut Then
		Local $i = GetFolderPath($to)
		If $i <> '' Then DirCreate($i)
		Local $Details = FileGetShortcutEx($from)
		If @error = 0 And IsArray($Details) Then FileCreateShortcut($Details[0], $to, $Details[1], $Details[2], $Details[3], $Details[4], $Details[7], $Details[5], $Details[6])
	Else
		If Not FileCopy($from, $to, 9) Then
			Local $test = IsWriteProtected(GetFolderPath($to))
		EndIf
	EndIf
EndFunc

Func NeoIniWrite($INI_filename, $INI_section, $INI_key, $INI_value)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|NeoIniWrite(): $INI_filename=' & $INI_filename & ' : $INI_section=' & $INI_section & ' : $INI_key=' & $INI_key & ' : $INI_value=' & $INI_value & @CRLF)
	If $INI_filename <> '' Then
		Local $i = IniWrite($INI_filename, $INI_section, $INI_key, $INI_value)
		If Not $i Then
			RemoveRSH($INI_filename)
			$i = IniWrite($INI_filename, $INI_section, $INI_key, $INI_value)
		EndIf
		Return $i
	EndIf
EndFunc

Func NoBackslash($PathIn) ;-)
	;If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|NoBackslash(): $PathIn=' & $PathIn & @CRLF)
	If StringRight($PathIn, 1) = '\' Then
		Return StringLeft($PathIn, StringLen($PathIn) - 1)
	Else
		Return $PathIn
	EndIf
EndFunc

Func NormalizeAssocExts($What)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|NormalizeAssocExts(): $What=' & $What & @CRLF)
	Local $temp = StringReplace(StringReplace(StringReplace(StringReplace($What, '"', ''), '|', ' '), '.', ' '), ',', ' ')
	Do
		$temp = StringReplace($temp, '  ', ' ')
	Until StringInStr($temp, '  ') = 0
	Return StringStripWS($temp, 3)
EndFunc

Func NormalizeInstallPath($line)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|NormalizeInstallPath(): $Line=' & $line & @CRLF)
	;$SystemDrive
	$line = $line & '\'
	If StringMid($line, 2, 2) = ':\' Then $line = StringMid($line, 3)
	If StringMid($line, 2, 1) = ':' Then $line = '\' & StringMid($line, 3)
	$line = StringReplace($line, '\Program Files (x86)\Common Files\', '')
	$line = StringReplace($line, StringMid(@CommonFilesDir, 3) & '\', '')
	$line = StringReplace($line, '\Program Files (x86)\', '')
	$line = StringReplace($line, StringMid(@ProgramFilesDir, 3) & '\', '')
	$line = StringReplace($line, StringMid(@SystemDir, 3) & '\', '')
	$line = StringReplace($line, StringMid(@WindowsDir, 3) & '\SYSWOW64\', '')
	$line = StringReplace($line, StringMid(@WindowsDir, 3) & '\', '')
	$line = StringReplace($line, '\Users\Public\', '')
	$line = StringReplace($line, StringMid(@AppDataCommonDir, 3) & '\', '')
	$line = StringReplace($line, StringMid(@DesktopCommonDir, 3) & '\', '')
	$line = StringReplace($line, StringMid(@DocumentsCommonDir, 3) & '\', '')
	$line = StringReplace($line, StringMid(@FavoritesCommonDir, 3) & '\', '')
	$line = StringReplace($line, StringMid(@StartupCommonDir, 3) & '\', '')
	$line = StringReplace($line, StringMid(@ProgramsCommonDir, 3) & '\', '')
	$line = StringReplace($line, StringMid(@StartMenuCommonDir, 3) & '\', '')
	$line = StringReplace($line, StringMid($QuickLaunch, 3) & '\', '')
	$line = StringReplace($line, StringMid($SendToPath, 3) & '\', '')
	$line = StringReplace($line, StringMid(@AppDataDir, 3) & '\', '')
	$line = StringReplace($line, StringMid(@DesktopDir, 3) & '\', '')
	$line = StringReplace($line, StringMid(@MyDocumentsDir, 3) & '\', '')
	$line = StringReplace($line, StringMid(@FavoritesDir, 3) & '\', '')
	$line = StringReplace($line, StringMid(@StartupDir, 3) & '\', '')
	$line = StringReplace($line, StringMid(@ProgramsDir, 3) & '\', '')
	$line = StringReplace($line, StringMid(@StartMenuDir, 3) & '\', '')
	$line = StringReplace($line, StringMid(@UserProfileDir, 3) & '\', '')
	$line = StringReplace($line, '\ppApps\', '')
	$line = StringReplace($line, '\ppGames\', '')
	If StringLeft($line, 1) = '\' Then
		If StringLen($line) > 1 Then
			$line = StringMid($line, 2)
		Else
			$line = ''
		EndIf
	EndIf
	Return NoBackslash($line)
EndFunc

Func ReconstructCmdLine(ByRef $CLIparameters)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|ReconstructCmdLine()' & @CRLF)
	Local $i, $temp = ''
	For $i = 1 To $CLIparameters[0]
		$temp = $temp & ' ' & $CLIparameters[$i]
	Next
	Return StringStripWS($temp, 3)
EndFunc

Func RegPathConvert($In, $Switch)
	;If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|RegPathConvert(): $In=' & $In & ' : $Switch=' & $Switch & @CRLF)
	If $Switch Then
		Return StringReplace($In, '\', '\\')
	Else
		Return $In
	EndIf
EndFunc

Func RemoveEmptyDir($from)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|RemoveEmptyDir(): $from=' & $from & @CRLF)
	Local $FileList
	If FileExists($from) Then
		$FileList = _FileListToArray($from, '*.*', 2) ; Return folders only
		If @error = 4 Or $FileList[0] = 0 Then
			DirRemove($from)
			Return True
		Else
		EndIf
	EndIf
	Return False
EndFunc

Func RemoveFlag(ByRef $temp, $This)
	;If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|RemoveFlag(): $Temp=' & $Temp & @CRLF)
	$temp = StringReplace($temp, $This, '')
	$temp = StringStripWS(StringReplace($temp, '||', '|'), 3)
	If StringLeft($temp, 1) = '|' Then $temp = StringMid($temp, 2)
	If StringRight($temp, 1) = '|' Then $temp = StringLeft($temp, StringLen($temp) - 1)
EndFunc

Func RemoveRSH($What, $Recurse = False)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|RemoveRSH(): $What=' & $What & ' : $Recurse=' & $Recurse & @CRLF)
	If StringInStr(FileGetAttrib($What), 'D') Then ; folder
		If $Recurse Then
			Local $i, $FileList
			$FileList = _FileListToArray($What, '*.*', 2) ; Return folders only
			If @error = 0 Then
				For $i = 1 To $FileList[0]
					RemoveRSH($What & '\' & $FileList[$i], True)
				Next
			EndIf
		EndIf
		RunWait($CLIprefix & 'attrib . -r -s -h', $What, @SW_HIDE)
		FileSetAttrib($What & '\*.*', '-RSH+N')
	Else ; file
;~ 		RunWait($CLIprefix & 'attrib . -r -s -h', GetFolderPath($What), @SW_HIDE)
		FileSetAttrib($What, '-RSH+N')
	EndIf
EndFunc

Func ResetINI($What)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|ResetINI(): $What=' & $What & @CRLF)
	If FileExists($ssTekResources & '\' & $What) Then FileDelete($ssTekResources & '\' & $What)
	Return CheckINI($What)
EndFunc

Func ResizeMe($hForm, $hCtrl, $iSize = Default, $iWeight = Default, $iAttrib = Default, $sFontName = "")
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|ResizeMe()' & @CRLF)
	Local $aCtrlSize = _StringSize(GUICtrlRead($hCtrl), $iSize, $iWeight, $iAttrib, $sFontName)
	Local $aCtrlPos = ControlGetPos($hForm, GUICtrlRead($hCtrl), $hCtrl)
	If @error = 0 And IsArray($aCtrlSize) Then
		GUICtrlSetPos($hCtrl, $aCtrlPos[0], $aCtrlPos[1], $aCtrlSize[2], $aCtrlSize[1]);l,t,w,h
		Return $aCtrlSize[2]
	Else
		Return False
	EndIf
EndFunc

Func SetHotKey($What, $Display = False)
	Local $test = ''
	$What = StringStripWS(StringLower($What), 8)
	If $Display Then
		If StringInStr($What, '^') Then
			$test = $test + 'CTRL'
			$What = StringReplace($What, '^', '')
		EndIf
		If StringInStr($What, '+') Then
			$test = $test + 'SHIFT'
			$What = StringReplace($What, '+', '')
		EndIf
		If StringInStr($What, '!') Then
			$test = $test + 'ALT'
			$What = StringReplace($What, '!', '')
		EndIf
		$test = $test & $What
		$test = StringReplace($test, 'CTRL', 'CTRL+')
		$test = StringReplace($test, 'ALT', 'ALT+')
		$test = StringReplace($test, 'SHIFT', 'SHIFT+')
	Else
		$test = StringReplace($What, '+', '')
		$test = StringReplace($test, 'CTRL', '^')
		$test = StringReplace($test, 'ALT', '!')
		$test = StringReplace($test, 'SHIFT', '+')
	EndIf
	Return $test
EndFunc

Func SetMenuStyle($MenuStyle)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|SetMenuStyle(): $MenuStyle=' & $MenuStyle & @CRLF)
	Local $i, $file
	If $MenuStyles[0][0] = 0 Or $MenuStyles[0][0] = '' Then GetMenuStyles() ;Array
;~ 	#cs ;Remove this section for Final
	If FileExists(@WindowsDir & '\LastXP') Then
		DirRemove(@WindowsDir & '\LastXP\Menu', 1)
		DirRemove(@WindowsDir & '\LastXP\Icons', 1)
		FileDelete(@WindowsDir & '\LastXP\Definitions.ini')
		Local $FileList = _FileListToArray(@WindowsDir & '\LastXP', '*.*', 0)
		If @error <> 0 Then DirRemove(@WindowsDir & '\LastXP', 1)
	EndIf
	If FileExists(@WindowsDir & '\LastOS') Then
		DirRemove(@WindowsDir & '\LastOS\Menu', 1)
		DirRemove(@WindowsDir & '\LastOS\Icons', 1)
		FileDelete(@WindowsDir & '\LastOS\Definitions.ini')
		Local $FileList = _FileListToArray(@WindowsDir & '\LastOS', '*.*', 0)
		If @error <> 0 Then DirRemove(@WindowsDir & '\LastOS', 1)
	EndIf
	For $i = 1 To $MenuStyles[0][0]
		FileDelete(@WindowsDir & '\' & $MenuStyles[$i][1] & 'SetupSMenu.ini')
	Next
	FileDelete(@WindowsDir & '\NoSetupSMenu.ini')
	FileDelete(@WindowsDir & '\KazzSetupSMenu.ini')
	FileDelete(@WindowsDir & '\LastXPSetupSMenu.ini')
	FileDelete(@WindowsDir & '\LastOSSetupSMenu.ini')
	FileDelete(@WindowsDir & '\ssTekSetupSMenu.ini')
	#cs
		FileDelete(@WindowsDir & '\SetupSMenu.ini')
		If $MenuStyle > 0 Then
		;~ 		NeoIniWrite(@WindowsDir & '\' & $MenuStyles[$MenuStyle][1] & 'SetupSMenu.ini', 'SetupS Menu', 'Style', $MenuStyles[$MenuStyle][1])
		NeoIniWrite(@WindowsDir & '\SetupSMenu.ini', 'SetupS Menu', 'Style', $MenuStyles[$MenuStyle][1])
		;~ 		$file = FileOpen(@WindowsDir & '\SetupSMenu.ini', 2)
		;~ 		FileWriteLine($file, $MenuStyles[$MenuStyle][1])
		;~ 		;FileWriteLine($file, @CRLF)
		;~ 		FileClose($file)
		;NeoIniWrite(@WindowsDir & '\SetupSMenu.ini', 'SetupS Menu', 'Style', $MenuStyles[$MenuStyle][1])
		EndIf
	#ce
	If $MenuStyle = 0 Then
		FileDelete(@WindowsDir & '\SetupSMenu.ini')
	Else
		$file = FileOpen(@WindowsDir & '\SetupSMenu.ini', 2)
		FileWriteLine($file, $MenuStyles[$MenuStyle][1])
		FileClose($file)
		NeoIniWrite(@WindowsDir & '\SetupSMenu.ini', 'SetupS Menu', 'Style', $MenuStyles[$MenuStyle][1])
	EndIf
	Return $MenuStyle
EndFunc

Func SetReportingFlags()
	Select ; Status reporting mode
		Case $SplashTips And $BalloonTips ; Verbose
			$TrayOnly = False
			$SplashOnly = False
			$Mute = False
		Case $BalloonTips And Not $SplashTips ; TrayOnly
			$TrayOnly = True
			$SplashOnly = False
			$Mute = False
		Case $SplashTips And Not $BalloonTips ; SplashOnly
			$TrayOnly = False
			$SplashOnly = True
			$Mute = False
		Case Else ; Mute
			$TrayOnly = False
			$SplashOnly = False
			$Mute = True
	EndSelect
EndFunc

Func SplashThis($Title, $Message)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|SplashThis(): $title=' & $Title & ' : $Message=' & $Message & @CRLF)
	$Message = StringReplace($Message, '&', '&&')
	Local $OnTop = 0, $OriginalMsg = $Message, $aCtrlSize = _StringSize($Message, 10, 400, 0, 'Arial'), $cutoff = 0 ;10
	While $aCtrlSize[2] > 485
		$cutoff += 1
		$Message = StringLeft($OriginalMsg, StringLen($OriginalMsg) - $cutoff - 16) & ' ... ' & StringRight($OriginalMsg, 11)
		$aCtrlSize = _StringSize($Message, 10, 400, 0, 'Arial')
	WEnd
	If ControlSetText($Title, '', 'Static1', $Message) = 0 Or ControlCommand($Title, '', 'Static1', 'IsVisible', '') = 0 Then
		If $SplashOnTop Then $OnTop = 2
		$SplashControlID = SplashTextOn($Title, $Message, -1, 42, -1, -1, 22 - $OnTop, 'Arial', 10, 400);w,42,x,y,20
	EndIf
EndFunc

Func StartMenuIcons($SnM, $ProgramsDir_EX = '') ; SetupS-style Folder Icons (StartMenu)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|StartMenuIcons(): $ProgramsDir_EX=' & $ProgramsDir_EX & @CRLF)
	Local $i, $test ; Global $App_NeverSort
	If $ProgramsDir_EX = '' Then $ProgramsDir_EX = @ProgramsDir
	For $i = 1 To $SnM[0]
		If StringStripWS($SnM[$i], 3) <> '' Then
			$test = $SnM[$i]
			CreateMenuDesktopINI($ssTekResources & '\Menu\' & $test, $ProgramsDir_EX & '\' & $test)
			While StringInStr($test, '\') > 0
				$test = GetFolderPath($test)
				CreateMenuDesktopINI($ssTekResources & '\Menu\' & $test, $ProgramsDir_EX & '\' & $test)
			WEnd
			If $App_KeepInFolder Then $SnM[$i] = GetFolderPath($SnM[$i])
			If IniRead($MenuDefinitionINI, $SnM[$i], 'IconFile', '') = '' Then
				$test = $ssTekResources & '\Menu\' & $SnM[$i]
				Do
					If Not FileExists($test & '\desktop.ini') Then
						DirCreate($test)
						CreateFolderDesktopINI('SHELL32.dll', ConvertFromVars('%SystemRoot%\system32'), '-20', $test)
					EndIf
					$test = GetFolderPath($test)
				Until $test = $ssTekResources
			EndIf
		EndIf
	Next
EndFunc

Func StringFilterFilename($s, $IsPath = False, $Morph = False) ;Removes invalid or unwanted characters from string
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|StringFilterFilename(): $s=' & $s & ' : $IsPath=' & $IsPath & @CRLF)
	If $Morph Then
		$s = StringStripWS($s, 7)
		$s = StringReplace($s, ' ', Chr(31))
		;Illegal characters: \/:*?"<>|
		$s = StringReplace(StringStripWS(StringReplace($s, '"', ' '), 7), ' ', '.')
		$s = StringReplace(StringStripWS(StringReplace($s, '|', ' '), 7), ' ', '.')
		$s = StringReplace(StringStripWS(StringReplace($s, '>', ' '), 7), ' ', '.')
		$s = StringReplace(StringStripWS(StringReplace($s, '<', ' '), 7), ' ', '.')
		$s = StringReplace(StringStripWS(StringReplace($s, '?', ' '), 7), ' ', '.')
		$s = StringReplace(StringStripWS(StringReplace($s, '*', ' '), 7), ' ', '.')
		If Not $IsPath Then ; Filename only
			$s = StringReplace(StringStripWS(StringReplace($s, ':', ' '), 7), ' ', '.')
			$s = StringReplace(StringStripWS(StringReplace($s, '\', ' '), 7), ' ', '.')
			$s = StringReplace(StringStripWS(StringReplace($s, '/', ' '), 7), ' ', '.')
		EndIf
		;Misc characters...
		$s = StringReplace(StringStripWS(StringReplace($s, '.-.', ' '), 4), ' ', '.')
		$s = StringReplace(StringStripWS(StringReplace($s, '.', ' '), 4), ' ', '.')
		$s = StringReplace(StringStripWS(StringReplace($s, '_', ' '), 4), ' ', '_')
		$s = StringReplace(StringStripWS(StringReplace($s, '-', ' '), 4), ' ', '-')
		$s = StringReplace($s, Chr(31), ' ')
	Else
		Local $i, $j = '\/:*?"<>|'
		If $IsPath Then $j = '*?"<>|'
		For $i = 1 To StringLen($j)
			$s = StringReplace($s, StringMid($j, $i, 1), '')
		Next
	EndIf
	Return $s
EndFunc

Func Timer(ByRef $Timer, $Message = '', $ShowTicks = False)
	;	===================================================
	;	Parameters ....
	;		$Timer	   - The timer object to use.
	;		$Message   - Optional: leave empty to only (re)start $Timer
	;		$ShowTicks - Optional: True to not convert to HH:MM:SS format
	;
	;	Example of use:
	;		Timer($StopWatch) ; start timer
	;		Timer($StopWatch, "Post-processing done!", True) ; stop timer
	;	===================================================
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|Timer(): $Message=' & $Message & ' : $ShowTicks=' & $ShowTicks & @CRLF)
	Local $Secs, $Mins, $Hour, $Time = Int(TimerDiff($Timer))
	If Not $ShowTicks Then
		_TicksToTime($Time, $Hour, $Mins, $Secs)
		$Time = StringFormat('%02i:%02i:%02i', $Hour, $Mins, $Secs)
	EndIf
	If $Message <> '' Then MsgBox(262144, $Message, $Time)
	$Timer = TimerInit()
EndFunc

Func UninstallDiff(ByRef $aReg1, $aReg2)
	Local $i, $j, $found, $arr[1][7]
	$arr[0][0] = 0 ; first row=count, 'key' thereafter
	$arr[0][1] = 'DisplayName'
	$arr[0][2] = 'InstallLocation'
	$arr[0][3] = 'DisplayIcon'
	$arr[0][4] = 'UninstallString'
	$arr[0][5] = 'Switches'
	$arr[0][6] = 'Script'
	For $i = 1 To $aReg2[0][0]
		$found = False
		For $j = 1 To $aReg1[0][0]
			If $aReg2[$i][0] = $aReg1[$j][0] Then
				$found = True
				ExitLoop
			EndIf
		Next
		If Not $found Then
			$arr[0][0] += 1
			ReDim $arr[$arr[0][0] + 1][7]
			For $j = 0 To 5
				$arr[$arr[0][0]][$j] = $aReg2[$i][$j]
			Next
		EndIf
	Next
	Return $arr
EndFunc

Func UninstallEnum($key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall')
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|UninstallEnum(): $key=' & $key & @CRLF)
	Local $i, $j, $var, $err, $arr[1][7], $test
	$arr[0][0] = 0 ; first row=count, 'key' thereafter
	$arr[0][1] = 'DisplayName'
	$arr[0][2] = 'InstallLocation'
	$arr[0][3] = 'DisplayIcon'
	$arr[0][4] = 'UninstallString'
	$arr[0][5] = 'Switches'
	$arr[0][6] = 'Script'
	Do
		$i += 1
		$var = RegEnumKey($key, $i)
		$err = @error
		If $err = 0 Then
			$arr[0][0] += 1
			ReDim $arr[$arr[0][0] + 1][7]
			$arr[$arr[0][0]][0] = $var
			For $j = 1 To 4
				$arr[$arr[0][0]][$j] = RegRead($key & '\' & $arr[$arr[0][0]][0], $arr[0][$j])
			Next
			$test = RegRead($key & '\' & $arr[$arr[0][0]][0], 'QuietUninstallString')
			If $test <> '' Then $arr[$arr[0][0]][5] = $test
		EndIf
	Until $err <> 0
	If $OSArch64 Then ;need to populate for x86 on 64-bit machines too
		$key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
		$i = 0
		Do
			$i += 1
			$var = RegEnumKey($key, $i)
			$err = @error
			If $err = 0 Then
				$arr[0][0] += 1
				ReDim $arr[$arr[0][0] + 1][7]
				$arr[$arr[0][0]][0] = $var
				For $j = 1 To 4
					$arr[$arr[0][0]][$j] = RegRead($key & '\' & $arr[$arr[0][0]][0], $arr[0][$j])
				Next
				$test = RegRead($key & '\' & $arr[$arr[0][0]][0], 'QuietUninstallString')
				If $test <> '' Then $arr[$arr[0][0]][5] = $test
			EndIf
		Until $err <> 0
	EndIf
	Return $arr
EndFunc

Func Update_Explorer()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|Update_Explorer()' & @CRLF)
	Local $bOld = Opt('WinSearchChildren', True)
	Local $a = WinList('[CLASS:SHELLDLL_DefView]')
	For $i = 0 To UBound($a) - 1
		DllCall('user32.dll', 'long', 'SendMessage', 'hwnd', $a[$i][1], 'int', 0x111, 'int', 28931, 'int', 0)
	Next
	Opt('WinSearchChildren', $bOld)
EndFunc

Func ValidateCatalog()
	Local $i, $j, $k, $value, $found = False, $LegacyFound = 0, $WholeCatalog, $CatalogUpdated = False
	For $i = 1 To $App_Catalog[0] ;check if $App_Catalog entries exist
		For $k = 1 To 2
			If FileExists(GetMenuDefs($k)) Then
				$WholeCatalog = IniReadSection(GetMenuDefs($k), 'Catalog')
				If IsArray($WholeCatalog) Then
					$found = False
					For $j = 1 To $WholeCatalog[0][0] ;MsgBox(4096, '', 'Key: ' & $WholeCatalog[$i][0] & @CRLF & 'Value: ' & $WholeCatalog[$i][1])
						If $WholeCatalog[$j][0] = $App_Catalog[$i] Then
							$found = True
							ExitLoop
						EndIf
					Next
					;$found = False ;debug remove
					If Not $found Then ; <StartmenuDestPath> in Catalog?
						If AddLegacy($WholeCatalog, $App_Catalog[$i], $k) Then
							$LegacyFound = $LegacyFound + $k
							$CatalogUpdated = True
						EndIf
					EndIf
				EndIf
			EndIf
		Next
		If Not $found Then
			Switch $LegacyFound
				Case 0 ; Was added to neither
					If $App_smLegacyPrimary[0] > 0 Then
						If GetMenuDefs(1) <> '' Then IniWrite(GetMenuDefs(1), 'Catalog', $App_Catalog[$i], $App_smLegacyPrimary[1])
						If $App_smLegacySecondary[0] > 0 Then
							If GetMenuDefs(2) <> '' Then IniWrite(GetMenuDefs(2), 'Catalog', $App_Catalog[$i], $App_smLegacySecondary[1])
						Else
							If GetMenuDefs(2) <> '' Then IniWrite(GetMenuDefs(2), 'Catalog', $App_Catalog[$i], $App_smLegacyPrimary[1])
						EndIf
						$CatalogUpdated = True
					ElseIf $App_smLegacySecondary[0] > 0 Then
						If GetMenuDefs(2) <> '' Then IniWrite(GetMenuDefs(2), 'Catalog', $App_Catalog[$i], $App_smLegacySecondary[1])
						If GetMenuDefs(1) <> '' Then IniWrite(GetMenuDefs(1), 'Catalog', $App_Catalog[$i], $App_smLegacySecondary[1])
						$CatalogUpdated = True
					Else ; Remove (bogus) entry from array
						$App_Catalog[$i] = ''
					EndIf
				Case 1 ; Was added to $App_smLegacyPrimary only
					If $App_smLegacySecondary[0] > 0 Then
						If GetMenuDefs(2) <> '' Then IniWrite(GetMenuDefs(2), 'Catalog', $App_Catalog[$i], $App_smLegacySecondary[1])
						$CatalogUpdated = True
					Else
						If GetMenuDefs(2) <> '' Then IniWrite(GetMenuDefs(2), 'Catalog', $App_Catalog[$i], $App_smLegacyPrimary[1])
						$CatalogUpdated = True
					EndIf
				Case 2 ; Was added to $App_smLegacySecondary only
					If $App_smLegacyPrimary[0] > 0 Then
						If GetMenuDefs(1) <> '' Then IniWrite(GetMenuDefs(1), 'Catalog', $App_Catalog[$i], $App_smLegacyPrimary[1])
						$CatalogUpdated = True
					Else
						If GetMenuDefs(1) <> '' Then IniWrite(GetMenuDefs(1), 'Catalog', $App_Catalog[$i], $App_smLegacySecondary[1])
						$CatalogUpdated = True
					EndIf
				Case 3 ; Found in both; so they're already added to catalog
			EndSwitch
		EndIf
	Next
	_ArrayRemoveBlanks($App_Catalog)
	If $CatalogUpdated = True Then FileCopy(GetMenuDefs($MenuStyle), $MenuDefinitionINI, 9)
	Return
EndFunc

Func VersionCompare($t1, $compare, $t2)
	Local $a = VersionFormat($t1), $b = VersionFormat($t2), $test
	If StringLen($a) < StringLen($b) Then
		$b = StringLeft($b, StringLen($a))
	ElseIf StringLen($a) > StringLen($b) Then
		$a = StringLeft($a, StringLen($b))
	EndIf
	Switch $compare
		Case '<'
			Return ($a < $b)
		Case '='
			Return ($a = $b)
		Case '>'
			Return ($a > $b)
		Case '<='
			Return ($a <= $b)
		Case '=<'
			Return ($a <= $b)
		Case '=>'
			Return ($a >= $b)
		Case '>='
			Return ($a >= $b)
		Case '<>'
			Return ($a <> $b)
		Case '><'
			Return ($a <> $b)
	EndSwitch
EndFunc

Func VersionFormat($What)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|VersionFormat(): $What=' & $What & @CRLF)
	If StringLeft($What, 1) = 'v' Then $What = StringMid($What, 2)
	Local $b = '', $a = StringSplit($What, '.')
	If @error Then $a = StringSplit($What, '-')
	If @error Then $a = StringSplit($What, '/')
	If IsNumber(Number($a[1])) Then
		For $i = 1 To $a[0]
			$a[$i] = _StringRepeat('0', 4 - StringLen(Number($a[$i]))) & Number($a[$i])
		Next
		Local $b = $a[1]
		For $i = 2 To $a[0]
			$b = $b & '.' & $a[$i]
		Next
	EndIf
	Return $b
EndFunc
#endregion

#region ;**** ScanForExpressInstall ****
Func ScanForExpressInstall_Add_Old($Where, $What, $FolderOnly = False) ;old method using FileListToArray
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|ScanForExpressInstall_Add_Old(): $Where=' & $Where & ' : $What=' & $What & ' : $FolderOnly=' & $FolderOnly & @CRLF)
	Local $i, $FileList
	$FileList = _FileListToArray($Where, $What, 1)
	Switch @error
		Case 0
			For $i = 1 To $FileList[0]
				$FileList[$i] = $Where & '\' & $FileList[$i]
			Next
			_ArrayConcatenate($ExpressInstall, $FileList, 1)
			$ExpressInstall[0] += $FileList[0]
		Case 4
	EndSwitch
EndFunc

Func ScanForExpressInstall_Add($Where, $What, $FolderOnly = False) ;new method using _FileListToArrayPlus
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|ScanForExpressInstall_Add(): $Where=' & $Where & ' : $What=' & $What & ' : $FolderOnly=' & $FolderOnly & @CRLF)
	Local $i, $FileList
	$FileList = _FileListToArrayPlus($Where, $What, 9) ; Files only & Recurse (1+8)
	If @error = 0 And IsArray($FileList) Then
		If $FileList[0] > 0 Then
			If $FolderOnly Then
				For $i = 1 To $FileList[0]
					$FileList[$i] = GetFolderPath($FileList[$i])
				Next
			EndIf
			_ArrayConcatenate($ExpressInstall, $FileList, 1)
			$ExpressInstall[0] += $FileList[0]
			Return True
		Else
			Return False
		EndIf
	Else
		Return False
	EndIf
EndFunc

Func ScanForExpressInstall($Where, $ExcludeXI = False, $BType = 'Any', $ScanMethod = 'Old')
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|ScanForExpressInstall(): $Where=' & $Where & ' : $ExcludeXI=' & $ExcludeXI & ' : $BType=' & $BType & ' : $ScanMethod=' & $ScanMethod & @CRLF)
	If StringInStr($Where, $ssTekResources) Then Return
	; recursively scan for SetupS files from $Where and
	; create a batch list of folders/files for SetupS to process
	If $ScanMethod = 'Old' Then ;old method using FileListToArray
		Local $i, $FileList, $found = $ExpressInstall[0]
		$ScanDepth += 1
		If FileExists($Where) Then
			If Not $ExcludeXI Then
				Switch $BType
					Case 'app'
						ScanForExpressInstall_Add_Old($Where, '*.apz')
					Case 'ppg'
						ScanForExpressInstall_Add_Old($Where, '*.pgz')
					Case Else
						ScanForExpressInstall_Add_Old($Where, '*.apz')
						ScanForExpressInstall_Add_Old($Where, '*.pgz')
				EndSwitch
			EndIf
			Switch StringLower($BType)
				Case 'app'
					$FileList = _FileListToArray($Where, '*.app', 1); files only
					If IsArray($FileList) Then
						$ExpressInstall[0] += 1
						ReDim $ExpressInstall[$ExpressInstall[0] + 1]
						$ExpressInstall[$ExpressInstall[0]] = $Where
					EndIf
				Case 'ppg'
					$FileList = _FileListToArray($Where, '*.ppg', 1); files only
					If IsArray($FileList) Then
						$ExpressInstall[0] += 1
						ReDim $ExpressInstall[$ExpressInstall[0] + 1]
						$ExpressInstall[$ExpressInstall[0]] = $Where
					EndIf
				Case Else
					$FileList = _FileListToArray($Where, '*.app', 1); files only
					If IsArray($FileList) Then
						$ExpressInstall[0] += 1
						ReDim $ExpressInstall[$ExpressInstall[0] + 1]
						$ExpressInstall[$ExpressInstall[0]] = $Where
					Else
						$FileList = _FileListToArray($Where, '*.ppg', 1); files only
						If IsArray($FileList) Then
							$ExpressInstall[0] += 1
							ReDim $ExpressInstall[$ExpressInstall[0] + 1]
							$ExpressInstall[$ExpressInstall[0]] = $Where
						Else
							$FileList = _FileListToArray($Where, '*.ppg', 1); files only
							If IsArray($FileList) Then
								$ExpressInstall[0] += 1
								ReDim $ExpressInstall[$ExpressInstall[0] + 1]
								$ExpressInstall[$ExpressInstall[0]] = $Where
							Else
								$FileList = _FileListToArray($Where, '*.ppg', 1); files only
								If IsArray($FileList) Then
									$ExpressInstall[0] += 1
									ReDim $ExpressInstall[$ExpressInstall[0] + 1]
									$ExpressInstall[$ExpressInstall[0]] = $Where
								EndIf
							EndIf
						EndIf
					EndIf
			EndSwitch
			If $found = $ExpressInstall[0] Then
				$FileList = _FileListToArray($Where, '*.*', 2) ; Return folders only
				If IsArray($FileList) Then
					For $i = 1 To $FileList[0]
						ScanForExpressInstall($Where & '\' & $FileList[$i], $ExcludeXI, $BType, $ScanMethod)
					Next
				EndIf
			EndIf
		EndIf
	Else ;new method using _FileListToArrayPlus
		Local $i, $FileList;, $found = $ExpressInstall[0]
		$ScanDepth += 1
		If FileExists($Where) Then
			If Not $ExcludeXI Then
				Switch $BType
					Case 'app'
						ScanForExpressInstall_Add($Where, '*.apz')
					Case 'ppg'
						ScanForExpressInstall_Add($Where, '*.pgz')
					Case Else
						ScanForExpressInstall_Add($Where, '*.apz')
						ScanForExpressInstall_Add($Where, '*.pgz')
				EndSwitch
			EndIf
			Switch $BType
				Case 'app'
					ScanForExpressInstall_Add($Where, '*.app', True)
				Case 'ppg'
					ScanForExpressInstall_Add($Where, '*.ppg', True)
				Case Else
					ScanForExpressInstall_Add($Where, '*.app', True)
					ScanForExpressInstall_Add($Where, '*.ppg', True)
			EndSwitch
		EndIf
	EndIf
EndFunc
#endregion

#region ;**** APP-IO_v9 ****
Func _AppRead($What, $ConvertVar = True, $ConvertVersion = True);, $ReadMode = 0) ; 0 = All, x = Refined (see _GetAppField() below), -1 = Install-only
	;Remember to use _AppReset() sometime before using this one for the first time!
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|_AppRead(): $What=' & $What & @CRLF)
	Local $temp, $i, $line, $file, $ShortcutS, $Temp_AppFile
	ReDim $App_Assembly[1], $App_scKeep[1], $App_scEXE[1], $App_scWorkDir[1], $App_scLNK[1], $App_scDesc[1], $App_scArgs[1]
	ReDim $App_scIcon[1], $App_scExt[1], $App_scIndex[1], $App_scState[1], $App_scDefaults[1], $App_FileType[1]
	ReDim $App_scCatalog[1], $App_scFlags[1], $App_scKey[1]
	ReDim $App_Script[1], $App_RegEntries[1], $App_StartMenu[1], $App_URL[1], $App_InstallFonts[1], $App_RegisterDLL[1]
	$App_Type = 0
	$App_Legacy = True
	$App_File = _GetAppFilename($What)
	If $App_File <> '' Then
		$App_TDStamp = FileGetTime($App_File, 0, 1)
		$App_FileVersion = _GetAppVersion($App_File)
		If VersionCompare($App_FileVersion, '>', '8') Then ; GetVersionNumber($App_FileVersion) > 8
			;Timer($StopWatch) ; start timer
			_AppRead_INI($App_File, $ConvertVar)
			;Timer($StopWatch, 'INI-fileformat read', True) ; stop timer
		Else
			;Timer($StopWatch) ; start timer
			_AppRead_Legacy($App_File, $ConvertVar)
			;Timer($StopWatch, 'Legacy-fileformat read', True) ; stop timer
		EndIf
		$temp = _GetAuxFilename(GetFolderPath($App_File), '.reg')
		If $App_CmdFile = '' Then $App_CmdFile = File2String(_GetAuxFilename(GetFolderPath($App_File), '.cmd'))
		If $App_CmdFile = '' Then $App_CmdFile = File2String(_GetAuxFilename(GetFolderPath($App_File), '.bat'))
		If $App_RegFile = '' Then $App_RegFile = File2String(_GetAuxFilename(GetFolderPath($App_File), '.reg'))
		If $App_PriorityOrder = '' Then $App_PriorityOrder = 5
		If $App_Type = 4 Then ; the special ppApp case: ppTweak
			$App_MakeStartMenu = False
			$App_scCount = 0
			$App_Category[0] = 1
			$App_Category[1] = 'Tweaks'
			$App_smSource = ''
			ReDim $App_scKeep[1]
			$App_scKeep[0] = 0
			ReDim $App_FileType[1]
			$App_FileType[0] = 0
			ReDim $App_StartMenu[1]
			$App_StartMenu[0] = 0
			ReDim $App_smLegacySecondary[1]
			$App_smLegacySecondary[0] = 0
			ReDim $App_smLegacyPrimary[1]
			$App_smLegacyPrimary[0] = 0
			ReDim $App_Catalog[1]
			$App_Catalog[0] = 0
			ReDim $App_Assembly[1]
			$App_Assembly[0] = 0
		Else
			#cs
				$App_scEXE[0] = $App_scCount
				$App_scWorkDir[0] = $App_scCount
				$App_scLNK[0] = $App_scCount
				$App_scDesc[0] = $App_scCount
				$App_scArgs[0] = $App_scCount
				$App_scIcon[0] = $App_scCount
				$App_scExt[0] = $App_scCount
				$App_scIndex[0] = $App_scCount
				$App_scState[0] = $App_scCount
				$App_scDefaults[0] = $App_scCount
				$App_scFlags[0] = $App_scCount
				$App_scCatalog[0] = $App_scCount
				$App_scKey[0] = $App_scKey
			#ce
			If FileExists($CategoryINI) Then ; Process Category redirects
				If $AllCategories[0][0] = '' Then $AllCategories = IniReadSection($CategoryINI, 'Category')
				If IsArray($AllCategories) Then
					If $App_Category[0] > 0 Then
						For $j = 1 To $AllCategories[0][0]
							If StringLeft($AllCategories[$j][0], 1) = '!' Then
								For $i = 1 To $App_Category[0]
									If $App_Category[$i] = StringMid($AllCategories[$j][0], 2) Then
										$App_Category[$i] = $AllCategories[$j][1]
									EndIf
								Next
							EndIf
						Next
					EndIf
				EndIf
			EndIf
			If FileExists($MenuDefinitionINI) Then ; Process Catalog redirects
				If $WholeCatalog[0][0] = '' Then $WholeCatalog = IniReadSection($MenuDefinitionINI, 'Catalog')
				If IsArray($WholeCatalog) Then
					If $App_Catalog[0] > 0 Then
						For $j = 1 To $WholeCatalog[0][0]
							If StringLeft($WholeCatalog[$j][0], 1) = '!' Then
								For $i = 1 To $App_Catalog[0]
									If $App_Catalog[$i] = StringMid($WholeCatalog[$j][0], 2) Then
										$App_Catalog[$i] = $WholeCatalog[$j][1]
									EndIf
								Next
							EndIf
						Next
					EndIf
				EndIf
			EndIf
			StartMenuDestPath()
			If $App_Type = 5 And $App_Category[0] > 0 Then
				$line = 'Games\'
				For $i = 1 To $App_Category[0]
					If (StringLeft($App_Category[$i], StringLen($line)) <> $line) Then $App_Category[$i] = $line & $App_Category[$i]
				Next
			EndIf
			#cs Copies to scKeep list first shortcut from Defs list:
				If $App_scKeep[0] = 0 And $App_scCount > 0 Then
				$App_scKeep[0] = 1
				ReDim $App_scKeep[2]
				$App_scKeep[1] = $App_scLNK[1]
				EndIf
			#ce
		EndIf
		If IsArray($App_FileType) Then $App_FileType = SingleLine2Multi(StringReplace(NormalizeAssocExts(StringReplace(Multi2SingleLine($App_FileType), $ssEOL, ' ')), ' ', $ssEOL))
		For $i = 1 To $App_scCount
			If StringInStr($App_scFlags[$i], 'Is_x86') Or StringInStr($App_scFlags[$i], 'Is_x64') Or StringInStr($App_scFlags[$i], 'Is_86') Or StringInStr($App_scFlags[$i], 'Is_64') Then
				$App_OSArchGated = True
				ExitLoop
			EndIf
		Next
		If Not $App_OSArchGated Then
			If $App_RegFile <> '' Then
				If StringInStr($App_RegFile, '#Is_x86#') Or StringInStr($App_RegFile, '#Is_x64#') Then $App_OSArchGated = True
			EndIf
			If Not $App_OSArchGated Then
				If $App_CmdFile <> '' Then
					If StringInStr($App_CmdFile, '#Is_x86#') Or StringInStr($App_CmdFile, '#Is_x64#') Then $App_OSArchGated = True
				EndIf
				If Not $App_OSArchGated Then
					$Temp_AppFile = File2String($App_File)
					If StringInStr($Temp_AppFile, '#Is_x86#') Or StringInStr($Temp_AppFile, '#Is_x64#') Then $App_OSArchGated = True
				EndIf
			EndIf
		EndIf
		If $ConvertVersion And $App_Version = '' And $App_Type < 5 Then
			GetVersionFromTitle()
			If $App_Version <> '' Then $App_Changed = True
		EndIf
		Switch $App_Type
			Case 1, 2
				$App_BuildType = 'ssApp'
			Case 3, 4
				$App_BuildType = 'ppApp'
			Case 5
				$App_BuildType = 'ppGame'
		EndSwitch
	EndIf
	;Set_scFlags()
	Return $App_File
EndFunc

Func _AppRead_INI($App_File, $ConvertVar)
	Local $i, $j, $temp, $file, $scFlags;, $HeaderInUse = False
	$App_Legacy = False
	Switch StringLower(IniRead($App_File, 'SetupS', 'BuildType', ''))
		Case 'setups'
			$App_Type = 1
		Case 'ssapp'
			$App_Type = 2
		Case 'ppapp'
			$App_Type = 3
		Case 'pptweak'
			$App_Type = 4
		Case 'ppgame'
			$App_Type = 5
	EndSwitch
	$App_Title = IniRead($App_File, 'SetupS', 'Title', '')
	$App_Version = IniRead($App_File, 'SetupS', 'Version', '')
	$App_Description = SingleLine2Multi(IniRead($App_File, 'SetupS', 'Description', ''))
	$App_URL = SingleLine2Multi(IniRead($App_File, 'SetupS', 'URL', ''), '|')
	$App_Category = SingleLine2Multi(IniRead($App_File, 'SetupS', 'Category', ''), '|')
	$App_Catalog = SingleLine2Multi(IniRead($App_File, 'SetupS', 'Catalog', ''), '|')
	$App_smLegacyPrimary = SingleLine2Multi(IniRead($App_File, 'SetupS', 'StartMenuLegacyPrimary', ''), '|')
	$App_smLegacySecondary = SingleLine2Multi(IniRead($App_File, 'SetupS', 'StartMenuLegacySecondary', ''), '|')
	$App_InstallPath = IniRead($App_File, 'SetupS', 'AppPath', '')
	$App_smSource = IniRead($App_File, 'SetupS', 'StartMenuSourcePath', '')
	$App_Assembly = SingleLine2Multi(IniRead($App_File, 'SetupS', 'Assembly', ''))
	$App_scKeep = SingleLine2Multi(IniRead($App_File, 'SetupS', 'ShortCutNamesKeep', ''), '|')
	$App_FileType = SingleLine2Multi(IniRead($App_File, 'SetupS', 'FileTypes', ''), '|')
	$App_InstallFonts = SingleLine2Multi(IniRead($App_File, 'SetupS', 'InstallFonts', ''), '|')
	$App_RegisterDLL = SingleLine2Multi(IniRead($App_File, 'SetupS', 'RegisterDLL', ''), '|')
	$App_FileFormat = StringLeft(IniRead($App_File, 'SetupS', 'App-File Style', '0'), 1)
	$App_OS = StringLeft(IniRead($App_File, 'SetupS', 'OS', '0'), 2)
	If $App_OS = 15 Then $App_OS = 0
	If VersionCompare($App_FileVersion, '<', '9.15.12') And $App_OS = 2 Then $App_OS = 14 ; NT6: (8+4+2+0)
	$App_Architecture = StringLeft(IniRead($App_File, 'SetupS', 'Architecture', '0'), 1)
	$temp = IniRead($App_File, 'SetupS', 'Flags', '')
	If $temp <> '' Then
		$scFlags = StringSplit($temp, '|')
		;_ArrayDisplay($scFlags)
		For $i = 1 To $scFlags[0]
			If $scFlags[$i] = 'RefreshDesktop' Or $scFlags[$i] = 'RefreshExplorer' Then $App_RefreshExplorer = True
			If $scFlags[$i] = 'NotInStartmenu' Then $App_MakeStartMenu = False
			If $scFlags[$i] = 'KeepInFolder' Then $App_KeepInFolder = True
			If $scFlags[$i] = 'KeepAll' Then $App_KeepAll = True
			If $scFlags[$i] = 'Root' Then $App_MakeInRoot = True
			If $scFlags[$i] = 'Programs' Then $App_MakeInPrograms = True
			If $scFlags[$i] = 'Startup' Then $App_MakeStartup = True
			If $scFlags[$i] = 'Desktop' Then $App_MakeDesktop = True
			If $scFlags[$i] = 'QuickLaunch' Then $App_MakeQuickLaunch = True
			If $scFlags[$i] = 'TaskbarPin' Then $App_TaskbarPin = True
			If $scFlags[$i] = 'StartmenuPin' Then $App_StartmenuPin = True
			If $scFlags[$i] = 'SendTo' Then $App_MakeSendTo = True
			If $scFlags[$i] = 'NoShortcuts' Then $App_NeverSort = True
			If $scFlags[$i] = 'AlwaysSort' Then $App_AlwaysSort = True
			If $scFlags[$i] = 'CurrentUserOnly' Then $App_AllUsers = False
			If $scFlags[$i] = 'NoMenuIcons' Then $App_NoIcons = True
			If $scFlags[$i] = 'LivePE' Then $App_LivePE = True
			If $scFlags[$i] = 'AlwaysShow' Then $App_AlwaysShow = True
			If $scFlags[$i] = 'AlwaysHide' Then $App_AlwaysHide = True
			If $scFlags[$i] = 'DuringSetupOnly' Then $App_DuringSetupOnly = True
			If $scFlags[$i] = 'InstallT13' Then $App_InstallT13 = True
			If $scFlags[$i] = 'InstallInstant' Then $App_InstallInstant = True
			If $scFlags[$i] = 'NoneThing' Then $App_NoneThing = True
			If $scFlags[$i] = 'NotUpdateAppFile' Then $App_UpdateAppFile = False
			If $scFlags[$i] = 'NotMetroFriendly' Then $App_MetroFriendly = False
			If $scFlags[$i] = 'NotssUninstall' Then $App_ssUninstall = False
			If $scFlags[$i] = 'AssemblyNoWait' Then $App_AssemblyNoWait = True
		Next
	EndIf
	$temp = Multi2SingleLine($App_Assembly)
	If StringInStr($temp, "%ClickMe%") Or StringInStr($temp, "%CloseMe%") Or StringInStr($temp, "%SelectMe%") Or StringInStr($temp, "%SendMe%") Or StringInStr($temp, "%WaitForIt%") Or StringInStr($temp, "%WaitForMe%") Or StringInStr($temp, "%ProcessKill%") Then $App_AssemblyNoWait = True
	$App_PriorityOrder = IniRead($App_File, 'SetupS', 'PriorityOrder', '')
	$App_Tags = SingleLine2Multi(IniRead($App_File, 'Meta', 'Tags', ''), '|')
	$App_Publisher = IniRead($App_File, 'Meta', 'Publisher', '')
	$App_Language = IniRead($App_File, 'Meta', 'Language', '')
	$App_Releaser = IniRead($App_File, 'Meta', 'Releaser', '')
	$App_Additional = IniRead($App_File, 'Meta', 'Additional', '')
	$App_ReleaseDate = IniRead($App_File, 'Meta', 'ReleaseDate', '')
	$App_ReleaseVersion = IniRead($App_File, 'Meta', 'ReleaseVersion', '')
	$App_Rating = IniRead($App_File, 'Meta', 'Rating', '')
	$App_RequiredRuntimes = IniRead($App_File, 'Meta', 'RequiredRuntimes', '')
	$App_InstalledSize = IniRead($App_File, 'Meta', 'InstalledSize', '')
	$App_LicenseType = StringLeft(IniRead($App_File, 'Meta', 'LicenseType', ''), 1)
	Switch $App_LicenseType
		Case 1, 2, 3
		Case Else
			$App_LicenseType = 0
	EndSwitch
	If $ConvertVar Then
		$App_InstallPath = NoBackslash(ConvertFromVars(ConvertToVars($App_InstallPath)))
		$App_smSource = NoBackslash(ConvertFromVars(ConvertToVars($App_smSource)))
		For $i = 1 To $App_Assembly[0]
			$App_Assembly[$i] = ConvertFromVars(ConvertToVars($App_Assembly[$i]))
		Next
		For $i = 1 To $App_InstallFonts[0]
			$App_InstallFonts[$i] = ConvertFromVars(ConvertToVars($App_InstallFonts[$i]))
		Next
	Else
		$App_InstallPath = NoBackslash($App_InstallPath)
		$App_smSource = NoBackslash($App_smSource)
	EndIf
	Local $SectionsList = IniReadSectionNames($App_File)
	If Not @error Then
		$App_scCount = 0
		For $i = 1 To $SectionsList[0]
			If StringRight($SectionsList[$i], 4) = '.lnk' Then
				$App_scCount += 2
				ReDim $App_scEXE[$App_scCount]
				ReDim $App_scWorkDir[$App_scCount]
				ReDim $App_scLNK[$App_scCount]
				ReDim $App_scDesc[$App_scCount]
				ReDim $App_scArgs[$App_scCount]
				ReDim $App_scIcon[$App_scCount]
				ReDim $App_scExt[$App_scCount]
				ReDim $App_scIndex[$App_scCount]
				ReDim $App_scState[$App_scCount]
				ReDim $App_scDefaults[$App_scCount]
				ReDim $App_scFlags[$App_scCount]
				ReDim $App_scCatalog[$App_scCount]
				ReDim $App_scKey[$App_scCount]
				$App_scCount -= 1
				If $ConvertVar Then
					$App_scLNK[$App_scCount] = NoBackslash(ConvertFromVars(ConvertToVars(StringReplace(StringLeft($SectionsList[$i], StringLen($SectionsList[$i]) - 4), '"', ''))))
					$App_scEXE[$App_scCount] = NoBackslash(ConvertFromVars(ConvertToVars(StringReplace(IniRead($App_File, $SectionsList[$i], 'Target', ''), '"', ''))))
					$App_scWorkDir[$App_scCount] = NoBackslash(ConvertFromVars(ConvertToVars(StringReplace(IniRead($App_File, $SectionsList[$i], 'StartIn', ''), '"', ''))))
					$App_scArgs[$App_scCount] = NoBackslash(ConvertFromVars(ConvertToVars(IniRead($App_File, $SectionsList[$i], 'Arguments', ''))))
					$App_scIcon[$App_scCount] = NoBackslash(ConvertFromVars(ConvertToVars(StringReplace(IniRead($App_File, $SectionsList[$i], 'Icon', ''), '"', ''))))
					$App_scDefaults[$App_scCount] = NoBackslash(ConvertFromVars(ConvertToVars(StringReplace(IniRead($App_File, $SectionsList[$i], 'DefaultMenu', ''), '"', ''))))
				Else
					$App_scLNK[$App_scCount] = NoBackslash(StringReplace(StringLeft($SectionsList[$i], StringLen($SectionsList[$i]) - 4), '"', ''))
					$App_scEXE[$App_scCount] = NoBackslash(StringReplace(IniRead($App_File, $SectionsList[$i], 'Target', ''), '"', ''))
					$App_scWorkDir[$App_scCount] = NoBackslash(StringReplace(IniRead($App_File, $SectionsList[$i], 'StartIn', ''), '"', ''))
					$App_scArgs[$App_scCount] = NoBackslash(IniRead($App_File, $SectionsList[$i], 'Arguments', ''))
					$App_scIcon[$App_scCount] = NoBackslash(StringReplace(IniRead($App_File, $SectionsList[$i], 'Icon', ''), '"', ''))
					$App_scDefaults[$App_scCount] = NoBackslash(StringReplace(IniRead($App_File, $SectionsList[$i], 'DefaultMenu', ''), '"', ''))
				EndIf
				$App_scIndex[$App_scCount] = StringReplace(IniRead($App_File, $SectionsList[$i], 'Index', ''), '"', '')
				$App_scExt[$App_scCount] = NormalizeAssocExts(IniRead($App_File, $SectionsList[$i], 'Extensions', ''))
				$App_scState[$App_scCount] = StringReplace(IniRead($App_File, $SectionsList[$i], 'Launch State', ''), '"', '')
				$App_scFlags[$App_scCount] = StringReplace(IniRead($App_File, $SectionsList[$i], 'Flags', ''), '"', '')
				$App_scCatalog[$App_scCount] = StringReplace(IniRead($App_File, $SectionsList[$i], 'Catalog', ''), '"', '')
				$App_scKey[$App_scCount] = StringReplace(IniRead($App_File, $SectionsList[$i], 'Hotkey', ''), '"', '')
				$App_scDesc[$App_scCount] = StringReplace(IniRead($App_File, $SectionsList[$i], 'Comment', ''), '"', '')
				If StringLen($App_scDesc[$App_scCount]) >= $MAX_PATH Then $App_scDesc[$App_scCount] = StringLeft($App_scDesc[$App_scCount], $MAX_PATH - 4) & '...'
			ElseIf StringLeft($SectionsList[$i], StringLen('UninstallKey.')) = 'UninstallKey.' Then
				$App_Uninstall[0][0] += 1
				ReDim $App_Uninstall[$App_Uninstall[0][0] + 1][7]
				$App_Uninstall[$App_Uninstall[0][0]][0] = StringMid($SectionsList[$i], StringLen('UninstallKey.') + 1)
				$App_Uninstall[$App_Uninstall[0][0]][1] = IniRead($App_File, $SectionsList[$i], 'DisplayName', '')
				$App_Uninstall[$App_Uninstall[0][0]][2] = ConvertFromVars(ConvertToVars(IniRead($App_File, $SectionsList[$i], 'InstallLocation', '')))
				$App_Uninstall[$App_Uninstall[0][0]][3] = ConvertFromVars(ConvertToVars(IniRead($App_File, $SectionsList[$i], 'DisplayIcon', '')))
				$App_Uninstall[$App_Uninstall[0][0]][4] = ConvertFromVars(ConvertToVars(IniRead($App_File, $SectionsList[$i], 'UninstallString', '')))
				$App_Uninstall[$App_Uninstall[0][0]][5] = IniRead($App_File, $SectionsList[$i], 'Switches', '')
				$App_Uninstall[$App_Uninstall[0][0]][6] = ConvertFromVars(ConvertToVars(IniRead($App_File, $SectionsList[$i], 'Script', '')))
				If StringLeft($App_Uninstall[$App_Uninstall[0][0]][4], 1) = ':' Then $App_Uninstall[$App_Uninstall[0][0]][4] = StringMid($App_Uninstall[$App_Uninstall[0][0]][4], 2)
			EndIf
		Next
		For $i = 1 To $App_scCount ;fix up any "duplicates" found
			$j = StringInStr($App_scLNK[$i], ' {#')
			If $j > 0 And StringInStr($App_scLNK[$i], '}', $j + 3) Then $App_scLNK[$i] = StringMid($App_scLNK[$i], 1, $j - 1)
		Next
	EndIf
EndFunc

Func _AppRead_Legacy($What, $ConvertVar = True)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|_AppRead_Legacy(): $What=' & $What & @CRLF)
	Local $i, $j, $file, $line, $EndOfFile, $Section, $AppKey, $AppValue, $KeepBlanks, $App_UseLegacyKeepInFolderRules = True
	$file = FileOpen($What, 0) ;Open the .app file
	If $file = -1 Then Return ''
	$EndOfFile = False
	Do ; Read in lines of text until the EOF is reached
		$line = FileReadLine($file)
		$EndOfFile = (@error = -1)
		$line = StringStripWS($line, 3)
		If $EndOfFile Then $line = ''
		While StringLeft($line, 1) = '<' ; new mode
			$Section = StringReplace(StringStripWS(StringReplace(StringMid($line, 2), '>', ''), 8), ' ', '')
			$KeepBlanks = False
			$line = FileReadLine($file)
			$EndOfFile = (@error = -1)
			$line = StringStripWS($line, 3)
			If $EndOfFile Then $line = ''
		WEnd
		If $line <> '' Or $KeepBlanks Then
			Switch $Section
				Case 'Title' ; <Title>
					$App_Title_Section[0] += 1
					ReDim $App_Title_Section[$App_Title_Section[0] + 1]
					$App_Title_Section[$App_Title_Section[0]] = $line
				Case 'Version' ; <Version>
					$App_Version_Section[0] += 1
					ReDim $App_Version_Section[$App_Version_Section[0] + 1]
					$App_Version_Section[$App_Version_Section[0]] = $line
				Case 'Description', 'about' ; <Description>
					$App_Description[0] += 1
					ReDim $App_Description[$App_Description[0] + 1]
					$App_Description[$App_Description[0]] = $line
					$KeepBlanks = True
				Case 'URL', 'web', 'urls' ; <Url>
					$App_URL[0] += 1
					ReDim $App_URL[$App_URL[0] + 1]
					$App_URL[$App_URL[0]] = $line
				Case 'Category', 'category', 'categories', 'Catagory'; <Category>
					$App_Category_Section[0] += 1
					ReDim $App_Category_Section[$App_Category_Section[0] + 1]
					$App_Category_Section[$App_Category_Section[0]] = $line
				Case 'BuildType', 'AppType' ;<BuildType>
					$App_Legacy = False
					$App_Type = $line
					Switch StringLower($App_Type)
						Case 'setups'
							$App_Type = 1
						Case 'ssapp'
							$App_Type = 2
						Case 'ppapp'
							$App_Type = 3
						Case 'pptweak'
							$App_Type = 4
						Case 'ppgame'
							$App_Type = 5
					EndSwitch
				Case 'OS', 'Operating System' ;<OS> 8 ;0=All, 1=NT5.x (2K/XP/2K3), 2=NT6.x (Vista/7), 3=Linux
					$App_OS = $line
					If StringLen($App_OS) > 0 Then $App_OS = StringLeft($App_OS, 2)
				Case 'Architecture', 'Arch' ;<Architecture> ;0=Any, 1=x86 (32-bit), 2=x64 (64-bit)
					;check that a flag has not already set this
					If $App_Architecture = '' Or $App_Architecture = 0 Then
						$App_Architecture = $line
						If StringLen($App_Architecture) > 0 Then
							Switch StringLeft($App_Architecture, 1)
								Case 1
									$App_Architecture = 1
								Case 2
									$App_Architecture = 2
								Case 3
									$App_Architecture = 3
								Case Else
									Select
										Case StringInStr($App_Architecture, 'x86')
											$App_Architecture = 1
										Case StringInStr($App_Architecture, 'x64') Or StringInStr($App_Architecture, 'IA64')
											$App_Architecture = 2
										Case StringInStr($App_Architecture, 'DualArch') Or (StringInStr($App_Architecture, 'x86') And StringInStr($App_Architecture, 'x64'))
											$App_Architecture = 3
										Case Else ;All
											$App_Architecture = 0
									EndSelect
							EndSwitch
						EndIf
					EndIf
				Case 'AppPath', 'InstallPath', 'InstallToPath' ; <AppPath>
					$AppValue = NoBackslash(ConvertFromVars(ConvertToVars($line)))
					If $ConvertVar Then
						$App_InstallPath = $AppValue
					Else
						$App_InstallPath = NoBackslash($line)
					EndIf
				Case 'Assembly', 'Install', 'Preinstall', 'Preprocessing', 'Assembler' ; <Assembly>
					$App_Assembly[0] += 1
					ReDim $App_Assembly[$App_Assembly[0] + 1]
					If $ConvertVar Then
						$App_Assembly[$App_Assembly[0]] = ConvertFromVars(ConvertToVars($line))
					Else
						$App_Assembly[$App_Assembly[0]] = $line
					EndIf
				Case 'StartMenuSourcePath', 'DefaultMenu', 'Default', 'DefaultStartMenu' ; <StartMenuSourcePath>
					If $ConvertVar Then
						$App_smSource = NoBackslash(ConvertFromVars(ConvertToVars($line)))
					Else
						$App_smSource = NoBackslash($line)
					EndIf
				Case 'Catalog', 'MenuCatalog', 'StartmenuCatalog' ;<Catalog>
					$App_Legacy = False
					$App_Catalog[0] += 1
					ReDim $App_Catalog[$App_Catalog[0] + 1]
					$App_Catalog[$App_Catalog[0]] = StringReplace($line, '"', '')
				Case 'StartMenuDestPath' ; <StartMenuDestPath>
					If $App_smLegacySecondary[0] = 0 Then
						$App_smLegacySecondary = StringSplit($line, '|')
						For $i = 1 To $App_smLegacySecondary[0]
							$App_smLegacySecondary[$i] = NoBackslash(StringStripWS($App_smLegacySecondary[$i], 3))
						Next
					Else ;first line or not
						$App_smLegacyPrimary = StringSplit(StringReplace(StringReplace($line, '_ ', '- '), '- Sound', '- Audio'), '|')
						For $i = 1 To $App_smLegacyPrimary[0]
							$App_smLegacyPrimary[$i] = NoBackslash(StringStripWS($App_smLegacyPrimary[$i], 3))
						Next
					EndIf
				Case 'Flags', 'Switches', 'Parameters' ; <Flags>
					$App_Flags_Section[0] += 1
					ReDim $App_Flags_Section[$App_Flags_Section[0] + 1]
					$App_Flags_Section[$App_Flags_Section[0]] = $line
				Case 'Meta' ; <Meta>
					$App_Meta_Section[0] += 1
					ReDim $App_Meta_Section[$App_Meta_Section[0] + 1]
					$App_Meta_Section[$App_Meta_Section[0]] = $line
				Case 'ShortcutS', 'ppApps', 'ppGames', 'ppApp', 'ppGame', 'Links' ; <ShortcutS>/<ppApps>
					$AppKey = StringLower(StringStripWS(StringLeft($line, StringInStr($line, '=') - 1), 8))
					$AppValue = StringStripWS(StringRight($line, StringLen($line) - StringInStr($line, '=', 1, 1)), 3)
					Switch $AppKey
						Case 'commandline', 'target', 'file', 'exe'
							$App_scCount += 2
							ReDim $App_scEXE[$App_scCount]
							ReDim $App_scWorkDir[$App_scCount]
							ReDim $App_scLNK[$App_scCount]
							ReDim $App_scDesc[$App_scCount]
							ReDim $App_scArgs[$App_scCount]
							ReDim $App_scIcon[$App_scCount]
							ReDim $App_scExt[$App_scCount]
							ReDim $App_scIndex[$App_scCount]
							ReDim $App_scState[$App_scCount]
							ReDim $App_scDefaults[$App_scCount]
							ReDim $App_scFlags[$App_scCount]
							ReDim $App_scCatalog[$App_scCount]
							ReDim $App_scKey[$App_scCount]
							$App_scCount -= 1
							If $ConvertVar Then
								$App_scEXE[$App_scCount] = NoBackslash(ConvertFromVars(ConvertToVars(StringReplace($AppValue, '"', ''))))
							Else
								$App_scEXE[$App_scCount] = NoBackslash(StringReplace($AppValue, '"', ''))
							EndIf
						Case 'startin', 'workingdir', 'workdir', 'workingpath', 'workpath', 'workingfolder', 'workfolder'
							If $ConvertVar Then
								$App_scWorkDir[$App_scCount] = NoBackslash(ConvertFromVars(ConvertToVars(StringReplace($AppValue, '"', ''))))
							Else
								$App_scWorkDir[$App_scCount] = NoBackslash(StringReplace($AppValue, '"', ''))
							EndIf
						Case 'shortcutname', 'linkname', 'link', 'name', 'lnk', 'shortcut'
							If $ConvertVar Then
								$App_scLNK[$App_scCount] = NoBackslash(ConvertFromVars(ConvertToVars(StringReplace($AppValue, '"', ''))))
							Else
								$App_scLNK[$App_scCount] = NoBackslash(StringReplace($AppValue, '"', ''))
							EndIf
						Case 'description', 'desc', 'comment'
							$App_scDesc[$App_scCount] = StringReplace($AppValue, '"', '')
							If StringLen($App_scDesc[$App_scCount]) >= $MAX_PATH Then $App_scDesc[$App_scCount] = StringLeft($App_scDesc[$App_scCount], $MAX_PATH - 4) & '...'
						Case 'arguments', 'parameters', 'args', 'params', 'switches', 'argument', 'parameter', 'arg', 'param', 'switch'
							If $ConvertVar Then
								$App_scArgs[$App_scCount] = NoBackslash(ConvertFromVars(ConvertToVars($AppValue)))
							Else
								$App_scArgs[$App_scCount] = NoBackslash($AppValue) ;StringReplace($AppValue, '"', '')
							EndIf
						Case 'shortcuticon', 'icon', 'shortcuticons', 'icons'
							If $ConvertVar Then
								$App_scIcon[$App_scCount] = NoBackslash(ConvertFromVars(ConvertToVars(StringReplace($AppValue, '"', ''))))
							Else
								$App_scIcon[$App_scCount] = NoBackslash(StringReplace($AppValue, '"', ''))
							EndIf
						Case 'iconindex', 'index', 'iconnumber', 'number'
							$App_scIndex[$App_scCount] = StringReplace($AppValue, '"', '')
						Case 'extension', 'ext', 'extensions'
							$App_scExt[$App_scCount] = NormalizeAssocExts($AppValue)
						Case 'state', 'launch', 'windowstate', 'launchstate'
							$App_scState[$App_scCount] = StringReplace($AppValue, '"', '')
						Case 'defaultmenu', 'default'
							If $ConvertVar Then
								$App_scDefaults[$App_scCount] = NoBackslash(ConvertFromVars(ConvertToVars(StringReplace($AppValue, '"', ''))))
							Else
								$App_scDefaults[$App_scCount] = NoBackslash(StringReplace($AppValue, '"', ''))
							EndIf
						Case 'menucatalog', 'catalog', 'startmenucatalog'
							$App_scCatalog[$App_scCount] = StringReplace($AppValue, '"', '')
						Case 'flags', 'flag'
							$App_scFlags[$App_scCount] = StringReplace($AppValue, '"', '')
					EndSwitch
				Case 'ShortcutNamesKeep', 'ShortcutNamesToKeep', 'ShortcutNamesMake', 'ShortcutNameKeep', 'ShortcutNameMake', 'ShortcutsKeep', 'ShortcutsMake', 'ShortcutKeep', 'ShortcutMake' ; <ShortcutNamesKeep>
					If $line <> '' Then
						$App_scKeep[0] += 1
						ReDim $App_scKeep[$App_scKeep[0] + 1]
						$App_scKeep[$App_scKeep[0]] = StringReplace($line, '"', '')
					EndIf
				Case 'FileTypes', 'Extensions', 'Filetype', 'Extension', 'Associations', 'Association', 'FileAssociations', 'FileAssociation' ;<FileTypes>
					$App_FileType[0] += 1
					ReDim $App_FileType[$App_FileType[0] + 1]
					$App_FileType[$App_FileType[0]] = $line
				Case 'InstallFonts', 'InstallFont' ;<InstallFonts>
					$App_InstallFonts[0] += 1
					ReDim $App_InstallFonts[$App_InstallFonts[0] + 1]
					If $ConvertVar Then
						$App_InstallFonts[$App_InstallFonts[0]] = ConvertFromVars(ConvertToVars($line))
					Else
						$App_InstallFonts[$App_InstallFonts[0]] = $line
					EndIf
				Case 'RegisterDLL', 'RegisterDLLs', 'RegisterOCX', 'RegisterOCXs', 'regsvr', 'regsvr32' ;<RegisterDLL>
					$App_RegisterDLL[0] += 1
					ReDim $App_RegisterDLL[$App_RegisterDLL[0] + 1]
					$App_RegisterDLL[$App_RegisterDLL[0]] = $line
				Case 'Script', 'Batch', 'Postprocessing', 'ProcessCMD', 'ProcessBAT' ;<Script>
					$KeepBlanks = True
					$App_Script[0] += 1
					ReDim $App_Script[$App_Script[0] + 1]
					If $ConvertVar Then
						$App_Script[$App_Script[0]] = ConvertFromVars(ConvertToVars($line))
					Else
						$App_Script[$App_Script[0]] = $line
					EndIf
				Case 'Registry', 'RegEntries', 'ImportRegistry', 'ImportReg', 'ProcessRegistry', 'ProcessReg' ;<Registry>
					$KeepBlanks = True
					$App_RegEntries[0] += 1
					ReDim $App_RegEntries[$App_RegEntries[0] + 1]
					If $ConvertVar Then
						$App_RegEntries[$App_RegEntries[0]] = ConvertFromVars(ConvertToVars($line, True), True)
					Else
						$App_RegEntries[$App_RegEntries[0]] = $line
					EndIf
				Case 'InstallInstant' ;<InstallInstant>
					$App_InstallInstant = ($line = 1) Or ($line = 'yes') Or ($line = 'true')
				Case 'DuringSetupOnly' ;<DuringSetupOnly>
					$App_DuringSetupOnly = ($line = 1) Or ($line = 'yes') Or ($line = 'true')
				Case 'Selected' ;<Selected>
					; ???
				Case 'PriorityOrder' ;<PriorityOrder>
					; ???
					$App_PriorityOrder = $line
				Case 'End'
					$EndOfFile = True
					$line = ''
			EndSwitch
		EndIf
	Until $EndOfFile
	FileClose($file)
	; some adjustments...
	If IsArray($App_Title_Section) Then
		For $i = $App_Title_Section[0] To 1 Step -1 ; Set to last line without a semi-colon
			If StringLeft($App_Title_Section[$i], 1) <> ';' Then
				$App_Title = $App_Title_Section[$i]
				ExitLoop
			EndIf
		Next
	EndIf
	If IsArray($App_Version_Section) Then
		For $i = $App_Version_Section[0] To 1 Step -1 ; Set to last line without a semi-colon
			If StringLeft($App_Version_Section[$i], 1) <> ';' Then
				$App_Version = $App_Version_Section[$i]
				ExitLoop
			EndIf
		Next
	EndIf
	If IsArray($App_Category_Section) Then
		For $i = $App_Category_Section[0] To 1 Step -1 ; Set to last line without a semi-colon
			If StringLeft($App_Category_Section[$i], 1) <> ';' Then
				$App_Category = StringSplit(StringReplace($App_Category_Section[$i], 'Games\Games', 'Games', 0), '|')
				ExitLoop
			EndIf
		Next
	EndIf
	If IsArray($App_Description) Then
		If $App_Description[$App_Description[0]] = '' Then ; remove trailing blank line
			If $App_Description[0] > 0 Then
				ReDim $App_Description[$App_Description[0]]
				$App_Description[0] -= 1
			EndIf
		EndIf
	EndIf
	If IsArray($App_Flags_Section) Then
		For $i = 1 To $App_Flags_Section[0]
			If StringLeft($App_Flags_Section[$i], 1) <> ';' Then
				$line = $App_Flags_Section[$i]
				$AppKey = StringReplace(StringLower(StringStripWS(StringLeft($line, StringInStr($line, '=') - 1), 8)), ' ', '')
				$AppValue = StringLower(StringReplace(StringStripWS(StringRight($line, StringLen($line) - StringInStr($line, '=', 1, 1)), 8), '"', ''))
				$AppValue = ($AppValue = 1) Or ($AppValue = 'yes') Or ($AppValue = 'true')
				Switch $AppKey
					;Shortcut Options
					Case 'makestart', 'keepstart', 'makestartmenushortcuts', 'makeinstartmenu', 'makestartmenu', 'keepinstartmenu', 'keepstartmenu'
						$App_MakeStartMenu = $AppValue
					Case 'keepinroot', 'makeinroot'
						$App_MakeInRoot = $AppValue
					Case 'makeinprograms', 'keepinprograms'
						$App_MakeInPrograms = $AppValue
					Case 'makestartup', 'makeinstartup', 'keepstartup', 'keepinstartup'
						$App_MakeStartup = $AppValue
					Case 'makedesktop', 'keepdesktop'
						$App_MakeDesktop = $AppValue
					Case 'makequicklaunch', 'keepquicklaunch'
						$App_MakeQuickLaunch = $AppValue
					Case 'maketaskbarpin', 'keeptaskbarpin', 'taskbarpin'
						$App_TaskbarPin = $AppValue
					Case 'makestartmenupin', 'keepstartmenupin', 'startmenupin'
						$App_StartmenuPin = $AppValue
					Case 'makesendto'
						$App_MakeSendTo = $AppValue
					Case 'neversort', 'nosorting', 'noshortcuts'
						$App_NeverSort = $App_NeverSort Or $AppValue
					Case 'alwayssort'
						$App_AlwaysSort = $AppValue
					Case 'keepinfolder'
						$App_KeepInFolder = $AppValue
					Case 'keepallshortcuts', 'keepall'
						$App_KeepAll = $AppValue
						$App_UseLegacyKeepInFolderRules = False
					Case 'refreshexplorer', 'refreshdesktop'
						$App_RefreshExplorer = $AppValue
					Case 'noicons', 'nomenuicons'
						$App_NoIcons = $AppValue
					Case 'allusers'
						$App_AllUsers = $AppValue
					Case 'livepe'
						$App_LivePE = $AppValue
						;ssWPI Options
					Case 'alwaysshow'
						$App_AlwaysShow = $AppValue
					Case 'alwayshide'
						$App_AlwaysHide = $AppValue
					Case 'duringsetuponly'
						$App_DuringSetupOnly = $AppValue
					Case 'installt13'
						$App_InstallT13 = $AppValue
					Case 'x86only'
						If $AppValue Then
							$App_Architecture = 1
							$App_Runx64 = False
						EndIf
					Case 'runx64', 'x64only'
						$App_Runx64 = $AppValue
						If $App_Runx64 Then $App_Architecture = 2
					Case 'installinstant'
						$App_InstallInstant = $AppValue
					Case 'PriorityOrder'
						$App_PriorityOrder = $AppValue
						;Post-processing Options
					Case 'nonething'
						$App_NoneThing = $AppValue
					Case 'AssemblyNoWait'
						$App_AssemblyNoWait = $AppValue
					Case 'UpdateAppFile'
						$App_UpdateAppFile = $AppValue
					Case 'MetroFriendly'
						$App_MetroFriendly = $AppValue
				EndSwitch
			EndIf
		Next
	EndIf
	If IsArray($App_Meta_Section) Then
		For $i = 1 To $App_Meta_Section[0]
			If StringLeft($App_Meta_Section[$i], 1) <> ';' Then
				$line = $App_Meta_Section[$i]
				$AppKey = StringReplace(StringLower(StringStripWS(StringLeft($line, StringInStr($line, '=') - 1), 8)), ' ', '')
				$AppValue = StringStripWS(StringRight($line, StringLen($line) - StringInStr($line, '=', 1, 1)), 3)
				Switch $AppKey
					;Shortcut Options
					Case 'Tags'
						$App_Tags = SingleLine2Multi($AppValue, '|')
					Case 'publisher', 'developer'
						$App_Publisher = $AppValue
					Case 'language'
						$App_Language = $AppValue
					Case 'Releaser'
						$App_Releaser = $AppValue
					Case 'Additional'
						$App_Additional = $AppValue
					Case 'Rating'
						$App_Rating = $AppValue
					Case 'RequiredRuntimes'
						$App_RequiredRuntimes = $AppValue
					Case 'ReleaseDate', 'ReleasedDate', 'DateOfRelease'
						$App_ReleaseDate = $AppValue
					Case 'ReleaseVersion', 'ReleasedVersion', 'VersionOfRelease'
						$App_ReleaseVersion = $AppValue
					Case 'LicenseType', 'License'
						$App_LicenseType = StringLeft($AppValue, 1)
						Switch $App_LicenseType
							Case 1, 2, 3
							Case Else
								$App_LicenseType = 0
						EndSwitch
					Case 'InstalledSize', 'ExtractedSize'
						$App_InstalledSize = $AppValue
				EndSwitch
			EndIf
		Next
	EndIf
	If IsArray($App_Script) And $App_Script[0] > 0 Then ; <Registry> present
		If $App_Script[$App_Script[0]] = '' Then ; remove trailing blank line
			ReDim $App_Script[$App_Script[0]]
			$App_Script[0] -= 1
		EndIf; Convert to external
		$App_CmdFile = Multi2SingleLine($App_Script, @CRLF)
		ReDim $App_Script[1]
		$App_Script[0] = 0
	EndIf
	If IsArray($App_RegEntries) And $App_RegEntries[0] > 0 Then ; <Registry> present
		If $App_RegEntries[$App_RegEntries[0]] = '' Then ; remove trailing blank line
			ReDim $App_RegEntries[$App_RegEntries[0]]
			$App_RegEntries[0] -= 1
		EndIf; Convert to external
		$App_RegFile = Multi2SingleLine($App_RegEntries, @CRLF)
		ReDim $App_RegEntries[1]
		$App_RegEntries[0] = 0
	EndIf
	If $App_Type = 0 Then ; Find Application Type: 1 to 2 are SetupS/ssApp's, 3 to 4 are ppApp's, and 5 is ppGame's
		Select
			Case (StringRight($What, StringLen('\SetupS.app')) = '\SetupS.app') Or (StringRight($What, StringLen('\SetupS.ini')) = '\SetupS.ini')
				$App_Type = 1
			Case (StringRight($What, StringLen('\ssApp.app')) = '\ssApp.app')
				$App_Type = 2
			Case (StringRight($What, StringLen('\ppApp.app')) = '\ppApp.app') Or (StringRight($What, StringLen('\ppApp.ini')) = '\ppApp.ini')
				$App_Type = 3
			Case (StringRight($What, StringLen('\ppTweak.app')) = '\ppTweak.app')
				$App_Type = 4
			Case (StringRight($What, StringLen('\ppGame.ppg')) = '\ppGame.ppg')
				$App_Type = 5
			Case Else
				EndGame('Error (4094 Core) ' & $ThisAppTitle & ':', '"' & $What & '" is not a recognized SetupS file.', False, 20, True)
		EndSelect
	EndIf
	If $App_Runx64 Then $App_Architecture = 2
	If $App_UseLegacyKeepInFolderRules Then ; no KeepAll flag
		If $App_Type > 2 Then ;ppApp/ppGame
			If $App_scKeep[0] = 0 Then
				$App_KeepAll = True
			Else
				$App_KeepAll = $App_KeepInFolder
			EndIf
		Else ;ssApp
			$App_KeepAll = $App_KeepInFolder
		EndIf
	EndIf
EndFunc

Func _AppReset()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|_AppReset()' & @CRLF)
	$TempDir = GenerateTempFolder($TempDir)
	$App_OSArchGated = False

	;strings
	$App_File = ''
	$App_Title = ''
	$App_Version = ''
	$App_smSource = ''
	$App_InstallPath = ''
	$App_TDStamp = ''
	$App_CmdFile = ''
	$App_RegFile = ''

	$App_Publisher = ''
	$App_Language = ''
	$App_Releaser = ''
	$App_Additional = ''
	$App_ReleaseDate = ''
	$App_ReleaseVersion = ''
	$App_Rating = ''
	$App_InstalledSize = ''
	$App_RequiredRuntimes = ''

	;values
	$App_Architecture = 0
	$App_OS = 0
	$App_Type = 0
	$App_scCount = 0
	$App_LicenseType = 0
	$App_FileVersion = 0
	$App_FileFormat = 0
	$App_PriorityOrder = 5

	;flags
	$App_KeepInFolder = False
	$App_MakeInRoot = False
	$App_MakeInPrograms = False
	$App_MakeStartMenu = True
	$App_MakeStartup = False
	$App_MakeDesktop = False
	$App_Runx64 = False
	$App_MakeQuickLaunch = False
	$App_TaskbarPin = False
	$App_StartmenuPin = False
	$App_RefreshExplorer = False
	$App_MakeSendTo = False
	$App_AlwaysSort = False
	$App_NeverSort = False
	$App_KeepAll = False
	$App_AlwaysShow = False
	$App_AlwaysHide = False
	$App_DuringSetupOnly = False
	$App_InstallT13 = False
	$App_InstallInstant = False
	$App_NoIcons = False
	$App_AllUsers = True
	$App_LivePE = False
	$App_NoneThing = False
	$App_UpdateAppFile = True
	$App_MetroFriendly = True
	$App_ssUninstall = True
	$App_AssemblyNoWait = False

	;arrays
	ReDim $App_Category[1]
	$App_Category[0] = 0
	ReDim $App_Tags[1]
	$App_Tags[0] = 0
	ReDim $App_Assembly[1]
	$App_Assembly[0] = 0
	ReDim $App_scKeep[1]
	$App_scKeep[0] = 0
	ReDim $App_FileType[1]
	$App_FileType[0] = 0
	ReDim $App_Script[1]
	$App_Script[0] = 0
	ReDim $App_RegEntries[1]
	$App_RegEntries[0] = 0
	ReDim $App_StartMenu[1]
	$App_StartMenu[0] = 0
	ReDim $App_smLegacySecondary[1]
	$App_smLegacySecondary[0] = 0
	ReDim $App_smLegacyPrimary[1]
	$App_smLegacyPrimary[0] = 0
	ReDim $App_URL[1]
	$App_URL[0] = 0
	ReDim $App_Description[1]
	$App_Description[0] = 0
	ReDim $App_InstallFonts[1]
	$App_InstallFonts[0] = 0
	ReDim $App_Catalog[1]
	$App_Catalog[0] = 0
	ReDim $App_RegisterDLL[1]
	$App_RegisterDLL[0] = 0
	ReDim $App_Title_Section[1]
	$App_Title_Section[0] = 0
	ReDim $App_Version_Section[1]
	$App_Version_Section[0] = 0
	ReDim $App_Category_Section[1]
	$App_Category_Section[0] = 0
	ReDim $App_Flags_Section[1]
	$App_Flags_Section[0] = 0
	ReDim $App_Meta_Section[1]
	$App_Meta_Section[0] = 0
	UIReset()

	;ShortcutS
	ReDim $App_scEXE[1]
	$App_scEXE[0] = 0
	ReDim $App_scWorkDir[1]
	$App_scWorkDir[0] = 0
	ReDim $App_scLNK[1]
	$App_scLNK[0] = 0
	ReDim $App_scDesc[1]
	$App_scDesc[0] = 0
	ReDim $App_scArgs[1]
	$App_scArgs[0] = 0
	ReDim $App_scIcon[1]
	$App_scIcon[0] = 0
	ReDim $App_scExt[1]
	$App_scExt[0] = 0
	ReDim $App_scIndex[1]
	$App_scIndex[0] = 0
	ReDim $App_scState[1]
	$App_scState[0] = 0
	ReDim $App_scDefaults[1]
	$App_scDefaults[0] = 0
	ReDim $App_scFlags[1]
	$App_scFlags[0] = 0
	ReDim $App_scCatalog[1]
	$App_scCatalog[0] = 0
	ReDim $App_scKey[1]
	$App_scKey[0] = 0

	GetMenuStyle()
EndFunc

Func _AppUpdate($What, $AppFileFormat = 2)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|_AppUpdate(): $What=' & $What & @CRLF)
	If $What <> '' Then
		Local $i, $j, $temp, $file, $ShortcutS, $found, $dup, $key, $value
		$App_FileFormat = $AppFileFormat
		If $App_Title = '' Then $App_Title = GetFilename(GetFolderPath(_PathFull($What)))
		IniWrite($What, 'SetupS', 'Title', $App_Title) ; Required
		IniUpdate($What, 'SetupS', 'Version', $App_Version)
		IniUpdate($What, 'SetupS', 'Description', $App_Description)
		IniUpdate($What, 'SetupS', 'URL', $App_URL, '|')
		IniUpdate($What, 'SetupS', 'Category', $App_Category, '|')
		Switch $App_OS
			Case 0, 15
				$temp = ''
			Case 1
				$temp = '1 (2K/XP/2K3)'
			Case 2
				$temp = '2 (Vista/7)'
			Case 3
				$temp = '3 (2K/XP/2K3/Vista/7)'
			Case 4
				$temp = '4 (8/8.1)'
			Case 5
				$temp = '5 (2K/XP/2K3/8/8.1)'
			Case 6
				$temp = '6 (Vista/7/8/8.1)'
			Case 7
				$temp = '7 (2K/XP/2K3/Vista/7/8/8.1)'
			Case 8
				$temp = '8 (10)'
			Case 9
				$temp = '9 (2K/XP/2K3/10)'
			Case 10
				$temp = '10 (Vista/7/10)'
			Case 11
				$temp = '11 (2K/XP/2K3/Vista/7/10)'
			Case 12
				$temp = '12 (8/8.1/10)'
			Case 13
				$temp = '13 (2K/XP/2K3/8/8.1/10)'
			Case 14
				$temp = '14 (Vista/7/8/8.1/10)'
		EndSwitch
		IniUpdate($What, 'SetupS', 'OS', $temp)
		Switch $App_Architecture
			Case 1
				$temp = '1 (x86)'
			Case 2
				$temp = '2 (x64)'
			Case 3
				$temp = '3 (DualArch)'
			Case Else
				$temp = ''
		EndSwitch
		IniUpdate($What, 'SetupS', 'Architecture', $temp)
		Switch $App_Type
			Case 1
				$temp = 'SetupS'
			Case 2
				$temp = 'ssApp'
			Case 3
				$temp = 'ppApp'
			Case 4
				$temp = 'ppTweak'
			Case 5
				$temp = 'ppGame'
			Case Else
				$temp = ''
		EndSwitch
		IniUpdate($What, 'SetupS', 'BuildType', $temp)
		IniWrite($What, 'SetupS', 'App-File Version', $SetupSFileVersion) ; Internal
		IniDelete($What, 'SetupS', 'App-File Format')
		Switch $App_FileFormat
			Case 1
				$temp = '1 (Dual)'
			Case Else ; 0, 2, 4
				$temp = '2 (INI)'
		EndSwitch
		IniWrite($What, 'SetupS', 'App-File Style', $temp) ; Internal
		IniUpdate($What, 'SetupS', 'AppPath', $App_InstallPath)
		IniUpdate($What, 'SetupS', 'Assembly', $App_Assembly)
		IniUpdate($What, 'SetupS', 'StartMenuSourcePath', $App_smSource)
		IniUpdate($What, 'SetupS', 'Catalog', $App_Catalog, '|')
		IniUpdate($What, 'SetupS', 'StartMenuLegacyPrimary', $App_smLegacyPrimary, '|')
		IniUpdate($What, 'SetupS', 'StartMenuLegacySecondary', $App_smLegacySecondary, '|')
		IniUpdate($What, 'SetupS', 'ShortCutNamesKeep', $App_scKeep, '|')
		IniUpdate($What, 'SetupS', 'FileTypes', $App_FileType, '|')
		IniUpdate($What, 'SetupS', 'InstallFonts', $App_InstallFonts, '|')
		IniUpdate($What, 'SetupS', 'RegisterDLL', $App_RegisterDLL, '|')
		If $App_PriorityOrder = 5 Then $App_PriorityOrder = ''
		IniUpdate($What, 'SetupS', 'PriorityOrder', $App_PriorityOrder)
		If $App_PriorityOrder = '' Then $App_PriorityOrder = 5
		$temp = Multi2SingleLine($App_Assembly)
		If StringInStr($temp, "%ClickMe%") Or StringInStr($temp, "%CloseMe%") Or StringInStr($temp, "%SelectMe%") Or StringInStr($temp, "%SendMe%") Or StringInStr($temp, "%WaitForIt%") Or StringInStr($temp, "%WaitForMe%") Or StringInStr($temp, "%ProcessKill%") Then $App_AssemblyNoWait = True
		$temp = '' ; <Flags>
		If $App_Type <> 4 Then ;Shortcut options
			If Not $App_MakeStartMenu Then AddFlag($temp, 'NotInStartmenu')
			If $App_KeepInFolder Then AddFlag($temp, 'KeepInFolder')
			If $App_KeepAll Then AddFlag($temp, 'KeepAll')
			If $App_MakeInRoot Then AddFlag($temp, 'Root')
			If $App_MakeInPrograms Then AddFlag($temp, 'Programs')
			If $App_MakeStartup Then AddFlag($temp, 'Startup')
			If $App_MakeDesktop Then AddFlag($temp, 'Desktop')
			If $App_MakeQuickLaunch Then AddFlag($temp, 'QuickLaunch')
			If $App_TaskbarPin Then AddFlag($temp, 'TaskbarPin')
			If $App_StartmenuPin Then AddFlag($temp, 'StartmenuPin')
			If $App_MakeSendTo Then AddFlag($temp, 'SendTo')
			If $App_NeverSort Then AddFlag($temp, 'NoShortcuts')
			If $App_AlwaysSort Then AddFlag($temp, 'AlwaysSort')
			If Not $App_AllUsers Then AddFlag($temp, 'CurrentUserOnly')
			If $App_NoIcons Then AddFlag($temp, 'NoMenuIcons')
			If Not $App_UpdateAppFile Then AddFlag($temp, 'NotUpdateAppFile')
			If Not $App_MetroFriendly Then AddFlag($temp, 'NotMetroFriendly')
			If Not $App_ssUninstall Then AddFlag($temp, 'NotssUninstall')
		EndIf
		If $App_LivePE Then AddFlag($temp, 'LivePE')
		If $App_RefreshExplorer Then AddFlag($temp, 'RefreshDesktop')
		If $App_AlwaysShow Then AddFlag($temp, 'AlwaysShow')
		If $App_AlwaysHide Then AddFlag($temp, 'AlwaysHide')
		If $App_DuringSetupOnly Then AddFlag($temp, 'DuringSetupOnly')
		If $App_InstallT13 Then AddFlag($temp, 'InstallT13')
		If $App_InstallInstant Then AddFlag($temp, 'InstallInstant')
		If $App_NoneThing Then AddFlag($temp, 'NoneThing')
		If $App_AssemblyNoWait Then AddFlag($temp, 'AssemblyNoWait')

		IniUpdate($What, 'SetupS', 'Flags', $temp)
		IniUpdate($What, 'Meta', 'Tags', $App_Tags, '|')
		IniUpdate($What, 'Meta', 'Publisher', $App_Publisher)
		IniUpdate($What, 'Meta', 'Language', $App_Language)
		IniUpdate($What, 'Meta', 'Releaser', $App_Releaser)
		IniUpdate($What, 'Meta', 'Additional', $App_Additional)
		IniUpdate($What, 'Meta', 'ReleaseDate', $App_ReleaseDate)
		IniUpdate($What, 'Meta', 'ReleaseVersion', $App_ReleaseVersion)
		IniUpdate($What, 'Meta', 'Rating', $App_Rating)
		IniUpdate($What, 'Meta', 'RequiredRuntimes', $App_RequiredRuntimes)
		IniUpdate($What, 'Meta', 'InstalledSize', $App_InstalledSize)
		Switch $App_LicenseType
			Case 1
				$temp = '1 (non-gratis)'
			Case 2
				$temp = '2 (gratis-only)'
			Case 3
				$temp = '3 (libre)'
			Case Else
				$temp = ''
		EndSwitch
		IniUpdate($What, 'Meta', 'LicenseType', $temp)
		If $ssUninstallRecover And $App_Uninstall[0][0] = 0 And $App_InstallPath <> '' Then $App_Uninstall = GetUninstallData($App_InstallPath)
		For $i = 1 To $App_Uninstall[0][0]
			If $App_Uninstall[$i][0] <> '' Then
				If $App_Uninstall[$i][4] <> '' Then
					$key = GetUninstallKey($App_Uninstall[$i][0], $value)
					If $key <> '' And $value <> '' Then
						If $ssUninstall And $App_ssUninstall Then
							If RegRead($key, 'ssUninstallRecovery') = '' Then
								$App_Uninstall[$i][6] = 'ssControlPanel -uninstall="' & $App_InstallPath & '"'
								RegWrite($key, 'ssUninstallRecovery', 'REG_SZ', ConvertFromVars(RegRead($key, 'UninstallString')))
								RegWrite($key, 'UninstallString', 'REG_SZ', ConvertFromVars($App_Uninstall[$i][6]))
							EndIf
						Else
							If RegRead($key, 'ssUninstallRecovery') <> '' Then
								RegWrite($key, 'UninstallString', 'REG_SZ', ConvertFromVars(RegRead($key, 'ssUninstallRecovery')))
								RegDelete($key, 'ssUninstallRecovery')
								$App_Uninstall[$i][6] = ''
							EndIf
						EndIf
					EndIf
				EndIf
				;If StringLeft($App_Uninstall[$i][4], 1) <> ':' Then $App_Uninstall[$i][4] = ':' & $App_Uninstall[$i][4] ;preserve quoted string
				$temp = 'UninstallKey.' & $App_Uninstall[$i][0]
				IniUpdate($What, $temp, 'DisplayName', $App_Uninstall[$i][1])
				IniUpdate($What, $temp, 'UninstallString', $App_Uninstall[$i][4])
				IniUpdate($What, $temp, 'InstallLocation', $App_Uninstall[$i][2])
				IniUpdate($What, $temp, 'DisplayIcon', $App_Uninstall[$i][3])
				IniUpdate($What, $temp, 'Switches', $App_Uninstall[$i][5])
				IniUpdate($What, $temp, 'Script', $App_Uninstall[$i][6])
				If StringLeft($App_Uninstall[$i][4], 1) = ':' Then $App_Uninstall[$i][4] = StringMid($App_Uninstall[$i][4], 2)
			EndIf
		Next
		For $i = 1 To $App_scCount - 1 ;check for any "duplicates"
			$dup = 1
			For $j = $i + 1 To $App_scCount
				If $App_scLNK[$i] = $App_scLNK[$j] Then
					$dup += 1
					$App_scLNK[$j] = $App_scLNK[$j] & ' {#' & $dup & '}'
				EndIf
			Next
			If $dup > 1 Then $App_scLNK[$i] = $App_scLNK[$i] & ' {#1}'
		Next
		$ShortcutS = IniReadSectionNames($What) ; <ShortcutS>
		If IsArray($ShortcutS) Then
			For $i = 1 To $ShortcutS[0]
				If StringRight($ShortcutS[$i], 4) = '.lnk' Then
					$found = False
					For $j = 1 To $App_scCount
						If $App_scLNK[$j] & '.lnk' = $ShortcutS[$i] Then
							$found = True
							ExitLoop
						EndIf
					Next
					If Not $found Or $App_scReset Then IniDelete($What, $ShortcutS[$i])
				EndIf
			Next
		EndIf
		For $i = 1 To $App_scCount
			If $App_scEXE[$i] <> '' And $App_scLNK[$i] <> '' Then
				$App_scFlags[$i] = StringReplace($App_scFlags[$i], '#Is_x86#', 'Is_x86')
				$App_scFlags[$i] = StringReplace($App_scFlags[$i], '#Is_x64#', 'Is_x64')
				$App_scFlags[$i] = StringReplace($App_scFlags[$i], 'Is_86', 'Is_x86')
				$App_scFlags[$i] = StringReplace($App_scFlags[$i], 'Is_64', 'Is_x64')
				If StringInStr($App_scLNK[$i], ' {#') Then
					$App_scLNK[$i] = StringReplace($App_scLNK[$i], ' {#1} {#', ' {#')
					If StringInStr($App_scWorkDir[$i], '_x86') Or StringInStr($App_scLNK[$i], '_x86') Then
						If $App_scFlags[$i] = '' Then
							$App_scFlags[$i] = 'Is_x86'
						ElseIf StringInStr($App_scFlags[$i], 'Is_x86') = 0 Then
							$App_scFlags[$i] += '|Is_x86'
						EndIf
					EndIf
					If StringInStr($App_scWorkDir[$i], '_x64') Or StringInStr($App_scLNK[$i], '_x64') Then
						If $App_scFlags[$i] = '' Then
							$App_scFlags[$i] = 'Is_x64'
						ElseIf StringInStr($App_scFlags[$i], 'Is_x64') = 0 Then
							$App_scFlags[$i] += '|Is_x64'
						EndIf
					EndIf
				EndIf
				$temp = $App_scLNK[$i] & '.lnk'
				IniWrite($What, $temp, 'Target', $App_scEXE[$i]) ; Required
				If StringInStr($App_scWorkDir[$i], $App_InstallPath) Then
					Select
						Case $App_scWorkDir[$i] = $App_InstallPath
							$App_scWorkDir[$i] = ''
						Case StringInStr($App_scWorkDir[$i], '\') And StringInStr($App_scWorkDir[$i], $App_InstallPath & '\')
							$App_scWorkDir[$i] = StringMid($App_scWorkDir[$i], StringInStr($App_scWorkDir[$i], $App_InstallPath & '\') + StringLen($App_InstallPath & '\'))
					EndSelect
				EndIf
				IniUpdate($What, $temp, 'StartIn', $App_scWorkDir[$i])
				IniUpdate($What, $temp, 'Arguments', $App_scArgs[$i])
				If StringInStr($App_scIcon[$i], '\') > 0 And StringInStr($App_scIcon[$i], $App_InstallPath) = 1 Then $App_scIcon[$i] = StringMid($App_scIcon[$i], StringLen($App_InstallPath) + 2)
				IniUpdate($What, $temp, 'Icon', $App_scIcon[$i])
				IniUpdate($What, $temp, 'Index', $App_scIndex[$i], '', '0')
				IniUpdate($What, $temp, 'Extensions', NormalizeAssocExts($App_scExt[$i]))
				IniUpdate($What, $temp, 'Launch State', $App_scState[$i], '', @SW_SHOWNORMAL)
				IniUpdate($What, $temp, 'DefaultMenu', $App_scDefaults[$i])
				IniUpdate($What, $temp, 'Flags', $App_scFlags[$i])
				IniUpdate($What, $temp, 'Catalog', $App_scCatalog[$i])
				IniUpdate($What, $temp, 'Hotkey', $App_scKey[$i])
				IniUpdate($What, $temp, 'Comment', $App_scDesc[$i])
			EndIf
		Next
		$App_scReset = False
		Local $Meta_Data = IniReadSection($What, 'Meta')
		If Not IsArray($Meta_Data) Or $Meta_Data[0][0] = 0 Then IniDelete($What, 'Meta')
	EndIf
	Return $What
EndFunc

Func _AppWrite($What, $Mode = '')
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|_AppWrite(): $What=' & $What & @CRLF)
	Local $temp = GetFolderPath($What) & '\' & GetAppTypeBase($App_Type), $file, $i
	ConvertBackAllPathVars()
	While FileExists(_GetAuxFilename(GetFolderPath($What), '.bat'))
		DeleteMe(_GetAuxFilename(GetFolderPath($What), '.bat'))
	WEnd
	While FileExists(_GetAuxFilename(GetFolderPath($What), '.cmd'))
		DeleteMe(_GetAuxFilename(GetFolderPath($What), '.cmd'))
	WEnd
	If $App_CmdFile <> '' Then
		If Not String2File($App_CmdFile, $temp & '.cmd') Then EndGame('Error (4460 Core) ' & $ThisAppTitle & ':', 'Problem writing file: "' & $temp & '.cmd"', False, 20, True)
	EndIf
	While FileExists(_GetAuxFilename(GetFolderPath($What), '.reg'))
		DeleteMe(_GetAuxFilename(GetFolderPath($What), '.reg'))
	WEnd
	If $App_RegFile <> '' Then
		If Not String2File($App_RegFile, $temp & '.reg') Then EndGame('Error (4466 Core) ' & $ThisAppTitle & ':', 'Problem writing file: "' & $temp & '.reg"', False, 20, True)
	EndIf
	If IsArray($App_Catalog) Then ;Sync the legacy Startmenus
		ReDim $App_smLegacySecondary[1], $App_smLegacyPrimary[1]
		$App_smLegacySecondary[0] = 0
		$App_smLegacyPrimary[0] = 0
		If IsArray($App_smLegacySecondary) Then Catalog2Menu($App_smLegacySecondary, 2)
		If IsArray($App_smLegacyPrimary) Then Catalog2Menu($App_smLegacyPrimary, 1)
	EndIf
	If $App_Type = 4 Then ; the special ppApp case: ppTweak
		$App_MakeStartMenu = False
		$App_scCount = 0
		$App_Category[0] = 1
		ReDim $App_Category[$App_Category[0] + 1]
		$App_Category[1] = 'Tweaks'
		ReDim $App_Tags[1]
		$App_Tags[0] = 0
		$App_smSource = ''
		ReDim $App_scKeep[1]
		$App_scKeep[0] = 0
		ReDim $App_FileType[1]
		$App_FileType[0] = 0
		ReDim $App_StartMenu[1]
		$App_StartMenu[0] = 0
		ReDim $App_smLegacySecondary[1]
		$App_smLegacySecondary[0] = 0
		ReDim $App_smLegacyPrimary[1]
		$App_smLegacyPrimary[0] = 0
		ReDim $App_Catalog[1]
		$App_Catalog[0] = 0
		ReDim $App_Assembly[1]
		$App_Assembly[0] = 0
	EndIf
	If $App_Runx64 Then $App_Architecture = 2
	If IsArray($App_FileType) Then $App_FileType = SingleLine2Multi(StringReplace(NormalizeAssocExts(StringReplace(Multi2SingleLine($App_FileType), $ssEOL, ' ')), ' ', $ssEOL))
	#cs
		Copies to scKeep list first shortcut from Defs list:
		If $App_scKeep[0] = 0 And $App_scCount > 0 Then
		$App_scKeep[0] = 1
		ReDim $App_scKeep[2]
		$App_scKeep[1] = $App_scLNK[1]
		EndIf
	#ce
	If $Mode = '' Then
		If VersionCompare($SetupSFileVersion, '>', '8') Then ;GetVersionNumber($SetupSFileVersion) > 8
			If $App_FileFormat = 0 Then
				$Mode = 'New'
			Else
				$Mode = 'Update'
			EndIf
		Else ; 'Legacy' still
			$Mode = 'Legacy'
		EndIf
	EndIf
	Switch $Mode
		Case 'New'
			DeleteMe($What)
			Return _AppUpdate($What)
		Case 'Update'
			Return _AppUpdate($What)
		Case 'Legacy', 'Old'
			Return _AppWrite_Legacy($What)
		Case 'Dual'
			Return _AppUpdate(_AppWrite_Legacy($What), 1)
	EndSwitch
EndFunc

Func _AppWrite_Legacy($AppFile)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|_AppWrite_Legacy(): $AppFile=' & $AppFile & @CRLF)
	Local $file, $i, $Section, $Mode, $AppValue, $found, $temp
	$file = FileOpen($AppFile, 10) ;Write mode (erase previous contents)
	If $file = -1 Then EndGame('Error (4537 Core) ' & $ThisAppTitle & ':', 'Problem opening file: "' & $AppFile & '"', False, 20, True)
	For $Mode = 1 To 20
		Switch $Mode
			Case 1 ; <Title>
				$Section = 'Title'
				FileWriteLine($file, '<' & $Section & '>')
				If $App_Title = '' Then $App_Title = GetFilename(GetFolderPath(_PathFull($AppFile)))
				If $App_Title_Section[0] > 0 Then
					$found = False
					For $i = $App_Title_Section[0] To 1 Step -1 ; Set last line without a semi-colon
						If StringLeft($App_Title_Section[$i], 1) <> ';' Then
							$App_Title_Section[$i] = $App_Title
							$found = True
							ExitLoop
						EndIf
					Next
					If Not $found Then ; add it
						$App_Title_Section[0] += 1
						ReDim $App_Title_Section[$App_Title_Section[0] + 1]
						$App_Title_Section[$App_Title_Section[0]] = $App_Title
					EndIf
					For $i = 1 To $App_Title_Section[0]
						FileWriteLine($file, @TAB & $App_Title_Section[$i])
					Next
				Else
					FileWriteLine($file, @TAB & $App_Title)
				EndIf
				FileWriteLine($file, @CRLF)
			Case 2 ; <Version>
				If $App_Version <> '' Then
					$Section = 'Version'
					FileWriteLine($file, '<' & $Section & '>')
					If $App_Version_Section[0] > 0 Then
						$found = False
						For $i = $App_Version_Section[0] To 1 Step -1 ; Set last line without a semi-colon
							If StringLeft($App_Version_Section[$i], 1) <> ';' Then
								$App_Version_Section[$i] = $App_Version
								$found = True
								ExitLoop
							EndIf
						Next
						If Not $found Then ; add it
							$App_Version_Section[0] += 1
							ReDim $App_Version_Section[$App_Version_Section[0] + 1]
							$App_Version_Section[$App_Version_Section[0]] = $App_Version
						EndIf
						For $i = 1 To $App_Version_Section[0]
							FileWriteLine($file, @TAB & $App_Version_Section[$i])
						Next
					Else
						FileWriteLine($file, @TAB & $App_Version)
					EndIf
					FileWriteLine($file, @CRLF)
				EndIf
			Case 3 ; <Description>
				If IsArray($App_Description) Then
					If $App_Description[0] > 0 Then
						$Section = 'Description'
						FileWriteLine($file, '<' & $Section & '>')
						For $i = 1 To $App_Description[0]
							If Not ($i = $App_Description[0] And StringStripWS($App_Description[$i], 3) = '') Then FileWriteLine($file, $App_Description[$i])
						Next
						FileWriteLine($file, @CRLF)
					EndIf
				EndIf
			Case 4 ; <Url>
				If IsArray($App_URL) Then
					If $App_URL[0] > 0 Then
						$Section = 'URL'
						FileWriteLine($file, '<' & $Section & '>')
						For $i = 1 To $App_URL[0]
							FileWriteLine($file, @TAB & $App_URL[$i])
						Next
						FileWriteLine($file, @CRLF)
					EndIf
				EndIf
			Case 5 ; <Category>
				If IsArray($App_Category) Then
					If $App_Category[0] > 0 Then
						$Section = 'Category'
						FileWriteLine($file, '<' & $Section & '>')
						$AppValue = Multi2SingleLine($App_Category, '|')
						If $App_Category_Section[0] > 0 Then
							$found = False
							For $i = $App_Category_Section[0] To 1 Step -1 ; Set last line without a semi-colon
								If StringLeft($App_Category_Section[$i], 1) <> ';' Then
									$App_Category_Section[$i] = $AppValue
									$found = True
									ExitLoop
								EndIf
							Next
							If Not $found Then ; add it
								$App_Category_Section[0] += 1
								ReDim $App_Category_Section[$App_Category_Section[0] + 1]
								$App_Category_Section[$App_Category_Section[0]] = $AppValue
							EndIf
							For $i = 1 To $App_Category_Section[0]
								FileWriteLine($file, @TAB & $App_Category_Section[$i])
							Next
						Else
							FileWriteLine($file, @TAB & $AppValue)
						EndIf
						FileWriteLine($file, @CRLF)
					EndIf
				EndIf
			Case 6 ;<BuildType>
				If $App_Type <> '' Then
					$Section = 'BuildType'
					FileWriteLine($file, '<' & $Section & '>')
					Switch $App_Type
						Case 1
							FileWriteLine($file, @TAB & 'SetupS')
						Case 2
							FileWriteLine($file, @TAB & 'ssApp')
						Case 3
							FileWriteLine($file, @TAB & 'ppApp')
						Case 4
							FileWriteLine($file, @TAB & 'ppTweak')
						Case 5
							FileWriteLine($file, @TAB & 'ppGame')
					EndSwitch
					FileWriteLine($file, @CRLF)
				EndIf
			Case 7 ;<OS>
				If $App_OS <> '' Or (0 > $App_OS And $App_OS < 15) Then
					$Section = 'OS'
					FileWriteLine($file, '<' & $Section & '>')
					Switch $App_OS
						Case 1
							$temp = '1 (2K/XP/2K3)'
						Case 2
							$temp = '2 (Vista/7)'
						Case 3
							$temp = '3 (2K/XP/2K3/Vista/7)'
						Case 4
							$temp = '4 (8/8.1)'
						Case 5
							$temp = '5 (2K/XP/2K3/8/8.1)'
						Case 6
							$temp = '6 (Vista/7/8/8.1)'
						Case 7
							$temp = '7 (2K/XP/2K3/Vista/7/8/8.1)'
						Case 8
							$temp = '8 (10)'
						Case 9
							$temp = '9 (2K/XP/2K3/10)'
						Case 10
							$temp = '10 (Vista/7/10)'
						Case 11
							$temp = '11 (2K/XP/2K3/Vista/7/10)'
						Case 12
							$temp = '12 (8/8.1/10)'
						Case 13
							$temp = '13 (2K/XP/2K3/8/8.1/10)'
						Case 14
							$temp = '14 (Vista/7/8/8.1/10)'
					EndSwitch
					FileWriteLine($file, @TAB & $temp)
					FileWriteLine($file, @CRLF)
				EndIf
			Case 8 ;<Architecture>
				If $App_Architecture <> '' Or $App_Architecture > 0 Then
					$Section = 'Architecture'
					FileWriteLine($file, '<' & $Section & '>')
					Switch $App_Architecture
						Case 1
							FileWriteLine($file, @TAB & '1 (x86)')
						Case 2
							FileWriteLine($file, @TAB & '2 (x64)')
						Case 3
							FileWriteLine($file, @TAB & '3 (DualArch)')
					EndSwitch
					FileWriteLine($file, @CRLF)
				EndIf
			Case 9 ; <AppPath>
				If $App_InstallPath <> '' Then
					$Section = 'AppPath';'Install To Path'
					FileWriteLine($file, '<' & $Section & '>')
					FileWriteLine($file, @TAB & $App_InstallPath)
					FileWriteLine($file, @CRLF)
				EndIf
			Case 10 ; <Assembly> Commands
				If IsArray($App_Assembly) Then
					If $App_Assembly[0] > 0 Then
						;If $App_Type > 2 Then
						$Section = 'Assembly' ;ToDo: Change this to 'PreInstall'
						;Else
						;	$Section = 'Install'
						;EndIf
						FileWriteLine($file, '<' & $Section & '>')
						For $i = 1 To $App_Assembly[0]
							FileWriteLine($file, @TAB & $App_Assembly[$i])
						Next
						FileWriteLine($file, @CRLF)
					EndIf
				EndIf
			Case 11 ; <StartMenuSourcePath>
				If $App_smSource <> '' Then
					$Section = 'StartMenuSourcePath' ;'Default Startmenu'
					FileWriteLine($file, '<' & $Section & '>')
					FileWriteLine($file, @TAB & $App_smSource)
					FileWriteLine($file, @CRLF)
				EndIf
			Case 12 ;<Catalog>
				If IsArray($App_Catalog) Then
					If $App_Catalog[0] > 0 Then
						$Section = 'Catalog'
						FileWriteLine($file, '<' & $Section & '>')
						For $i = 1 To $App_Catalog[0]
							FileWriteLine($file, @TAB & $App_Catalog[$i])
						Next
						FileWriteLine($file, @CRLF)
					EndIf
				EndIf
			Case 13 ; <StartMenuDestPath>
				If $App_smLegacySecondary[0] > 0 Or $App_smLegacyPrimary[0] > 0 Then
					$Section = 'StartMenuDestPath'
					FileWriteLine($file, '<' & $Section & '>')
					If $App_smLegacySecondary[0] > 0 Then
						$AppValue = Multi2SingleLine($App_smLegacySecondary, '|')
						FileWriteLine($file, @TAB & $AppValue)
					EndIf
					If $App_smLegacyPrimary[0] > 0 Then
						$AppValue = Multi2SingleLine($App_smLegacyPrimary, '|')
						FileWriteLine($file, @TAB & $AppValue)
					EndIf
					FileWriteLine($file, @CRLF)
				Else ;Construct them
				EndIf
			Case 14 ; <Flags>
				$Section = 'Flags'
				FileWriteLine($file, '<' & $Section & '>')
				If $App_Flags_Section[0] > 0 Then ; pull all comments to the top
					For $i = 1 To $App_Flags_Section[0]
						If StringLeft($App_Flags_Section[$i], 1) = ';' Then FileWriteLine($file, @TAB & $App_Flags_Section[$i])
					Next
				EndIf
				;Shortcut Options
				If $App_Type <> 4 Then
					If Not $App_MakeStartMenu Then FileWriteLine($file, @TAB & 'MakeInStartmenu = No')
					If $App_KeepInFolder Then FileWriteLine($file, @TAB & 'KeepInFolder = Yes')
					If $App_KeepAll Then
						FileWriteLine($file, @TAB & 'KeepAll = Yes')
					Else
						FileWriteLine($file, @TAB & 'KeepAll = No')
					EndIf
					If $App_MakeInRoot Then FileWriteLine($file, @TAB & 'MakeInRoot = Yes')
					If $App_MakeInPrograms Then FileWriteLine($file, @TAB & 'MakeInPrograms = Yes')
					If $App_MakeStartup Then FileWriteLine($file, @TAB & 'MakeStartup = Yes')
					If $App_MakeDesktop Then FileWriteLine($file, @TAB & 'MakeDesktop = Yes')
					If $App_MakeQuickLaunch Then FileWriteLine($file, @TAB & 'MakeQuickLaunch = Yes')
					If $App_TaskbarPin Then FileWriteLine($file, @TAB & 'TaskbarPin = Yes')
					If $App_StartmenuPin Then FileWriteLine($file, @TAB & 'StartmenuPin = Yes')
					If $App_MakeSendTo Then FileWriteLine($file, @TAB & 'MakeSendTo = Yes')
					If $App_NeverSort Then FileWriteLine($file, @TAB & 'NoShortcuts = Yes')
					If $App_AlwaysSort Then FileWriteLine($file, @TAB & 'AlwaysSort = Yes')
					If Not $App_AllUsers Then FileWriteLine($file, @TAB & 'AllUsers = No')
					If $App_NoIcons Then FileWriteLine($file, @TAB & 'NoMenuIcons = Yes')
					If Not $App_UpdateAppFile Then FileWriteLine($file, @TAB & 'UpdateAppFile = No')
					If Not $App_MetroFriendly Then FileWriteLine($file, @TAB & 'MetroFriendly = No')
					If Not $App_ssUninstall Then FileWriteLine($file, @TAB & 'ssUninstall = No')
				EndIf
				If $App_LivePE Then FileWriteLine($file, @TAB & 'LivePE = Yes')
				If $App_RefreshExplorer Then FileWriteLine($file, @TAB & 'RefreshDesktop = Yes')
				;ssWPI Options
				If $App_Runx64 Then FileWriteLine($file, @TAB & 'RunX64 = Yes')
				If $App_AlwaysShow Then FileWriteLine($file, @TAB & 'AlwaysShow = Yes')
				If $App_AlwaysHide Then FileWriteLine($file, @TAB & 'AlwaysHide = Yes')
				If $App_DuringSetupOnly Then FileWriteLine($file, @TAB & 'DuringSetupOnly = Yes')
				If $App_InstallT13 Then FileWriteLine($file, @TAB & 'InstallT13 = Yes')
				If $App_InstallInstant Then FileWriteLine($file, @TAB & 'InstallInstant = Yes')
				If Not ($App_PriorityOrder = 5 Or $App_PriorityOrder = '') Then FileWriteLine($file, @TAB & 'InstallInstant = ' & $App_PriorityOrder)
				;Post-processing Options
				If $App_NoneThing Then FileWriteLine($file, @TAB & 'NoneThing = Yes')
				If $App_AssemblyNoWait Then FileWriteLine($file, @TAB & 'AssemblyNoWait = Yes')
				FileWriteLine($file, @CRLF)
			Case 15 ; <Meta>
				$Section = 'Meta'
				FileWriteLine($file, '<' & $Section & '>')
				If $App_Meta_Section[0] > 0 Then ; pull all comments to the top
					For $i = 1 To $App_Meta_Section[0]
						If StringLeft($App_Meta_Section[$i], 1) = ';' Then FileWriteLine($file, @TAB & $App_Meta_Section[$i])
					Next
				EndIf
				;Meta data
				If IsArray($App_Tags) And $App_Tags[0] > 0 Then FileWriteLine($file, @TAB & 'Tags=' & Multi2SingleLine($App_Tags, '|'))
				If $App_Publisher <> '' Then FileWriteLine($file, @TAB & 'Publisher=' & $App_Publisher)
				If $App_Language <> '' Then FileWriteLine($file, @TAB & 'Language=' & $App_Language)
				If $App_Releaser <> '' Then FileWriteLine($file, @TAB & 'Releaser=' & $App_Releaser)
				If $App_Additional <> '' Then FileWriteLine($file, @TAB & 'Additional=' & $App_Additional)
				If $App_ReleaseDate <> '' Then FileWriteLine($file, @TAB & 'ReleaseDate=' & $App_ReleaseDate)
				If $App_ReleaseVersion <> '' Then FileWriteLine($file, @TAB & 'ReleaseVersion=' & $App_ReleaseVersion)
				If $App_LicenseType <> '' Or $App_LicenseType > 0 Then
					Switch $App_LicenseType
						Case 1
							FileWriteLine($file, @TAB & 'LicenseType=1 (non-gratis)')
						Case 2
							FileWriteLine($file, @TAB & 'LicenseType=2 (gratis-only)')
						Case 3
							FileWriteLine($file, @TAB & 'LicenseType=3 (libre)')
					EndSwitch
				EndIf
				If $App_Rating <> '' Then FileWriteLine($file, @TAB & 'Rating=' & $App_Rating)
				If $App_RequiredRuntimes <> '' Then FileWriteLine($file, @TAB & 'RequiredRuntimes=' & $App_RequiredRuntimes)
				If $App_InstalledSize <> '' Then FileWriteLine($file, @TAB & 'InstalledSize=' & $App_InstalledSize)
				FileWriteLine($file, @CRLF)
			Case 16 ;<FileTypes>
				If IsArray($App_FileType) Then
					If $App_FileType[0] > 0 Then
						$Section = 'FileTypes'
						FileWriteLine($file, '<' & $Section & '>')
						For $i = 1 To $App_FileType[0]
							FileWriteLine($file, @TAB & $App_FileType[$i])
						Next
						FileWriteLine($file, @CRLF)
					EndIf
				EndIf
			Case 17 ;<InstallFonts>
				If IsArray($App_InstallFonts) Then
					If $App_InstallFonts[0] > 0 Then
						$Section = 'InstallFonts';'Install Fonts'
						FileWriteLine($file, '<' & $Section & '>')
						For $i = 1 To $App_InstallFonts[0]
							FileWriteLine($file, @TAB & $App_InstallFonts[$i])
						Next
						FileWriteLine($file, @CRLF)
					EndIf
				EndIf
			Case 18 ;<RegisterDLL>
				If IsArray($App_RegisterDLL) Then
					If $App_RegisterDLL[0] > 0 Then
						$Section = 'RegisterDLL'
						FileWriteLine($file, '<' & $Section & '>')
						For $i = 1 To $App_RegisterDLL[0]
							FileWriteLine($file, @TAB & $App_RegisterDLL[$i])
						Next
						FileWriteLine($file, @CRLF)
					EndIf
				EndIf
			Case 19 ; <ShortCutNamesKeep>
				If IsArray($App_scKeep) Then
					If $App_scKeep[0] > 0 Then
						$Section = 'ShortCutNamesKeep';'ShortCut Names To Keep'
						FileWriteLine($file, '<' & $Section & '>')
						For $i = 1 To $App_scKeep[0]
							FileWriteLine($file, @TAB & $App_scKeep[$i])
						Next
						FileWriteLine($file, @CRLF)
					EndIf
				EndIf
			Case 20 ; <ShortcutS>/<ppApps>
				If $App_scCount > 0 Then
					$Section = 'ShortcutS'
					FileWriteLine($file, '<' & $Section & '>')
					For $i = 1 To $App_scCount
						If $App_scEXE[$i] <> '' And $App_scLNK[$i] <> '' Then
							FileWriteLine($file, @TAB & 'Target="' & $App_scEXE[$i] & '"')
							If StringInStr($App_scWorkDir[$i], $App_InstallPath) Then
								Select
									Case $App_scWorkDir[$i] = $App_InstallPath
										$App_scWorkDir[$i] = ''
									Case StringInStr($App_scWorkDir[$i], '\') And StringInStr($App_scWorkDir[$i], $App_InstallPath & '\')
										$App_scWorkDir[$i] = StringMid($App_scWorkDir[$i], StringInStr($App_scWorkDir[$i], $App_InstallPath & '\') + StringLen($App_InstallPath & '\'))
								EndSelect
							EndIf
							If $App_scWorkDir[$i] <> '' Then FileWriteLine($file, @TAB & 'StartIn="' & $App_scWorkDir[$i] & '"')
							If $App_scArgs[$i] <> '' Then FileWriteLine($file, @TAB & 'Arguments=' & $App_scArgs[$i])
							If $App_scDesc[$i] <> '' Then FileWriteLine($file, @TAB & 'Comment="' & $App_scDesc[$i] & '"')
							If StringInStr($App_scIcon[$i], '\') > 0 And StringInStr($App_scIcon[$i], $App_InstallPath) = 1 Then $App_scIcon[$i] = StringMid($App_scIcon[$i], StringLen($App_InstallPath) + 2)
							If $App_scIcon[$i] <> '' Then FileWriteLine($file, @TAB & 'Icon="' & $App_scIcon[$i] & '"')
							If $App_scIndex[$i] <> '' And $App_scIndex[$i] <> '0' Then FileWriteLine($file, @TAB & 'Index=' & $App_scIndex[$i])
							If $App_scExt[$i] <> '' Then FileWriteLine($file, @TAB & 'Extensions=' & NormalizeAssocExts($App_scExt[$i]))
							If $App_scState[$i] <> '' And $App_scState[$i] <> @SW_SHOWNORMAL Then FileWriteLine($file, @TAB & 'Launch State=' & $App_scState[$i])
							If $App_scDefaults[$i] <> '' Then FileWriteLine($file, @TAB & 'DefaultMenu=' & $App_scDefaults[$i])
							If $App_scFlags[$i] <> '' Then FileWriteLine($file, @TAB & 'Flags=' & $App_scFlags[$i])
							If $App_scCatalog[$i] <> '' Then FileWriteLine($file, @TAB & 'Catalog=' & $App_scCatalog[$i])
							If $App_scKey[$i] <> '' Then FileWriteLine($file, @TAB & 'Hotkey=' & $App_scKey[$i])
							If $App_scLNK[$i] <> '' Then FileWriteLine($file, @TAB & 'Name="' & $App_scLNK[$i] & '"')
							FileWriteLine($file, @CRLF)
						EndIf
					Next
				EndIf
			Case 21 ;<Script>
;~ 				If IsArray($App_Script) Then
;~ 					If $App_Script[0] > 0 Then
;~ 						$Section = 'Script'
;~ 						FileWriteLine($file, '<' & $Section & '>')
;~ 						For $i = 1 To $App_Script[0]
;~ 							If Not ($i = $App_Script[0] And StringStripWS($App_Script[$i], 3) = '') Then FileWriteLine($file, @TAB & $App_Script[$i])
;~ 						Next
;~ 						FileWriteLine($file, @CRLF)
;~ 					EndIf
;~ 				EndIf
			Case 22 ;<Registry>
;~ 				If IsArray($App_RegEntries) Then
;~ 					If $App_RegEntries[0] > 0 Then
;~ 						$Section = 'Registry'
;~ 						FileWriteLine($file, '<' & $Section & '>')
;~ 						For $i = 1 To $App_RegEntries[0]
;~ 							If Not ($i = $App_RegEntries[0] And StringStripWS($App_RegEntries[$i], 3) = '') Then FileWriteLine($file, @TAB & $App_RegEntries[$i])
;~ 						Next
;~ 						FileWriteLine($file, @CRLF)
;~ 					EndIf
;~ 				EndIf
		EndSwitch
	Next
	$Section = 'End'
	FileWriteLine($file, '<' & $Section & '>')
	FileClose($file)
	Return $AppFile
EndFunc

Func _GetAppField($What) ; (Experimental)
	;Local $App_TotalSections = 4
	Switch $What ; Return 2^(-1 + Section_number)
		Case 'BuildType'
			Return 1
		Case 'Category'
			Return 2
		Case 'Catalog'
			Return 4
		Case 'Rest'
			Return 8
			;Case ''
			;	Return 16
			;Case ''
			;	Return 32
			;Case ''
			;	Return 64
			;Case ''
			;	Return 128
			;Case ''
			;	Return 256
			;Case ''
			;	Return 1024
		Case Else ; All
			Return 15 ; 2 ^ $App_TotalSections - 1
	EndSwitch
EndFunc

Func _GetAppFilename($What)
	If StringInStr(FileGetAttrib($What), 'D') Then ; Folder passed, need to find .App file
		$What = NoBackslash($What)
		Select
			Case FileExists($What & '\ssApp.app')
				Return $What & '\ssApp.app'
			Case FileExists($What & '\ppApp.app')
				Return $What & '\ppApp.app'
			Case FileExists($What & '\ppGame.ppg')
				Return $What & '\ppGame.ppg'
			Case FileExists($What & '\SetupS.app')
				Return $What & '\SetupS.app'
			Case FileExists($What & '\SetupS.ini')
				Return $What & '\SetupS.ini'
			Case FileExists($What & '\ppApp.ini')
				Return $What & '\ppApp.ini'
			Case Else
				Return ''
		EndSelect
	ElseIf FileExists($What) Then
		Return $What
	Else
		Return ''
	EndIf
EndFunc

Func _GetAppVersion($What)
	Local $SFV = IniRead($What, 'SetupS', 'App-File Version', '')
	If $SFV = '' Then $SFV = IniRead($What, 'SetupS', 'App-File Format', 'v8.13')
	If StringLeft($SFV, 1) <> 'v' Then $SFV = 'v' & $SFV
	Return $SFV
EndFunc

Func _GetAuxFilename($What, $Ext)
	If StringInStr(FileGetAttrib($What), 'D') Then ; Folder passed, need to find .$Ext file
		$What = NoBackslash($What)
		If StringLeft($Ext, 1) <> '.' Then $Ext = '.' & $Ext
		Select
			Case FileExists($What & '\' & GetAppTypeBase($App_Type) & $Ext)
				Return $What & '\' & GetAppTypeBase($App_Type) & $Ext
			Case FileExists($What & '\ssApp' & $Ext)
				Return $What & '\ssApp' & $Ext
			Case FileExists($What & '\ppApp' & $Ext)
				Return $What & '\ppApp' & $Ext
			Case FileExists($What & '\ppGame' & $Ext)
				Return $What & '\ppGame' & $Ext
			Case FileExists($What & '\SetupS' & $Ext)
				Return $What & '\SetupS' & $Ext
			Case FileExists($What & '\SetupS' & $Ext)
				Return $What & '\SetupS' & $Ext
			Case Else
				Return ''
		EndSelect
	ElseIf FileExists($What) Then
		Return $What
	Else
		Return ''
	EndIf
EndFunc

Func Catalog2Menu(ByRef $Menu, $Style = $MenuStyle)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|Catalog2Menu(): $Style=' & $Style & @CRLF)
	Local $i, $j, $found, $value, $MenuDefinitionINI
	If $App_Catalog[0] > 0 Then ; get StartMenu from Catalog
		If $ToolsPath <> '' Then $MenuDefinitionINI = GetMenuDefs($Style)
		If Not FileExists($MenuDefinitionINI) Then Return
		For $i = 1 To $App_Catalog[0]
			$value = IniRead($MenuDefinitionINI, 'Catalog', $App_Catalog[$i], '')
			$found = False
			For $j = 1 To $Menu[0]
				If ($Menu[$j] = $value) Then
					$found = True
					ExitLoop
				EndIf
			Next
			If Not $found Then
				$Menu[0] += 1
				ReDim $Menu[$Menu[0] + 1]
				$Menu[$Menu[0]] = $value
			EndIf
		Next
	EndIf
EndFunc

Func File2String($What)
	Local $temp = ''
	If FileExists($What) Then
		Local $file = FileOpen($What, 0)
		If $file <> -1 Then
			$temp = FileRead($file)
			FileClose($file)
		EndIf
	EndIf
	Return $temp
EndFunc

Func IniUpdate($IniFile, $Section, $key, $value, $useEOL = '', $notValue = '')
	If $IniFile <> '' Then
		If IsArray($value) Then
			If $value[0] > 0 Then IniWrite($IniFile, $Section, $key, Multi2SingleLine($value, $useEOL))
			If $value[0] = 0 Then IniDelete($IniFile, $Section, $key)
		Else
			If $value <> '' And $value <> $notValue Then IniWrite($IniFile, $Section, $key, $value)
			If $value = '' Or $value = $notValue Then IniDelete($IniFile, $Section, $key)
		EndIf
	EndIf
EndFunc

Func IsWriteProtected($What)
	Local $file = FileOpen($What & '\Test4WriteProtection.txt', 10) ;Write mode (erase previous contents)
	If $file = -1 Then Return True
	FileClose($file)
	If Not FileExists($What & '\Test4WriteProtection.txt') Then Return True
	If Not DeleteMe($What & '\Test4WriteProtection.txt', False) Then Return True
	Return False
EndFunc

Func Legacy2Catalog(ByRef $Menu, $StyleName = 1)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|Legacy2Catalog(): $StyleName=' & $StyleName & @CRLF)
	Local $smStyle
	Switch $StyleName
		Case 1, 'LastOS', 'ssTek', 'LastXP'
			$smStyle = GetMenuDefs(1) ;$ToolsPath & '\Menus\' & $MenuStyles[1][1] & 'Menu\Definitions.ini'
		Case 2, 'Kazz'
			$smStyle = GetMenuDefs(2) ;$ToolsPath & '\Menus\' & $MenuStyles[2][1] & 'Menu\Definitions.ini'
	EndSwitch
	Local $i, $j, $item, $found, $test
	If $WholeCatalog[0][0] = '' Then $WholeCatalog = IniReadSection($smStyle, 'Catalog')
	If IsArray($WholeCatalog) Then
		For $i = 1 To $Menu[0]
			$item = LegacyFilter($Menu[$i])
			For $j = 1 To $WholeCatalog[0][0]
				;MsgBox(4096, '', 'Key: ' & $WholeCatalog[$j][0] & @CRLF & 'Value: ' & $WholeCatalog[$j][1])
				$test = LegacyFilter($WholeCatalog[$j][1])
				If StringInStr(LegacyFilter($WholeCatalog[$j][1]), $item) Then
					$found = False ; is it listed already?
					For $k = 1 To $App_Catalog[0]
						If StringInStr(LegacyFilter($App_Catalog[$k]), $item) Or StringInStr($App_Catalog[$k], $WholeCatalog[$j][0]) Then ;
							$found = True
							ExitLoop
						EndIf
					Next
					If Not $found Then
						$App_Catalog[0] += 1
						ReDim $App_Catalog[$App_Catalog[0] + 1]
						$App_Catalog[$App_Catalog[0]] = $WholeCatalog[$j][0]
					EndIf
				EndIf
			Next
		Next
	EndIf
EndFunc

Func LegacyFilter($item)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|LegacyFilter(): $item=' & $item & @CRLF)
	Local $Out = StringReplace($item, '_', ' ')
	$Out = StringReplace($Out, '-', ' ')
	$Out = StringReplace($Out, '\', ' ')
	$Out = StringReplace($Out, '/', ' ')
	$Out = StringReplace($Out, '&', ' ')
	$Out = StringReplace($Out, ',', ' ')
	$Out = StringReplace($Out, "'s", ' ')
	$Out = StringReplace($Out, "'", ' ')
	$Out = StringReplace($Out, '"', ' ')
	$Out = StringReplace($Out, '1 ', ' ')
	$Out = StringReplace($Out, '2 ', ' ')
	$Out = StringReplace($Out, '3 ', ' ')
	$Out = StringReplace($Out, '4 ', ' ')
	$Out = StringReplace($Out, '5 ', ' ')
	$Out = StringReplace($Out, '6 ', ' ')
	$Out = StringReplace($Out, '7 ', ' ')
	$Out = StringReplace($Out, '8 ', ' ')
	$Out = StringReplace($Out, '9 ', ' ')
	$Out = StringReplace($Out, '0 ', ' ')
	Return StringStripWS($Out, 7)
EndFunc

Func Multi2SingleLine($What, $useEOL = $ssEOL)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|Multi2SingleLine()' & @CRLF)
	If IsArray($What) And $What[0] > 0 Then
		Local $i, $temp = $What[1]
		If $useEOL = '' Then $useEOL = $ssEOL
		For $i = 2 To $What[0]
			$temp = $temp & $useEOL & $What[$i]
		Next
		Return StringReplace($temp, $tEOL, $useEOL)
	Else
		Return ''
	EndIf
EndFunc

Func Set_scFlags()
	Local $i
	For $i = 1 To $App_scCount
		If Not $App_MakeStartMenu Then
			AddFlag($App_scFlags[$i], 'NotInStartmenu')
		Else
			RemoveFlag($App_scFlags[$i], 'NotInStartmenu')
		EndIf
		If $App_KeepAll Then
			AddFlag($App_scFlags[$i], 'Keep')
		Else
			RemoveFlag($App_scFlags[$i], 'Keep')
		EndIf
		If $App_MakeInRoot Then
			AddFlag($App_scFlags[$i], 'Root')
		Else
			RemoveFlag($App_scFlags[$i], 'Root')
		EndIf
		If $App_MakeInPrograms Then
			AddFlag($App_scFlags[$i], 'Programs')
		Else
			RemoveFlag($App_scFlags[$i], 'Programs')
		EndIf
		If $App_MakeStartup Then
			AddFlag($App_scFlags[$i], 'Startup')
		Else
			RemoveFlag($App_scFlags[$i], 'Startup')
		EndIf
		If $App_MakeDesktop Then
			AddFlag($App_scFlags[$i], 'Desktop')
		Else
			RemoveFlag($App_scFlags[$i], 'Desktop')
		EndIf
		If $App_MakeQuickLaunch Then
			AddFlag($App_scFlags[$i], 'QuickLaunch')
		Else
			RemoveFlag($App_scFlags[$i], 'QuickLaunch')
		EndIf
		If $App_TaskbarPin Then
			AddFlag($App_scFlags[$i], 'TaskbarPin')
		Else
			RemoveFlag($App_scFlags[$i], 'TaskbarPin')
		EndIf
		If $App_StartmenuPin Then
			AddFlag($App_scFlags[$i], 'StartmenuPin')
		Else
			RemoveFlag($App_scFlags[$i], 'StartmenuPin')
		EndIf
		If $App_MakeSendTo Then
			AddFlag($App_scFlags[$i], 'SendTo')
		Else
			RemoveFlag($App_scFlags[$i], 'SendTo')
		EndIf
		If $App_NeverSort Then
			AddFlag($App_scFlags[$i], 'NoShortcut')
		Else
			RemoveFlag($App_scFlags[$i], 'NoShortcut')
		EndIf
		If $App_AlwaysSort Then
			AddFlag($App_scFlags[$i], 'AlwaysSort')
		Else
			RemoveFlag($App_scFlags[$i], 'AlwaysSort')
		EndIf
		If Not $App_AllUsers Then
			AddFlag($App_scFlags[$i], 'CurrentUserOnly')
		Else
			RemoveFlag($App_scFlags[$i], 'CurrentUserOnly')
		EndIf
	Next
EndFunc

Func SingleLine2Multi($temp, $useEOL = $ssEOL)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|SingleLine2Multi()' & @CRLF)
	Local $What[1], $i
	$What[0] = 0
	If $temp <> '' Then
		If $useEOL = @CRLF Then
			$What = StringSplit($temp, @CRLF, 1)
		Else
			$What = StringSplit(StringReplace($temp, $tEOL, $useEOL), $useEOL)
		EndIf
	EndIf
	For $i = 1 To $What[0]
		$What[$i] = StringStripWS($What[$i], 3)
	Next
	Return $What
EndFunc

Func StartMenuDestPath($2ndPass = False)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|StartMenuDestPath()' & @CRLF)
	Local $i, $j, $found, $value
	If FileExists($MenuDefinitionINI) Then ; Try to use Catalog system
		If $App_Catalog[0] = 0 Then ; covert legacy to Catalog (comprehensive)
			If $App_smLegacyPrimary[0] > 0 Then Legacy2Catalog($App_smLegacyPrimary, 1)
			If $App_smLegacySecondary[0] > 0 Then Legacy2Catalog($App_smLegacySecondary, 2)
		EndIf
		If $App_Catalog[0] > 0 Then ; get StartMenu from Catalog
			For $i = 1 To $App_Catalog[0]
				$value = IniRead($MenuDefinitionINI, 'Catalog', $App_Catalog[$i], '')
				$found = False
				For $j = 1 To $App_StartMenu[0]
					If ($App_StartMenu[$j] = $value) Then
						$found = True
						ExitLoop
					EndIf
				Next
				If Not $found Then
					$App_StartMenu[0] += 1
					ReDim $App_StartMenu[$App_StartMenu[0] + 1]
					$App_StartMenu[$App_StartMenu[0]] = $value
				EndIf
			Next
		EndIf
	EndIf
	If $App_Catalog[0] = 0 Or Not FileExists($MenuDefinitionINI) Then ; Catalog system failed, so try to get StartMenu from legacy instead...
		Switch $MenuStyle
			Case 1 ; 'LastOS'
				If $App_smLegacyPrimary[0] > 0 Then $App_StartMenu = $App_smLegacyPrimary
			Case 2 ; 'Kazz'
				If $App_smLegacySecondary[0] > 0 Then $App_StartMenu = $App_smLegacySecondary
			Case 0 ; Standard
				ReDim $App_StartMenu[2]
				$App_StartMenu[0] = 1
				$App_StartMenu[1] = $App_smSource
		EndSwitch
	EndIf
	ValidateCatalog()
	If $App_Catalog[0] = 0 And $App_Category[0] > 0 Then ; Get Catalog from Category(s)
		If FileExists($CategoryINI) Then
			For $i = 1 To $App_Category[0]
				$value = IniRead($CategoryINI, 'Category', $App_Category[$i], '')
				If $value <> '' Then
					$found = False ; is it listed already?
					For $j = 1 To $App_Catalog[0]
						If ($App_Catalog[$j] = $value) Then
							$found = True
							ExitLoop
						EndIf
					Next
					If Not $found Then
						$App_Catalog[0] += 1
						ReDim $App_Catalog[$App_Catalog[0] + 1]
						$App_Catalog[$App_Catalog[0]] = $value
					EndIf
				EndIf
			Next
		EndIf
	EndIf
	_ArrayRemoveBlanks($App_StartMenu)
	If Not $2ndPass Then StartMenuDestPath(True)
EndFunc

Func String2File($StrIn, $What)
	If StringRight($What, 4) = '.reg' Then ;add header if not present
		Local $header = 'Windows Registry Editor Version 5.00'
		If Not (StringLeft($StrIn, StringLen($header)) = $header Or StringLeft($StrIn, StringLen('REGEDIT4')) = 'REGEDIT4') Then
			$StrIn = $header & @CRLF & @CRLF & $StrIn
		EndIf
	EndIf
	Local $file = FileOpen($What, 10) ;Write mode (erase previous contents)
	If $file <> -1 Then
		FileWrite($file, $StrIn)
		FileClose($file)
		Return True
	EndIf
	Return False
EndFunc

Func UIReset()
	ReDim $App_Uninstall[1][7]
	$App_Uninstall[0][0] = 0 ; 'UninstallKey.'
	$App_Uninstall[0][1] = 'DisplayName'
	$App_Uninstall[0][2] = 'InstallLocation'
	$App_Uninstall[0][3] = 'DisplayIcon'
	$App_Uninstall[0][4] = 'UninstallString'
	$App_Uninstall[0][5] = 'Switches'
	$App_Uninstall[0][6] = 'Script'
EndFunc
#endregion

#region ;**** Updater support ***

; #FUNCTION# ====================================================================================================================
; Name...........: _VersionCompare
; Description ...: Compares two file versions for equality
; Syntax.........: _VersionCompare($sVersion1, $sVersion2)
; Parameters ....: $sVersion1   - IN - The first version
;                  $sVersion2   - IN - The second version
; Return values .: Success      - Following Values:
;                  | 0          - Both versions equal
;                  | 1          - Version 1 greater
;                  |-1          - Version 2 greater
;                  Failure      - @error will be set in the event of a catasrophic error
; Author ........: Valik
; Modified.......:
; Remarks .......: This will try to use a numerical comparison but fall back on a lexicographical comparison.
;                  See @extended for details about which type was performed.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _VersionCompare($sVersion1, $sVersion2)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupScp.au3|_VersionCompare(): $sVersion1 = ' & $sVersion1 & ' : $sVersion2 = ' & $sVersion2 & @CRLF)
	If $sVersion1 = $sVersion2 Then Return 0
	Local $sep = "."
	If StringInStr($sVersion1, $sep) = 0 Then $sep = ","
	Local $aVersion1 = StringSplit($sVersion1, $sep)
	Local $aVersion2 = StringSplit($sVersion2, $sep)
	If UBound($aVersion1) <> UBound($aVersion2) Or UBound($aVersion1) = 0 Then
		; Compare as strings
		SetExtended(1)
		If $sVersion1 > $sVersion2 Then
			Return 1
		ElseIf $sVersion1 < $sVersion2 Then
			Return -1
		EndIf
	Else
		For $i = 1 To UBound($aVersion1) - 1
			; Compare this segment as numbers
			If StringIsDigit($aVersion1[$i]) And StringIsDigit($aVersion2[$i]) Then
				If Number($aVersion1[$i]) > Number($aVersion2[$i]) Then
					Return 1
				ElseIf Number($aVersion1[$i]) < Number($aVersion2[$i]) Then
					Return -1
				EndIf
			Else ; Compare the segment as strings
				SetExtended(1)
				If $aVersion1[$i] > $aVersion2[$i] Then
					Return 1
				ElseIf $aVersion1[$i] < $aVersion2[$i] Then
					Return -1
				EndIf
			EndIf
		Next
	EndIf
	; This point should never be reached
	Return SetError(2, 0, 0)
EndFunc

Func DownloadFile($url, $outfile, $SplashTips = False, $BalloonTips = False, $DLTitle = '')
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupScp.au3|DownloadFile(): $url = ' & $url & ' : $outfile = ' & $outfile & ' : $SplashTips = ' & $SplashTips & ' : $BalloonTips = ' & $BalloonTips & @CRLF)
	If $AbortDL Then Return ''
	If Not FileExists(GetFolderPath($outfile)) Then DirCreate(GetFolderPath($outfile))
	Local $PercentDL, $SizeDL, $Done, $Remain, $hDownload = InetGet($url, $outfile, 9, 1)
	If $DLTitle = '' Then $DLTitle = $ThisAppTitle
	If $BalloonTips Then _TrayTip('Downloading... (ESC to abort)', '0 % (0/0)', 300, 16)
	If $SplashTips Then ProgressOn($DLTitle, 'Downloading... (ESC to abort)', '0 % (0/0)', Default, Default, 16)
	If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Update Downloading' & @CRLF)
	HotKeySet('{Esc}', 'DownloadFile_Abort')
	Do
		$SizeDL = InetGetInfo($hDownload, 1)
		$PercentDL = 100 * InetGetInfo($hDownload, 0) / $SizeDL
		If $PercentDL < 100 Then
			$Done = Round(InetGetInfo($hDownload, 0) / (1024 ^ 2), 1)
			If StringLeft(StringRight($Done, 2), 1) <> '.' Then $Done = $Done & ".0"
			$Remain = Round($SizeDL / (1024 ^ 2), 1)
			If $BalloonTips Then _TrayTip('Downloading... (ESC to abort)', Int($PercentDL) & '% (' & $Done & '/' & $Remain & ') MB', 300, 16)
			If $SplashTips Then ProgressSet($PercentDL, Int($PercentDL) & '% (' & $Done & '/' & $Remain & ') MB')
		EndIf
		Sleep(100)
	Until InetGetInfo($hDownload, 2) Or $AbortDL Or InetGetInfo($hDownload, 4) <> 0; Check if the download is complete or has been aborted.
	HotKeySet('{Esc}')
	Local $aData = InetGetInfo($hDownload) ; Get all information.
	InetClose($hDownload) ; Close the handle to release resourcs.
	Local $error = $aData[4]
	If $BalloonTips Then _TrayTip('', '', 300, 16)
	If $SplashTips Then
		Select
			Case $AbortDL
				ProgressSet(0, 'Not able to download... user aborted.', 'Download aborted')
				Sleep(2000)
			Case $error
				ProgressSet(0, 'Not able to download... check Internet connection.', 'Error!')
				Sleep(1500)
			Case Else
				ProgressSet(100, 'Done', 'Complete')
				Sleep(100)
		EndSelect
		ProgressOff()
	EndIf
	If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Update Done' & @CRLF)
	If $AbortDL Or $error Then Return ''
	Return $aData
EndFunc

Func DownloadFile_Abort()
	$AbortDL = True
EndFunc

Func ExecuteUpdate($TempDL, $UpdateFile, $MD5, $NoGUI)
	If $MD5 <> '' Then ; Update only if the MD5 hash of downloaded file is correct
		_Crypt_Startup()
		_MD5Write2File(_MD5Calc($TempDL & '\' & $UpdateFile), $UpdateFile, $TempDL & '\checksum.md5')
		_Crypt_Shutdown()
		Local $line = FileReadLine($TempDL & '\checksum.md5')
		$line = StringStripWS(StringLeft($line, StringInStr($line, ' ')), 3)
		If ($MD5 <> $line) Then Return
	EndIf
	Local $file = FileOpen($TempDL & '\' & 'UpdateMe.cmd', 10)
	If $file <> -1 Then
		FileWrite($file, '"' & $UpdateFile & '"' & @CRLF)
		FileWrite($file, 'cd ..' & @CRLF)
		FileWrite($file, '"' & @ScriptFullPath & '" -AutoUpdate=' & $TempDL & $NoGUI)
		FileClose($file)
		Cleanup()
		FileChangeDir($TempDL)
		If $SetupSFolder <> '' And Not StringInStr(EnvGet('Path'), $SetupSFolder) Then EnvSet('path', $SetupSFolder & ';' & EnvGet('path'))
		Run('UpdateMe.cmd', $TempDL, @SW_HIDE)
		Sleep(100)
		Exit
	EndIf
EndFunc

Func SetThisApp($Title = '');, $Version
	DualArch($ThisAppFilename)
	If @Compiled Then
		$ThisAppVersion = FileGetVersion(FindMe(@ScriptName))
	Else
		$ThisAppVersion = FileGetVersion(FindMe($ThisAppFilename & '.exe'))
	EndIf
	If $ThisAppVersion = '0.0.0.0' Or $ThisAppVersion = '' Or (StringLeft($ThisAppVersion, 1) = '#' And StringRight($ThisAppVersion, 1) = '#') Then $ThisAppVersion = $SetupS_CoreVer
	$ThisAppVersion = StringReplace($ThisAppVersion, 'v', '')
	$ThisAppTitle = $Title
	If $ThisAppTitle = '' Then $ThisAppTitle = $ThisAppFilename
	If StringLeft($ThisAppTitle, 2) == 'ss' Then
		$ThisAppTitle = 'SetupS ' & StringMid($ThisAppTitle, 3) & ' (' & $ThisAppTitle & ') v' & $ThisAppVersion
	Else
		$ThisAppTitle = $ThisAppTitle & ' v' & $ThisAppVersion
	EndIf
EndFunc

Func UpdateMe($UpdateLink, $SetupSInfo, $Attend = False, $UseGUI = True)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupScp.au3|UpdateMe(): $UpdateLink = ' & $UpdateLink & ' : $App_Title = ' & $App_Title & ' : $App_Version = ' & $App_Version & ' : $Attend = ' & $Attend & @CRLF)

	_AppReset()
	$App_File = _AppRead($SetupSInfo, False, True)
	If (StringLeft($App_Title, 1) = '#' And StringRight($App_Title, 1) = '#') Then $App_Title = $ThisAppFilename
	;$App_BuildType = {given}
	If StringInStr($App_Version, '#ProjectVersion#') Then $App_Version = 'v' & $ThisAppVersion
	$App_Version = StringReplace($App_Version, 'v', '')
	$App_InstallPath = ConvertFromVars($App_InstallPath)

	If $RepoLink & $BackupRepoLink & $UpdateLink = '' Then Return 1 ;'Update.ini fail'
	Local $i, $Continue, $TempDL = GenerateTempFolder(), $MD5, $DownloadLink, $UpdateFile, $NoGUI = '', $Return = ''
	Local $SplashTips_Temp = $SplashTips, $BalloonTips_Temp = $BalloonTips
	If $OS_NT5 Then
		$SplashTips = False
		$BalloonTips = True
	Else
		$SplashTips = True
		$BalloonTips = False
	EndIf
	DirCreate($TempDL)
	$AbortDL = False
	Local $aData = DownloadFile($RepoLink & '/' & $RepoFolder & '/' & $UpdateLink, $TempDL & '\update.ini', $Attend, False)
	If Not (IsArray($aData) And $aData[3]) Then
		$aData = DownloadFile($BackupRepoLink & '/' & $RepoFolder & '/' & $UpdateLink, $TempDL & '\update.ini', $Attend, False)
	Else
	EndIf
	If IsArray($aData) Then
		If $aData[3] Then
			Local $test = IniRead($TempDL & '\update.ini', $App_Title & '_' & $App_BuildType, 'Version', '')
			If $test <> '' And $App_Version <> '' Then
				Local $vAvail = StringReplace($test, 'v', ''), $vThis = StringReplace($App_Version, 'v', '')
				Select
					Case VersionCompare($vThis, '<', $vAvail)
						$Continue = True
						If $Attend And MsgBox(4, 'Update', 'A new version is available: ' & $test & @CRLF & @CRLF & 'Do you wish to download and install it?') <> 6 Then $Continue = False
					Case VersionCompare($vThis, '=', $vAvail)
						$Continue = False
						If $Attend And MsgBox(4, 'Update', 'Your version is current.' & @CRLF & @CRLF & 'Do you still wish to download and install it?') = 6 Then $Continue = True
					Case VersionCompare($vThis, '>', $vAvail)
						$Continue = False
						If $Attend And MsgBox(4, 'Update', 'Your version is newer.' & @CRLF & @CRLF & 'Do you still wish to download and install it?') = 6 Then $Continue = True
				EndSelect
				If $Continue Then
					If Not $UseGUI Then $NoGUI = ' -NoGUI'
					$UpdateFile = GetFilename(IniRead($TempDL & '\update.ini', $App_Title & '_' & $App_BuildType, 'Update', ''))
					If $WINEVersion = '' Or VersionCompare($WINEVersion, '>=', '1.7') Then
						$MD5 = StringStripWS(IniRead($TempDL & '\update.ini', $App_Title & '_' & $App_BuildType, 'MD5', ''), 3)
					Else
						$MD5 = ''
					EndIf
					For $i = 1 To $AltDistr[0][0]
						$DownloadLink = $AltDistr[$AltDistrOrder[$i]][0]
						If StringLeft($DownloadLink, 7) <> 'http://' Then $DownloadLink = 'http://' & $DownloadLink
						$aData = DownloadFile($DownloadLink & '/' & $UpdateFile & $AltDistr[$AltDistrOrder[$i]][1], $TempDL & '\' & $UpdateFile, $SplashTips, $BalloonTips)
						If IsArray($aData) And $aData[3] Then ExecuteUpdate($TempDL, $UpdateFile, $MD5, $NoGUI); Create the bootstrap
					Next
					$DownloadLink = IniRead($TempDL & '\update.ini', $App_Title & '_' & $App_BuildType, 'Download', '')
					If StringLeft($DownloadLink, 7) <> 'http://' Then $DownloadLink = 'http://' & $DownloadLink
					$aData = DownloadFile($DownloadLink & '/' & $UpdateFile, $TempDL & '\' & $UpdateFile, $SplashTips, $BalloonTips)
					If IsArray($aData) And $aData[3] Then ExecuteUpdate($TempDL, $UpdateFile, $MD5, $NoGUI); Create the bootstrap
				EndIf
			EndIf
			$Return = 2 ;'No update'
		ElseIf $aData[4] <> 0 Then ;Debug
;~ 			MsgBox(0, "", "Bytes read: " & $aData[0] & @CRLF & _
;~ 					"Size: " & $aData[1] & @CRLF & _
;~ 					"Complete?: " & $aData[2] & @CRLF & _
;~ 					"Successful?: " & $aData[3] & @CRLF & _
;~ 					"@error: " & $aData[4] & @CRLF & _
;~ 					"@extended: " & $aData[5] & @CRLF)
			$Return = 1 ;'Update.ini fail'
		Else
		EndIf
	EndIf
	DeleteMe($TempDL)
	$TempDL = ''
	$SplashTips = $SplashTips_Temp
	$BalloonTips = $BalloonTips_Temp
	Return $Return
EndFunc
#endregion

#region ;**** ssClean.Support ****
Func DeleteUninstalled($Dir, $BalloonTipsIn = '', $SplashTipsIn = '')
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|DeleteUninstalled(): $Dir=' & $Dir & @CRLF)
	Local $i, $j, $PackingList, $hFile, $test, $exit, $found, $AppFile = '', $key = '', $value = ''
	Local $ScanDir = NoBackslash($Dir), $BType, $ScanMethod = 'Old' ;use '' for auto-switch
	If $BalloonTipsIn <> '' Then
		Local $BalloonTipsOld = $BalloonTips
		$BalloonTips = $BalloonTipsIn
	EndIf
	If $SplashTipsIn <> '' Then
		Local $SplashTipsOld = $SplashTips
		$SplashTips = $SplashTipsIn
	EndIf
	If $OS_NT5 Then
		$SplashTips = False
		$BalloonTips = True
	Else
		$SplashTips = True
		$BalloonTips = False
	EndIf
	If $BalloonTips Then
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', '2')
		Opt('TrayIconHide', 0) ;Show tray icon
		Opt('TrayAutoPause', 0) ;Turn off autopause
	Else
		;RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', '0')
		Opt('TrayIconHide', 1) ;Hide tray icon
	EndIf
	If $BalloonTips Then
		If $ssUninstallChanged Then
			If $ssUninstall Then
				_TrayTip('Enabling ssUninstall for:', '"' & $ScanDir & '"', 30, 17)
			Else
				_TrayTip('Disabling ssUninstall for:', '"' & $ScanDir & '"', 30, 17)
			EndIf
		Else
			_TrayTip('Scanning for uninstalled in:', '"' & $ScanDir & '"', 30, 17)
		EndIf
	EndIf
	If $SplashTips Then
		If $ssUninstallChanged Then
			If $ssUninstall Then
				SplashThis('Please wait...', 'Enabling ssUninstall for: "' & $ScanDir & '"')
			Else
				SplashThis('Please wait...', 'Disabling ssUninstall for: "' & $ScanDir & '"')
			EndIf
		Else
			SplashThis('Please wait...', 'Scanning for uninstalled in: "' & $ScanDir & '"')
		EndIf
	EndIf
	If StringInStr(StringMid($ScanDir, 3), '\ssApps') = 1 Then $BType = 'app'
	If StringInStr(StringMid($ScanDir, 3), '\SetupSApps') = 1 Then $BType = 'app'
	If StringInStr(StringMid($ScanDir, 3), '\ppApps') = 1 Then
		$BType = 'app'
		$ScanMethod = 'Old'
	EndIf
	If StringInStr(StringMid($ScanDir, 3), '\ppGames') = 1 Then
		$BType = 'ppg'
		$ScanMethod = 'Old'
	EndIf
	ReDim $ExpressInstall[1]
	$ExpressInstall[0] = 0
	ScanForExpressInstall($ScanDir, True, $BType, $ScanMethod)
	;_ArrayDisplay($ExpressInstall, @ScriptLineNumber)
	If IsArray($ExpressInstall) Then
		For $i = 1 To $ExpressInstall[0]
			If StringStripWS($ExpressInstall[$i], 3) <> '' Then
				_AppReset()
				$AppFile = _AppRead($ExpressInstall[$i])
				If $App_InstallPath <> '' And $App_Uninstall[0][0] = 0 Then $App_Uninstall = GetUninstallData($App_InstallPath)
				If FileExists($AppFile) And IsArray($App_Uninstall) Then
					If $App_Uninstall[0][0] > 0 Then
						;_ArrayDisplay($App_Uninstall, @ScriptLineNumber)
						For $j = 1 To $App_Uninstall[0][0]
							$key = GetUninstallKey($App_Uninstall[$j][0], $value)
							If $key <> '' Then ExitLoop
						Next
						If $key = '' Then
							If $Debug Then _ConsoleWriteDebug('@@ Debug(5193) SetupS.Core|DeleteUninstalled(): $App_InstallPath=' & $App_InstallPath & @CRLF)
							DeleteMe($App_InstallPath)
							;$key = GetUninstallKey($App_Uninstall[$j][0], $value, True)
							;If $key <> '' Then RegDelete($key)
						Else
							If $Debug Then _ConsoleWriteDebug('@@ Debug(5196) SetupS.Core|DeleteUninstalled(): $test=' & $test & @CRLF)
							_AppWrite($AppFile, 'Update')
						EndIf
						;UIReset()
					EndIf
				EndIf
			EndIf
		Next
	EndIf
	If $BalloonTipsIn <> '' Then
		$BalloonTips = $BalloonTipsOld
		If $BalloonTips Then
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', '2')
			Opt('TrayIconHide', 0) ;Show tray icon
			Opt('TrayAutoPause', 0) ;Turn off autopause
			_ShowTray() ;AdlibRegister('_ShowTray', 500)
		Else
			;RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', '0')
			Opt('TrayIconHide', 1) ;Hide tray icon
		EndIf
	EndIf
	If $SplashTipsIn <> '' Then $SplashTips = $SplashTipsOld
EndFunc

Func RecycleMe($What, $ssClean = True)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|RecycleMe(): $What=' & $What & @CRLF)
	If $ssClean And $ssCleanerDeleteDudAppPath Then
		Local $Target = FileGetShortcutEx($What)
		If @error = 0 And IsArray($Target) Then RemoveSetupSfiles(GetFolderPath($Target[0]))
	EndIf
	FileRecycle($What)
EndFunc

Func RemoveSetupSfiles($What)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|RemoveSetupSfiles(): $What=' & $What & @CRLF)
	If FileExists($What) Then
		_AppReset()
		If _AppRead($What) <> '' Then
			Local $i, $FileList, $DeleteMe
			If $App_InstallPath <> $What Then ;what?
			EndIf
			;first check all the defs listed in <Shortcuts> to make sure their targets really do not exist...
			$DeleteMe = True
			For $i = 1 To $App_scCount
				If FileExists($What & '\' & $App_scEXE[$i]) Then
					$DeleteMe = False
					ExitLoop
				EndIf
			Next
			If $DeleteMe And Not DirRecycle($What) Then ;Only remove SetupS related files.
				$FileList = _FileListToArray($What, 'SetupS.*', 1) ; Return SetupS files only
				If @error = 0 Then
					For $i = 1 To $FileList[0]
						FileRecycle($What & '\' & $FileList[$i])
					Next
				EndIf
				$FileList = _FileListToArray($What, 'ssApp.*', 1) ; Return ssApp files only
				If @error = 0 Then
					For $i = 1 To $FileList[0]
						FileRecycle($What & '\' & $FileList[$i])
					Next
				EndIf
				$FileList = _FileListToArray($What, 'ppApp.*', 1) ; Return ppApp files only
				If @error = 0 Then
					For $i = 1 To $FileList[0]
						FileRecycle($What & '\' & $FileList[$i])
					Next
				EndIf
				$FileList = _FileListToArray($What, 'ppGame.*', 1) ; Return ppGame files only
				If @error = 0 Then
					For $i = 1 To $FileList[0]
						FileRecycle($What & '\' & $FileList[$i])
					Next
				EndIf
				$FileList = _FileListToArray($What, '*.*', 1) ; Return files only
				If @error = 0 Then
					For $i = 1 To $FileList[0]
						$DeleteMe = True
						Select; Remove other unnecessary files
							Case ($FileList[$i] = 'folder.jpg')
							Case ($FileList[$i] = 'folder.gif')
							Case ($FileList[$i] = 'desktop.ini')
							Case ($FileList[$i] = 'thumbs.db')
							Case Else
								$DeleteMe = False
						EndSelect
						If $DeleteMe Then FileRecycle($What & '\' & $FileList[$i])
					Next
				EndIf
				$FileList = _FileListToArray($What, '*.*', 1) ; Return files only
				Switch @error
					Case 0
						If $FileList[0] = 0 Then ;Remove empty folder
							DirRecycle($What)
						Else ;files still present in folder
						EndIf
					Case 4 ;None found, remove
						DirRecycle($What)
					Case Else
				EndSwitch
			EndIf
		EndIf
	EndIf
EndFunc

Func ssCleaner($Dir, $BalloonTipsIn = '', $SplashTipsIn = '', $TopLevel = True) ; Just feed this any folder (with shortcuts) and it'll take care of the rest
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|ssCleaner(): $Dir=' & $Dir & @CRLF)
	Local $i, $FileList, $Path, $Details, $DirCount = 0, $ssClean = True, $DirMax, $DirLen = StringLen($Dir)
	$Dir = _PathFull($Dir)
	If FileExists($Dir) Then
		If $BalloonTipsIn & $SplashTipsIn <> '' Then
			If $BalloonTipsIn <> '' Then
				Local $BalloonTipsOld = $BalloonTips
				$BalloonTips = $BalloonTipsIn
			EndIf
			If $SplashTipsIn <> '' Then
				Local $SplashTipsOld = $SplashTips
				$SplashTips = $SplashTipsIn
			EndIf
			If $OS_NT5 Then
				$SplashTips = False
				$BalloonTips = True
			Else
				$SplashTips = True
				$BalloonTips = False
			EndIf
			If $BalloonTips Then
				RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', '2')
				Opt('TrayIconHide', 0) ;Show tray icon
				Opt('TrayAutoPause', 0) ;Turn off autopause
			Else
				;RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', '0')
				Opt('TrayIconHide', 1) ;Hide tray icon
			EndIf
		EndIf
		If $BalloonTips And $TopLevel Then
			$DirMax = 39
			If $DirLen > $DirMax Then $DirLen = Int(($DirMax - 3) / 2)
			_TrayTip('Checking (shortcuts)', '"' & StringLeft($Dir, $DirLen) & '...' & StringRight($Dir, $DirLen) & '"', 30, 17)
			_ShowTray() ;AdlibRegister('_ShowTray', 500)
		EndIf
		If $SplashTips Then SplashThis('Checking (shortcuts)', '"' & $Dir & '"')
		If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Checking (shortcuts)' & ': "' & $Dir & '"' & @CRLF)
		$FileList = _FileListToArray($Dir, '*.*', 2) ; folders only
		If @error = 0 And IsArray($FileList) Then
			For $i = 1 To $FileList[0]
				Select ; do NOT delete if
					Case ssCleaner($Dir & '\' & $FileList[$i], $BalloonTipsIn, $SplashTipsIn, False) > 0 ;folder not empty
					Case ($Dir & '\' & $FileList[$i] = @StartupDir)
					Case ($Dir & '\' & $FileList[$i] = @StartupCommonDir)
					Case ($Dir & '\' & $FileList[$i] = @ProgramsDir)
					Case ($Dir & '\' & $FileList[$i] = @ProgramsCommonDir)
					Case ($Dir & '\' & $FileList[$i] = @StartMenuDir)
					Case ($Dir & '\' & $FileList[$i] = @StartMenuCommonDir)
					Case ($Dir & '\' & $FileList[$i] = @DesktopDir)
					Case ($Dir & '\' & $FileList[$i] = @DesktopCommonDir)
					Case ($Dir & '\' & $FileList[$i] = $SendToPath)
					Case ($Dir & '\' & $FileList[$i] = $QuickLaunch)
					Case ($Dir & '\' & $FileList[$i] = @ProgramsDir & '\Administrative Tools') ;Administrative Tools	Current User
					Case ($Dir & '\' & $FileList[$i] = @ProgramsCommonDir & '\Administrative Tools') ;Administrative Tools	Current User
					Case Else
						If $Debug Then _ConsoleWriteDebug('@@ Debug(5318) SetupS.Core|ssCleaner(): $Dir & "\" & $FileList[$i]=' & $Dir & '\' & $FileList[$i] & @CRLF)
						RecycleMe($Dir & '\' & $FileList[$i])
						$LLDeleted += 1
				EndSelect
			Next
		EndIf
		$FileList = _FileListToArray($Dir, '*.url', 1) ; weblinks only
		If @error = 0 And IsArray($FileList) Then
			For $i = 1 To $FileList[0]
				If $Debug Then _ConsoleWriteDebug('@@ Debug(5327) SetupS.Core|ssCleaner(): $Dir & "\" & $FileList[$i]=' & $Dir & '\' & $FileList[$i] & @CRLF)
				FileRecycle($Dir & '\' & $FileList[$i])
				$LLDeleted += 1
			Next
			$LLChecked = $LLChecked + $FileList[0]
		EndIf
		$FileList = _FileListToArray($Dir, '*.lnk', 1) ; shortcuts only
		If @error = 0 And IsArray($FileList) Then
			For $i = 1 To $FileList[0]
				If Not ValidateShortcut($Dir & '\' & $FileList[$i], $ssClean) Then $LLDeleted += 1
			Next
			$LLChecked = $LLChecked + $FileList[0]
		EndIf
		$FileList = _FileListToArray($Dir) ; how many's left?
		Switch @error
			Case 0 ; File(s) Found
				If IsArray($FileList) Then
					$DirCount = $FileList[0]
					If $FileList[0] = 1 And $FileList[1] = 'desktop.ini' Then ; is only Desktop.ini left?
						Switch $Dir ; do NOT delete if
							Case @StartupDir
							Case @StartupCommonDir
							Case @ProgramsDir
							Case @ProgramsCommonDir
							Case @StartMenuDir
							Case @StartMenuCommonDir
							Case @DesktopDir
							Case @DesktopCommonDir
							Case $SendToPath
							Case $QuickLaunch
							Case Else
								If $Debug Then _ConsoleWriteDebug('@@ Debug(5357) SetupS.Core|ssCleaner(): $Dir & "\" & $FileList[1]=' & $Dir & '\' & $FileList[1] & @CRLF)
								RecycleMe($Dir & '\' & $FileList[1])
								$LLDeleted += 1
								$DirCount = 0
						EndSwitch
					EndIf
				EndIf
			Case Else ; or 4 ; No File(s) Found
				$DirCount = 0
				;Case 2, 3 ; what?
				;	EndGame('Error (5805 Core) ' & $ThisAppTitle & ':', 'Invalid $sFilter or $iFlag FileListToArray parameter', False, 20, True)
		EndSwitch
		If $BalloonTipsIn & $SplashTipsIn <> '' Then
			If $BalloonTipsIn <> '' Then $BalloonTips = $BalloonTipsOld
			If $SplashTipsIn <> '' Then $SplashTips = $SplashTipsOld
			If $BalloonTips Then
				RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', '2')
				Opt('TrayIconHide', 0) ;Show tray icon
				Opt('TrayAutoPause', 0) ;Turn off autopause
			Else
				;RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', '0')
				Opt('TrayIconHide', 1) ;Hide tray icon
			EndIf
		EndIf
;~ 		If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Scanning ...' & @CRLF)
		Return $DirCount
	EndIf
EndFunc

Func ValidateShortcut($What, $ssClean = False)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|ValidateShortcut(): $What=' & $What & @CRLF)
	If Not FileExists($What) Then Return False
	Local $Details = FileGetShortcutEx($What)
	If @error = 0 And IsArray($Details) Then ; Valid shortcut
		If Not StringInStr($Details[0], 'http://') Then ; Not an Internet weblink (http:)
			Select ; do NOT delete if target exists -- or is network or Internet (which is beyond the scope of this utility)
				Case FileExists(ConvertFromVars($Details[0]))
				Case FileExists(ConvertFromVars($Details[4]))
				Case StringInStr($Details[0], '\\') > 0 ; Network
				Case StringInStr($Details[0], '//') > 0 ; Internet (not http:)
				Case Else
					RecycleMe($What, $ssClean)
					Return False
			EndSelect
			Return True
		EndIf
	EndIf
	FileRecycle($What)
	Return False
EndFunc
#endregion

#region ;**** MD5.Support ****
Func _MD5Calc($FileToHash, $ShowProgress = False)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|_MD5Calc(): $FileToHash=' & $FileToHash & @CRLF)
;~ 	If $OS_Linux Then Return '' ; skips this in Linux (because it currently doesn't work in Linux)
	Local $filehandle = FileOpen($FileToHash, 16), $percent_md5
	Local $buffersize = 0x20000, $final = 0, $hash = ""
	Local $iterations = Ceiling(FileGetSize($FileToHash) / $buffersize)
	If $ShowProgress Then ProgressOn('Computing hash', GetFilename($FileToHash), '0 %', -1, -1, 16)
	For $i = 1 To $iterations
		If $i = $iterations Then $final = 1
		$hash = _Crypt_HashData(FileRead($filehandle, $buffersize), $CALG_MD5, $final, $hash)
		If $ShowProgress Then
			$percent_md5 = Round(100 * $i / $iterations)
			ProgressSet($percent_md5, $percent_md5 & " %")
		EndIf
	Next
	FileClose($filehandle)
	If $ShowProgress Then
		ProgressSet(100, "100%", "File hashed")
		ProgressOff()
	EndIf
	Return StringTrimLeft(StringLower($hash), 2)
EndFunc

Func _MD5Remove($FILENAME, $MD5File)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|_MD5Remove(): $FILENAME=' & $FILENAME & @CRLF)
	Local $found = False, $hFileNew = FileOpen(@ScriptDir & '~NewHash.md5', 9)
	If FileExists($MD5File) Then
		Local $hFile = FileOpen($MD5File, 0), $test, $exit = False
		If $hFile <> -1 Then
			Do
				$test = FileReadLine($hFile)
				$exit = (@error = -1)
				If Not $exit Then
					If StringMid($test, StringInStr($test, ' ') + 2) = $FILENAME Then
						$found = True
						;FileWrite($hFileNew, $hash & ' *' & $FILENAME & @CRLF)
					Else
						FileWrite($hFileNew, $test & @CRLF)
					EndIf
				EndIf
			Until $exit = -1
			FileClose($hFile)
		EndIf
	EndIf
	;If Not $found And $FILENAME <> $MD5File Then FileWrite($hFileNew, $hash & ' *' & $FILENAME & @CRLF)
	FileClose($hFileNew)
	FileMove(@ScriptDir & '~NewHash.md5', $MD5File, 9)
EndFunc

Func _MD5Write2File($hash, $FILENAME, $MD5File = '')
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|_MD5Write2File(): $FILENAME=' & $FILENAME & @CRLF)
	Local $found = False, $hFileNew = FileOpen(@ScriptDir & '~NewHash.md5', 9)
	If $MD5File = '' Then $MD5File = $FILENAME & '.md5'
	If FileExists($MD5File) Then
		Local $hFile = FileOpen($MD5File, 0), $test, $exit = False
		If $hFile <> -1 Then
			Do
				$test = FileReadLine($hFile)
				$exit = (@error = -1)
				If Not $exit Then
					If StringMid($test, StringInStr($test, ' ') + 2) = $FILENAME Then
						$found = True
						FileWrite($hFileNew, $hash & ' *' & $FILENAME & @CRLF)
					Else
						FileWrite($hFileNew, $test & @CRLF)
					EndIf
				EndIf
			Until $exit = -1
			FileClose($hFile)
		EndIf
	EndIf
	If Not $found And $FILENAME <> $MD5File Then FileWrite($hFileNew, $hash & ' *' & $FILENAME & @CRLF)
	FileClose($hFileNew)
	FileMove(@ScriptDir & '~NewHash.md5', $MD5File, 9)
EndFunc
#endregion

#region ;**** MouseCursor.Support ****
Func API($v_ret)
	Local $err = @error, $Ext = @extended
	If Not $err Then
		If IsArray($v_ret) Then
			Return $v_ret[0]
		Else
			Return $v_ret
		EndIf
	EndIf
	Return SetError($err, $Ext, 0)
EndFunc

Func CursorWait($hOrigCur = False)
	If $hOrigCur Then
		Return SetCursor($hOrigCur)
	Else
		Return SetCursor(LoadCursor($OCR_WAIT))
	EndIf
EndFunc

Func LoadCursor($iCursor)
	Return API(DllCall('user32.dll', 'int', 'LoadCursorA', 'hwnd', 0, 'int', $iCursor))
EndFunc

Func SetCursor($hCursor)
	Return API(DllCall('user32.dll', 'int', 'SetCursor', 'int', $hCursor))
EndFunc
#endregion
#cs ;Common header
	#NoTrayIcon
	#region
	#AutoIt3Wrapper_Icon=SetupS.ico
	#AutoIt3Wrapper_Outfile=Tools\SetupS.Core.exe
	#AutoIt3Wrapper_Res_Description=SetupS Project Core (Common Declarations & Functions)
	#AutoIt3Wrapper_Res_Fileversion=#ProjectVersion#
	#AutoIt3Wrapper_Res_LegalCopyright=� #cYear# #cHolder#
	#AutoIt3Wrapper_Res_Language=1033
	#AutoIt3Wrapper_Res_Field=Release Date|#ProjectDate#
	#AutoIt3Wrapper_Res_Field=#WebSite1#|http://#WebLink1#
	#AutoIt3Wrapper_Res_Field=#WebSite2#|http://#WebLink2#
	#AutoIt3Wrapper_Res_Field=#WebSite3#|http://#WebLink3#
		#AutoIt3Wrapper_Res_Field=#WebSite6#|http://#WebLink6#
	#AutoIt3Wrapper_Res_Field=Original Concept|Glenn L. Chugg (ReturnOfNights)
	#AutoIt3Wrapper_Compression=4
	#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
	#AutoIt3Wrapper_Run_Tidy=y
	#Tidy_Parameters=/pr=1 /uv=3 /tc=0 /sf /reel /refc /rerc /kv=100
	;~ 	#AutoIt3Wrapper_Run_Obfuscator=y
	;~ 	#Obfuscator_Parameters=/mergeonly
	#AutoIt3Wrapper_UseX64=n
	#endregion
#ce
;~ End Of File

