#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Fileversion=0.0.0.3
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/pr=1 /uv=3 /tc=0 /sf /reel /refc /rerc /kv=100
#endregion

;~ #include <File.au3>
#include <Array.au3>
Local $CLIprefix = @ComSpec & ' /c ', $CLIparameters = $CMDLine, $cmd = ''
Local $FTP_File = @ScriptDir & '\..\Accounts.ini'
Local $Outfile = @ScriptDir & '\..\UploadMewinscp.cmd'

If Not @Compiled Then
	$CLIparameters[0] += 1
	ReDim $CLIparameters[$CLIparameters[0] + 1]
	$CLIparameters[$CLIparameters[0]] = 'kill'
EndIf
;_ArrayDisplay($CLIparameters)

If $CLIparameters[0] > 0 Then
	Local $i, $j, $l, $FTP_Site = $CLIparameters[1]
	Local $FTP_Type = IniRead($FTP_File, $FTP_Site, 'Type', '')
	Local $FTP_Domain = IniRead($FTP_File, $FTP_Site, 'Domain', '')
	Local $FTP_Username = IniRead($FTP_File, $FTP_Site, 'Username', '')
	Local $FTP_Password = IniRead($FTP_File, $FTP_Site, 'Password', '')
	If $FTP_Type & $FTP_Domain & $FTP_Username & $FTP_Password <> '' Then
		$cmd = File2String(@ScriptDir & '\templates\' & $FTP_Type & '.cmd')
		$cmd = StringReplace($cmd, '#Domain#', $FTP_Domain)
		$cmd = StringReplace($cmd, '#Site#', $FTP_Domain)
		$cmd = StringReplace($cmd, '#Username#', $FTP_Username)
		$cmd = StringReplace($cmd, '#Account#', $FTP_Username)
		$cmd = StringReplace($cmd, '#Password#', $FTP_Password)
	EndIf
EndIf
String2File($cmd, $Outfile)
Exit

Func File2String($What)
	Local $temp = ''
	If FileExists($What) Then
		Local $File = FileOpen($What, 0)
		If $File <> -1 Then
			$temp = FileRead($File)
			FileClose($File)
		EndIf
	EndIf
	Return $temp
EndFunc

Func GetFilename($What)
	If StringInStr($What, '/', -1, -1) Then Return StringRight($What, StringLen($What) - StringInStr($What, '/', -1, -1))
	Return StringRight($What, StringLen($What) - StringInStr($What, '\', -1, -1))
EndFunc

Func GetFolderPath($What)
	If StringInStr($What, '/', -1, -1) Then Return StringLeft($What, StringInStr($What, '/', -1, -1) - 1)
	Return StringLeft($What, StringInStr($What, '\', -1, -1) - 1)
EndFunc

Func String2File($StrIn, $What)
	If StringRight($What, 4) = '.reg' Then ;add header if not present
		Local $header = 'Windows Registry Editor Version 5.00'
		If Not (StringLeft($StrIn, StringLen($header)) = $header Or StringLeft($StrIn, StringLen('REGEDIT4')) = 'REGEDIT4') Then
			$StrIn = $header & @CRLF & @CRLF & $StrIn
		EndIf
	EndIf
	Local $File = FileOpen($What, 10) ;Write mode (erase previous contents)
	If $File <> -1 Then
		FileWrite($File, $StrIn)
		FileClose($File)
		Return True
	EndIf
	Return False
EndFunc
