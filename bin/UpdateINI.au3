#NoTrayIcon
#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Au3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/pr=1 /uv=3 /tc=0 /sf /reel /refc /rerc /kv=100
#endregion
#include <..\Source.Code\SetupS.Core.au3>

If Not @Compiled Then
	If $CLIparameters[0] = 0 Then
		$CLIparameters[0] += 1
		ReDim $CLIparameters[$CLIparameters[0] + 1]
		$CLIparameters[$CLIparameters[0]] = 'D:\ssTEK.Projects\SetupS.Sendto.Suite\vCurrent\Source.Code'

		$CLIparameters[0] += 1
		ReDim $CLIparameters[$CLIparameters[0] + 1]
		$CLIparameters[$CLIparameters[0]] = 'exe'

		$CLIparameters[0] += 1
		ReDim $CLIparameters[$CLIparameters[0] + 1]
		$CLIparameters[$CLIparameters[0]] = 'sstek.vergitek.com/files'
	EndIf
EndIf

If $CLIparameters[0] = 3 Then
	Local $ssConfigINI = '..\Source.Code\default.ini\ssConfig.ini'
	GetSetupSOptions($ssConfigINI)
	If ($RepoLink = '' And $BackupRepoLink = '') Or $RepoLink = $BackupRepoLink Or $RepoLink = 'http://sstek.googlecode.com/files' Then
		$RepoLink = 'http://sstek.vergitek.com/files'
		$BackupRepoLink = 'http://www.lastos.org/files'
	EndIf
	If Not GetUpdateINI($RepoLink & '/update.ini') Then GetUpdateINI($BackupRepoLink & '/update.ini')
	If FileExists('..\update.ini') Then
		_AppReset()
		$App_File = _AppRead($CLIparameters[1], False, True)
		If $App_File <> '' Then
			$App_Version = StringReplace($App_Version, '#ProjectVersion#', '8.13.2.11')
			Local $SectionName = $App_Title & '_' & $App_BuildType, $MD5
			Local $n = StringReplace($App_Title, ' ', '.'), $Ext = $CLIparameters[2], $Download = $CLIparameters[3]
			If StringLeft($Download, 7) <> 'http://' Then $Download = 'http://' & $Download
			If StringLeft($Ext, 1) <> '.' Then $Ext = '.' & $Ext
			If $App_Version <> '' Then $n = $n & '_' & StringReplace($App_Version, ' ', '.')
			Switch $App_OS
				Case 1
					$n = $n & '_NT5'
				Case 2
					$n = $n & '_NT6'
				Case 3
					$n = $n & '_Linux'
			EndSwitch
			Switch $App_Architecture
				Case 1
					$n = $n & '_x86'
				Case 2
					$n = $n & '_x64'
				Case 3
					$n = $n & '_DualArch'
			EndSwitch
			$n = StringFilterFilename($n & '_' & $App_BuildType & $Ext)
			$n = MakeSafeFilename($n, '.php')
			$n = MakeSafeFilename($n, '.html')
			$n = MakeSafeFilename($n, '.htm')
			If FileExists(@ScriptDir & '\..\' & $n) Then
				_Crypt_Startup()
				$MD5 = _MD5Calc(@ScriptDir & '\..\' & $n)
				_Crypt_Shutdown()
			EndIf
			If $MD5 <> '' Then
				IniWrite('..\update.ini', $SectionName, 'Version', $App_Version)
				IniWrite('..\update.ini', $SectionName, 'Update', $n)
				IniWrite('..\update.ini', $SectionName, 'Download', $Download)
				IniWrite('..\update.ini', $SectionName, 'MD5', StringStripWS($MD5, 3))
			EndIf
		EndIf
	EndIf
EndIf

Func GetUpdateINI($UpdateLink, $Attend = False)
;~ 	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupScp.au3|UpdateMe(): $UpdateLink = ' & $UpdateLink & ' : $App_Title = ' & $App_Title & ' : $App_Version = ' & $App_Version & ' : $Attend = ' & $Attend & @CRLF)
	If $UpdateLink = '' Then Return False ;'Update.ini fail'
	Local $aData = DownloadFile($UpdateLink, '..\update.ini', $Attend, False)
	If IsArray($aData) And $aData[3] Then Return True
	Return False
EndFunc
