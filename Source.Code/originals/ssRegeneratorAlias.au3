#NoTrayIcon
#region
#AutoIt3Wrapper_Icon=Tiny.ico
#AutoIt3Wrapper_Outfile=Tools\Regenerator.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=Alias for SetupS Regenerator
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

Local $CLIparameters = $CMDLine
Run('ssRegenerator ' & ReconstructCmdLine($CLIparameters), '.', @SW_HIDE)

Func ReconstructCmdLine(ByRef $CLIparameters)
;~ 	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core.au3|ReconstructCmdLine()' & @CRLF)
	Local $i, $Temp = ''
	For $i = 1 To $CLIparameters[0]
		$Temp = $Temp & ' ' & $CLIparameters[$i]
	Next
	Return StringStripWS($Temp, 3)
EndFunc
