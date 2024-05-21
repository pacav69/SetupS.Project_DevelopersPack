#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Au3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/pr=1 /uv=3 /tc=0 /sf /reel /refc /rerc /kv=10
#EndRegion
#include-once
;main UDF ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#Region
Global $Abort7z = False

Func _7zRead($sCmd, $sParam, $7zProcessPriority = 0, $iProgress = "", $sProgress = "", $sProgressSubText = "", $iStatic = "", $iStaticText = "", $nShow = @SW_HIDE, $WorkingDir = "")
	;   Function:       _7zRead
	;   Description:    Reads progress from 7zip window and sets control data
	;   Parameters:     $sCmd = 7zip Commandline to be executed
	;                   $iProgress = [optional] ControlID of Progress Control to be updated (if none, use "")
	;                   $sProgress = [optional] 1 if Progress Bar Window has to be updated, "" if not
	;                   $sProgressSubText = [optional] 1 if Progress Bar Subtext to be written, "" if not
	;                   $iStatic = [optional] ControlID of a Static Control (label, button etc pp) to be updated (if none, use "")
	;                   $iStaticText = [optional] Text for $iStatic, the percentage will be added
	;                   $nShow = [optional] Flag for 7zip window, default is @SW_HIDE
	;   Author:         jennico (http://www.autoitscript.com/forum/index.php?showtopic=91283), basic script by valik
	;   Note:           You can run the script as .au3 or #include it, but it cannot be run from SciTe.
	Local $iPID = Run(@ComSpec & ' /c ' & FileGetShortName($sCmd) & ' ' & $sParam, $WorkingDir, $nShow), $nPercent
	ProcessSetPriority($iPID, $7zProcessPriority)
	ProcessWait($iPID)
	If $iStatic Then GUICtrlSetData($iStatic, $iStaticText & "0%")
	Local $hPercent = Open7ZipPercent($iPID), $opercent = -1
	While ProcessExists($iPID)
		$nPercent = Read7ZipPercent($hPercent)
		If $nPercent >= 0 And $opercent <> $nPercent Then
			If $sProgressSubText Then $sProgressSubText = $nPercent
			If $sProgress <> "" Then ProgressSet($nPercent, $nPercent & "%" & $sProgress)
			If $iProgress Then GUICtrlSetData($iProgress, $nPercent)
			If $iStatic Then GUICtrlSetData($iStatic, $iStaticText & $nPercent & '%')
			$opercent = $nPercent
		Else
			Sleep(50)
		EndIf
	WEnd
	Close7ZipPercent($hPercent)
	If $iPID = ProcessExists(StringRight($sCmd, StringLen($sCmd) - StringInStr($sCmd, '\', -1, -1))) Then ProcessClose($iPID)
EndFunc

Func _AttachConsole($nPid)
	Local $aRet = DllCall("Kernel32.dll", "int", "AttachConsole", "dword", $nPid)
	If @error Then Return SetError(@error, @extended, False)
	Return $aRet[0]
EndFunc

Func _GetConsoleScreenBufferInfo($hConsoleOutput, $pConsoleScreenBufferInfo)
	Local $aRet = DllCall("Kernel32.dll", "int", "GetConsoleScreenBufferInfo", "hwnd", $hConsoleOutput, "ptr", _SafeGetPtr($pConsoleScreenBufferInfo))
	If @error Then Return SetError(@error, @extended, False)
	Return $aRet[0]
EndFunc

Func _GetStdHandle($nHandle)
	Local $aRet = DllCall("Kernel32.dll", "hwnd", "GetStdHandle", "dword", $nHandle)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aRet[0]
EndFunc

Func _ReadConsoleOutput($hConsoleOutput, $pBuffer, $pSmallRect);, 65540, 0,
	Local $aRet = DllCall("Kernel32.dll", "int", "ReadConsoleOutputW", "ptr", $hConsoleOutput, "int", _SafeGetPtr($pBuffer), "int", 65540, "int", 0, "ptr", _SafeGetPtr($pSmallRect))
	If @error Then SetError(@error, @extended, False)
	Return $aRet[0]
EndFunc

Func _SafeGetPtr(Const ByRef $PTR)
	Local $_ptr = DllStructGetPtr($PTR)
	If @error Then $_ptr = $PTR
	Return $_ptr
EndFunc

Func Close7ZipPercent(ByRef $vHandle)
	If UBound($vHandle) <> 4 Then Return False
	DllCall("Kernel32.dll", "int", "FreeConsole")
	$vHandle = 0
	Return True
EndFunc

Func Open7ZipPercent($pid)
	If _AttachConsole($pid) = 0 Then Return
	Local $vHandle[4]
	$vHandle[0] = _GetStdHandle(-11)
	$vHandle[1] = DllStructCreate("short dwSizeX; short dwSizeY;short dwCursorPositionX; short dwCursorPositionY; short wAttributes;short Left; short Top; short Right; short Bottom; short dwMaximumWindowSizeX; short dwMaximumWindowSizeY")
	$vHandle[2] = DllStructCreate("dword[4]")
	$vHandle[3] = DllStructCreate("short Left; short Top; short Right; short Bottom")
	Return $vHandle
EndFunc

Func Read7ZipPercent(ByRef $vHandle)
	If UBound($vHandle) = 4 Then
		Local Const $hStdOut = $vHandle[0]
		Local Const $pConsoleScreenBufferInfo = $vHandle[1]
		Local Const $pBuffer = $vHandle[2]
		Local Const $pSmallRect = $vHandle[3]
		local $test
		If _GetConsoleScreenBufferInfo($hStdOut, $pConsoleScreenBufferInfo) Then
			;DllStructSetData($pSmallRect, "Left", DllStructGetData($pConsoleScreenBufferInfo, "dwCursorPositionX") - 4) ; 7-Zip v9.20
			DllStructSetData($pSmallRect, "Left", 0) ; 7-Zip v15.12
			DllStructSetData($pSmallRect, "Top", DllStructGetData($pConsoleScreenBufferInfo, "dwCursorPositionY"))
			DllStructSetData($pSmallRect, "Right", DllStructGetData($pConsoleScreenBufferInfo, "dwCursorPositionX"))
			DllStructSetData($pSmallRect, "Bottom", DllStructGetData($pConsoleScreenBufferInfo, "dwCursorPositionY"))
			$test=DllStructGetData($pConsoleScreenBufferInfo, "dwCursorPositionX")
			If _ReadConsoleOutput($hStdOut, $pBuffer, $pSmallRect) Then
				Local $sPercent = ""
				For $i = 0 To 3
					Local $pCharInfo = DllStructCreate("wchar UnicodeChar; short Attributes", DllStructGetPtr($pBuffer) + ($i * 4))
					$sPercent &= DllStructGetData($pCharInfo, "UnicodeChar")
				Next
				If StringRight($sPercent, 1) = "%" Then Return Number($sPercent)
			EndIf
		EndIf
	EndIf
	Return -1
EndFunc

Func Stop7z()
	$Abort7z = True
	ProcessClose("7z.exe")
EndFunc
#EndRegion